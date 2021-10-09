FROM docker.io/alpine:3.14.2 AS builder

ARG GIT_REF=develop

ADD https://github.com/ddclient/ddclient/archive/${GIT_REF}.tar.gz /ddclient.tar.gz

RUN apk add --no-cache make autoconf automake wget && \
    tar -xvf /ddclient.tar.gz -C / && \
    cd /ddclient-* && \
    ./autogen && \
    ./configure --prefix=/usr/local --sysconfdir=/etc/ddclient --localstatedir=/var && \
    make && \
    make VERBOSE=1 check && \
    make DESTDIR="/ddclient-install" install && \
    chmod 600 /ddclient-install/etc/ddclient/ddclient.conf


FROM docker.io/alpine:latest

RUN apk add --no-cache perl

COPY --from=builder /ddclient-install/ /

VOLUME ["/var/cache/ddclient", "/etc/ddclient"]

ENTRYPOINT ["/usr/local/bin/ddclient"]
CMD ["-foreground"]
