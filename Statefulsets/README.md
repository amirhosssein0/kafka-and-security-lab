In today’s example, we want to run three Redis replicas, and the Pods can be scheduled on different nodes inside the cluster.

One of the Pods will be responsible for both reads and writes—we call it the leader.
The other replicas are followers: they are read-only, and we keep them synchronized with the leader.

When a user sends a request:

if it’s a write request, it goes to redis-0

if it’s a read request, it can be sent to any of the three Pods


Each Pod has its own dedicated volume.
Each Pod also has a unique name and can be reached via DNS:

redis-0

redis-1

redis-2

Whenever we want to use a StatefulSet, we need a Headless Service. The StatefulSet uses it, and through it we can communicate with each Pod in the StatefulSet by name.

In a StatefulSet, each replica will have its own dedicated volume, unlike a Deployment where we define a single PVC and all replicas use that one volume. But here we want three separate volumes.

That’s why Kubernetes provides volumeClaimTemplates: it automatically creates a separate PVC per Pod (one PVC for each replica).

1) kubectl apply -f redis/

2) kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
redis-0   1/1     Running   0          19s #first
redis-1   1/1     Running   0          17s #second
redis-2   1/1     Running   0          11s #third

3) kubectl get pvc --> 3 pvc

4) kubectl exec -it redis-0 -- redis-cli
Defaulted container "redis-container" out of: redis-container, init-redis (init)
127.0.0.1:6379> SET capital:IRAN "Tehran"
OK
127.0.0.1:6379> exit

5) kubectl exec -it redis-0 -- redis-cli
Defaulted container "redis-container" out of: redis-container, init-redis (init)
127.0.0.1:6379> SET capital:IRAN "Tehran"
OK
127.0.0.1:6379> exit
amirhosein@amirhosein:~/Desktop/main/Kubernetes/25$ sudo k3s kubectl exec -it redis-1 -- redis-cli
Defaulted container "redis-container" out of: redis-container, init-redis (init)
127.0.0.1:6379> GET capital:IRAN
"Tehran"
127.0.0.1:6379> SET capital:UK "London"
(error) READONLY You can't write against a read only replica.

6) kubectl delete -f redis/

7) kubectl get pvc 

PVCs created via volumeClaimTemplates are not deleted when you delete the StatefulSet.
You either have to delete them manually, or define a customized StorageClass so that when the StatefulSet is deleted, those resources are deleted as well.