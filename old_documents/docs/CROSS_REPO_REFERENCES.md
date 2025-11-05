# Cross-Repository Reference System

This document explains how to reference files across the AE Infinity multi-repo setup in a way that's resilient to repo moves, renames, and isolation.

## 🎯 Problem

Hard-coded relative paths like `../../ae-infinity-api/docs/DB_SCHEMA.md` are fragile:
- ❌ Break when repos are renamed or moved
- ❌ Don't work when repo is cloned in isolation
- ❌ Fail when repos aren't in expected sibling structure
- ❌ Can't fall back to remote content

## ✅ Solution: Multi-Strategy Reference System

### 1. Reference Format in Documentation

Use a **logical reference syntax** instead of hard-coded paths:

```markdown
<!-- OLD WAY (fragile) -->
See [DB_SCHEMA.md](../../ae-infinity-api/docs/DB_SCHEMA.md)

<!-- NEW WAY (resilient) -->
See [DB_SCHEMA.md](@api:docs/DB_SCHEMA.md)
```

**Syntax**: `@{repo-alias}:{path-in-repo}`

### 2. Repository Aliases

Defined in `.repo-references.json`:
- `@context` → ae-infinity-context
- `@api` → ae-infinity-api  
- `@ui` → ae-infinity-ui

### 3. Resolution Strategies

The system tries multiple strategies in order:

#### Strategy 1: Local Relative Path
```bash
# If repos are siblings (typical dev setup)
../ae-infinity-api/docs/DB_SCHEMA.md
```

#### Strategy 2: Local Absolute Path
```bash
# If configured in .repo-references.json
/Users/user/Projects/ae-infinity/ae-infinity-api/docs/DB_SCHEMA.md
```

#### Strategy 3: GitHub Raw URL
```bash
# Fallback to remote content
https://raw.githubusercontent.com/your-org/ae-infinity-api/main/docs/DB_SCHEMA.md
```

#### Strategy 4: GitHub CLI
```bash
# Fetch content via gh CLI
gh api repos/your-org/ae-infinity-api/contents/docs/DB_SCHEMA.md \
  --jq '.content' | base64 --decode
```

## 🔧 Configuration File

**`.repo-references.json`** defines:
- Repository metadata (GitHub org, repo name, branch)
- Local path configurations
- Named references to frequently accessed files
- Resolution strategy priority

Example:
```json
{
  "repositories": {
    "api": {
      "github": {
        "owner": "your-org",
        "repo": "ae-infinity-api",
        "branch": "main"
      },
      "local": {
        "relativePath": "../ae-infinity-api"
      }
    }
  },
  "references": {
    "db-schema": {
      "repository": "api",
      "path": "docs/DB_SCHEMA.md"
    }
  }
}
```

## 📝 Documentation Conventions

### For Human-Readable Docs

Use **dual-link pattern** - provide both logical reference and GitHub URL:

```markdown
**Database Schema**: See [@api:docs/DB_SCHEMA.md] or 
[view on GitHub](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md)
```

### For Machine-Readable References

Use the `@repo:path` syntax in:
- Cross-references in markdown
- Tool configurations
- Scripts and automation

### For Critical References

Provide multiple access methods:

```markdown
## Primary Reference

**Source**: Database schema specification

**Access Methods**:
1. **Local**: `../ae-infinity-api/docs/DB_SCHEMA.md` (if repos are siblings)
2. **GitHub**: [DB_SCHEMA.md](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md)
3. **CLI**: `gh api repos/your-org/ae-infinity-api/contents/docs/DB_SCHEMA.md`
4. **Logical**: `@api:docs/DB_SCHEMA.md` (requires resolution tool)
```

## 🛠️ Resolution Tool (Concept)

Create a tool to resolve references:

```bash
# Resolve logical reference to actual path/URL
resolve-ref @api:docs/DB_SCHEMA.md

# Output:
# Strategy: local-relative
# Path: ../ae-infinity-api/docs/DB_SCHEMA.md
# Exists: true
```

```bash
# Fetch content from reference
fetch-ref @api:docs/DB_SCHEMA.md

# Falls back through strategies until successful
```

## 🤖 For AI/LLM Agents

When an AI agent encounters a reference:

1. **Try Local First**: Check if relative path exists
2. **Use GitHub API**: Fetch via `gh api` if available
3. **Use Raw URL**: Fetch from GitHub raw URL
4. **Fail Gracefully**: Note reference but continue

**Example Prompt Pattern**:
```
Context needed:
- @api:docs/DB_SCHEMA.md (database schema)

Resolution:
1. Try: ../ae-infinity-api/docs/DB_SCHEMA.md
2. Fallback: gh api repos/{org}/{repo}/contents/docs/DB_SCHEMA.md
3. Fallback: https://raw.githubusercontent.com/{org}/{repo}/main/docs/DB_SCHEMA.md
```

## 📊 Implementation Approaches

### Approach 1: Documentation Convention (Immediate)

Simply adopt the dual-link pattern in all documentation:

```markdown
**Reference**: [@api:docs/DB_SCHEMA.md] - Database Schema
- **Local**: `../ae-infinity-api/docs/DB_SCHEMA.md`
- **GitHub**: [View on GitHub](https://github.com/...)
```

**Pros**: Immediate, no tooling needed
**Cons**: Manual, not enforced

### Approach 2: Pre-processor Script (Medium)

Create a script that processes markdown and resolves references:

```bash
# Before committing
./scripts/resolve-refs.sh docs/*.md

# Replaces @api:path references with actual links
```

**Pros**: Automated, consistent
**Cons**: Requires discipline to run

### Approach 3: Custom Documentation Tool (Advanced)

Build a tool (or use existing like MkDocs with plugin) that:
- Reads `.repo-references.json`
- Resolves references at build/serve time
- Provides validation

**Pros**: Full automation, validation
**Cons**: More complex setup

### Approach 4: GitHub Actions Validation (Recommended)

Add a CI check that validates cross-repo references:

```yaml
# .github/workflows/validate-references.yml
name: Validate Cross-Repo References

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate References
        run: |
          # Check if referenced files exist (via GitHub API)
          ./scripts/validate-refs.sh
```

## 🎯 Recommended Pattern for AE Infinity

Use **hybrid approach**:

1. **Primary**: Use descriptive text with GitHub URLs for critical references
   ```markdown
   **Source**: Database schema in backend repository
   [View DB_SCHEMA.md on GitHub](https://github.com/...)
   ```

2. **Secondary**: Keep relative paths as convenience (with disclaimer)
   ```markdown
   **Local Path**: `../ae-infinity-api/docs/DB_SCHEMA.md` 
   _(only works if repos are cloned as siblings)_
   ```

3. **Machine-Readable**: Add `.repo-references.json` for future tooling

4. **AI-Friendly**: In `.cursorrules` or context docs, specify fetch strategy
   ```markdown
   When referencing cross-repo files:
   1. Check local relative path
   2. Use: gh api repos/{owner}/{repo}/contents/{path}
   3. Use: https://raw.githubusercontent.com/...
   ```

## 📝 Migration Guide

### Step 1: Add Configuration
Create `.repo-references.json` with repo metadata

### Step 2: Update Documentation Pattern
Replace hard-coded paths with dual-link pattern:

**Before**:
```markdown
See [DB_SCHEMA.md](../../ae-infinity-api/docs/DB_SCHEMA.md)
```

**After**:
```markdown
**Database Schema**: See backend repository documentation
- **GitHub**: [DB_SCHEMA.md](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md)
- **Local**: `../ae-infinity-api/docs/DB_SCHEMA.md` (if repos are siblings)
```

### Step 3: Update AI Context
Add to `.cursorrules`:
```markdown
## Cross-Repository References

When documentation references other repositories:
1. Prefer GitHub URLs (always work)
2. Use `gh api` to fetch content if needed
3. Local paths are convenience only (may not exist)

Config: See .repo-references.json for repository locations
```

## 🔍 Example: Resolving @api:docs/DB_SCHEMA.md

**Using GitHub CLI**:
```bash
gh api repos/your-org/ae-infinity-api/contents/docs/DB_SCHEMA.md \
  --jq '.content' | base64 --decode
```

**Using curl**:
```bash
curl -H "Accept: application/vnd.github.v3.raw" \
  https://api.github.com/repos/your-org/ae-infinity-api/contents/docs/DB_SCHEMA.md
```

**Using raw URL**:
```bash
curl https://raw.githubusercontent.com/your-org/ae-infinity-api/main/docs/DB_SCHEMA.md
```

## ✅ Benefits

1. **Resilient**: Works even if repos move/rename
2. **Flexible**: Multiple resolution strategies
3. **Isolated**: Each repo can work standalone
4. **Remote-Friendly**: Can fetch from GitHub when needed
5. **Future-Proof**: Config-based for easy updates

## 🔗 Related

- [.repo-references.json](./.repo-references.json) - Configuration file
- [REORGANIZATION_GUIDE.md](./REORGANIZATION_GUIDE.md) - Context structure

---

**Status**: Proposed pattern - not yet fully implemented
**Next Steps**: Decide on implementation approach and update existing docs

