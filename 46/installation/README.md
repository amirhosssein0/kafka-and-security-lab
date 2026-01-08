1) kubectl create namespace argocd

2) kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

3) kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          100s
argocd-applicationset-controller-5b6b8dcb67-6g474   1/1     Running   0          101s
argocd-dex-server-847d9d6b84-9m9g4                  1/1     Running   0          101s
argocd-notifications-controller-54b4b9db6-fp8d2     1/1     Running   0          101s
argocd-redis-68f5477f5d-l7zj7                       1/1     Running   0          101s
argocd-repo-server-5db8b966cd-bv497                 1/1     Running   0          100s
argocd-server-5c54b98b9f-hvdqk                      1/1     Running   0          100s

4) kubectl get svc -n argocd
argocd-server        ClusterIP   10.43.62.43     80/TCP,443/TCP 

5) kubectl port-forward -n argocd svc/argocd-server 8085:443 --address=<clusterip>

6) <clusrerip>:8085  --> username is <admin> but we should check the generated password in cluster

7) kubectl get secret -A --> argocd-initial-admin-secret

8) kubectl get secret argocd-initial-admin-secret -n argocd -o yaml --> see encoded password

9) echo <password> | base64 --decode

login