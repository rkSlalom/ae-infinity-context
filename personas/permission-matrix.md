# Permission Matrix

Complete comparison of permissions across all user roles in AE Infinity.

## 📊 Quick Reference

| Capability | Owner | Editor | Viewer |
|---|:---:|:---:|:---:|
| **List Management** |
| Create new lists | ✅ | ❌ | ❌ |
| Edit list name/description | ✅ | ❌ | ❌ |
| Delete list | ✅ | ❌ | ❌ |
| Archive/unarchive list | ✅ | ❌ | ❌ |
| Transfer ownership | ✅ | ❌ | ❌ |
| **Collaborator Management** |
| Add collaborators | ✅ | ❌ | ❌ |
| Remove collaborators | ✅ | ❌ | ❌ |
| Change permissions | ✅ | ❌ | ❌ |
| View collaborators | ✅ | ✅ | ✅ |
| **Item Management** |
| Add items | ✅ | ✅ | ❌ |
| Edit items | ✅ | ✅ | ❌ |
| Delete items | ✅ | ✅ | ❌ |
| Mark as purchased | ✅ | ✅ | ❌ |
| Reorder items | ✅ | ✅ | ❌ |
| Add notes | ✅ | ✅ | ❌ |
| Add images | ✅ | ✅ | ❌ |
| **Viewing & Search** |
| View lists | ✅ | ✅ | ✅ |
| View items | ✅ | ✅ | ✅ |
| Search items | ✅ | ✅ | ✅ |
| Filter by category | ✅ | ✅ | ✅ |
| View item history | ✅ | ✅ | ✅ |
| See who added items | ✅ | ✅ | ✅ |
| **Real-time Features** |
| See live updates | ✅ | ✅ | ✅ |
| View presence | ✅ | ✅ | ✅ |
| Receive notifications | ✅ | ✅ | ✅ |

## 🎭 Role Descriptions

### Owner (Full Control)

**Identity**: The list creator  
**Access Level**: Unrestricted  
**Primary Responsibility**: List governance and management

**Key Privileges**:
- Only role that can delete lists
- Only role that can manage collaborators
- Only role that can transfer ownership
- Inherits all Editor capabilities
- Cannot be removed from their own list

**Automatic Assignment**:
- User who creates a list automatically becomes Owner
- Only one Owner per list (can be transferred)

**API Reference**: [../api/lists.md](../api/lists.md#ownership)

---

### Editor (Modify Items)

**Identity**: Active collaborator  
**Access Level**: Item management  
**Primary Responsibility**: Maintain and update shopping items

**Key Privileges**:
- Full CRUD operations on items
- Can mark items as purchased
- Can add notes and images
- Cannot modify list settings or collaborators
- Can be promoted to Owner or demoted to Viewer

**Typical Use Case**:
- Family member who shops regularly
- Roommate with equal shopping responsibility
- Trusted friend helping with party planning

**API Reference**: [../api/items.md](../api/items.md#permissions)

---

### Viewer (Read-Only)

**Identity**: Passive observer  
**Access Level**: Read-only  
**Primary Responsibility**: Stay informed

**Key Privileges**:
- View-only access to list and items
- Receive real-time updates
- See presence indicators
- Cannot make any modifications
- Can be promoted to Editor

**Typical Use Case**:
- Teenage child with limited responsibility
- House guest needing to know what's available
- Personal assistant viewing boss's list
- Friend attending a party (viewing menu/supplies)

**API Reference**: [../api/lists.md](../api/lists.md#viewer-access)

## 🔒 Permission Enforcement

### API Level

All API endpoints check permissions before allowing operations:

```typescript
// Example: Update item endpoint
PUT /api/v1/lists/{listId}/items/{itemId}

// Permission Check:
if (user.permission === 'Viewer') {
  return 403 Forbidden;
}
// Owner and Editor can proceed
```

**Reference**: [../api/authentication.md](../api/authentication.md#authorization)

### UI Level

UI elements are conditionally rendered based on user permissions:

```typescript
// Example: Hide delete button for Viewers
{['Owner', 'Editor'].includes(myPermission) && (
  <DeleteButton />
)}

// Show edit form only to Owner
{myPermission === 'Owner' && (
  <EditListForm />
)}
```

**Reference**: [../components/README.md](../components/README.md#permission-based-ui)

### Database Level

Database enforces permissions through foreign key constraints:

```sql
-- Example: Only list owner can delete list
DELETE FROM ShoppingLists 
WHERE Id = @listId 
  AND OwnerId = @userId
```

**Reference**: [../architecture/data-models.md](../architecture/data-models.md#access-control)

## 🔄 Permission Transitions

### Viewer → Editor

**Triggered By**: Owner changes permission  
**Requirements**: None  
**Effect**: User can now modify items

```typescript
PATCH /api/v1/lists/{listId}/collaborators/{userId}/permission
{
  "permission": "Editor"
}
```

**Use Case**: Teenage child proves responsible, gets upgraded access

---

### Editor → Viewer

**Triggered By**: Owner changes permission  
**Requirements**: None  
**Effect**: User loses ability to modify items  
**Note**: User retains view access

**Use Case**: Roommate moving out, downgraded to just stay informed

---

### Editor → Owner (Transfer Ownership)

**Triggered By**: Current Owner transfers ownership  
**Requirements**: Target must already be a collaborator  
**Effect**: 
- Target becomes new Owner
- Original Owner becomes Editor (unless they leave)

```typescript
POST /api/v1/lists/{listId}/transfer-ownership
{
  "newOwnerId": "user-id-here"
}
```

**Use Case**: Spouse takes over household shopping management

---

### Owner → Editor (Not Possible)

**Restriction**: Owner cannot demote themselves  
**Workaround**: Transfer ownership first, then new Owner can change permission  
**Reason**: Prevents orphaned lists without an owner

## 🚫 Permission Restrictions

### What Editors CANNOT Do

Even though Editors have broad permissions, they explicitly CANNOT:

1. ❌ **Modify List Metadata**
   - Change list name
   - Change list description
   - Archive or delete list

2. ❌ **Manage Access**
   - Add collaborators
   - Remove collaborators  
   - Change anyone's permissions
   - Leave the list (must be removed by Owner)

3. ❌ **Transfer Ownership**
   - Cannot make themselves Owner
   - Cannot transfer ownership to others

**Rationale**: List governance remains with Owner to prevent chaos in shared spaces

### What Viewers CANNOT Do

Viewers have strictly read-only access and CANNOT:

1. ❌ **Any Modifications**
   - Cannot add, edit, or delete items
   - Cannot mark items as purchased
   - Cannot add notes or images
   - Cannot reorder items

2. ❌ **Any Management**
   - Cannot modify list settings
   - Cannot manage collaborators
   - Cannot change their own permission (must ask Owner)

**Rationale**: Viewer role is intentionally restrictive for oversight scenarios

## 📋 Permission Scenarios

### Scenario 1: Family Household

**Setup**:
- Sarah (Owner) - Mom who manages household
- Mike (Editor) - Dad who shares shopping
- Emma (Viewer) - Teenage daughter learning responsibility
- Jake (Not invited) - Younger child, too young for app

**Permission Flow**:
1. Sarah creates "Weekly Groceries" list (becomes Owner)
2. Sarah invites Mike as Editor (he shops regularly)
3. Sarah invites Emma as Viewer (wants oversight)
4. Emma proves responsible → Sarah promotes to Editor
5. Later: Sarah transfers ownership to Mike (she's traveling)

---

### Scenario 2: Roommate Situation

**Setup**:
- Alex (Owner) - Created shared apartment list
- Jordan (Editor) - Roommate with equal responsibility
- Casey (Editor) - Another roommate
- Sam (Viewer) - Casey's partner, occasional guest

**Permission Flow**:
1. Alex creates "Apartment Supplies" (becomes Owner)
2. Alex invites Jordan and Casey as Editors (equal partners)
3. Casey invites Sam as Viewer (not a resident, just wants to know)
4. Sam needs to be invited by Alex (Owner), not Casey (Editor)
5. When roommates split up, Alex archives list

---

### Scenario 3: Party Planning

**Setup**:
- Lisa (Owner) - Hosting the party
- Mark (Editor) - Co-host helping with shopping
- Guests (Viewers) - 5 friends who want to see the menu

**Permission Flow**:
1. Lisa creates "New Year's Party" list (Owner)
2. Lisa invites Mark as Editor (will shop with her)
3. Lisa invites guests as Viewers (they want to see what's planned)
4. After party: Lisa archives list but keeps access
5. Next party: Lisa duplicates list, same collaborators

## 🔗 Related Documentation

- **Personas**:
  - [list-creator.md](./list-creator.md) - Owner persona
  - [active-collaborator.md](./active-collaborator.md) - Editor persona
  - [passive-viewer.md](./passive-viewer.md) - Viewer persona

- **API**:
  - [../api/authentication.md](../api/authentication.md) - Auth & authorization
  - [../api/lists.md](../api/lists.md) - List permissions
  - [../api/items.md](../api/items.md) - Item permissions

- **Architecture**:
  - [../architecture/security.md](../architecture/security.md) - Security model
  - [../architecture/data-models.md](../architecture/data-models.md) - Database schema

- **Journeys**:
  - [../journeys/sharing-list.md](../journeys/sharing-list.md) - How to share lists
  - [../journeys/managing-permissions.md](../journeys/managing-permissions.md) - Permission management

