#!/bin/bash

NEXUS_URL="http://localhost:8081"
NEXUS_USER="admin"
NEXUS_PASS=$(cat /nexus-data/admin.password)

function create_repo() {
    curl -u "${NEXUS_USER}:${NEXUS_PASS}" \
        -X POST "${NEXUS_URL}/service/rest/v1/repositories/pypi/hosted" \
        -H "Content-Type: application/json" \
        -d '{
           "name": "pypi-hosted",
           "online": true,
           "storage": {
             "blobStoreName": "default",
             "strictContentTypeValidation": true,
             "writePolicy": "allow_once"
           }
         }'
}

function create_proxy_repo() {
    curl -u "${NEXUS_USER}:${NEXUS_PASS}" \
        -X POST "${NEXUS_URL}/service/rest/v1/repositories/pypi/proxy" \
        -H "Content-Type: application/json" \
        -d '{
           "name": "pypi-proxy",
           "online": true,
           "proxy": {
             "remoteUrl": "https://pypi.org/"
           },
           "storage": {
             "blobStoreName": "default",
             "strictContentTypeValidation": true
           }
         }'
}

function create_group_repo() {
    curl -u "${NEXUS_USER}:${NEXUS_PASS}" \
        -X POST "${NEXUS_URL}/service/rest/v1/repositories/pypi/group" \
        -H "Content-Type: application/json" \
        -d '{
           "name": "pypi-group",
           "online": true,
           "storage": {
             "blobStoreName": "default",
             "strictContentTypeValidation": true
           },
           "group": {
             "memberNames": ["pypi-hosted", "pypi-proxy"]
           }
         }'
}
