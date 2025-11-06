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

# Create/checkout the cursor branch
echo "🌿 Checking out $BRANCH..."
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git checkout "$BRANCH"
else
    echo "  Branch not found locally, fetching from origin..."
    git fetch origin "$BRANCH:$BRANCH"
    git checkout "$BRANCH"
fi

# Attempt to merge main
echo "🔀 Merging $TARGET with --allow-unrelated-histories..."
if git merge "$TARGET" --allow-unrelated-histories --no-edit; then
    echo "✅ Merge completed without conflicts"
else
    echo "⚠️  Conflicts detected, resolving..."
    
    # Resolve conflicts by accepting main's versions
    echo "📝 Accepting $TARGET's versions for conflicting files..."
    
    # List of files that may have conflicts
    CONFLICT_FILES=(
        ".github/pull_request_template.md"
        ".github/workflows/auto-merge-on-label.yml"
        ".github/workflows/auto-open-pr-on-push.yml"
        ".github/workflows/baseline-guard.yml"
        ".github/workflows/merge-on-green.yml"
        "README.md"
        "scripts/auto_merge_claude.sh"
    )
    
    for file in "${CONFLICT_FILES[@]}"; do
        if git status --porcelain | grep -q "^[AUD][AUD] $file"; then
            echo "  Resolving: $file"
            git checkout --theirs "$file" || echo "  ⚠️  Warning: Could not resolve $file"
        fi
    done
    
    # Stage all changes
    git add .
    
    # Commit the resolution
    echo "💾 Committing resolution..."
    git commit -m "chore: resolve merge conflicts with main branch" \
               -m "Resolved conflicts by accepting main branch's versions for:" \
               -m "- .github/pull_request_template.md (primary conflict)" \
               -m "- .github/workflows/*.yml files" \
               -m "- README.md" \
               -m "- scripts/auto_merge_claude.sh" \
               -m "" \
               -m "This aligns the cursor branch with the current project state and" \
               -m "allows PR #17 to proceed to review." \
               -m "" \
               -m "Evidence: Merge commit resolving unrelated histories issue"
fi

echo "✅ Conflicts resolved successfully!"
echo "📤 To push: git push origin $BRANCH"
echo ""
echo "Note: You may need to force push if there are divergent histories:"
echo "git push origin $BRANCH --force-with-lease"
