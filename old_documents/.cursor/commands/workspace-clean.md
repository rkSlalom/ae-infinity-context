---
description: "Clean up working directories and temporary workspaces"
tags: ["workspace", "cleanup", "maintenance"]
---

# Cleanup Working Directories

Remove working directories and temporary workspaces when you're done with them.

## What This Command Does

Safely removes working directories created by the setup script, freeing up disk space and keeping your workspace organized.

## Basic Cleanup

### Remove Default Working Directory
```bash
cd ae-infinity-context
rm -rf work/
```

### Remove Custom Working Directory
```bash
cd ae-infinity-context
rm -rf [workspace-name]/
```

## Safety Checks

Before removing, verify you've committed any important changes:

```bash
cd work/ae-infinity-api
git status
git log --oneline -5

cd ../ae-infinity-ui
git status
git log --oneline -5
```

## Selective Cleanup

### Option 1: Keep Code, Remove Dependencies

**Backend (API):**
```bash
cd work/ae-infinity-api
dotnet clean
rm -rf src/*/bin/ src/*/obj/
# Keeps source code, removes build artifacts
```

**Frontend (UI):**
```bash
cd work/ae-infinity-ui
rm -rf node_modules/
# Keeps source code, removes dependencies
```

### Option 2: Full Removal
```bash
cd ae-infinity-context
rm -rf work/
# Removes everything
```

## Interactive Cleanup

For safety, use interactive mode to confirm each deletion:

```bash
rm -rfi work/
# Will prompt: remove directory 'work/'?
# Type 'y' to confirm, 'n' to cancel
```

## Cleanup Multiple Workspaces

If you've created multiple workspaces:

```bash
cd ae-infinity-context

# List all potential workspaces
ls -d work-*/ 2>/dev/null || echo "No workspaces found"

# Remove specific ones
rm -rf work-feature-a/
rm -rf work-experiment-1/

# Or remove all at once (careful!)
rm -rf work-*/
```

## Before Cleanup Checklist

- [ ] Review uncommitted changes
  ```bash
  cd work/ae-infinity-api && git status
  cd work/ae-infinity-ui && git status
  ```

- [ ] Check if changes need to be saved
  ```bash
  git diff > my-changes.patch  # Save changes to file
  ```

- [ ] Verify nothing running
  ```bash
  # Make sure no processes using these directories
  lsof +D work/ 2>/dev/null
  ```

- [ ] Confirm workspace name
  ```bash
  pwd  # Make sure you're in the right place
  ls   # Verify the directory name
  ```

## Cleanup Patterns

### Pattern 1: Daily Cleanup
At end of day, remove experimental workspaces:
```bash
cd ae-infinity-context
rm -rf work-*-$(date +%Y%m%d)/
```

### Pattern 2: Weekly Cleanup
Keep only the most recent workspace:
```bash
cd ae-infinity-context
# List all workspaces by date
ls -lt | grep "work-"
# Keep the newest, remove others
```

### Pattern 3: Disk Space Check
Check space before/after cleanup:
```bash
# Before
du -sh work/
# Example output: 450M    work/

# Remove
rm -rf work/

# Verify
du -sh work/ 2>/dev/null || echo "Workspace removed"
```

## Automated Cleanup Script

Create a helper script for regular cleanup:

```bash
#!/bin/bash
# cleanup-old-workspaces.sh

echo "🧹 Cleaning up old workspaces..."

cd ae-infinity-context

# Find directories older than 7 days
find . -maxdepth 1 -type d -name "work-*" -mtime +7 | while read dir; do
    echo "Removing old workspace: $dir"
    rm -rf "$dir"
done

echo "✅ Cleanup complete!"
```

Make it executable:
```bash
chmod +x cleanup-old-workspaces.sh
./cleanup-old-workspaces.sh
```

## Recovery Options

### If You Deleted Too Soon

If the workspace was a git clone, you can recreate it:
```bash
./setup-working-directory.sh
# All code comes fresh from git origins
```

### If You Need Changes Back

If you saved changes to a patch:
```bash
# Recreate workspace
./setup-working-directory.sh

# Apply saved changes
cd work/ae-infinity-api
git apply ../../my-changes.patch
```

## Disk Space Management

### Check Current Usage
```bash
cd ae-infinity-context
du -sh work*/
# Shows size of each workspace
```

### Typical Sizes
- Fresh workspace: ~450 MB
- With build artifacts: ~500 MB
- With node_modules cache: +100 MB

### Free Up Space
If disk space is tight:
1. Remove node_modules: `rm -rf */node_modules/`
2. Remove .NET build: `find . -name "bin" -o -name "obj" | xargs rm -rf`
3. Clean npm cache: `npm cache clean --force`
4. Clean NuGet cache: `dotnet nuget locals all --clear`

## Troubleshooting

### "Directory not empty"
If you get errors about directory not being empty:
```bash
# Force removal
rm -rf work/
# or
sudo rm -rf work/  # Use with caution
```

### "Permission denied"
```bash
# Fix permissions first
chmod -R u+w work/
rm -rf work/
```

### "Device or resource busy"
```bash
# Find what's using the directory
lsof +D work/

# Kill processes if needed
# Then retry removal
```

### Verify Removal
```bash
ls -la | grep work
# Should show nothing if removed
```

## Best Practices

1. **Review Before Removing**
   - Always check git status
   - Save any important changes
   - Verify workspace name

2. **Use Descriptive Names**
   - Name workspaces by feature or date
   - Makes it easier to identify what to keep

3. **Regular Cleanup**
   - Don't accumulate old workspaces
   - Set up weekly cleanup routine
   - Monitor disk usage

4. **Document Important Workspaces**
   - Add README if workspace needs to persist
   - Use git branches for long-running work

5. **Automation**
   - Script repetitive cleanup tasks
   - Use cron jobs for scheduled cleanup
   - Add to CI/CD cleanup steps

## Summary Commands

```bash
# Quick cleanup (default workspace)
rm -rf work/

# Safe cleanup (interactive)
rm -rfi work/

# Cleanup with verification
ls work/ && rm -rf work/ && echo "Cleaned!"

# Cleanup old workspaces (7+ days)
find . -name "work-*" -mtime +7 -exec rm -rf {} \;

# Check space saved
du -sh work/ || echo "Workspace removed"
```

## Help

For more information about working directories:
- **Setup Guide**: [WORKING_DIRECTORY_GUIDE.md](../../WORKING_DIRECTORY_GUIDE.md)
- **Quick Reference**: [QUICK_SETUP.md](../../QUICK_SETUP.md)

