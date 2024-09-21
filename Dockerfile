FROM alpine:latest

ENV S6_OVERLAY_VERSION=3.1.4.0
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0
# ENV S6_ARCH=x86_64
ENV S6_ARCH=aarch64

RUN set -x && apk add --no-cache bash libgcc libstdc++ curl curl-dev coreutils tzdata shadow libstdc++ logrotate py3-pip \
  && groupmod -g 911 users \
  && useradd -u 911 -U -d /config -s /bin/false abc \
  && usermod -G users abc \
  && mkdir -p /app /config /defaults \
  && pip3 install tzupdate \
  && apk del --purge \
  && rm -rf /tmp/* \
  && sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf


ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz

RUN apk add --no-cache jq curl bind-tools

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 CF_API=https://api.cloudflare.com/client/v4 RRTYPE=A CRON="*/5   *   *   *   *"

ADD root /

ENTRYPOINT [ "/init" ]
