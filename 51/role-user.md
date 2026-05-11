1) openssl genrsa -out amir.key 2048
2) openssl req -new -key ./amir.key -out amir.csr -subj "/CN=amir/O=customer-developers"
3) openssl x509 -req -in amir.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out amir.crt -days 500
4) kubectl config set-cluster kind-cka-lab \
  --server=https://127.0.0.1:39421 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=amir-kubeconfig.yaml
5) cat amir-kubeconfig.yaml
6) kubectl config set-credentials amir \
  --client-certificate=amir.crt \
  --client-key=amir.key \
  --embed-certs=true \
  --kubeconfig=amir-kubeconfig.yaml
  7) kubectl config set-context amir-context \
  --cluster=kind-cka-lab \
  --user=amir \
  --namespace=customer \
  --kubeconfig=amir-kubeconfig.yaml 
8) kubectl config use-context amir-context --kubeconfig=amir-kubeconfig.yaml (amir-context to amir-kubeconfig.yaml set mishe just)
9) kubectl config view --kubeconfig=amir.yaml
10) kubectl get pods --kubeconfig=amir-kubeconfig.yaml -n customer

11) export KUBECONFIG=~/amir-kubeconfig.yaml
12) KUBECONFIG=~/.kube/config:~/amir-kubeconfig.yaml kubectl config view --flatten > /tmp/merged.yaml
13) mv /tmp/merged.yaml ~/.kube/config
14) kubectl config use-context amir-context 