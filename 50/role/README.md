Role

Assume we have a user named Alex. We want to grant Alex some permissions so they can do certain actions inside the dev namespace—for example, create and deploy Pods, or create volumes.

How do we do that?

In Kubernetes, instead of assigning permissions directly to each individual user, we define a Role that describes what actions are allowed within a specific namespace (for example, a “deployment role”). Then we assign that Role to Alex.

To give a user a Role, we use a concept called a RoleBinding. A RoleBinding connects (binds) a Role to a user.

If we want to define a Role that is not limited to a single namespace and instead applies to the whole cluster, we use a ClusterRole and a ClusterRoleBinding.

1) kubectl api-versions
admissionregistration.k8s.io/v1
apiextensions.k8s.io/v1
apiregistration.k8s.io/v1
apps/v1
argoproj.io/v1alpha1
authentication.k8s.io/v1
authorization.k8s.io/v1
autoscaling/v1
autoscaling/v2
batch/v1
certificates.k8s.io/v1
coordination.k8s.io/v1
discovery.k8s.io/v1
events.k8s.io/v1
flowcontrol.apiserver.k8s.io/v1
gateway.networking.k8s.io/v1
gateway.networking.k8s.io/v1beta1
helm.cattle.io/v1
hub.traefik.io/v1alpha1
k3s.cattle.io/v1
metrics.k8s.io/v1beta1
networking.k8s.io/v1
node.k8s.io/v1
policy/v1
rbac.authorization.k8s.io/v1 --> we can create and use roles (role base access control)
scheduling.k8s.io/v1
storage.k8s.io/v1
traefik.io/v1alpha1
v1

2) kubectl get roles -A
NAMESPACE     NAME                                             CREATED AT
argocd        argocd-application-controller                    2026-01-08T08:17:41Z
argocd        argocd-applicationset-controller                 2026-01-08T08:17:41Z
argocd        argocd-dex-server                                2026-01-08T08:17:41Z
argocd        argocd-notifications-controller                  2026-01-08T08:17:41Z
argocd        argocd-redis                                     2026-01-08T08:17:41Z
argocd        argocd-server                                    2026-01-08T08:17:41Z
default       pod-reader                                       2026-01-08T07:38:28Z
kube-public   system:controller:bootstrap-signer               2025-12-21T19:26:30Z
kube-system   extension-apiserver-authentication-reader        2025-12-21T19:26:30Z
kube-system   system::leader-locking-kube-controller-manager   2025-12-21T19:26:30Z
kube-system   system::leader-locking-kube-scheduler            2025-12-21T19:26:30Z
kube-system   system:controller:bootstrap-signer               2025-12-21T19:26:30Z
kube-system   system:controller:cloud-provider                 2025-12-21T19:26:30Z
kube-system   system:controller:token-cleaner                  2025-12-21T19:26:30Z

3) kubectl get clusterroles -A
NAME                                                                   CREATED AT
admin                                                                  2025-12-21T19:26:30Z
argocd-application-controller                                          2026-01-08T08:17:41Z
argocd-applicationset-controller                                       2026-01-08T08:17:41Z
argocd-server                                                          2026-01-08T08:17:41Z
cluster-admin                                                          2025-12-21T19:26:30Z
clustercidrs-node                                                      2025-12-21T19:26:35Z
edit                                                                   2025-12-21T19:26:30Z
k3s-cloud-controller-manager                                           2025-12-21T19:26:34Z
local-path-provisioner-role                                            2025-12-21T19:26:34Z
system:aggregate-to-admin                                              2025-12-21T19:26:30Z
system:aggregate-to-edit                                               2025-12-21T19:26:30Z
system:aggregate-to-view                                               2025-12-21T19:26:30Z

4) kubectl describe clusterrole cluster-admin
Name:         cluster-admin
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  *.*        []                 []              [*]
             [*]                []              [*]