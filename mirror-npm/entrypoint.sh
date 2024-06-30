#!/bin/sh
if
    ! whoami &
    >/dev/null
then
    if [ -w /etc/passwd ]; then
        echo "${VERDACCIO_USER_NAME:-default}:x:$(id -u):0:${VERDACCIO_USER_NAME:-default} user:${HOME}:/sbin/nologin" >>/etc/passwd
    fi
fi

if [ "$ENABLE_MAGIC" = "TRUE" ]; then
    export HTTP_PROXY="http://$MAGIC_USER:$MAGIC_PASSWORD@127.0.0.1:7890"
    export HTTPS_PROXY="http://$MAGIC_USER:$MAGIC_PASSWORD@127.0.0.1:7890"
fi

exec /usr/bin/dumb-init -- "$@"
