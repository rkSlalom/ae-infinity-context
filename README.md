# AE Infinity - Context Repository

**Version**: 1.0  
**Last Updated**: November 3, 2025  
**Repository Type**: Specification & Documentation (Source of Truth)

## 🆕 Recent Updates

### Authentication System (2025-11-03 PM)
**✅ Full authentication documentation now available!** The backend API has implemented JWT-based authentication. All relevant docs have been updated:

- **[API_SPEC.md](./API_SPEC.md)** - Login, logout, and user endpoints fully documented
- **[GLOSSARY.md](./GLOSSARY.md)** - Authentication & security terminology added
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Complete security architecture section
- **UI Docs** - Integration guide with TypeScript examples

**Ready to use**:
- `POST /api/auth/login` - JWT token authentication
- `POST /api/auth/logout` - Session cleanup
- `GET /api/users/me` - Current user profile
- **Test users**: sarah@example.com, alex@example.com, mike@example.com (Password: `Password123!`)

See **[CHANGELOG.md](./CHANGELOG.md)** for complete details.

---

## 🎯 Purpose

This repository contains comprehensive, granular documentation that enables:
- **Spec-driven development** - Build features based on complete specifications
- **AI-assisted coding** - Provide precise context to LLMs and coding assistants
- **Cross-functional alignment** - Shared understanding across product, design, and engineering
- **Knowledge preservation** - Maintain institutional knowledge in structured format

## 📚 Documentation Structure

### 👥 [Personas](./personas/)
Detailed user personas with needs, goals, and permission levels

- **[list-creator.md](./personas/list-creator.md)** - Owner persona (Sarah) - Full control over lists
- **[active-collaborator.md](./personas/active-collaborator.md)** - Editor persona (Mike) - Actively manages items
- **[passive-viewer.md](./personas/passive-viewer.md)** - Viewer persona (Emma) - Read-only access
- **[permission-matrix.md](./personas/permission-matrix.md)** - Complete permission comparison

### 🗺️ [Journeys](./journeys/)
Step-by-step user workflows showing how personas accomplish goals

- **[creating-first-list.md](./journeys/creating-first-list.md)** - First-time user onboarding
- **[sharing-list.md](./journeys/sharing-list.md)** - Sharing lists with collaborators
- **[shopping-together.md](./journeys/shopping-together.md)** - Real-time collaborative shopping
- **[managing-permissions.md](./journeys/managing-permissions.md)** - Managing list access

### 🔌 [API](./api/)
REST API specifications split by domain (Coming Soon - see API_SPEC.md for now)

- **authentication.md** - Auth endpoints and JWT handling
- **lists.md** - Shopping list CRUD operations
- **items.md** - Shopping item management
- **categories.md** - Category endpoints
- **search.md** - Search functionality
- **realtime-events.md** - SignalR events and subscriptions
- **error-handling.md** - Error response formats

### 🏗️ [Architecture](./architecture/)
System architecture and technical decisions (Coming Soon - see ARCHITECTURE.md for now)

- **system-overview.md** - High-level system architecture
- **frontend-architecture.md** - React application structure
- **backend-architecture.md** - .NET API structure
- **data-models.md** - Database schemas and relationships
- **state-management.md** - Frontend state patterns
- **realtime-strategy.md** - SignalR implementation details
- **security.md** - Security architecture and auth flow
- **performance.md** - Performance optimization strategies
- **offline-sync.md** - Offline support and synchronization

### 🎨 [Components](./components/)
UI component specifications and design system (Coming Soon - see COMPONENT_SPEC.md for now)

- **design-system.md** - Colors, typography, spacing, and design tokens
- **common-components.md** - Reusable components (Button, Input, Modal)
- **list-components.md** - List-specific UI components
- **item-components.md** - Item-specific UI components
- **layout-components.md** - Layout and navigation components

### ⚙️ [Config](./config/)
Configuration documentation (Coming Soon)

- **environment-variables.md** - Environment variable reference
- **deployment-config.md** - Deployment configurations
- **feature-flags.md** - Feature toggle system

### 📋 [Schemas](./schemas/)
JSON Schema definitions for API contracts

- **Authentication** - Login request/response schemas
- **Users** - User profile and stats schemas
- **Lists** - List and list detail schemas
- **Items** - Item schemas with categories
- **Collaboration** - Collaborator and invitation schemas
- **Search** - Search result schemas with pagination

## 📖 Core Documents

These documents provide project-wide context:

- **[PROJECT_SPEC.md](./PROJECT_SPEC.md)** - Complete project requirements and features
- **[API_SPEC.md](./API_SPEC.md)** - Full REST API specification (to be split into api/)
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture (to be split into architecture/)
- **[COMPONENT_SPEC.md](./COMPONENT_SPEC.md)** - UI components (to be split into components/)
- **[USER_PERSONAS.md](./USER_PERSONAS.md)** - Original personas document (replaced by personas/)
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - Development workflow
- **[GLOSSARY.md](./GLOSSARY.md)** - ✅ **NEW** - Terminology and jargon reference
- **[QUICK_START.md](./QUICK_START.md)** - Quick start guide

## 🚀 Quick Start

### For Developers

1. **Start with** [PROJECT_SPEC.md](./PROJECT_SPEC.md) for project overview
2. **Understand users** via [personas/](./personas/)
3. **Review workflows** in [journeys/](./journeys/)
4. **Check API contracts** in [API_SPEC.md](./API_SPEC.md) (or api/ when available)
5. **Follow architecture** in [ARCHITECTURE.md](./ARCHITECTURE.md) (or architecture/ when available)
6. **Build UI** per [COMPONENT_SPEC.md](./COMPONENT_SPEC.md) (or components/ when available)

### For AI/LLM Agents

**Context Loading Pattern**:
```
1. Load PROJECT_SPEC.md for project overview
2. Load relevant persona from personas/
3. Load relevant journey from journeys/
4. Load API specification for endpoints needed
5. Load architecture docs for patterns
6. Generate code following specifications
```

**Example Prompt**:
```
Context:
- Persona: personas/active-collaborator.md
- Journey: journeys/shopping-together.md  
- API: API_SPEC.md#shopping-items-endpoints
- Architecture: ARCHITECTURE.md#state-management-strategy

Task: Implement real-time item purchase toggle with optimistic updates
```

### For Designers

1. **Research users** in [personas/](./personas/)
2. **Map workflows** from [journeys/](./journeys/)
3. **Follow design system** in [COMPONENT_SPEC.md](./COMPONENT_SPEC.md)
4. **Reference API data** in [API_SPEC.md](./API_SPEC.md) for data structures

### For Product Managers

1. **Review** [PROJECT_SPEC.md](./PROJECT_SPEC.md) for requirements
2. **Understand users** via [personas/](./personas/)
3. **Analyze workflows** in [journeys/](./journeys/)
4. **Plan features** based on user needs and technical constraints

## 🎨 What Makes This Different

### Spec-Driven Development
Every feature starts with comprehensive specifications before implementation.

### LLM-Optimized
Documentation structured for easy consumption by AI coding assistants like Cursor, GitHub Copilot, and ChatGPT.

### Granular & Cross-Referenced
Small, focused files that link to related content. No monolithic documents.

### Single Source of Truth
All product, design, and technical decisions documented here.

### Living Documentation
Continuously updated as project evolves.

## 📊 Documentation Principles

1. **Completeness**: Every feature fully specified before implementation
2. **Precision**: Exact API contracts, data models, and workflows
3. **Cross-referencing**: Documents link to related content
4. **Versioning**: Track changes via Git
5. **Accessibility**: Easy to read for humans and LLMs

## 🔗 Repository Structure

```
ae-infinity-context/
├── personas/           # User personas and permissions
├── journeys/           # User workflows and flows
├── api/                # API specifications by domain (Coming Soon)
├── architecture/       # System architecture docs (Coming Soon)
├── components/         # UI component specs (Coming Soon)
├── config/             # Configuration docs (Coming Soon)
├── schemas/            # JSON Schema definitions for API contracts
├── metadata/           # Project metadata
├── docs/               # Additional documentation
│
├── PROJECT_SPEC.md     # Project requirements
├── API_SPEC.md         # Complete API spec
├── ARCHITECTURE.md     # System architecture
├── COMPONENT_SPEC.md   # UI components
├── USER_PERSONAS.md    # Original personas (see personas/ for new)
├── DEVELOPMENT_GUIDE.md # Development workflow
├── QUICK_START.md      # Quick start guide
├── README.md           # This file
└── REORGANIZATION_GUIDE.md # Migration guide for new structure
```

## 📖 Related Repositories

- **ae-infinity-ui** - React + TypeScript frontend
  - See [ae-infinity-ui/README.md](../ae-infinity-ui/README.md)
  - References this context repo for all specifications
  
- **ae-infinity-api** - .NET 8 Web API backend
  - See [ae-infinity-api/README.md](../ae-infinity-api/README.md)
  - Implements API contracts defined here

## 🔄 Using This Repository

### In Development

**When implementing a feature:**
```bash
# 1. Read the spec
cat PROJECT_SPEC.md | grep "feature-name"

# 2. Understand the user
cat personas/relevant-persona.md

# 3. Review the workflow
cat journeys/relevant-journey.md

# 4. Check the API
cat API_SPEC.md | grep "endpoint"

# 5. Follow architecture
cat ARCHITECTURE.md | grep "pattern"
```

### With AI Assistants

**Cursor/Copilot:**
```
1. Open relevant context files
2. Reference in comments:
   // See: ../ae-infinity-context/api/items.md#update-purchased
3. AI uses context for accurate code generation
```

**ChatGPT/Claude:**
```
Attach context files directly:
- Persona file
- Journey file
- API spec section
- Architecture pattern

AI generates code matching exact specifications
```

## 🤝 Contributing

### Adding New Content

1. **New Persona**: Add to `personas/` with cross-references
2. **New Journey**: Add to `journeys/` with step-by-step flow
3. **New API Endpoint**: Update `API_SPEC.md` (or add to `api/` when available)
4. **Architecture Change**: Update `ARCHITECTURE.md` (or relevant `architecture/` file)
5. **Component Spec**: Update `COMPONENT_SPEC.md` (or add to `components/`)

### Updating Existing Content

1. Find relevant file(s)
2. Make changes
3. Update cross-references if needed
4. Verify related docs still accurate
5. Commit with descriptive message

## 📝 Documentation Standards

- **Markdown format** for all documents
- **Clear headings** for easy navigation
- **Code examples** where applicable
- **Cross-references** to related content
- **Version history** via Git commits

## 🎯 Migration Status

The repository is being reorganized into a more granular structure:

✅ **Completed:**
- `personas/` - User personas fully migrated
- `journeys/` - Key user journeys documented
- `schemas/` - JSON Schema definitions for all API contracts

🚧 **In Progress:**
- `api/` - Splitting API_SPEC.md into domain files
- `architecture/` - Splitting ARCHITECTURE.md into focused docs
- `components/` - Splitting COMPONENT_SPEC.md by component type
- `config/` - Extracting configuration docs

📖 **See Also**: [REORGANIZATION_GUIDE.md](./REORGANIZATION_GUIDE.md) for migration details

## 🔗 Quick Links

**Getting Started:**
- [QUICK_START.md](./QUICK_START.md) - Quick start guide
- [PROJECT_SPEC.md](./PROJECT_SPEC.md) - Project overview

**For Developers:**
- [API_SPEC.md](./API_SPEC.md) - API contracts
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System design
- [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - Dev workflow

**For Designers:**
- [personas/](./personas/) - User research
- [journeys/](./journeys/) - User flows
- [COMPONENT_SPEC.md](./COMPONENT_SPEC.md) - UI specs

**For Product:**
- [PROJECT_SPEC.md](./PROJECT_SPEC.md) - Requirements
- [personas/](./personas/) - User personas
- [journeys/](./journeys/) - User workflows

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
