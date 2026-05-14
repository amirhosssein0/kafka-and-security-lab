1) openssl genrsa -out amir.key 2048
2) openssl req -new -key ./amir.key -out amir.csr -subj "/CN=amir/O=customer-developers"
3) cat amir.csr | base64 | tr -d '\n'

```
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: amir
spec:
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZEQ0NBVHdDQVFBd0R6RU5NQXNHQTFVRUF3d0VZVzFwY2pDQ0FTSXdEUVlKS29aSWh
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
```

  
4) kubectl certificate approve amir
5) kubectl get csr amir -o jsonpath='{.status.certificate}' | base64 -d > amir.crt
6) kubectl config set-cluster kind-cka-lab \
  --server=https://127.0.0.1:39421 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=amir.yaml
7) cat amir-kubeconfig.yaml
8) kubectl config set-credentials amir \
  --client-certificate=amir.crt \
  --client-key=amir.key \
  --embed-certs=true \
  --kubeconfig=amir.yaml
9) kubectl config set-context amir-context \
  --cluster=kind-cka-lab \
  --user=amir \
  --namespace=customer \
  --kubeconfig=amir.yaml 
10) kubectl config use-context amir-context --kubeconfig=amir.yaml (amir-context to amir-kubeconfig.yaml set mishe just)
11) kubectl config view --kubeconfig=amir.yaml
12) kubectl get pods --kubeconfig=amir.yaml -n customer
13) export KUBECONFIG=~/amir.yaml
14) KUBECONFIG=~/.kube/config:~/amir.yaml kubectl config view --flatten > /tmp/merged.yaml
15) mv /tmp/merged.yaml ~/.kube/config
16) kubectl config use-context amir-context 