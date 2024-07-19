#!/bin/bash

INIT_FLAG="/nexus-data/initialized.flag"

/opt/sonatype/nexus/bin/nexus run &

NEXUS_PID=$!

if [ ! -f "$INIT_FLAG" ]; then

    while ! curl -s -o /dev/null http://localhost:8081; do
        echo "Nexus is not ready yet, waiting..."
        sleep 5
    done

    echo "Nexus is up and running."

    set -e

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
                        \"hostname\": \"magic\",
                        \"port\": 7890,
                        \"username\": \"${MAGIC_USERNAME}\",
                        \"password\": \"${MAGIC_PASSPWRD}\",
                        \"passwordIsIncluded\": true
                    }"
            curl -u "${NEXUS_USER}:${NEXUS_PASS}" \
                -X PUT "${NEXUS_URL}/service/rest/v1/settings/https" \
                -H "Content-Type: application/json" \
                -d "{
                        \"hostname\": \"magic\",
                        \"port\": 7890,
                        \"username\": \"${MAGIC_USERNAME}\",
                        \"password\": \"${MAGIC_PASSPWRD}\",
                        \"passwordIsIncluded\": true
                    }"
        fi
    }

    create_repo
    create_proxy_repo
    create_group_repo
    # setting_magic

    touch "$INIT_FLAG"

else
    echo "Initialization already done, skipping."
fi

wait $NEXUS_PID
