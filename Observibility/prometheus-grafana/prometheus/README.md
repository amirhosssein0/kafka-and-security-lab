1) kubectl create ns monitoring

2) helm show values bitnami/prometheus > prometheus.yaml

```
alertmanager:
  service:
    type: ClusterIP  # Change from LoadBalancer to ClusterIP
```

and 

```
server:
  service:
    type: ClusterIP  # Change from LoadBalancer to ClusterIP
    ports:
      http: 9090
```

3) helm install prometheus bitnami/prometheus -f prometheus.yaml -n monitoring

4) kubectl get pods -n monitoring

* Prometheus Server UI

5) kubectl port-forward --namespace monitoring svc/prometheus-server 9090:9090 --address=<clusterip>

* Alertmanager UI

6) kubectl port-forward --namespace monitoring svc/prometheus-alertmanager 9093:80 --address=<clusterip>