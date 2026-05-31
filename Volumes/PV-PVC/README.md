PVC, PV, and Storage Class In Action

1)  kubectl apply -f postgres-secret.yaml -f postgres-deployment.yaml -f pvc.yaml

2) kubectl get pvc
    NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS      
    postgres-pvc   Bound    pvc-ca8b77c7-ea13-46c5-b5b5-a7c452d56411   1Gi        RWO            local-path     


Here, I can see that the app is running correctly.
I also see that postgres-pvc is bound to a volume, even though we didn’t manually create that volume. How did that happen?

I can see that there is a StorageClass that we didn’t create ourselves, and it dynamically created 1GB of storage for us.

In fact, behind the scenes, k3s has defined a default StorageClass for us automatically.      

3) kubectl get storageclass
    NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
    local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer 

If we define a PVC and don’t do anything special, k3s automatically creates a volume for us with the default cluster-level settings.

The same thing happens on AWS, Azure, and Google Cloud, but the settings come from the cloud provider’s defaults. These clouds already have StorageClasses, and when we create a PVC, they dynamically provision storage for us.

But now let’s assume we want to customize this behavior and modify or create our own StorageClass based on the one in AWS.

