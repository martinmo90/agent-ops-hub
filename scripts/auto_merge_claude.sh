#!/usr/bin/env bash
set -euo pipefail

# -------- CONFIG (adjust only if you need to) ---------------------------------
OWNER="martinmo90"
REPO="agent-ops-hub"
BRANCH_PREFIX="claude/"                 # only auto-merge PRs from these heads
REQUIRED_CHECKS=("Baseline Guard / verify")  # must be green
MERGE_METHOD="squash"                   # squash | merge | rebase
DELETE_HEAD_AFTER_MERGE="true"          # delete merged head branch
DRY_RUN="${DRY_RUN:-false}"             # set DRY_RUN=true to simulate

# Token search order; paste your Classic PAT into any of these env vars:
TOKEN="${CLAUDE_GH_TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"

# -------- Helpers --------------------------------------------------------------
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing $1. Please install it."; exit 2; }; }
need curl; need jq

if [[ -z "${TOKEN}" ]]; then
  echo "❌ No GitHub token found. Export CLAUDE_GH_TOKEN (or GITHUB_TOKEN / GH_TOKEN)."
  exit 2
fi

API="https://api.github.com"
AUTH_H=(-H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json")

get_json()  { curl -fsSL "${AUTH_H[@]}" "$1"; }
post_json() { curl -fsSL -X POST "${AUTH_H[@]}" -H "Content-Type: application/json" -d "$2" "$1"; }
put_json()  { curl -fsSL -X PUT  "${AUTH_H[@]}" -H "Content-Type: application/json" -d "$2" "$1"; }
del()       { curl -fsSL -X DELETE "${AUTH_H[@]}" "$1"; }

enc_ref() { local s="$1"; echo "${s//\//%2F}"; }

# --- GraphQL (for unresolved review threads) ---
graphql() {
  local q="$1" v="$2"
  curl -fsSL -H "Authorization: bearer ${TOKEN}" -H "Content-Type: application/json" \
    -X POST https://api.github.com/graphql \
    -d "$(jq -n --arg q "$q" --argjson v "$v" '{query:$q, variables:$v}')"
}

# Check required checks for a commit SHA
check_required_checks() {
  local sha="$1"; local ok="true"

  # /check-runs (Checks API)
  local runs; runs=$(get_json "${API}/repos/${OWNER}/${REPO}/commits/${sha}/check-runs")
  for name in "${REQUIRED_CHECKS[@]}"; do
    local match; match=$(echo "${runs}" | jq -r --arg n "$name" '
      .check_runs[]? | select(.name==$n) | {status, conclusion} | @base64' || true)
    if [[ -z "${match}" ]]; then
      echo "❌ Required check missing: ${name}"
      ok="false"
      continue
    fi
    local status conclusion
    status=$(echo "${runs}" | jq -r --arg n "$name" '.check_runs[]? | select(.name==$n) | .status')
    conclusion=$(echo "${runs}" | jq -r --arg n "$name" '.check_runs[]? | select(.name==$n) | .conclusion')
    if [[ "${status}" != "completed" || "${conclusion}" != "success" ]]; then
      echo "❌ Check not green: ${name} (status=${status}, conclusion=${conclusion})"
      ok="false"
    else
      echo "✅ Check passed: ${name}"
    fi
  done

  [[ "${ok}" == "true" ]]
}

# Count unresolved review threads (conversation resolution rule)
count_unresolved_threads() {
  local number="$1"
  local q='query($o:String!,$r:String!,$n:Int!){
    repository(owner:$o, name:$r){
      pullRequest(number:$n){
        reviewThreads(first:100){ nodes{ isResolved } }
      }
    }
  }'
  local vars; vars=$(jq -n --arg o "$OWNER" --arg r "$REPO" --argjson n "$number" '{o:$o,r:$r,n:$n}')
  local out; out=$(graphql "$q" "$vars")
  echo "$out" | jq '[.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved==false)] | length'
}

# Attempt merge
merge_pr() {
  local number="$1" title="$2" head="$3"
  echo "🟨 Attempting ${MERGE_METHOD} merge: #${number} — ${title}"

  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "DRY_RUN: would merge PR #${number}"
    return 0
  fi

  local body; body=$(jq -n --arg m "$MERGE_METHOD" --arg t "$title" '{merge_method:$m, commit_title:$t}')
  local resp; set +e
  resp=$(put_json "${API}/repos/${OWNER}/${REPO}/pulls/${number}/merge" "${body}") ; rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    echo "❌ Merge API error."
    echo "$resp" | jq -r '.message // .'
    return 1
  fi
  local merged; merged=$(echo "$resp" | jq -r '.merged')
  if [[ "${merged}" == "true" ]]; then
    echo "✅ Merged PR #${number}"
    if [[ "${DELETE_HEAD_AFTER_MERGE}" == "true" && -n "${head}" ]]; then
      local enc; enc=$(enc_ref "${head}")
      set +e
      del "${API}/repos/${OWNER}/${REPO}/git/refs/heads/${enc}" >/dev/null 2>&1
      if [[ $? -eq 0 ]]; then
        echo "🧹 Deleted branch ${head}"
      else
        echo "ℹ️ Could not delete branch ${head} (maybe already deleted or protected)."
      fi
      set -e
    fi
    return 0
  else
    echo "❌ Merge failed: $(echo "$resp" | jq -r '.message')"
    return 1
  fi
}

# Process a single PR by number
process_pr() {
  local number="$1"
  local pr; pr=$(get_json "${API}/repos/${OWNER}/${REPO}/pulls/${number}")
  local head_ref head_sha title state draft base_ref mergeable_state
  head_ref=$(echo "$pr" | jq -r '.head.ref')
  head_sha=$(echo "$pr" | jq -r '.head.sha')
  title=$(echo "$pr" | jq -r '.title')
  state=$(echo "$pr" | jq -r '.state')
  draft=$(echo "$pr" | jq -r '.draft')
  base_ref=$(echo "$pr" | jq -r '.base.ref')
  mergeable_state=$(echo "$pr" | jq -r '.mergeable_state // "unknown"')

  echo "— PR #${number} [${state}] ${head_ref} → ${base_ref}  (mergeable_state=${mergeable_state}, draft=${draft})"

  # Only process heads from our prefix
  if [[ "${head_ref}" != ${BRANCH_PREFIX}* ]]; then
    echo "  ⏭️  Skip: head '${head_ref}' does not match '${BRANCH_PREFIX}*'"
    return 0
  fi

  # Block on unresolved threads
  local unresolved; unresolved=$(count_unresolved_threads "${number}")
  if [[ "${unresolved}" != "0" ]]; then
    echo "  ❌ Blocked: ${unresolved} unresolved review thread(s). Resolve conversations first."
    return 1
  else
    echo "  ✅ No unresolved review threads."
  fi

  # Required checks
  if ! check_required_checks "${head_sha}"; then
    echo "  ❌ Blocked: required checks not green."
    return 1
  fi

  # Merge attempt
  merge_pr "${number}" "${title}" "${head_ref}"
}

# Auto discover open PRs (optionally filter by one head)
discover_and_process() {
  local head_filter="${1:-}"
  local prs; prs=$(get_json "${API}/repos/${OWNER}/${REPO}/pulls?state=open&per_page=100")
  local count; count=$(echo "$prs" | jq 'length')
  if [[ "$count" -eq 0 ]]; then
    echo "ℹ️  No open PRs."
    return 0
  fi

  # Build list of PR numbers to process
  local numbers=()
  while IFS= read -r n; do numbers+=("$n"); done < <(
    echo "$prs" | jq -r --arg p "$BRANCH_PREFIX" --arg hf "$head_filter" '
      .[] | select(.head.ref | startswith($p)) |
      select($hf=="" or .head.ref==$hf) |
      .number'
  )

  if [[ "${#numbers[@]}" -eq 0 ]]; then
    echo "ℹ️  No matching PRs for prefix '${BRANCH_PREFIX}'${head_filter:+ and head='$head_filter'}."
    return 0
  fi

  for n in "${numbers[@]}"; do
    process_pr "$n" || true
  done
}

usage() {
  cat <<'USAGE'
Usage:
  scripts/auto_merge_claude.sh               # process all open PRs from heads starting with claude/
  scripts/auto_merge_claude.sh --pr 9        # process a specific PR number
  scripts/auto_merge_claude.sh --head claude/your-branch   # process a specific head branch

Env:
  CLAUDE_GH_TOKEN / GITHUB_TOKEN / GH_TOKEN  (required)
  DRY_RUN=true   (simulate only)

USAGE
}

# -------- Entry ---------------------------------------------------------------
mkdir -p scripts >/dev/null 2>&1 || true

case "${1:-}" in
  --pr)
    shift; [[ $# -ge 1 ]] || { usage; exit 2; }
    process_pr "$1"
    ;;
  --head)
    shift; [[ $# -ge 1 ]] || { usage; exit 2; }
    discover_and_process "$1"
    ;;
  -h|--help)
    usage
    ;;
  *)
    discover_and_process ""
    ;;
esac
