FROM node:12.16.3-alpine3.11 as builder

WORKDIR /opt/verdaccio-gitlab-build

RUN apk --no-cache add git openssh
RUN git clone https://github.com/bufferoverflow/verdaccio-gitlab.git .

ENV NODE_ENV=production \
    VERDACCIO_BUILD_REGISTRY=https://registry.npmjs.org/

RUN yarn config set registry $VERDACCIO_BUILD_REGISTRY && \
    yarn install --production=false && \
    yarn code:docker-build && \
    yarn cache clean && \
    yarn install --production=true --pure-lockfile



FROM verdaccio/verdaccio:4.6.2
LABEL maintainer="https://github.com/bufferoverflow/verdaccio-gitlab"

# Go back to root to be able to install the plugin
USER root

COPY --from=builder /opt/verdaccio-gitlab-build/build /opt/verdaccio-gitlab/build
COPY --from=builder /opt/verdaccio-gitlab-build/package.json /opt/verdaccio-gitlab/package.json
COPY --from=builder /opt/verdaccio-gitlab-build/node_modules /opt/verdaccio-gitlab/node_modules

# Inherited from parent image
WORKDIR $VERDACCIO_APPDIR
RUN ln -s /opt/verdaccio-gitlab/build /verdaccio/plugins/verdaccio-gitlab

# Inherited from parent image
USER $VERDACCIO_USER_UID
