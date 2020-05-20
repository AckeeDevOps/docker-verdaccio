FROM verdaccio/verdaccio:4.6.2 as builder

ENV NODE_ENV=production \
    VERDACCIO_BUILD_REGISTRY=https://registry.verdaccio.org

RUN apk --no-cache add openssl ca-certificates wget && \
    apk --no-cache add g++ gcc libgcc libstdc++ linux-headers git make python && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk && \
    apk add glibc-2.25-r0.apk

WORKDIR /opt/verdaccio-build
COPY . .

RUN git clone https://github.com/bufferoverflow/verdaccio-gitlab.git && \
    cd verdaccio-gitlab && \
    yarn install && \
    yarn start

FROM verdaccio/verdaccio:4.6.2

LABEL maintainer="https://github.com/verdaccio/verdaccio"

ENV VERDACCIO_APPDIR=/opt/verdaccio \
    VERDACCIO_USER_NAME=verdaccio \
    VERDACCIO_USER_UID=10001 \
    VERDACCIO_PORT=4873 \
    VERDACCIO_PROTOCOL=http
ENV PATH=$VERDACCIO_APPDIR/docker-bin:$PATH \
    HOME=$VERDACCIO_APPDIR

WORKDIR $VERDACCIO_APPDIR

COPY --from=builder /opt/verdaccio-build .
