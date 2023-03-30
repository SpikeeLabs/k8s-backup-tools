# k8s-backup-tools

A toolbox to backup k8s related resources in k8s.

## Tools

---
### Etcd backup to S3
This tools backup an etcd to S3

<details>
<summary>CronJob</summary>

```yml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
name: etcd-backup
spec:
schedule: "0 0 * * *"
jobTemplate:
    spec:
    template:
        spec:
        containers:
            - name: etcd-backup
            image: spklabs/k8s-backup-tools
            args:
                - backup-etcd
                - my_db # database name prefix
                - https://x.x.x.x:2379 ## give the etcd pod address
            volumeMounts:
                - mountPath: /data
                name: etcd-certs
            env:
                - name: MINIO_SERVER
                value: https://s3.example.com # minio console address
                - name: MINIO_BUCKET
                value: etcd-backup # bucket name
                - name: MINIO_ACCESS_KEY
                valueFrom:
                    secretKeyRef:
                    name: etcd-backup
                    key: MINIO_ACCESS_KEY
                - name: MINIO_SECRET_KEY
                valueFrom:
                    secretKeyRef:
                    name: etcd-backup
                    key: MINIO_SECRET_KEY
            resources:
                requests:
                memory: "50Mi"
                cpu: "100m"
                limits:
                memory: "200Mi"
                cpu: "400m"
        volumes:
            - name: etcd-certs
            secret:
                secretName: mysecret
        # Do not restart pod, job takes care on restarting failed pod.
        restartPolicy: Never
```
</details>

---

### ClusterApi backup to S3

<details>
  <summary>CronJob</summary>

```yml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
name: etcd-backup
spec:
schedule: "0 0 * * *"
jobTemplate:
    spec:
    template:
        spec:
        containers:
            - name: etcd-backup
            image: spklabs/k8s-backup-tools
            args:
                - backup-capi
                - my_db # database name prefix
                - https://x.x.x.x:2379 ## give the etcd pod address
            volumeMounts:
                - mountPath: /data
                name: kube-config
            env:
                - name: MINIO_SERVER
                value: https://s3.example.com # minio console address
                - name: MINIO_BUCKET
                value: etcd-backup # bucket name
                - name: MINIO_ACCESS_KEY
                valueFrom:
                    secretKeyRef:
                    name: etcd-backup
                    key: MINIO_ACCESS_KEY
                - name: MINIO_SECRET_KEY
                valueFrom:
                    secretKeyRef:
                    name: etcd-backup
                    key: MINIO_SECRET_KEY
            resources:
                requests:
                memory: "50Mi"
                cpu: "100m"
                limits:
                memory: "200Mi"
                cpu: "400m"
        volumes:
            - name: kube-config
            secret:
                secretName: mysecret
        # Do not restart pod, job takes care on restarting failed pod.
        restartPolicy: Never
```
</details>
