#
FROM docker.io/library/fedora:latest
LABEL maintainer="https://github.com/mr700/"

ARG ARG_DEVPI_SERVER_VERSION=5.5.0
ARG ARG_DEVPI_WEB_VERSION=4.0.5
ARG ARG_DEVPI_CLIENT_VERSION=5.2.1

ENV DEVPI_SERVER_VERSION $ARG_DEVPI_SERVER_VERSION
ENV DEVPI_WEB_VERSION $ARG_DEVPI_WEB_VERSION
ENV DEVPI_CLIENT_VERSION $ARG_DEVPI_CLIENT_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="https://pypi.python.org/simple"
ENV PIP_TRUSTED_HOST="127.0.0.1"
ENV VIRTUAL_ENV /env

# devpi user
RUN groupadd --system --gid 1000 devpi \
    && adduser --system --uid 1000 --home /data --shell /sbin/nologin --gid 1000 devpi

# create a virtual env in $VIRTUAL_ENV, ensure it respects pip version
RUN dnf install -y virtualenv pip \
    && dnf clean all \
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
