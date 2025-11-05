#!/usr/bin/env bash
set -euo pipefail

# -------- GitHub CLI Monitor for PRs and Workflow Runs -----------------------
# Helper script to monitor pull requests and GitHub Actions workflow runs
# using the GitHub CLI (gh) tool.

# -------- Helpers -------------------------------------------------------------
need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing $1. Please install it."; exit 2; }; }
need gh

# -------- Functions -----------------------------------------------------------

# Show open pull requests
show_open_prs() {
  echo "📋 Listing open pull requests..."
  echo ""
  gh pr list --state open
}

# List recent workflow runs
list_recent_runs() {
  local limit="${1:-5}"
  echo "🔄 Listing ${limit} most recent workflow runs..."
  echo ""
  gh run list --limit "${limit}"
}

# Watch a specific workflow run
watch_run() {
  local run_id="$1"
  echo "👀 Watching workflow run ${run_id}..."
  echo ""
  gh run watch "${run_id}"
}

# Interactive mode - select a run to watch
interactive_watch() {
  echo "🔄 Fetching recent workflow runs..."
  echo ""
  
  # Get the run ID from user selection
  local run_id
  run_id=$(gh run list --limit 10 --json databaseId,displayTitle,status,conclusion,startedAt \
    --jq '.[] | "\(.databaseId)\t\(.displayTitle)\t\(.status)\t\(.conclusion // "N/A")\t\(.startedAt)"' | \
    fzf --header="Select a workflow run to watch:" --delimiter='\t' --with-nth=2,3,4,5 | \
    cut -f1)
  
  if [[ -n "${run_id}" ]]; then
    watch_run "${run_id}"
  else
    echo "❌ No run selected."
    exit 1
  fi
}

# Display help
usage() {
  cat <<'USAGE'
GitHub PR and Workflow Run Monitor

Usage:
  scripts/monitor_prs_and_runs.sh prs                    # Show open pull requests
  scripts/monitor_prs_and_runs.sh runs [limit]           # List recent workflow runs (default: 5)
  scripts/monitor_prs_and_runs.sh watch <run-id>         # Watch a specific workflow run
  scripts/monitor_prs_and_runs.sh interactive            # Interactively select and watch a run (requires fzf)
  scripts/monitor_prs_and_runs.sh all                    # Show PRs and recent runs

Examples:
  scripts/monitor_prs_and_runs.sh prs
  scripts/monitor_prs_and_runs.sh runs 10
  scripts/monitor_prs_and_runs.sh watch 1234567890
  scripts/monitor_prs_and_runs.sh interactive

Requirements:
  - GitHub CLI (gh) must be installed and authenticated
  - Optional: fzf for interactive mode

USAGE
}

# -------- Entry Point ---------------------------------------------------------

case "${1:-all}" in
  prs)
    show_open_prs
    ;;
  runs)
    list_recent_runs "${2:-5}"
    ;;
  watch)
    shift
    [[ $# -ge 1 ]] || { echo "❌ Error: run-id required"; usage; exit 2; }
    watch_run "$1"
    ;;
  interactive)
    interactive_watch
    ;;
  all)
    show_open_prs
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    list_recent_runs 5
    ;;
  -h|--help)
    usage
    ;;
  *)
    echo "❌ Unknown command: $1"
    usage
    exit 2
    ;;
esac
