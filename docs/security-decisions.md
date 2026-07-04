# Security Scan Decisions (Checkov)

This document records which Checkov findings were fixed vs. accepted as
known risk for this lab environment, and why.

## Terraform — Fixed

| Check | Description | Fix |
|---|---|---|
| CKV_AZURE_168 | Nodes should use minimum 50 pods | Set `max_pods = 110` explicitly on the node pool |
| CKV_AZURE_109 | Key Vault firewall rules | Added `network_acls` restricting access to the AKS subnet + operator's IP |

## Terraform — Accepted Risk

| Check | Description | Reason |
|---|---|---|
| CKV_AZURE_139, 164, 165, 166, 167, 233, 237 | ACR: public network disable, signed images, geo-replication, zone redundancy, quarantine, dedicated endpoints, retention policy | All require **Premium SKU**. Not justified for a single-region lab environment with cost constraints. |
| CKV_AZURE_115 | AKS private cluster | Would block direct `kubectl` access from a local workstation, which this lab relies on for iteration speed. |
| CKV_AZURE_6 | AKS API server authorized IP ranges | Same reasoning — adds friction for a lab environment with a single operator and dynamic IP. |
| CKV_AZURE_117, 227 | Disk encryption set / host encryption | Requires customer-managed keys; adds cost/complexity disproportionate to a lab. Platform-managed encryption (default) is already in place. |
| CKV_AZURE_226 | Ephemeral OS disks | Requires specific VM SKUs with local temp disk large enough; current `Standard_D2s_v3` does not qualify without a larger (costlier) SKU. |
| CKV_AZURE_170 | AKS Paid SKU (SLA) | Free tier control plane is a deliberate cost-control decision (see terraform module comments). |
| CKV_AZURE_171 | AKS upgrade channel | Cluster is ephemeral (destroyed after each session via `terraform destroy`); a weekly upgrade schedule has no practical effect. |
| CKV_AZURE_4 | AKS logging to Azure Monitor | Requires a Log Analytics Workspace, adding cost. Cluster lifetime is short-lived per session. |
| CKV_AZURE_232 | Only critical pods on system nodes | Would require a second (user) node pool, adding cost. Single node pool is intentional for this lab's scale. |
| CKV_AZURE_116 | Azure Policy Add-on | Deliberately replaced by **Kyverno** (see `security/kyverno/`), which serves the same admission-control purpose with more granular, Kubernetes-native policies. |
| CKV_AZURE_110, 42 | Key Vault purge protection / recoverability | Deliberately disabled (`purge_protection_enabled = false`) to allow clean `terraform destroy`/recreate cycles between sessions without waiting out a retention period. |
| CKV2_AZURE_32 | Key Vault private endpoint | Would require additional private DNS zone + VNet integration complexity disproportionate to this lab's single-subnet design. Network ACLs (fixed above) provide a lighter-weight equivalent for this scale. |
| CKV2_AZURE_31 | Subnet NSG | AKS NetworkPolicy (see `helm/notification-system/templates/network-policy.yaml`) already provides pod-level traffic control with finer granularity than a subnet-level NSG would add. |

## Kubernetes/Helm — Fixed

| Check | Description | Fix |
|---|---|---|
| CKV_K8S_20, 23, 29, 30, 22, 28, 37, 31, 40 | Various pod/container security context checks | Added `securityContext` (non-root UID 10001, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities.drop: [ALL]`, `seccompProfile: RuntimeDefault`) to all three deployments (producer, consumer, dlq-handler). Updated Dockerfiles to create a high, explicit UID. |
| CKV_K8S_15 | Image pull policy should be Always | Added `imagePullPolicy: Always` to all three deployments |
| CKV_K8S_38 | Service account tokens only mounted where necessary | Added `automountServiceAccountToken: false` to producer and dlq-handler (neither calls the Kubernetes API) |

## Kubernetes/Helm — Accepted Risk

| Check | Description | Reason |
|---|---|---|
| CKV_K8S_38 (consumer only) | Service account token auto-mount | Consumer legitimately needs its ServiceAccount token for Azure Workload Identity federation (Key Vault access via CSI driver). This is a false positive from Checkov's perspective — the token is required, not incidental. |
| CKV_K8S_43 | Image should use digest | Using mutable tags (`v1`) instead of SHA256 digests for simplicity during manual deployment iteration. Will be revisited if/when CI pins digests automatically (see Phase 9 CI/CD). |
| CKV_K8S_8, 9 | Liveness/Readiness probes | dlq-handler and consumer have no HTTP endpoint (Kafka consumer loop only); standard HTTP probes don't apply. An exec-based probe was considered but deemed disproportionate complexity for this lab's scope. |
| CKV_K8S_35 | Prefer secrets as files over env vars | SMTP credentials are injected via `secretKeyRef` (standard Kubernetes Secret env var pattern) rather than mounted files. Accepted because: (1) this is standard, widely-used Kubernetes practice, (2) the CSI-mounted volume already exists for other purposes, and (3) anyone with access to pod crash dumps or `/proc` on this cluster already has cluster-admin-equivalent access. |