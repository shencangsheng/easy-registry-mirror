# 基础镜像
FROM openresty/openresty:alpine

# 安装必须的依赖包
RUN apk add --no-cache \
    lua-cjson \
    curl \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-http

# 创建目录来存放Nginx配置文件
RUN mkdir -p /etc/openresty

# 拷贝本地Nginx配置文件到容器中
COPY nginx.conf /etc/openresty/nginx.conf

# 暴露端口
EXPOSE 80

# 启动OpenResty
CMD ["openresty", "-g", "daemon off;"]