NodePort

NodePort is another way to allow people outside the cluster to send their requests into the cluster.
It’s another alternative that provides this access.
But it has some problems:

user --> node(30080) --> service(8055) --> pod(5000) --> http://NODEIP1:<nodeport>
user --> node(30080) --> service(8055) --> pod(5000) --> http://NODEIP2:<nodeport>
user --> node(30080) --> service(8055) --> pod(5000) --> http://NODEIP3:<nodeport>
user --> node(30080) --> service(8055) --> pod(5000) --> http://NODEIP4:<nodeport>
user --> node(30080) --> service(8055) --> pod(5000) --> http://NODEIP5:<nodeport>
user --> node(30080) --> service(8055) --> pod(5000) --> http://NODEIP6:<nodeport>

With NodePort, we need direct access to each node’s IP address (to individual nodes).
But with a LoadBalancer, we didn’t have to deal with the nodes—the LoadBalancer itself distributes the traffic across the nodes and the Pods running on them.

Also, with NodePort we are very directly and explicitly opening a port on our node/server, which raises security concerns.

Usually, NodePort is used for testing, and in production we use a LoadBalancer.


user --> loadbalancer(8055) --> pod(5000) --> http://loadbalancerip:8055

