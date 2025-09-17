# Expose RStudio Server port
###############################################
# books-of-ukraine DevContainer Base Image
#
# This Dockerfile builds a project-specific image extending the
# rocker devcontainer tidyverse image (R 4.4 + tidyverse stack).
# It adds:
#   - System libraries needed for geospatial, compilation, SQLite
#   - Quarto CLI for report rendering
#   - PowerShell (optional, mirrors devcontainer feature)
#   - Locale configuration (en_US.UTF-8)
#   - Optional pre-installation of project R package dependencies
#
# Build (from repository root):
#   docker build -f .devcontainer/Dockerfile -t books-of-ukraine:latest .
# Save image to host (Windows PowerShell):
#   docker save books-of-ukraine:latest -o C:/books-of-ukraine-image.tar
# (Create C:/books-of-ukraine-image.tar on C: drive)
#
# Also save the base image (for offline reproduction):
#   docker pull ghcr.io/rocker-org/devcontainer/tidyverse:4.4
#   docker save ghcr.io/rocker-org/devcontainer/tidyverse:4.4 -o C:/rocker-tidyverse-4.4.tar
#
# To use this image in devcontainer.json, replace the "image" field with:
#   "build": { "dockerfile": "Dockerfile", "context": ".devcontainer/.." }
# (or simply context root and dockerfile path)
###############################################

FROM ghcr.io/rocker-org/devcontainer/tidyverse:4.4

LABEL org.opencontainers.image.source="https://github.com/RG-FIDES/books-of-ukraine" \
			org.opencontainers.image.title="books-of-ukraine" \
			org.opencontainers.image.description="Analytic environment for Books of Ukraine project (R 4.4, tidyverse, Quarto, geospatial libs)" \
			org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
		TZ=Etc/UTC \
		LANG=en_US.UTF-8 \
		LC_ALL=en_US.UTF-8

# Build arguments (can be overridden at build time)
ARG INSTALL_R_PACKAGES=true
ARG QUARTO_VERSION=latest
ARG INSTALL_POWERSHELL=false

###############################################
# System dependencies & tooling
###############################################
RUN set -eux; \
		apt-get update; \
		apt-get install -y --no-install-recommends \
			locales \
			curl \
			ca-certificates \
			gnupg \
			software-properties-common \
			build-essential \
			make \
			git \
			wget \
			unzip \
			sqlite3 \
			libsqlite3-dev \
			libcurl4-openssl-dev \
			libssl-dev \
			libxml2-dev \
			libgeos-dev \
			libproj-dev \
			gdal-bin \
			libgdal-dev \
			libudunits2-dev \
			libv8-dev \
			libpng-dev \
			libjpeg-dev \
			libfreetype6-dev \
			libtiff5-dev \
			libpcre2-dev || true; \
		# Locale
		echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; \
		locale-gen; \
		update-ca-certificates; \
		rm -rf /var/lib/apt/lists/*

###############################################
# Install Quarto (deb package)
###############################################
RUN set -eux; \
		arch="$(dpkg --print-architecture)"; \
		mkdir -p /tmp/quarto; \
		if [ "$QUARTO_VERSION" = "latest" ]; then \
			 QUARTO_DEB_URL="https://quarto.org/download/linux/${arch}/deb/quarto-${QUARTO_VERSION}.deb"; \
		else \
			 QUARTO_DEB_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${arch}.deb"; \
		fi; \
		curl -fsSL "$QUARTO_DEB_URL" -o /tmp/quarto/quarto.deb || { echo "Falling back to generic latest URL"; curl -fsSL "https://quarto.org/download/latest/quarto-linux-${arch}.deb" -o /tmp/quarto/quarto.deb; }; \
		apt-get update; \
		apt-get install -y --no-install-recommends gdebi-core; \
		gdebi -n /tmp/quarto/quarto.deb || dpkg -i /tmp/quarto/quarto.deb || apt-get -f install -y; \
		rm -rf /tmp/quarto; \
		quarto --version || echo "Quarto install check failed"

###############################################
# Install PowerShell (optional) -- set --build-arg INSTALL_POWERSHELL=true
###############################################
RUN if [ "$INSTALL_POWERSHELL" = "true" ]; then \
		set -eux; \
		wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb; \
		dpkg -i packages-microsoft-prod.deb; \
		rm packages-microsoft-prod.deb; \
		apt-get update; \
		apt-get install -y --no-install-recommends powershell; \
		pwsh -NoLogo -NoProfile -Command "$PSVersionTable.PSVersion" || true; \
		rm -rf /var/lib/apt/lists/*; \
	else \
		echo "Skipping PowerShell install (INSTALL_POWERSHELL=false)"; \
	fi

###############################################
# (Optional) Pre-install R packages defined by project
# You can skip this during rapid iteration: --build-arg INSTALL_R_PACKAGES=false
###############################################
WORKDIR /opt/build
COPY utility ./utility
RUN if [ "$INSTALL_R_PACKAGES" = "true" ]; then \
			echo "Installing project R package dependencies..."; \
			Rscript utility/install-packages.R || echo "R package bootstrap encountered non-fatal issues"; \
		else \
			echo "Skipping R package installation (INSTALL_R_PACKAGES=false)"; \
		fi; \
		rm -rf /tmp/downloaded_packages || true

###############################################
# Final workdir (will be bind-mounted by devcontainer)
###############################################
WORKDIR /workspaces/books-of-ukraine

###############################################
# Environment metadata
###############################################
ENV PROJECT_NAME=books-of-ukraine

###############################################
# Health / version diagnostics + RStudio Server startup
###############################################
CMD ["bash", "-lc", "echo 'Container for books-of-ukraine ready'; R --version | head -n 1; quarto --version || true; command -v pwsh >/dev/null 2>&1 && pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion' || echo 'pwsh not installed'; rserver --www-port=8880 --auth-none=1 & sleep infinity"]
CMD ["sudo", "rstudio-server", "restart"]