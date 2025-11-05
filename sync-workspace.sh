#!/usr/bin/env bash
# Workspace Synchronization Script
# Purpose: Check status of all repos and identify what needs syncing
# Platform: Cross-platform (Linux, macOS, Windows with Git Bash)
#
# Usage:
#   ./sync-workspace.sh
#
# Environment Variables:
#   WORKSPACE_ROOT - Override workspace location (default: parent of script dir)
#   NO_COLOR       - Disable colored output
#   REPOS          - Space-separated list of repo names to check
#                    (default: ae-infinity-context ae-infinity-api ae-infinity-ui)
#
# The script automatically detects the workspace based on its location.
# Place this script in a subdirectory of your workspace for auto-detection.
#
# Examples:
#   ./sync-workspace.sh                    # Use default repos
#   REPOS="repo1 repo2" ./sync-workspace.sh # Check specific repos
#   WORKSPACE_ROOT=/path/to/workspace ./sync-workspace.sh # Override location

set -e

# Auto-detect workspace root (parent directory of this script's location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="${WORKSPACE_ROOT:-$(dirname "$SCRIPT_DIR")}"

# Verify workspace exists
if [ ! -d "$WORKSPACE" ]; then
    echo "Error: Workspace directory not found at: $WORKSPACE"
    echo "Set WORKSPACE_ROOT environment variable to override"
    exit 1
fi

echo "Using workspace: $WORKSPACE"
echo ""

# Colors (disable if NO_COLOR is set or not in a terminal)
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Repository list (can be overridden via REPOS environment variable)
DEFAULT_REPOS="ae-infinity-context ae-infinity-api ae-infinity-ui"
IFS=' ' read -ra REPOS_ARRAY <<< "${REPOS:-$DEFAULT_REPOS}"

echo -e "${BLUE}🔄 Starting Workspace Synchronization Check${NC}"
echo ""

# Function to check repo status
check_repo() {
    local repo=$1
    local dir="$WORKSPACE/$repo"
    
    if [ ! -d "$dir" ]; then
        echo -e "${RED}❌ $repo: Not found${NC}"
        return 1
    fi
    
    # Check if it's a git repository
    if [ ! -d "$dir/.git" ]; then
        echo -e "${RED}❌ $repo: Not a git repository${NC}"
        return 1
    fi
    
    # Use subshell to avoid changing current directory
    (
        cd "$dir" || return 1
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        
        echo -e "${BLUE}📁 $repo${NC}"
        echo "   Branch: $branch"
        
        # Check for uncommitted changes
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo -e "   ${YELLOW}⚠️  Uncommitted changes:${NC}"
            git status --short 2>/dev/null | sed 's/^/      /' || echo "      (error reading status)"
        else
            echo -e "   ${GREEN}✅ Clean working directory${NC}"
        fi
        
        # Check for unpushed commits (requires network, may fail if no upstream)
        local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
        if [ "$ahead" != "0" ]; then
            echo -e "   ${YELLOW}⚠️  $ahead unpushed commit(s)${NC}"
            git log @{u}..HEAD --oneline 2>/dev/null | head -5 | sed 's/^/      /' || true
        fi
        
        echo ""
    )
    
    return 0
}

# Check all repos
for repo in "${REPOS_ARRAY[@]}"; do
    check_repo "$repo"
done

echo -e "${GREEN}✅ Synchronization check complete!${NC}"
echo ""

# Summary
echo "📋 Branch Summary:"
for repo in "${REPOS_ARRAY[@]}"; do
    repo_dir="$WORKSPACE/$repo"
    if [ -d "$repo_dir/.git" ]; then
        (
            cd "$repo_dir" || exit 0
            branch=$(git branch --show-current 2>/dev/null || echo "unknown")
            printf "   %-25s → %s\n" "$repo" "$branch"
        )
    else
        printf "   %-25s → %s\n" "$repo" "(not found or not a git repo)"
    fi
done

echo ""
echo "💡 Next steps:"
echo "   • Commit any uncommitted changes"
echo "   • Push branches: git push origin <branch-name>"
echo "   • Create PRs if ready for review"

