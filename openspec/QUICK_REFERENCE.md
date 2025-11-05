# OpenSpec Quick Reference - AE Infinity

Fast reference for common OpenSpec tasks across the three repositories.

## Setup

```bash
# One-time setup from parent directory
cd ae-infinity
./scripts/setup-openspec-all.sh
```

## Common Commands

### View Specs
```bash
# From any repo
openspec list --specs                    # List all capabilities
openspec show authentication             # View a spec
openspec show authentication --json      # JSON output
```

### View Changes
```bash
# From any repo
openspec list                            # List active changes
openspec show add-feature                # View a change
openspec show add-feature --deltas-only  # View only spec deltas
```

### Create Change
```bash
# Context repo (cross-cutting)
cd ae-infinity-context
mkdir -p openspec/changes/add-two-factor
cd openspec/changes/add-two-factor
touch proposal.md tasks.md
mkdir -p specs/authentication
# Edit specs/authentication/spec.md with ## ADDED Requirements

# API repo (backend-only)
cd ae-infinity-api
mkdir -p openspec/changes/refactor-queries
cd openspec/changes/refactor-queries
touch proposal.md tasks.md
# No spec deltas needed

# UI repo (frontend-only)
cd ae-infinity-ui
mkdir -p openspec/changes/redesign-dashboard
cd openspec/changes/redesign-dashboard
touch proposal.md tasks.md design.md
# No spec deltas needed
```

### Validate
```bash
openspec validate [change-id] --strict
```

### Archive
```bash
# With spec updates (context repo)
openspec archive add-two-factor --yes

# Without spec updates (API/UI repos)
openspec archive refactor-queries --skip-specs --yes
```

## Decision Matrix

| Question | Answer | Location |
|----------|--------|----------|
| Does it change API contract? | Yes | context/changes/ |
| Does it change data model? | Yes | context/changes/ |
| Does it affect both FE & BE? | Yes | context/changes/ |
| Backend refactoring only? | No | api/changes/ |
| UI/UX redesign only? | No | ui/changes/ |
| Bug fix? | Usually no | Direct fix |

## File Structure

### Context Repo (Hub)
```
ae-infinity-context/openspec/
├── project.md                # Shared project context
├── AGENTS.md                 # Shared AI instructions
├── specs/                    # All capability specs
│   ├── authentication/
│   │   └── spec.md
│   └── lists/
│       └── spec.md
└── changes/                  # Cross-cutting changes
    └── add-feature/
        ├── proposal.md
        ├── tasks.md
        └── specs/
            └── capability/
                └── spec.md
```

### API Repo (Spoke)
```
ae-infinity-api/openspec/
├── project.md → ../../context/openspec/project.md
├── AGENTS.md → ../../context/openspec/AGENTS.md
├── specs/ → ../../context/openspec/specs/
└── changes/                  # Backend-only changes
    └── refactor-feature/
        ├── proposal.md
        └── tasks.md
```

### UI Repo (Spoke)
```
ae-infinity-ui/openspec/
├── project.md → ../../context/openspec/project.md
├── AGENTS.md → ../../context/openspec/AGENTS.md
├── specs/ → ../../context/openspec/specs/
└── changes/                  # Frontend-only changes
    └── redesign-feature/
        ├── proposal.md
        ├── tasks.md
        └── design.md
```

## Spec Delta Operations

### ADDED Requirements
```markdown
## ADDED Requirements
### Requirement: New Feature
System SHALL provide new capability.

#### Scenario: Success case
- **WHEN** action
- **THEN** result
```

### MODIFIED Requirements
```markdown
## MODIFIED Requirements
### Requirement: Existing Feature
[FULL requirement with ALL scenarios - old + new]

#### Scenario: Updated behavior
- **WHEN** new action
- **THEN** new result
```

### REMOVED Requirements
```markdown
## REMOVED Requirements
### Requirement: Old Feature
**Reason**: No longer needed
**Migration**: Use new feature instead
```

### RENAMED Requirements
```markdown
## RENAMED Requirements
- FROM: `### Requirement: Old Name`
- TO: `### Requirement: New Name`
```

## Git Workflow

### Feature with API Changes
```bash
# 1. Create change in context repo
cd ae-infinity-context
mkdir -p openspec/changes/add-categories
# Write proposal, tasks, spec deltas
git add openspec/changes/add-categories
git commit -m "spec: add categories capability"

# 2. Implement in API
cd ../ae-infinity-api
# Implement, reference change ID in commits
git commit -m "feat(api): implement categories endpoints (ref: add-categories)"

# 3. Implement in UI
cd ../ae-infinity-ui
# Implement, reference change ID in commits
git commit -m "feat(ui): add categories UI (ref: add-categories)"

# 4. After deployment, archive in context
cd ../ae-infinity-context
openspec archive add-categories --yes
git add openspec/specs/ openspec/changes/
git commit -m "spec: archive add-categories change"
```

### Backend-Only Refactoring
```bash
# 1. Create change in API repo
cd ae-infinity-api
mkdir -p openspec/changes/optimize-queries
# Write proposal, tasks (no spec deltas)
git add openspec/changes/optimize-queries
git commit -m "refactor: plan query optimization"

# 2. Implement
# Make changes, test
git commit -m "refactor(api): optimize list queries"

# 3. Archive locally
openspec archive optimize-queries --skip-specs --yes
git add openspec/changes/
git commit -m "refactor: archive query optimization"
```

## Troubleshooting

### Symlinks not working
```bash
# Re-create symlinks
cd ae-infinity-api/openspec
rm -f project.md AGENTS.md specs
ln -s ../../ae-infinity-context/openspec/project.md project.md
ln -s ../../ae-infinity-context/openspec/AGENTS.md AGENTS.md
ln -s ../../ae-infinity-context/openspec/specs specs
```

### OpenSpec can't find specs
```bash
# Check symlink
ls -la openspec/specs/
# Should show: specs -> ../../ae-infinity-context/openspec/specs

# Check context repo has specs
ls ../ae-infinity-context/openspec/specs/
```

### Validation errors
```bash
# Use strict mode for detailed errors
openspec validate [change-id] --strict

# Check JSON output
openspec show [change-id] --json --deltas-only

# Common fixes:
# - Use #### Scenario: (4 hashtags)
# - Include at least one scenario per requirement
# - Use ## ADDED|MODIFIED|REMOVED Requirements headers
```

## AI Assistant Prompts

### Creating a spec
```
Context:
- @openspec/project.md (project conventions)
- @openspec/AGENTS.md (spec format)

Task: Create a spec for [capability] with requirements for [features].
Follow the OpenSpec format with ## Requirements and #### Scenario: headers.
```

### Implementing from spec
```
Context:
- @openspec/project.md (architecture patterns)
- @openspec/specs/[capability]/spec.md (requirements)

Task: Implement [requirement] from the spec.
Follow all scenarios and handle all cases specified.
```

### Creating a change
```
Context:
- @openspec/AGENTS.md (change proposal format)
- @openspec/specs/ (existing specs)

Task: Create a change proposal for [feature].
Include proposal.md, tasks.md, and spec deltas if needed.
```

## Links

- **Full Setup Guide**: [CROSS_REPO_SETUP.md](./CROSS_REPO_SETUP.md)
- **Spec Creation Guide**: [specs/README.md](./specs/README.md)
- **AI Instructions**: [AGENTS.md](./AGENTS.md)
- **Project Context**: [project.md](./project.md)

---

**Quick Tip**: Run `openspec validate --strict` before committing any change!

