Node Affinity

In the previous section, we learned how to use labels.
But now let’s assume our requirements become more complex and we need additional logic.

For example, we want our Pods to run on nodes that have certain labels and do not have certain other labels—in other words, more complex logic.

In this case, nodeSelector is no longer sufficient, because the logic has become more advanced and simple equality or label existence checks are not enough.
For example, we might want nodes that are a subset of a group of labels, or nodes that match some labels but explicitly exclude others.

1) kubectl get nodes --show-labels

2) kubectl label node node02 gpu=true

3) kubectl apply -f deployment.yaml

4) kubectl get pods -o wide

5) kubectl label node node02 gpu-