# Working Directory Pattern for Agentic Development

**Version:** 1.0  
**Last Updated:** November 5, 2025  
**Purpose:** Encapsulate and isolate agentic development iterations

## 🎯 Overview

The Working Directory Pattern provides a reproducible, isolated workspace for AI-assisted development across multiple repositories. This pattern enables agents to iterate on features in clean environments without affecting the primary development workspace.

## 🏗️ Architecture

### Three-Repository Structure

```
ae-infinity/
├── ae-infinity-context/    # Hub: Source of truth
│   ├── specs/              # All specifications
│   ├── docs/               # Documentation
│   └── scripts/            # Setup automation
│       └── setup-working-directory.sh
│
├── ae-infinity-api/        # Backend implementation
│   └── src/                # .NET 9.0 API
│
└── ae-infinity-ui/         # Frontend implementation
    └── src/                # React + TypeScript
```

### Hub-and-Spoke Model

```
┌─────────────────────────────────────────────┐
│         ae-infinity-context (Hub)           │
│                                             │
│  • All specifications                       │
│  • Documentation                            │
│  • Setup scripts                            │
│  • OpenSpec configurations                  │
└──────────────┬──────────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼─────┐    ┌────▼──────┐
│ ae-infinity│    │ae-infinity│
│    -api    │    │    -ui    │
│            │    │           │
│ .NET API   │    │ React UI  │
└────────────┘    └───────────┘
```

## 🔄 The Pattern

### 1. Replication Strategy

**Goal:** Create identical, isolated working environments on demand.

**Implementation:**
```bash
./scripts/setup-working-directory.sh [target-directory]
```

**Benefits:**
- ✅ Reproducible environments
- ✅ Isolated from main workspace
- ✅ Safe for agent iterations
- ✅ Easy cleanup

### 2. Encapsulation Principles

#### A. Repository-Level Encapsulation
Each repository maintains its own:
- Dependencies
- Configuration
- Build artifacts
- Test data

#### B. Workspace-Level Encapsulation
Each working directory contains:
- All three repos
- Complete dependency tree
- Independent git state
- Isolated configurations

#### C. Agent-Level Encapsulation
Each agent iteration gets:
- Clean workspace
- Fresh git checkouts
- No shared state
- Independent execution

### 3. Automation Components

#### Setup Script Features
1. **Prerequisites Check**
   - Validates required tools (git, node, dotnet)
   - Reports missing dependencies
   - Provides installation links

2. **Repository Cloning**
   - Clones all three repos from GitHub
   - Checks out specified branch (default: main)
   - Maintains git history

3. **Dependency Installation**
   - npm install for UI
   - dotnet restore for API
   - Can be skipped for speed

4. **Configuration Generation**
   - Creates .env.local for UI
   - Sets API base URLs
   - Configures feature flags

5. **Health Checks**
   - Validates repository structure
   - Checks build configurations
   - Verifies critical files

6. **Summary & Next Steps**
   - Shows workspace statistics
   - Provides startup commands
   - Lists test credentials

## 🤖 Agentic Development Workflows

### Workflow 1: Single Agent Iteration

```bash
# 1. Agent requests workspace
./setup-working-directory.sh ~/agent-workspace-001

# 2. Agent reads context
cd ~/agent-workspace-001/ae-infinity-context
# Parse PROJECT_SPEC.md, API_SPEC.md, etc.

# 3. Agent implements changes
cd ~/agent-workspace-001/ae-infinity-api
# Make changes to backend...

# 4. Agent tests changes
cd src/AeInfinity.Api
dotnet run
# Test endpoints...

# 5. Agent commits work
git add .
git commit -m "feat: implement feature X"
git push origin feature/agent-iteration-001

# 6. Clean up workspace (optional)
cd ~
rm -rf ~/agent-workspace-001
```

### Workflow 2: Multi-Agent Parallel Development

```bash
# Agent A: Backend feature
./setup-working-directory.sh ~/agent-a-backend
cd ~/agent-a-backend/ae-infinity-api
# Work on API endpoints...

# Agent B: Frontend feature (parallel)
./setup-working-directory.sh ~/agent-b-frontend
cd ~/agent-b-frontend/ae-infinity-ui
# Work on UI components...

# Agent C: Documentation (parallel)
./setup-working-directory.sh ~/agent-c-docs
cd ~/agent-c-docs/ae-infinity-context
# Update specifications...

# Each agent works independently, no conflicts
```

### Workflow 3: Feature Branch Isolation

```bash
# Create workspace for feature branch
./setup-working-directory.sh \
  --branch feature/new-auth \
  ~/workspace-new-auth

# Agent works on feature
cd ~/workspace-new-auth
# Develop, test, iterate...

# When complete, merge feature branch
cd ae-infinity-api
git push origin feature/new-auth
# Create PR, review, merge

# Clean up feature workspace
cd ~
rm -rf ~/workspace-new-auth
```

### Workflow 4: Continuous Integration

```yaml
# .github/workflows/agent-test.yml
name: Agent Integration Test

on: [push, pull_request]

jobs:
  test-agent-workspace:
    runs-on: ubuntu-latest
    steps:
      - name: Clone context repo
        uses: actions/checkout@v3
        with:
          repository: rkSlalom/ae-infinity-context
          
      - name: Setup workspace
        run: |
          ./scripts/setup-working-directory.sh /tmp/ci-workspace
          
      - name: Run tests
        run: |
          cd /tmp/ci-workspace/ae-infinity-api
          dotnet test
          cd /tmp/ci-workspace/ae-infinity-ui
          npm test
```

## 📊 Repository Analysis

### ae-infinity-context
**Role:** Hub / Source of Truth

**Key Files:**
- `PROJECT_SPEC.md` - Project requirements
- `API_SPEC.md` - API contracts
- `ARCHITECTURE.md` - System design
- `COMPONENT_SPEC.md` - UI specifications
- `openspec/` - OpenSpec specs and changes

**Origin:** https://github.com/rkSlalom/ae-infinity-context.git

**Dependencies:** None (documentation only)

**Purpose:**
- Centralize all specifications
- Provide context for AI agents
- Maintain single source of truth
- Enable spec-driven development

### ae-infinity-api
**Role:** Backend Implementation

**Technology Stack:**
- .NET 9.0
- Entity Framework Core
- SQLite (in-memory)
- MediatR (CQRS)
- FluentValidation
- AutoMapper
- JWT Authentication

**Origin:** https://github.com/rkSlalom/ae-infinity-api.git

**Dependencies:**
- .NET 9.0 SDK
- NuGet packages (see .csproj files)

**Architecture:**
- Clean Architecture (4 layers)
- Domain → Application → Infrastructure → API
- CQRS pattern with MediatR
- Repository pattern

**Setup:**
```bash
dotnet restore
dotnet build
cd src/AeInfinity.Api
dotnet run
```

**Ports:**
- HTTP: 5233
- HTTPS: 7184

### ae-infinity-ui
**Role:** Frontend Implementation

**Technology Stack:**
- React 19
- TypeScript 5.9
- Vite 7
- TailwindCSS 3.4
- React Router 7

**Origin:** https://github.com/dallen4/ae-infinity-ui.git

**Dependencies:**
- Node.js 20+
- npm packages (see package.json)

**Architecture:**
- Feature-based organization
- Context API for state
- React Router for navigation
- TailwindCSS for styling

**Setup:**
```bash
npm install
npm run dev
```

**Port:** 5173

## 🔧 Configuration Patterns

### Environment Variables

**UI (.env.local):**
```bash
VITE_API_BASE_URL=http://localhost:5233/api
VITE_API_TIMEOUT=30000
VITE_ENVIRONMENT=development
VITE_DEBUG=true
```

**API (appsettings.json):**
```json
{
  "Jwt": {
    "Secret": "your-secret-key-min-32-characters-long",
    "Issuer": "AeInfinity",
    "Audience": "AeInfinityUsers",
    "ExpirationMinutes": 60
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    }
  }
}
```

### Git Configuration

Each workspace maintains independent git state:
- Separate working trees
- Independent branches
- No shared refs
- Clean commit history

### Dependency Management

**UI Dependencies (npm):**
- Lock file: `package-lock.json`
- Install: `npm install`
- Update: `npm update`

**API Dependencies (dotnet):**
- Lock file: `*.csproj` files
- Install: `dotnet restore`
- Update: `dotnet add package`

## 🎨 Design Decisions

### Why Three Repositories?

**Separation of Concerns:**
- Context: Documentation and specs (language-agnostic)
- API: Backend implementation (.NET)
- UI: Frontend implementation (React)

**Benefits:**
- Independent versioning
- Technology-specific tooling
- Clear boundaries
- Easier access control

**Alternative (Monorepo):**
- Could use single repo with folders
- Rejected: Less flexible for access control
- Rejected: Mixed technology tooling complexity

### Why Scripted Setup?

**Automation Benefits:**
- Consistency across environments
- Reduces human error
- Faster onboarding
- Self-documenting process

**Alternative (Manual Setup):**
- Could document manual steps
- Rejected: Error-prone
- Rejected: Time-consuming
- Rejected: Not reproducible

### Why Clean Workspaces?

**Isolation Benefits:**
- No state pollution
- Safe experimentation
- Easy cleanup
- Parallel development

**Alternative (Shared Workspace):**
- Could use single workspace
- Rejected: Branch conflicts
- Rejected: Dependency conflicts
- Rejected: State management complexity

## 📏 Best Practices

### 1. Workspace Naming

**Pattern:** `{type}-{date}-{feature}`

**Examples:**
```bash
agent-2025-11-05-auth-feature
team-workspace-001
ci-build-1234
feature-new-dashboard
```

### 2. Cleanup Strategy

**When to Clean:**
- After feature completion
- After PR merge
- Failed iterations
- Disk space constraints

**How to Clean:**
```bash
# Quick cleanup
rm -rf ~/workspace-name

# Careful cleanup (preserve work)
cd ~/workspace-name
git status  # Check for uncommitted work
# Save any needed changes
cd ~
rm -rf ~/workspace-name
```

### 3. Branch Strategy

**Main Branch (Stable):**
```bash
./setup-working-directory.sh ~/workspace-stable
```

**Feature Branch (Development):**
```bash
./setup-working-directory.sh \
  --branch feature/new-feature \
  ~/workspace-feature
```

**Multiple Branches (Testing):**
```bash
# Test branch A
./setup-working-directory.sh \
  --branch feature-a \
  ~/workspace-a

# Test branch B  
./setup-working-directory.sh \
  --branch feature-b \
  ~/workspace-b
```

### 4. Resource Management

**Disk Space:**
- Each workspace: ~500MB (with node_modules)
- Monitor disk usage: `du -sh ~/workspace-*`
- Clean old workspaces regularly

**Memory:**
- API: ~100MB RAM
- UI (dev server): ~200MB RAM
- Node modules: ~300MB RAM

**CPU:**
- Compilation: High during build
- Runtime: Low during dev

## 🔍 Troubleshooting

### Common Issues

#### 1. Clone Failures
**Problem:** Git clone fails

**Solutions:**
```bash
# Check internet connection
ping github.com

# Check git credentials
git config --global user.name
git config --global user.email

# Try with verbose output
./setup-working-directory.sh --verbose ~/workspace
```

#### 2. Dependency Installation Failures
**Problem:** npm or dotnet restore fails

**Solutions:**
```bash
# UI: Clear cache and retry
cd ~/workspace/ae-infinity-ui
rm -rf node_modules package-lock.json
npm install

# API: Clean and restore
cd ~/workspace/ae-infinity-api
dotnet clean
dotnet restore
```

#### 3. Permission Denied
**Problem:** Script not executable

**Solution:**
```bash
chmod +x scripts/setup-working-directory.sh
```

#### 4. Port Conflicts
**Problem:** Ports 5233 or 5173 already in use

**Solutions:**
```bash
# Find and kill process
lsof -ti:5233 | xargs kill -9
lsof -ti:5173 | xargs kill -9

# Or change ports in configuration
```

## 📈 Metrics & Monitoring

### Setup Performance

**Typical Timings:**
- Clone repos: 10-30 seconds
- Install UI deps: 30-60 seconds
- Install API deps: 10-20 seconds
- **Total: ~1-2 minutes**

**With --skip-deps:**
- Clone only: 10-30 seconds
- **Total: <1 minute**

### Workspace Size

**Breakdown:**
```
ae-infinity-context/  ~10MB   (docs only)
ae-infinity-api/      ~50MB   (with packages)
ae-infinity-ui/       ~400MB  (with node_modules)
Total:                ~460MB
```

### Success Rate

**Target:** 99% successful setups

**Monitoring:**
- Prerequisites check pass rate
- Clone success rate
- Dependency install success rate
- Health check pass rate

## 🚀 Future Enhancements

### Phase 1: Current (v1.0)
- ✅ Basic workspace setup
- ✅ Dependency installation
- ✅ Health checks
- ✅ Branch selection

### Phase 2: Enhancements
- 🔜 Workspace templates
- 🔜 Custom configurations
- 🔜 Pre-configured git hooks
- 🔜 Auto-start services

### Phase 3: Advanced
- 🔜 Docker containerization
- 🔜 Cloud workspace support
- 🔜 Workspace sharing
- 🔜 State persistence

### Phase 4: Integration
- 🔜 CI/CD templates
- 🔜 VSCode/Cursor integration
- 🔜 Agent orchestration
- 🔜 Metrics dashboard

## 🔗 Related Documentation

- [Setup Script README](../scripts/README.md)
- [OpenSpec Cross-Repo Setup](../openspec/CROSS_REPO_SETUP.md)
- [Development Guide](../DEVELOPMENT_GUIDE.md)
- [Architecture](../ARCHITECTURE.md)

## 💡 Key Takeaways

1. **Reproducibility** - Same setup every time
2. **Isolation** - Independent workspaces
3. **Automation** - One command setup
4. **Flexibility** - Configurable options
5. **Safety** - No shared state issues

## 📮 Feedback & Contributions

This pattern is designed to evolve based on usage. Please provide feedback on:
- Setup time and performance
- Common issues encountered
- Feature requests
- Integration needs

---

**Version:** 1.0.0  
**Maintained by:** AE Infinity Team  
**Last Updated:** November 5, 2025

