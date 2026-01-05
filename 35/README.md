Redis Helm Chart

1) helm create redis

2) helm install redisapp ./redis/ --set replicaCount=4
NAME: redisapp
LAST DEPLOYED: Mon Jan  5 17:29:32 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None

3) kubectl get pods
NAME                          READY   STATUS      RESTARTS   AGE
redis-0                       1/1     Running     0          57s
redis-1                       1/1     Running     0          44s
redis-2                       1/1     Running     0          31s
redis-3                       1/1     Running     0          18s