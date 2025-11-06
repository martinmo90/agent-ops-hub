#!/bin/bash
# resolve_pr17_conflicts.sh
# Script to resolve merge conflicts in PR #17 (cursor/pr-template-20251104)

set -e

BRANCH="cursor/pr-template-20251104"
TARGET="main"

echo "🔧 Resolving conflicts for PR #17..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Fetch latest changes
echo "📥 Fetching latest changes..."
git fetch origin

# Checkout the cursor branch
echo "🌿 Checking out $BRANCH..."
git checkout "$BRANCH"

# Attempt to merge main
echo "🔀 Merging $TARGET with --allow-unrelated-histories..."
if git merge "$TARGET" --allow-unrelated-histories --no-edit; then
    echo "✅ Merge completed without conflicts"
else
    echo "⚠️  Conflicts detected, resolving..."
    
    # Resolve conflicts by accepting main's versions
    echo "📝 Accepting $TARGET's versions for conflicting files..."
    git checkout --theirs .github/pull_request_template.md
    git checkout --theirs .github/workflows/auto-merge-on-label.yml 2>/dev/null || true
    git checkout --theirs .github/workflows/auto-open-pr-on-push.yml 2>/dev/null || true
    git checkout --theirs .github/workflows/baseline-guard.yml 2>/dev/null || true
    git checkout --theirs .github/workflows/merge-on-green.yml 2>/dev/null || true
    git checkout --theirs README.md 2>/dev/null || true
    git checkout --theirs scripts/auto_merge_claude.sh 2>/dev/null || true
    
    # Stage all changes
    git add .
    
    # Commit the resolution
    echo "💾 Committing resolution..."
    git commit -m "chore: resolve merge conflicts with main branch

Resolved conflicts by accepting main branch's versions for:
- .github/pull_request_template.md (primary conflict)
- .github/workflows/*.yml files
- README.md
- scripts/auto_merge_claude.sh

This aligns the cursor branch with the current project state and
allows PR #17 to proceed to review.

Evidence: Merge commit resolving unrelated histories issue"
fi

echo "✅ Conflicts resolved successfully!"
echo "📤 To push: git push origin $BRANCH"
echo ""
echo "Note: You may need to force push if there are divergent histories:"
echo "git push origin $BRANCH --force-with-lease"
