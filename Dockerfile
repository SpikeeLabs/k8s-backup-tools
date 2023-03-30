# Fetch the mc command line client
FROM alpine:3.17.2 AS mc

RUN apk update && apk add --no-cache ca-certificates wget && \
    update-ca-certificates


RUN wget -q --show-progress --progress=dot:giga https://dl.minio.io/client/mc/release/linux-amd64/mc -O /tmp/mc  && \ 
    wget -q --show-progress --progress=dot:giga https://raw.githubusercontent.com/mercuriev/bash_colors/master/bash_colors.sh -O /tmp/.colors && \ 
    wget -q --show-progress --progress=dot:giga https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.4.0/clusterctl-linux-amd64 -O /tmp/clusterctl && \
    chmod +x /tmp/mc /tmp/.colors /tmp/clusterctl

FROM k8s.gcr.io/etcd:3.5.1-0 AS build

# Then build our backup image
FROM alpine:3.17.2

RUN apk add --no-cache bash

WORKDIR /usr/local/bin

COPY --from=mc /tmp/.colors /tmp/mc /tmp/clusterctl ./
COPY --from=build /usr/local/bin/etcdctl .
COPY scripts ./scripts
COPY utils/* ./utils/

RUN chmod -R +x /usr/local/bin/scripts /usr/local/bin/utils

ENV DATE_FORMAT="+%d-%m-%Y %H:%M:%S" \
    PATH="$PATH:/usr/local/bin/scripts:/usr/local/bin/utils"

WORKDIR /app

ENTRYPOINT [ "bash" ]
