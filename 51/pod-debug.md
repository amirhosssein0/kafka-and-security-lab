# -----------------------------------------------
# سناریو ۴ — Pending
# -----------------------------------------------
# علت: node نداره یا resource کافی نیست

# تشخیص:
# kubectl describe pod → Events: FailedScheduling

# fix:
# kubectl describe node → چک کن resource داره
# kubectl get nodes → چک کن node Ready هست


# -----------------------------------------------
# دستورات مفید
# -----------------------------------------------
# لاگ فعلی:
kubectl logs <pod>
kubectl logs <pod> -c <container>   # اگه چند container داره

# لاگ قبل از crash:
kubectl logs <pod> --previous

# shell گرفتن از داخل pod:
kubectl exec -it <pod> -- sh
kubectl exec -it <pod> -- bash

# replace --force:
kubectl replace --force -f <file>
