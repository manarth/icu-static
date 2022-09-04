ARG SRC="https://git.alpinelinux.org/aports/tree/main/icu?h=master"
ARG VER="master"
ARG OWNER=manarth
ARG REPO=icu-static

FROM alpine:latest as build

RUN apk add alpine-sdk
# The `aports` repo contains the APKBUILD files for every Alpine Linux package.
RUN git clone https://gitlab.alpinelinux.org/alpine/aports /srv/aports
WORKDIR /srv/aports

# Prepare to build ICU.
RUN apk add python3 py-yaml
COPY icu-datapackaging-static.patch /tmp
RUN patch -p1 < /tmp/icu-datapackaging-static.patch

WORKDIR /srv/aports/main/icu
RUN abuild -F unpack
RUN abuild -F build
RUN abuild -F package

# Deploy into an empty container for packaging.
FROM scratch as dist
ARG SRC
ARG VER
ARG OWNER
ARG REPO

COPY --from=build /srv/aports/main/icu/pkg/icu/ /
COPY --from=build /bin/false /bin/false
ENTRYPOINT [ "/bin/false" ]

LABEL icu-static.source=${SRC}
LABEL icu-static.version=${VER}
LABEL org.opencontainers.image.source https://github.com/${OWNER}/${REPO}
