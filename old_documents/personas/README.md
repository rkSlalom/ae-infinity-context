# User Personas

This directory contains detailed user personas for the AE Infinity application. Each persona represents a distinct user type with specific needs, goals, and behaviors.

## 📁 Persona Files

- **[list-creator.md](./list-creator.md)** - The Owner persona (Sarah)
  - Creates and manages lists
  - Full control over list settings
  - Manages collaborators and permissions

- **[active-collaborator.md](./active-collaborator.md)** - The Editor persona (Mike)
  - Actively adds and manages items
  - Shops regularly using shared lists
  - Cannot modify list settings

- **[passive-viewer.md](./passive-viewer.md)** - The Viewer persona (Emma)
  - Views lists for reference
  - Cannot make modifications
  - May transition to editor role

- **[permission-matrix.md](./permission-matrix.md)** - Permission levels reference
  - Complete permission comparison
  - Feature access by role
  - Permission inheritance rules

## 🔗 Related Documentation

- **User Journeys**: [../journeys/](../journeys/) - How personas interact with the system
- **API Permissions**: [../api/authentication.md](../api/authentication.md) - API permission enforcement
- **Architecture**: [../architecture/security.md](../architecture/security.md) - Security model

## 💡 Usage

When building features:
1. **Read relevant persona** to understand user needs
2. **Check permission matrix** to verify what the user can do
3. **Reference user journeys** to see how they accomplish goals
4. **Implement permissions** according to the security model

## 📊 Permission Hierarchy

```
Owner (Full Control)
  ├─ Can do everything Editors can do
  ├─ Manage list settings
  ├─ Add/remove collaborators
  ├─ Change permissions
  ├─ Delete list
  └─ Transfer ownership

Editor (Modify Items)
  ├─ Can do everything Viewers can do
  ├─ Add/edit/delete items
  ├─ Mark items as purchased
  ├─ Reorder items
  └─ Add notes and images

Viewer (Read-Only)
  ├─ View list and items
  ├─ See updates in real-time
  └─ Receive notifications
```

