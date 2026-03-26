#!/bin/sh

set -eu 

# for backwards compatibility, seperates host and port from url
export FRONTEND_DOMAIN=${FRONTEND_DOMAIN:-${FRONTEND_HOST%:*}}
export FRONTEND_PORT=${FRONTEND_PORT:-${FRONTEND_HOST##*:}}

export BACKEND_DOMAIN=${BACKEND_DOMAIN:-${BACKEND_HOST%:*}}
export BACKEND_PORT=${BACKEND_PORT:-${BACKEND_HOST##*:}}

FRONTEND_DOMAIN=$(echo $FRONTEND_DOMAIN | sed -e 's|^[^/]*//||')
BACKEND_DOMAIN=$(echo $BACKEND_DOMAIN | sed -e 's|^[^/]*//||')

echo using frontend: ${FRONTEND_DOMAIN} with port: ${FRONTEND_PORT}
echo using backend: ${BACKEND_DOMAIN} with port: ${BACKEND_PORT}

exec caddy run --config /app/Caddyfile --adapter caddyfile 2>&1
