1) kubectl create ns ml

2) helm show values bitnami/jupyterhub > jupyterhub.yaml

```
public:
  ## @param proxy.service.public.type Public service type
  ##
  type: ClusterIP
  # HTTP Port
  ## @param proxy.service.public.ports.http Public service HTTP port
  ##
  ports:
    http: 8080
```

3) helm install jupyter bitnami/jupyterhub -f jupyterhub.yaml -n ml

4) kubectl port-forward --namespace ml svc/jupyter-jupyterhub-proxy-public 8080:8080

```
echo "Admin user: user"
echo "Password: $(kubectl get secret --namespace ml jupyter-jupyterhub-hub -o jsonpath="{.data['values\.yaml']}" | base64 -d | awk -F: '/password/ {gsub(/[ \t]+/, "", $2);print $2}')"
```