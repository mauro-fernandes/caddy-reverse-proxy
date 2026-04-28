# [Caddy](https://caddyserver.com/) Legacy Redirect Gateway (Caddy)

*TL/DR.:* This Caddy Proxy implementation provides a straightforward URL Forwarding solution.
The repository implements a 301 HTTP redirection from the legacy Railway frontend URL (*.up.railway.app) to the new Custom Domain URL.
This solution is essential to maintain application continuity, as several active notification templates still point to the legacy URL and cannot be updated at this time.

**This repository hosts a lightweight *Reverse Proxy* built with [Caddy](https://caddyserver.com) to handle traffic redirection from our legacy infrastructure to our new canonical frontend domain.**

## 📋 Context & Motivation

We have successfully migrated our frontend application to a custom subdomain. However, several external dependencies—primarily **Meta Business/WhatsApp notification templates**—still contain hardcoded links pointing to the original Railway-assigned URL.

Due to temporary administrative access constraints on our Meta Business account, these templates cannot be updated immediately. This service acts as a **Backward Compatibility Layer**, ensuring that users clicking on legacy notification links are seamlessly redirected to the correct destination without any service interruption.

## 🏗️ Architecture

The proxy performs a **Permanent Redirect (HTTP 301)** while preserving the full URI path and query parameters.

- **Legacy Entry Point (Source):** `https://${URL_ANTIGA_RAILWAY}`
- **Canonical Domain (Destination):** `https://${NOVO_DOMINIO_FRONTEND}`

### Infrastructure Details
- **Platform:** Deployed on [Railway](https://railway.app).
- **SSL/TLS & HSTS:** Handled upstream by Railway's Edge Network. The Caddy instance operates behind trusted proxies to ensure secure and valid HTTPS connections.
- **Redirection Logic:** 
    - Incoming requests matching the legacy host are redirected via `301`.
    - Any other traffic is automatically **aborted** for security and resource optimization.

## 🚀 Configuration (Caddyfile)

The service is configured via environment variables for maximum flexibility:

- `PORT`: The internal port assigned by Railway.
- `URL_ANTIGA_RAILWAY`: The full legacy hostname (e.g., `project.up.railway.app`).
- `NOVO_DOMINIO_FRONTEND`: The new destination hostname (e.g., `://yourdomain.com`).

## 🛠️ Validation

To verify that the redirect is functioning correctly, you can run the following command in your terminal:

```bash
curl -I https://railway.app
```

**Expected Result:**
- `HTTP/2 301`
- `Location: https://://yourdomain.com/any-path?param=1`

## ⚠️ Deprecation Plan

This service is intended to be a **long-term bridge**. It should only be decommissioned when:
1. Access to the **Meta Business Manager** is fully restored.
2. All notification templates have been updated to the new canonical URL.
3. Traffic monitoring logs indicate zero hits on the legacy endpoint for at least 30 consecutive days.

-----------------------




When deploying your Proxy service it will require you to set some service variables: **FRONTEND_DOMAIN** / **FRONTEND_PORT** 

**Note:** You will first need to have set a fixed `PORT` variable in both the frontend and backend services before deploying this template.

These are the four template variables that you will be required to fill out during the first deployment of this service, it is highly recommended to use [reference variables](https://docs.railway.app/guides/variables#referencing-another-services-variable).

Example:

```
FRONTEND_DOMAIN = ${{Frontend.RAILWAY_PRIVATE_DOMAIN}}
FRONTEND_PORT = ${{Frontend.PORT}}
```

**Relevant Caddy documentation:**

- [The Caddyfile](https://caddyserver.com/docs/caddyfile)
- [Caddyfile Directives](https://caddyserver.com/docs/caddyfile/directives)
- [reverse_proxy](https://caddyserver.com/docs/caddyfile/directives/reverse_proxy)

**Some prerequisites to help with common issues that could arise:**

- Both the frontend and backend need to listen on fixed ports, in my example project I have configured my frontend and backend to both listen on port `3000`
    - This can be done by [configuring your frontend and backend apps to listen on the `$PORT`](https://docs.railway.app/troubleshoot/fixing-common-errors) environment variable, then setting a `PORT` service variable to `3000`

- Since Railway's internal network is IPv6 only the frontend and backend apps will need to listen on `::` (all interfaces, both IPv4 and IPv6)

    **Start commands for some popular frameworks:**

    - **Gunicorn:** `gunicorn main:app -b [::]:${PORT:-3000}`

    - **Uvicorn:** `uvicorn main:app --host :: --port ${PORT:-3000}`

        - Uvicorn does not support dual-stack binding (IPv6 and IPv4) from the CLI, so while that start command will work to enable access from within the private network, this prevents you from accessing the app from the public domain if needed, I recommend using [Hypercorn](https://pgjones.gitlab.io/hypercorn/) instead

    - **Hypercorn:** `hypercorn main:app --bind [::]:${PORT:-3000}`

    - **Next:** `next start -H :: --port ${PORT:-3000}`

    - **Express/Nest:** `app.listen(process.env.PORT || 3000, "::");`
