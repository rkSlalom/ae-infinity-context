# Working Directory Setup Guide

**Version**: 1.0  
**Last Updated**: November 5, 2025  
**Purpose**: Encapsulated environment for agentic development

---

## 🎯 Overview

The `setup-working-directory.sh` script creates a clean, isolated working environment by cloning all three AE Infinity repositories and setting up their dependencies. This approach enables:

- **Clean Isolation**: Separate working copies without affecting your main development environment
- **Agentic Development**: AI agents can iterate safely without disrupting production code
- **Reproducible Setup**: Consistent environment across team members and CI/CD
- **Easy Reset**: Quick teardown and recreation for testing different approaches

---

## 📋 Prerequisites

Before running the setup script, ensure you have:

### Required Software

| Tool | Minimum Version | Installation |
|------|----------------|--------------|
| **Git** | 2.0+ | https://git-scm.com/downloads |
| **.NET SDK** | 9.0+ | https://dotnet.microsoft.com/download/dotnet/9.0 |
| **Node.js** | 20+ | https://nodejs.org/ |
| **npm** | 10+ | Included with Node.js |

### System Requirements

- **OS**: macOS, Linux, or Windows with WSL/Git Bash
- **Disk Space**: ~500 MB for all repos and dependencies
- **Memory**: 4 GB RAM minimum (8 GB recommended)
- **Network**: Internet connection for cloning repos and downloading packages

---

## 🚀 Quick Start

### Basic Usage

```bash
# Navigate to context repo
cd ae-infinity-context

# Run the setup script
./scripts/setup-working-directory.sh
```

This creates a `work/` directory with all three repositories.

### Custom Directory

```bash
# Create working directory with custom name
./scripts/setup-working-directory.sh my-workspace

# Use absolute path
./scripts/setup-working-directory.sh /tmp/ae-dev-$(date +%Y%m%d)
```

### Show Help

```bash
./scripts/setup-working-directory.sh --help
```

---

## 📁 What Gets Created

### Directory Structure

```
work/                                    # Working directory (or your custom name)
├── ae-infinity-api/                     # Backend API
│   ├── src/
│   │   ├── AeInfinity.Domain/          # Domain layer
│   │   ├── AeInfinity.Application/     # Application layer
│   │   ├── AeInfinity.Infrastructure/  # Infrastructure layer
│   │   └── AeInfinity.Api/            # Presentation layer
│   ├── AeInfinity.sln                  # Solution file
│   └── README.md
│
├── ae-infinity-ui/                      # Frontend UI
│   ├── src/
│   │   ├── components/                 # React components
│   │   ├── pages/                      # Page components
│   │   ├── services/                   # API services
│   │   ├── hooks/                      # Custom hooks
│   │   └── types/                      # TypeScript types
│   ├── package.json
│   ├── node_modules/                   # Installed (by script)
│   └── README.md
│
└── ae-infinity-context/                 # Documentation
    ├── PROJECT_SPEC.md                 # Project requirements
    ├── API_SPEC.md                     # API specification
    ├── ARCHITECTURE.md                 # System architecture
    ├── COMPONENT_SPEC.md              # UI components
    ├── personas/                       # User personas
    ├── journeys/                       # User journeys
    ├── schemas/                        # JSON schemas
    └── features/                       # Feature documentation
```

### What Gets Installed

**API (.NET)**:
- NuGet packages restored
- Solution built (Debug configuration)
- Database configured (SQLite in-memory)

**UI (React)**:
- npm packages installed
- TypeScript compiled
- Build verified

**Context**:
- Documentation ready (no build needed)

---

## 🔧 What the Script Does

### Step-by-Step Process

1. **Check Prerequisites**
   - Verifies Git, .NET SDK, Node.js, and npm are installed
   - Checks .NET 9.0 SDK availability
   - Reports missing dependencies with installation links

2. **Setup Directory**
   - Creates working directory (prompts if exists)
   - Validates path and permissions

3. **Clone Repositories**
   - Clones from GitHub origins:
     - `ae-infinity-api`: https://github.com/rkSlalom/ae-infinity-api
     - `ae-infinity-ui`: https://github.com/dallen4/ae-infinity-ui.git
     - `ae-infinity-context`: https://github.com/rkSlalom/ae-infinity-context.git
   - Reports branch and commit for each

4. **Setup API**
   - Runs `dotnet restore`
   - Runs `dotnet build`
   - Validates build success

5. **Setup UI**
   - Runs `npm install`
   - Runs `npm run build` for verification
   - Validates dependencies

6. **Setup Context**
   - Verifies key documentation files
   - No build steps needed

7. **Generate Summary**
   - Reports setup status
   - Provides quick start commands
   - Lists test credentials
   - Shows documentation links

---

## 🎮 Using the Working Directory

### Starting the Application

**Terminal 1 - Backend API:**
```bash
cd work/ae-infinity-api/src/AeInfinity.Api
dotnet run
```
API will be available at:
- HTTP: http://localhost:5233
- HTTPS: https://localhost:7184
- Swagger UI: http://localhost:5233/

**Terminal 2 - Frontend UI:**
```bash
cd work/ae-infinity-ui
npm run dev
```
UI will be available at:
- Default: http://localhost:5173

### Test Credentials

| Email | Password | Role |
|-------|----------|------|
| sarah@example.com | Password123! | List Owner |
| alex@example.com | Password123! | Collaborator |
| mike@example.com | Password123! | Collaborator |

### Browsing Documentation

```bash
cd work/ae-infinity-context

# View project overview
cat PROJECT_SPEC.md

# View API endpoints
cat API_SPEC.md

# View system architecture
cat ARCHITECTURE.md

# Browse features
ls features/
```

---

## 🤖 Agentic Development Patterns

### Use Cases

**1. Feature Development Iteration**
```bash
# Create working directory for new feature
./scripts/setup-working-directory.sh work-feature-xyz

# Agent develops in isolation
cd work-feature-xyz

# Test, iterate, refine
# When ready, merge back to main repos
```

**2. Experimental Changes**
```bash
# Create experimental workspace
./scripts/setup-working-directory.sh experiment-$(date +%Y%m%d)

# Try risky refactoring
# If successful, apply to main
# If failed, just delete directory
```

**3. Parallel Development**
```bash
# Team member 1
./scripts/setup-working-directory.sh work-auth-feature

# Team member 2
./scripts/setup-working-directory.sh work-search-feature

# Both work independently, merge later
```

**4. Testing Different Approaches**
```bash
# Approach A
./scripts/setup-working-directory.sh approach-a
cd approach-a
# Implement solution A

# Approach B
./scripts/setup-working-directory.sh approach-b
cd approach-b
# Implement solution B

# Compare results, choose best approach
```

### AI Agent Workflow

1. **Context Loading**
   ```
   Agent reads: work/ae-infinity-context/PROJECT_SPEC.md
   Agent reads: work/ae-infinity-context/API_SPEC.md
   Agent reads: work/ae-infinity-context/features/[relevant-feature]/
   ```

2. **Implementation**
   ```
   Agent modifies: work/ae-infinity-api/src/...
   Agent modifies: work/ae-infinity-ui/src/...
   ```

3. **Verification**
   ```
   Agent runs: dotnet build
   Agent runs: npm run build
   Agent tests: manual or automated
   ```

4. **Iteration**
   ```
   Repeat 2-3 until feature complete
   ```

5. **Integration**
   ```
   Review changes in working directory
   Apply to main repositories
   Clean up working directory
   ```

---

## 🔄 Repository Information

### Origins

Each cloned repository maintains its original git remote:

| Repository | Origin URL |
|------------|-----------|
| **ae-infinity-api** | https://github.com/rkSlalom/ae-infinity-api |
| **ae-infinity-ui** | https://github.com/dallen4/ae-infinity-ui.git |
| **ae-infinity-context** | https://github.com/rkSlalom/ae-infinity-context.git |

### Git Operations

```bash
# Check git status in each repo
cd work/ae-infinity-api && git status
cd work/ae-infinity-ui && git status
cd work/ae-infinity-context && git status

# Pull latest changes
cd work/ae-infinity-api && git pull origin main
cd work/ae-infinity-ui && git pull origin main
cd work/ae-infinity-context && git pull origin main

# Create feature branch
cd work/ae-infinity-api && git checkout -b feature/my-feature

# View commit history
cd work/ae-infinity-api && git log --oneline -10
```

---

## 🧹 Cleanup and Reset

### Remove Working Directory

```bash
# Simple removal
rm -rf work/

# Or with confirmation
rm -rfi work/
```

### Start Fresh

```bash
# Remove and recreate
rm -rf work/
./scripts/setup-working-directory.sh work
```

### Selective Cleanup

```bash
# Keep code, remove dependencies
cd work/ae-infinity-ui
rm -rf node_modules/
npm install

# Rebuild API
cd work/ae-infinity-api
dotnet clean
dotnet build
```

---

## 🚨 Troubleshooting

### Common Issues

**Issue**: "Missing required dependencies: dotnet"
```bash
# Solution: Install .NET 9.0 SDK
# macOS (Homebrew):
brew install --cask dotnet-sdk

# Windows:
# Download from https://dotnet.microsoft.com/download/dotnet/9.0

# Linux:
# Follow instructions at https://learn.microsoft.com/en-us/dotnet/core/install/linux
```

**Issue**: "Missing required dependencies: node"
```bash
# Solution: Install Node.js 20+
# macOS (Homebrew):
brew install node@20

# Windows:
# Download from https://nodejs.org/

# Linux:
# Use nvm or package manager
```

**Issue**: "Directory 'work' already exists"
```bash
# Solution 1: Remove existing directory
rm -rf work/
./scripts/setup-working-directory.sh

# Solution 2: Use different name
./scripts/setup-working-directory.sh work-new
```

**Issue**: "Failed to clone ae-infinity-ui"
```bash
# Check network connection
ping github.com

# Check Git credentials
git config --global user.name
git config --global user.email

# Try manual clone to debug
git clone https://github.com/dallen4/ae-infinity-ui.git test-clone
```

**Issue**: "Build failed (see errors above)" for API
```bash
# Check .NET version
dotnet --version
dotnet --list-sdks

# Ensure .NET 9.0+ is installed
# Try manual build
cd work/ae-infinity-api
dotnet restore -v detailed
dotnet build -v detailed
```

**Issue**: "npm install failed" for UI
```bash
# Clear npm cache
npm cache clean --force

# Delete and reinstall
cd work/ae-infinity-ui
rm -rf node_modules/ package-lock.json
npm install

# Try with verbose logging
npm install --verbose
```

### Getting Help

**Check Script Output**
The script provides colored, detailed output:
- 🔵 Blue: Progress steps
- 🟢 Green: Success messages
- 🟡 Yellow: Warnings (non-critical)
- 🔴 Red: Errors (critical)
- 🔵 Cyan: Information

**Enable Debug Mode**
```bash
# Run with bash debug
bash -x ./scripts/setup-working-directory.sh
```

**Manual Verification**
```bash
# Verify prerequisites
git --version
dotnet --version
node --version
npm --version

# Check disk space
df -h .

# Check permissions
ls -la setup-working-directory.sh
```

---

## 📊 Architecture Details

### Technology Stack

**Backend (ae-infinity-api)**
- Framework: .NET 9.0 Web API
- Architecture: Clean Architecture (Domain, Application, Infrastructure, API layers)
- Database: SQLite in-memory with Entity Framework Core
- Patterns: CQRS with MediatR, Repository pattern
- Authentication: JWT Bearer tokens
- Validation: FluentValidation
- Mapping: AutoMapper

**Frontend (ae-infinity-ui)**
- Framework: React 19
- Language: TypeScript
- Bundler: Vite 7
- Routing: React Router 7
- Styling: Tailwind CSS 3
- State: React Context + hooks

**Context (ae-infinity-context)**
- Format: Markdown + JSON Schema
- Structure: Feature-driven documentation
- Purpose: Single source of truth for specifications

### Dependencies

**API (NuGet Packages)**
- Microsoft.EntityFrameworkCore.Sqlite
- MediatR
- FluentValidation
- AutoMapper
- BCrypt.Net-Next
- Serilog
- Swashbuckle.AspNetCore (Swagger)

**UI (npm Packages)**
- react & react-dom
- react-router
- typescript
- tailwindcss
- vite
- eslint

---

## 🔐 Security Considerations

### What's Safe

✅ **Safe for agentic development**:
- Working directory is isolated
- No production data
- Test credentials only
- Local development environment

✅ **Safe to delete**:
- Entire working directory
- No impact on original repositories
- Can recreate anytime

### What to Watch

⚠️ **Be careful with**:
- Git operations (pushes, force pushes)
- Committing secrets or API keys
- Exposing ports publicly
- Running untrusted code

⚠️ **Don't commit**:
- `.env` files with real secrets
- `appsettings.*.json` with production config
- Personal access tokens
- SSH keys or certificates

### Best Practices

1. **Use working directory for experimentation**
   - Keep main repos clean
   - Test in isolation first

2. **Review before merging back**
   - Check all changes carefully
   - Run tests
   - Code review if team environment

3. **Clean up regularly**
   - Remove old working directories
   - Don't accumulate stale workspaces

4. **Keep dependencies updated**
   - Periodically run setup again
   - Get latest from git origins

---

## 📖 Additional Resources

### Documentation

- **[PROJECT_SPEC.md](./PROJECT_SPEC.md)** - Complete project requirements
- **[API_SPEC.md](./API_SPEC.md)** - REST API endpoints and contracts
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture and patterns
- **[COMPONENT_SPEC.md](./COMPONENT_SPEC.md)** - UI component specifications
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - Development workflow

### Related Repositories

- **API**: [ae-infinity-api README](../ae-infinity-api/README.md)
- **UI**: [ae-infinity-ui README](../ae-infinity-ui/README.md)
- **Context**: [ae-infinity-context README](./README.md)

### External Links

- **.NET Documentation**: https://learn.microsoft.com/en-us/dotnet/
- **React Documentation**: https://react.dev/
- **Vite Documentation**: https://vite.dev/
- **TypeScript Documentation**: https://www.typescriptlang.org/docs/

---

## 🎓 Examples

### Example 1: Quick Development Session

```bash
# Morning: Create fresh workspace
./scripts/setup-working-directory.sh work-$(date +%Y%m%d)

# Start development
cd work-20251105/ae-infinity-api/src/AeInfinity.Api
dotnet run &

cd ../../ae-infinity-ui
npm run dev &

# Develop all day...
# Make changes, test, iterate

# Evening: Review and commit
cd ae-infinity-api
git add .
git commit -m "feat: Add new feature"

# Push to feature branch
git push origin feature/my-feature

# Cleanup
cd ../../../
rm -rf work-20251105/
```

### Example 2: AI Agent Iteration

```bash
# Setup workspace
./scripts/setup-working-directory.sh ai-workspace

# Agent reads context
cat ai-workspace/ae-infinity-context/PROJECT_SPEC.md
cat ai-workspace/ae-infinity-context/features/authentication/README.md

# Agent implements feature
# (AI modifies files in ai-workspace/)

# Human reviews
cd ai-workspace
git diff ae-infinity-api/src/

# If good, merge to main
# If not, iterate or discard

# Cleanup when done
cd ..
rm -rf ai-workspace/
```

### Example 3: Comparing Implementations

```bash
# Create two workspaces
./scripts/setup-working-directory.sh approach-state-management
./scripts/setup-working-directory.sh approach-context-api

# Implement different approaches
cd approach-state-management/ae-infinity-ui
# Implement using state management library

cd ../approach-context-api/ae-infinity-ui
# Implement using React Context

# Compare results
diff -r approach-state-management/ae-infinity-ui/src approach-context-api/ae-infinity-ui/src

# Choose best approach
# Cleanup non-selected workspace
```

---

## ✅ Checklist for Success

### Before Running Script

- [ ] Git installed and configured
- [ ] .NET 9.0 SDK installed
- [ ] Node.js 20+ installed
- [ ] npm 10+ installed
- [ ] Internet connection available
- [ ] Adequate disk space (~500 MB)

### After Running Script

- [ ] All three repos cloned successfully
- [ ] API builds without errors
- [ ] UI dependencies installed
- [ ] Context documentation accessible
- [ ] Test credentials work
- [ ] Both API and UI start successfully

### For Production Use

- [ ] Review all changes in working directory
- [ ] Run comprehensive tests
- [ ] Update documentation if needed
- [ ] Code review completed
- [ ] Merge to main repositories
- [ ] Clean up working directory

---

## 📝 Script Maintenance

### Updating Repository URLs

If repository locations change, edit `setup-working-directory.sh`:

```bash
# Line ~12-14 in the script
API_REPO="https://github.com/rkSlalom/ae-infinity-api"
UI_REPO="https://github.com/dallen4/ae-infinity-ui.git"
CONTEXT_REPO="https://github.com/rkSlalom/ae-infinity-context.git"
```

### Adding New Repositories

To add a fourth repository:

1. Add URL constant at top of script
2. Create `clone_new_repo()` function call in `clone_repositories()`
3. Add `setup_new_repo()` function if build steps needed
4. Update `generate_summary()` to include new repo

### Customizing Build Steps

Edit the `setup_api()` or `setup_ui()` functions to change build commands:

```bash
setup_api() {
    # Add custom build steps here
    dotnet restore
    dotnet build --configuration Release  # Change to Release
    dotnet test  # Add test step
}
```

---

## 🤝 Contributing

### Improving the Script

1. Test your changes thoroughly
2. Update this guide with new features
3. Maintain backward compatibility
4. Add helpful error messages
5. Update version number in script header

### Reporting Issues

If you encounter issues:

1. Run script with debug: `bash -x ./scripts/setup-working-directory.sh`
2. Check prerequisites are met
3. Review error messages carefully
4. Document steps to reproduce
5. Report to team with details

---

## 📄 License

This script is part of the AE Infinity project for the Slalom AE Immersion Workshop.

---

## 📞 Support

For questions or issues:
- Check this guide's troubleshooting section
- Review the main project documentation
- Reach out to the development team
- Check repository issues on GitHub

---

**Version**: 1.0  
**Last Updated**: November 5, 2025  
**Maintained by**: AE Infinity Team

---

**Happy Coding! 🚀**

