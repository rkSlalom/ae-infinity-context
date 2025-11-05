# Shopping Lists Management

**Feature Domain**: Shopping Lists  
**Version**: 1.0  
**Status**: 100% Backend, 70% Frontend, 0% Integrated

---

## Overview

Core functionality for creating, viewing, updating, and managing shopping lists.

---

## Features

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| Create List | POST `/lists` | ✅ | 🟡 UI Ready | Ready for Integration |
| Get All Lists | GET `/lists` | ✅ | 🟡 UI Ready | Ready for Integration |
| Get List Details | GET `/lists/{id}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Update List | PUT `/lists/{id}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Delete List | DELETE `/lists/{id}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Archive List | PUT `/lists/{id}` (isArchived: true) | ✅ | ✅ | Ready for Integration |
| Unarchive List | PUT `/lists/{id}` (isArchived: false) | ✅ | ✅ | Ready for Integration |
| List Filtering | GET `/lists?includeArchived=...` | ✅ | 🟡 UI Ready | Ready for Integration |
| List Sorting | GET `/lists?sortBy=...&sortOrder=...` | ✅ | 🟡 UI Ready | Ready for Integration |
| List Pagination | GET `/lists?page=...&pageSize=...` | ✅ | ❌ | Backend Only |

---

## API Specification

See [API_SPEC.md](../../API_SPEC.md) lines 118-280

### Endpoints

#### GET /lists
Query Parameters:
- `includeArchived?: boolean` (default: false)
- `page?: number` (default: 1)
- `pageSize?: number` (default: 20, max: 100)
- `sortBy?: string` (default: "updatedAt")
- `sortOrder?: 'asc' | 'desc'` (default: "desc")

#### POST /lists
Request Body:
```json
{
  "name": "string (1-100 chars, required)",
  "description": "string (max 500 chars, optional)"
}
```

#### PUT /lists/{listId}
Request Body:
```json
{
  "name": "string (optional)",
  "description": "string (optional)",
  "isArchived": "boolean (optional)"
}
```

---

## Frontend Implementation

### Pages
- **ListsDashboard** (`/lists`) 🟡
  - Grid/list view toggle
  - Filter controls (owned, shared, archived)
  - Sort options
  - Search functionality
  - Create new list button
  - **Uses**: Mock data

- **ListDetail** (`/lists/:listId`) 🟡
  - List header with name, description
  - Items list with checkboxes
  - Quick add item form
  - Collaborators sidebar
  - Action buttons (Settings, Share, History)
  - **Uses**: Mock data

- **CreateList** (`/lists/new`) 🟡
  - Form with name and description
  - Validation
  - **Needs**: Integration with listsService.createList()

- **ListSettings** (`/lists/:listId/settings`) 🟡
  - Edit list details
  - Archive/Delete buttons (permission-based)
  - **Needs**: Integration with listsService.updateList()

- **SharedLists** (`/shared`) ✅
  - Grid of lists shared with user
  - Permission badges
  - Progress indicators
  - **Needs**: Replace mock data

- **ArchivedLists** (`/archived`) ✅
  - List of archived lists
  - Unarchive/Delete actions
  - **Needs**: Replace mock data

### Services
**Location**: `ae-infinity-ui/src/services/listsService.ts` ✅

All methods implemented and ready:
- `getAllLists(params)`
- `getListById(id)`
- `createList(data)`
- `updateList(id, data)`
- `deleteList(id)`
- `archiveList(id)`
- `unarchiveList(id)`

---

## Backend Implementation

### Controllers
**Location**: `ae-infinity-api/src/AeInfinity.Api/Controllers/ListsController.cs` ✅

All endpoints implemented.

### Features (CQRS)
**Location**: `ae-infinity-api/src/AeInfinity.Application/Features/Lists/`

- CreateList command ✅
- GetLists query ✅
- GetListById query ✅
- UpdateList command ✅
- DeleteList command ✅
- Archive/Unarchive commands ✅

---

## Data Models

### Database Entity

```csharp
public class List : BaseAuditableEntity
{
    public string Name { get; set; }
    public string? Description { get; set; }
    public Guid OwnerId { get; set; }
    public User Owner { get; set; }
    public bool IsArchived { get; set; }
    public ICollection<ListItem> Items { get; set; }
    public ICollection<UserToList> Collaborators { get; set; }
}
```

### TypeScript Types

```typescript
interface ShoppingListSummary {
  id: string
  name: string
  description: string | null
  ownerId: string
  ownerName: string
  isArchived: boolean
  myPermission: 'Owner' | 'Editor' | 'Viewer'
  itemCount: number
  purchasedCount: number
  collaboratorCount: number
  createdAt: string
  updatedAt: string
}

interface ShoppingListDetail {
  id: string
  name: string
  description: string | null
  ownerId: string
  ownerName: string
  isArchived: boolean
  myPermission: 'Owner' | 'Editor' | 'Viewer'
  collaborators: ListCollaborator[]
  createdAt: string
  updatedAt: string
}
```

---

## Integration Steps

### Replace Mock Data in ListsDashboard

**Current** (Mock):
```typescript
const [lists, setLists] = useState(mockLists)
```

**Target** (Real API):
```typescript
useEffect(() => {
  const fetchLists = async () => {
    try {
      setLoading(true)
      const response = await listsService.getAllLists({
        includeArchived: false,
        sortBy: 'updatedAt',
        sortOrder: 'desc'
      })
      setLists(response.lists)
    } catch (error) {
      setError(error.message)
    } finally {
      setLoading(false)
    }
  }
  fetchLists()
}, [])
```

### Similar Updates Needed For
- ListDetail page
- SharedLists page
- ArchivedLists page
- CreateList page

---

## User Stories

### Create List
```
As a user
I want to create a new shopping list
So that I can start tracking items I need to buy
```

### View My Lists
```
As a user
I want to see all my lists in one place
So that I can quickly access any list
```

### Archive Completed Lists
```
As a user
I want to archive lists I've completed
So that my active lists stay organized
```

---

## Validation Rules

### List Name
- Required
- 1-100 characters
- No leading/trailing whitespace

### List Description
- Optional
- Max 500 characters

---

## Next Steps

1. ✅ Backend complete
2. 🔄 Update ListsDashboard to use real API
3. 🔄 Update ListDetail to use real API
4. 🔄 Update CreateList to use real API
5. 🔄 Add pagination to UI
6. 🔄 Test all list operations end-to-end

---

## Related Features

- [Items](../items/) - Items within lists
- [Collaboration](../collaboration/) - Sharing and permissions
- [Real-time](../realtime/) - Live updates

