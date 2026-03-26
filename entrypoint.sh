#!/bin/sh

set -eu 

# Limpa o protocolo (https://) caso o usuário tenha colado a URL completa no Railway
# Isso evita o erro de "module value cannot be null" ou falha no Matcher host
URL_ANTIGA_RAILWAY=$(echo ${URL_ANTIGA_RAILWAY:-} | sed -e 's|^[^/]*//||')
NOVO_DOMINIO_FRONTEND=$(echo ${NOVO_DOMINIO_FRONTEND:-} | sed -e 's|^[^/]*//||')

# Exporta para o Caddy enxergar
export URL_ANTIGA_RAILWAY
export NOVO_DOMINIO_FRONTEND

echo "Configurando Redirecionamento 301:"
echo "De: ${URL_ANTIGA_RAILWAY}"
echo "Para: https://${NOVO_DOMINIO_FRONTEND}"

# Executa o Caddy usando o arquivo na pasta /app
exec caddy run --config /app/Caddyfile --adapter caddyfile 2>&1
