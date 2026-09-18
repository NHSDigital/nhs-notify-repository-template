#!/bin/bash

# Triggers a remote GitHub workflow in nhs-notify-internal and waits for completion.

# Usage:
#   ./dispatch_internal_repo_workflow.sh \
#     --infraRepoName <repo> \
#     --releaseVersion <version> \
#     --targetWorkflow <workflow.yaml> \
#     --targetEnvironment <env> \
#     --targetComponent <component> \
#     --targetAccountGroup <group> \
#     --terraformAction <action> \
#     --internalRef <ref> \
#     --overrides <overrides> \
#     --overrideRoleName <name> \
#     --shardCount <count>

#
# All arguments are required except terraformAction, and internalRef.
# Example:
#   ./dispatch_internal_repo_workflow.sh \
#     --infraRepoName "nhs-notify-dns" \
#     --releaseVersion "v1.2.3" \
#     --targetWorkflow "deploy.yaml" \
#     --targetEnvironment "prod" \
#     --targetComponent "web" \
#     --targetAccountGroup "core" \
#     --terraformAction "apply" \
#     --internalRef "main" \
#     --overrides "tf_var=someString" \
#     --overrideRoleName nhs-service-iam-role \
#     --shardCount "4"

set -e

usage() {
  cat >&2 <<'EOF'
Usage:
  ./dispatch_internal_repo_workflow.sh \
    --infraRepoName <repo> \
    --releaseVersion <version> \
    --targetWorkflow <workflow.yaml> \
    --targetEnvironment <env> \
    --targetComponent <component> \
    --targetAccountGroup <group> \
    [--terraformAction <action>] \
    [--internalRef <ref>] \
    [--overrides <overrides>] \
    [--overrideRoleName <name>] \
    [--shardCount <count>]
EOF
  return 0
}

require_arg() {
  local name="$1"
  local value="$2"

  if [[ -z "$value" ]]; then
    echo "[ERROR] Missing required argument: $name" >&2
    usage
    exit 1
  fi

  return 0
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --infraRepoName) # Name of the infrastructure repo in NHSDigital org (required)
      infraRepoName="$2"
      shift 2
      ;;
    --releaseVersion) # Release version, commit, or tag to deploy (required)
      releaseVersion="$2"
      shift 2
      ;;
    --targetWorkflow) # Name of the workflow file to call in nhs-notify-internal (required)
      targetWorkflow="$2"
      shift 2
      ;;
    --targetEnvironment) # Terraform environment to deploy (required)
      targetEnvironment="$2"
      shift 2
      ;;
    --targetComponent) # Terraform component to deploy (required)
      targetComponent="$2"
      shift 2
      ;;
    --targetAccountGroup) # Terraform account group to deploy (required)
      targetAccountGroup="$2"
      shift 2
      ;;
    --terraformAction) # Terraform action to run (optional)
      terraformAction="$2"
      shift 2
      ;;
    --internalRef) # Internal repo reference branch or tag (optional, default: "main")
      internalRef="$2"
      shift 2
      ;;
    --overrides) # Terraform overrides for passing in extra variables (optional)
      overrides="$2"
      shift 2
      ;;
    --overrideRoleName) # Override the role name (optional)
      overrideRoleName="$2"
      shift 2
      ;;
    --shardCount) # Number of parallel shards to split tests across (optional)
      shardCount="$2"
      shift 2
      ;;
    *)
    echo "[ERROR] Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

require_arg "--infraRepoName" "${infraRepoName:-}"
require_arg "--releaseVersion" "${releaseVersion:-}"
require_arg "--targetWorkflow" "${targetWorkflow:-}"
require_arg "--targetEnvironment" "${targetEnvironment:-}"
require_arg "--targetComponent" "${targetComponent:-}"
require_arg "--targetAccountGroup" "${targetAccountGroup:-}"

if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "[ERROR] GH_TOKEN environment variable is not set or is empty." >&2
  exit 1
fi

# Token is minted by actions/create-github-app-token in the calling workflow
PR_TRIGGER_PAT="$GH_TOKEN"

GITHUB_API_ACCEPT_HEADER="Accept: application/vnd.github+json"
GITHUB_API_VERSION_HEADER="X-GitHub-Api-Version: 2022-11-28"

if [[ -z "$overrides" ]]; then
  overrides=""
fi

if [[ -z "$internalRef" ]]; then
  internalRef="main"
fi

echo "==================== Workflow Dispatch Parameters ===================="
echo "  infraRepoName:      $infraRepoName"
echo "  releaseVersion:     $releaseVersion"
echo "  targetWorkflow:     $targetWorkflow"
echo "  targetEnvironment:  $targetEnvironment"
echo "  targetComponent:    $targetComponent"
echo "  targetAccountGroup: $targetAccountGroup"
echo "  terraformAction:    $terraformAction"
echo "  internalRef:        $internalRef"
echo "  overrides:          $overrides"
echo "  overrideRoleName:   $overrideRoleName"
echo "  shardCount:         ${shardCount:-}"

DISPATCH_EVENT=$(jq -ncM \
  --arg internalRef "$internalRef" \
  --arg infraRepoName "$infraRepoName" \
  --arg releaseVersion "$releaseVersion" \
  --arg targetEnvironment "$targetEnvironment" \
  --arg targetAccountGroup "$targetAccountGroup" \
  --arg targetComponent "$targetComponent" \
  --arg terraformAction "$terraformAction" \
  --arg targetWorkflow "$targetWorkflow" \
  --arg overrides "$overrides" \
  --arg overrideRoleName "$overrideRoleName" \
  --arg shardCount "${shardCount:-}" \
  '{
    "ref": $internalRef,
    "inputs": (
      (if $infraRepoName != "" then { "infraRepoName": $infraRepoName } else {} end) +
      (if $terraformAction != "" then { "terraformAction": $terraformAction } else {} end) +
      (if $overrideRoleName != "" then { "overrideRoleName": $overrideRoleName } else {} end) +
      (if $shardCount != "" then { "shardCount": $shardCount } else {} end) +
      {
        "releaseVersion": $releaseVersion,
        "targetEnvironment": $targetEnvironment,
        "targetAccountGroup": $targetAccountGroup,
        "targetComponent": $targetComponent,
        "overrides": $overrides
      }
    )
  }')

echo "[INFO] Triggering workflow '$targetWorkflow' in nhs-notify-internal..."

trigger_response=$(curl -s -L \
  --proto '=https' \
  --fail \
  -X POST \
  -H "$GITHUB_API_ACCEPT_HEADER" \
  -H "Authorization: Bearer ${PR_TRIGGER_PAT}" \
  -H "$GITHUB_API_VERSION_HEADER" \
  "https://api.github.com/repos/NHSDigital/nhs-notify-internal/actions/workflows/$targetWorkflow/dispatches" \
  -d "$DISPATCH_EVENT" 2>&1)

if [[ $? -ne 0 ]]; then
  echo "[ERROR] Failed to trigger workflow. Response: $trigger_response" >&2
  exit 1
fi

echo "[INFO] Workflow trigger request sent successfully, waiting for completion..."

sleep 10 # Wait a few seconds before checking for the presence of the api to account for GitHub updating

# Poll GitHub API to check the workflow status
workflow_run_url=""

for _ in {1..18}; do

  response=$(curl -s -L \
    --proto '=https' \
    -H "$GITHUB_API_ACCEPT_HEADER" \
    -H "Authorization: Bearer ${PR_TRIGGER_PAT}" \
    -H "$GITHUB_API_VERSION_HEADER" \
    "https://api.github.com/repos/NHSDigital/nhs-notify-internal/actions/runs?event=workflow_dispatch")

  if ! echo "$response" | jq empty 2>/dev/null; then
    echo "[ERROR] Invalid JSON response from GitHub API during workflow polling:" >&2
    echo "$response" >&2
    exit 1
  fi

  workflow_run_url=$(echo "$response" | jq -r \
    --arg targetWorkflow "$targetWorkflow" \
    --arg targetEnvironment "$targetEnvironment" \
    --arg targetAccountGroup "$targetAccountGroup" \
    --arg targetComponent "$targetComponent" \
    --arg terraformAction "$terraformAction" \
    '.workflow_runs[]
      | select(.path == ".github/workflows/" + $targetWorkflow)
      | select(.name
          | contains($targetEnvironment)
          and contains($targetAccountGroup)
          and contains($targetComponent)
          and contains($terraformAction)
      )
      | .url')

  if [[ -n "$workflow_run_url" && "$workflow_run_url" != null ]]; then
    # Workflow_run_url is a list of all workflows which were run for this combination of inputs, but are the API uri
    workflow_run_url=$(echo "$workflow_run_url" | head -n 1)

    # Take the first and strip it back to being an accessible url
    # Example https://api.github.com/repos/MyOrg/my-repo/actions/runs/12346789 becomes
    # becomes https://github.com/MyOrg/my-repo/actions/runs/12346789
    workflow_run_ui_url=${workflow_run_url/api./} # Strips the api. prefix
    workflow_run_ui_url=${workflow_run_ui_url/\/repos/} # Strips the repos/ uri
    echo "[INFO] Found workflow run url: $workflow_run_ui_url"
    break
  fi

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Waiting for workflow to start..."
  sleep 10
done

if [[ -z "$workflow_run_url" || "$workflow_run_url" == null ]]; then
  echo "[ERROR] Failed to get the workflow run url. Exiting." >&2
  exit 1
fi

# Wait for workflow completion
while true; do
  sleep 10
  response=$(curl -s -L \
    --proto '=https' \
    -H "Authorization: Bearer ${PR_TRIGGER_PAT}" \
    -H "$GITHUB_API_ACCEPT_HEADER" \
    "$workflow_run_url")

  status=$(echo "$response" | jq -r '.status')
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Workflow status: $status"

  if [[ "$status" == "completed"  ]]; then
    conclusion=$(echo "$response" | jq -r '.conclusion')
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Workflow conclusion: $conclusion"

    if [[ -z "$conclusion" || "$conclusion" == "null" ]]; then
      echo "[WARN] Workflow marked completed but conclusion not yet available, retrying..."
      sleep 5
      continue
    fi

    if [[ "$conclusion" == "success"  ]]; then
      echo "[SUCCESS] Workflow completed successfully!"
      exit 0
    else
      echo "[FAIL] Workflow failed with conclusion: $conclusion" >&2
      exit 1
    fi
  fi
done
