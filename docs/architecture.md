# Architecture

This document describes the technical design of the Kafka & Security Lab
in more depth than the top-level README.

## 1. Event-Driven Flow

```
Producer (HTTP API) → Kafka topic `notifications` → Consumer (SMTP) → success
                                                              │
                                                              └─ on failure → Kafka topic `notifications-dlq` → DLQ Handler (logs)
```

### Producer
- Go service using Gin, exposing `POST /notify` and `GET /healthz`.
- Validates `email` and `message`, writes the payload to the `notifications`
  topic using the email as the partition key (so retries/ordering for a
  given recipient stay on the same partition).
- Stateless — scales horizontally via a standard Kubernetes HPA
  (CPU-based, 2–5 replicas).

### Kafka (Strimzi)
- Deployed via the Strimzi operator using `KafkaNodePool` + `Kafka` CRDs
  in KRaft mode (no Zookeeper).
- Single broker (`replicas: 1`) combining broker + controller roles —
  appropriate for a lab environment where the cluster is destroyed and
  recreated between sessions, not for production HA requirements.
- `notifications` topic: 3 partitions (sized to give KEDA/consumer
  scaling something meaningful to scale against).
- `notifications-dlq` topic: 1 partition (no need for parallelism on
  the failure path).
- Storage is `ephemeral` — no PersistentVolume. Message data does not
  survive a broker restart, which is an intentional cost/complexity
  tradeoff (see `docs/security-decisions.md`).

### Consumer
- Reads from `notifications` with consumer group
  `notification-consumer-group`.
- Attempts SMTP delivery with exponential backoff (configurable via
  `MAX_RETRIES` / `RETRY_BASE_DELAY_MS`).
- On exhausting retries, publishes a structured failure record
  (original email/message + error + timestamp) to `notifications-dlq`
  and commits the original offset either way — the pipeline never
  blocks on a single bad message.
- Scaled by KEDA (not a standard HPA) — see section 3.

### DLQ Handler
- Independent consumer group (`dlq-handler-group`) reading
  `notifications-dlq`.
- Currently observability-only (structured logging). This is the
  natural place to add alerting (Slack/webhook) or persistent storage
  for manual triage in a production iteration.

## 2. Secrets Management

SMTP credentials are stored in Azure Key Vault and injected into the
consumer pod via:

1. **Workload Identity federation** — a user-assigned managed identity
   is granted `Key Vault Secrets User` and federated to the
   `notification-apps` Kubernetes ServiceAccount (via OIDC issuer on
   the AKS cluster).
2. **Secrets Store CSI Driver** — a `SecretProviderClass` pulls the
   four SMTP secrets from Key Vault and syncs them into a Kubernetes
   `Secret` (`smtp-credentials`), which the consumer reads via
   `secretKeyRef` environment variables.

This means the actual secret values never pass through Terraform state,
Helm values, or Git — only the *mechanism* to fetch them is version
controlled.

## 3. Autoscaling

Two independent autoscaling mechanisms are used, for different reasons:

| Component | Mechanism | Trigger | Range |
|---|---|---|---|
| Producer | Standard Kubernetes HPA | CPU utilization | 2–5 replicas |
| Consumer | KEDA `ScaledObject` | Kafka consumer-group lag | 0–3 replicas |
| AKS node pool | Cluster Autoscaler | Pod scheduling pressure | 2–3 nodes |

The consumer specifically needs KEDA (not a plain HPA) because its
natural scaling signal is *lag on the Kafka topic*, not CPU — and
because scale-to-zero (`minReplicaCount: 0`) is only meaningful when
the trigger can also detect "no work" and scale back down, which a
CPU-based HPA cannot do reliably for an idle, low-CPU consumer.

Because KEDA writes directly to `spec.replicas` on the consumer
Deployment, the ArgoCD Application for `notification-system` explicitly
ignores differences on that field (see
`argocd/notification-system-app.yaml`) to avoid ArgoCD and KEDA fighting
over ownership of the same field. All other fields (image, env,
resources, etc.) remain fully GitOps-managed.

## 4. Security Layers

The project applies defense-in-depth across the full lifecycle of a
deployment, rather than relying on a single tool:

| Stage | Tool | What it checks |
|---|---|---|
| Shift-left (pre-deploy) | Trivy | Container image vulnerabilities (OS packages + Go dependencies) |
| Shift-left (pre-deploy) | Checkov | Terraform and Kubernetes/Helm misconfigurations |
| Admission (deploy-time) | Kyverno | Enforces non-root, resource limits, no privileged containers |
| Runtime (post-deploy) | Falco | Detects unexpected shell spawns, filesystem writes, and outbound connections |
| Backup / DR | Velero | Scheduled + on-demand backup and restore of cluster state |

Kyverno policies exclude infrastructure namespaces (`kube-system`,
`kyverno`, `falco`, `velero`, `argocd`) because tools like Falco
legitimately require privileged access to do their job (monitoring
syscalls across other containers) — the policies are scoped to
application workloads, not the security tooling itself.

See `docs/security-decisions.md` for the full list of Checkov findings,
which were fixed, and which were consciously accepted as risk (with
rationale) for this lab's scale and cost constraints.

## 5. Infrastructure (Terraform)

Five Terraform modules, composed in `terraform/environments/dev`:

| Module | Purpose |
|---|---|
| `resource-group` | Base resource group |
| `vnet` | Single subnet for AKS nodes |
| `aks` | AKS cluster (2–3 node autoscaling, Azure CNI Overlay, workload identity, Key Vault CSI addon) |
| `acr` | Container registry (Standard SKU) with `AcrPull` granted to the AKS kubelet identity |
| `keyvault` | Secrets store, RBAC-authorized, network-restricted to the AKS subnet + operator IP |
| `velero-storage` | Storage account + blob container for Velero backups |

State is stored remotely in Azure Storage (`tfstate-rg`), separate from
the lab's own resource group so it survives `terraform destroy` cycles
of the lab infrastructure itself.

## 6. GitOps (ArgoCD)

An "App of Apps" pattern is used: a single root `Application`
(`app-of-apps.yaml`) points at the `argocd/` directory, which contains
one `Application` per concern:

| Application | Source | Notes |
|---|---|---|
| `notification-system` | This repo, `helm/notification-system` | The three Go apps |
| `kafka` | This repo, `kafka/` | `Kafka` and `KafkaTopic` CRDs (not the Strimzi operator itself — that's a one-time bootstrap) |
| `kyverno` / `kyverno-policies` | Upstream chart / this repo | Split so the tool and the policies can evolve independently |
| `falco` | Upstream chart + `security/falco/values.yaml` (multi-source) | Custom rules live in this repo, chart comes from upstream |
| `velero` / `velero-schedule` | Upstream chart / this repo | Same split rationale as Kyverno |

Tools that require a one-time cluster bootstrap before GitOps can take
over (Strimzi operator CRDs, ArgoCD itself) are intentionally *not*
GitOps-managed — they are installed once via `kubectl create`/`helm
install` per the README's "Getting Started" steps.

## 7. CI/CD

- **CI** (`.github/workflows/build-and-scan.yaml`): on push to `apps/**`,
  builds each of the three images, scans with Trivy (fails the build on
  HIGH/CRITICAL vulnerabilities) and Checkov (soft-fail, informational),
  pushes to ACR tagged with the short git SHA, then commits the updated
  tag back into `helm/notification-system/values.yaml`.
- **CD** (ArgoCD): watches `master` and automatically syncs the updated
  `values.yaml`, rolling out the new image — no manual `kubectl apply`
  or `helm upgrade` involved after the initial bootstrap.
- **Terraform CI** (`.github/workflows/terraform-plan.yaml`): runs
  Checkov and `terraform plan` on every change under `terraform/**`.