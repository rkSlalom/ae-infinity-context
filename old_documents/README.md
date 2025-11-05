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

### **What Happened?**

On November 5, 2025, we transitioned from a monolithic documentation approach to **Spec Kit SDD**, which provides:
- ✅ **Feature-driven specifications** - Each feature has its own complete specification
- ✅ **AI-friendly context** - Specifications designed to work with AI coding assistants
- ✅ **Structured workflow** - `/speckit.specify`, `/speckit.plan`, `/speckit.tasks` commands
- ✅ **Quality gates** - Constitution-based development standards
- ✅ **Test-driven** - TDD approach with 80% coverage requirement

### **What Changed?**

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

### **Root Documentation** (NEW)

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

### **Constitution** (NEW)

The project constitution defines development principles and quality gates:
- **Location**: [/.specify/memory/constitution.md](../.specify/memory/constitution.md)
- **Purpose**: Core principles, technical standards, quality gates, governance

### **Feature Specifications** (NEW)

Each feature has a complete specification package:

**Location**: `/specs/XXX-feature-name/`

**Files per feature**:
- `README.md` - Quick overview
- `spec.md` - Business requirements (user stories, acceptance scenarios)
- `plan.md` - Implementation strategy (technical approach, phases)
- `data-model.md` - Entity definitions, DTOs, database schema
- `quickstart.md` - Developer guide with code examples
- `tasks.md` - Implementation checklist
- `contracts/` - API JSON schemas
- `checklists/requirements.md` - Quality validation

**Completed Features**:
- [Feature 001: User Authentication](../specs/001-user-authentication/)
- [Feature 002: User Profile Management](../specs/002-user-profile-management/)

**Feature Catalog**: [/specs/README.md](../specs/README.md)

---

## 🗂️ Archived Files Reference

### **Old Root Files** → **New Locations**

| Old File | Migrated To | Notes |
|----------|-------------|-------|
| `README.md` | [/README.md](../README.md) | Rewritten for Spec Kit |
| `ARCHITECTURE.md` | [/ARCHITECTURE.md](../ARCHITECTURE.md) | Updated for .NET 9.0, SQLite |
| `CHANGELOG.md` | [/CHANGELOG.md](../CHANGELOG.md) | Updated with Spec Kit adoption |
| `FEATURES.md` | [/specs/README.md](../specs/README.md) | Feature catalog |
| `API_SPEC.md` | [/API_REFERENCE.md](../API_REFERENCE.md) | API overview + per-feature contracts |
| `PROJECT_SPEC.md` | Split into feature specs | See `/specs/XXX-*/spec.md` |
| `DEVELOPMENT_GUIDE.md` | [/GETTING_STARTED.md](../GETTING_STARTED.md) + [/CONTRIBUTING.md](../CONTRIBUTING.md) | Split into setup + workflow |
| `COMPONENT_SPEC.md` | Future feature specs | To be created per feature |
| `data-models.md` | Per-feature `data-model.md` | See `/specs/XXX-*/data-model.md` |

### **Old Directories** → **New Locations**

| Old Directory | Migrated To | Notes |
|---------------|-------------|-------|
| `schemas/` | Per-feature `contracts/` | e.g., `/specs/001-user-authentication/contracts/` |
| `features/` | `/specs/` | Feature-based organization |
| `journeys/` | Per-feature `spec.md` | User stories in each feature spec |
| `personas/` | Per-feature `spec.md` | User scenarios in each feature spec |
| `openspec/` | `/.specify/` | Spec Kit configuration and templates |
| `docs/` | Root documentation | Promoted to root level |

---

## 📖 How to Use Archived Files

### **When to Reference Old Documents**

✅ **Historical context** - Understand past decisions
✅ **Migration verification** - Ensure nothing was missed
✅ **Content consolidation** - When creating new feature specs

❌ **Don't use for**:
- Current development (use new specs)
- API contracts (use new contracts/)
- Architecture decisions (use new plan.md files)
- Development workflow (use new CONTRIBUTING.md)

### **Example: Creating Feature 003 Specification**

When specifying Feature 003 (Shopping Lists CRUD), reference:
1. ✅ `old_documents/API_SPEC.md` - List endpoints
2. ✅ `old_documents/schemas/list*.json` - Previous list schemas
3. ✅ `old_documents/FEATURES.md` - Feature description
4. ✅ `old_documents/journeys/creating-first-list.md` - User journey

Then generate new specification:
```bash
/speckit.specify "Shopping lists CRUD with create, read, update, delete, and archive"
```

This will create `/specs/003-shopping-lists-crud/` with all necessary files.

---

## 🔍 Archived File Index

### **Root Level**
- `README.md` - Old project README (superseded)
- `ARCHITECTURE.md` - Old architecture docs (superseded)
- `CHANGELOG.md` - Old changelog (merged)
- `FEATURES.md` - Old feature list (superseded by specs/README.md)
- `API_SPEC.md` - Old API docs (superseded by API_REFERENCE.md + contracts/)
- `PROJECT_SPEC.md` - Old project spec (split into feature specs)
- `DEVELOPMENT_GUIDE.md` - Old dev guide (superseded by GETTING_STARTED.md)
- `COMPONENT_SPEC.md` - Old UI component specs (to be feature-based)
- `data-models.md` - Old data models (now per-feature data-model.md)
- `AGENTS.md` - OpenSpec agent instructions (migrated to .specify/)
- `CLAUDE.md` - AI assistant instructions (migrated to .specify/)

### **schemas/** (46 JSON files)
All schema files migrated to per-feature `contracts/` directories:
- `user*.json` → `/specs/001-user-authentication/contracts/`
- `list*.json` → Future `/specs/003-shopping-lists-crud/contracts/`
- `item*.json` → Future `/specs/004-list-items-management/contracts/`
- `category.json` → Future `/specs/005-categories-system/contracts/`
- `collaborator.json`, `invitation.json` → Future `/specs/008-invitations-permissions/contracts/`
- `search-result.json` → Future `/specs/006-basic-search/contracts/`

### **features/** (9 feature folders)
Feature documentation migrated to `/specs/XXX-feature-name/`:
- `authentication/` → `/specs/001-user-authentication/`
- `lists/` → Future `/specs/003-shopping-lists-crud/`
- `items/` → Future `/specs/004-list-items-management/`
- `categories/` → Future `/specs/005-categories-system/`
- `search/` → Future `/specs/006-basic-search/`
- `collaboration/` → Future `/specs/007-real-time-collaboration/`
- `realtime/` → Future `/specs/007-real-time-collaboration/`
- `ui-components/` → To be feature-specific
- `infrastructure/` → Architecture documentation

### **journeys/** (3 user journey files)
User journeys migrated to feature `spec.md` files:
- `creating-first-list.md` → Future `/specs/003-shopping-lists-crud/spec.md`
- `shopping-together.md` → Future `/specs/007-real-time-collaboration/spec.md`

### **personas/** (5 persona files)
Personas consolidated into feature specifications:
- `list-creator.md` → Referenced in feature specs
- `active-collaborator.md` → Referenced in collaboration specs
- `passive-viewer.md` → Referenced in collaboration specs
- `permission-matrix.md` → Preserved in ARCHITECTURE.md and feature plans

### **openspec/** (OpenSpec methodology)
OpenSpec files migrated to `.specify/`:
- `AGENTS.md` → `/.specify/templates/`
- `CROSS_REPO_SETUP.md` → Constitution
- `project.md` → Constitution + README
- `QUICK_REFERENCE.md` → Per-feature quickstart.md
- `specs/` → `/specs/` (new structure)
- `doctor/` → `.specify/scripts/`

### **docs/** (Reference documentation)
Documentation promoted to root level:
- `CROSS_REPO_REFERENCES.md` → ROOT_REFERENCE section in root docs
- `README.md` → Merged into root README.md
- `REFERENCE_EXAMPLES.md` → Per-feature quickstart.md

---

## 🚀 Next Steps for Developers

### **If You're New to the Project**
1. **Start here**: [/README.md](../README.md) - Get project overview
2. **Quick setup**: [/GETTING_STARTED.md](../GETTING_STARTED.md) - Running in 5-10 minutes
3. **Learn workflow**: [/CONTRIBUTING.md](../CONTRIBUTING.md) - How we work with Spec Kit
4. **Review constitution**: [/.specify/memory/constitution.md](../.specify/memory/constitution.md) - Development principles

### **If You're Continuing Development**
1. **Review feature catalog**: [/specs/README.md](../specs/README.md) - See all features
2. **Pick a feature**: See `specs/XXX-feature/tasks.md` for implementation tasks
3. **Follow quickstart**: Each feature has step-by-step guide
4. **Use Spec Kit commands**: `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`

### **If You're Specifying New Features**
1. **Check old docs** in this folder for reference content
2. **Run**: `/speckit.specify "feature description"`
3. **Review generated spec**: `specs/XXX-feature/spec.md`
4. **Consolidate old content**: Integrate relevant old docs into new spec
5. **Generate plan**: `/speckit.plan XXX-feature`
6. **Break down tasks**: `/speckit.tasks XXX-feature`

---

## 📞 Questions?

- **About old documents**: This README or search within `old_documents/`
- **About new structure**: See [/README.md](../README.md)
- **About Spec Kit**: See [/CONTRIBUTING.md](../CONTRIBUTING.md)
- **About architecture**: See [/ARCHITECTURE.md](../ARCHITECTURE.md)
- **About specific features**: See `/specs/XXX-feature/README.md`

---

## 📊 Archive Statistics

| Category | Count | Status |
|----------|-------|--------|
| Root markdown files | 11 | ✅ Archived |
| Feature directories | 9 | ✅ Migrated to specs/ |
| JSON schemas | 28 | ✅ Migrated to contracts/ |
| User journeys | 3 | ✅ Consolidated into specs |
| Personas | 5 | ✅ Integrated into specs |
| OpenSpec files | 7 | ✅ Migrated to .specify/ |
| Documentation pages | 12 | ✅ Migrated to root |
| **Total archived files** | **75+** | ✅ Complete |

---

**Archive Maintained For**: Historical reference, migration verification, content consolidation

**Last Updated**: November 5, 2025

**Migration Status**: ✅ Complete - All active documentation migrated to Spec Kit structure
