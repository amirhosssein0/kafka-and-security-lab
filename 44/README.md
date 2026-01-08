ServiceAccount

Let's assume we want to use Jenkins or ArgoCD for CI/CD. That is, we want to use an app that will manage another app, deploy Pods, and interact with Kubernetes.

Jenkins, for example, is not a human user; it's an application that needs to interact with Kubernetes APIs to manage the application and deploy Pods.

In some cases, we need the Pods that are running Jenkins to have access to Kubernetes APIs to perform tasks like:

Running kubectl apply

Creating volumes

Interacting with Kubernetes resources


ServiceAccount is an identity that represents an application (or a Pod) within Kubernetes, not a human user.

When we add a user to a Kubernetes cluster or namespace and assign roles to it, we’re dealing with a human user. But when a Pod needs to interact with Kubernetes APIs (for example, to run kubectl get pods), it uses a ServiceAccount.

For example, we might want to create a Pod that can run kubectl get pods from within itself. The pod needs to be associated with a ServiceAccount that grants it the necessary permissions to interact with the Kubernetes API.

This allows the Pod to perform actions as if it were a user, but it’s an application-level identity, not a human.

1)  kubectl apply -f ./pod.yaml -f ./role-binding.yaml -f ./role.yaml -f ./serviceaccount.yaml

2) kubectl exec -it list-pod -- sh
kubectl get pods --> by pod