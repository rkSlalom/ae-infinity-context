---
description: "Load project specifications into context for AI-assisted development"
tags: ["context", "specs", "documentation", "ai"]
---

# Load Project Context

Load comprehensive project specifications, API contracts, and architecture documentation to inform AI-assisted development.

## What This Command Does

Provides you with curated content from the context repository to understand:
- Project requirements and goals
- API endpoints and contracts
- System architecture and patterns
- User personas and workflows
- Feature specifications

## Context Loading Strategy

### Step 1: Project Overview
Start by understanding the big picture:

**Read**: `PROJECT_SPEC.md`
- Complete project requirements
- Core features
- Business goals
- Success metrics

### Step 2: API Contracts
Understand the backend interface:

**Read**: `API_SPEC.md`
- All REST endpoints
- Request/response formats
- Authentication flow
- Error handling

### Step 3: System Architecture
Learn the technical design:

**Read**: `ARCHITECTURE.md`
- Clean Architecture layers
- CQRS pattern with MediatR
- State management strategy
- Real-time architecture (SignalR)
- Security design

### Step 4: User Context (Optional)
For user-facing features, load relevant persona:

**Read**: `personas/[persona-name].md`
- `list-creator.md` - Owner persona (Sarah)
- `active-collaborator.md` - Editor persona (Mike)
- `passive-viewer.md` - Viewer persona (Emma)
- `permission-matrix.md` - Permission comparison

### Step 5: User Journey (Optional)
For workflow-related features:

**Read**: `journeys/[journey-name].md`
- `creating-first-list.md`
- `shopping-together.md`

### Step 6: Feature Details
For specific features:

**Read**: `features/[domain]/README.md`

Available domains:
- `authentication/` - Auth & user management
- `lists/` - Shopping list CRUD
- `items/` - Shopping item management
- `collaboration/` - List sharing & permissions
- `categories/` - Item categorization
- `search/` - Global search
- `realtime/` - SignalR live updates
- `ui-components/` - Component library
- `infrastructure/` - DevOps & cross-cutting

### Step 7: Data Contracts
For type-safe development:

**Read**: `schemas/[schema-name].json`

Available schemas:
- `user.json`, `user-basic.json`, `user-stats.json`
- `list.json`, `list-detail.json`, `list-basic.json`
- `list-item.json`, `list-item-basic.json`
- `category.json`
- `collaborator.json`, `invitation.json`
- `search-result.json`, `pagination.json`
- `login-request.json`, `login-response.json`

## Quick Context Loading Examples

### Example 1: Implementing Authentication Feature
```
Load:
1. API_SPEC.md (Authentication section)
2. features/authentication/README.md
3. schemas/login-request.json
4. schemas/login-response.json
5. schemas/user.json

Now implement with full understanding of:
- Endpoint contract
- Security requirements
- Response format
- Error handling
```

### Example 2: Building List Management UI
```
Load:
1. COMPONENT_SPEC.md
2. API_SPEC.md (Lists section)
3. personas/list-creator.md
4. journeys/creating-first-list.md
5. schemas/list.json

Now build with knowledge of:
- UI component specs
- API endpoints to call
- User needs and goals
- Expected workflow
- Data structure
```

### Example 3: Adding Search Functionality
```
Load:
1. API_SPEC.md (Search section)
2. features/search/README.md
3. schemas/search-result.json
4. schemas/pagination.json

Now implement with clarity on:
- Search endpoints
- Filtering options
- Pagination strategy
- Response format
```

## Context for Different Roles

### Backend Developer
Essential reading:
- PROJECT_SPEC.md
- API_SPEC.md
- ARCHITECTURE.md (Backend section)
- features/[relevant-domain]/

### Frontend Developer
Essential reading:
- PROJECT_SPEC.md
- API_SPEC.md
- COMPONENT_SPEC.md
- personas/
- journeys/

### Full-Stack Developer
Essential reading:
- PROJECT_SPEC.md
- API_SPEC.md
- ARCHITECTURE.md
- COMPONENT_SPEC.md
- features/[relevant-domain]/

### AI Agent
Recommended loading order:
1. PROJECT_SPEC.md (overview)
2. Relevant persona (user context)
3. Relevant journey (workflow)
4. API_SPEC.md (contracts)
5. ARCHITECTURE.md (patterns)
6. Feature details (specifics)

## Pro Tips

### Tip 1: Load Progressively
Don't try to load everything at once. Start with essentials, then load specifics as needed.

### Tip 2: Use File References
When discussing code, reference the specs:
```
// See: ae-infinity-context/API_SPEC.md#authentication-endpoints
// See: ae-infinity-context/schemas/user.json
```

### Tip 3: Cross-Reference
Specs cross-reference each other. Follow links for deeper understanding.

### Tip 4: Verify Against Specs
Before implementing, verify your understanding:
- Does this match the API contract?
- Does this follow the architecture pattern?
- Does this meet the user's needs?

### Tip 5: Update Specs First
If you need to change something:
1. Update the spec first
2. Review the change
3. Implement in code
4. Mark as implemented in specs

## Working Directory Context

If you're using a working directory workspace, all context is available at:

```
work/ae-infinity-context/
└── [all specs and docs]
```

Load from there to ensure you're working with the same version as your working repos.

## Quick Reference

### Must-Read for Any Feature
- [ ] PROJECT_SPEC.md
- [ ] API_SPEC.md (relevant section)
- [ ] ARCHITECTURE.md (relevant pattern)

### User-Facing Features
- [ ] Relevant persona from personas/
- [ ] Relevant journey from journeys/
- [ ] COMPONENT_SPEC.md

### Backend Development
- [ ] Clean Architecture layers
- [ ] CQRS pattern documentation
- [ ] Repository pattern
- [ ] Validation approach

### Frontend Development
- [ ] State management strategy
- [ ] Component patterns
- [ ] API integration approach
- [ ] Error handling

## Help

For comprehensive documentation about the project structure:
```bash
cat ae-infinity-context/README.md
```

For development workflow:
```bash
cat ae-infinity-context/DEVELOPMENT_GUIDE.md
```

