1) openssl genrsa -out amir.key 2048
2) openssl req -new -key ./amir.key -out amir.csr -subj "/CN=amir/O=customer-developers"
3) 
```
  cat <<EOF | kubectl apply -f -
  apiVersion: certificates.k8s.io/v1
  kind: CertificateSigningRequest
  metadata:
    name: john
  spec:
    request: $(cat john.csr | base64 | tr -d '\n')
    signerName: kubernetes.io/kube-apiserver-client
    usages:
    - client auth
  EOF
```
4) kubectl certificate approve john
5) kubectl get csr john -o jsonpath='{.status.certificate}' | base64 -d > john.crt
6) kubectl config set-cluster kind-cka-lab \
  --server=https://127.0.0.1:39421 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=amir-kubeconfig.yaml
7) cat amir-kubeconfig.yaml
8) kubectl config set-credentials amir \
  --client-certificate=amir.crt \
  --client-key=amir.key \
  --embed-certs=true \
  --kubeconfig=amir-kubeconfig.yaml
9) kubectl config set-context amir-context \
  --cluster=kind-cka-lab \
  --user=amir \
  --namespace=customer \
  --kubeconfig=amir-kubeconfig.yaml 
10) kubectl config use-context amir-context --kubeconfig=amir-kubeconfig.yaml (amir-context to amir-kubeconfig.yaml set mishe just)
11) kubectl config view --kubeconfig=amir.yaml
12) kubectl get pods --kubeconfig=amir-kubeconfig.yaml -n customer
13) export KUBECONFIG=~/amir-kubeconfig.yaml
14) KUBECONFIG=~/.kube/config:~/amir-kubeconfig.yaml kubectl config view --flatten > /tmp/merged.yaml
15) mv /tmp/merged.yaml ~/.kube/config
16) kubectl config use-context amir-context 