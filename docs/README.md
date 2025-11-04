# Documentation

**Last Updated**: November 4, 2025  
**Purpose**: Centralized project documentation following SDD best practices

---

## 📚 Documentation Structure

This documentation is organized into logical sections for easy navigation and maintenance.

---

## 🎯 Quick Navigation

### For New Team Members
1. Start with [Project Specification](./project/PROJECT_SPEC.md)
2. Review [Architecture](./project/ARCHITECTURE.md)
3. Read [Development Guide](./project/DEVELOPMENT_GUIDE.md)
4. Check [Feature Status](./project/FEATURES.md)

### For Product/Design
- [User Personas](./personas/) - Who are our users?
- [User Journeys](./journeys/) - How do users accomplish their goals?
- [Feature Status](./project/FEATURES.md) - What's implemented?

### For Developers
- [Development Guide](./project/DEVELOPMENT_GUIDE.md) - Setup and workflow
- [API Specification](./api/API_SPEC.md) - REST API contracts
- [Architecture](./project/ARCHITECTURE.md) - System design
- [Data Models](./api/data-models.md) - Database schema

---

## 📂 Directory Organization

### [project/](./project/) - Project-Level Documentation
Core project documentation that defines what we're building.

| Document | Purpose | Update When |
|----------|---------|-------------|
| [PROJECT_SPEC.md](./project/PROJECT_SPEC.md) | High-level requirements and goals | Major feature additions |
| [ARCHITECTURE.md](./project/ARCHITECTURE.md) | System architecture and tech stack | Architectural changes |
| [DEVELOPMENT_GUIDE.md](./project/DEVELOPMENT_GUIDE.md) | Setup and development workflow | Process changes |
| [FEATURES.md](./project/FEATURES.md) | Feature implementation tracker | After each feature update |

---

### [api/](./api/) - API & Technical Specifications
Technical contracts and interface definitions.

| Document | Purpose | Update When |
|----------|---------|-------------|
| [API_SPEC.md](./api/API_SPEC.md) | Complete REST API specification | Adding/modifying endpoints |
| [COMPONENT_SPEC.md](./api/COMPONENT_SPEC.md) | UI component specifications | Adding UI components |
| [data-models.md](./api/data-models.md) | Database schema and entities | Schema changes |

---

### [personas/](./personas/) - User Personas
Detailed user types and their needs.

| Document | Description |
|----------|-------------|
| [README.md](./personas/README.md) | Personas overview |
| [list-creator.md](./personas/list-creator.md) | Owner persona (Sarah) |
| [active-collaborator.md](./personas/active-collaborator.md) | Editor persona (Mike) |
| [passive-viewer.md](./personas/passive-viewer.md) | Viewer persona (Emma) |
| [permission-matrix.md](./personas/permission-matrix.md) | Complete permission reference |

---

### [journeys/](./journeys/) - User Journey Maps
Step-by-step flows showing how users accomplish tasks.

| Document | Journey |
|----------|---------|
| [README.md](./journeys/README.md) | Journeys overview |
| [creating-first-list.md](./journeys/creating-first-list.md) | First-time user experience |
| [shopping-together.md](./journeys/shopping-together.md) | Real-time collaboration |

---

## 🔗 Related Content

### Feature Specifications
See [../specs/](../specs/) for detailed feature specifications following SDD methodology.

### Code Repositories
- **Backend**: `ae-infinity-api` - .NET 8 Web API
- **Frontend**: `ae-infinity-ui` - React + TypeScript + Vite

---

## 📝 Documentation Standards

### Writing Style
- **Clear and Concise**: Use simple language
- **Action-Oriented**: Focus on what and how
- **Up-to-Date**: Keep synchronized with implementation
- **Well-Linked**: Cross-reference related documents

### Structure Guidelines
- Use Markdown formatting consistently
- Include table of contents for long documents
- Add status indicators (✅ 🟡 ❌)
- Keep file names lowercase with hyphens

### Maintenance
- Update documentation alongside code changes
- Review quarterly for accuracy
- Archive outdated information
- Use clear commit messages: `docs: Update X documentation`

---

## 🤝 Contributing

### When to Update Documentation

**Always Update**:
- Adding/removing features
- Changing API contracts
- Modifying architecture
- Updating workflow processes

**Review and Update**:
- Quarterly documentation review
- When onboarding new team members
- After major releases
- When specs drift from implementation

### How to Update

1. **Make Changes**: Edit the relevant markdown file
2. **Update References**: Fix any broken links
3. **Update Metadata**: Adjust "Last Updated" dates
4. **Commit**: Use descriptive commit message
5. **Notify Team**: Announce significant changes

---

## 🎯 Document Status Legend

- ✅ **Complete** - Fully documented and current
- 🟡 **Partial** - Needs updates or expansion
- ❌ **Outdated** - Requires significant revision
- 🚧 **In Progress** - Currently being updated

---

## 📞 Questions or Feedback?

- **Documentation Issues**: Create an issue or PR
- **Clarifications Needed**: Reach out to the team
- **Suggestions**: Open a discussion

---

**Remember**: Good documentation is a living resource that grows with the project! 📖

