# Migration Guide: Finding Your Files After Reorganization

**Date**: November 4, 2025  
**Version**: 2.0

---

## 🗺️ Quick Reference: Where Did My File Go?

### Root Documentation Files

| Old Location | New Location | Quick Link |
|-------------|--------------|------------|
| `PROJECT_SPEC.md` | `docs/project/PROJECT_SPEC.md` | [📋 Link](./project/PROJECT_SPEC.md) |
| `ARCHITECTURE.md` | `docs/project/ARCHITECTURE.md` | [🏗️ Link](./project/ARCHITECTURE.md) |
| `DEVELOPMENT_GUIDE.md` | `docs/project/DEVELOPMENT_GUIDE.md` | [💻 Link](./project/DEVELOPMENT_GUIDE.md) |
| `FEATURES.md` | `docs/project/FEATURES.md` | [✅ Link](./project/FEATURES.md) |
| `API_SPEC.md` | `docs/api/API_SPEC.md` | [🔌 Link](./api/API_SPEC.md) |
| `COMPONENT_SPEC.md` | `docs/api/COMPONENT_SPEC.md` | [🎨 Link](./api/COMPONENT_SPEC.md) |
| `data-models.md` | `docs/api/data-models.md` | [🗄️ Link](./api/data-models.md) |

### Directories

| Old Location | New Location | Quick Link |
|-------------|--------------|------------|
| `personas/` | `docs/personas/` | [👥 Link](./personas/) |
| `journeys/` | `docs/journeys/` | [🗺️ Link](./journeys/) |
| `features/` | `specs/archive/features/` | [📦 Link](../specs/archive/features/) |
| `specs/feat-001-live-update/` | `specs/active/feat-001-live-updates/` | [🚧 Link](../specs/active/feat-001-live-updates/) |

---

## 📖 Common Tasks: How to Find What You Need

### I Need Project Information

**Looking for**: Project overview, goals, requirements  
**Go to**: [docs/project/PROJECT_SPEC.md](./project/PROJECT_SPEC.md)

### I Need Technical Architecture

**Looking for**: System design, tech stack, patterns  
**Go to**: [docs/project/ARCHITECTURE.md](./project/ARCHITECTURE.md)

### I Need API Documentation

**Looking for**: REST endpoints, SignalR events  
**Go to**: [docs/api/API_SPEC.md](./api/API_SPEC.md)

### I Need Database Schema

**Looking for**: Tables, relationships, entity definitions  
**Go to**: [docs/api/data-models.md](./api/data-models.md)

### I Need Setup Instructions

**Looking for**: Environment setup, development workflow  
**Go to**: [docs/project/DEVELOPMENT_GUIDE.md](./project/DEVELOPMENT_GUIDE.md)

### I Need Feature Status

**Looking for**: What's implemented, what's pending  
**Go to**: [docs/project/FEATURES.md](./project/FEATURES.md)

### I Need User Personas

**Looking for**: User types, permissions, behaviors  
**Go to**: [docs/personas/](./personas/)

### I Need User Journeys

**Looking for**: User flows, step-by-step workflows  
**Go to**: [docs/journeys/](./journeys/)

### I Need Feature Specifications

**Looking for**: Detailed feature specs following SDD  
**Go to**: [specs/active/](../specs/active/) (or [specs/README.md](../specs/README.md))

### I Need Old Feature Documentation

**Looking for**: Original features/ content  
**Go to**: [specs/archive/features/](../specs/archive/features/)

---

## 🔍 Updating Your Bookmarks

If you had bookmarks to old paths, update them:

### Documentation Bookmarks

```
OLD: /PROJECT_SPEC.md
NEW: /docs/project/PROJECT_SPEC.md

OLD: /API_SPEC.md
NEW: /docs/api/API_SPEC.md

OLD: /DEVELOPMENT_GUIDE.md
NEW: /docs/project/DEVELOPMENT_GUIDE.md
```

### Directory Bookmarks

```
OLD: /features/
NEW: /specs/archive/features/

OLD: /personas/
NEW: /docs/personas/

OLD: /journeys/
NEW: /docs/journeys/
```

---

## 🛠️ Updating Your Scripts

If you have scripts that reference old paths, update them:

### Git Pre-commit Hooks

```bash
# OLD
if [[ -f "PROJECT_SPEC.md" ]]; then
  
# NEW
if [[ -f "docs/project/PROJECT_SPEC.md" ]]; then
```

### CI/CD Pipelines

```yaml
# OLD
- name: Validate specs
  run: |
    markdown-lint *.md
    
# NEW
- name: Validate specs
  run: |
    markdown-lint docs/**/*.md
    markdown-lint specs/**/*.md
```

### Documentation Generators

```bash
# OLD
find . -name "*.md" -path "*/features/*"

# NEW
find . -name "*.md" -path "*/specs/archive/features/*"
```

---

## 📝 Updating Your Code Comments

If your code has comments with doc links:

```typescript
// OLD
// See: PROJECT_SPEC.md for details

// NEW
// See: docs/project/PROJECT_SPEC.md for details
```

```csharp
// OLD
/// <summary>
/// Implements feature as per features/authentication/README.md
/// </summary>

// NEW
/// <summary>
/// Implements feature as per specs/archive/features/authentication/README.md
/// </summary>
```

---

## 🚀 New Ways to Navigate

### Entry Points

1. **[../README.md](../README.md)** - Start here for overview
2. **[docs/README.md](./README.md)** - Documentation hub
3. **[specs/README.md](../specs/README.md)** - Specifications hub

### For Developers

```
../README.md
  ├─ docs/project/DEVELOPMENT_GUIDE.md (setup)
  ├─ docs/api/API_SPEC.md (endpoints)
  └─ specs/active/ (current features)
```

### For Product/Design

```
../README.md
  ├─ docs/personas/ (user types)
  ├─ docs/journeys/ (user flows)
  └─ docs/project/FEATURES.md (status)
```

### For Architects

```
../README.md
  ├─ docs/project/ARCHITECTURE.md (design)
  ├─ docs/api/data-models.md (schema)
  └─ specs/active/ (technical specs)
```

---

## 💡 Benefits of New Structure

### Cleaner Root
- **Before**: 8+ markdown files cluttering root
- **After**: Just README and REORGANIZATION_SUMMARY

### Logical Organization
- **Before**: Flat structure, hard to navigate
- **After**: Hierarchical, organized by purpose

### SDD Compliance
- **Before**: Partial SDD adoption
- **After**: Full SDD methodology in specs/

### Better Navigation
- **Before**: No clear entry points
- **After**: README files guide you

### Scalability
- **Before**: Would get messier with growth
- **After**: Structure supports expansion

---

## 🤔 Frequently Asked Questions

### Q: Why was features/ moved to specs/archive/?

**A**: To align with SDD methodology. Active features now follow the SDD workflow in `specs/active/`, while the original feature documentation is preserved for reference in the archive.

### Q: Can I still access old feature documentation?

**A**: Yes! All original content is preserved in `specs/archive/features/`. Nothing was deleted.

### Q: Where do I put new documentation?

**A**: 
- **Project docs**: `docs/project/`
- **API docs**: `docs/api/`
- **User research**: `docs/personas/` or `docs/journeys/`
- **Feature specs**: Use `/brief` command or create in `specs/active/`

### Q: Will git history be preserved?

**A**: Yes! Files were moved (not deleted and recreated), so all git history is intact.

### Q: Do I need to update my local branches?

**A**: Yes, after pulling the reorganization, you may need to resolve conflicts if you modified files that were moved.

### Q: What if I find a broken link?

**A**: Please update it! The main cross-references have been updated, but some internal links in archived content may need fixes.

---

## 🆘 Need Help?

### If you can't find something:

1. Check the main [README.md](../README.md)
2. Check [docs/README.md](./README.md) for documentation
3. Check [specs/README.md](../specs/README.md) for specifications
4. Use this migration guide as reference
5. Ask the team if still unclear

### If you find broken links:

1. Check this migration guide for correct path
2. Update the link in the file
3. Commit with message: `docs: Fix broken link to X`

---

## 📞 Questions?

Open an issue or reach out to the team if you have questions about the new structure.

---

**Happy navigating!** 🧭

