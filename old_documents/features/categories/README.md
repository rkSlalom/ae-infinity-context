# Categories

**Feature Domain**: Categories  
**Version**: 1.0  
**Status**: 100% Backend, 100% Frontend, 0% Integrated

---

## Overview

Item categorization system with default and custom categories.

---

## Features

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| Get Categories | GET `/categories` | ✅ | ✅ Service Ready | Ready for Integration |
| Create Category | POST `/categories` | ✅ | ✅ Service Ready | Ready for Integration |
| Default Categories | GET `/categories?includeCustom=false` | ✅ | ✅ Service Ready | Ready for Integration |
| Custom Categories | GET `/categories?includeCustom=true` | ✅ | ✅ Service Ready | Ready for Integration |

---

## Default Categories

The system provides these default categories:

| Name | Icon | Color | Description |
|------|------|-------|-------------|
| Produce | 🥬 | #4CAF50 | Fruits and vegetables |
| Dairy | 🥛 | #2196F3 | Milk, cheese, yogurt |
| Meat | 🥩 | #F44336 | Meat and poultry |
| Seafood | 🐟 | #00BCD4 | Fish and seafood |
| Bakery | 🍞 | #FF9800 | Bread and baked goods |
| Frozen | ❄️ | #03A9F4 | Frozen foods |
| Beverages | 🥤 | #9C27B0 | Drinks |
| Snacks | 🍿 | #FF5722 | Chips, candy, etc. |
| Household | 🧼 | #607D8B | Cleaning supplies |
| Personal Care | 🧴 | #E91E63 | Hygiene products |

---

## API Specification

See [API_SPEC.md](../../API_SPEC.md) lines 556-614

### GET /categories
Query Parameters:
- `includeCustom?: boolean` (default: true)

Response:
```json
{
  "categories": [
    {
      "id": "string",
      "name": "string",
      "icon": "string (emoji)",
      "color": "string (hex)",
      "isDefault": true,
      "createdBy": null
    }
  ]
}
```

### POST /categories
Request Body:
```json
{
  "name": "string (1-50 chars, required)",
  "icon": "string (emoji, required)",
  "color": "string (hex color, required)"
}
```

---

## Frontend Implementation

### Services
**Location**: `ae-infinity-ui/src/services/categoriesService.ts` ✅

All methods implemented:
- `getAllCategories(params)`
- `createCategory(data)`
- `getDefaultCategories()`
- `getAllCategoriesWithCustom()`

### Usage in Components
Categories are used in:
- **CreateItem/EditItem** forms - Category dropdown
- **ListDetail** - Filter items by category
- **ItemRow** - Display category badge

---

## Backend Implementation

### Controllers
**Location**: `ae-infinity-api/src/AeInfinity.Api/Controllers/CategoriesController.cs` ✅

### Seed Data
**Location**: `ae-infinity-api/src/AeInfinity.Infrastructure/Persistence/ApplicationDbContextSeed.cs`

Default categories are seeded on startup.

---

## Data Models

### Database Entity

```csharp
public class Category : BaseEntity
{
    public string Name { get; set; }
    public string Icon { get; set; }
    public string Color { get; set; }
    public bool IsDefault { get; set; }
    public Guid? CreatedById { get; set; }
    public User? CreatedBy { get; set; }
}
```

### TypeScript Types

```typescript
interface Category {
  id: string
  name: string
  icon: string
  color: string
  isDefault: boolean
  createdBy: UserRef | null
}

interface CategoryRef {
  id: string
  name: string
  icon: string
  color: string
}
```

---

## Validation Rules

### Category Name
- Required
- 1-50 characters
- Unique per user (case-insensitive)
- No leading/trailing whitespace

### Icon
- Required
- Must be a valid emoji character
- Single character only

### Color
- Required
- Valid hex color format (#RRGGBB)
- Examples: #4CAF50, #2196F3

---

## User Stories

### Use Default Categories
```
As a user
I want to use predefined categories
So that I can quickly organize my items
```

### Create Custom Category
```
As a user
I want to create my own categories
So that I can organize items my way
```

---

## Integration Steps

1. ✅ Backend complete
2. ✅ Frontend service complete
3. 🔄 Fetch categories on app load
4. 🔄 Display categories in item forms
5. 🔄 Allow custom category creation
6. 🔄 Display category badges on items

### Fetch Categories Example

```typescript
useEffect(() => {
  const fetchCategories = async () => {
    try {
      const response = await categoriesService.getAllCategories({ 
        includeCustom: true 
      })
      setCategories(response.categories)
    } catch (error) {
      console.error('Failed to fetch categories', error)
    }
  }
  fetchCategories()
}, [])
```

---

## Next Steps

1. ✅ Backend complete
2. ✅ Frontend service complete
3. 🔄 Integrate with item forms
4. 🔄 Add category filter to list detail
5. 🔄 Test custom category creation

---

## Related Features

- [Items](../items/) - Items use categories

