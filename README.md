![github-cover](https://user-images.githubusercontent.com/70569022/233320406-da81d842-c0d9-4d63-938e-fe521203e4e0.png)

---

# btw

[btw](https://btw.so) is an open source personal website builder.

You can [sign up](https://btw.so) and use btw without installing anything. You can also use the open source version to self-host.

![btw-editor-screenshot](https://user-images.githubusercontent.com/70569022/233320021-e05c995f-4e4e-48a9-83de-f578d3662df1.png)

### Demo blogs published using btw:

-   [dc.btw.so](https://dc.btw.so/)
-   [siddg.com](https://www.siddg.com/about)

## Table of contents

-   [Getting Started](#getting-started)
    -   [Pre-requisites](#pre-requisites)
    -   [Installation](#installation)
    -   [Development](#development)
    -   [Local Email & OTP Behaviour](#local-email--otp-behaviour)
    -   [Custom Domains (Production)](#custom-domains-production)
-   [Community](#community)
-   [Coming next](#coming-next)
-   [License](#license)

## Getting started

These instructions will help you to get a copy of the project up and running on your local machine

### Pre-requisites

-   Install the latest version of Docker & Docker Compose
-   (Bundled) Postgres & Redis already run via docker-compose.dev.yml
-   (Bundled) MailHog for email interception – no external SMTP needed in dev

### Installation

Set ADMIN_EMAIL and ADMIN_SLUG in `deploy/docker-compose.dev.yml`. These are the only mandatory fields. Your database will be automatically configured on first startup.

Details of important variables in the compose file:

| Variable Name            | Description                                                                                                         |
|--------------------------|---------------------------------------------------------------------------------------------------------------------|
| TASKS_DATABASE_URL       | Connection URL to internal Postgres (already set for dev)                                                           |
| ADMIN_EMAIL              | Your email address (REQUIRED)                                                                                       |
| ADMIN_SLUG               | Unique slug (REQUIRED)                                                                                              |
| ADMIN_OTP                | OPTIONAL 6 digit code to enforce OTP (disabled / bypassed by default locally)                                      |
| SECRET / SECRET_KEY      | Change defaults; used for signing / encryption                                                                     |
| SMTP_HOST / PORT / USER / PASS / FROM | Only needed in production. In dev we auto‑route to MailHog                                             |
| ROOT_DOMAIN              | In dev forced to localhost / localhost:9222 for publisher                                                          |
| S3_*                     | OPTIONAL – enable image uploads (object storage)                                                                  |

### Development

1. From the `deploy` folder run:
    ```
    docker compose -f deploy/docker-compose.dev.yml up --build
    ```
2. Apps:
    - Writer (editor): http://localhost:9000
    - List UI: http://localhost:9300
    - Published content (publisher): http://localhost:9222
    - MailHog UI (captured emails): http://localhost:8025
3. Publish flow:
    - Set your name & slug in Writer Settings (http://localhost:9000/#/settings)
    - Create a note, give it a title, toggle Publish
    - Public URL (dev) will be: `http://localhost:9222/<note-slug>`
      (Internally we force `userDomain` to `localhost:9222` in development instead of `<slug>.btw.so`.)

### Local Email & OTP Behaviour

Goal: Never send real emails or OTPs from a development environment.

Implemented changes:

- Added a `mailhog` service in `docker-compose.dev.yml`. It exposes:
  - SMTP on port 1025 (containers use host `mailhog`)
  - Web UI on http://localhost:8025
- All services that would send email now receive these environment variables in development:
  - `SMTP_HOST=mailhog`
  - `SMTP_PORT=1025`
  - `SMTP_*` auth fields left blank (MailHog does not need auth)
- OTP / login emails are intercepted and viewable in the MailHog UI; nothing is delivered externally.
- If you wish to simulate production delivery, override the SMTP_* vars manually (not recommended for shared dev environments).

### Domain & URL Handling

Dynamic domain/protocol logic ensures proper URLs in both development and production:

- **Development**: Published notes use `http://localhost:9222` regardless of user slug
- **Production**: Published notes use `https://<custom-domain>` or `https://<slug>.<ROOT_DOMAIN>`
- **Meta tags**: `og:url` and other social sharing tags are now injected dynamically via React Helmet
- **Protocol logic**: Always HTTPS in production; HTTP only in development when `HTTPS_DOMAIN=0`

This prevents hardcoded localhost URLs from appearing in production and ensures SSL is enforced where needed.

Bypassing OTP locally:

- The code path checks for `ADMIN_OTP`. If unset, and single‑user mode is active, it logs you in without sending an OTP.
- To force OTP even in dev, set `ADMIN_OTP=123456` (or any 6 digit code) in the relevant service environment.
- To inspect the OTP email after enabling it, open MailHog and read the captured message.

### Custom Domains (Production)

In production, published content normally resolves to either:

- `<slug>.<ROOT_DOMAIN>` (default style)
- A verified custom domain stored in the `btw.custom_domains` table.

Steps for a production custom domain:

1. Point the domain's DNS (A / CNAME) to your reverse proxy / load balancer.
2. Configure your proxy (e.g., Nginx / Caddy / Traefik) to route the host to the `publisher` service.
3. Obtain TLS certificates (Let’s Encrypt). Automate via your proxy of choice.
4. Insert or update the domain via the app (Settings → Custom domain) or directly into `btw.custom_domains`.
5. Ensure `ROOT_DOMAIN` and any analytics / tracking environment variables reflect production values.

Local vs Production Domain Logic:

- Development hard‑overrides `userDomain` to `localhost:9222` so all published links are local.
- Production uses (in order): first custom domain, else `<slug>.<ROOT_DOMAIN>`.

### Troubleshooting Dev URLs

| Symptom | Fix |
|---------|-----|
| Opening a published note prompts HTTPS error | Ensure protocol is http:// in dev (we force this now in DashContainer) |
| 404 on refresh of a published note | Verify publisher container is running & port 9222 bound |
| No OTP email appears | Check MailHog UI; if absent, confirm `SMTP_HOST=mailhog` in container env |
| Real emails accidentally send | Remove any real SMTP_* variables from dev compose |

## Community

-   Twitter: https://twitter.com/btw_hq
-   Discord: https://discord.com/invite/vbDysPXJuF

## Coming next

-   Simplified development setup
-   Sample cloud deployment setup
-   Sample custom domain setup instructions
-   Feature roadmap
-   Documentation
-   Contributing guidelines

## License

See the [LICENSE](https://github.com/btw-so/btw/blob/main/LICENSE) file for details.
