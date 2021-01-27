FROM docker.io/library/alpine:latest AS build

ARG ARG_DEVPI_SERVER_VERSION=5.5.0
ARG ARG_DEVPI_WEB_VERSION=4.0.5
ARG ARG_DEVPI_CLIENT_VERSION=5.2.1

ENV DEVPI_SERVER_VERSION $ARG_DEVPI_SERVER_VERSION
ENV DEVPI_WEB_VERSION $ARG_DEVPI_WEB_VERSION
ENV DEVPI_CLIENT_VERSION $ARG_DEVPI_CLIENT_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="https://pypi.python.org/simple"
ENV PIP_TRUSTED_HOST="127.0.0.1"

LABEL maintainer="https://github.com/mr700/"

RUN apk add --update --no-cache python3 build-base python3-dev libffi-dev \
    && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && pip3 install --upgrade pip setuptools wheel

RUN pip --cache-dir=/root/.cache install \
    "devpi-client==${DEVPI_CLIENT_VERSION}" \
    "devpi-web==${DEVPI_WEB_VERSION}" \
    "devpi-server==${DEVPI_SERVER_VERSION}"

COPY mv_to_srv /mv_to_srv

RUN /mv_to_srv



FROM docker.io/library/alpine:latest

ARG ARG_DEVPI_SERVER_VERSION=5.5.0
ARG ARG_DEVPI_WEB_VERSION=4.0.5
ARG ARG_DEVPI_CLIENT_VERSION=5.2.1

ENV DEVPI_SERVER_VERSION $ARG_DEVPI_SERVER_VERSION
ENV DEVPI_WEB_VERSION $ARG_DEVPI_WEB_VERSION
ENV DEVPI_CLIENT_VERSION $ARG_DEVPI_CLIENT_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="https://pypi.python.org/simple"
ENV PIP_TRUSTED_HOST="127.0.0.1"

COPY --from=build /srv /srv

# devpi user
RUN addgroup -S -g 1000 devpi && adduser -S -u 1000 -h /data -s /sbin/nologin -G devpi -D devpi

ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 \
    && ln -sf python3 /usr/bin/python \
    && python3 -m ensurepip \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && pip3 install --upgrade pip setuptools wheel pydf \
    && pip install /srv/*.whl \
        "devpi-client==${DEVPI_CLIENT_VERSION}" \
        "devpi-web==${DEVPI_WEB_VERSION}" \
        "devpi-server==${DEVPI_SERVER_VERSION}" \
    && rm -rf /srv/* /root/.cache

EXPOSE 3141
VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER devpi
ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
