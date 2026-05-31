Changing default values!

Helm allows us to define variables (values) when we create a package (chart), and by changing these variables, we can change how our application is deployed and how it behaves on Kubernetes.

1) helm install nginxapp bitnami/nginx

2) helm show values bitnami/nginx  --> we can change these values

3) helm install nginxapp bitnami/nginx --set service.ports.http=8088

4) kubectl get deploy

5) kubectl get svc

6) helm ls

7) helm upgrade nginxapp bitnami.nginx --set service.ports.http=8089 
instead of uninstall and install with new changes!!   

---

```
# Add repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install
helm install web bitnami/nginx -n exercise-13 --create-namespace --set replicaCount=2

# Verify
helm list -n exercise-13
k get pods -n exercise-13

# Upgrade
helm upgrade web bitnami/nginx -n exercise-13 --set replicaCount=3

# Check history
helm history web -n exercise-13

# Rollback
helm rollback web 1 -n exercise-13

# Verify rollback
k get deploy -n exercise-13 -o jsonpath='{.items[0].spec.replicas}'
helm history web -n exercise-13
```