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

source ./magic-fn

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
    "join")
        magic_join
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
