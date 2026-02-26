# # This script is run before the Terraform apply command.
# # It ensures all Node.js dependencies are installed, generates any required dependencies,
# # and builds all Lambda functions in the workspace before Terraform provisions infrastructure.
# pre.sh runs in the same shell as terraform.sh, not in a subshell
# any variables set or changed, any change of directory will persist once this script exits and returns control to terraform.sh
# REGION=$1
# ENVIRONMENT=$2
# ACTION=$3

# # Helper function for error handling
# run_or_fail() {
#   "$@"
#   if [ $? -ne 0 ]; then
#     echo "$* failed!" >&2
#     exit 1
#   fi
# }

# echo "Running app pre.sh"
# echo "REGION=$REGION"
# echo "ENVIRONMENT=$ENVIRONMENT"
# echo "ACTION=$ACTION"

## Required logic for building and pushing Lambda container images to ECR before Terraform provisions infrastructure.
# GIT_TAG="$(git describe --tags --exact-match 2>/dev/null || true)"
# if [ -n "${GIT_TAG}" ]; then
#   RELEASE_VERSION="${GIT_TAG#v}"
#   export TF_VAR_container_image_tag_suffix="release-${RELEASE_VERSION}-$(git rev-parse --short HEAD)"
#   echo "On tag: $GIT_TAG, image tag suffixes will be: release-${RELEASE_VERSION}-$(git rev-parse --short HEAD)"
# else
#   export TF_VAR_container_image_tag_suffix="sha-$(git rev-parse --short HEAD)"
#   echo "Not on a tag, image tag suffix will be: sha-$(git rev-parse --short HEAD)"
# fi

# # change to monorepo root
# cd $(git rev-parse --show-toplevel)

# run_or_fail npm ci
# run_or_fail npm run generate-dependencies --workspaces --if-present
# run_or_fail npm run lambda-build --workspaces --if-present

# # revert back to original directory
# cd -
