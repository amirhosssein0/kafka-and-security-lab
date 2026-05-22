# بخش مهم در describe:
# Conditions → Ready: False/Unknown
# Message → علت مشکل

# پیام‌های رایج:
# "Kubelet stopped posting node status"  → kubelet مشکل داره
# "container runtime is down"           → containerd مشکل داره
# "NetworkPlugin not initialized"        → CNI مشکل داره


# kubelet:
systemctl status kubelet
journalctl -u kubelet -f        # live
journalctl -u kubelet --no-pager | tail -50   # last logs

# containerd:
systemctl status containerd
journalctl -u containerd -f



# restart kubelet:
systemctl restart kubelet
systemctl enable kubelet 

# restart containerd:
systemctl restart containerd
systemctl enable containerd

# both:
systemctl daemon-reload
systemctl restart kubelet
systemctl restart containerd

# سناریو ۱ — kubelet stop:
# describe میگه: "Kubelet stopped posting node status"
# fix: systemctl restart kubelet

# سناریو ۲ — containerd stop:
# describe میگه: "container runtime is down"
# fix: systemctl restart containerd

# سناریو ۳ — هر دو مشکل دارن:
# اول containerd، بعد kubelet restart کن
