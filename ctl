#!/bin/bash

# creator by shencangsheng

set -e
set -o pipefail

cd $(dirname $(realpath $0))

_PWD=$(pwd)

_ARGS=("$@")

source ./tools

_OS="$(uname -s)"

case "${_OS}" in
Linux*) machine=Linux ;;
*)
    Error "OS not supported: ${OS}"
    exit 1
    ;;
esac

function fn_magic() {
    cd magic
    Info "Start Magic"

    case "$2" in
    "install")
        local sub_url=
        read -r -p "Sub URL: " sub_url
        cat <<EOF >.env
MAGIC_SUB_URL=$sub_url
MAGIC_USERNAME=$RANDOM
MAGIC_PASSWORD=$RANDOM
EOF

        docker compose up -d

        cat <<EOF

vim /etc/docker/daemon.json 
==============================================
{
  "proxies": {
    "http-proxy": "http://$MAGIC_USERNAME:$MAGIC_PASSWORD@127.0.0.1:37890",
    "https-proxy": "http://$MAGIC_USERNAME:$MAGIC_PASSWORD@127.0.0.1:37890"
  }
}
===============================================

systemctl daemon-reload
systemctl restart docker
EOF
        ;;
    *)
        Error "Unknown option $1"
        exit 1
        ;;
    esac

}

case "$1" in
"magic")
    fn_magic
    ;;
*)
    Error "Unknown option $1"
    exit 1
    ;;
esac
