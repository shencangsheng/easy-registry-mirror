# Easy Registry Mirror

English | [简体中文](https://github.com/shencangsheng/easy-registry-mirror)

In today's increasingly challenging environment, it is essential for both companies and individuals to start building their own repositories. This project facilitates the rapid setup of a private `Docker registry` without requiring any modifications to existing `Dockerfile` or `docker-compose.yaml` files, ensuring minimal migration costs. Future support will include additional repositories such as `npm`, `maven`, and `pip`.

## Trying

```bash
git clone https://github.com/shencangsheng/easy-registry-mirror.git
cd easy-registry-mirror
chmod +x ctl
./ctl help
./ctl docker install
./ctl docker sync help
```

## Features

1. Docker Registry
2. Auto Sync Docker Images

## Upcoming Features

1. npm Registry

## Principle

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

## Problem

If your server can no longer pull images, download the required images from the project's `Releases`. On your server, run `gunzip -c xxx.tar.gz | docker load` to load the images. Use `./ctl magic help` to learn how to use the project.

## License

A short snippet describing the license (MIT)

MIT © Cangsheng Shen
