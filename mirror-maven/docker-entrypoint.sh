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

  function setting_magic() {
    if [[ $MAGIC_ENABLE = "TRUE" ]]; then
      curl -u "${NEXUS_USER}:${NEXUS_PASS}" \
        -X POST "${NEXUS_URL}/service/extdirect" \
        -H "Content-Type: application/json" \
        -d "{
                      \"action\": \"coreui_HttpSettings\",
                      \"method\": \"update\",
                      \"data\": [
                        {
                          \"httpEnabled\": true,
                          \"httpHost\": \"magic\",
                          \"httpPort\": \"7890\",
                          \"httpAuthEnabled\": true,
                          \"httpAuthUsername\": \"${MAGIC_USERNAME}\",
                          \"httpAuthPassword\": \"${MAGIC_PASSWORD}\",
                          \"httpsEnabled\": true,
                          \"httpsHost\": \"magic\",
                          \"httpsPort\": \"7890\",
                          \"httpsAuthEnabled\": true,
                          \"httpsAuthUsername\": \"${MAGIC_USERNAME}\",
                          \"httpsAuthPassword\": \"${MAGIC_PASSWORD}\",
                          \"nonProxyHosts\": [],
                          \"timeout\": null,
                          \"retries\": null
                        }
                      ],
                      \"type\": \"rpc\",
                      \"tid\": 1
                    }"
    fi
  }

  setting_magic

  touch "$INIT_FLAG"

else
  echo "Initialization already done, skipping."
fi

wait $NEXUS_PID
