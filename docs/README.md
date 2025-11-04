# Documentation Directory

Additional context documentation and guides.

## 📁 Files in This Directory

### Cross-Repository Reference System

- **[CROSS_REPO_REFERENCES.md](./CROSS_REPO_REFERENCES.md)** - Complete guide to referencing files across repos
  - Problem statement and solution
  - Multiple resolution strategies (local, GitHub CLI, raw URLs)
  - Configuration system
  - AI agent guidelines
  - Implementation approaches

- **[REFERENCE_EXAMPLES.md](./REFERENCE_EXAMPLES.md)** - Practical reference patterns
  - 4 recommended patterns with pros/cons
  - Before/after migration examples
  - Tool configuration examples
  - When to use which pattern

## 🎯 Quick Start

### Problem
Hard-coded relative paths like `../../ae-infinity-api/docs/DB_SCHEMA.md` break when:
- Repositories are moved or renamed
- Repo is cloned in isolation
- Multi-repo structure changes

### Solution
Use **resilient reference patterns** that:
1. Try local path first (fastest)
2. Fall back to GitHub CLI fetch
3. Fall back to GitHub raw URL
4. Fail gracefully if unavailable

### Best Practice

**Always provide GitHub URL as primary reference:**

```markdown
**Database Schema**: See [DB_SCHEMA.md](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md) in backend repository

> **Local**: `../ae-infinity-api/docs/DB_SCHEMA.md` (if repos are siblings)
```

## 🔧 Tools

### Validation Script
```bash
# Validate all cross-repo references
./scripts/validate-refs.sh

# Validate specific directory
./scripts/validate-refs.sh docs/
```

### Configuration
See [../.repo-references.json](../.repo-references.json) for repository configuration.

## 🤖 For AI Agents

When an AI needs to load cross-repo context:

1. **Try local first**: `../ae-infinity-api/docs/DB_SCHEMA.md`
2. **Use GitHub CLI**: `gh api repos/{owner}/{repo}/contents/{path}`
3. **Use raw URL**: `https://raw.githubusercontent.com/{owner}/{repo}/main/{path}`

See [CROSS_REPO_REFERENCES.md#for-aillm-agents](./CROSS_REPO_REFERENCES.md#for-aillm-agents)

## 📖 Related Documentation

- [../REORGANIZATION_GUIDE.md](../REORGANIZATION_GUIDE.md) - Context repo structure
- [../GLOSSARY.md](../GLOSSARY.md) - Terminology reference
- [../CHANGELOG.md](../CHANGELOG.md) - Recent changes

---

**Status**: Active documentation - refer here for cross-repo reference patterns

