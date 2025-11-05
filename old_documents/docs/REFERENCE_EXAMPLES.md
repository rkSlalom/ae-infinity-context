# Cross-Repository Reference Examples

Practical examples of how to reference files across the AE Infinity multi-repo setup.

## ✅ Recommended Patterns

### Pattern 1: GitHub URL Primary (Most Resilient)

Use when the reference is critical and must always work:

```markdown
## Database Schema

**Primary Source**: Backend repository database documentation

**Access**:
- [View DB_SCHEMA.md on GitHub](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md)
- Local: `../ae-infinity-api/docs/DB_SCHEMA.md` (if repos are siblings)

For complete database schema including all tables, indexes, and constraints, see the backend repository documentation.
```

**Pros**: Always works, clearly indicates it's external
**Cons**: Less convenient for local development

---

### Pattern 2: Dual Link with Context

Provide both local and remote access:

```markdown
## Related Documentation

### Backend Database Schema
- **GitHub**: [DB_SCHEMA.md](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md)
- **Local**: `../ae-infinity-api/docs/DB_SCHEMA.md`
- **Description**: Complete database schema with soft delete and audit patterns

### Frontend UI Documentation  
- **GitHub**: [README.md](https://github.com/your-org/ae-infinity-ui/blob/main/README.md)
- **Local**: `../ae-infinity-ui/README.md`
- **Description**: React UI setup and component patterns
```

**Pros**: Best of both worlds
**Cons**: More verbose

---

### Pattern 3: Smart Link with Tooltip

Use descriptive text with a link:

```markdown
This feature implements the [database soft delete pattern](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md#soft-delete-implementation) documented in the backend repository.

> 💡 **Local Path**: If you have the backend repo as a sibling, see: `../ae-infinity-api/docs/DB_SCHEMA.md`
```

**Pros**: Natural reading flow
**Cons**: GitHub link might be long

---

### Pattern 4: Reference Section

For documents with many cross-repo references:

```markdown
## 🔗 External References

This document references files from other AE Infinity repositories. Access methods depend on your setup:

| Document | Local Path | GitHub |
|----------|-----------|--------|
| DB Schema | `../ae-infinity-api/docs/DB_SCHEMA.md` | [View](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md) |
| API README | `../ae-infinity-api/README.md` | [View](https://github.com/your-org/ae-infinity-api/blob/main/README.md) |
| UI Patterns | `../ae-infinity-ui/docs/DEVELOPMENT_PATTERNS.md` | [View](https://github.com/your-org/ae-infinity-ui/blob/main/docs/DEVELOPMENT_PATTERNS.md) |

**Note**: Local paths only work if repositories are cloned as siblings.
```

**Pros**: Clean organization of all external references
**Cons**: Requires maintenance

---

## 🔧 For Tool/Script Configuration

### In package.json / Scripts

```json
{
  "scripts": {
    "fetch-context": "command -v gh >/dev/null && gh api repos/your-org/ae-infinity-context/contents/GLOSSARY.md --jq '.content' | base64 --decode > .context/GLOSSARY.md || curl -s https://raw.githubusercontent.com/your-org/ae-infinity-context/main/GLOSSARY.md > .context/GLOSSARY.md"
  }
}
```

### In .cursorrules / AI Instructions

```markdown
## Context Loading

When you need context from other repositories:

1. **Try local path first** (fastest):
   ```
   ../ae-infinity-context/GLOSSARY.md
   ```

2. **Use GitHub CLI** (if available):
   ```bash
   gh api repos/your-org/ae-infinity-context/contents/GLOSSARY.md \
     --jq '.content' | base64 --decode
   ```

3. **Use GitHub raw URL** (fallback):
   ```bash
   curl https://raw.githubusercontent.com/your-org/ae-infinity-context/main/GLOSSARY.md
   ```

Config: `.repo-references.json` contains repository locations
```

### In CI/CD (GitHub Actions)

```yaml
- name: Fetch Cross-Repo Documentation
  run: |
    # Use GitHub API to fetch from sibling repos
    curl -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
         -H "Accept: application/vnd.github.v3.raw" \
         https://api.github.com/repos/${{ github.repository_owner }}/ae-infinity-context/contents/GLOSSARY.md \
         -o .context/GLOSSARY.md
```

---

## 🤖 For AI Agents

### Example: Cursor AI Prompt

```markdown
Context needed for this task:

1. **Database Schema**
   - Logical: @api:docs/DB_SCHEMA.md
   - Local: ../ae-infinity-api/docs/DB_SCHEMA.md
   - Remote: https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md
   - Contains: Complete database schema with all tables

2. **User Permissions**
   - Logical: @context:personas/permission-matrix.md
   - Local: ../ae-infinity-context/personas/permission-matrix.md
   - Remote: https://github.com/your-org/ae-infinity-context/blob/main/personas/permission-matrix.md
   - Contains: Role-based permission definitions

Try to load these in order: local → gh api → raw URL
```

---

## 📋 Migration Examples

### Before (Fragile)

```markdown
The database uses soft delete pattern. See 
[DB_SCHEMA.md](../../ae-infinity-api/docs/DB_SCHEMA.md) for details.

For API endpoints, check [API_SPEC.md](../../ae-infinity-context/API_SPEC.md).
```

**Problems**:
- Relative paths break if repos move
- Doesn't work in isolation
- No fallback

### After (Resilient)

```markdown
The database uses soft delete pattern. See the 
[Backend Database Schema](https://github.com/your-org/ae-infinity-api/blob/main/docs/DB_SCHEMA.md) 
for complete details.

> **Local Path**: `../ae-infinity-api/docs/DB_SCHEMA.md` (if backend repo is a sibling)

For API endpoints, check the [API Specification](https://github.com/your-org/ae-infinity-context/blob/main/API_SPEC.md) 
in the context repository.

> **Local Path**: `../ae-infinity-context/API_SPEC.md`
```

**Benefits**:
- GitHub links always work
- Local paths provided as convenience
- Clear that these are external references

---

## 🎯 Which Pattern to Use?

### Use Pattern 1 (GitHub URL Primary) When:
- Reference is critical for understanding
- Document might be viewed in isolation (e.g., on GitHub)
- Audience may not have local setup

### Use Pattern 2 (Dual Link) When:
- Document has multiple cross-repo references
- Want to support both local and remote workflows
- Need to be explicit about external dependencies

### Use Pattern 3 (Smart Link) When:
- Reference is inline within paragraph
- Want natural reading flow
- Secondary reference (nice-to-have)

### Use Pattern 4 (Reference Section) When:
- Many cross-repo references
- Want centralized access methods
- Document is primarily about cross-repo content

---

## 🔍 Validation

Use the validation script to check references:

```bash
# Validate all markdown files
./scripts/validate-refs.sh

# Validate specific directory
./scripts/validate-refs.sh docs/

# Check single file
grep -o '\.\./[^)]*\.md' FILE.md | while read ref; do
  [ -f "$ref" ] && echo "✅ $ref" || echo "❌ $ref"
done
```

---

## 🔗 Related

- [CROSS_REPO_REFERENCES.md](./CROSS_REPO_REFERENCES.md) - Complete system documentation
- [.repo-references.json](../.repo-references.json) - Configuration file
- [validate-refs.sh](../scripts/validate-refs.sh) - Validation tool

---

**Best Practice**: Always provide at least a GitHub URL for cross-repo references. Local paths are convenience only.

