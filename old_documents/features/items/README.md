# Shopping Items Management

**Feature Domain**: Shopping Items  
**Version**: 1.0  
**Status**: 90% Backend, 70% Frontend, 0% Integrated

---

## Overview

Functionality for adding, editing, and managing items within shopping lists.

---

## Features

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| Add Item | POST `/lists/{id}/items` | ✅ | 🟡 UI Ready | Ready for Integration |
| Get Items | GET `/lists/{id}/items` | ✅ | 🟡 UI Ready | Ready for Integration |
| Update Item | PUT `/lists/{id}/items/{itemId}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Delete Item | DELETE `/lists/{id}/items/{itemId}` | ✅ | 🟡 UI Ready | Ready for Integration |
| Mark Purchased | PATCH `/lists/{id}/items/{itemId}/purchased` | ✅ | 🟡 UI Ready | Ready for Integration |
| Reorder Items | PATCH `/lists/{id}/items/reorder` | ✅ | 🟡 UI Ready | Ready for Integration |
| Item Categories | Via Category ID | ✅ | 🟡 UI Ready | Ready for Integration |
| Item Notes | Part of item model | ✅ | 🟡 UI Ready | Ready for Integration |
| Item Quantities | Part of item model | ✅ | 🟡 UI Ready | Ready for Integration |
| Item Images | imageUrl field | ❌ Upload | 🟡 UI Placeholder | Not Started |

---

## API Specification

See [API_SPEC.md](../../API_SPEC.md) lines 349-551

### Endpoints

#### POST /lists/{listId}/items
Request Body:
```json
{
  "name": "string (1-100 chars, required)",
  "quantity": "number (optional, default: 1)",
  "unit": "string (optional, e.g., 'gallons', 'pieces')",
  "categoryId": "string (optional)",
  "notes": "string (max 500 chars, optional)",
  "imageUrl": "string (optional)"
}
```

#### PATCH /lists/{listId}/items/{itemId}/purchased
Request Body:
```json
{
  "isPurchased": "boolean"
}
```

#### PATCH /lists/{listId}/items/reorder
Request Body:
```json
{
  "itemPositions": [
    {
      "itemId": "string",
      "position": "number"
    }
  ]
}
```

---

## Frontend Implementation

### Components (Needed but Not Built Yet)
Based on COMPONENT_SPEC.md:

- **ShoppingItemRow** ❌
  - Checkbox for purchased status
  - Item name, quantity, unit
  - Category badge
  - Notes (collapsible)
  - Edit/delete actions
  - Drag handle
  - Currently using native HTML

- **ItemForm** ❌
  - Name input
  - Quantity and unit inputs
  - Category dropdown
  - Notes textarea
  - Image upload
  - Currently using native HTML

### Current Implementation
- Items displayed in ListDetail page
- Using native HTML elements
- Basic functionality works with mock data

### Services
**Location**: `ae-infinity-ui/src/services/itemsService.ts` ✅

All methods implemented:
- `getListItems(listId, params)`
- `createItem(listId, data)`
- `updateItem(listId, itemId, data)`
- `deleteItem(listId, itemId)`
- `updatePurchasedStatus(listId, itemId, data)`
- `markAsPurchased(listId, itemId)`
- `markAsNotPurchased(listId, itemId)`
- `reorderItems(listId, data)`

---

## Backend Implementation

### Controllers
**Location**: `ae-infinity-api/src/AeInfinity.Api/Controllers/ListItemsController.cs` ✅

All endpoints implemented.

### Features (CQRS)
**Location**: `ae-infinity-api/src/AeInfinity.Application/Features/ListItems/`

- CreateListItem command ✅
- GetListItems query ✅
- UpdateListItem command ✅
- DeleteListItem command ✅
- UpdatePurchasedStatus command ✅
- ReorderItems command ✅

---

## Data Models

### Database Entity

```csharp
public class ListItem : BaseAuditableEntity
{
    public string Name { get; set; }
    public decimal Quantity { get; set; }
    public string? Unit { get; set; }
    public Guid CategoryId { get; set; }
    public Category Category { get; set; }
    public string? Notes { get; set; }
    public string? ImageUrl { get; set; }
    public bool IsPurchased { get; set; }
    public int Position { get; set; }
    public Guid ListId { get; set; }
    public List List { get; set; }
    public Guid? PurchasedById { get; set; }
    public User? PurchasedBy { get; set; }
    public DateTime? PurchasedAt { get; set; }
}
```

### TypeScript Types

```typescript
interface ShoppingItem {
  id: string
  name: string
  quantity: number
  unit: string | null
  category: CategoryRef
  notes: string | null
  imageUrl: string | null
  isPurchased: boolean
  position: number
  createdBy: UserRef
  createdAt: string
  updatedAt: string
  purchasedBy: UserRef | null
  purchasedAt: string | null
}
```

---

## Permissions

All users (including Viewers) can:
- ✅ Mark items as purchased/unpurchased

Only Editors and Owners can:
- ✅ Add items
- ✅ Edit items
- ✅ Delete items
- ✅ Reorder items

---

## Validation Rules

### Item Name
- Required
- 1-100 characters
- No leading/trailing whitespace

### Quantity
- Optional (default: 1)
- Must be positive number
- Can be decimal (e.g., 2.5)

### Unit
- Optional
- Max 50 characters
- Examples: "gallons", "pounds", "pieces", "boxes"

### Notes
- Optional
- Max 500 characters

### Image URL
- Optional
- Valid URL format
- **Note**: Image upload endpoint not implemented yet

---

## Integration Steps

### Replace Mock Data in ListDetail

**Current** (Mock):
```typescript
const [items, setItems] = useState(mockItems)
```

**Target** (Real API):
```typescript
useEffect(() => {
  const fetchItems = async () => {
    try {
      setLoading(true)
      const response = await itemsService.getListItems(listId, {
        includeCompleted: true
      })
      setItems(response.items)
    } catch (error) {
      setError(error.message)
    } finally {
      setLoading(false)
    }
  }
  fetchItems()
}, [listId])
```

### Add Item Creation

```typescript
const handleAddItem = async (data: CreateItemRequest) => {
  try {
    const newItem = await itemsService.createItem(listId, data)
    setItems([...items, newItem])
  } catch (error) {
    // Handle error
  }
}
```

### Toggle Purchased Status

```typescript
const handleToggle = async (itemId: string, isPurchased: boolean) => {
  try {
    await itemsService.updatePurchasedStatus(listId, itemId, { isPurchased })
    // Update local state
  } catch (error) {
    // Handle error
  }
}
```

---

## User Stories

### Add Item
```
As a list editor
I want to add items to my shopping list
So that I remember what to buy
```

### Mark as Purchased
```
As any list collaborator
I want to check off items as I purchase them
So that others know what's been bought
```

### Reorder Items
```
As a list editor
I want to reorder items
So that I can organize them by store layout
```

---

## Future Enhancements

### Image Upload
- Backend endpoint for image upload
- Blob storage integration (Azure Blob Storage or AWS S3)
- Image compression and thumbnail generation
- Frontend image picker and upload UI

### Smart Suggestions
- Suggest items based on previous lists
- Autocomplete item names
- Category suggestions based on item name

---

## Next Steps

1. ✅ Backend complete (except image upload)
2. 🔄 Update ListDetail to use real API
3. 🔄 Implement item CRUD operations
4. 🔄 Add drag-and-drop reordering UI
5. 🔄 Test purchased status updates
6. 🔄 Add image upload feature

---

## Related Features

- [Lists](../lists/) - Parent list management
- [Categories](../categories/) - Item categorization
- [Real-time](../realtime/) - Live item updates
- [Collaboration](../collaboration/) - Permission-based actions

