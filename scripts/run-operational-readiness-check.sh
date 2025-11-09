#!/bin/bash
# Wrapper script for operational readiness check

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${SCRIPT_DIR}/operational-readiness-check.py"

# Check if GITHUB_TOKEN is set
if [ -z "${GITHUB_TOKEN:-}" ] && [ -z "${GH_TOKEN:-}" ]; then
    echo "ERROR: GITHUB_TOKEN or GH_TOKEN environment variable must be set"
    echo ""
    echo "Usage:"
    echo "  export GITHUB_TOKEN=your_token_here"
    echo "  $0"
    exit 1
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 is not installed"
    exit 1
fi

# Install requests library if not available
python3 -c "import requests" 2>/dev/null || {
    echo "Installing requests library..."
    python3 -m pip install requests --quiet
}

# Run the script
echo "Running operational readiness check..."
echo ""
python3 "${SCRIPT_PATH}"
