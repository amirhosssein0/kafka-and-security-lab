Creating an Entrypoint for a Kubernetes Cluster with Ingress

In the previous sections, we had two apps: one that generated a random number, and another one (SpaceX). For each app, we wrote its own Deployment and Service.

But the user needs us to provide an entry point—a single access point for the cluster.

Right now, using LoadBalancers, we created one entry point for the random-number app and another one for the SpaceX app. But the cluster itself doesn’t have a single entry point. So if we want to access the apps, we have to use different ports—one port for the random app and a different port for the SpaceX app.

We need to define a cluster entry point based on the URL. For example:

if the user goes to application.com/random, the request should be sent to the random-number service

if they go to application.com/x, the request should be sent to the SpaceX service


We can implement this using Ingress.

Ingress is a resource where we define rules so that when the user types a certain URL/path, the traffic is routed to the correct Service.

1) kubectl apply -f ./random/

2) kubectl apply -f ./spacex/

3) kubectl apply -f ./ingress.yaml