# Context Repository Reorganization Guide

This document explains the new granular structure of the AE Infinity context repository.

## 🎯 Reorganization Goals

1. **Granularity**: Break large monolithic files into focused, single-topic documents
2. **Cross-referencing**: Documents link to related content across folders
3. **Discoverability**: Clear folder structure makes finding information intuitive
4. **Maintainability**: Easier to update specific topics without affecting others
5. **AI-Friendly**: Smaller, focused files are easier for LLMs to process

## 📂 New Structure

```
ae-infinity-context/
├── personas/                    # User personas and permissions
│   ├── README.md
│   ├── list-creator.md         # Owner persona (Sarah)
│   ├── active-collaborator.md  # Editor persona (Mike)
│   ├── passive-viewer.md       # Viewer persona (Emma)
│   └── permission-matrix.md    # Complete permission comparison
│
├── journeys/                    # User journey workflows
│   ├── README.md
│   ├── creating-first-list.md  # First-time user experience
│   ├── sharing-list.md         # Collaboration setup
│   ├── shopping-together.md    # Real-time coordination
│   └── managing-permissions.md # Access control workflows
│
├── api/                         # API specifications by domain
│   ├── README.md
│   ├── authentication.md        # Auth endpoints and JWT
│   ├── lists.md                # List CRUD operations
│   ├── items.md                # Item management
│   ├── categories.md           # Category endpoints
│   ├── search.md               # Search functionality
│   ├── realtime-events.md      # SignalR events
│   └── error-handling.md       # Error formats and codes
│
├── architecture/                # System architecture docs
│   ├── README.md
│   ├── system-overview.md      # High-level architecture
│   ├── frontend-architecture.md # React app structure
│   ├── backend-architecture.md # .NET API structure
│   ├── data-models.md          # Database schemas
│   ├── state-management.md     # Frontend state patterns
│   ├── realtime-strategy.md    # SignalR implementation
│   ├── security.md             # Security architecture
│   ├── performance.md          # Performance optimization
│   └── offline-sync.md         # Offline support strategy
│
├── components/                  # UI component specifications
│   ├── README.md
│   ├── design-system.md        # Colors, typography, spacing
│   ├── common-components.md    # Button, Input, Modal, etc.
│   ├── list-components.md      # List-specific components
│   ├── item-components.md      # Item-specific components
│   └── layout-components.md    # Headers, navigation, etc.
│
├── config/                      # Configuration documentation
│   ├── README.md
│   ├── environment-variables.md # Env var reference
│   ├── deployment-config.md    # Deployment settings
│   └── feature-flags.md        # Feature toggle system
│
├── workflows/                   # Development processes
│   ├── README.md
│   ├── development-workflow.md # Git flow, PR process
│   ├── testing-strategy.md     # Testing approach
│   └── deployment-process.md   # CI/CD pipeline
│
├── schemas/                     # JSON schemas (existing)
├── metadata/                    # Project metadata (existing)
│
├── README.md                    # Master index (UPDATED)
└── QUICK_START.md              # Quick start guide
```

## 🔄 Migration from Old Structure

### Old → New Mapping

**USER_PERSONAS.md** split into:
- `personas/list-creator.md` - Owner persona details
- `personas/active-collaborator.md` - Editor persona details
- `personas/passive-viewer.md` - Viewer persona details
- `personas/permission-matrix.md` - Permission comparison

**API_SPEC.md** split into:
- `api/authentication.md` - Auth endpoints
- `api/lists.md` - Shopping lists endpoints
- `api/items.md` - Shopping items endpoints
- `api/categories.md` - Categories endpoints
- `api/search.md` - Search endpoint
- `api/realtime-events.md` - SignalR events
- `api/error-handling.md` - Error formats

**ARCHITECTURE.md** split into:
- `architecture/system-overview.md` - High-level view
- `architecture/frontend-architecture.md` - Frontend details
- `architecture/backend-architecture.md` - Backend details
- `architecture/data-models.md` - Database schemas
- `architecture/state-management.md` - State patterns
- `architecture/realtime-strategy.md` - Real-time implementation
- `architecture/security.md` - Security model
- `architecture/performance.md` - Performance optimization
- `architecture/offline-sync.md` - Offline support

**COMPONENT_SPEC.md** split into:
- `components/design-system.md` - Design tokens
- `components/common-components.md` - Reusable components
- `components/list-components.md` - List features
- `components/item-components.md` - Item features
- `components/layout-components.md` - Layout structure

**DEVELOPMENT_GUIDE.md** split into:
- `workflows/development-workflow.md` - Git flow, PRs
- `workflows/testing-strategy.md` - Testing approach
- `workflows/deployment-process.md` - CI/CD
- `config/environment-variables.md` - Environment setup
- `config/deployment-config.md` - Deployment settings

## 📖 How to Use the New Structure

### For Developers

**Scenario 1: Implementing a new feature**
```
1. Read feature requirements
   → Check PROJECT_SPEC.md (if not yet split)
   
2. Understand the user
   → Read relevant persona in personas/
   
3. Review user flow
   → Read relevant journey in journeys/
   
4. Check API contract
   → Read relevant API doc in api/
   
5. Review architecture
   → Read relevant architecture doc in architecture/
   
6. Build UI
   → Follow component spec in components/
```

**Scenario 2: Understanding permissions**
```
1. Read personas/permission-matrix.md for quick reference
2. Deep dive into specific persona if needed
3. Check api/authentication.md for API enforcement
4. Review architecture/security.md for implementation
```

### For AI Agents

**Prompt Pattern**:
```
Context:
- Persona: personas/active-collaborator.md
- Journey: journeys/shopping-together.md
- API: api/items.md#update-purchased
- Architecture: architecture/realtime-strategy.md

Task: Implement real-time item purchase toggle
```

**Benefits**:
- Load only relevant context files
- Avoid overwhelming with unnecessary details
- Precise references with file paths
- Cross-reference related documents

### For Product Managers

**Planning a feature**:
1. Review personas/ to understand users
2. Read journeys/ to see current workflows
3. Identify gaps or pain points
4. Reference api/ and architecture/ for feasibility

### For Designers

**Designing a screen**:
1. Read relevant persona for user needs
2. Review journey for user flow
3. Check components/ for design system
4. Reference existing patterns

## 🔗 Cross-Reference System

Every document includes cross-references to related files:

**Example from personas/list-creator.md**:
```markdown
## Related Documentation

- **Permissions**: [permission-matrix.md](./permission-matrix.md)
- **Journeys**: [../journeys/creating-first-list.md](../journeys/creating-first-list.md)
- **API**: [../api/lists.md](../api/lists.md)
- **Security**: [../architecture/security.md](../architecture/security.md)
```

**Benefits**:
- Easy navigation between related topics
- Discover related information
- Understand full context
- Validate consistency

## 📊 Document Types

### Persona Documents
- **Focus**: Individual user type
- **Structure**: Profile, goals, pain points, usage patterns
- **Length**: 300-500 lines
- **Cross-refs**: Journeys, permissions, API

### Journey Documents
- **Focus**: Step-by-step user workflow
- **Structure**: Preconditions, steps, screens, API calls, success criteria
- **Length**: 400-800 lines
- **Cross-refs**: Personas, API, components

### API Documents
- **Focus**: Specific endpoint domain
- **Structure**: Endpoints, requests, responses, examples
- **Length**: 200-400 lines
- **Cross-refs**: Data models, journeys, authentication

### Architecture Documents
- **Focus**: System component or pattern
- **Structure**: Overview, implementation, decisions, diagrams
- **Length**: 200-500 lines
- **Cross-refs**: Related architecture docs, API, data models

### Component Documents
- **Focus**: UI component specifications
- **Structure**: Purpose, props, states, examples, accessibility
- **Length**: 200-400 lines
- **Cross-refs**: Design system, journeys, API data

## 🎯 Benefits of New Structure

### 1. **Improved Discoverability**
- Clear folder names indicate content type
- README in each folder provides overview
- Easy to find specific information

### 2. **Better Maintainability**
- Update specific topic without affecting others
- Smaller files easier to edit and review
- Reduced merge conflicts

### 3. **Enhanced AI Context Loading**
- Load only relevant files for task
- Avoid token limits with large files
- More precise context for better results

### 4. **Clearer Dependencies**
- Cross-references show relationships
- Easy to track impact of changes
- Better understanding of system

### 5. **Flexible Consumption**
- Read deep on single topic
- Browse related topics
- Get quick overview from READMEs

## 🔄 Ongoing Maintenance

### Adding New Content

**New Persona**:
1. Create `personas/new-persona.md`
2. Update `personas/README.md`
3. Add to `personas/permission-matrix.md` if different permissions
4. Create related journey if needed

**New API Endpoint**:
1. Add to appropriate `api/*.md` file
2. Update `api/README.md` if new domain
3. Cross-reference from related journeys
4. Update data models if schema changes

**New Architecture Decision**:
1. Create or update `architecture/*.md`
2. Update `architecture/system-overview.md` if major
3. Cross-reference from API or components
4. Update journeys if workflow changes

### Consistency Checks

**Quarterly Review**:
- [ ] Verify all cross-references are valid
- [ ] Check for outdated information
- [ ] Ensure consistent formatting
- [ ] Update master README index

## 🔗 Quick Links

**Start Here**:
- [README.md](./README.md) - Master index
- [QUICK_START.md](./QUICK_START.md) - Quick start guide

**For Developers**:
- [personas/](./personas/) - Understand users
- [api/](./api/) - API contracts
- [architecture/](./architecture/) - System design

**For Designers**:
- [personas/](./personas/) - User needs
- [journeys/](./journeys/) - User flows
- [components/](./components/) - UI specs

**For Product**:
- [personas/](./personas/) - User research
- [journeys/](./journeys/) - Current workflows
- [PROJECT_SPEC.md](./PROJECT_SPEC.md) - Product requirements

---

**Questions or suggestions?** Open an issue or discuss with the team!

