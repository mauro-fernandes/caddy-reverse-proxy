FROM caddy:2.7-alpine

WORKDIR /app

COPY Caddyfile ./
COPY entrypoint.sh ./

# Garante permissão de execução e formata o Caddyfile
RUN chmod +x entrypoint.sh && caddy fmt --overwrite Caddyfile
EXPOSE 80

# No Railway, é melhor usar o CMD diretamente para chamar o script
CMD ["./entrypoint.sh"]
