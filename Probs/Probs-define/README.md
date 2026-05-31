Readiness and Liveness probes

Kubernetes uses probes to send requests to a container in order to check its health status.
In response, the container returns a status code that represents its internal state.

A probe fails if the request that Kubernetes sends times out, if no response is received, or if the container determines that something is wrong internally—for example, a required dependency is not available and the container becomes unhealthy.

We have two probes:

Liveness

Readiness


Liveness checks whether the container is still running and should be restarted or not.
Readiness checks whether the container is ready to receive traffic.

They are different concepts. The way Kubernetes sends the probes is similar, but the container must implement different logic internally so it can return the correct response for each probe.

If a probe fails:

For liveness: the container (and therefore the Pod) is terminated and replaced.

For readiness: Kubernetes temporarily removes the Pod from the set of endpoints that receive network traffic, until the probe starts passing again.


For example, if we have 3 Pods behind a load balancer and one of them fails the readiness probe, Kubernetes will take that Pod out of rotation and only send traffic to the other two, until the Pod becomes ready again.

If the liveness probe fails, recovery takes longer because the Pod needs to be recreated, scheduled onto a node, and started again.
But for readiness, recovery is usually faster because the Pod is not replaced—it’s already running, it just doesn’t receive traffic temporarily.