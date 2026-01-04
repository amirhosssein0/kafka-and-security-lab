What is Helm?

Helm is a package manager.
It helps us package complex Kubernetes applications—written as multiple manifest files—so we can share them with others and customize them. Then, with aپ single command like helm install, we can install the app.

Instead of manually managing and applying many YAML files, we bundle everything with Helm and install it much more easily.

1) helm version
version.BuildInfo{Version:"v4.0.4", GitCommit:"8650e1dad9e6ae38b41f60b712af9218a0d8cc11", GitTreeState:"clean", GoVersion:"go1.25.5", KubeClientVersion:"v1.34"}

2) helm env

Each packaged set of YAML files is called a chart, for example a Postgres chart.

Bitnami is a repository that provides popular charts like Redis, Postgres, and others. Behind the scenes, each chart is made up of multiple YAML files that together define the application.

3) helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories

4) helm repo list
NAME   	URL                               
bitnami	https://charts.bitnami.com/bitnami

5) helm search repo bitnami

6) helm install nginxapp bitnami/nginx

7) kubectl get deploy
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
nginxapp                             1/1     1            1           24s

8) kubectl get svc
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
kubernetes                  ClusterIP      10.43.0.1       <none>        443/TCP                      13d
nginxapp                    LoadBalancer   10.43.214.118   <pending>     80:31853/TCP,443:32453/TCP   2m9s

* Without needing to write a YAML file for NGINX, we brought it up with a single command.

9) helm uninstall nginxapp
release "nginxapp" uninstalled

                     
