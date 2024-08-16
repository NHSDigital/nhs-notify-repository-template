#!/usr/bin/env bash

# Check if tfsec is installed
if ! command -v tfsec &> /dev/null; then
    echo "tfsec could not be found, please install it first."
    exit 1
fi

# Check if a directory was passed as an argument
if [ "$#" -eq 1 ]; then
    DIR_TO_SCAN="$1"
elif [ "$#" -gt 1 ]; then
    echo "Usage: $0 [directory]"
    exit 1
fi

# Run tfsec
echo "Running tfsec on directory: $DIR_TO_SCAN"
tfsec \
    --concise-output \
    --force-all-dirs \
    --exclude-downloaded-modules \
    --config-file ../config/tfsec.yaml
    "$DIR_TO_SCAN"


# Check the exit status of tfsec
if [ $? -eq 0 ]; then
    echo "tfsec completed successfully."
else
    echo "tfsec found issues."
    exit 1
fi