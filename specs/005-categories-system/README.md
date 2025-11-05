# Feature: Categories System

**Feature ID**: 005-categories-system  
**Created**: 2025-11-05  
**Status**: Specification Complete, Ready for Planning  
**Implementation**: Backend 100%, Frontend 100%, Integration 0%

---

## Overview

Item categorization system enabling users to organize shopping items using default system categories (Produce, Dairy, Meat, etc.) and create custom categories tailored to their personal shopping needs. Categories feature visual icons and colors for quick recognition.

---

## Quick Links

| Document | Purpose | Status |
|----------|---------|--------|
| **[spec.md](./spec.md)** | Business requirements, user scenarios, success criteria | ✅ Complete |
| **[checklists/requirements.md](./checklists/requirements.md)** | Specification quality validation | ✅ Passed |
| **[contracts/](./contracts/)** | JSON schemas for API contracts | ✅ Complete |
| **plan.md** | Technical implementation plan | ⏳ Not yet created (use `/speckit.plan`) |
| **data-model.md** | Entity definitions and relationships | ⏳ Not yet created (use `/speckit.plan`) |
| **tasks.md** | Implementation task breakdown | ⏳ Not yet created (use `/speckit.tasks`) |

---

## Key Capabilities

### ✅ Implemented (Backend)
- GET /categories endpoint with includeCustom query parameter
- POST /categories endpoint for custom category creation
- Category validation (name, icon, color)
- Default category seeding on application startup
- User-scoped custom categories (CreatedById)
- Case-insensitive name uniqueness per user
- Categories controller with full CRUD

### ✅ Implemented (Frontend)
- CategoriesService with all API methods
- Category picker component in item forms
- Category badges on items (icon, name, color)
- Category filtering in list view
- "Create Category" form with validation
- Real-time category display updates

### ❌ Missing (Integration)
- Connect frontend category picker to backend API
- Verify default category seeding on app initialization
- End-to-end testing of custom category creation
- Category filtering integration with list views
- Error handling for category operations

---

## User Stories

1. **View Default Categories** (P1) - Access 10 pre-defined system categories
2. **Create Custom Category** (P1) - Define personal categories with emoji and color
3. **Filter Categories** (P2) - View only defaults or include custom categories
4. **Assign Categories to Items** (P1) - Organize items with category badges
5. **Filter List Items by Category** (P2) - Shop by category section

---

## Success Metrics

- Users see categories in <1 second from page load
- Custom category creation completes in <10 seconds
- 100% of default categories present after system initialization
- Category picker displays icons and colors for visual recognition
- Category filtering returns results in <100ms (client-side)
- 95% of API requests complete in <300ms
- Zero duplicate categories per user

---

## Default Categories

The system provides 10 default categories:

| Name | Icon | Color | Description |
|------|------|-------|-------------|
| Produce | 🥬 | #4CAF50 | Fruits and vegetables |
| Dairy | 🥛 | #2196F3 | Milk, cheese, yogurt |
| Meat | 🥩 | #F44336 | Meat and poultry |
| Seafood | 🐟 | #00BCD4 | Fish and seafood |
| Bakery | 🍞 | #FF9800 | Bread and baked goods |
| Frozen | ❄️ | #03A9F4 | Frozen foods |
| Beverages | 🥤 | #9C27B0 | Drinks |
| Snacks | 🍿 | #FF5722 | Chips, candy, snacks |
| Household | 🧼 | #607D8B | Cleaning supplies |
| Personal Care | 🧴 | #E91E63 | Hygiene products |

---

## API Contracts

### Endpoints

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| GET | `/categories` | Retrieve all categories (default + custom) | ✅ Implemented |
| GET | `/categories?includeCustom=false` | Retrieve only default categories | ✅ Implemented |
| POST | `/categories` | Create custom category | ✅ Implemented |

### Request/Response Examples

**GET /categories**
```json
{
  "categories": [
    {
      "id": "guid",
      "name": "Produce",
      "icon": "🥬",
      "color": "#4CAF50",
      "isDefault": true,
      "createdBy": null
    }
  ]
}
```

**POST /categories**
```json
{
  "name": "Pet Supplies",
  "icon": "🐾",
  "color": "#8B4513"
}
```

---

## Dependencies

**Depends on**: 
- 001-user-authentication (for user-scoped custom categories)
- 004-list-items-management (to assign categories to items)

**Required by**: 
- 006-basic-search (search by category)
- 013-advanced-search (filter by category)

---

## Validation Rules

### Category Name
- Required
- 1-50 characters
- Unique per user (case-insensitive)
- No leading/trailing whitespace

### Icon
- Required
- Must be valid emoji character
- Single character or emoji sequence

### Color
- Required
- Valid hex color format (#RRGGBB or #RGB)
- Examples: #4CAF50, #FF5733

---

## Tech Stack

**Backend**:
- .NET 9 Web API
- Entity Framework Core
- SQLite database
- CategoriesController with validation

**Frontend**:
- React 19 + TypeScript
- categoriesService.ts (API client)
- Category picker component
- Tailwind CSS for styling

---

## Next Steps

1. **Run** `/speckit.plan` to generate implementation plan
2. **Verify** default category seeding on app initialization
3. **Connect** frontend category picker to backend API
4. **Test** custom category creation flow end-to-end
5. **Integrate** category filtering with list views
6. **Add** category search for large category lists

---

## Related Documentation

- **Old Documentation**: [/old_documents/features/categories/](../../old_documents/features/categories/)
- **Backend Implementation**: `ae-infinity-api/src/AeInfinity.Api/Controllers/CategoriesController.cs`
- **Frontend Service**: `ae-infinity-ui/src/services/categoriesService.ts`
- **Database Seed**: `ae-infinity-api/src/AeInfinity.Infrastructure/Persistence/ApplicationDbContextSeed.cs`

---

**Ready for**: Planning phase - use `/speckit.plan` command to generate technical implementation plan


