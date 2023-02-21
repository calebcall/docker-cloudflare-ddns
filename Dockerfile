ARG S6_OVERLAY_VERSION=3.1.4.0
# FROM oznu/s6-alpine:3.12-${S6_ARCH:-amd64}
FROM alpine:latest

RUN apk add --no-cache jq curl bind-tools

ADD https://github.com/just-containers/s6-overlay/releases/download/v3.1.4.0/s6-overlay-aarch64.tar.xz /tmp
# ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-aarch64.tar.xz

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 CF_API=https://api.cloudflare.com/client/v4 RRTYPE=A CRON="*/5	*	*	*	*"

COPY root /
