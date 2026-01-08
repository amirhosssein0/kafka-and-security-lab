1) helm repo add elastic https://helm.elastic.co

2) helm repo update

3) helm show values elastic/elasticsearch > elastic.yaml

4) kubectl get sc ->line113 in yaml

5) kubectl create namespace logging -> deploy elastic in this ns

6) helm install elasticsearch -f elastic.yaml elastic/elasticsearch -n logging

7) kubectl get pods -n logging

8) helm --namespace=logging test elasticsearch