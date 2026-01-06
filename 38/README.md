HorizontalPodAutoscaler

We previously talked about scaling our apps using replicas, but now we want scaling to be based on the amount of load and traffic being sent.

For example, if the number of requests is high, we want the number of replicas to increase, and if requests are low, we want replicas to decrease—meaning the replica count is determined dynamically.

This can be done using the Horizontal Pod Autoscaler (HPA).

1) kubectl apply -f ./random

2) kubectl get pods

3) kubectl top pods

4) kubectl get hpa

If we open the app in the browser and keep sending requests repeatedly, then run kubectl get pods, we can see that the number of replicas has increased.

