#!/bin/bash

# Script to sync the OpenRouter fork with upstream LibreChat
# while preserving the custom OpenRouter implementation

echo "🔄 Starting upstream sync process..."

# 1. Ensure we're on the correct branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "feat-open-router-integration" ]; then
    echo "⚠️  Not on feat-open-router-integration branch. Current branch: $CURRENT_BRANCH"
    echo "Run: git checkout feat-open-router-integration"
    exit 1
fi

# 2. Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi

# 3. Fetch latest upstream
echo "📥 Fetching latest upstream changes..."
git fetch upstream main

# 4. Start merge
echo "🔀 Starting merge with upstream/main..."
git merge upstream/main --no-edit || {
    echo "⚠️  Merge conflicts detected. Resolving..."

    # Check if api/package.json has conflicts
    if grep -q "<<<<<<< HEAD" api/package.json 2>/dev/null; then
        echo "📦 Resolving api/package.json conflicts..."

        # Backup current file
        cp api/package.json api/package.json.backup

        # Remove conflict markers and keep our @librechat/agents line
        sed -i '' '/^<<<<<<< HEAD$/d' api/package.json
        sed -i '' '/^=======$/d' api/package.json
        sed -i '' '/^>>>>>>> upstream\/main$/d' api/package.json

        # Remove the upstream's @librechat/agents line (the npm version)
        sed -i '' '/"@librechat\/agents": "\^[0-9]/d' api/package.json

        echo "✅ Kept your custom @librechat/agents fork reference"
        git add api/package.json
    fi

    # Regenerate package-lock.json
    if grep -q "<<<<<<< HEAD" package-lock.json 2>/dev/null; then
        echo "🔒 Regenerating package-lock.json..."
        rm package-lock.json
        npm install --package-lock-only
        git add package-lock.json
    fi

    # Check if all conflicts are resolved
    if git diff --check 2>&1 | grep -q "conflict"; then
        echo "❌ Some conflicts remain unresolved. Please fix manually:"
        git diff --check
        exit 1
    else
        echo "✅ All conflicts resolved. Completing merge..."
        git commit --no-edit
    fi
}

echo "✨ Sync complete! Your OpenRouter changes are preserved."
echo ""
echo "📋 Summary:"
echo "  - Current branch: $(git branch --show-current)"
echo "  - Latest commit: $(git log --oneline -1)"
echo "  - @librechat/agents: $(grep '@librechat/agents' api/package.json | head -1)"
echo ""
echo "🔍 Recommended next steps:"
echo "  1. Run tests: npm test"
echo "  2. Build the project: npm run build"
echo "  3. Test OpenRouter functionality manually"