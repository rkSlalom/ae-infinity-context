#!/Users/nieky.allen/Projects/ae-workshop/ae-infinity/ae-infinity-context/openspec/doctor

This directory contains the **OpenSpec Doctor** - an automated diagnostic and repair tool for cross-repository OpenSpec setups.

## Purpose

OpenSpec Doctor ensures your multi-repo OpenSpec configuration is healthy by:
- ✅ Detecting all repositories automatically
- ✅ Validating symlinks and directory structure
- ✅ Checking .gitignore entries
- ✅ Verifying slash commands are present
- ✅ Auto-fixing common issues

## Quick Start

### Run Diagnostics

```bash
cd /path/to/ae-infinity-context/openspec/doctor
./openspec-doctor.sh
```

This shows what's wrong without changing anything.

### Auto-Fix Issues

```bash
./openspec-doctor.sh --fix
```

Automatically repairs detected issues.

### Verbose Mode

```bash
./openspec-doctor.sh --fix --verbose
```

Shows detailed information about each check.

## What It Checks

### 1. Repository Detection
- Automatically finds API repo (looks for .NET projects)
- Automatically finds UI repo (looks for React/Vite package.json)
- Works even if repos are renamed
- Relative path detection

### 2. Context Repo Structure
- `openspec/project.md` exists
- `openspec/AGENTS.md` exists
- `openspec/specs/` directory exists
- `openspec/changes/` directory exists
- Documentation files present

### 3. Symlinks (API and UI repos)
- `openspec/project.md` → `../../ae-infinity-context/openspec/project.md`
- `openspec/AGENTS.md` → `../../ae-infinity-context/openspec/AGENTS.md`
- `openspec/specs/` → `../../ae-infinity-context/openspec/specs/`
- Calculates correct relative paths automatically
- Verifies symlinks point to correct locations

### 4. .gitignore Entries
- Checks for OpenSpec symlink exclusions
- Verifies proper format
- Auto-adds missing entries

### 5. Slash Commands
- Checks for `.cursor/commands/` directory in each repo
- Checks root directory `.cursor/commands/` as well
- Verifies presence of:
  - `openspec-proposal.md`
  - `openspec-apply.md`
  - `openspec-archive.md`
  - `openspec-doctor.md`
- Copies missing commands from context repo

### 6. Local Directories
- Each implementation repo has `openspec/changes/` (local)
- Archive directories exist

## Usage Examples

### From Context Repo

```bash
cd ae-infinity-context/openspec/doctor
./openspec-doctor.sh --fix
```

### From API Repo

```bash
cd ae-infinity-api
../ae-infinity-context/openspec/doctor/openspec-doctor.sh
```

### From UI Repo

```bash
cd ae-infinity-ui
../ae-infinity-context/openspec/doctor/openspec-doctor.sh --fix
```

### As Part of CI/CD

```bash
# In your CI script
if ! ./openspec-doctor.sh; then
    echo "OpenSpec setup has issues!"
    ./openspec-doctor.sh --fix
fi
```

## Output Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OpenSpec Doctor v1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ  Running in AUTO-FIX mode

ℹ  Detecting repository locations...
✓  API repo detected: ae-infinity-api
✓  UI repo detected: ae-infinity-ui

ℹ  Checking context repo structure...
✓  Found: openspec/project.md
✓  Found: openspec/AGENTS.md
✓  Found: openspec/specs/
✓  Found: openspec/changes/

ℹ  Checking API repo symlinks...
✓  API repo: project.md → correct
✓  API repo: AGENTS.md → correct
✓  API repo: specs → correct
✓  API repo: Has local changes/ directory

ℹ  Checking API repo .gitignore...
✓  API repo: .gitignore has OpenSpec entries

ℹ  Checking API repo slash commands...
✓  API repo: Has all OpenSpec slash commands

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OpenSpec Health Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ All checks passed!
  OpenSpec is correctly configured across all repositories.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Common Issues and Fixes

### Issue: "API repo not found"
**Cause**: Script can't detect .NET project markers
**Fix**: Ensure repo has `*.sln` or `*.csproj` files
**Manual**: Set `API_REPO` environment variable

### Issue: "Symlink points to wrong location"
**Cause**: Repo was moved or renamed
**Fix**: Run with `--fix` to recalculate paths
**Result**: Symlinks updated with correct relative paths

### Issue: "openspec/project.md exists but is not a symlink"
**Cause**: File was created manually instead of symlinked
**Fix**: Script will ask to replace with symlink
**Action**: Backup the file first if it has changes

### Issue: "Missing slash commands"
**Cause**: `.cursor/commands/` not set up
**Fix**: Run with `--fix` to copy from context repo
**Verify**: Check `.cursor/commands/` directory

## Advanced Usage

### Custom Repository Names

If your repos have different names:

```bash
# Set environment variables
export API_REPO=/path/to/my-custom-api-name
export UI_REPO=/path/to/my-custom-ui-name

./openspec-doctor.sh --fix
```

### Different Folder Hierarchy

Works with any structure as long as repos are siblings:

```
my-project/
├── backend/          # API repo (will be detected)
├── frontend/         # UI repo (will be detected)
└── documentation/    # Context repo (run doctor from here)
```

### Continuous Monitoring

Add to git hooks:

```bash
# .git/hooks/pre-commit
#!/bin/bash
if ! ../ae-infinity-context/openspec/doctor/openspec-doctor.sh; then
    echo "OpenSpec setup has issues. Run 'openspec-doctor.sh --fix'"
    exit 1
fi
```

## Integration with Cursor

Use the `/openspec-doctor` slash command:

1. Open any repo in Cursor
2. Type `/openspec-doctor` in chat
3. Review diagnostics
4. Confirm auto-fix if needed
5. Verify health report

The slash command wraps this script and provides interactive feedback.

## Exit Codes

- `0` - All checks passed
- `>0` - Number of issues found (diagnostic mode)
- `>0` - Number of issues remaining after fix (auto-fix mode)

Use in CI/CD:

```bash
if ./openspec-doctor.sh; then
    echo "✓ OpenSpec setup is healthy"
else
    echo "✗ OpenSpec setup needs attention"
    exit 1
fi
```

## Requirements

- Bash 4.0+
- Python 3 (for relative path calculation)
- Standard Unix tools (ln, readlink, grep, find)
- Works on macOS, Linux, WSL

## Files Created/Modified

**Auto-creates (if missing):**
- `{repo}/openspec/` directory
- `{repo}/openspec/changes/archive/` directory
- `{repo}/.cursor/commands/` directory
- `{context}/openspec/specs/` directory
- `{context}/openspec/changes/` directory

**Auto-modifies (if needed):**
- `{repo}/.gitignore` - Adds OpenSpec exclusions
- `{repo}/openspec/project.md` - Creates/fixes symlink
- `{repo}/openspec/AGENTS.md` - Creates/fixes symlink
- `{repo}/openspec/specs/` - Creates/fixes symlink

**Never modifies:**
- Actual content in context repo (project.md, AGENTS.md, specs/)
- Existing changes in any repo
- Custom slash commands

## Troubleshooting

### Symlinks not working on Windows

Enable Developer Mode or use Git Bash:
```bash
# In Git Bash
./openspec-doctor.sh --fix
```

### Permission denied

Make script executable:
```bash
chmod +x openspec-doctor.sh
```

### Python not found

Install Python 3 or manually set relative paths in the script.

### Script can't find repos

Manually specify:
```bash
API_REPO=/full/path/to/api \
UI_REPO=/full/path/to/ui \
./openspec-doctor.sh --fix
```

## Maintenance

### Updating the Doctor

Pull latest from context repo:
```bash
cd ae-infinity-context
git pull origin main
```

Doctor updates automatically.

### Adding New Checks

Edit `openspec-doctor.sh` and add functions:
1. Define check function
2. Call from `main()`
3. Update this README
4. Test with `--verbose` flag

## Support

- **Documentation**: See `../CROSS_REPO_SETUP.md`
- **Quick Reference**: See `../QUICK_REFERENCE.md`
- **Issues**: Open issue in context repo
- **Questions**: Check `../AGENTS.md` for patterns

---

**Remember**: Run doctor after:
- Initial setup
- Repo renames/moves
- Team member onboarding
- Merge conflicts in openspec/
- Suspected configuration drift

