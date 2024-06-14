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

function magic_uninstall() {
    docker compose down
    rm -f .env
}

function magic_install() {
    local sub_url=
    read -r -p "Sub URL: " sub_url

    local password=$(openssl rand -base64 12)

    cat <<EOF >.env
MAGIC_SUB_URL=$sub_url
MAGIC_USERNAME=user
MAGIC_PASSWORD=$password
EOF

    docker compose up -d

    cat <<EOF

vim /etc/docker/daemon.json
==============================================
{
  "proxies": {
    "http-proxy": "http://user:$password@127.0.0.1:37890",
    "https-proxy": "http://user:$password@127.0.0.1:37890"
  }
}
===============================================

systemctl daemon-reload
systemctl restart docker
EOF
}

function magic_entrypoint() {
    cd magic
    Info "Start Magic"

    case "$2" in
    "install")
        magic_install $@
        ;;
    "uninstall")
        magic_uninstall
        ;;
    *)
        Error "Unknown option $1"
        exit 1
        ;;
    esac

}

case "$1" in
"magic")
    magic_entrypoint $@
    ;;
*)
    Error "Unknown option $1"
    exit 1
    ;;
esac
