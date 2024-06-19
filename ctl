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
    "help")
        magic_help
        ;;
    *)
        Error "Unknown option $2"
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
    "sync")
        case "$3" in
        "exec")
            mirror_docker_exec_sync_images
            ;;
        "install")
            mirror_docker_install_sync_images
            ;;
        "uninstall")
            mirror_docker_uninstall_sync_images
            ;;
        "help")
            mirror_docker_help_sync_images
            ;;
        *)
            Error "Unknown option $3"
            exit 1
            ;;
        esac
        ;;
    "help")
        mirror_docker_help
        ;;
    *)
        Error "Unknown option $2"
        exit 1
        ;;
    esac
}

function help() {
    cat <<EOF

    Designed for quickly setting up a private Docker registry without requiring any modifications to existing Dockerfiles or docker-compose.yaml files, ensuring minimal migration costs. Future support will include additional repositories such as npm, Maven, and pip.

    Usage: ./ctl [OPTION...]

    Examples:
        ./ctl help
        ./ctl docker help
        ./ctl magic help

    Other options:

         -h, --help                 give this help list
           , --help-cn              中文帮助文档 
EOF
}

function help_cn() {
    cat <<EOF

    用于快速搭建一个 Docker 私有仓库，并且无需修改已运行的 Dockerfile / docker-compose.yaml，几乎没有迁移成本；未来会支持更多 npm、Maven、pip 等仓库。

    Usage: ./ctl [OPTION...]

    Examples:
        ./ctl help
        ./ctl docker help
        ./ctl magic help

    Other options:

         -h, --help                 give this help list
           , --help-cn              中文帮助文档 
EOF
}

case "$1" in
"magic")
    magic_entrypoint $@
    ;;
"docker")
    mirror_docker_entrypoint $@
    ;;
--help | -h | help)
    help
    exit 0
    ;;
--help-cn | help-cn)
    help_cn
    exit 0
    ;;
*)
    Error "Unknown option $1"
    exit 1
    ;;
esac
