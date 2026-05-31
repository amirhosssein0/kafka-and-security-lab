Securing Sensitive Data in Kubernetes with Secret

Sometimes the things we need are very critical and sensitive—like a database password, a token, or an SSH key—and they shouldn’t be easily accessible. So we use the Secret object.

It’s very similar to a ConfigMap, but the difference is that the resource we create is of type Secret, and it comes with certain restrictions—for example, not all Pods can access this resource or view its contents.

1) 
    echo -n "postgrespass" | base64 --> cG9zdGdyZXNwYXNz

2) 
    kubectl describe secret/postgres-secret
    Name:         postgres-secret
    Namespace:    default
    Labels:       <none>
    Annotations:  <none>

    Type:  Opaque

    Data   ---> it doesnt show data, but config map shows
    ====
    postgres-password:  12 bytes

3) 
    kubectl exec -it deploy/postgres-deployment -c postgres -- sh
    >/# echo $POSTGRES_PASSWORD_FILE
    /etc/secrets/postgres-password
    >/# ls -l /etc/secrets
    total 0
    lrwxrwxrwx 1 root root 24 Dec 28 08:29 postgres-password -> ..data/postgres-password
    >/# ls -l $(readlink -f /etc/secrets/postgres-password)
    -r-------- 1 root root 12 Dec 28 08:29 /etc/secrets/..2025_12_28_08_29_59.3607037502/postgres-password