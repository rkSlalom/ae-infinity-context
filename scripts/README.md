# AE Infinity - Setup Scripts

This directory contains automation scripts for setting up and managing the AE Infinity project workspace.

## 📁 Scripts

### `setup-working-directory.sh`

Creates a clean working directory with all three repositories cloned and configured for agentic development.

**Purpose:**
- Sets up an isolated workspace for AI-assisted development
- Clones all three repos (context, api, ui)
- Installs dependencies
- Creates configuration files
- Runs health checks
- Provides next steps

**Usage:**
```bash
# Basic usage - creates workspace in current directory
./setup-working-directory.sh

# Create workspace in specific directory
./setup-working-directory.sh ~/my-workspace

# Skip dependency installation (faster for quick setup)
./setup-working-directory.sh --skip-deps ~/workspace

# Use different branch (e.g., develop, feature-branch)
./setup-working-directory.sh --branch develop ~/workspace

# Verbose output for debugging
./setup-working-directory.sh --verbose ~/workspace
```

**Options:**
```
-b, --branch BRANCH       Branch to checkout (default: main)
-s, --skip-deps           Skip dependency installation
-n, --no-health-check     Skip health checks
-v, --verbose             Verbose output
-h, --help                Show help message
```

**What it does:**
1. ✓ Checks prerequisites (git, node, npm, dotnet)
2. ✓ Creates target directory structure
3. ✓ Clones three repositories:
   - `ae-infinity-context` - Specs and documentation
   - `ae-infinity-api` - .NET 9.0 backend
   - `ae-infinity-ui` - React frontend
4. ✓ Installs dependencies (npm for UI, dotnet restore for API)
5. ✓ Creates configuration files (.env.local)
6. ✓ Runs health checks
7. ✓ Provides workspace summary and next steps

**Example output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AE Infinity - Working Directory Setup v1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Workspace setup complete!

Location: /Users/username/ae-infinity-workspace

Repositories:
  • ae-infinity-context - Context & specifications
  • ae-infinity-api     - .NET backend API
  • ae-infinity-ui      - React frontend

Statistics:
  • Repositories cloned: 3/3
  • Dependencies installed: 2/2
  • Health checks passed: 3/3
```

## 🎯 Use Cases

### 1. Fresh Development Environment
Create a new workspace for development:
```bash
./setup-working-directory.sh ~/projects/ae-infinity
```

### 2. Agent Iteration Workspace
Create isolated workspace for AI agents to iterate on features:
```bash
./setup-working-directory.sh ~/ae-agent-workspace
```

### 3. Testing Different Branches
Test a feature branch across all repos:
```bash
./setup-working-directory.sh --branch feature/new-auth ~/test-workspace
```

### 4. Quick Setup (No Dependencies)
Fast setup for reading code only:
```bash
./setup-working-directory.sh --skip-deps --no-health-check ~/read-only
```

## 🏗️ Workspace Structure

After running the script, your workspace will have:

```
target-directory/
├── ae-infinity-context/          # Hub repository
│   ├── PROJECT_SPEC.md           # Project requirements
│   ├── API_SPEC.md               # API documentation
│   ├── ARCHITECTURE.md           # System architecture
│   ├── COMPONENT_SPEC.md         # UI components
│   ├── openspec/                 # OpenSpec specs and changes
│   ├── features/                 # Feature documentation
│   ├── personas/                 # User personas
│   ├── journeys/                 # User journeys
│   └── schemas/                  # JSON schemas
│
├── ae-infinity-api/              # Backend repository
│   ├── src/
│   │   ├── AeInfinity.Domain/    # Domain layer
│   │   ├── AeInfinity.Application/ # Application layer
│   │   ├── AeInfinity.Infrastructure/ # Infrastructure
│   │   └── AeInfinity.Api/       # API layer
│   ├── AeInfinity.sln            # Solution file
│   └── docs/                     # API documentation
│
└── ae-infinity-ui/               # Frontend repository
    ├── src/
    │   ├── components/           # React components
    │   ├── pages/                # Route pages
    │   ├── services/             # API clients
    │   ├── hooks/                # Custom hooks
    │   ├── contexts/             # React contexts
    │   └── types/                # TypeScript types
    ├── package.json              # Dependencies
    ├── .env.local                # Environment config (created by script)
    └── docs/                     # UI documentation
```

## 🔧 Prerequisites

The script checks for and requires:
- **Git** - Version control
- **Node.js 20+** - For React frontend
- **npm** - Package manager for UI
- **.NET 9.0 SDK** - For backend API

Install missing tools before running:
- Git: https://git-scm.com/
- Node.js: https://nodejs.org/
- .NET SDK: https://dotnet.microsoft.com/download/dotnet/9.0

## 🚀 After Setup

### Start the Backend API
```bash
cd target-directory/ae-infinity-api
cd src/AeInfinity.Api
dotnet run
```

Available at:
- HTTP: http://localhost:5233
- HTTPS: https://localhost:7184
- Swagger UI: http://localhost:5233/

### Start the Frontend UI
```bash
cd target-directory/ae-infinity-ui
npm run dev
```

Available at:
- http://localhost:5173

### Test Credentials
```
Email: sarah@example.com, alex@example.com, mike@example.com
Password: Password123!
```

## 🤖 Agentic Development Patterns

### Pattern 1: Context-First Development
```bash
# 1. Create workspace
./setup-working-directory.sh ~/agent-workspace

# 2. Agent reads context
cd ~/agent-workspace/ae-infinity-context
# Read PROJECT_SPEC.md, API_SPEC.md, etc.

# 3. Agent implements in api or ui repo
cd ~/agent-workspace/ae-infinity-api
# Make changes...

# 4. Test and iterate
```

### Pattern 2: Feature Branch Isolation
```bash
# Create workspace for specific feature branch
./setup-working-directory.sh --branch feature/user-profiles ~/feature-workspace

# Agent works in isolation
# Merge when complete
```

### Pattern 3: Multi-Agent Parallel Development
```bash
# Agent 1: Backend features
./setup-working-directory.sh ~/agent1-backend

# Agent 2: Frontend features  
./setup-working-directory.sh ~/agent2-frontend

# Agent 3: Documentation updates
./setup-working-directory.sh ~/agent3-docs
```

## 📊 Repositories Configuration

### ae-infinity-context
- **Type:** Hub repository (source of truth)
- **Remote:** https://github.com/rkSlalom/ae-infinity-context.git
- **Purpose:** All specifications, documentation, and OpenSpec content
- **Dependencies:** None (documentation only)

### ae-infinity-api
- **Type:** Implementation repository
- **Remote:** https://github.com/rkSlalom/ae-infinity-api.git
- **Purpose:** .NET 9.0 backend Web API
- **Dependencies:** .NET 9.0 SDK, Entity Framework Core, MediatR, etc.
- **Build:** `dotnet build`
- **Run:** `dotnet run` (from src/AeInfinity.Api)

### ae-infinity-ui
- **Type:** Implementation repository
- **Remote:** https://github.com/dallen4/ae-infinity-ui.git
- **Purpose:** React + TypeScript frontend
- **Dependencies:** Node.js 20+, React 19, Vite 7, TailwindCSS
- **Build:** `npm run build`
- **Run:** `npm run dev`

## 🔄 Workflow Integration

### With CI/CD
```bash
# In CI pipeline
./setup-working-directory.sh --skip-deps /tmp/ci-workspace
cd /tmp/ci-workspace
# Run tests, builds, etc.
```

### With Docker
```bash
# In Dockerfile or docker-compose
RUN ./setup-working-directory.sh --skip-deps /app/workspace
```

### With VS Code / Cursor
```bash
# Create workspace and open in editor
./setup-working-directory.sh ~/workspace
code ~/workspace
# or
cursor ~/workspace
```

## 🛠️ Troubleshooting

### Permission Denied
```bash
chmod +x setup-working-directory.sh
```

### Missing Prerequisites
The script will check and report missing tools:
```
✗ Missing required tools: node npm
Please install missing tools and try again
```

### Clone Failures
Check:
- Internet connection
- Git credentials configured
- Repository access permissions

### Dependency Installation Failures
UI (npm):
```bash
cd target-directory/ae-infinity-ui
rm -rf node_modules package-lock.json
npm install
```

API (dotnet):
```bash
cd target-directory/ae-infinity-api
dotnet clean
dotnet restore
```

## 📝 Script Maintenance

### Updating Repository URLs
Edit the script variables:
```bash
CONTEXT_REPO="https://github.com/rkSlalom/ae-infinity-context.git"
API_REPO="https://github.com/rkSlalom/ae-infinity-api.git"
UI_REPO="https://github.com/dallen4/ae-infinity-ui.git"
```

### Adding New Repositories
1. Add repo URL variable
2. Add clone step in `clone_repositories()`
3. Add dependency installation if needed
4. Update health checks
5. Update documentation

### Version Updates
Update the version constant:
```bash
VERSION="1.0.0"
```

## 🔗 Related Documentation

- [Project Specification](../PROJECT_SPEC.md)
- [Architecture Guide](../ARCHITECTURE.md)
- [Development Guide](../DEVELOPMENT_GUIDE.md)
- [OpenSpec Doctor](../openspec/doctor/README.md)

## 💡 Tips

1. **Use descriptive workspace names:** Include date or feature name
   ```bash
   ./setup-working-directory.sh ~/workspace-2025-11-05-auth-feature
   ```

2. **Keep workspaces temporary:** Delete after use to save disk space
   ```bash
   rm -rf ~/old-workspace
   ```

3. **Document agent iterations:** Keep notes in workspace
   ```bash
   echo "Agent iteration notes" > ~/workspace/AGENT_NOTES.md
   ```

4. **Use `.gitignore` for agent artifacts:** Add to workspace-level gitignore
   ```bash
   echo "agent-output/" >> ~/workspace/.gitignore
   ```

## 🎯 Success Criteria

A successful workspace setup includes:
- ✓ All 3 repos cloned
- ✓ All dependencies installed
- ✓ Configuration files created
- ✓ Health checks passed
- ✓ Clear next steps provided

## 📮 Support

For issues or questions:
1. Check this README
2. Review script `--help` output
3. Check troubleshooting section
4. Review related documentation

---

**Version:** 1.0.0  
**Last Updated:** November 5, 2025  
**Maintained by:** AE Infinity Team

