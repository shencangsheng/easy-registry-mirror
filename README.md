# Easy Registry Mirror

简体中文 | [English](./i18n/README.us-en.md)

在国内日渐严峻的网络下，无论是公司还是个人，自建仓库都是非常有必要的，这个项目用于快速搭建一个`Docker`私有仓库，并且无需修改已运行的`Dockerfile`/`docker-compose.yaml`，几乎没有迁移成本；未来会支持更多`npm`、`maven`、`pip`等仓库。

## Trying

```bash
git clone https://github.com/shencangsheng/easy-registry-mirror.git
cd easy-registry-mirror
chmod +x ctl
./ctl help
./ctl docker help
./ctl docker install
./ctl docker sync help
./ctl npm help
./ctl maven help
```

## Features

1. Proxy Docker Registry
2. Auto Sync Docker Images
3. NPM Registry
4. Maven Registry

## Upcoming Features

1. pip Registry

## Principle

原理是 Docker 的所有请求会先进入代理层，代理判断是否为获取镜像请求，代理层会先将镜像上传到 Docker Registry 中，再转发请求到 Docker Registry 中并响应；这样的策略与常见定期同步 Dockerhub 镜像不同的是，仅获取所需的镜像，避免流量和存储的过渡浪费。但依然提供了根据列表每周自动同步镜像的功能，执行 `./ctl docker sync help` 来了解如何使用

```mermaid
graph TD;
    A[Docker Request] --> B[Docker Registry Proxy];
    B --> C{docker pull?};
    C -- Yes --> D[docker pull image];
    C -- No --> E[Docker Registry Server];
    D --> F[Upload Docker Registry];
    F --> E
    E -- Response --> B
    B -- Response --> A
```

## Credits

This project was inspired by the [shencangsheng/registry-mirror-proxy](https://github.com/shencangsheng/registry-mirror-proxy) available in the GitHub project.

This project was inspired by the [verdaccio/verdaccio](https://github.com/verdaccio/verdaccio) available in the GitHub project.

## 疑难杂症

如果已经因为网络无法获取到镜像，那么点击 [Releases](https://github.com/shencangsheng/easy-registry-mirror/releases/tag/v1.1.0) 下载项目所需要的基础镜像，运行 `gunzip -c xxx.tar.gz | docker load` 来载入镜像，`./ctl magic help` 来了解如何使用

## License

A short snippet describing the license (MIT)

MIT © Cangsheng Shen
