#!/bin/bash

INIT_FLAG="/nexus-data/initialized.flag"

/opt/sonatype/nexus/bin/nexus run &

if [ ! -f "$INIT_FLAG" ]; then

    while ! curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/service/metrics/ping | grep -q "200"; do
        echo "Nexus is not ready yet, waiting..."
        sleep 5
    done

    echo "Nexus is up and running."

    local NEXUS_URL="http://localhost:8081"
    local NEXUS_USER="admin"
    local NEXUS_PASS=$(cat /nexus-data/admin.password)

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
             "remoteUrl": "https://pypi.org/",
             "contentMaxAge": 1440,
             "metadataMaxAge": 1440
           },
           "negativeCache": {
             "enabled": true,
             "timeToLive": 1440
           },
           "httpClient": {
             "blocked": false,
             "autoBlock": true,
             "connection": {
               "retries": 3,
               "userAgentSuffix": "",
               "timeout": 60,
               "enableCircularRedirects": false,
               "enableCookies": false
             }
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

    function setting_magic() {
        if [[ $MAGIC_ENABLE = "TRUE" ]]; then
            curl -u "${NEXUS_USER}:${NEXUS_PASS}" \
                -X PUT "${NEXUS_URL}/service/rest/v1/settings/http" \
                -H "Content-Type: application/json" \
                -d "{
           \"httpProxy\": {
             \"enabled\": true,
             \"host\": \"magic\",
             \"port\": 7890,
             \"authentication\": {
               \"username\": \"${MAGIC_USERNAME}\",
               \"password\": \"${MAGIC_PASSWORD}\"
             }
           },
           \"httpsProxy\": {
             \"enabled\": true,
             \"host\": \"magic\",
             \"port\": 7890,
             \"authentication\": {
               \"username\": \"${MAGIC_USERNAME}\",
               \"password\": \"${MAGIC_PASSWORD}\"
             }
           },
           \"nonProxyHosts\": [
             \"localhost\",
             \"127.0.0.1\"
           ]
         }"
        fi
    }

    create_repo
    create_proxy_repo
    create_group_repo
    setting_magic

    touch "$INIT_FLAG"

else
    echo "Initialization already done, skipping."
fi

fg %1
