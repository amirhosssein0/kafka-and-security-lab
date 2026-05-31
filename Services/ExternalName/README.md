ExternalName Service


Sometimes we want to access resources outside the cluster from inside the cluster, like an external database or an API that is not running in Kubernetes. We want the Pods inside the cluster to communicate with them—so this time we are sending traffic from inside to outside.

If we have the public IP of that external system, we can send requests to it from the cluster.
But it’s better to assign a name to the external system and have Pods access it by name instead of IP. That way, if the external system’s IP changes, it won’t cause problems for us.

In this case, the user accesses a Pod through a LoadBalancer, and then the Pod communicates with the external service.

In this case our external service is spaceX API!!

1) 
    kubectl apply -f spacex-app-deployment.yaml -f spacex-app-svc.yaml

2) 
    kubectl apply -f spacex-api-svc.yaml


user(8055) --> loadbalancer --> pod(5000) --> spacex-api-service ---> api.spacexdata.com --> http://spacex-api-service/v4/launches/latest