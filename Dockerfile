FROM ubuntu:22.04
ARG SAMBA_VERSION=4.20.1
ARG S6_OVERLAY_VER=3.1.6.2
ARG PROJECT_VERSION=4.20.1
ARG S6_OVERLAY_ARCH=x86_64 # aarch64, x86_64
# https://github.com/just-containers/s6-overlay#which-architecture-to-use-depending-on-your-targetarch
# ^ is necessary because s6-overlay maintainer is overtly hostile
# to making the project compatible with TARGETARCH:
# https://github.com/just-containers/s6-overlay/issues/512

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install -yq \
       ca-certificates tzdata wget xz-utils

RUN mkdir -p /usr/src \
	&& cd /usr/src \
	&& wget https://download.samba.org/pub/samba/stable/samba-${SAMBA_VERSION}.tar.gz \
	&& tar xzf samba-${SAMBA_VERSION}.tar.gz
RUN cd /usr/src/samba-${SAMBA_VERSION}/bootstrap/generated-dists/ubuntu2204 \
	&& ./bootstrap.sh
RUN rm -rf /var/lib/apt/lists/*
RUN cd /usr/src/samba-${SAMBA_VERSION} \
	&& ./configure \
	--with-sendfile-support \
	--enable-spotlight \
	--without-ad-dc \
	--without-smb1-server \
	--disable-avahi \
	--without-systemd \
	--disable-cups --disable-iprint \
	--without-regedit --without-winexe \
	--with-profiling-data
RUN cd /usr/src/samba-${SAMBA_VERSION} \
	&& make -j 2 \
	&& make install
RUN mkdir -p /usr/local/samba/var/log

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VER}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VER}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz
ENV S6_KEEP_ENV=1
RUN mkdir -p /etc/cont-init.d
ENV PATH="/usr/local/samba/bin:/usr/local/samba/sbin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

CMD ["/usr/local/samba/sbin/smbd", "--foreground", "--no-process-group", "--configfile", "/usr/local/samba/etc/smb.conf"]
ENTRYPOINT ["/init"]
HEALTHCHECK CMD ps aux | grep -c 'smbd'

LABEL license="GPL-3.0-or-later"
LABEL maintainer="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.authors="Chris Dzombak <https://www.dzombak.com>"
LABEL org.opencontainers.image.url="https://github.com/cdzombak/samba-docker"
LABEL org.opencontainers.image.documentation="https://github.com/cdzombak/samba-docker/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/cdzombak/samba-docker.git"
LABEL org.opencontainers.image.version="${PROJECT_VERSION}"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"
LABEL org.opencontainers.image.title="samba-docker"
LABEL org.opencontainers.image.description="Up-to-date Samba Docker image optimized for NAS file sharing with full macOS Spotlight support"

# n.b. Elasticsearch 8.9.0 and newer **are not compatible with Samba**.
