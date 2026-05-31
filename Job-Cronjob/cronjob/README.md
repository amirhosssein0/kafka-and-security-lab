What Is a CronJob in Kubernetes?

A CronJob is the same as the Job we worked with in the previous section, except that it runs on a schedule that we define.

For example, we can say: “run this Job once every week.”

We use it for maintenance-type tasks that need to happen periodically. For example, compressing log files is a repetitive task—every two weeks we can create ZIP archives of the log files.

1) kubectl apply -f multi-container/

2) kubectl exec -it deploy/multi-container-pod -c random-number-api -- ls -l /logs
total 28
-rw-r--r-- 1 root root   0 Jan  2 11:19 app.log
-rw-r--r-- 1 root root  29 Jan  2 11:15 archive-1767352500.tar.gz
-rw-r--r-- 1 root root  29 Jan  2 11:15 archive-1767352501.tar.gz
-rw-r--r-- 1 root root 299 Jan  2 11:15 archive-1767352514.tar.gz
-rw-r--r-- 1 root root  92 Jan  2 11:16 archive-1767352560.tar.gz
-rw-r--r-- 1 root root  91 Jan  2 11:17 archive-1767352620.tar.gz
-rw-r--r-- 1 root root  91 Jan  2 11:18 archive-1767352680.tar.gz
-rw-r--r-- 1 root root  91 Jan  2 11:19 archive-1767352740.tar.gz