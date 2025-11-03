# AE Infinity - Context Repository

Welcome to the AE Infinity context repository! This is the single source of truth for all project specifications, designed for both human developers and AI-assisted development.

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

### 🔄 [Workflows](./workflows/)
Development processes and workflows (Coming Soon - see DEVELOPMENT_GUIDE.md for now)

- **development-workflow.md** - Git flow and PR process
- **testing-strategy.md** - Testing approach and standards
- **deployment-process.md** - CI/CD pipeline

## 📖 Core Documents

These documents provide project-wide context:

- **[PROJECT_SPEC.md](./PROJECT_SPEC.md)** - Complete project requirements and features
- **[API_SPEC.md](./API_SPEC.md)** - Full REST API specification (to be split into api/)
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture (to be split into architecture/)
- **[COMPONENT_SPEC.md](./COMPONENT_SPEC.md)** - UI components (to be split into components/)
- **[USER_PERSONAS.md](./USER_PERSONAS.md)** - Original personas document (replaced by personas/)
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - Development workflow (to be split into workflows/)
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
├── workflows/          # Development processes (Coming Soon)
├── schemas/            # JSON schemas
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

🚧 **In Progress:**
- `api/` - Splitting API_SPEC.md into domain files
- `architecture/` - Splitting ARCHITECTURE.md into focused docs
- `components/` - Splitting COMPONENT_SPEC.md by component type
- `config/` - Extracting configuration docs
- `workflows/` - Extracting process docs from DEVELOPMENT_GUIDE.md

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

**Questions?** Open an issue or reach out to the team.

**Contributing?** See contributing guidelines above.

**Using with AI?** See "For AI/LLM Agents" section above.
