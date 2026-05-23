Controller:
    It is a resource which is the manager of other resources.
    For instance, we have an object in kubernetes called Deployment, which is a specific type of controllers.

    Deployment is the manager of Pods and life-cycle of them.
    For example, if we have 2 nodes; node1 has 2 pods and node2 has 1 pod (totally 3 pos).

    If node2 fails, it's pod cant run. On the other hand, we dont want to create a pod in node1 manually beside 2 others pods. We want to kubernetes adds 1 pod in node1 automaticaly.

1) 
    kubectl create deployment hello-kube --image=nginx

2) 
    kubectl get deployment

3) 
    kubectl get pods => we can see our pod!!
    We didn’t create the Pod manually here.
    We manage the Deployment, and the Deployment manages the Pod.
    For example, if a Pod crashes, the Deployment recreates it.
    If the server goes down, once it comes back up, the Deployment brings the Pods back up automatically.

4) 
    kubectl get deploy hello-kube => deployment, please manage pods.

5) 
    kubectl get deploy hello-kube -o json

6) 
    kubectl get pods -l app=hello-kube

7) 
    kubectl port-forward deploy/hello-kube 8080:80

8) 
    kubectl delete deploy hello-kube

