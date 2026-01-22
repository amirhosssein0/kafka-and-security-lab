1) kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://127.0.0.1:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
  name: default
current-context: default
kind: Config
users:
- name: default
  user:
    client-certificate-data: DATA+OMITTED
    client-key-data: DATA+OMITTED
we are manager of the cluster!

We want to create a user named Alex with restrictions in the customer namespace, so that Alex can only deploy or delete Pods.

In this part, we don’t want to talk about permissions yet. We only want to focus on the first part: how to add the user Alex so that the cluster recognizes that a user named Alex exists, using an authentication mechanism (identification).

Authorization is the part that shows the level of permissions.

Identification (authentication) checks whether the user is really who they claim to be.

We create new rsa key for alex:

1) openssl genrsa -out alex.key 2048

So that the user (Alex) can later request a certificate to identify himself to the cluster, we need to create a Certificate Signing Request (CSR).

2) openssl req -new -key ./alex.key -out alex.crt -subj "/CN=alex/O=customer-developers"

With this certificate request, Alex can send a request to Kubernetes to have a certificate issued for him. After the certificate is issued and returned, he can use that certificate to authenticate himself to the cluster.

That’s why we send this request.

client-certificate-data --> alex.crt
client-key-data --> alex.key

Now alex to be authenticated with these certificate and key.
We should create a kube config file

3) kubectl config set-cluster kubernetes \
  --server=https://10.0.0.10:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=alex-kubeconfig.yaml

4) cat alex-kubeconfig.yaml --> but we dont have context yet
it has certificate-authority-data and server

5) kubectl config set-credentials alex \
  --client-certificate=alex.crt \
  --client-key=alex.key \
  --embed-certs=true \
  --kubeconfig=alex-kubeconfig.yaml

6) cat alex-kubeconfig.yaml --> it has client datas

7) kubectl config set-context alex-context \
  --cluster=kubernetes \
  --user=alex \
  --namespace=customer \
  --kubeconfig=alex-kubeconfig.yaml 

8) cat alex-kubeconfig.yaml --> it has context now

we will give it to alex and he will use it for authentication.

9) kubectl config use-context alex-context --kubeconfig=alex-kubeconfig.yaml

10) kubectl get pods -A --> Forebidden because we didnt give any permissions . we dont have authorization!

11) export KUBECONFIG=alex-kubeconfig.yaml --> now we are alex