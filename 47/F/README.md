1) helm show values bitnami/fluent-bit > fluentbit.yaml

```
daemonset:
  enabled: true
```

and

```
  outputs: |
    [OUTPUT]
        Name                    es
        Match                   *
        Host                    elasticsearch-master.logging.svc.cluster.local
        Port                    9200
        HTTP_User               elastic
        HTTP_Passwd             # Replace with your password
        Logstash_Format         On
        Logstash_Prefix         fluentbit
        Replace_Dots            On
        Suppress_Type_Name      On
        tls                     On
        tls.verify              Off
        Retry_Limit             False
```

2) helm install fluent-bit -f fluentbit.yaml bitnami/fluent-bit -n logging

3) kubectl get pods -n logging

4) kubectl get svc -n logging

5) kubectl -n logging port-forward elasticsearch-master-0 9200:9200

6) curl -u elastic:<password> https://localhost:9200/_cat/indices?v --insecure