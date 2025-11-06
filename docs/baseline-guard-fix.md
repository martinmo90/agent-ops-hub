# Baseline Guard Timeout Fix

## Problem Statement

Multiple PR merge requests were failing to start due to the "Baseline Guard / verifyExpected" workflow appearing to be stuck in a "waiting for status to be reported" state. The workflow would keep running indefinitely, preventing PRs from being merged.

## Root Cause Analysis

The issue was caused by **missing timeout configurations** in the GitHub Actions workflows:

1. **No job-level timeout**: The `baseline-guard.yml` workflow (and other critical workflows) did not have a `timeout-minutes` configuration at the job level. This meant that if something went wrong, the workflow could run for up to the default GitHub Actions timeout of 360 minutes (6 hours).

2. **No step-level timeout**: Individual steps also lacked timeout configurations, which could cause them to hang indefinitely if there was an issue with the script execution.

3. **Insufficient error handling**: The baseline verification script lacked proper error handling for edge cases like jq parsing failures or empty baseline file lists.

4. **Cascading effect**: The `auto_merge_claude.sh` script and other auto-merge workflows depend on the "Baseline Guard / verifyExpected" check to complete successfully. If that check hangs, the entire merge pipeline is blocked.

## Solution Implemented

### 1. Added Timeout Configurations

Added `timeout-minutes` to all critical workflows:

- **baseline-guard.yml**: 5 minutes job timeout, 3 minutes step timeout
- **auto-merge-on-label.yml**: 10 minutes (accounts for polling with 20 retries × 15 seconds)
- **merge-on-green.yml**: 5 minutes
- **auto-merge-doctor.yml**: 10 minutes
- **list-open-prs-merge-readiness.yml**: 10 minutes

### 2. Improved Error Handling in Baseline Guard

Enhanced the baseline verification script with:

- **Set strict mode**: Added `set -euo pipefail` to catch errors early
- **JQ error handling**: Added explicit error handling for `jq` parsing failures
- **Empty list handling**: Added proper handling when no baseline files are found
- **File count tracking**: Added counting to report exactly how many files were verified
- **Better logging**: Improved output messages to show progress and final count

### 3. Benefits

- **Prevents indefinite hanging**: Workflows will now timeout after a reasonable period instead of running for hours
- **Faster failure detection**: Issues are detected and reported within minutes instead of hours
- **Clear error messages**: Better logging helps diagnose issues when they occur
- **Unblocked merge pipeline**: Timeouts ensure that even failed checks don't block the entire pipeline indefinitely

## Testing

The fix was tested locally by:

1. Running the updated baseline-guard script against the current `manifest.json`
2. Verifying all 9 baseline files are correctly detected and validated
3. Testing error handling by simulating missing files
4. Confirming proper exit codes and error messages

## Impact

- PRs will no longer get stuck waiting indefinitely for the Baseline Guard check
- Failed checks will timeout and report failure clearly
- Auto-merge workflows can proceed once checks complete (success or timeout)
- Overall PR merge pipeline reliability is significantly improved

## Future Improvements

Consider adding:

1. Monitoring/alerting for workflow timeout occurrences
2. Retry logic for transient failures
3. More granular timeout configurations based on workflow complexity
4. Health checks for dependent services before starting workflows
