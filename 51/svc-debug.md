# ============================================
# Service Debug Cheatsheet
# CKA Practice - Day 24
# ============================================


# -----------------------------------------------
# چک‌لیست اول — Endpoints
# -----------------------------------------------
# اگه service به pod وصل نمیشه، اول اینو چک کن:
kubectl get endpoints <svc-name>

# اگه خالی بود → selector مشکل داره
# اگه پر بود ولی کار نمیکرد → port مشکل داره


# -----------------------------------------------
# سناریو ۱ — selector اشتباه
# -----------------------------------------------
# تشخیص:
kubectl get svc -o wide          # selector رو ببین
kubectl get pods --show-labels   # label های pod رو ببین
kubectl describe svc <svc>       # Endpoints خالیه

# مشکل: selector سرویس با label pod match نمیکنه

# fix:
kubectl edit svc <svc>
# spec.selector رو درست کن
# مثلاً: app=wrong-label → app=web


# -----------------------------------------------
# سناریو ۲ — targetPort اشتباه
# -----------------------------------------------
# تشخیص:
kubectl describe svc <svc>    # TargetPort رو چک کن
kubectl describe pod <pod>    # container واقعاً روی چه port ای گوش میده؟

# مشکل: targetPort سرویس با port container match نمیکنه

# fix:
kubectl edit svc <svc>
# spec.ports.targetPort رو درست کن
# مثلاً: 8080 → 80


# -----------------------------------------------
# سناریو ۳ — service در namespace اشتباه
# -----------------------------------------------
# تشخیص:
kubectl get svc -A   # همه namespace ها رو چک کن

# fix:
# service رو در namespace درست بساز


# -----------------------------------------------
# تست اتصال
# -----------------------------------------------
# از داخل pod:
kubectl run test --image=busybox --rm -it -- sh
# wget -qO- http://<svc-name>:<port>
# wget -qO- http://<svc-name>.<namespace>.svc.cluster.local:<port>

# چک کردن endpoint مستقیم:
# wget -qO- http://<pod-ip>:<port>
# اگه pod IP کار کرد ولی svc نکرد → مشکل از service/selector هست


# -----------------------------------------------
# دستورات مفید
# -----------------------------------------------
kubectl get svc -o wide
kubectl get endpoints <svc>
kubectl describe svc <svc>
kubectl get pods --show-labels
