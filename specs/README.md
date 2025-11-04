# Feature Specifications

**Last Updated**: November 4, 2025  
**Methodology**: Specification-Driven Development (SDD)  
**Purpose**: Complete feature specifications from planning to delivery

---

## 🎯 What is SDD?

**Specification-Driven Development** is a methodology that emphasizes:

1. **Specification First** - Define requirements before coding
2. **Comprehensive Planning** - Think through the entire feature
3. **Living Documentation** - Keep specs updated with reality
4. **Structured Workflow** - Follow proven phases

### SDD Workflow

```
Brief → Research → Specify → Plan → Tasks → Implement → Complete
  ↓        ↓         ↓        ↓       ↓         ↓          ↓
30min   Hours     Days    Days   Hours    Weeks     Archive
```

---

## 📂 Directory Structure

```
specs/
├── README.md           # This file - navigation
├── index.json          # Machine-readable registry
├── active/             # 🚧 Features in development
├── backlog/            # 📋 Planned features
├── completed/          # ✅ Delivered features
└── archive/            # 📦 Reference material
```

---

## 🚧 Active Features

Features currently in development.

### [feat-001-live-updates](./active/feat-001-live-updates/)
**Real-time Live Updates for Shopping Lists**

- **Status**: 📝 Specification Complete
- **Phase**: Planning / Ready for Implementation
- **Priority**: High
- **Estimated**: 12-16 days
- **Description**: SignalR-based real-time synchronization for collaborative shopping

**Documents**:
- [README.md](./active/feat-001-live-updates/README.md) - Overview
- [LIVE_UPDATES_SPEC.md](./active/feat-001-live-updates/LIVE_UPDATES_SPEC.md) - Requirements
- [SIGNALR_ARCHITECTURE.md](./active/feat-001-live-updates/SIGNALR_ARCHITECTURE.md) - Architecture
- [SIGNALR_API_SPEC.md](./active/feat-001-live-updates/SIGNALR_API_SPEC.md) - API Contract
- [LIVE_UPDATES_IMPLEMENTATION_GUIDE.md](./active/feat-001-live-updates/LIVE_UPDATES_IMPLEMENTATION_GUIDE.md) - Implementation Steps

---

## 📋 Backlog

Planned features not yet started.

See [backlog/](./backlog/) for upcoming features.

**Potential Next Features**:
- Item images and photo upload
- Advanced search and filters
- Shopping list templates
- Price tracking
- Store location mapping
- Recipe integration

---

## ✅ Completed Features

Successfully delivered features moved to [completed/](./completed/).

**Current Status**: No features completed yet (initial development phase)

---

## 📦 Archive

Reference material including legacy feature documentation.

### [archive/features/](./archive/features/)
Original feature-driven documentation preserved for reference:

| Feature Domain | Description | Status |
|---------------|-------------|---------|
| [authentication](./archive/features/authentication/) | User auth & profile management | 80% Backend, 80% Frontend |
| [lists](./archive/features/lists/) | Shopping list CRUD | 100% Backend, 70% Frontend |
| [items](./archive/features/items/) | Shopping item management | 90% Backend, 70% Frontend |
| [collaboration](./archive/features/collaboration/) | Sharing & permissions | 90% Backend, 70% Frontend |
| [categories](./archive/features/categories/) | Item categorization | 100% Backend, 100% Frontend |
| [search](./archive/features/search/) | Global search | 100% Backend, 100% Frontend |
| [realtime](./archive/features/realtime/) | Live updates (being replaced by feat-001) | 0% |
| [ui-components](./archive/features/ui-components/) | Component library | 10% |
| [infrastructure](./archive/features/infrastructure/) | Cross-cutting concerns | Partial |

---

## 🔄 SDD Workflow Phases

### Phase 1: Brief (`/brief`) - 30 Minutes
- **Purpose**: Quick planning for rapid development
- **Output**: `feature-brief.md`
- **Best For**: Small to medium features, clear requirements

### Phase 2: Research (`/research`) - Hours to Days
- **Purpose**: Investigate patterns and solutions
- **Output**: `research.md`
- **Best For**: Complex features, new technologies

### Phase 3: Specify (`/specify`) - Days
- **Purpose**: Define WHAT to build
- **Output**: `spec.md`
- **Best For**: Features needing detailed requirements

### Phase 4: Plan (`/plan`) - Days
- **Purpose**: Define HOW to build
- **Output**: `plan.md`
- **Best For**: Technical architecture decisions

### Phase 5: Tasks (`/tasks`) - Hours
- **Purpose**: Break down into actionable items
- **Output**: `tasks.md`
- **Best For**: Implementation planning

### Phase 6: Implement (`/implement`) - Weeks
- **Purpose**: Build the feature
- **Output**: Code, tests, documentation
- **Best For**: Execution phase

### Phase 7: Complete - Ongoing
- **Purpose**: Deliver and maintain
- **Output**: Production feature, updated docs
- **Best For**: Feature complete and in production

---

## 📊 Feature Status Indicators

- 📝 **Specification** - Requirements being defined
- 🎨 **Design** - UI/UX design in progress
- 🛠️ **Planning** - Technical planning phase
- 🚧 **Development** - Actively coding
- 🧪 **Testing** - QA and testing phase
- 🔍 **Review** - Code review in progress
- ✅ **Complete** - Delivered to production
- ❌ **Cancelled** - Feature not proceeding
- ⏸️ **On Hold** - Paused for dependencies

---

## 🎯 Creating New Feature Specs

### Quick Start (Brief)
```bash
# Use the brief command for rapid development
/brief "Feature name and description"
```

### Comprehensive Specification
```bash
# Follow the full SDD workflow
/research "Feature investigation"
/specify "Feature requirements"
/plan "Technical approach"
/tasks "Break into tasks"
/implement "Execute implementation"
```

### Full Project Planning
```bash
# Create complete project roadmap
/sdd-full-plan "Project goals and scope"
```

---

## 📐 Specification Templates

Located in `../.sdd/templates/`:

| Template | Purpose |
|----------|---------|
| `feature-brief-v2.md` | Quick planning (SDD 2.5) |
| `spec-template.md` | Detailed requirements |
| `plan-template.md` | Technical architecture |
| `tasks-template.md` | Implementation tasks |
| `research-template.md` | Investigation findings |
| `roadmap-template.md` | Project-level planning |

---

## 🔗 Related Documentation

### Project Documentation
- [../docs/project/](../docs/project/) - Project specifications
- [../docs/api/](../docs/api/) - API specifications
- [../docs/personas/](../docs/personas/) - User personas
- [../docs/journeys/](../docs/journeys/) - User journeys

### SDD Framework
- [../.sdd/guidelines.md](../.sdd/guidelines.md) - SDD methodology
- [../.sdd/templates/](../.sdd/templates/) - Document templates
- [../.cursor/commands/](../.cursor/commands/) - SDD commands

---

## 📝 Best Practices

### When to Create a Spec
- **Always**: For new features or major changes
- **Maybe**: For small enhancements (brief may suffice)
- **Never**: For bug fixes (use issue tracking instead)

### Keeping Specs Current
1. **Update during development** when requirements change
2. **Mark sections outdated** if implementation differs
3. **Archive completed specs** to completed/ folder
4. **Reference from code** via comments linking to specs

### Naming Conventions
- **Format**: `feat-XXX-descriptive-name`
- **Example**: `feat-001-live-updates`
- **Consistency**: Use hyphens, lowercase, descriptive

---

## 🤝 Contributing

### Adding New Feature Specs
1. Create folder in `active/`: `feat-XXX-name/`
2. Follow SDD workflow phases
3. Use templates from `.sdd/templates/`
4. Update this README with feature entry
5. Update `index.json` registry

### Moving Features
- **To Completed**: When feature is in production
- **To Backlog**: When postponed
- **To Archive**: When cancelled or replaced

---

## 💡 Tips for Success

1. **Start Small**: Use `/brief` for most features
2. **Upgrade When Needed**: Use `/upgrade` if complexity grows
3. **Keep It Real**: Update specs when implementation changes
4. **Link Everything**: Cross-reference related docs
5. **Review Regularly**: Quarterly spec reviews catch drift

---

**Remember**: Specs are living documents that evolve with the project! 🚀

