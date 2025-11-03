# Collaboration & Sharing

**Feature Domain**: Collaboration & Sharing  
**Version**: 1.0  
**Status**: 90% Backend, 70% Frontend, 0% Integrated

---

## Overview

Features for sharing lists with other users, managing collaborators, and permission levels.

---

## Features

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| Share List | POST `/lists/{id}/share` | ✅ | 🟡 UI Ready | Ready for Integration |
| View Collaborators | Included in GET `/lists/{id}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Remove Collaborator | DELETE `/lists/{id}/collaborators/{userId}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Change Permission | PATCH `/lists/{id}/collaborators/{userId}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Accept Invite | POST `/invites/{token}/accept` | ❌ | ✅ UI Complete | Blocked by Backend |
| View Pending Invites | GET `/invites` | ❌ | 🟡 UI Placeholder | Not Started |
| Cancel Invite | DELETE `/invites/{id}` | ❌ | 🟡 UI Placeholder | Not Started |

---

## Permission Levels

| Permission | Can View | Can Add/Edit Items | Can Delete Items | Can Manage Collaborators | Can Delete List |
|------------|----------|-------------------|------------------|-------------------------|----------------|
| **Owner** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Editor** | ✅ | ✅ | ✅ | ❌ | ❌ |
| **Viewer** | ✅ | ❌ | ❌ | ❌ | ❌ |

**Note**: All users (including Viewers) can mark items as purchased.

See [permission-matrix.md](../../personas/permission-matrix.md) for complete details.

---

## API Specification

See [API_SPEC.md](../../API_SPEC.md) lines 283-346

### POST /lists/{listId}/share

Request Body:
```json
{
  "email": "user@example.com",
  "permission": "Editor" | "Viewer"
}
```

Response:
```json
{
  "inviteId": "string",
  "email": "string",
  "permission": "Editor" | "Viewer",
  "invitedAt": "ISO 8601 date",
  "status": "Pending" | "Accepted"
}
```

### PATCH /lists/{listId}/collaborators/{userId}

Request Body:
```json
{
  "permission": "Owner" | "Editor" | "Viewer"
}
```

---

## Frontend Implementation

### Pages
- **ShareList** (`/lists/:listId/share`) 🟡
  - Email input for inviting users
  - Permission dropdown
  - Share button
  - List of pending invitations
  - **Needs**: Integration with listsService.shareList()

- **ManageCollaborators** (`/lists/:listId/collaborators`) 🟡
  - List of current collaborators
  - Permission badges
  - Change permission dropdown
  - Remove collaborator button
  - **Needs**: Integration with list details API

- **AcceptInvite** (`/invite/:token`) ✅
  - Invitation acceptance flow
  - Shows list details
  - Accept/Decline buttons
  - **Needs**: Backend endpoint

### Services
**Location**: `ae-infinity-ui/src/services/listsService.ts` ✅

Collaboration methods implemented:
- `shareList(listId, data)`
- `removeCollaborator(listId, userId)`
- `updateCollaboratorPermission(listId, userId, data)`

### Utilities
**Location**: `ae-infinity-ui/src/utils/permissions.ts` ✅

Permission helper functions:
- `canEdit(permission)` - Check if user can edit
- `canManageCollaborators(permission)` - Check if user can manage collaborators
- `canDeleteList(permission)` - Check if user can delete
- `canAddItems(permission)` - Check if user can add items
- `canEditItems(permission)` - Check if user can edit items
- `canDeleteItems(permission)` - Check if user can delete items
- `canMarkPurchased(permission)` - Check if user can mark as purchased (always true)
- `getPermissionColor(permission)` - Get badge color
- `getPermissionDescription(permission)` - Get human-readable description

---

## Backend Implementation

### Controllers
**Location**: `ae-infinity-api/src/AeInfinity.Api/Controllers/ListsController.cs` ✅

Share and collaborator management endpoints implemented.

### Features (CQRS)
**Location**: `ae-infinity-api/src/AeInfinity.Application/Features/Lists/`

- ShareList command ✅
- RemoveCollaborator command ✅
- UpdateCollaboratorPermission command ✅
- **Missing**: Accept invite, pending invites, cancel invite

---

## Data Models

### Database Entity

```csharp
public class UserToList : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; }
    public Guid ListId { get; set; }
    public List List { get; set; }
    public PermissionLevel Permission { get; set; }
    public DateTime InvitedAt { get; set; }
    public DateTime? AcceptedAt { get; set; }
}

public enum PermissionLevel
{
    Owner,
    Editor,
    Viewer
}
```

### TypeScript Types

```typescript
interface ListCollaborator {
  userId: string
  displayName: string
  avatarUrl: string | null
  permission: 'Owner' | 'Editor' | 'Viewer'
  invitedAt: string
  acceptedAt: string | null
  isPending: boolean
}
```

---

## Integration Steps

### 1. Implement Missing Backend Endpoints
- [ ] POST `/invites/{token}/accept` - Accept invitation
- [ ] GET `/invites` - Get my pending invitations
- [ ] DELETE `/invites/{id}` - Cancel invitation

### 2. Update ShareList Page
```typescript
const handleShare = async (email: string, permission: Permission) => {
  try {
    await listsService.shareList(listId, { email, permission })
    // Show success message
    // Refresh pending invitations list
  } catch (error) {
    // Show error message
  }
}
```

### 3. Update ManageCollaborators Page
```typescript
// Fetch list with collaborators
const list = await listsService.getListById(listId)
setCollaborators(list.collaborators)

// Remove collaborator
const handleRemove = async (userId: string) => {
  await listsService.removeCollaborator(listId, userId)
  // Refresh collaborators
}

// Change permission
const handleChangePermission = async (userId: string, permission: Permission) => {
  await listsService.updateCollaboratorPermission(listId, userId, { permission })
  // Refresh collaborators
}
```

---

## User Stories

### Share List
```
As a list owner
I want to share my list with another user
So that we can collaborate on shopping together
```

**Acceptance Criteria**:
- Enter email address of user to invite
- Select permission level (Editor or Viewer)
- User receives invitation
- Invited user can accept/decline
- List owner can see pending invitations

### Manage Collaborators
```
As a list owner
I want to manage who has access to my list
So that I can control collaboration
```

**Acceptance Criteria**:
- View all current collaborators
- See their permission levels
- Change someone's permission
- Remove collaborators
- Cannot remove or change owner

### Accept Invitation
```
As an invited user
I want to accept an invitation to a shared list
So that I can start collaborating
```

**Acceptance Criteria**:
- Receive invitation link/email
- View list details before accepting
- Accept or decline invitation
- On accept, list appears in "Shared with Me"

---

## Validation Rules

### Share List
- Email must be valid format
- Email must exist in system (registered user)
- Cannot invite same user twice
- Cannot invite yourself
- Permission must be Editor or Viewer (not Owner)

### Change Permission
- Only owner can change permissions
- Cannot change owner's permission
- Cannot remove owner
- Must be a valid permission level

---

## Security Considerations

### Authorization Checks
- Verify user has Owner permission before allowing:
  - Share list
  - Remove collaborator
  - Change permissions
  - Delete list

- Verify user has Editor permission before allowing:
  - Add/edit/delete items

- All users can:
  - View list (if they have any permission)
  - Mark items as purchased

### Invitation Tokens
- Should be unique, random, and secure
- Should expire after 7 days
- Should be single-use
- Should include list ID and inviter ID

---

## Next Steps

1. 🔄 Implement accept invite endpoint
2. 🔄 Implement pending invitations API
3. 🔄 Update ShareList page with real API
4. 🔄 Update ManageCollaborators page with real API
5. 🔄 Test permission enforcement
6. 🔄 Add email notifications for invitations

---

## Related Features

- [Lists](../lists/) - List management
- [Authentication](../authentication/) - User management
- [Real-time](../realtime/) - Live collaborator presence

