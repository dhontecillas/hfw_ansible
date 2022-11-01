#!/bin/bash

# This scripts allows to push an image by running a local
# docker registry.
#
# usage: push [server] [docker_image]

docker run --rm -d -p 127.0.0.1:5000:5000 \
    --name tmp_docker_registry \
    -e REGISTRY_STORAGE=s3 \
    -e REGISTRY_STORAGE_S3_REGION=$S3_REGION \
    -e REGISTRY_STORAGE_S3_BUCKET=$S3_BUCKET \
    -e REGISTRY_STORAGE_S3_ACCESSKEY=$S3_KEY \
    -e REGISTRY_STORAGE_S3_SECRETKEY=$S3_SECRET \
    -e REGISTRY_STORAGE_CACHE_BLOBDESCRIPTOR=inmemory \
    -e REGISTRY_HTTP_SECRET=$REGISTRY_HTTP_SECRET \
    registry:2

# wait a little bit for the container to run
sleep 2

# pull the image to the repository
docker push $1

# and stop the temporary local registry
docker stop tmp_docker_registry
