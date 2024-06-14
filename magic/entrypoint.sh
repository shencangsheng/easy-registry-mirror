#!/bin/sh

if [ -z "$url" ]; then
    echo "Error: The subscription address cannot be empty."
    exit 1
fi

wget -T 10 -O /root/.config/clash/config.yaml "$MAGIC_URL"

sed -i '/^external-controller:/d' /root/.config/clash/config.yaml

cat <<EOF >>/root/.config/clash/config.yaml

authentication:
  - "user:${MAGIC_USERNAME}"
secret: "${MAGIC_PASSWORD}"
external-controller: :9090
EOF

exec /clash
