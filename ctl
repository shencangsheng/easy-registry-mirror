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
source ./mirror-npm-fn
source ./mirror-maven-fn
source ./mirror-pypi-fn

create_docker_vol "mirror-docker-vol"
create_docker_vol "mirror-npm-vol"
create_docker_vol "mirror-maven-vol"
create_docker_vol "mirror-pypi-vol"

create_docker_network "magic-network"
create_docker_network "mirror-docker-network"

function get_services_status() {
    mirror_docker_status
    magic_status
    mirror_maven_status
    mirror_npm_status
    mirror_pypi_status
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
    "join")
        magic_join
        ;;
    "help")
        magic_help
        ;;
    "auth")
        magic_auth
        ;;
    "status")
        mirror_magic_status
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
    "status")
        mirror_docker_status
        ;;
    "clean")
        mirror_docker_clean
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

function mirror_npm_entrypoint() {
    cd mirror-npm
    Info "Start NPM Registry"

    case "$2" in
    "install")
        mirror_npm_install $@
        ;;
    "uninstall")
        mirror_npm_uninstall
        ;;
    "join")
        mirror_npm_join
        ;;
    "status")
        mirror_npm_status
        ;;
    "clean")
        mirror_npm_clean
        ;;
    "help")
        mirror_npm_help
        ;;
    *)
        Error "Unknown option $2"
        exit 1
        ;;
    esac
}

function mirror_maven_entrypoint() {
    cd mirror-maven
    Info "Start Maven Registry"

    case "$2" in
    "install")
        mirror_maven_install $@
        ;;
    "uninstall")
        mirror_maven_uninstall
        ;;
    "join")
        mirror_maven_join
        ;;
    "help")
        mirror_maven_help
        ;;
    "magic")
        mirror_maven_magic
        ;;
    "status")
        mirror_maven_status
        ;;
    "clean")
        mirror_maven_clean
        ;;
    *)
        Error "Unknown option $2"
        exit 1
        ;;
    esac
}

function mirror_pypi_entrypoint() {
    cd mirror-pypi
    Info "Start Python Registry"

    case "$2" in
    "install")
        mirror_pypi_install $@
        ;;
    "uninstall")
        mirror_pypi_uninstall
        ;;
    "join")
        mirror_pypi_join
        ;;
    "help")
        mirror_pypi_help
        ;;
    "magic")
        mirror_pypi_magic
        ;;
    "status")
        mirror_pypi_status
        ;;
    "clean")
        mirror_pypi_clean
        ;;
    *)
        Error "Unknown option $2"
        exit 1
        ;;
    esac
}

function help() {
    cat <<EOF

    Designed for quickly setting up a private Docker registry without requiring any modifications to existing Dockerfiles or docker-compose.yaml files, ensuring minimal migration costs. Future support will include additional repositories such as npm, maven, and pip.

    Usage: ./ctl [OPTION...]

    Examples:
        ./ctl help
        ./ctl status
        ./ctl docker help
        ./ctl magic help
        ./ctl npm help
        ./ctl maven help

    Other options:

         -h, --help                 give this help list
           , --help-cn              中文帮助文档 
EOF
}

function help_cn() {
    cat <<EOF

    用于快速搭建一个 Docker 私有仓库，并且无需修改已运行的 Dockerfile / docker-compose.yaml，几乎没有迁移成本；未来会支持更多 npm、maven、pip 等仓库。

    Usage: ./ctl [OPTION...]

    Examples:
        ./ctl help
        ./ctl status
        ./ctl docker help
        ./ctl magic help
        ./ctl npm help
        ./ctl maven help

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
"npm")
    mirror_npm_entrypoint $@
    ;;
"maven")
    mirror_maven_entrypoint $@
    ;;
"python|pypi")
    mirror_pypi_entrypoint $@
    ;;
"status")
    get_services_status
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
