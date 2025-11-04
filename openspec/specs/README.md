# Capability Specifications

This directory contains all capability specifications for AE Infinity.

## Purpose

Specifications define **what the system does** (requirements and behavior), not how it's implemented. Each capability is documented with:

- **Requirements**: SHALL/MUST statements describing behavior
- **Scenarios**: Concrete examples of requirements in action
- **Design** (optional): Technical patterns and decisions

## Structure

```
specs/
├── authentication/          # User authentication capability
│   ├── spec.md             # Requirements and scenarios
│   └── design.md           # JWT implementation, password hashing
├── lists/                   # Shopping list management
│   └── spec.md
├── items/                   # Shopping item management
│   └── spec.md
├── collaboration/           # List sharing and permissions
│   └── spec.md
└── realtime/               # Real-time synchronization (planned)
    └── spec.md
```

## Creating New Specs

### When to Create a Spec

Create a spec when introducing a new **capability** - a cohesive set of related features that can be described in one sitting (10-minute rule).

**Good capability boundaries:**
- `authentication` - User login, logout, session management
- `lists` - List CRUD, archiving, filtering
- `items` - Item CRUD, purchase tracking, reordering
- `collaboration` - Sharing, permissions, invitations

**Too broad:**
- `backend` - Not a single capability
- `api` - Too generic

**Too narrow:**
- `login-button` - Too specific, part of authentication
- `mark-purchased` - Part of items capability

### Spec File Format

Every `spec.md` follows this structure:

```markdown
# [Capability Name]

Brief description of the capability and its purpose.

## Requirements

### Requirement: [Name]
The system SHALL/MUST [description of requirement].

#### Scenario: [Success case]
- **GIVEN** [precondition]
- **WHEN** [action]
- **THEN** [expected result]

#### Scenario: [Error case]
- **WHEN** [error condition]
- **THEN** [expected error handling]

### Requirement: [Another requirement]
...
```

**Critical formatting:**
- Use `## Requirements` header (exactly)
- Use `### Requirement:` for each requirement
- Use `#### Scenario:` for each scenario (4 hashtags)
- Use SHALL/MUST for normative requirements
- Every requirement MUST have at least one scenario

### Creating a Spec via Change Proposal

Specs are created through OpenSpec change proposals:

```bash
# 1. Create a change in context repo
cd ae-infinity-context
mkdir -p openspec/changes/add-authentication

# 2. Write proposal
cat > openspec/changes/add-authentication/proposal.md << 'EOF'
# Change: Add User Authentication

## Why
Users need secure access to their shopping lists.

## What Changes
- JWT-based authentication
- Login/logout endpoints
- Password hashing with BCrypt
- Session management

## Impact
- New capability: authentication
- Affected code: API controllers, middleware
EOF

# 3. Create spec delta
mkdir -p openspec/changes/add-authentication/specs/authentication
cat > openspec/changes/add-authentication/specs/authentication/spec.md << 'EOF'
## ADDED Requirements

### Requirement: User Login
Users SHALL authenticate with email and password.

#### Scenario: Successful login
- **GIVEN** valid credentials
- **WHEN** user submits email and password
- **THEN** system returns JWT token and user details

#### Scenario: Invalid credentials
- **WHEN** user submits incorrect email or password
- **THEN** system returns 401 Unauthorized with generic error
EOF

# 4. Validate
openspec validate add-authentication --strict

# 5. After implementation, archive (copies spec to specs/authentication/)
openspec archive add-authentication --yes
```

### Design Documents

Create `design.md` alongside `spec.md` when:
- Cross-cutting change (multiple services)
- New architectural pattern
- External dependencies
- Security/performance/migration complexity

**Minimal design.md structure:**
```markdown
## Context
[Background, constraints]

## Goals / Non-Goals
- Goals: [...]
- Non-Goals: [...]

## Decisions
- Decision: [What and why]
- Alternatives: [Options considered]

## Risks / Trade-offs
- [Risk] → Mitigation

## Migration Plan
[If applicable]
```

## Current Capabilities

This section will be populated as specs are created:

- [ ] **Authentication** - User login, logout, JWT tokens
- [ ] **Lists** - Shopping list CRUD and management
- [ ] **Items** - Shopping item CRUD and purchase tracking
- [ ] **Collaboration** - List sharing and permissions
- [ ] **Categories** - Item categorization
- [ ] **Search** - Finding lists and items
- [ ] **Real-time** - Live synchronization (planned)
- [ ] **Offline** - Offline support with sync (planned)

## Viewing Specs

### CLI
```bash
# List all specs
openspec list --specs

# Show a specific spec
openspec show authentication --type spec

# Show as JSON
openspec show authentication --type spec --json
```

### Direct Reading
```bash
# Read spec file
cat specs/authentication/spec.md

# Search across specs
rg "Requirement:" specs/
```

## Modifying Specs

**Never edit specs directly!** Always modify through change proposals:

```bash
# 1. Create a change
mkdir -p openspec/changes/update-authentication

# 2. Create spec delta with MODIFIED Requirements
cat > openspec/changes/update-authentication/specs/authentication/spec.md << 'EOF'
## MODIFIED Requirements

### Requirement: User Login
Users SHALL authenticate with email and password or OAuth provider.

[Include FULL requirement content with all scenarios]
EOF

# 3. After implementation, archive (updates the spec)
openspec archive update-authentication --yes
```

## Spec Validation

All specs must pass validation:

```bash
# Validate specific spec
openspec validate [change-id] --strict

# Common validation rules:
# - Every requirement has ≥1 scenario
# - Scenarios use #### header (4 hashtags)
# - Requirements use SHALL/MUST
# - Headers are consistent
```

## Best Practices

### Capability Naming
- Use kebab-case: `user-authentication`, `list-management`
- Verb-noun pattern preferred
- Single purpose per capability
- 10-minute understandability rule

### Requirement Writing
- **Specific**: "System SHALL validate email format" not "System SHALL validate input"
- **Testable**: Can verify with concrete test case
- **Unambiguous**: One clear interpretation
- **Traceable**: Can map to implementation

### Scenario Writing
- **Complete**: Include all steps (GIVEN/WHEN/THEN or just WHEN/THEN)
- **Concrete**: Specific values, not "some data"
- **Independent**: Each scenario stands alone
- **Representative**: Covers success and failure paths

### Spec Organization
- Group related requirements together
- Order requirements logically (happy path first)
- Use clear, descriptive names
- Keep specs focused (split if > 500 lines)

## Cross-Repository Usage

These specs are **shared across all three repos** via symlinks:

- **ae-infinity-api**: Uses specs to guide backend implementation
- **ae-infinity-ui**: Uses specs to understand API contracts and behavior
- **ae-infinity-context**: Authoritative source (this repo)

See `../CROSS_REPO_SETUP.md` for details on cross-repository OpenSpec usage.

## AI Assistant Integration

When working with AI assistants:

```
Load context:
- openspec/project.md (project-wide context)
- openspec/specs/[capability]/spec.md (relevant requirements)
- openspec/AGENTS.md (AI instructions)

Generate code that:
- Implements all requirements
- Handles all scenarios
- Follows architecture patterns in project.md
```

## Questions?

- See `../AGENTS.md` for comprehensive OpenSpec instructions
- See `../CROSS_REPO_SETUP.md` for multi-repo setup
- Check existing specs for examples
- Review `openspec validate --help` for validation rules

---

**Remember**: Specs define **what**, implementation defines **how**. Keep them separate!

