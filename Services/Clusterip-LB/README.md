LoadBalacer VS CluserIp

In this project, we have two Deployments, and each one manages a single Pod:

a client Pod that users send requests to

an API Pod that generates a random number and returns it to the client


We said that to enable communication between Pods without needing to know their IP addresses, we use a Service. That way, we can access the selected Pods without knowing each Pod’s IP individually, and the Service forwards the request to one of the Pods.

This is called a ClusterIP, which is used for internal communication inside the cluster.

But if we want to create a connection between a user outside the cluster and the client Pod—meaning they can send their network traffic to our app—there is a Service called a LoadBalancer.

It provides a public IP address for the user, and we can connect to the cluster and send requests through it. Our request goes to the LoadBalancer, and the LoadBalancer forwards the incoming traffic to one of the Pods. This Pod selection is done intelligently, meaning it keeps the traffic balanced across the Pods.

So we are exposing the client Pod to external users through a LoadBalancer Service, and the user cannot connect directly to the API Pod. The user only sees the LoadBalancer IP.

1) 
    kubectl apply -f random-number-api-deployment.yaml -f random-number-api-svc.yaml

2) 
    kubectl apply -f random-number-client-deployment.yaml -f random-number-client-svc.yaml

3) 
    kubectl get svc random-number-client-svc  => EXTERNAL-IP 

The random-number-client web app sends requests to random-number-api using the service name random-number-api-svc (ClusterIP).

The random-number-api generates a random number and returns it to the client app.

The result is displayed in the web interface of random-number-client.