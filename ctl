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
    Error "OS not supported: ${_OS}"
    exit 1
    ;;
esac

source ./magic-fn
source ./mirror-docker-fn

create_docker_vol "mirror-docker-vol"

create_docker_network "magic-network"
create_docker_network "mirror-docker-network"

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

function mirror_docker_entrypoint() {
    cd mirror-docker
    Info "Start Docker Registry"

    case "$2" in
    "install")
        mirror_docker_install
        ;;
    "uninstall")
        mirror_docker_uninstall
        ;;
    "join")
        mirror_docker_join
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
"docker")
    mirror_docker_entrypoint $@
    ;;
*)
    Error "Unknown option $1"
    exit 1
    ;;
esac
