FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/jekyll:2-bullseye
LABEL org.opencontainers.image.source=https://github.com/NHSDigital/nhs-notify-repository-template

COPY packages.txt packages.txt

USER root
RUN apt-get update \
    && xargs apt-get -y install --no-install-recommends < packages.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Run the container as a non-root user by default.
USER vscode
