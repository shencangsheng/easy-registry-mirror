# Swift Registry

[简体中文](https://github.com/shencangsheng/easy-registry-mirror) | English

This project aims to quickly set up a private repository based on Docker. Initially, it was created to set up a Docker private repository, but it has now been expanded to support `npm`, `Maven`, `PyPI`, and other repositories in the future. Users do not need to worry about proxy issues; simply configure a subscription, and the software will automatically configure it for use in various repositories. All traffic is confined within the respective containers, ensuring security and efficiency.

## 🌟 Features

- [x] `Docker`
- [x] `Maven`
- [x] `npm`
- [x] `PyPI`
- [ ] `APT`
- [ ] `Yum(RPM)`
- [ ] `Cargo`
- [ ] `Conda`

## 🛠️ Installation

<details>
<summary>Docker</summary>

```bash
$ ./ctl docker install
```

</details>

<details>
<summary>npm</summary>

```bash
$ ./ctl npm install
```

</details>

<details>
<summary>Maven</summary>

```bash
$ ./ctl maven install
```

</details>

<details>
<summary>PyPI</summary>

```bash
$ ./ctl pypi install
```

</details>

## 💡 Try

```bash
git clone https://github.com/shencangsheng/easy-registry-mirror.git
cd easy-registry-mirror
chmod +x ctl
./ctl help
./ctl docker help
./ctl docker install
```

## 📖 Features

1. Proxy Docker registry
2. Auto sync Docker images
3. npm private repository
4. Maven private repository
5. PyPI private repository
6. npm fastestmirror

## 🔮 Future features

1. APT
2. Yum(RPM)
3. Cargo
4. Conda
5. Go registry
6. Maven fastestmirror
7. PyPi fastestmirror

## 🤝 Libraries Used

These open source libraries were used to create this project.

- [shencangsheng/registry-mirror-proxy](https://github.com/shencangsheng/registry-mirror-proxy)
- [verdaccio/verdaccio](https://github.com/verdaccio/verdaccio)
- [sonatype/nexus3](https://github.com/sonatype/docker-nexus3)

## 🤝 Special thanks

1. **fastestmirror** feature, special thanks to [RubyMetric/chsrc](https://github.com/RubyMetric/chsrc) project for providing software support

## 📝 License

A short snippet describing the license (MIT)

MIT © Cangsheng Shen
