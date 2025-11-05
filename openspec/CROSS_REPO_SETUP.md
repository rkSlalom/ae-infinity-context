# Cross-Repository OpenSpec Setup

This document describes how OpenSpec is configured across the three AE Infinity repositories for extensible spec-driven development.

## Repository Structure

The project consists of three repositories with a hub-and-spoke OpenSpec configuration:

```
ae-infinity/
├── ae-infinity-context/     # Hub: Authoritative specs
│   └── openspec/
│       ├── project.md       # Shared project context (master)
│       ├── AGENTS.md        # Shared AI instructions (master)
│       ├── specs/           # All capability specs (authoritative)
│       └── changes/         # Cross-cutting changes
│
├── ae-infinity-api/         # Spoke: Backend implementation
│   └── openspec/
│       ├── project.md       # Symlink → context/openspec/project.md
│       ├── AGENTS.md        # Symlink → context/openspec/AGENTS.md
│       ├── specs/           # Symlink → context/openspec/specs/
│       └── changes/         # Backend-specific changes only
│
└── ae-infinity-ui/          # Spoke: Frontend implementation
    └── openspec/
        ├── project.md       # Symlink → context/openspec/project.md
        ├── AGENTS.md        # Symlink → context/openspec/AGENTS.md
        ├── specs/           # Symlink → context/openspec/specs/
        └── changes/         # Frontend-specific changes only
```

## Design Principles

### 1. Single Source of Truth
- **Context repo** is the authoritative source for:
  - Project-wide context (`project.md`)
  - All capability specifications (`specs/`)
  - Cross-cutting changes affecting multiple repos
  - AI agent instructions (`AGENTS.md`)

### 2. Local Implementation Changes
- **API/UI repos** manage their own:
  - Implementation-specific changes (`changes/`)
  - Changes that only affect that specific codebase
  - No duplicate specs - read from context via symlinks

### 3. Shared Configuration
- All repos use the same `project.md` for consistency
- All repos use the same `AGENTS.md` for AI instructions
- Changes reference shared specs for validation

## Quick Setup

### Automated Setup (Recommended)

Run the master setup script from the parent directory:

```bash
cd ae-infinity  # Parent directory containing all three repos
chmod +x scripts/setup-openspec-all.sh
./scripts/setup-openspec-all.sh
```

This will configure OpenSpec in all three repositories with proper symlinks and directory structure.

### Manual Setup (Advanced)

If you prefer manual setup or need to configure individual repositories:

## Setup Instructions

### Step 1: Initialize OpenSpec in API Repo

```bash
cd ae-infinity-api
chmod +x setup-openspec.sh
./setup-openspec.sh
```

Or manually:

```bash
cd ae-infinity-api
mkdir -p openspec/changes

# Create symlinks to shared files
ln -s ../../ae-infinity-context/openspec/project.md openspec/project.md
ln -s ../../ae-infinity-context/openspec/AGENTS.md openspec/AGENTS.md
ln -s ../../ae-infinity-context/openspec/specs openspec/specs

# Add to .gitignore to prevent committing symlinks
echo "" >> .gitignore
echo "# OpenSpec symlinks (point to context repo)" >> .gitignore
echo "openspec/project.md" >> .gitignore
echo "openspec/AGENTS.md" >> .gitignore
echo "openspec/specs" >> .gitignore

# Configure git
git config --local openspec.context-repo "../ae-infinity-context"
```

### Step 2: Initialize OpenSpec in UI Repo

```bash
cd ae-infinity-ui
chmod +x setup-openspec.sh
./setup-openspec.sh
```

Or manually:

```bash
cd ae-infinity-ui
mkdir -p openspec/changes

# Create symlinks to shared files
ln -s ../../ae-infinity-context/openspec/project.md openspec/project.md
ln -s ../../ae-infinity-context/openspec/AGENTS.md openspec/AGENTS.md
ln -s ../../ae-infinity-context/openspec/specs openspec/specs

# Add to .gitignore
echo "" >> .gitignore
echo "# OpenSpec symlinks (point to context repo)" >> .gitignore
echo "openspec/project.md" >> .gitignore
echo "openspec/AGENTS.md" >> .gitignore
echo "openspec/specs" >> .gitignore

# Configure git
git config --local openspec.context-repo "../ae-infinity-context"
```

### Step 3: Verify Context Repo Structure

```bash
cd ae-infinity-context/openspec

# Verify specs directory exists with README
ls -la specs/

# Should contain README.md with guidance
cat specs/README.md
```

### Step 4: Verify Setup

```bash
# From parent directory
cd ae-infinity

# Check API repo
ls -la ae-infinity-api/openspec/
# Should show symlinks: project.md -> ../../ae-infinity-context/openspec/project.md

# Check UI repo
ls -la ae-infinity-ui/openspec/
# Should show symlinks: AGENTS.md -> ../../ae-infinity-context/openspec/AGENTS.md

# Test OpenSpec CLI (if installed)
cd ae-infinity-api && openspec list --specs
cd ae-infinity-ui && openspec list --specs
```

## Usage Patterns

### Creating Cross-Cutting Changes

**When**: Change affects API contract, data models, or both frontend and backend

**Where**: `ae-infinity-context/openspec/changes/`

**Example**: Adding authentication to all endpoints
```bash
cd ae-infinity-context
mkdir -p openspec/changes/add-authentication
# Create proposal.md, tasks.md, spec deltas
openspec validate add-authentication --strict
```

### Creating Backend-Specific Changes

**When**: Change only affects backend implementation (no API contract change)

**Where**: `ae-infinity-api/openspec/changes/`

**Example**: Refactoring database queries
```bash
cd ae-infinity-api
mkdir -p openspec/changes/refactor-query-performance
# Create proposal.md, tasks.md (no spec deltas needed)
```

### Creating Frontend-Specific Changes

**When**: Change only affects UI/UX (no API contract change)

**Where**: `ae-infinity-ui/openspec/changes/`

**Example**: Redesigning list view component
```bash
cd ae-infinity-ui
mkdir -p openspec/changes/redesign-list-view
# Create proposal.md, tasks.md, design.md
```

## OpenSpec CLI Usage Across Repos

### From Context Repo (Hub)
```bash
cd ae-infinity-context

# List all specs (authoritative)
openspec list --specs

# Validate a cross-cutting change
openspec validate add-authentication --strict

# Archive a completed change
openspec archive add-authentication --yes
```

### From API Repo (Spoke)
```bash
cd ae-infinity-api

# List specs (reads from context via symlink)
openspec list --specs

# List local backend changes
openspec list

# Validate a backend-specific change
openspec validate refactor-query-performance --strict

# Archive a completed backend change
openspec archive refactor-query-performance --skip-specs --yes
```

### From UI Repo (Spoke)
```bash
cd ae-infinity-ui

# List specs (reads from context via symlink)
openspec list --specs

# List local frontend changes
openspec list

# Validate a frontend-specific change
openspec validate redesign-list-view --strict

# Archive a completed frontend change
openspec archive redesign-list-view --skip-specs --yes
```

## Change Type Decision Matrix

| Change Type | Affects | Location | Has Spec Deltas? |
|-------------|---------|----------|------------------|
| **New Feature** | API + UI | context/changes/ | ✅ Yes |
| **API Contract Change** | API + UI | context/changes/ | ✅ Yes |
| **Data Model Change** | API + specs | context/changes/ | ✅ Yes |
| **Architecture Change** | Multiple | context/changes/ | ✅ Yes |
| **Backend Refactoring** | API only | api/changes/ | ❌ No |
| **UI/UX Redesign** | UI only | ui/changes/ | ❌ No (unless changes API usage) |
| **Performance Optimization** | One repo | respective repo | ⚠️ Depends (if changes behavior) |
| **Bug Fix** | Any | respective repo | ❌ Usually no proposal needed |

## Git Workflow

### Cross-Cutting Feature
1. Create change in `context/changes/`
2. Commit to context repo
3. Implement in API repo (reference context change ID)
4. Implement in UI repo (reference context change ID)
5. After deployment, archive change in context repo (updates specs)
6. Sync context repo changes to API/UI repos

### Repo-Specific Feature
1. Create change in respective repo's `changes/`
2. Implement in same repo
3. After deployment, archive with `--skip-specs` flag
4. No spec updates needed

## AI Assistant Integration

When working with AI assistants (Cursor, GitHub Copilot, etc.):

**Context Repo:**
```
Always load:
- openspec/project.md (full project context)
- openspec/AGENTS.md (AI instructions)
- relevant specs from specs/
```

**API Repo:**
```
Load via symlinks:
- openspec/project.md (shared context)
- openspec/AGENTS.md (shared instructions)
- openspec/specs/[capability]/ (relevant specs)

Plus:
- API-specific docs from docs/
- Current backend changes from openspec/changes/
```

**UI Repo:**
```
Load via symlinks:
- openspec/project.md (shared context)
- openspec/AGENTS.md (shared instructions)
- openspec/specs/[capability]/ (relevant specs)

Plus:
- UI-specific docs from docs/
- Current frontend changes from openspec/changes/
```

## Maintenance

### Syncing Symlinks
If symlinks break (e.g., after cloning):

```bash
# From api or ui repo
cd openspec
ln -sf ../../ae-infinity-context/openspec/project.md project.md
ln -sf ../../ae-infinity-context/openspec/AGENTS.md AGENTS.md
ln -sf ../../ae-infinity-context/openspec/specs specs
```

### Updating Shared Files
Always update in context repo:

```bash
cd ae-infinity-context/openspec
# Edit project.md or AGENTS.md
git add project.md
git commit -m "docs(openspec): update project context"
git push

# Changes automatically visible in API/UI repos via symlinks
```

### Cleaning Up Archived Changes
Periodically clean up old archived changes:

```bash
# Context repo
cd ae-infinity-context/openspec/changes/archive
# Review and remove very old archives if needed

# API/UI repos
cd ae-infinity-api/openspec/changes/archive
cd ae-infinity-ui/openspec/changes/archive
# Clean up implementation-specific archives
```

## Benefits of This Approach

✅ **Single Source of Truth**: All specs in one place (context repo)
✅ **No Duplication**: Symlinks prevent drift between repos
✅ **Local Autonomy**: Each repo manages implementation changes
✅ **Consistent Context**: All repos see same project.md and AGENTS.md
✅ **OpenSpec CLI Works**: Commands work in all three repos
✅ **Git-Friendly**: Implementation repos don't commit specs
✅ **AI-Friendly**: Clear context loading strategy for each repo

## Troubleshooting

### Symlinks Not Working
**Windows users**: Enable Developer Mode or use Git Bash
```bash
# Check if symlinks are supported
ls -la openspec/
# Should show symlink arrows (->)
```

### OpenSpec CLI Can't Find Specs
```bash
# Verify symlink is correct
cd ae-infinity-api  # or ae-infinity-ui
ls -la openspec/specs/
# Should show: specs -> ../../ae-infinity-context/openspec/specs
```

### Merge Conflicts in Specs
```bash
# Specs only edited in context repo - should never conflict in API/UI
# If conflict occurs, it's in context repo
cd ae-infinity-context
git status
# Resolve in context repo only
```

## Migration Path

If you already have changes in API/UI repos:

1. **Identify cross-cutting changes** → Move to context/changes/
2. **Keep implementation-specific changes** → Leave in api/ui changes/
3. **Create specs in context repo** for existing capabilities
4. **Set up symlinks** as described above
5. **Update .gitignore** in each repo
6. **Test OpenSpec CLI** in each repo

## Next Steps

1. Run setup instructions for API and UI repos
2. Create first spec in `context/openspec/specs/`
3. Practice creating changes in appropriate repos
4. Update this document with lessons learned

---

**Questions?** See `AGENTS.md` for detailed OpenSpec patterns or open an issue.

