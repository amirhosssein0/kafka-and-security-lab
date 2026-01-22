Why do we need Service?

We create two Pods, and each Pod is managed by a separate Deployment.
When each Pod is created, a virtual IP address is assigned to it.

Here, on our node, we created two Deployments, each managing one Pod, and in each Pod there is an NGINX container.

1) 
    kubectl apply -f hello-kube-1.yaml -f hello-kube-2.yaml

2) 
    kubectl get deployments => here we see 2 deployments.

3) 
    kubectl get pod -l app=hello-kube-1 -o wide => see IP = 10.42.0.21
    !! Pods can commiunicate to each other with their IPs!!

4) 
    kubectl exec -it deploy/hello-kube-2 -c web -- sh 

    /#curl 10.42.0.21:80 => HTML page

! But there is a problem. These Ips are dynamic and temporary and they will be replaced. 
! So as a result, it’s not a good approach for Pods to communicate using Pod IPs directly.

  Instead, we want to be able to communicate with them without knowing each Pod’s individual IP.

  The idea is to use DNS.

  Kubernetes has an internal DNS, and there’s an object called a Service that is created in front of one or more Pods. If I create a Service for multiple Pods, I choose a name for the Service, and whenever I want to communicate with the Pods, I send the network request to the Service name. The Service receives the traffic and forwards it to the Pods.

5) 
    kubectl apply -f service.yaml 

6) 
    kubectl get svc hello-kube-1-svc

7) 
    kubectl exec -it deploy/hello-kube-2 -c web -- sh
    / # curl hello-kube-1-svc:80 (metadata name) => HTML page

8) 
    kubectl delete -f service.yaml 