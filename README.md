# [Caddy](https://caddyserver.com/) Frontend Proxy

## This one Caddy Proxy implementation specifically addresses a simple Proxy solution: 

**This repo implements a 301 HTTP redirection of the Railway frontend legacy URL service (railway domain name `*.up.railway.app`) to the new Plus frontend Custom Domain URL (with their private domain name)**
This solution is essencial to avoid breaking the application. Some notifications is still pointing to those old URL.


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
