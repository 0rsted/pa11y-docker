# syntax=docker/dockerfile:1.7

ARG NODE_VERSION=24.19.0

FROM node:${NODE_VERSION}-bookworm-slim AS build

ARG PA11Y_DASHBOARD_VERSION=latest
ENV PUPPETEER_CACHE_DIR=/opt/pa11y-dashboard/.cache/puppeteer

WORKDIR /opt/pa11y-dashboard

# Clone only the selected upstream release. The final image contains no git,
# compiler toolchain, or npm cache.
RUN apt-get update \
    && apt-get install --no-install-recommends -y ca-certificates curl git jq \
    && release="${PA11Y_DASHBOARD_VERSION}" \
    && if [ "$release" = latest ]; then \
         release="$(curl --fail --retry 3 -sS https://api.github.com/repos/pa11y/pa11y-dashboard/releases/latest | jq -r .tag_name)"; \
       fi \
    && test -n "$release" -a "$release" != null \
    && git clone --depth 1 --branch "$release" \
        https://github.com/pa11y/pa11y-dashboard.git . \
    && rm -rf .git /var/lib/apt/lists/*

# Puppeteer's bundled Chromium needs these libraries at install time.
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 \
        libcups2 libdbus-1-3 libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 \
        libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 xdg-utils wget \
    && PUPPETEER_SKIP_DOWNLOAD=true npm ci --omit=dev --ignore-scripts=false \
    && npx --no-install puppeteer browsers install chrome \
    && rm -rf /root/.npm /var/lib/apt/lists/*

FROM node:${NODE_VERSION}-bookworm-slim AS runtime

ARG PA11Y_DASHBOARD_VERSION=latest
ARG NODE_VERSION
LABEL org.opencontainers.image.title="Pa11y Dashboard" \
      org.opencontainers.image.description="Containerized Pa11y Dashboard for monitoring web accessibility" \
      org.opencontainers.image.authors="Pa11y developers and contributors" \
      org.opencontainers.image.url="https://github.com/pa11y/pa11y-dashboard" \
      org.opencontainers.image.documentation="https://github.com/0rsted/pa11y-docker/blob/master/README.md" \
      org.opencontainers.image.source="https://github.com/pa11y/pa11y-dashboard" \
      org.opencontainers.image.licenses="GPL-3.0-only" \
      org.opencontainers.image.version="${PA11Y_DASHBOARD_VERSION}" \
      org.opencontainers.image.base.name="node:${NODE_VERSION}-bookworm-slim"

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        fonts-liberation libasound2 libatk-bridge2.0-0 libatk1.0-0 \
        libcups2 libdbus-1-3 libdrm2 libgbm1 libgtk-3-0 libnspr4 libnss3 \
        libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 xdg-utils \
    && groupadd --system pptruser \
    && useradd --system --gid pptruser --groups audio,video --create-home pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/pa11y-dashboard
COPY --from=build --chown=pptruser:pptruser /opt/pa11y-dashboard /opt/pa11y-dashboard
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN mkdir -p /app \
    && chown pptruser:pptruser /app \
    && chmod 0755 /usr/local/bin/docker-entrypoint.sh

ENV NODE_ENV=production \
    PUPPETEER_CACHE_DIR=/opt/pa11y-dashboard/.cache/puppeteer \
    PUID=1000 \
    PGID=1000
EXPOSE 4000
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["node", "/opt/pa11y-dashboard/index.js"]
