Configuration Data with ConfigMap and Volume

In this section, we have a small project where we run a Redis Pod, and its config file is located at /usr/local/redis/redis.conf.

In the previous part, we talked about using ConfigMaps for environment variables, but sometimes we have an actual configuration file—like here.

We can still use a ConfigMap and use its configuration data inside Pods, but we won’t use envFrom or valueFrom anymore, because those are for environment variables. Here, we have a .conf file and we want our Pod to access it, so we need to do this using volumes.

We need to follow a few steps:

1. Create a ConfigMap from the .conf file.


2. Create a volume and use the ConfigMap as a file named redis.conf, then mount that file into the Redis container at the required path—so the container can read it from that location.

1) 
    kubectl create configmap redis-config --from-file configmap/redis.conf
    kubectl describe cm redis-config

But we can create our configmap in a YAML file(declerative)!!!

So: kubectl delete cm redis-config

2) 
    kubectl apply -f redis-config.yaml

3) 
    kubectl apply -f redis-deployment.yaml

4) 
    kubectl exec -it deploy/redis-deployment -c redis -- sh
    #cat /usr/local/etc/redis/redis.conf

