1) kubectl apply -f redis/

2) kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
redis-0   1/1     Running   0          50s
redis-1   1/1     Running   0          33s
redis-2   0/1     Running   0          16s

2) kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
redis-0   1/1     Running   0          58s
redis-1   1/1     Running   0          41s
redis-2   1/1     Running   0          24s