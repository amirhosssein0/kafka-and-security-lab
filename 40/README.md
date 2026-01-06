Taint and Toleration

Sometimes we want to apply restrictions on our nodes and Pods so that not every Pod is allowed to run on every node.

For example, some Pods can run with a GPU, but others cannot. Also, GPU resources are limited—meaning not all nodes support GPUs. Some nodes have GPUs and some don’t.

So we may want to add a restriction to the nodes that support GPUs and say that if a Pod is not GPU-enabled, it must not be scheduled onto that node.

This restriction is called a taint, and satisfying it is called a toleration.

So we can apply constraints on a node, and Pods that don’t meet those constraints cannot run on that node.

We apply these constraints to nodes using key–value pairs.

1) kubectl taint nodes node01 gpu=true:NoSchedule
   kubectl taint nodes node02 gpu=true:NoSchedule

2) kubectl describe node node02 | grep Taints
Taints:             gpu=true:NoSchedule

3) kubectl apply -f deployment.yaml

4) kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-kube-6bcb845c8b-99z6j   0/1     Pending   0          14s

---

5) kubectl taint nodes node01 gpu=true:NoSchedule- -> revert

6) kubectl apply -f deployment.yaml

7) kubectl get pods -o wide
NAME                                   READY   STATUS    RESTARTS   NODE     
hello-kube-critical-6c58bc97d4-l48qc   1/1     Running   0          node01   

---
* update yaml
```
spec:
    tolerations:
    - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```
8) kubectl apply -f deployment.yaml

9) kubectl get pods -o wide
NAME                                   READY   STATUS        NODE 
hello-kube-critical-777f84cb6f-t7dx6   1/1     Running       node02

---

Taint Effects
* NoSchedule:
Prevents pods that do not tolerate the taint from being scheduled on the node.

* NoExecute:
In addition to preventing new pods from being scheduled, this effect evicts already-running pods that do not tolerate the taint.

* PreferNoSchedule:
Acts as a soft constraint where the scheduler tries to avoid placing pods on the node, but if no other options are available, the pod may still be scheduled.

---

Toleration Operators
* Equal:
The toleration matches only if the taint’s key and value are exactly the same as specified in the toleration.

* Exists:
The toleration matches any taint with the specified key, regardless of the value.
```
tolerations:
- key: "gpu"
  operator: "Exists"
  effect: "NoSchedule"
```