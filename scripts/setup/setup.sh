#!/usr/bin/env bash

# WARNING: Please DO NOT edit this file! It is maintained in the Repository Template (https://github.com/nhs-england-tools/repository-template). Raise a PR instead.

set -euo pipefail

# Pre-Install dependencies and run make config on Github Runner.
#
# Usage:
#   $ ./setup.sh
# ==============================================================================

function main() {

  cd "$(git rev-parse --show-toplevel)"

  run-setup
}

function run-setup() {

  sudo apt install bundler -y
  time make config

  check-setup-status
}

# Check the exit status of tfsec.
function check-setup-status() {

  if [ $? -eq 0 ]; then
    echo "Setup completed successfully."
  else
    echo "Setup was unsuccessful."
    exit 1
  fi
}

# ==============================================================================

main "$@"

exit 0
