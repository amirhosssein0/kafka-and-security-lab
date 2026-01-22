mainDaemonSet

A DaemonSet is a controller, meaning it manages a set of Pods. The Pods that a DaemonSet deploys are designed to run on every node in the cluster, unless we restrict them to specific nodes using a nodeSelector or other mechanisms.

On each node, exactly one Pod defined by the DaemonSet runs.

For example, if we want to collect logs from every node, we can deploy a DaemonSet that runs a Pod on each node to read that node’s logs.
Or if we want to monitor CPU and memory usage and collect node-level metrics, we can use a DaemonSet to run monitoring Pods on all nodes.


1) kubectl apply -f ./monitor.yaml

2) kubectl get ds -A
NAMESPACE     NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE       
kube-system   node-exporter            1         1         1       1            1           
                                                 |
                                                 we have 1 node
                                            
3) kubectl get pods -n kube-system -o wide

4) curl <nodeip>:9100/metrics

