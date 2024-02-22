FROM docker.io/library/alpine:latest AS build
LABEL maintainer="https://github.com/gunchev/"

ARG ARG_DEVPI_SERVER_VERSION
ARG ARG_DEVPI_CLIENT_VERSION
ARG ARG_DEVPI_WEB_VERSION

ENV DEVPI_SERVER_VERSION=$ARG_DEVPI_SERVER_VERSION
ENV DEVPI_WEB_VERSION=$ARG_DEVPI_WEB_VERSION
ENV DEVPI_CLIENT_VERSION=$ARG_DEVPI_CLIENT_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="https://pypi.python.org/simple"
ENV PIP_TRUSTED_HOST="127.0.0.1"
ENV VIRTUAL_ENV /env

# devpi user
RUN addgroup -S -g 1000 devpi \
    && adduser -u 1000 -h /data -s /sbin/nologin -G devpi -D devpi

# create a virtual env in $VIRTUAL_ENV, ensure it respects pip version
RUN apk add --update --no-cache python3 py3-virtualenv py3-pip \
    && virtualenv $VIRTUAL_ENV

ENV PATH $VIRTUAL_ENV/bin:$PATH

RUN pip install --upgrade pip \
    && pip install \
    "devpi-client==${DEVPI_CLIENT_VERSION}" \
    "devpi-web==${DEVPI_WEB_VERSION}" \
    "devpi-server==${DEVPI_SERVER_VERSION}"

EXPOSE 3141
VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER devpi
ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
