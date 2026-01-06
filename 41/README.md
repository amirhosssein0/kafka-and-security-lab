Node Labeling and Node Selector

In previous sections, we talked about taints and nodeName.
In this section, we want to see another way to decide which node Pods should run on.

There is a concept called a label that can be assigned to nodes. A node can have multiple labels.

When a node is added to Kubernetes, the platform that provides the cluster automatically assigns a set of well-known, default labels to it.

1) kubectl get node node02 --show-labels

create personal label:
2) kubectl label node node02 serv=customer

3) kubectl apply -f deployment.yaml

4) kubectl get pods -o wide

5) kubectl label node node02 serv- => revert label

It’s kind of the opposite of taints, because here we are explicitly saying which nodes these Pods should run on.

Instead of blocking Pods from running on certain nodes (like with taints), we are selecting specific nodes and telling Kubernetes that the Pods must be scheduled on those nodes.