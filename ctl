#!/bin/bash
# Author: Cangsheng Sheng
# Email: shencangsheng@126.com
# Created: 2024-06-10
# Version: 1.0

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
    Info "Start Docker registry"

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
    Info "Start npm registry"

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
    "start")
        mirror_npm_start
        ;;
    "stop")
        mirror_npm_stop
        ;;
    "restart")
        mirror_npm_restart
        ;;
    "fastest|fastestmirror")
        mirror_npm_fastest_mirror
        ;;
    *)
        Error "Unknown option $2"
        exit 1
        ;;
    esac
}

function mirror_maven_entrypoint() {
    cd mirror-maven
    Info "Start Maven registry"

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
    "user")
        mirror_maven_user
        ;;
    "start")
        mirror_maven_start
        ;;
    "stop")
        mirror_maven_stop
        ;;
    "restart")
        mirror_maven_restart
        ;;
    *)
        Error "Unknown option $2"
        exit 1
        ;;
    esac
}

function mirror_pypi_entrypoint() {
    cd mirror-pypi
    Info "Start PyPI registry"

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
    "status")
        mirror_pypi_status
        ;;
    "clean")
        mirror_pypi_clean
        ;;
    "user")
        mirror_pypi_user
        ;;
    "start")
        mirror_pypi_start
        ;;
    "stop")
        mirror_pypi_stop
        ;;
    "restart")
        mirror_pypi_restart
        ;;
    *)
        Error "Unknown option $2"
        exit 1
        ;;
    esac
}

function help() {
    cat <<EOF

    Used for quickly setting up a private Docker registry without needing to modify existing Dockerfile or docker-compose.yaml files, resulting in almost no migration costs. Additionally, this project supports private repositories for Maven, npm, and PyPI, with plans to support more types of repositories in the future.

    Usage: ./ctl [OPTION...]

    Examples:
        ./ctl help
        ./ctl status
        ./ctl docker help
        ./ctl magic help
        ./ctl npm help
        ./ctl maven help
        ./ctl pypi help

    Other options:

         -h, --help                 Give this help list
           , --help-cn              中文帮助文档 
EOF
}

function help_cn() {
    cat <<EOF

    用于快速搭建一个 Docker 私有仓库，并且无需修改已运行的 Dockerfile / docker-compose.yaml，几乎没有迁移成本；此外，本项目还支持 Maven、npm 和 PyPI 的私有仓库，未来将支持更多仓库。

    Usage: ./ctl [OPTION...]

    Examples:
        ./ctl help
        ./ctl status
        ./ctl docker help
        ./ctl magic help
        ./ctl npm help
        ./ctl maven help
        ./ctl pypi help

    Other options:

         -h, --help                 帮助列表
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
python | pypi | pip | py)
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
