<div align="center">
<img src="https://cdn.simpleicons.org/apachekafka/231F20" width="60" alt="Kafka" />
&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/kubernetes/326CE5" width="60" alt="Kubernetes" />
&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/terraform/844FBA" width="60" alt="Terraform" />
&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/argo/EF7B4D" width="60" alt="ArgoCD" />
&nbsp;&nbsp;&nbsp;
<img src="https://cdn.simpleicons.org/falco/00AEC7" width="60" alt="Falco" />
&nbsp;&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/github/explore/main/topics/azure/azure.png" width="60" alt="Azure" />


# kafka-and-security-lab
**Event-driven notification system on Kubernetes with Kafka (Strimzi) & KEDA autoscaling — secured with Trivy, Checkov, Kyverno, Falco & Velero**

![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA?style=flat-square&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Kafka](https://img.shields.io/badge/Messaging-Kafka-231F20?style=flat-square&logo=apachekafka&logoColor=white)
![KEDA](https://img.shields.io/badge/Autoscaling-KEDA-3C7FE7?style=flat-square)
![Helm](https://img.shields.io/badge/Helm-v3-0F1689?style=flat-square&logo=helm&logoColor=white)
![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?style=flat-square&logo=argo&logoColor=white)
![Trivy](https://img.shields.io/badge/Scan-Trivy-1904DA?style=flat-square)
![Checkov](https://img.shields.io/badge/IaC%20Scan-Checkov-4287f5?style=flat-square)
![Kyverno](https://img.shields.io/badge/Admission-Kyverno-3D8FD8?style=flat-square)
![Falco](https://img.shields.io/badge/Runtime-Falco-00AEC7?style=flat-square&logo=falco&logoColor=white)
![Velero](https://img.shields.io/badge/Backup-Velero-4E5EE4?style=flat-square)
![Go](https://img.shields.io/badge/Go-App-00ADD8?style=flat-square&logo=go&logoColor=white)
![Azure](https://img.shields.io/badge/Cloud-Azure-0078D4?style=flat-square)
</div>

---

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

---

<div align="center">
<sub>Part of a DevOps portfolio — <a href="https://github.com/amirhosssein0/terraform-lab">terraform-lab</a> | <a href="https://github.com/amirhosssein0/vault-cicd-lab">vault-cicd-lab</a></sub>
</div>