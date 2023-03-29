# Fetch the mc command line client
FROM alpine:3.17.2 AS mc

RUN apk update && apk add --no-cache ca-certificates wget && \
    update-ca-certificates && \
    wget --progress=dot:giga -O /tmp/mc https://dl.minio.io/client/mc/release/linux-amd64/mc && \ 
    wget --progress=dot:giga -O /tmp/.colors https://raw.githubusercontent.com/mercuriev/bash_colors/master/bash_colors.sh && \ 
    chmod +x /tmp/mc /tmp/.colors

FROM k8s.gcr.io/etcd:3.5.1-0 AS build

# Then build our backup image
FROM alpine:3.17.2

RUN apk update && apk add --no-cache bash

WORKDIR /usr/local/bin

COPY --from=mc /tmp/.colors /tmp/mc ./

COPY --from=build /usr/local/bin/etcdctl .

COPY scripts ./ 
COPY utils/* ./

RUN mkdir -p /var/etcd/ /var/lib/etcd/ && \
    chmod -R +x /usr/local/bin

ENV DATE_FORMAT="+%d-%m-%Y %H:%M:%S"

WORKDIR /app

ENTRYPOINT [ "bash" ]
