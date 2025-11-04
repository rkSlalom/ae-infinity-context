# OpenSpec Doctor - Quick Start

The simplest way to ensure your OpenSpec setup is healthy.

## From Cursor (Recommended)

In any of the three repos, use the slash command:

```
/openspec-doctor
```

The AI will:
1. Run diagnostics
2. Show you what's wrong (if anything)
3. Ask if you want to auto-fix
4. Fix issues and show final report

## From Command Line

### Check Health

```bash
# From anywhere
cd /path/to/ae-infinity-context/openspec/doctor
./openspec-doctor.sh
```

### Auto-Fix Issues

```bash
./openspec-doctor.sh --fix
```

### See Details

```bash
./openspec-doctor.sh --verbose
```

## What It Fixes

- ✅ Missing symlinks
- ✅ Incorrect symlink targets
- ✅ Missing directories (`openspec/`, `changes/`, `specs/`)
- ✅ Missing .gitignore entries
- ✅ Missing slash commands
- ✅ Incorrect relative paths

## When to Run

**Always run after:**
- Initial setup
- Cloning repos for the first time
- Moving/renaming repos
- Team member onboarding
- Suspected configuration issues
- Merge conflicts in openspec/

**Regular checks:**
- Before starting new features
- After long branches are merged
- Weekly (if actively developing)

## Example Output

### Healthy Setup

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OpenSpec Doctor v1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ API repo detected: ae-infinity-api
✓ UI repo detected: ae-infinity-ui
✓ All checks passed!
  OpenSpec is correctly configured across all repositories.
```

### Issues Found (Diagnostic Mode)

```
⚠ Found 3 issue(s)

  ⚠ API repo: Missing symlink: project.md
  ⚠ UI repo: .gitignore missing 1 OpenSpec entries  
  ⚠ API repo: Missing 2 slash commands

Run with --fix flag to automatically repair issues:
  ./openspec-doctor.sh --fix
```

### Issues Auto-Fixed

```
✓ API repo: Created project.md symlink [FIXED]
✓ UI repo: Added OpenSpec entries to .gitignore [FIXED]
✓ API repo: Copied missing slash commands [FIXED]

✓ Fixed 3 issue(s) automatically
```

## Integration Options

### 1. Git Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
if ! ../ae-infinity-context/openspec/doctor/openspec-doctor.sh; then
    echo ""
    echo "❌ OpenSpec setup has issues!"
    echo "Run: ./openspec-doctor.sh --fix"
    exit 1
fi
```

### 2. CI/CD

```yaml
# .github/workflows/openspec-check.yml
name: OpenSpec Health Check
on: [pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check OpenSpec
        run: |
          cd ae-infinity-context/openspec/doctor
          ./openspec-doctor.sh
```

### 3. NPM Script (UI repo)

```json
{
  "scripts": {
    "openspec:check": "../ae-infinity-context/openspec/doctor/openspec-doctor.sh",
    "openspec:fix": "../ae-infinity-context/openspec/doctor/openspec-doctor.sh --fix"
  }
}
```

### 4. Make Target (API repo)

```makefile
.PHONY: openspec-check openspec-fix

openspec-check:
	../ae-infinity-context/openspec/doctor/openspec-doctor.sh

openspec-fix:
	../ae-infinity-context/openspec/doctor/openspec-doctor.sh --fix
```

## Troubleshooting

**"API repo not found"**
→ Ensure repo has `.sln` or `.csproj` files

**"UI repo not found"**  
→ Ensure repo has `package.json` with react/vite

**"Permission denied"**
→ Run: `chmod +x openspec-doctor.sh`

**"Python not found"**
→ Install Python 3 or set paths manually

**Symlinks not working (Windows)**
→ Enable Developer Mode or use Git Bash

## Full Documentation

- **Detailed Guide**: See [README.md](./README.md)
- **Setup Instructions**: See [../CROSS_REPO_SETUP.md](../CROSS_REPO_SETUP.md)
- **Quick Reference**: See [../QUICK_REFERENCE.md](../QUICK_REFERENCE.md)

---

**TL;DR**: Run `/openspec-doctor` in Cursor or `./openspec-doctor.sh --fix` from command line. Done! ✅

