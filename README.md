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

## 📚 Key Documents

### Core Specifications

| Document | Purpose | When to Update |
|----------|---------|----------------|
| [PROJECT_SPEC.md](./PROJECT_SPEC.md) | High-level project requirements and goals | When adding major features or changing project scope |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System architecture, tech stack, and implementation details | When architectural decisions change or implementations are completed |
| [API_SPEC.md](./API_SPEC.md) | Complete REST API contract and SignalR events | When adding/modifying API endpoints |
| [COMPONENT_SPEC.md](./COMPONENT_SPEC.md) | UI component library specifications | When designing new UI components |
| [FEATURES.md](./FEATURES.md) | Master feature tracker with implementation status | After each feature is implemented or integrated |

### Feature-Specific Documentation

| Directory | Purpose |
|-----------|---------|
| [features/](./features/) | **Feature-driven documentation** - Each feature domain has its own directory with detailed specs, implementation details, and integration steps |
| [features/authentication/](./features/authentication/) | Authentication & user management |
| [features/lists/](./features/lists/) | Shopping list CRUD operations |
| [features/items/](./features/items/) | Shopping item management |
| [features/collaboration/](./features/collaboration/) | List sharing & permissions |
| [features/categories/](./features/categories/) | Item categorization |
| [features/search/](./features/search/) | Global search functionality |
| [features/realtime/](./features/realtime/) | SignalR live updates |
| [features/ui-components/](./features/ui-components/) | UI component library |
| [features/infrastructure/](./features/infrastructure/) | DevOps & cross-cutting concerns |

### Data & Domain

| Document | Purpose |
|----------|---------|
| [DB_SCHEMA.md](./docs/DB_SCHEMA.md) | Database schema and relationships |
| [architecture/data-models.md](./architecture/data-models.md) | Domain model definitions |

### User-Centric

| Document | Purpose |
|----------|---------|
| [USER_PERSONAS.md](./USER_PERSONAS.md) | User types and their needs |
| [personas/permission-matrix.md](./personas/permission-matrix.md) | Permission levels and capabilities |
| [journeys/](./journeys/) | User journey maps and flows |

### Development Guides

| Document | Purpose |
|----------|---------|
| [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) | How to set up and develop |
| [API_INTEGRATION_GUIDE.md](./docs/API_INTEGRATION_GUIDE.md) | How to integrate frontend with backend |

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
├── README.md                  # This file - start here!
├── FEATURES.md               # Master feature tracker
├── PROJECT_SPEC.md           # High-level project requirements
├── ARCHITECTURE.md           # System architecture + implementation
├── API_SPEC.md              # REST API specification
├── COMPONENT_SPEC.md        # UI component specifications
├── USER_PERSONAS.md         # User types and needs
├── DEVELOPMENT_GUIDE.md     # Setup and development guide
│
├── architecture/            # Detailed architecture docs
│   ├── data-models.md
│   └── README.md
│
├── personas/               # User persona details
│   ├── permission-matrix.md
│   └── *.md
│
├── journeys/              # User journey maps
│   ├── creating-first-list.md
│   └── *.md
│
├── docs/                  # Additional documentation
│   ├── API_INTEGRATION_GUIDE.md
│   └── DB_SCHEMA.md
│
└── api/                   # API-specific docs
    └── README.md
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

1. Read [PROJECT_SPEC.md](./PROJECT_SPEC.md) - Understand what we're building
2. Read [ARCHITECTURE.md](./ARCHITECTURE.md) - Understand how it's structured
3. Read [FEATURES.md](./FEATURES.md) - See what's implemented
4. Read [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - Set up your environment

### I'm Adding a New Feature

1. Open [FEATURES.md](./FEATURES.md) - Add your feature to the tracker
2. Update relevant spec files - API_SPEC.md, COMPONENT_SPEC.md, etc.
3. Commit your spec changes
4. Implement in code repos
5. Come back and mark as implemented

### I'm Connecting Frontend to Backend

1. Read [API_INTEGRATION_GUIDE.md](./docs/API_INTEGRATION_GUIDE.md)
2. Check [API_SPEC.md](./API_SPEC.md) for endpoint contracts
3. Update [ARCHITECTURE.md](./ARCHITECTURE.md) as you integrate
4. Mark features as integrated in [FEATURES.md](./FEATURES.md)

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
