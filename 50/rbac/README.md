Now that Alex has been authenticated, we want to restrict his access within the customer namespace.

1) kubectl create namespace customer

now we should create specific role for customer namespace

2) kubectl apply -f developer-role.yaml -f alex-rolebinding.yaml

3) export KUBECONFIG=$HOME/users/alex/alex-kubeconfig.yaml

4) kubectl get pods (-A)

5) kubectl apply -f deployment.yaml

if we change ```namespace: customer``` to ```namespace: default``` : forebidden