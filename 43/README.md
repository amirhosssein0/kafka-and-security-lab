NetworkPolicies

We currently have two Deployments.
The client sends a request to the API Pod and receives the number.

By default, Pods can send requests to each other and also receive requests. But this is not very secure: if someone gains access to one Pod, they can effectively access the other Pods as well.

With NetworkPolicies, we can restrict network communication between Services/Pods and improve network security.

Kubernetes supports this feature, but it is not enabled by default, so we need to enable it.

1) kubectl apply -f ./random/

2) kubectl get pods -o wide 

Now we bring up a container inside the cluster that has nothing to do with our app, but it is still able to send requests to the API.

3) kubectl run testpod --rm -it --image=busybox --restart=Never -- sh
/ # wget http://random-number-api-svc/generate -O -
Connecting to random-number-api-svc (10.43.251.77:80)
writing to stdout
{"message":"Random number: 15"}

Now we want requests from outside (from the browser)—meaning through the client—to work, but we don’t want anything else inside the cluster (outside of our app) to be able to access it.

4) kubectl apply -f ./random/

5) kubectl run testpod2 --rm -it --image=busybox --restart=Never -- sh
/ # wget http://random-number-api-svc/generate -O -
Connecting to random-number-api-svc (10.43.251.77:80)
wget: can't connect to remote host (10.43.251.77): Connection refused