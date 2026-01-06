Manually scheduling a pod with nodeName

In previous sections, we said there is a scheduler that decides which node a Pod should run on based on its resource requirements.

But we can bypass that and manually tell Kubernetes which node the Pod must run on. For example, I have two nodes, and in the manifest I want to specify that the Pod should run on worker node 2.

1) kubectl apply -f deployment.yaml

Of course, in a real production environment this is generally not a good practice, but it is still possible to do it manually.