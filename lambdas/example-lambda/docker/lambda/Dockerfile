ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# Copy the built output from the build context (docker.sh should have run build.sh already)
COPY dist/index.js ${LAMBDA_TASK_ROOT}/index.js

CMD [ "index.handler" ]
