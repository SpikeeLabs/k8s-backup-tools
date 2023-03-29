#! /bin/bash
set -e -o pipefail

DB="$1"

ENDPOINTS="$2"
MINIO_API_VERSION="${MINIO_API_VERSION:S3v4}"
DATE=$(date "$DATE_FORMAT")
FILENAME="$DB-$DATE"


echo Using $ENDPOINTS as endpoint
echo Using $MINIO_API_VERSION as api verison



mc --insecure alias set pg "$MINIO_SERVER" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY" --api "$MINIO_API_VERSION"

echo "Dumping $DB to $FILENAME"

echo "> ETCDCTL_API=3 etcdctl --endpoints=$ENDPOINTS --cert=/certs/server.crt --cacert=/certs/ca.crt --key=/certs/server.key snapshot save $FILENAME"

etcdctl --endpoints=$ENDPOINTS --cert=/certs/server.crt --cacert=/certs/ca.crt --key=/certs/server.key snapshot save "$FILENAME"

echo " coping $FILENAME to pg/${MINIO_BUCKET}/${DB}/ "

echo "> mc cp $FILENAME pg/${MINIO_BUCKET}/${DB}/ --json "

REMOTE_PATH="pg/$MINIO_BUCKET/$DB/$FILENAME"

mc --insecure cp "$FILENAME" "$REMOTE_PATH" --json  || { echo "Backup failed"; mc rm "$REMOTE_PATH"; exit 1; }

echo "size check"

ls -lah "$FILENAME"

echo "Backup complete"
