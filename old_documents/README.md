# 📦 Archived Documentation

**Archived Date**: November 5, 2025  
**Reason**: Migration to Spec Kit SDD methodology  
**Status**: Preserved for reference only

---

## ⚠️ Important Notice

**These documents are archived and no longer maintained.**

The project has adopted **Spec Kit SDD** (Specification-Driven Development) methodology with a new documentation structure. All active documentation has been migrated to the new format.

**For current documentation, see the root folder and `specs/` directory.**

---

## 🔄 Migration Summary

### What Happened?

On November 5, 2025, we transitioned from a monolithic documentation approach to **Spec Kit SDD**, which provides:
- ✅ **Feature-driven specifications** - Each feature has its own complete specification
- ✅ **AI-friendly context** - Specifications designed to work with AI coding assistants
- ✅ **Structured workflow** - `/speckit.specify`, `/speckit.plan`, `/speckit.tasks` commands
- ✅ **Quality gates** - Constitution-based development standards
- ✅ **Test-driven** - TDD approach with 80% coverage requirement

### What Changed?

| Old Structure | New Structure | Status |
|---------------|---------------|--------|
| Single `README.md` | Root `README.md` + per-feature READMEs | ✅ Migrated |
| Single `ARCHITECTURE.md` | Root `ARCHITECTURE.md` + per-feature `plan.md` | ✅ Migrated |
| Single `API_SPEC.md` | Per-feature `contracts/` directories | ✅ Migrated |
| Global `schemas/` folder | Per-feature `contracts/` with JSON schemas | ✅ Migrated |
| Single `FEATURES.md` | `specs/README.md` feature catalog | ✅ Migrated |
| Multiple scattered docs | Constitution + root docs + feature specs | ✅ Migrated |

---

## 📂 Where to Find Current Documentation

### Root Documentation

| Document | Purpose | Location |
|----------|---------|----------|
| **README.md** | Project overview and navigation hub | [/README.md](../README.md) |
| **GETTING_STARTED.md** | Quick start guide (5-10 min setup) | [/GETTING_STARTED.md](../GETTING_STARTED.md) |
| **CONTRIBUTING.md** | Development workflow and standards | [/CONTRIBUTING.md](../CONTRIBUTING.md) |
| **ARCHITECTURE.md** | System architecture overview | [/ARCHITECTURE.md](../ARCHITECTURE.md) |
| **CHANGELOG.md** | Project history and updates | [/CHANGELOG.md](../CHANGELOG.md) |
| **ROADMAP.md** | Product roadmap (Q4 2025 - Q3 2026) | [/ROADMAP.md](../ROADMAP.md) |
| **API_REFERENCE.md** | API endpoints and contracts | [/API_REFERENCE.md](../API_REFERENCE.md) |
| **TESTING_GUIDE.md** | Comprehensive testing standards | [/TESTING_GUIDE.md](../TESTING_GUIDE.md) |

### Constitution

| Document | Purpose | Location |
|----------|---------|----------|
| **constitution.md** | Project-wide quality standards | [/constitution.md](../constitution.md) |

### Feature Specifications

All feature specifications are now in the `/specs/` directory:

```
specs/
├── README.md                    # Feature catalog
├── authentication/              # User authentication feature
├── lists/                       # Shopping lists feature
├── items/                       # List items feature
├── collaboration/               # Sharing and permissions
└── [other features]/
```

Each feature directory contains:
- **README.md** - Feature specification
- **plan.md** - Technical implementation plan
- **contracts/** - API contracts and JSON schemas
- **tests/** - Test specifications

---

## 📋 Archived Contents

This directory contains the old documentation structure for historical reference:

### Archived Files

- Old README.md content
- Previous .cursor/commands/
- Old setup scripts
- Legacy documentation files

### Why Archive?

These documents are kept for:
1. **Historical reference** - Understanding past decisions
2. **Migration tracking** - Seeing what changed and why
3. **Rollback safety** - Preserved in case needed

---

## 🚀 Getting Started (New Way)

### For New Developers

1. Read [/GETTING_STARTED.md](../GETTING_STARTED.md)
2. Review [/constitution.md](../constitution.md)
3. Browse [/specs/README.md](../specs/README.md) for features

### For AI Agents

1. Load [/constitution.md](../constitution.md)
2. Use `/speckit.specify [feature]` to load feature specs
3. Use `/speckit.plan [feature]` for implementation plans
4. Use `/speckit.tasks [feature]` for task breakdown

### Quick Commands

```bash
# Setup environment
npm install  # or yarn install

# Run development servers
npm run dev:api    # Backend API
npm run dev:ui     # Frontend UI

# Run tests
npm test

# Use Spec Kit commands in Cursor
/speckit.specify authentication
/speckit.plan authentication
/speckit.tasks authentication
```

---

## 📞 Need Help?

### Current Documentation
- 📖 Start with [/README.md](../README.md)
- 🚀 Quick setup: [/GETTING_STARTED.md](../GETTING_STARTED.md)
- 🏗️ Architecture: [/ARCHITECTURE.md](../ARCHITECTURE.md)
- 📋 Features: [/specs/README.md](../specs/README.md)

### Questions?

If you need clarification on the migration or archived content, refer to:
- [/CHANGELOG.md](../CHANGELOG.md) - Migration details
- [/CONTRIBUTING.md](../CONTRIBUTING.md) - New development workflow

---

## 🗂️ Archive Note

**Do not modify files in this directory.**

This is a read-only archive. All updates should be made to the new documentation structure in the root and `/specs/` directories.

If you believe something from the archive should be restored, please:
1. Open an issue explaining what and why
2. Propose where it fits in the new structure
3. Submit a PR with the migration

---

**Last Updated**: November 5, 2025  
**Migration Version**: 1.0  
**Archive Status**: Complete ✅
