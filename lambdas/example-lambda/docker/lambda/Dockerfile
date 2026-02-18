ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# Copy the built output from the build context (docker.sh should have run build.sh already)
COPY dist/ ${LAMBDA_TASK_ROOT}/

CMD [ "index.handler" ]
