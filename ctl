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

    local content=$(
        cat <<EOF

Remove the 'proxies' configuration in /etc/docker/daemon.json, Then restart docker

vim /etc/docker/daemon.json
==============================================
{
${_RED}
  "proxies": {
    "http-proxy": "http://user:xxxxx@127.0.0.1:37890",
    "https-proxy": "http://user:xxxxx@127.0.0.1:37890"
  }
${_NC}
}
===============================================

systemctl daemon-reload
systemctl restart docker
EOF
    )
    echo -e "$content"
}

function magic_install() {
    local sub_url=
    read -r -p "Sub URL: " sub_url

    local password=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 16)

    cat <<EOF >.env
MAGIC_SUB_URL=$sub_url
MAGIC_USERNAME=user
MAGIC_PASSWORD=$password
EOF

    docker compose up --build -d

    local content=$(
        cat <<EOF

Configure the proxy in /etc/docker/daemon.json, Then restart docker

vim /etc/docker/daemon.json

==============================================
{
${_GREEN}
  "proxies": {
    "http-proxy": "http://user:$password@127.0.0.1:37890",
    "https-proxy": "http://user:$password@127.0.0.1:37890"
  }
${_NC}
}
===============================================

systemctl daemon-reload
systemctl restart docker
EOF
    )
    echo -e "$content"
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

create_docker_vol "mirror-docker-vol"

create_docker_network "magic-network"
create_docker_network "mirror-docker-network"

case "$1" in
"magic")
    magic_entrypoint $@
    ;;
*)
    Error "Unknown option $1"
    exit 1
    ;;
esac
