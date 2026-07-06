# Velero Restore Runbook

This runbook describes how to restore the `notifications` and `kafka`
namespaces from a Velero backup, for disaster recovery scenarios
(e.g. accidental deletion, cluster corruption, or testing DR readiness).

## Prerequisites

- Velero CLI installed and configured against the target cluster
- `velero backup-location get` shows `Phase: Available`
- A completed backup exists: `velero backup get`

## 1. Identify the backup to restore from

```bash
velero backup get
```

Pick the backup name (either from the daily schedule,
e.g. `daily-notification-system-backup-20260706020000`,
or a manual backup like `manual-test-backup`).

## 2. (If restoring into a fresh/recreated cluster) Recreate prerequisites first

Velero restores Kubernetes resources (Deployments, Secrets, ConfigMaps,
CRDs, etc.) but does **not** recreate cloud infrastructure. Before
restoring, make sure the following already exist:

```bash
cd terraform/environments/dev
terraform apply
```

Also make sure the Strimzi operator and Kyverno/Falco/KEDA are installed,
since Velero restores custom resources (like `Kafka`, `KafkaTopic`) but
not the operators/controllers that reconcile them:

```bash
kubectl create -f 'https://strimzi.io/install/latest?namespace=kafka' -n kafka
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
helm install falco falcosecurity/falco --namespace falco --create-namespace --set tty=true
helm install keda kedacore/keda --namespace keda --create-namespace
```

## 3. Run the restore

```bash
velero restore create restore-$(date +%Y%m%d%H%M%S) \
  --from-backup <BACKUP_NAME> \
  --include-namespaces notifications,kafka
```

## 4. Monitor restore progress

```bash
velero restore describe restore-<TIMESTAMP>
```

Wait for `Phase: Completed`. If `Phase: PartiallyFailed` or `Failed`,
check detailed logs:

```bash
velero restore logs restore-<TIMESTAMP>
```

## 5. Verify the restored resources

```bash
kubectl get pods -n kafka
kubectl get kafka -n kafka
kubectl get kafkatopics -n kafka

kubectl get pods -n notifications
kubectl get secret smtp-credentials -n notifications
```

Wait for the Kafka cluster to report `READY: True`:

```bash
kubectl get kafka -n kafka -w
```

## 6. End-to-end validation

Port-forward the producer and send a test notification to confirm the
full pipeline (producer → Kafka → consumer → SMTP) works post-restore:

```bash
kubectl port-forward -n notifications svc/producer 8080:8080 &
curl -X POST localhost:8080/notify \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","message":"post-restore validation"}'
```

Check consumer logs for a successful send:

```bash
kubectl logs -n notifications deployment/consumer --tail=20
```

## Known limitations

- Velero restores the `SecretProviderClass` and Kubernetes `Secret`
  objects, but the actual secret **values** in Azure Key Vault are
  not managed by Velero — they must already exist in Key Vault
  (Key Vault itself is Terraform-managed infrastructure, not
  cluster state).
- Kafka topic data itself is **not** backed up (storage is `ephemeral`
  by design — see `kafka/strimzi/kafka-cluster.yaml`). A restore
  recreates the topics but does not recover in-flight/unconsumed
  messages from before the disaster.