```bash
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# kernel modules
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system
```

---


```bash
apt-get update
apt-get install -y containerd

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd
```

---


```bash
apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
  https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | \
  tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl
```

---
 

```bash
kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --apiserver-advertise-address=<IP_CONTROL_PLANE>
```


```
Your Kubernetes control-plane has initialized successfully!

kubeadm join <IP>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```


```bash
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

---


```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
```


```bash
kubectl get pods -n kube-system -w
```


```bash
kubectl get nodes
# NAME       STATUS   ROLES           AGE
# cp-node    Ready    control-plane   2m
```

---


```bash
kubeadm join <IP>:6443 \
  --token <token> \
  --discovery-token-ca-cert-hash sha256:<hash>
```


```bash
kubectl get nodes
# NAME          STATUS   ROLES           AGE
# cp-node       Ready    control-plane   5m
# worker-node   Ready    <none>          30s
```

---


```bash
kubectl run nginx --image=nginx
kubectl get pods -o wide
```

---
