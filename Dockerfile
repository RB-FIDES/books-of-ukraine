# syntax=docker/dockerfile:1.7
###############################################
# books-of-ukraine.v5 - Geospatial + Analytics Image
# Base: rocker/geospatial (R 4.5 + sf, terra, gdal ready)
# Adds: Quarto, pak-managed project deps, optional PowerShell
###############################################

ARG BASE_R_IMAGE=ghcr.io/rocker-org/geospatial:4.4.1
FROM ${BASE_R_IMAGE}

LABEL org.opencontainers.image.source="https://github.com/RG-FIDES/books-of-ukraine" \
  org.opencontainers.image.title="books-of-ukraine.v5" \
  org.opencontainers.image.description="Analytic environment (R geospatial, Quarto, pak) - default R 4.4.1 for RStudio compatibility; override with --build-arg BASE_R_IMAGE=ghcr.io/rocker-org/geospatial:4.5.0" \
  org.opencontainers.image.licenses="MIT"

ARG QUARTO_VERSION=latest
ARG INSTALL_POWERSHELL=true
ARG INSTALL_R_PACKAGES=true
ENV DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    CRAN_REPO=https://packagemanager.posit.co/cran/__linux__/bookworm/latest \
    MAKEFLAGS=-j"$(nproc)"

# Set CRAN repo globally
RUN echo "options(repos = c(CRAN='${CRAN_REPO}'))" >> /usr/local/lib/R/etc/Rprofile.site

###############################################
# System utilities + build tooling
###############################################
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      curl gdebi-core git locales unzip libv8-dev libpq-dev \
      libxml2-dev libssl-dev libcurl4-openssl-dev sqlite3 libsqlite3-dev \
      make build-essential wget; \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; \
    locale-gen; \
    rm -rf /var/lib/apt/lists/*

###############################################
# Quarto CLI
###############################################
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    if [ "$QUARTO_VERSION" = "latest" ]; then \
        QUARTO_DEB_URL="https://quarto.org/download/linux/${arch}/deb/quarto-${QUARTO_VERSION}.deb"; \
    else \
        QUARTO_DEB_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${arch}.deb"; \
    fi; \
    curl -fsSL "$QUARTO_DEB_URL" -o /tmp/quarto.deb || curl -fsSL "https://quarto.org/download/latest/quarto-linux-${arch}.deb" -o /tmp/quarto.deb; \
    gdebi -n /tmp/quarto.deb || dpkg -i /tmp/quarto.deb || apt-get -f install -y; \
    rm -f /tmp/quarto.deb; \
    quarto --version || true

###############################################
# Optional PowerShell
###############################################
RUN if [ "$INSTALL_POWERSHELL" = "true" ]; then \
      set -eux; \
      apt-get update; \
      apt-get install -y --no-install-recommends ca-certificates gnupg; \
      mkdir -p /etc/apt/keyrings; \
      curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg; \
      chmod 644 /etc/apt/keyrings/microsoft.gpg; \
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/microsoft-prod.list; \
      apt-get update; \
      apt-get install -y --no-install-recommends powershell || echo 'PowerShell install failed'; \
      rm -rf /var/lib/apt/lists/*; \
    else echo "Skipping PowerShell"; fi

WORKDIR /opt/build
COPY utility ./utility
COPY scripts/install-packages-pak.R ./install-packages-pak.R

###############################################
# Install R packages via pak (layer cached)
###############################################
RUN if [ "$INSTALL_R_PACKAGES" = "true" ]; then \
      R -q -e "if(!requireNamespace('pak', quietly=TRUE)) install.packages('pak')"; \
      R -q -e "source('install-packages-pak.R')" || echo 'Package install step had non-fatal issues'; \
    else echo 'Skipping R package install'; fi

###############################################
# Final workspace
###############################################
WORKDIR /workspaces/books-of-ukraine
ENV PROJECT_NAME=books-of-ukraine

# Set RStudio default working directory to mounted repo
ENV HOME=/workspaces/books-of-ukraine
ENV RSTUDIO_HOME=/workspaces/books-of-ukraine

###############################################
# RStudio Server (adds web IDE on port 8787)
###############################################
ARG RSTUDIO_VERSION=2024.09.0-375
RUN set -eux; \
    . /etc/os-release; \
    case "$VERSION_CODENAME" in \
      bookworm) DIST_PATH="debian12" ;; \
      bullseye) DIST_PATH="debian11" ;; \
      jammy) DIST_PATH="jammy" ;; \
      focal) DIST_PATH="focal" ;; \
      *) DIST_PATH="debian12" ;; \
    esac; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      gdebi-core psmisc libnss3 libx11-6 libxkbcommon0 libxcomposite1 \
      libxrandr2 libxtst6 libdrm2 libgbm1; \
    wget -qO /tmp/rstudio-server.deb "https://download2.rstudio.org/server/${DIST_PATH}/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb" \
      || (echo 'FALLBACK: trying jammy build' && wget -qO /tmp/rstudio-server.deb "https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb"); \
    gdebi -n /tmp/rstudio-server.deb || dpkg -i /tmp/rstudio-server.deb || apt-get -f install -y; \
    rm -f /tmp/rstudio-server.deb; \
    rstudio-server version || true; \
    apt-get clean; rm -rf /var/lib/apt/lists/*

ENV RSTUDIO_USER=admin RSTUDIO_PASSWORD=alphabet

RUN printf '#!/usr/bin/env bash\nset -euo pipefail\n: "${RSTUDIO_USER:=admin}"; : "${RSTUDIO_PASSWORD:=alphabet}";\nif ! id "$RSTUDIO_USER" >/dev/null 2>&1; then useradd -m -s /bin/bash "$RSTUDIO_USER"; usermod -d /workspaces/books-of-ukraine "$RSTUDIO_USER"; fi;\necho "$RSTUDIO_USER:$RSTUDIO_PASSWORD" | chpasswd;\necho "[startup] RStudio Server user=$RSTUDIO_USER port=8787";\nexec /usr/lib/rstudio-server/bin/rserver --server-daemonize=0 --www-port=8787 --server-user "$RSTUDIO_USER"\n' > /usr/local/bin/start-rstudio.sh && chmod +x /usr/local/bin/start-rstudio.sh

EXPOSE 8787 8888
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD wget -q -O /dev/null http://localhost:8787/ || exit 1

CMD ["/usr/local/bin/start-rstudio.sh"]

###############################################
# R terminal profile for VS Code (devcontainer)
###############################################
# If you want VS Code to offer an R terminal profile automatically, add this to your devcontainer.json:
#
# "customizations": {
#   "vscode": {
#     "settings": {
#       "terminal.integrated.profiles.linux": {
#         "R": { "path": "/usr/local/bin/R", "args": ["--no-save", "--quiet"], "icon": "symbol-method" }
#       }
#     }
#   }
# }
#
# This is a VS Code config, not a Dockerfile command. The R binary is already available in your image at /usr/local/bin/R.
#
# To use R interactively in the container shell, just run:
# R
#
# No Dockerfile changes are needed for R terminal support beyond what you already have.

COPY . /workspaces/books-of-ukraine
