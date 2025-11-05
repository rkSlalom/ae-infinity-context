#!/usr/bin/env bash
# Master setup script for OpenSpec across all AE Infinity repositories
# Platform: Cross-platform (Linux, macOS, Windows with Git Bash)
#
# Usage:
#   ./setup-openspec-all.sh
#
# This script must be run from the ae-infinity parent directory containing:
#   - ae-infinity-context/
#   - ae-infinity-api/
#   - ae-infinity-ui/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up OpenSpec across all AE Infinity repositories..."
echo ""
echo "This will configure OpenSpec in:"
echo "  - ae-infinity-context (hub)"
echo "  - ae-infinity-api (spoke)"
echo "  - ae-infinity-ui (spoke)"
echo "  - Root directory (slash commands)"
echo ""

# Check if we're in the right directory
if [ ! -d "ae-infinity-context" ] || [ ! -d "ae-infinity-api" ] || [ ! -d "ae-infinity-ui" ]; then
    echo "❌ Error: Must run from the ae-infinity parent directory"
    echo "   Expected structure:"
    echo "   ae-infinity/"
    echo "   ├── ae-infinity-context/"
    echo "   ├── ae-infinity-api/"
    echo "   └── ae-infinity-ui/"
    exit 1
fi

echo "✅ Directory structure validated"
echo ""

# Setup context repo (hub)
echo "📦 1/3: Setting up context repo..."
cd ae-infinity-context

if [ ! -f "openspec/specs/README.md" ]; then
    echo "   Creating specs directory structure..."
    mkdir -p openspec/specs
    # README should already be created
fi

echo "   ✅ Context repo ready (specs hub)"
cd ..
echo ""

# Setup API repo (spoke)
echo "📦 2/3: Setting up API repo..."
cd ae-infinity-api

if [ ! -f "setup-openspec.sh" ]; then
    echo "   ❌ Error: setup-openspec.sh not found in ae-infinity-api/"
    exit 1
fi

chmod +x setup-openspec.sh
./setup-openspec.sh

cd ..
echo ""

# Setup UI repo (spoke)
echo "📦 3/3: Setting up UI repo..."
cd ae-infinity-ui

if [ ! -f "setup-openspec.sh" ]; then
    echo "   ❌ Error: setup-openspec.sh not found in ae-infinity-ui/"
    exit 1
fi

chmod +x setup-openspec.sh
./setup-openspec.sh

cd ..
echo ""

# Setup root directory slash commands
echo "📦 4/4: Setting up root directory..."
mkdir -p .cursor/commands

if [ -d "ae-infinity-context/.cursor/commands" ]; then
    cp ae-infinity-context/.cursor/commands/openspec-*.md .cursor/commands/
    echo "   ✅ Copied OpenSpec slash commands to root directory"
else
    echo "   ⚠️  Context repo commands not found, skipping root setup"
fi

cd ..
echo ""

# Verify setup
echo "🔍 Verifying setup..."
echo ""

echo "Context repo:"
ls -la ae-infinity-context/openspec/ | grep -E "(project.md|AGENTS.md|specs)"

echo ""
echo "API repo:"
ls -la ae-infinity-api/openspec/ | grep -E "(project.md|AGENTS.md|specs|changes)"

echo ""
echo "UI repo:"
ls -la ae-infinity-ui/openspec/ | grep -E "(project.md|AGENTS.md|specs|changes)"

echo ""
echo "Root directory:"
ls -la .cursor/commands/ | grep "openspec"

echo ""
echo "✅ OpenSpec cross-repository setup complete!"
echo ""
echo "📚 Next steps:"
echo ""
echo "1. Read the setup guide:"
echo "   cat ae-infinity-context/openspec/CROSS_REPO_SETUP.md"
echo ""
echo "2. Test OpenSpec CLI in each repo:"
echo "   cd ae-infinity-context && openspec list --specs"
echo "   cd ae-infinity-api && openspec list --specs"
echo "   cd ae-infinity-ui && openspec list --specs"
echo ""
echo "3. Create your first spec:"
echo "   cd ae-infinity-context"
echo "   mkdir -p openspec/changes/add-first-capability"
echo "   # Follow examples in openspec/specs/README.md"
echo ""
echo "📖 Documentation:"
echo "   - Full setup guide: ae-infinity-context/openspec/CROSS_REPO_SETUP.md"
echo "   - Spec creation: ae-infinity-context/openspec/specs/README.md"
echo "   - AI instructions: ae-infinity-context/openspec/AGENTS.md"
echo ""

