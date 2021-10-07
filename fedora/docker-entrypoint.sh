#!/bin/sh

function defaults {
    : ${DEVPISERVER_SERVERDIR="/data/server"}
    : ${DEVPI_CLIENTDIR="/data/client"}
    : ${DEVPISERVER_SECRET="$DEVPISERVER_SERVERDIR/.secret.txt"}

    echo "DEVPISERVER_SERVERDIR is ${DEVPISERVER_SERVERDIR}"
    echo "DEVPI_CLIENTDIR is ${DEVPI_CLIENTDIR}"
    echo "DEVPISERVER_SECRET is ${DEVPISERVER_SECRET}"

    export DEVPISERVER_SERVERDIR DEVPI_CLIENTDIR DEVPISERVER_SECRET
}

function initialise_devpi {
    # devpi-gen-config
    echo "=== Initialise devpi-server ==="
    devpi-init --role=standalone --serverdir=/data/server --storage=sqlite --keyfs-cache-size=64000 --root-passwd="${DEVPI_PASSWORD}"
    devpi-server --start --restrict-modify=root --host=127.0.0.1 --port=3141
    sleep 1
    devpi use http://localhost:3141
    devpi login root --password="${DEVPI_PASSWORD}"
    devpi index -y -c public pypi_whitelist='*'
    devpi-server --stop
}

defaults

if [ "$1" = 'devpi' ] && [ $# == 1 ]; then
    # First run initialization
    if [ ! -f  "${DEVPISERVER_SERVERDIR}/.serverversion" ]; then
        echo "=== Initializing devpi-server ==="
        initialise_devpi
        sleep 2
    fi
    # Secret file (if missing/deleted)
    if [ ! -f "${DEVPISERVER_SECRET}" ]; then
        echo "=== Creating server secret ==="
        python -c 'import base64; import os; print(base64.b64encode(os.urandom(32)).decode("ascii"), end="")' \
            > "${DEVPISERVER_SECRET}"
        chmod u=r,go=- -- "${DEVPISERVER_SECRET}"
    fi

    echo "=== Launching devpi-server ==="
    exec devpi-server --secretfile="${DEVPISERVER_SECRET}" --restrict-modify=root --host=0.0.0.0 --port=3141
fi

echo "=== Running user provided command ==="
exec "$@"
