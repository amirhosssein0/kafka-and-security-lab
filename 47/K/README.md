1) helm show values elastic/kibana > kibana.yaml

2) helm install kibana -f kibana.yaml elastic/kibana -n logging

3) kubectl get nodes -o wide

4) kubectl get svc -n logging

5) kubectl port-forward -n logging svc/kibana-kibana 8080:5601 
 
6) kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d

7) kubectl get secrets --namespace=logging elasticsearch-master-credentials -ojsonpath='{.data.username}' | base64 -d