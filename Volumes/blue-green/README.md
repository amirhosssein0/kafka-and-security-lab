Blue/Green Strategy for Deployment

Assume our product is currently running as the blue version and is receiving traffic.

A new version of the product is released—the green version—and we want to make it available to users.

First, we bring up the Pods, containers, and all required resources for the green version alongside the blue version, but we do not send network traffic to it yet. That means the load balancer still routes traffic to the blue version, and external users only see the blue version and don’t even realize a new version exists.

After some time, once we confirm the green version is fully up and ready, we tell the load balancer to route traffic to green instead of blue.

Now users see the new version without any downtime.

The advantage is that availability doesn’t drop to zero, and the new version does not need to be compatible with the old version—unlike a rollout, where old and new Pods run side by side and must coexist. In blue-green, the load balancer routes traffic either to blue or to green at any given moment, not both.

Also, if we route traffic to green and something goes wrong, we can simply tell the load balancer to send traffic back to blue.

The disadvantage is that it requires stronger/more hardware—effectively double—because we run both blue and green environments at the same time.

1) kubectl apply -f deployment-blue.yaml -f service.yaml

2) kubectl apply -f deployment-green.yaml --> but dont recieve traffic

3) kubectl apply -f service.yaml

4) kubectl delete -f deployment-blue.yaml