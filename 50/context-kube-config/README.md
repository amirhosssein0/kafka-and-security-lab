~/.kube/config

```
apiVersion: v1
clusters: #list of clusters like prod , staging or dev
- cluster:
    certificate-authority-data: 
    server: https://127.0.0.1:6443
  name: default
contexts:
- context:
    cluster: default
    user: default
    #namespace:
  name: default
current-context: default
kind: Config
preferences: {}
users:
- name: default
  user:
    client-certificate-data:
    client-key-data:
```

1) certificate-authority-data: When we run kubectl apply, we are trying to communicate with the Kubernetes API server.
By verifying the Certificate Authority (CA) certificate, the client makes sure that kubectl is truly talking to the real Kubernetes API server, and it prevents a man-in-the-middle attack—where someone sits between us and the API server and responds to our kubectl requests instead.


When we run kubectl commands as the default user, the Kubernetes API server also needs to make sure that we really are the default user and not someone else.

It verifies this using two things:

1. The certificate


2. The private RSA key that is used to sign that certificate



By validating the certificate and the signature created with the private key, the API server can confirm that the request was actually made by the default user and not by an impersonator.