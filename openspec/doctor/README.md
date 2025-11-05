# OpenSpec Doctor - Automated Setup Validation

A self-contained diagnostic and repair tool that ensures OpenSpec is correctly configured across all three repositories.

## Problem It Solves

When working with multiple repositories and symlinks, things can go wrong:
- ❌ Symlinks point to wrong locations after repo moves
- ❌ Missing directories or configuration files
- ❌ .gitignore not excluding symlinks
- ❌ New team members have incomplete setup
- ❌ Different folder names or hierarchies break paths

**OpenSpec Doctor fixes all of these automatically.**

## Quick Usage

### Option 1: Cursor Slash Command (Easiest)

From any of the three repos in Cursor:

```
/openspec-doctor
```

The AI will:
1. Run diagnostics
2. Explain issues found
3. Ask permission to fix
4. Auto-repair and verify

### Option 2: Command Line

```bash
# Diagnostic mode (reports issues)
cd ae-infinity-context/openspec/doctor
./openspec-doctor.sh

# Auto-fix mode (repairs issues)
./openspec-doctor.sh --fix

# Verbose mode (detailed output)
./openspec-doctor.sh --fix --verbose
```

## What It Checks

### 1. Repository Detection ✅
- Automatically finds API repo (.NET markers: `.sln`, `.csproj`)
- Automatically finds UI repo (React/Vite markers: `package.json`)
- Works even if repos are renamed or in different locations

### 2. Context Repo Structure ✅
- `openspec/project.md` exists
- `openspec/AGENTS.md` exists
- `openspec/specs/` directory exists
- `openspec/changes/` directory exists
- Documentation files present

### 3. Symlinks (API & UI repos) ✅
- `openspec/project.md` → correct relative path to context
- `openspec/AGENTS.md` → correct relative path to context
- `openspec/specs/` → correct relative path to context
- Calculates relative paths automatically
- Creates missing symlinks
- Fixes incorrect symlink targets

### 4. .gitignore Entries ✅
- Verifies symlinks are excluded from git
- Adds missing OpenSpec exclusion rules
- Prevents accidental commits of symlinks

### 5. Slash Commands ✅
- Checks for `.cursor/commands/` directory
- Verifies `openspec-proposal.md`, `openspec-apply.md`, `openspec-archive.md`
- Copies missing commands from context repo

### 6. Directory Structure ✅
- Each repo has `openspec/` directory
- Implementation repos have local `changes/` directory
- Archive directories exist

## How It Works

```
┌─────────────────────────────────────────┐
│  Run: /openspec-doctor                  │
│  or: ./openspec-doctor.sh --fix         │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  1. Detect Repositories                 │
│     - Scan parent directory             │
│     - Identify by file markers          │
│     - Calculate relative paths          │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  2. Validate Context Repo               │
│     - Check required files exist        │
│     - Verify directory structure        │
│     - Create missing dirs if --fix      │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  3. Check API & UI Repos                │
│     - Validate symlinks                 │
│     - Check .gitignore entries          │
│     - Verify slash commands             │
│     - Fix issues if --fix flag set      │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  4. Generate Health Report              │
│     - Count issues found                │
│     - Count issues fixed                │
│     - Display summary                   │
└─────────────────────────────────────────┘
```

## Example: Fixing a Broken Setup

### Before (Issues Found)

```bash
$ ./openspec-doctor.sh

ℹ  Detecting repository locations...
✓  API repo detected: ae-infinity-api
✓  UI repo detected: ae-infinity-ui

ℹ  Checking API repo symlinks...
⚠  API repo: Missing symlink: project.md
⚠  API repo: Missing symlink: AGENTS.md
⚠  API repo: specs → incorrect target

ℹ  Checking API repo .gitignore...
⚠  API repo: .gitignore missing 3 OpenSpec entries

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OpenSpec Health Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ Found 6 issue(s)

Run with --fix flag to automatically repair issues:
  ./openspec-doctor.sh --fix
```

### After (Auto-Fixed)

```bash
$ ./openspec-doctor.sh --fix

ℹ  Running in AUTO-FIX mode

ℹ  Checking API repo symlinks...
✓  API repo: Created project.md symlink [FIXED]
✓  API repo: Created AGENTS.md symlink [FIXED]
✓  API repo: Fixed specs symlink [FIXED]

ℹ  Checking API repo .gitignore...
✓  API repo: Added OpenSpec entries to .gitignore [FIXED]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OpenSpec Health Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Fixed 6 issue(s) automatically

✓ All checks passed!
  OpenSpec is correctly configured across all repositories.
```

## Advanced Features

### Works with Any Repo Names

```
my-project/
├── backend/          # Detected as API repo
├── frontend/         # Detected as UI repo
└── docs/             # Context repo (run doctor from here)
```

### Works from Any Location

```bash
# From API repo
cd ae-infinity-api
../ae-infinity-context/openspec/doctor/openspec-doctor.sh --fix

# From UI repo
cd ae-infinity-ui
../ae-infinity-context/openspec/doctor/openspec-doctor.sh --fix

# From parent directory
cd ae-infinity
ae-infinity-context/openspec/doctor/openspec-doctor.sh --fix
```

### Calculates Correct Paths Automatically

No matter where repos are located, the doctor calculates correct relative paths:

```
From: ae-infinity-api/openspec/
To:   ae-infinity-context/openspec/
Path: ../../ae-infinity-context/openspec/
```

## Integration Examples

### CI/CD

```yaml
# .github/workflows/pr-check.yml
name: OpenSpec Health
on: [pull_request]
jobs:
  openspec:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run OpenSpec Doctor
        run: |
          cd ae-infinity-context/openspec/doctor
          ./openspec-doctor.sh
```

### Git Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash
if ! ../ae-infinity-context/openspec/doctor/openspec-doctor.sh; then
    echo "❌ OpenSpec setup has issues!"
    echo "Fix with: ./openspec-doctor.sh --fix"
    exit 1
fi
```

### NPM Script

```json
{
  "scripts": {
    "pretest": "../ae-infinity-context/openspec/doctor/openspec-doctor.sh"
  }
}
```

## When to Run

**Always:**
- After initial repo setup
- After cloning repos
- Before opening PR
- When onboarding new team members

**As Needed:**
- After moving/renaming repos
- After long-running branches merge
- When symlinks seem broken
- When slash commands don't work

**Regular:**
- Weekly if actively developing
- Before major releases
- After dependency updates

## Files Created/Modified

### Auto-Creates (if missing):
- `{repo}/openspec/` directory
- `{repo}/openspec/changes/` directory
- `{repo}/.cursor/commands/` directory
- Symlinks: `project.md`, `AGENTS.md`, `specs/`

### Auto-Modifies:
- `{repo}/.gitignore` - Adds OpenSpec exclusions

### Never Touches:
- Actual spec content in context repo
- Existing changes in any repo
- Custom slash commands
- User data or configurations

## Benefits for Your Teammate

When your teammate clones the repos:

```bash
# 1. Clone all three repos
git clone .../ae-infinity-context
git clone .../ae-infinity-api  
git clone .../ae-infinity-ui

# 2. Run doctor (from any repo)
cd ae-infinity-context/openspec/doctor
./openspec-doctor.sh --fix

# 3. Done! ✅
# - All symlinks created
# - All directories set up
# - .gitignore configured
# - Slash commands installed
```

**Zero manual configuration needed!**

## Documentation

- **Quick Start**: [doctor/QUICK_START.md](ae-infinity-context/openspec/doctor/QUICK_START.md)
- **Full Guide**: [doctor/README.md](ae-infinity-context/openspec/doctor/README.md)
- **Setup Guide**: [openspec/CROSS_REPO_SETUP.md](ae-infinity-context/openspec/CROSS_REPO_SETUP.md)

## Troubleshooting

See [doctor/README.md#troubleshooting](ae-infinity-context/openspec/doctor/README.md#troubleshooting) for:
- Repository not detected
- Symlink issues on Windows
- Permission errors
- Python not found
- Custom repo names/locations

## Summary

**OpenSpec Doctor is your safety net for cross-repository OpenSpec setups.**

- ✅ Auto-detects repos (even with different names)
- ✅ Validates configuration (symlinks, directories, files)
- ✅ Auto-fixes issues (with permission)
- ✅ Works from anywhere (any repo, any location)
- ✅ Integrates everywhere (Cursor, CLI, CI/CD)
- ✅ Zero manual work (for new team members)

**Your teammate just needs to run one command after cloning. That's it.**

---

**Try it now**: Type `/openspec-doctor` in Cursor or run `./openspec-doctor.sh --fix`

