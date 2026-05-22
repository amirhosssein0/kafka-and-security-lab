# ============================================
# Node Troubleshoot Cheatsheet
# CKA Practice - Day 22
# ============================================


# -----------------------------------------------
# مرحله ۱: تشخیص مشکل
# -----------------------------------------------
kubectl get nodes
kubectl describe node <node-name>

# بخش مهم در describe:
# Conditions → Ready: False/Unknown
# Message → علت مشکل

# پیام‌های رایج:
# "Kubelet stopped posting node status"  → kubelet مشکل داره
# "container runtime is down"           → containerd مشکل داره
# "NetworkPlugin not initialized"        → CNI مشکل داره


# -----------------------------------------------
# مرحله ۲: رفتن روی node
# -----------------------------------------------
ssh <node-name>


# -----------------------------------------------
# مرحله ۳: چک کردن servcies
# -----------------------------------------------

# kubelet:
systemctl status kubelet
journalctl -u kubelet -f        # لاگ live
journalctl -u kubelet --no-pager | tail -50   # آخرین لاگ‌ها

# containerd:
systemctl status containerd
journalctl -u containerd -f


# -----------------------------------------------
# مرحله ۴: fix کردن
# -----------------------------------------------

# restart kubelet:
systemctl restart kubelet
systemctl enable kubelet         # اگه disabled بود

# restart containerd:
systemctl restart containerd
systemctl enable containerd      # اگه disabled بود

# هر دو:
systemctl daemon-reload
systemctl restart kubelet
systemctl restart containerd


# -----------------------------------------------
# مرحله ۵: verify
# -----------------------------------------------
systemctl status kubelet
systemctl status containerd
exit

# از controlplane:
kubectl get nodes
kubectl describe node <node-name>


# -----------------------------------------------
# سناریوهای رایج
# -----------------------------------------------

# سناریو ۱ — kubelet stop:
# describe میگه: "Kubelet stopped posting node status"
# fix: systemctl restart kubelet

# سناریو ۲ — containerd stop:
# describe میگه: "container runtime is down"
# fix: systemctl restart containerd

# سناریو ۳ — هر دو مشکل دارن:
# اول containerd، بعد kubelet restart کن
