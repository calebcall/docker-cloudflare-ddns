# ARG S6_OVERLAY_VERSION=3.1.4.0
# # FROM oznu/s6-alpine:3.12-${S6_ARCH:-amd64}
# FROM alpine:latest

# RUN apk add --no-cache jq curl bind-tools

# ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.0/s6-overlay-aarch64.tar.xz /tmp
# # ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz /tmp
# RUN tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz

# ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 CF_API=https://api.cloudflare.com/client/v4 RRTYPE=A CRON="*/5	*	*	*	*"

# COPY root /


ARG BASE_IMAGE
FROM alpine:latest

# ARG QEMU_ARCH
# ENV QEMU_ARCH=${QEMU_ARCH:-x86_64} S6_KEEP_ENV=1

# ARG NODE_VERSION
# ENV NODE_VERSION=${NODE_VERSION:-16.15.1}

ENV S6_OVERLAY_VERSION=3.1.4.0
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

# COPY qemu/qemu-${QEMU_ARCH}-static /usr/bin/

RUN set -x && apk add --no-cache bash libgcc libstdc++ curl curl-dev coreutils tzdata shadow libstdc++ logrotate py3-pip \
  # && groupmod -g 911 users \
  # && useradd -u 911 -U -d /config -s /bin/false abc \
  # && usermod -G users abc \
  && mkdir -p /app /config /defaults \
  && pip3 install tzupdate \
  && apk del --purge \
  && rm -rf /tmp/* \
  && sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf

ENV S6_ARCH=aarch64

# RUN cd /tmp \
#   && curl -SLO https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}-installer \
#   && chmod +x /tmp/s6-overlay-${S6_ARCH}-installer && /tmp/s6-overlay-${S6_ARCH}-installer /

ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.0/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.0/s6-overlay-aarch64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz

# RUN set -x && curl -fLO https://github.com/oznu/alpine-node/releases/download/${NODE_VERSION}/node-v${NODE_VERSION}-linux-${S6_ARCH}-alpine.tar.gz \
#   && tar -xzf node-v${NODE_VERSION}-linux-${S6_ARCH}-alpine.tar.gz -C /usr --strip-components=1 --no-same-owner \
#   && rm -rf node-v${NODE_VERSION}-linux-${S6_ARCH}-alpine.tar.gz \
#   && npm set prefix /usr/local \
#   && npm config set unsafe-perm true

RUN apk add --no-cache jq curl bind-tools

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=1 CF_API=https://api.cloudflare.com/client/v4 RRTYPE=A CRON="*/5   *   *   *   *"

ADD root /
# RUN chmod +x /app/cloudflare.sh

# CMD "/bin/bash"
# CMD "/app/cloudflare.sh"
ENTRYPOINT [ "/init" ]