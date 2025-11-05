---
description: "Setup a new isolated working directory with all three repositories"
tags: ["workspace", "setup", "clone"]
---

# Setup Working Directory

Create a clean, isolated working environment by cloning all three AE Infinity repositories and installing their dependencies.

## What This Command Does

1. Runs the automated setup script
2. Clones all three repos (API, UI, Context)
3. Installs dependencies (NuGet packages, npm modules)
4. Builds projects to verify setup
5. Reports status and next steps

## Usage

You can customize the workspace directory name:
- Default: `work/`
- Custom: Provide a directory name

## Prerequisites

Before running, ensure you have:
- Git 2.0+
- .NET SDK 9.0+
- Node.js 20+
- npm 10+

## Script Execution

```bash
cd ae-infinity-context
./setup-working-directory.sh [workspace-name]
```

## After Setup

The script will create a complete working environment:

```
work/                           # Or your custom name
├── ae-infinity-api/           # Backend (built and ready)
├── ae-infinity-ui/            # Frontend (dependencies installed)
└── ae-infinity-context/       # Documentation
```

## Starting the Application

**Terminal 1 - Backend:**
```bash
cd work/ae-infinity-api/src/AeInfinity.Api
dotnet run
# API at http://localhost:5233
```

**Terminal 2 - Frontend:**
```bash
cd work/ae-infinity-ui
npm run dev
# UI at http://localhost:5173
```

## Test Credentials

| Email | Password |
|-------|----------|
| sarah@example.com | Password123! |
| alex@example.com | Password123! |
| mike@example.com | Password123! |

## Common Use Cases

### Feature Development
```bash
./setup-working-directory.sh feature-user-stats
# Develop in isolated environment
# Test thoroughly
# Merge back if successful
```

### Experimental Changes
```bash
./setup-working-directory.sh experiment-$(date +%Y%m%d)
# Try risky refactoring
# Delete if it doesn't work out
```

### Parallel Development
```bash
# Team member 1
./setup-working-directory.sh work-auth

# Team member 2  
./setup-working-directory.sh work-search
```

## Documentation

- **Full Guide**: [WORKING_DIRECTORY_GUIDE.md](../../WORKING_DIRECTORY_GUIDE.md)
- **Quick Reference**: [QUICK_SETUP.md](../../QUICK_SETUP.md)
- **Visual Overview**: [VISUAL_OVERVIEW.md](../../VISUAL_OVERVIEW.md)
- **Repository Analysis**: [REPOSITORY_ANALYSIS.md](../../REPOSITORY_ANALYSIS.md)

## Cleanup

When done with the workspace:

```bash
rm -rf work/
# Or your custom workspace name
```

## Help

For detailed options:
```bash
./setup-working-directory.sh --help
```

