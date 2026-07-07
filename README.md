# Kafka & Security Lab

Event-driven notification system on Kubernetes with Kafka (Strimzi) & KEDA autoscaling — secured with Trivy, Checkov, Kyverno, Falco & Velero.

This project combines a real event-driven architecture (Kafka + KEDA scale-to-zero autoscaling) with a full DevSecOps pipeline (shift-left scanning, admission control, runtime security, and disaster recovery), deployed via GitOps (ArgoCD) on Azure Kubernetes Service.

---

## Architecture

```
                    ┌─────────────┐
   HTTP POST        │             │
──────────────────▶ │  Producer   │
   /notify          │  (Go/Gin)   │
                    └──────┬──────┘
                           │ writes
                           ▼
                  ┌──────────────────┐
                  │  Kafka Topic:     │
                  │  notifications    │        (Strimzi, KRaft mode,
                  │  (3 partitions)   │         single-broker)
                  └────────┬─────────┘
                           │ reads (consumer group)
                           ▼
                  ┌──────────────────┐
                  │   Consumer        │
                  │  (retry + backoff)│──────▶ SMTP (email delivery)
                  └────────┬─────────┘
                           │ on failure after max retries
                           ▼
                  ┌──────────────────┐
                  │  Kafka Topic:     │
                  │  notifications-dlq│
                  └────────┬─────────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │  DLQ Handler      │
                  │  (logs failures)  │
                  └──────────────────┘

   KEDA watches consumer-group lag on `notifications` topic and
   scales the Consumer deployment between 0 and 3 replicas
   (matching the topic's partition count).
```

**Security layers wrapping the above:**

| Layer | Tool | When |
|---|---|---|
| Shift-left (IaC & image scanning) | Trivy, Checkov | Before deploy (CI) |
| Admission control | Kyverno | At deploy time |
| Runtime security | Falco | After deploy (continuous) |
| Backup / DR | Velero | Scheduled + on-demand |

---

## Tech Stack

| Category | Technology |
|---|---|
| Messaging | Apache Kafka (Strimzi operator, KRaft mode) |
| Autoscaling | KEDA (Kafka lag-based, scale-to-zero) |
| Infrastructure | Terraform (Azure: AKS, ACR, Key Vault, VNet, Storage) |
| Container orchestration | Azure Kubernetes Service (AKS) |
| App packaging | Helm |
| GitOps | ArgoCD (App of Apps pattern) |
| CI | GitHub Actions |
| Image/IaC scanning | Trivy, Checkov |
| Admission policy | Kyverno |
| Runtime security | Falco |
| Backup & DR | Velero |
| Secrets | Azure Key Vault + Workload Identity (CSI driver) |
| Apps | Go (producer, consumer, dlq-handler) |

---

## Prerequisites

- Azure subscription
- `az` CLI (logged in)
- `kubectl`
- `helm`
- `terraform` (>= 1.9.0)
- `docker`
- `velero` CLI (for backup/restore operations)

---

## Getting Started

> ⚠️ This project targets a low-cost Azure environment. Review `docs/security-decisions.md` for cost-vs-security tradeoffs before deploying to anything beyond a personal lab.

### 1. Provision infrastructure

```bash
cd terraform/environments/dev
terraform init
terraform apply
az aks get-credentials --resource-group rg-kafka-lab-dev --name aks-kafka-lab-dev
```

### 2. Install cluster-level tools (one-time bootstrap)

```bash
# Strimzi operator
kubectl apply -f kafka/namespace.yaml
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka

# KEDA
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda --namespace keda --create-namespace

# Kyverno
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
kubectl apply -f security/kyverno/policies/

# Falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco --namespace falco --create-namespace \
  --set tty=true --set-file customRules."custom-rules\.yaml"=security/falco/custom-rules.yaml

# ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side
```

### 3. Deploy Kafka cluster and topics

```bash
kubectl apply -f kafka/strimzi/kafka-cluster.yaml
kubectl apply -f kafka/strimzi/kafka-topics.yaml
```

### 4. Bootstrap GitOps (ArgoCD takes over from here)

```bash
kubectl apply -f app-of-apps.yaml
```

ArgoCD will then sync `notification-system`, `velero`, `velero-schedule`, and Kyverno policies automatically from Git.

### 5. Validate end-to-end

```bash
kubectl port-forward -n notifications svc/producer 8080:8080 &
curl -X POST localhost:8080/notify \
  -H "Content-Type: application/json" \
  -d '{"email":"you@example.com","message":"hello from kafka-and-security-lab"}'
```

Check consumer logs to confirm delivery:
```bash
kubectl logs -n notifications deployment/consumer --tail=20
```

### 6. Tear down (cost control)

```bash
cd terraform/environments/dev
terraform destroy
```

See `scripts/destroy.sh` for a scripted version of the full teardown.

---

## Repository Structure

```
.
├── apps/                  # Go source for producer, consumer, dlq-handler
├── argocd/                # ArgoCD Application manifests (App of Apps)
├── docs/                  # Architecture, DLQ pattern, security decisions
├── helm/notification-system/  # Helm chart for the three apps
├── kafka/strimzi/         # Kafka cluster + topic CRDs
├── security/
│   ├── falco/             # Custom Falco rules
│   └── kyverno/policies/  # Admission control policies
├── terraform/             # Infrastructure as Code (Azure)
├── velero/                # Backup schedule + restore runbook
├── scripts/               # deploy.sh / destroy.sh helpers
└── .github/workflows/     # CI pipelines
```

---

## Further Reading

- [`docs/architecture.md`](docs/architecture.md) — detailed architecture walkthrough
- [`docs/dlq-pattern.md`](docs/dlq-pattern.md) — dead-letter queue design and retry logic
- [`docs/security-decisions.md`](docs/security-decisions.md) — Checkov findings: fixed vs. accepted risk, with rationale
- [`velero/restore-runbook.md`](velero/restore-runbook.md) — disaster recovery restore procedure

---

## License

See [LICENSE](LICENSE).