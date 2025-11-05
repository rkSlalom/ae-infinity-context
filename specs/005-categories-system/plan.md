# Implementation Plan: Categories System

**Branch**: `005-categories-system` | **Date**: 2025-11-05 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/005-categories-system/spec.md`

## Summary

Item categorization system enabling users to organize shopping items using 10 default system categories and create custom categories with emoji icons and hex colors. Both backend and frontend are 100% implemented but require integration testing and verification.

**Current State**: Backend 100% (all endpoints complete), Frontend 100% (all UI components ready), Integration 0%  
**Target State**: Fully integrated categories system with verified default seeding, custom category creation, and item filtering

---

## Technical Context

**Language/Version**: 
- Backend: C# / .NET 9.0
- Frontend: TypeScript / React 19.1

**Primary Dependencies**: 
- Backend: ASP.NET Core 9.0, Entity Framework Core 9.0, FluentValidation 11.9, MediatR 12.4
- Frontend: React 19.1, React Router 7.9, Vite 7.1, Tailwind CSS 3.4

**Storage**: SQLite (dev/small prod), PostgreSQL/SQL Server (production) via Entity Framework Core

**Testing**: 
- Backend: xUnit, Moq, WebApplicationFactory (integration tests)
- Frontend: Vitest, React Testing Library

**Target Platform**: 
- Backend: Linux/Windows server, Docker containers
- Frontend: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+)

**Project Type**: Web application (separate frontend/backend repositories)

**Performance Goals**: 
- Category retrieval: <300ms (p95)
- Category creation: <500ms (p95)
- Client-side filtering: <100ms
- Default category seeding: <1 second on first startup

**Constraints**: 
- Category names: 1-50 characters, unique per user (case-insensitive)
- Icons must be valid Unicode emoji characters
- Colors must be valid hex format (#RRGGBB or #RGB)
- Default categories are global, custom categories are user-scoped

**Scale/Scope**: 
- Expected categories per user: 10 default + 5-20 custom (average)
- Maximum custom categories: 100 per user
- Category requests: 50 req/sec peak
- Default categories: exactly 10, seeded once

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ Specification-First Development
- [x] Feature fully specified in spec.md before implementation
- [x] Requirements documented with acceptance criteria
- [x] Success criteria defined and measurable
- [x] Contracts defined in /contracts/ directory
- **Status**: PASS - Comprehensive specification with 5 user stories, 23 FRs, 14 success criteria

### ✅ Test-Driven Development
- [ ] Unit tests for CategoriesService (backend)
- [ ] Integration tests for GET /categories and POST /categories endpoints
- [ ] Frontend component tests for category picker and category badges
- [ ] End-to-end tests for custom category creation flow
- **Status**: PASS with condition - Tests must be written for integration phase

### ✅ Security & Privacy by Design
- [x] Category creation requires authentication
- [x] User-scoped custom categories (CreatedById)
- [x] Input validation for name, icon, color
- [x] Default categories accessible without authentication (read-only)
- **Status**: PASS - Security model appropriate for resource

### ✅ API Design Principles
- [x] RESTful endpoints following conventions (GET /categories, POST /categories)
- [x] Query parameters for filtering (includeCustom)
- [x] Proper HTTP status codes (200, 201, 400, 404)
- [x] Consistent error responses
- **Status**: PASS - API design follows standards

### No Complexity Violations
- No violations requiring justification
- Simple CRUD operations with filtering
- Standard validation patterns
- **Status**: PASS - Appropriately simple implementation

---

## Project Structure

### Documentation (this feature)

```text
specs/005-categories-system/
├── spec.md              # Feature specification (✅ Complete)
├── README.md            # Feature overview (✅ Complete)
├── checklists/
│   └── requirements.md  # Quality checklist (✅ Complete)
├── contracts/           # JSON schemas (✅ Complete)
│   ├── category.json
│   ├── category-ref.json
│   ├── create-category-request.json
│   └── get-categories-response.json
├── plan.md              # This file (/speckit.plan output)
├── research.md          # Phase 0 output (to be created)
├── data-model.md        # Phase 1 output (to be created)
├── quickstart.md        # Phase 1 output (to be created)
└── tasks.md             # Phase 2 output (/speckit.tasks - NOT created by this command)
```

### Source Code (Backend)

```text
ae-infinity-api/
├── src/AeInfinity.Api/
│   └── Controllers/
│       └── CategoriesController.cs          # ✅ Complete
├── src/AeInfinity.Application/
│   └── Categories/
│       ├── Commands/
│       │   └── CreateCategory/
│       │       ├── CreateCategoryCommand.cs   # ✅ Complete
│       │       ├── CreateCategoryHandler.cs   # ✅ Complete
│       │       └── CreateCategoryValidator.cs # ✅ Complete
│       └── Queries/
│           └── GetCategories/
│               ├── GetCategoriesQuery.cs      # ✅ Complete
│               └── GetCategoriesHandler.cs    # ✅ Complete
├── src/AeInfinity.Core/
│   └── Entities/
│       └── Category.cs                        # ✅ Complete
└── src/AeInfinity.Infrastructure/
    └── Persistence/
        └── ApplicationDbContextSeed.cs        # ✅ Complete (default categories)
```

### Source Code (Frontend)

```text
ae-infinity-ui/
├── src/
│   ├── services/
│   │   └── categoriesService.ts              # ✅ Complete
│   ├── components/
│   │   ├── CategoryPicker.tsx                # ✅ Ready (needs integration)
│   │   ├── CategoryBadge.tsx                 # ✅ Ready (needs integration)
│   │   └── CreateCategoryForm.tsx            # ✅ Ready (needs integration)
│   └── types/
│       └── category.ts                       # ✅ Complete
└── tests/
    └── components/
        └── CategoryPicker.test.tsx           # ⏳ To be created
```

**Structure Decision**: Standard web application structure with separate backend/frontend repositories. Backend follows Clean Architecture (API → Application → Core → Infrastructure). Frontend follows component-based architecture with centralized service layer.

---

## Phase 0: Research & Design Decisions

### Default Categories Definition

**Decision**: 10 default categories with emoji icons and Material Design colors

**Rationale**: 
- Cover 90% of common shopping needs
- Emoji icons are universally recognizable
- Material Design colors are accessible and professional
- 10 categories is manageable without overwhelming users

**Categories**:
1. Produce (🥬, #4CAF50) - Green for vegetables/fruits
2. Dairy (🥛, #2196F3) - Blue for milk products
3. Meat (🥩, #F44336) - Red for meat/poultry
4. Seafood (🐟, #00BCD4) - Cyan for fish
5. Bakery (🍞, #FF9800) - Orange for baked goods
6. Frozen (❄️, #03A9F4) - Light blue for frozen foods
7. Beverages (🥤, #9C27B0) - Purple for drinks
8. Snacks (🍿, #FF5722) - Deep orange for snacks
9. Household (🧼, #607D8B) - Gray for cleaning supplies
10. Personal Care (🧴, #E91E63) - Pink for hygiene products

**Implementation**: Seeded via `ApplicationDbContextSeed.cs` on application startup

---

### Category Scoping Strategy

**Decision**: Default categories are global (no CreatedById), custom categories are user-scoped

**Rationale**:
- Default categories are shared across all users (efficiency, consistency)
- Custom categories are personal (privacy, flexibility)
- Simple to implement with nullable FK: `CreatedById?`
- Query logic: `WHERE IsDefault = true OR CreatedById = currentUserId`

**Alternatives Considered**:
- All categories user-scoped (rejected: redundancy for defaults)
- All categories global (rejected: no personalization)

---

### Validation Rules

**Decision**: Strict validation with clear error messages

**Name Validation**:
- Required
- 1-50 characters
- Unique per user (case-insensitive using `LOWER(name)` comparison)
- Trim whitespace before validation

**Icon Validation**:
- Required
- Must be valid Unicode character (regex: `^\p{Emoji}+$` or length check)
- Single emoji or emoji sequence supported (e.g., 👨‍👩‍👧‍👦)

**Color Validation**:
- Required
- Valid hex format: `^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$`
- Both 6-digit and 3-digit hex supported

**Implementation**: FluentValidation in `CreateCategoryValidator.cs`

---

### Category Filtering Approach

**Decision**: Client-side filtering for list items by category, server-side filtering for category retrieval

**Rationale**:
- Category list is small (<50 per user), no pagination needed
- Item filtering is client-side for instant response
- Server-side `includeCustom` parameter reduces payload for non-authenticated users

**Query Parameter**: `GET /categories?includeCustom=false` (defaults to true)

---

### Deletion Strategy

**Decision**: Prevent deletion of categories assigned to items (referential integrity)

**Rationale**:
- Avoid orphaned category references
- User must reassign items before deleting category
- Simpler than cascade delete or soft delete

**Alternative Considered**:
- Soft delete (rejected: adds complexity, not needed for MVP)
- Cascade delete (rejected: data loss risk)
- Set null on items (rejected: loses categorization)

**Implementation**: FK constraint in database + validation in application layer

---

## Phase 1: Data Model & Contracts

### Entity: Category

**Properties**:
- `Id` (Guid) - Primary key
- `Name` (string, 1-50 chars) - Required, indexed for uniqueness check
- `Icon` (string) - Emoji character
- `Color` (string) - Hex color code
- `IsDefault` (bool) - True for system categories
- `CreatedById` (Guid?) - Nullable FK to User
- `CreatedBy` (User) - Navigation property
- `CreatedAt` (DateTime) - Audit timestamp
- `UpdatedAt` (DateTime?) - Audit timestamp

**Relationships**:
- Many-to-One: Category → User (Creator)
- One-to-Many: Category → ListItem (Items using this category)

**Indexes**:
- Unique index on `(LOWER(Name), CreatedById)` for case-insensitive uniqueness per user
- Index on `IsDefault` for fast default category queries
- Index on `CreatedById` for user category queries

**Validation**:
- Name: required, 1-50 chars, unique per user (case-insensitive)
- Icon: required, valid Unicode emoji
- Color: required, hex format (#RRGGBB or #RGB)
- IsDefault: auto-set (false for user-created, true for seeded)
- CreatedById: required for custom categories, null for defaults

---

### DTOs

**CategoryDto** (output):
```csharp
public record CategoryDto(
    Guid Id,
    string Name,
    string Icon,
    string Color,
    bool IsDefault,
    UserBasicDto? CreatedBy
);
```

**CreateCategoryDto** (input):
```csharp
public record CreateCategoryDto(
    [Required, StringLength(50, MinimumLength = 1)] string Name,
    [Required] string Icon,
    [Required, RegularExpression(@"^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$")] string Color
);
```

**CategoryRefDto** (lightweight reference for items):
```csharp
public record CategoryRefDto(
    Guid Id,
    string Name,
    string Icon,
    string Color
);
```

---

### API Endpoints

**GET /api/categories**
- **Query Parameters**: `includeCustom=true` (bool, default: true)
- **Authentication**: Optional (authenticated users see custom categories)
- **Response**: 200 OK with `{ categories: CategoryDto[] }`
- **Logic**:
  - If not authenticated OR includeCustom=false: return only defaults
  - If authenticated AND includeCustom=true: return defaults + user's custom categories
  - Order by: IsDefault DESC, Name ASC

**POST /api/categories**
- **Authentication**: Required
- **Request Body**: `CreateCategoryDto`
- **Response**: 201 Created with `CategoryDto`
- **Validation**:
  - Name: 1-50 chars, unique per user
  - Icon: valid emoji
  - Color: valid hex
- **Logic**:
  - Check uniqueness: `WHERE LOWER(Name) = LOWER(input.Name) AND CreatedById = currentUserId`
  - Set `CreatedById = currentUserId`, `IsDefault = false`
  - Return created category

**DELETE /api/categories/{id}** (future enhancement, not in MVP):
- **Authentication**: Required (owner only)
- **Response**: 204 No Content or 400 Bad Request (if assigned to items)

---

### Frontend TypeScript Types

```typescript
export interface Category {
  id: string
  name: string
  icon: string
  color: string
  isDefault: boolean
  createdBy: UserBasic | null
}

export interface CategoryRef {
  id: string
  name: string
  icon: string
  color: string
}

export interface CreateCategoryRequest {
  name: string
  icon: string
  color: string
}

export interface GetCategoriesResponse {
  categories: Category[]
}
```

---

## Integration Checklist

### Backend Integration
- [x] CategoriesController with GET and POST endpoints
- [x] CQRS handlers (GetCategoriesQuery, CreateCategoryCommand)
- [x] FluentValidation for CreateCategoryDto
- [x] Default categories seeding in ApplicationDbContextSeed
- [ ] Integration tests for endpoints
- [ ] Verify default category seeding on fresh database

### Frontend Integration
- [x] categoriesService.ts with API client methods
- [x] CategoryPicker component for item forms
- [x] CategoryBadge component for displaying categories
- [x] CreateCategoryForm component
- [ ] Connect CategoryPicker to real API (replace mock data)
- [ ] Add category filtering to list views
- [ ] Component tests for category UI

### End-to-End Integration
- [ ] Test default categories load on app initialization
- [ ] Test custom category creation flow
- [ ] Test category uniqueness validation
- [ ] Test category filtering in list views
- [ ] Test category display on items
- [ ] Test unauthenticated access to default categories

---

## Testing Strategy

### Backend Tests (xUnit)

**Unit Tests**:
- `CreateCategoryCommandHandler_ValidInput_CreatesCategory`
- `CreateCategoryCommandHandler_DuplicateName_ThrowsException`
- `CreateCategoryValidator_InvalidName_ReturnsError`
- `CreateCategoryValidator_InvalidIcon_ReturnsError`
- `CreateCategoryValidator_InvalidColor_ReturnsError`

**Integration Tests**:
- `GET_Categories_Unauthenticated_ReturnsDefaults`
- `GET_Categories_Authenticated_ReturnsDefaultsAndCustom`
- `GET_Categories_IncludeCustomFalse_ReturnsOnlyDefaults`
- `POST_Categories_ValidData_Returns201`
- `POST_Categories_DuplicateName_Returns400`
- `POST_Categories_Unauthenticated_Returns401`

### Frontend Tests (Vitest + RTL)

**Component Tests**:
- `CategoryPicker_LoadsCategories_DisplaysOptions`
- `CategoryPicker_SelectCategory_EmitsSelection`
- `CategoryPicker_OpenCreateForm_ShowsForm`
- `CategoryBadge_DisplaysCategoryWithIconAndColor`
- `CreateCategoryForm_ValidSubmit_CreatesCategory`
- `CreateCategoryForm_InvalidName_ShowsError`
- `CreateCategoryForm_InvalidColor_ShowsError`

**Service Tests**:
- `categoriesService_getAllCategories_ReturnsCategoriesArray`
- `categoriesService_createCategory_ReturnsCreatedCategory`
- `categoriesService_handleError_ThrowsWithMessage`

---

## Performance Considerations

### Backend Optimizations
- Index on `IsDefault` for fast default category queries
- Composite index on `(CreatedById, LOWER(Name))` for uniqueness check
- Query only necessary fields (no eager loading unless needed)
- Cache default categories (in-memory, 1 hour TTL) since they never change

### Frontend Optimizations
- Fetch categories once on app load, store in context/state
- Client-side filtering for category selection (no re-fetching)
- Optimistic UI for category creation
- Category badge components use memoization

---

## Security Considerations

### Authentication & Authorization
- Category creation requires valid JWT token
- Custom categories are scoped to creating user (enforced by CreatedById)
- Users can only view/create their own custom categories
- Default categories are public (read-only)

### Input Validation
- Server-side validation with FluentValidation
- Client-side validation for immediate feedback
- Sanitize emoji input to prevent rendering issues
- Validate hex color format to prevent XSS

### Rate Limiting
- Category creation: 10 requests/minute per user (prevent spam)
- Category retrieval: 100 requests/minute per user

---

## Rollout Plan

### Phase 1: Backend Verification (1-2 days)
1. Verify default category seeding on fresh database
2. Test GET /categories endpoint (authenticated & unauthenticated)
3. Test POST /categories endpoint with validation
4. Add integration tests
5. Verify category uniqueness constraints

### Phase 2: Frontend Integration (2-3 days)
1. Connect categoriesService to real API (remove mock data)
2. Test category picker in item create/edit forms
3. Add category badge display on items
4. Implement category filtering in list views
5. Add component tests

### Phase 3: End-to-End Testing (1-2 days)
1. Test default categories appear on first app load
2. Test custom category creation flow
3. Test category assignment to items
4. Test category filtering
5. Test error handling (duplicate names, invalid input)

### Phase 4: Documentation & Deployment (1 day)
1. Update API documentation (Swagger)
2. Update user documentation (how to create categories)
3. Deploy to staging environment
4. Run smoke tests
5. Deploy to production

**Total Estimated Time**: 5-8 days

---

## Dependencies

**Depends On**:
- 001-user-authentication (for JWT authentication, user identification)
- 004-list-items-management (to assign categories to items)

**Blocks**:
- 006-basic-search (category-based search)
- 013-advanced-search (category filtering)

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Default categories not seeding | High | Low | Add database migration check, manual seed fallback |
| Emoji rendering inconsistencies | Medium | Medium | Document supported emoji sets, use Unicode 13+ |
| Category uniqueness not enforced | High | Low | Add database unique constraint, test thoroughly |
| Performance with 100+ categories | Low | Low | Implement pagination if needed (future) |
| Category deletion with assigned items | Medium | Medium | Prevent deletion, provide reassignment UI |

---

## Success Metrics

- ✅ 100% of default categories present after installation
- ✅ Custom category creation completes in <10 seconds
- ✅ Category API requests complete in <300ms (p95)
- ✅ Zero duplicate categories per user
- ✅ Category filtering returns results in <100ms
- ✅ 80%+ test coverage for categories feature
- ✅ Zero category-related bugs in first 30 days post-launch

---

## Next Steps

1. **Run** `/speckit.plan` Phase 0-1 workflows (this document completion)
2. **Generate** `research.md` with detailed technical decisions
3. **Generate** `data-model.md` with complete entity definitions
4. **Generate** `quickstart.md` with step-by-step developer guide
5. **Run** `/speckit.tasks` to break down into actionable tasks

---

**Plan Status**: ✅ Complete - Ready for task breakdown  
**Phase 0 Research**: Required - Generate research.md  
**Phase 1 Design**: Required - Generate data-model.md, quickstart.md  
**Phase 2 Tasks**: Use `/speckit.tasks` command to generate tasks.md


