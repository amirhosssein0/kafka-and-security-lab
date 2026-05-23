1) 
    kubectl run pod-name --image=image-name-in-dockerhub --restart=Never
    kubectl run hello-kube --image=nginx --restart=Never

2) 
    kuberctl get pods 

3) 
    kuberctl describe pod hello-kube => important information

4) 
    kuberctl get pod hello-kube -o json => all information

5) 
    By default, traffic of network comes for node. So, we can change it to specific pod

    kuberctl port-forward pod/hello-kube 8080:80

6)  
    kuberctl delete pod hello-kube
    kuberctl get pods => We dont see our pod 