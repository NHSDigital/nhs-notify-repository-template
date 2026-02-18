#!/bin/bash

# Fail fast on errors, unset variables, and pipeline failures.
set -euo pipefail

# Ensure build.sh is executable and build the lambda artifacts before producing the Docker image.
chmod +x ./build.sh
./build.sh


# Parse arguments
BASE_IMAGE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --base-image)
      BASE_IMAGE="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$BASE_IMAGE" ]]; then
  echo "Error: --base-image parameter is required." >&2
  exit 1
fi

CSI="${PROJECT}-${ENVIRONMENT}-${COMPONENT}"
ECR_REPO="${ECR_REPO:-nhs-notify-main-acct}"
GHCR_LOGIN_TOKEN="${GITHUB_TOKEN}"
GHCR_LOGIN_USER="${GITHUB_ACTOR}"
LAMBDA_NAME="${LAMBDA_NAME:-$(basename "$PWD")}"

## Set IMAGE_TAG_SUFFIX based on git tag or short SHA for unique lambda image tagging in ECR.
#This ensures that each build produces a uniquely identifiable image, and tagged releases are easily traceable.
echo "Checking if current commit is a tag..."
GIT_TAG="$(git describe --tags --exact-match 2>/dev/null || true)"
if [ -n "$GIT_TAG" ]; then
  TAGGED="tag-$GIT_TAG"
  echo "On tag: $GIT_TAG, exporting IMAGE_TAG_SUFFIX as tag: $TAGGED"
  export IMAGE_TAG_SUFFIX="$TAGGED"

else
  SHORT_SHA="sha-$(git rev-parse --short HEAD)"
  echo "Not on a tag, exporting IMAGE_TAG_SUFFIX as short SHA: $SHORT_SHA"
  export IMAGE_TAG_SUFFIX="$SHORT_SHA"
fi

## Check if we are running in the context of a Terraform apply or plan, and set PUBLISH_LAMBDA_IMAGE accordingly. We only want to push images to ECR on apply, not on plan.
echo "Checking if ACTION is 'apply' to set PUBLISH_LAMBDA_IMAGE..."
if [ "$ACTION" = "apply" ]; then
  echo "Setting PUBLISH_LAMBDA_IMAGE to true for apply action"
  export PUBLISH_LAMBDA_IMAGE="true"
else
  echo "Not setting PUBLISH_LAMBDA_IMAGE for action ($ACTION)"
fi

# Ensure required AWS/ECR configuration is present.
echo "BASE_IMAGE: ${BASE_IMAGE:-<unset>}"
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID:-<unset>}"
echo "AWS_REGION: ${AWS_REGION:-<unset>}"
echo "COMPONENT: ${COMPONENT:-<unset>}"
echo "CSI: ${CSI:-<unset>}"
echo "ECR_REPO: ${ECR_REPO:-<unset>}"
echo "ENVIRONMENT: ${ENVIRONMENT:-<unset>}"
echo "GHCR_LOGIN_TOKEN: ${GHCR_LOGIN_TOKEN:-<unset>}"
echo "GHCR_LOGIN_USER: ${GHCR_LOGIN_USER:-<unset>}"
echo "IMAGE_TAG_SUFFIX: ${IMAGE_TAG_SUFFIX:-<unset>}"
echo "LAMBDA_NAME: ${LAMBDA_NAME:-<unset>}"

# Authenticate Docker with AWS ECR using an ephemeral login token.
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}".dkr.ecr."${AWS_REGION}".amazonaws.com

# Authenticate to GitHub Container Registry for base images.
if [ -n "${GHCR_LOGIN_USER:-}" ] && [ -n "${GHCR_LOGIN_TOKEN:-}" ]; then
  echo "Attempting GHCR login as ${GHCR_LOGIN_USER}..."
  if echo "${GHCR_LOGIN_TOKEN}" | docker login ghcr.io --username "${GHCR_LOGIN_USER}" --password-stdin; then
    echo "GHCR login successful."
  else
    echo "GHCR login failed!" >&2
  fi
fi

# Namespace tag by CSI and lambda name to avoid cross-environment collisions.
IMAGE_TAG="${CSI}-${LAMBDA_NAME}"

# Compose the full ECR image references.
ECR_REPO_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"

# Final tag names we will produce

IMAGE_TAG_LATEST="${ECR_REPO_URI}:${IMAGE_TAG}-latest"
IMAGE_TAG_SUFFIXED="${ECR_REPO_URI}:${IMAGE_TAG}-${IMAGE_TAG_SUFFIX}"

echo "Will build and tag images:"
echo "  LATEST -> ${IMAGE_TAG_LATEST}"
echo "  SUFFIXED -> ${IMAGE_TAG_SUFFIXED}"

# Build and tag the Docker image for the lambda.
# --load makes the built image available to the local docker daemon (single-platform).
docker buildx build \
  -f docker/lambda/Dockerfile \
  --platform=linux/amd64 \
  --provenance=false \
  --sbom=false \
  --build-arg BASE_IMAGE="${BASE_IMAGE}" \
  -t "${IMAGE_TAG_LATEST}" \
  -t "${IMAGE_TAG_SUFFIXED}" \
  --load \
  .

# Push the image tag(s) to ECR on apply only. The Terraform configuration will reference image digest.
if [ "${PUBLISH_LAMBDA_IMAGE:-false}" = "true" ]; then
  echo "PUBLISH_LAMBDA_IMAGE is set to true. Pushing Docker images to ECR..."


  for TAG in "${IMAGE_TAG_LATEST}" "${IMAGE_TAG_SUFFIXED}"; do
    echo "Pushing ${TAG}..."
    docker push "${TAG}"
  done

  echo "Push complete."
else
  echo "PUBLISH_LAMBDA_IMAGE is not set to true (likely TF Plan). Skipping Docker push."
  exit 0
fi
