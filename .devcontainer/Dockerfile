FROM mcr.microsoft.com/devcontainers/jekyll:3.4-bookworm
LABEL org.opencontainers.image.source=https://github.com/NHSDigital/nhs-notify-repository-template

COPY packages.txt packages.txt

RUN apt-get update && xargs apt-get -y install < packages.txt
