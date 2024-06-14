FROM alpine:3.20

RUN apk update && apk add --no-cache bash curl jq netcat-openbsd

COPY webhook_listener.sh /usr/local/bin/webhook_listener.sh

RUN chmod +x /usr/local/bin/webhook_listener.sh

CMD ["bash", "/usr/local/bin/webhook_listener.sh"]