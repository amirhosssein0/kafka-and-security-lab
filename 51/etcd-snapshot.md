1) export ECTDCTL_API=3
2) etcdctl snapshot
3) etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/etcd/ca.crt --cert=/etc/etcd/etcd.crt --key=/etc/etcd/etcd.key snapshot save /backup/etcd-snapshot.db 

4) etcdutl snapshot restore /opt/etcd-snapshot.db --data-dir=/var/lib/etcd-from-backup

5) vi /etc/kubernetes/manifests/etcd.yaml

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

6) kubectl delete pod/etcd-controlplane -n kube-system 
