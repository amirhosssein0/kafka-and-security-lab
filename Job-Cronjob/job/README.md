Job in Kubernetes

We know that a Deployment and a StatefulSet are controllers that manage multiple Pods in a way that those Pods keep running continuously.

But sometimes we want a Pod to start, run once, finish, and then exit. It’s not meant to run continuously—it just needs to complete a specific task and then end.

We can achieve this using a Kubernetes object called a Job.

We want, in the same Redis example, to start a temporary Pod that writes some data to the leader Pod, and then finishes and exits.

1) kubectl apply -f redis/

2) kubectl get pods
NAME                      READY   STATUS     RESTARTS   AGE
redis-0                   0/1     Running    0          7s
redis-data-loader-pjn77   0/1     Init:0/1   0          7s

3) kubectl get pods
NAME                      READY   STATUS     RESTARTS   AGE
redis-0                   1/1     Running    0          19s
redis-1                   0/1     Running    0          5s
redis-data-loader-pjn77   0/1     Completed  0          19s

4) kubectl logs -c data-loader jobs/redis-data-loader
OK --> tehran
OK --> london

5) kubectl exec -it redis-0 -- redis-cli
Defaulted container "redis-container" out of: redis-container, init-redis (init)
127.0.0.1:6379> GET capital:IRAN
"Tehran"