1) helm show values bitnami/grafana > grafana.yaml

```
persistence:
  enabled: true
  storageClass: "local-path"
  accessMode: ReadWriteOnce
  size: 1Gi # Adjust size if needed
```

```
datasources:
  secretDefinition:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server:9090
      access: proxy
      isDefault: true
```

```
admin:
  user: "admin"
  password: "your-secure-password" # Replace with a strong password or leave empty to auto-generate
```

2) helm install grafana bitnami/grafana -f grafana.yaml -n monitoring

3) kubectl get pods -n monitoring

4) kubectl get secret grafana-admin --namespace monitoring -o jsonpath="{.data GF_SECURITY_ADMIN_PASSWORD}" | base64 -d

if dont set manually!

5) kubectl port-forward --namespace monitoring svc/grafana 3000:3000 --address=<clusterip>

