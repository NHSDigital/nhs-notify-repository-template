ARG BASE_IMAGE

FROM ${BASE_IMAGE}

WORKDIR /app

COPY dist/ .

EXPOSE 8080

CMD ["node", "server.js"]
