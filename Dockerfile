# latest tag, i know ...
ARG ALPINE_VERSION=latest
FROM alpine:${ALPINE_VERSION}

ARG ANSIBLE_VERSION="8.1.0"
COPY ./entrypoint.sh /usr/local/bin

RUN set -euxo pipefail ;\
    sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories ;\
    apk add --no-cache --update --virtual .build-deps g++ python3-dev build-base libffi-dev openssl-dev ;\
    apk add --no-cache --update python3 py3-pip ca-certificates openssh-client sshpass dumb-init su-exec ;\
    pip3 install --no-cache --upgrade setuptools wheel ansible==${ANSIBLE_VERSION} ;\
    apk del --no-cache --purge .build-deps ;\
    rm -rf /var/cache/apk/* ;\
    rm -rf /root/.cache ;\
    mkdir -p /etc/ansible/ ;\
    /bin/echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts ;\
    ssh-keygen -q -t ed25519 -N '' -f /root/.ssh/id_ed25519 ;\
    mkdir -p ~/.ssh && echo "Host *" > ~/.ssh/config && echo " StrictHostKeyChecking no" >> ~/.ssh/config ;\
    chmod +x /usr/local/bin/entrypoint.sh ;\
    adduser -s /bin/ash -u 1000 -D -h /ansible ansible


WORKDIR /ansible

ENTRYPOINT ["/usr/bin/dumb-init","--","entrypoint.sh"]
CMD ["/bin/sh"]
