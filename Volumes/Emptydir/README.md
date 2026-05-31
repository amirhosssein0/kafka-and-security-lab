What Is an emptyDir Volume

A volume is a storage space that can be made available to containers.

Why do we need it?
We can write data or create files inside a container, but a container’s lifecycle is temporary and containers may be replaced over time. We don’t want our data to be lost when that happens.

A volume allows us to have storage that is independent of the container lifecycle, for example for database data.

Volumes have different types. In the previous session, we talked about Secrets as one type of volume. In this session, we’re talking about emptyDir, which is another volume type.

An emptyDir is a type of storage whose lifecycle is tied to the Pod.
What does that mean?
It means that even if the Pod is recreated and, as a result, the containers are replaced, the data is still accessible. The data is only removed when the Pod itself is deleted.

1) kubectl apply -f deployment.yaml

2) kubectl get pods

3) kubectl exec -it deploy/cache-example -c cache-container -- sh
    > / # cat /cache/data.txt

4) kubectl exec -it deploy/cache-example -c cache-container -- killall5 
by this command, all processes of container will be killed and it will crash.
so, our pod will be replaced. but we can see our data in new pod!!

5) kubectl get pods --> we see new pod

6) kubectl exec -it deploy/cache-example -c cache-container -- sh
    >/ # cat /cache/data.txt --> we see our data in new pod!

7) kubectl delete -f deployment.yaml --> if delete our pod and apply again, we wont see our last data!

In the end, the emptyDir volume is mostly used for storing caches or temporary data—data that is temporary, but not so temporary that it should disappear when a container is removed or replaced. It only gets deleted when the Pod is deleted.