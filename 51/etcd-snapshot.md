1) etcdctl snapshot save /opt/etcd-backup.db \
--endpoints=https://127.0.0.1:2379 \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--key=/etc/kubernetes/pki/etcd/server.key 

2) etcdutl snapshot restore /opt/etcd-snapshot.db --data-dir=/var/lib/etcd-from-backup

3) vi /etc/kubernetes/manifests/etcd.yaml

```
- hostPath:
      path: /var/lib/etcd
      type: DirectoryOrCreate
    name: etcd-data
```

to

```
- hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
    name: etcd-data
```

4) kubectl delete pod/etcd-controlplane -n kube-system 
