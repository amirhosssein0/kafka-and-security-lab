Storing Data in the hostPath Volume

A hostPath volume stores data on a specific node—the node where the Pod is running.
This volume is not tied to the Pod lifecycle, meaning if the Pod is deleted and a new Pod is created, as long as it runs on the same node, it can still access the data.

In other words, the data is stored on the server/node itself.

Important note:
We said it’s on the node, not across the whole cluster. What does that mean?
If I have a cluster with 10 nodes and my Pod is running on node A, then if the Pod is deleted and later comes up on node B, it cannot access node A’s data through a hostPath volume. So it’s not cluster-wide—it’s node-level.

In today’s example, we have a Postgres Deployment that starts on a specific port, reads a Secret, and configures the database. But this Deployment doesn’t have persistent storage for its data.

We want to define a volume that remains persistent regardless of whether the Pod exists or not—meaning it stays durable at the node level.

It's like binding volumes in Docker!!

1) 
kubectl apply -f postgres-secret.yaml -f postgres-deployment.yaml

2) kubectl exec -it postgres-deployment-54dbd97489-56kql -- psql -U postgres
>postgres=# CREATE DATABASE testdb;
>postgres=# \c testdb;
>CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100), age INT);
>INSERT INTO users (name, age) VALUES ('Amir', 30), ('Hossein', 20);
>SELECT * FROM users;
 id |  name   | age 
----+---------+-----
  1 | Amir    |  30
  2 | Hossein |  20
(2 rows)
>\q

3) kubectl get pods

4) kubectl delete pod postgres-deployment-54dbd97489-56kql

5) kubectl get pods --> we see new pod

6) kubectl exec -it postgres-deployment-54dbd97489-k6lb4 -- psql -U postgres --> connenct to new pod

>postgres=# \c testdb;
You are now connected to database "testdb" as user "postgres".
testdb=# SELECT * FROM users;
 id |  name   | age 
----+---------+-----
  1 | Amir    |  30
  2 | Hossein |  20
(2 rows)