FROM alpine:latest
MAINTAINER Yukio Yamamoto <yukio@planeta.sci.isas.jaxa.jp>

ENV FLOW_VERSION=1.4
ENV CFITSIO_VERSION=3450
ENV LUA_VERSION=5.3

RUN set -ex \
  && mkdir -p \
       /tmp/src \
  && apk add --no-cache --virtual .build-deps \
       curl \
       gcc \
       make \
       libc-dev \
       lua${LUA_VERSION}-dev \
       libxml2-dev \
       curl-dev \
       libjpeg-turbo-dev \
       libpng-dev \
 # Install cfitsio
  && curl -fsSL https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio${CFITSIO_VERSION}.tar.gz | tar vxz -C /tmp/src/ \
  && cd /tmp/src/cfitsio \
  && ./configure \
  && make -j$(getconf _NPROCESSORS_ONLN) \
 # Install cspice
  && curl -fsSL https://naif.jpl.nasa.gov/pub/naif/toolkit/C/PC_Linux_GCC_64bit/packages/cspice.tar.Z | tar vxz -C /tmp/src/ \
  && cd /tmp/src/cspice/src/cspice \
  && gcc -c -ansi -m64 -O2 -fPIC -DNON_UNIX_STDIO *.c \
  && rm ../../lib/cspice.a \
  && ar rcs ../../lib/cspice.a *.o \
 # Install flow
  && curl -fsSL http://darts.isas.jaxa.jp/planet/tools/flow/flow-${FLOW_VERSION}.tar.gz | tar vxz -C /tmp/src/ \
  && cd /tmp/src/flow-${FLOW_VERSION} \
  && ln -s /usr/bin/lua${LUA_VERSION} /usr/bin/lua \
  && LDFLAGS=-lcurl ./configure \
        --prefix=/usr \
        --with-cfitsio=/tmp/src/cfitsio \
        --with-cspice=/tmp/src/cspice \
        --with-lua-inc=/usr/include/lua${LUA_VERSION} \
        --with-lua-lib=/usr/lib/lua${LUA_VERSION} \
        --enable-wms \
        --enable-spice-dsk \
  && make -j$(getconf _NPROCESSORS_ONLN) \
  && make install \
 # Install run deps
  && runDeps="$( \
    scanelf --needed --nobanner /usr/bin/flow_se /usr/bin/flow_ig /usr/bin/flow_cov \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u \
      | xargs -r apk info --installed \
      | sort -u \
    )" \
  && apk add --no-cache --virtual .spice-flow-rundeps $runDeps \
 # Clean up packages
  && apk del .build-deps \
  && rm -rf \
      /tmp/* \
      /var/tmp/* \
      /var/cache/apk/*
