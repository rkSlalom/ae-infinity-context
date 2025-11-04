# AE Infinity - Context Repository

**Version**: 1.0  
**Last Updated**: November 3, 2025  
**Repository Type**: Specification & Documentation (Source of Truth)

This repository contains all specifications, architecture decisions, and documentation for the AE Infinity collaborative shopping list application. It serves as the **single source of truth** for spec-driven development.

---

## 📋 What is This?

This is **NOT** a code repository. This is the **specification and documentation repository** that drives development of:

- **Backend API**: `ae-infinity-api` (.NET 8 Web API)
- **Frontend UI**: `ae-infinity-ui` (React + TypeScript + Vite)

All features are **specified here first**, then implemented in the respective code repositories.

---

## 🎯 Purpose: Spec-Driven Development

We follow a **specification-first** approach:

```
1. Write/Update SPEC → 2. Implement Code → 3. Mark as Implemented → 4. Integration Test
   (This Repo)          (Code Repos)         (Update This Repo)       (Both Connected)
```

### Benefits

- **Single Source of Truth** - All teams reference the same specs
- **Clear Requirements** - Features are fully specified before coding begins
- **Change Management** - Spec changes are tracked in git
- **Documentation Always Current** - Specs evolve with the project
- **Easy Onboarding** - New developers read specs to understand the system

---

## 📚 Documentation Structure

This repository follows **Specification-Driven Development (SDD)** with a clean, organized structure:

### 📖 [docs/](./docs/) - Project Documentation
Comprehensive project documentation organized by topic.

| Section | Description |
|---------|-------------|
| [docs/project/](./docs/project/) | Core project specs, architecture, features tracker |
| [docs/api/](./docs/api/) | API specifications, component specs, data models |
| [docs/personas/](./docs/personas/) | User personas and permission matrix |
| [docs/journeys/](./docs/journeys/) | User journey maps and workflows |

**Start here**: [docs/README.md](./docs/README.md)

---

### 🎯 [specs/](./specs/) - Feature Specifications
SDD-compliant feature specifications from planning to delivery.

| Section | Description |
|---------|-------------|
| [specs/active/](./specs/active/) | Features currently in development |
| [specs/backlog/](./specs/backlog/) | Planned features |
| [specs/completed/](./specs/completed/) | Delivered features |
| [specs/archive/](./specs/archive/) | Reference material and legacy docs |

**Start here**: [specs/README.md](./specs/README.md)

---

## 🚀 Quick Links

### For New Team Members
1. 📋 [Project Specification](./docs/project/PROJECT_SPEC.md) - What we're building
2. 🏗️ [Architecture](./docs/project/ARCHITECTURE.md) - How it's structured
3. 💻 [Development Guide](./docs/project/DEVELOPMENT_GUIDE.md) - Setup and workflow
4. ✅ [Features Tracker](./docs/project/FEATURES.md) - Implementation status

### For Developers
- 🔌 [API Specification](./docs/api/API_SPEC.md) - REST API contracts
- 🗄️ [Data Models](./docs/api/data-models.md) - Database schema
- 🎨 [Component Spec](./docs/api/COMPONENT_SPEC.md) - UI components
- 📐 [Feature Specs](./specs/) - Detailed feature specifications

### For Product/Design
- 👥 [User Personas](./docs/personas/) - Who are our users?
- 🗺️ [User Journeys](./docs/journeys/) - How do users accomplish goals?
- ✨ [Features Tracker](./docs/project/FEATURES.md) - What's implemented?
- 🎯 [Active Features](./specs/active/) - What's in development?

---

## 🔄 Workflow

### Adding a New Feature

1. **Specify** the feature in this repo
   - Update `FEATURES.md` (add to tracker)
   - Update relevant spec docs (API_SPEC.md, COMPONENT_SPEC.md, etc.)
   - Commit with message: `spec: Add feature X specification`

2. **Implement** in code repos
   - Backend: `ae-infinity-api`
   - Frontend: `ae-infinity-ui`
   - Commit with message: `feat: Implement feature X`

3. **Update Implementation Status** in this repo
   - Update `FEATURES.md` (mark as ✅ or 🟡)
   - Update `ARCHITECTURE.md` (add to implementation details)
   - Commit with message: `docs: Mark feature X as implemented`

4. **Integration** 
   - Connect frontend to backend
   - Update `FEATURES.md` (mark integration complete)
   - Commit with message: `docs: Feature X fully integrated`

### Updating Existing Features

1. **Update the Spec First**
   - Modify the specification
   - Note breaking changes
   - Commit: `spec: Update feature X - breaking change`

2. **Implement Changes**
   - Update backend/frontend code
   - Commit in code repos

3. **Sync Documentation**
   - Update implementation notes
   - Commit: `docs: Sync feature X changes`

### When Specs Drift from Reality

If you discover the implementation doesn't match the spec:

1. **Decide**: Should code change to match spec, or spec change to match code?
2. **Document**: Add note in ARCHITECTURE.md about the deviation
3. **Update**: Modify either spec or code to align
4. **Commit**: Clear commit message explaining the sync

---

## 📊 Status Indicators

Throughout this repository, you'll see status indicators:

- ✅ **Complete** - Fully implemented, tested, and integrated
- 🟡 **Partial** - Implemented but needs integration or using mock data
- ❌ **Not Started** - Specified but not yet implemented
- 🚧 **In Progress** - Currently being worked on
- 🔜 **Planned** - Specified and prioritized for upcoming sprint

---

## 🏗️ Repository Structure

```
ae-infinity-context/
├── README.md                    # This file - start here!
│
├── docs/                        # 📚 Project Documentation
│   ├── README.md               # Documentation navigation
│   ├── project/                # Core project docs
│   │   ├── PROJECT_SPEC.md
│   │   ├── ARCHITECTURE.md
│   │   ├── DEVELOPMENT_GUIDE.md
│   │   └── FEATURES.md
│   ├── api/                    # API specifications
│   │   ├── API_SPEC.md
│   │   ├── COMPONENT_SPEC.md
│   │   └── data-models.md
│   ├── personas/               # User personas
│   │   ├── list-creator.md
│   │   ├── active-collaborator.md
│   │   ├── passive-viewer.md
│   │   └── permission-matrix.md
│   └── journeys/               # User journey maps
│       ├── creating-first-list.md
│       └── shopping-together.md
│
├── specs/                       # 🎯 SDD Feature Specifications
│   ├── README.md               # Specs navigation
│   ├── index.json              # Machine-readable registry
│   ├── active/                 # In development
│   │   └── feat-001-live-updates/
│   ├── backlog/                # Planned features
│   ├── completed/              # Delivered features
│   └── archive/                # Reference material
│       └── features/           # Legacy feature docs
│
├── .sdd/                        # ⚙️ SDD Framework
│   ├── guidelines.md
│   ├── templates/
│   └── config.json
│
└── .cursor/                     # 🤖 Cursor Commands
    └── commands/
```

---

## 🎯 Current State

**Project Version**: 1.0 (Development Phase)

### Implementation Progress
- **Backend API**: 80% complete
- **Frontend UI**: 85% complete
- **Integration**: 0% complete (ready to start)
- **Real-time**: 0% complete (SignalR not started)

See [FEATURES.md](./FEATURES.md) for detailed breakdown.

### What's Ready
- ✅ Complete type system (Frontend)
- ✅ All API service layers (Frontend)
- ✅ All CRUD endpoints (Backend)
- ✅ All UI pages (Frontend)
- ✅ Authentication flow (Backend + Frontend)

### What's Next
1. **Connect frontend to backend** - Replace mock data with real API calls
2. **Complete missing endpoints** - Registration, password reset
3. **Add SignalR** - Real-time features
4. **Polish** - Error handling, loading states, optimistic updates

---

## 🤝 Contributing

### For Developers

1. **Always read the spec first** before implementing
2. **Ask questions** if the spec is unclear (update spec with clarification)
3. **Update status** when you complete implementation
4. **Document deviations** when you must deviate from spec

### For Product/Design

1. **Update specs** when requirements change
2. **Provide context** in commit messages
3. **Version major changes** to track evolution
4. **Link to designs** when adding UI specs

### Commit Message Convention

```
spec: Add/Update/Remove feature specification
docs: Update documentation or implementation status
fix: Correct errors in specifications
refactor: Reorganize documentation structure
```

---

## 📖 Quick Start

### I'm New to This Project

1. Read [Project Specification](./docs/project/PROJECT_SPEC.md) - Understand what we're building
2. Read [Architecture](./docs/project/ARCHITECTURE.md) - Understand how it's structured
3. Check [Features Tracker](./docs/project/FEATURES.md) - See what's implemented
4. Follow [Development Guide](./docs/project/DEVELOPMENT_GUIDE.md) - Set up your environment

### I'm Adding a New Feature

**Quick Start (Most Features)**:
```bash
# Use SDD brief for rapid planning
/brief "Your feature description"
```

**Comprehensive Planning (Complex Features)**:
1. Navigate to [specs/](./specs/)
2. Create feature folder in `specs/active/`
3. Follow SDD workflow: research → specify → plan → tasks → implement
4. Use templates from [.sdd/templates/](./.sdd/templates/)
5. Update [specs/README.md](./specs/README.md) and [index.json](./specs/index.json)

### I'm Implementing a Feature

1. Check [specs/active/](./specs/active/) for feature specification
2. Review [API Specification](./docs/api/API_SPEC.md) for endpoints needed
3. Follow [Development Guide](./docs/project/DEVELOPMENT_GUIDE.md) for workflow
4. Update [Features Tracker](./docs/project/FEATURES.md) as you progress
5. Update spec status when complete

---

## 🔗 Related Repositories

- **Backend API**: [ae-infinity-api](../ae-infinity-api/) - .NET 8 Web API
- **Frontend UI**: [ae-infinity-ui](../ae-infinity-ui/) - React + TypeScript + Vite

---

## 📝 License

Internal project for Slalom AE Immersion Workshop

---

## 💬 Questions?

- **Spec unclear?** Open an issue or submit a PR to clarify
- **Found a bug in specs?** Submit a PR with the fix
- **Need architectural decision?** Discuss and document in ARCHITECTURE.md

---

**Remember**: This repo is the source of truth. When in doubt, check here first! 🎯
