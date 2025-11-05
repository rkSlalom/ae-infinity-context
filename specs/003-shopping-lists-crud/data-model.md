# Data Model: Shopping Lists CRUD

**Feature**: 003-shopping-lists-crud  
**Created**: 2025-11-05  
**Last Updated**: 2025-11-05  
**Status**: ✅ Documented from Existing Implementation

**Note**: Backend API is 100% implemented. This data model documents the existing database schema and DTOs.

---

## ⚠️ Key Implementation Notes

1. **Soft Delete**: All entities use soft delete pattern with `IsDeleted` flag
2. **Inheritance**: ShoppingList extends BaseAuditableEntity extends BaseEntity
3. **Validation**: Via FluentValidation (not data annotations)
4. **Owner Relationship**: Each list has exactly one owner (FK to User)
5. **Statistics**: Item counts calculated dynamically via queries (not stored fields)
6. **Archive Pattern**: `IsArchived` flag + `ArchivedAt` timestamp

---

## Entity Definitions

### ShoppingList Entity

**Purpose**: Represents a collection of shopping items with name, description, owner, and archived status.

**Location**: `AeInfinity.Domain/Entities/ShoppingList.cs`

**Inheritance**: `ShoppingList` extends `BaseAuditableEntity` extends `BaseEntity`

#### Fields (Direct)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Name` | string | Required, Min 1 char, Max 200 chars | List name (e.g., "Weekly Groceries") |
| `Description` | string? | Optional, Max 1000 chars | Optional description of list purpose |
| `OwnerId` | Guid | Required, FK → User, Indexed | User who created/owns the list |
| `IsArchived` | bool | Required, Default: false | Whether list is archived (hidden from main view) |
| `ArchivedAt` | DateTime? | Optional, UTC | Timestamp when list was archived (null if active) |

#### Fields (Inherited from BaseEntity)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Id` | Guid | PK, Required, Unique | Unique list identifier (from BaseEntity) |
| `CreatedAt` | DateTime | Required, UTC | List creation timestamp (from BaseEntity) |
| `UpdatedAt` | DateTime? | Optional, UTC | Last modification timestamp (from BaseEntity) |
| `DeletedAt` | DateTime? | Optional, UTC | Soft delete timestamp (from BaseEntity) |
| `IsDeleted` | bool | Required, Default: false | Soft delete flag (from BaseEntity) |

#### Fields (Inherited from BaseAuditableEntity)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `CreatedBy` | Guid? | Optional, FK → User | User who created this list (from BaseAuditableEntity) |
| `UpdatedBy` | Guid? | Optional, FK → User | User who last modified this list (from BaseAuditableEntity) |
| `DeletedBy` | Guid? | Optional, FK → User | User who soft-deleted this list (from BaseAuditableEntity) |

#### Navigation Properties

| Property | Type | Relationship | Description |
|----------|------|--------------|-------------|
| `Owner` | User | Many-to-One | The user who owns this list |
| `Items` | ICollection\<ShoppingItem\> | One-to-Many | All items in this list (Feature 004) |
| `Collaborators` | ICollection\<ListCollaborator\> | One-to-Many | All collaborators with access (Feature 008) |

#### Indexes

```sql
-- Primary key
PRIMARY KEY (Id)

-- Owner lookup (frequent query)
INDEX IX_ShoppingLists_OwnerId ON ShoppingLists(OwnerId) WHERE IsDeleted = false

-- Archived status filtering
INDEX IX_ShoppingLists_IsArchived ON ShoppingLists(IsArchived) WHERE IsDeleted = false

-- Soft delete index (for query filter performance)
INDEX IX_ShoppingLists_IsDeleted ON ShoppingLists(IsDeleted)

-- Combined index for dashboard queries (owner + archived + deleted)
INDEX IX_ShoppingLists_Owner_Archived ON ShoppingLists(OwnerId, IsArchived, IsDeleted)

-- Updated timestamp for sorting
INDEX IX_ShoppingLists_UpdatedAt ON ShoppingLists(UpdatedAt DESC) WHERE IsDeleted = false
```

**Note**: EF Core adds query filter `WHERE IsDeleted = false` automatically to all queries unless explicitly disabled.

#### Validation Rules

**Name**:
- Minimum 1 character (required, cannot be whitespace only)
- Maximum 200 characters
- Cannot be null or empty
- Trimmed of leading/trailing whitespace before save

**Description**:
- Optional (can be null or empty)
- Maximum 1000 characters if provided
- Trimmed of leading/trailing whitespace before save

**OwnerId**:
- Must reference an existing, non-deleted user
- Cannot be null
- Cannot be changed after list creation (ownership transfer requires special logic)

**IsArchived**:
- Boolean flag (true = archived, false = active)
- Defaults to false on creation
- When set to true, `ArchivedAt` timestamp is automatically set

**ArchivedAt**:
- Automatically set when `IsArchived` changes from false to true
- Cleared (set to null) when `IsArchived` changes from true to false
- Must not be set manually

#### Business Rules

1. **Ownership**: Only the owner can:
   - Delete the list (soft delete)
   - Archive/unarchive the list
   - Transfer ownership (future feature)
   - Share the list with collaborators (Feature 008)

2. **Archive Behavior**:
   - Archived lists are hidden from main dashboard by default
   - Archived lists can still be accessed by direct link
   - Items in archived lists can still be viewed
   - Collaborators retain access to archived lists

3. **Delete Behavior** (Soft Delete):
   - Setting `IsDeleted = true` and `DeletedAt = NOW`
   - Cascades to all items (items also soft-deleted)
   - List no longer appears in any queries (query filter)
   - Can be restored by admin (set `IsDeleted = false`, clear `DeletedAt`)

4. **Statistics**:
   - `TotalItems`: Count of non-deleted items in the list
   - `PurchasedItems`: Count of items where `IsPurchased = true`
   - `CollaboratorsCount`: Count of unique users with access (including owner)
   - These are calculated dynamically, not stored in database

---

## DTOs (Data Transfer Objects)

### ListDto (Summary)

**Purpose**: Lightweight list representation for dashboard and list views.

**Location**: `AeInfinity.Application/Lists/DTOs/ListDto.cs`

**Validation**: Handled by command validators (FluentValidation)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Id` | Guid | Required | Unique list identifier |
| `Name` | string | Required, Min 1, Max 200 | List name |
| `Description` | string? | Optional, Max 1000 | List description (can be null) |
| `OwnerId` | Guid | Required | Owner's user ID |
| `Owner` | UserBasicDto? | Optional | Owner details (id, displayName, avatarUrl) |
| `IsArchived` | bool | Required | Whether list is archived |
| `ArchivedAt` | DateTime? | Optional, UTC | When list was archived (null if active) |
| `CreatedAt` | DateTime | Required, UTC | List creation timestamp |
| `UpdatedAt` | DateTime? | Optional, UTC | Last modification timestamp |
| `TotalItems` | int | Required, >= 0 | Total number of items in list |
| `PurchasedItems` | int | Required, >= 0 | Number of purchased items |
| `CollaboratorsCount` | int | Required, >= 0 | Number of collaborators (including owner) |

**Usage**: GET /lists (paginated list of all accessible lists)

---

### ListDetailDto

**Purpose**: Complete list information including collaborators and items.

**Location**: `AeInfinity.Application/Lists/DTOs/ListDetailDto.cs`

**Validation**: Handled by command validators (FluentValidation)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Id` | Guid | Required | Unique list identifier |
| `Name` | string | Required, Min 1, Max 200 | List name |
| `Description` | string? | Optional, Max 1000 | List description (can be null) |
| `OwnerId` | Guid | Required | Owner's user ID |
| `Owner` | UserBasicDto? | Optional | Owner details (id, displayName, avatarUrl) |
| `IsArchived` | bool | Required | Whether list is archived |
| `ArchivedAt` | DateTime? | Optional, UTC | When list was archived (null if active) |
| `CreatedAt` | DateTime | Required, UTC | List creation timestamp |
| `UpdatedAt` | DateTime? | Optional, UTC | Last modification timestamp |
| `TotalItems` | int | Required, >= 0 | Total number of items in list |
| `PurchasedItems` | int | Required, >= 0 | Number of purchased items |
| `CollaboratorsCount` | int | Required, >= 0 | Number of collaborators |
| `Collaborators` | List\<CollaboratorDto\> | Required | List of all collaborators with permissions |
| `Items` | List\<ShoppingItemDto\> | Required | All items in the list (Feature 004) |
| `UserRole` | string? | Optional | Current user's permission level ("Owner", "Editor", "Viewer") |

**Usage**: GET /lists/{listId} (detailed view with items and collaborators)

---

### CreateListDto

**Purpose**: Request payload for creating a new list.

**Location**: `AeInfinity.Application/Lists/DTOs/CreateListDto.cs`

**Validation**: `CreateListCommandValidator` (FluentValidation)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Name` | string | Required, Min 1, Max 200 | List name (e.g., "Weekly Groceries") |
| `Description` | string? | Optional, Max 1000 | Optional description |

**Validation Rules**:
```csharp
// CreateListCommandValidator
RuleFor(x => x.Name)
    .NotEmpty().WithMessage("List name is required")
    .MaximumLength(200).WithMessage("List name must be 200 characters or less");

RuleFor(x => x.Description)
    .MaximumLength(1000).WithMessage("Description must be 1000 characters or less")
    .When(x => !string.IsNullOrEmpty(x.Description));
```

**Usage**: POST /lists

**Note**: OwnerId is set automatically from authenticated user's JWT claims, not provided in request.

---

### UpdateListDto

**Purpose**: Request payload for updating list details.

**Location**: `AeInfinity.Application/Lists/DTOs/UpdateListDto.cs`

**Validation**: `UpdateListCommandValidator` (FluentValidation)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Name` | string | Required, Min 1, Max 200 | Updated list name |
| `Description` | string? | Optional, Max 1000 | Updated description (null to clear) |

**Validation Rules**:
```csharp
// UpdateListCommandValidator
RuleFor(x => x.Name)
    .NotEmpty().WithMessage("List name is required")
    .MaximumLength(200).WithMessage("List name must be 200 characters or less");

RuleFor(x => x.Description)
    .MaximumLength(1000).WithMessage("Description must be 1000 characters or less")
    .When(x => x.Description != null);
```

**Usage**: PUT /lists/{listId}

**Authorization**: Only owner or editors can update. Checked in command handler.

---

## MediatR Commands and Queries

### Commands

#### CreateListCommand

**Purpose**: Create a new shopping list.

**Location**: `AeInfinity.Application/Lists/Commands/CreateListCommand.cs`

**Handler**: `CreateListCommandHandler`

**Properties**:
- `Name` (string, required): List name
- `Description` (string?, optional): List description
- `UserId` (Guid, injected): Owner ID from JWT claims

**Business Logic**:
1. Validate name and description (via validator)
2. Create new ShoppingList entity
3. Set OwnerId to current user
4. Set CreatedBy to current user (audit)
5. Initialize IsArchived = false
6. Save to database
7. Return ListDto with new list details

**Authorization**: Any authenticated user can create lists

---

#### UpdateListCommand

**Purpose**: Update list name and/or description.

**Location**: `AeInfinity.Application/Lists/Commands/UpdateListCommand.cs`

**Handler**: `UpdateListCommandHandler`

**Properties**:
- `ListId` (Guid, required): List to update
- `Name` (string, required): New name
- `Description` (string?, optional): New description (null to clear)
- `UserId` (Guid, injected): Current user from JWT

**Business Logic**:
1. Fetch list by ID (query filter excludes deleted)
2. Check user has Editor or Owner permission
3. Validate name and description
4. Update Name and Description
5. Set UpdatedBy to current user (audit)
6. Set UpdatedAt to NOW
7. Save to database
8. Return updated ListDto

**Authorization**: Owner or Editor can update

---

#### DeleteListCommand

**Purpose**: Soft-delete a shopping list.

**Location**: `AeInfinity.Application/Lists/Commands/DeleteListCommand.cs`

**Handler**: `DeleteListCommandHandler`

**Properties**:
- `ListId` (Guid, required): List to delete
- `UserId` (Guid, injected): Current user from JWT

**Business Logic**:
1. Fetch list by ID (query filter excludes deleted)
2. Check user is Owner (only owners can delete)
3. Set IsDeleted = true
4. Set DeletedAt = NOW
5. Set DeletedBy to current user (audit)
6. Cascade soft-delete to all items (set IsDeleted = true on all ShoppingItems)
7. Save to database
8. Return success

**Authorization**: Owner only

**Note**: Soft delete allows potential recovery. Physical delete may be done by background job after 30 days.

---

#### ArchiveListCommand

**Purpose**: Archive a shopping list.

**Location**: `AeInfinity.Application/Lists/Commands/ArchiveListCommand.cs`

**Handler**: `ArchiveListCommandHandler`

**Properties**:
- `ListId` (Guid, required): List to archive
- `UserId` (Guid, injected): Current user from JWT

**Business Logic**:
1. Fetch list by ID (query filter excludes deleted)
2. Check user is Owner (only owners can archive)
3. Set IsArchived = true
4. Set ArchivedAt = NOW
5. Set UpdatedBy to current user (audit)
6. Set UpdatedAt = NOW
7. Save to database
8. Return updated ListDto

**Authorization**: Owner only

---

#### UnarchiveListCommand

**Purpose**: Unarchive (restore) a shopping list.

**Location**: `AeInfinity.Application/Lists/Commands/UnarchiveListCommand.cs`

**Handler**: `UnarchiveListCommandHandler`

**Properties**:
- `ListId` (Guid, required): List to unarchive
- `UserId` (Guid, injected): Current user from JWT

**Business Logic**:
1. Fetch list by ID (include archived lists in query)
2. Check user is Owner (only owners can unarchive)
3. Set IsArchived = false
4. Set ArchivedAt = null
5. Set UpdatedBy to current user (audit)
6. Set UpdatedAt = NOW
7. Save to database
8. Return updated ListDto

**Authorization**: Owner only

---

### Queries

#### GetListsQuery

**Purpose**: Retrieve all shopping lists accessible to user with filtering, sorting, and pagination.

**Location**: `AeInfinity.Application/Lists/Queries/GetListsQuery.cs`

**Handler**: `GetListsQueryHandler`

**Properties**:
- `UserId` (Guid, injected): Current user from JWT
- `IncludeArchived` (bool, default: false): Include archived lists
- `Page` (int, default: 1): Page number (1-indexed)
- `PageSize` (int, default: 20): Items per page (max: 100)
- `SortBy` (string, default: "UpdatedAt"): Field to sort by
- `SortOrder` (string, default: "desc"): "asc" or "desc"

**Business Logic**:
1. Query lists where user is owner OR collaborator (via ListCollaborator junction table)
2. Filter: Exclude soft-deleted lists (automatic query filter)
3. Filter: If `IncludeArchived = false`, exclude archived lists
4. Sort: Apply sorting by specified field and order
5. Paginate: Skip((Page-1) * PageSize).Take(PageSize)
6. Project: Map ShoppingList entities to ListDto
7. Calculate statistics (TotalItems, PurchasedItems, CollaboratorsCount)
8. Return paginated result with metadata

**Authorization**: Returns only lists user has access to

**Supported Sort Fields**:
- "Name" - Alphabetical by list name
- "CreatedAt" - Date created
- "UpdatedAt" - Date last modified (default)
- "TotalItems" - Number of items in list

---

#### GetListByIdQuery

**Purpose**: Retrieve detailed information about a specific list.

**Location**: `AeInfinity.Application/Lists/Queries/GetListByIdQuery.cs`

**Handler**: `GetListByIdQueryHandler`

**Properties**:
- `ListId` (Guid, required): List to fetch
- `UserId` (Guid, injected): Current user from JWT

**Business Logic**:
1. Query list by ID (query filter excludes deleted)
2. Include: Owner, Collaborators, Items (eager loading)
3. Check user has access (is owner OR collaborator)
4. If no access, throw ForbiddenException
5. Map ShoppingList entity to ListDetailDto
6. Include owner details, collaborators, and items
7. Set UserRole to current user's permission level
8. Return ListDetailDto

**Authorization**: User must be owner or collaborator

**Note**: Returns 404 if list doesn't exist, 403 if user doesn't have access

---

## Database Queries

### Get All Lists for User (Dashboard)

```sql
-- Simplified representation (actual query via EF Core LINQ)
SELECT 
    sl.Id,
    sl.Name,
    sl.Description,
    sl.OwnerId,
    sl.IsArchived,
    sl.ArchivedAt,
    sl.CreatedAt,
    sl.UpdatedAt,
    COUNT(DISTINCT si.Id) AS TotalItems,
    COUNT(DISTINCT CASE WHEN si.IsPurchased = 1 THEN si.Id END) AS PurchasedItems,
    COUNT(DISTINCT lc.UserId) AS CollaboratorsCount
FROM ShoppingLists sl
LEFT JOIN ShoppingItems si ON sl.Id = si.ListId AND si.IsDeleted = 0
LEFT JOIN ListCollaborators lc ON sl.Id = lc.ListId
WHERE sl.IsDeleted = 0
  AND (sl.OwnerId = @UserId OR lc.UserId = @UserId)
  AND (@IncludeArchived = 1 OR sl.IsArchived = 0)
GROUP BY sl.Id, sl.Name, sl.Description, sl.OwnerId, sl.IsArchived, 
         sl.ArchivedAt, sl.CreatedAt, sl.UpdatedAt
ORDER BY sl.UpdatedAt DESC
OFFSET @Skip ROWS FETCH NEXT @PageSize ROWS ONLY;
```

**Performance Notes**:
- Index on (OwnerId, IsArchived, IsDeleted) speeds up owner filter
- Index on ListCollaborators(UserId, ListId) speeds up collaborator lookup
- Grouping for statistics may be slow with 1000+ lists; consider caching

---

### Get List by ID with Details

```sql
-- Simplified representation (actual query via EF Core LINQ with includes)
SELECT 
    sl.*,
    u.Id AS Owner_Id,
    u.DisplayName AS Owner_DisplayName,
    u.AvatarUrl AS Owner_AvatarUrl
FROM ShoppingLists sl
INNER JOIN Users u ON sl.OwnerId = u.Id
WHERE sl.Id = @ListId AND sl.IsDeleted = 0;

-- Separate queries for collaborators and items (EF Core eager loading)
SELECT * FROM ListCollaborators WHERE ListId = @ListId;
SELECT * FROM ShoppingItems WHERE ListId = @ListId AND IsDeleted = 0 ORDER BY Position;
```

**Performance Notes**:
- Primary key lookup is fast (indexed)
- Eager loading collaborators and items avoids N+1 queries
- Items sorted by Position for consistent display order

---

## Caching Strategy

**Current**: No caching implemented (all queries hit database)

**Recommended** (future enhancement):
1. **List Dashboard Cache**:
   - Cache key: `lists:user:{userId}:page:{page}:archived:{includeArchived}`
   - TTL: 5 minutes
   - Invalidate on: List create, update, delete, archive, unarchive

2. **List Detail Cache**:
   - Cache key: `list:{listId}:detail`
   - TTL: 5 minutes
   - Invalidate on: List update, item add/update/delete, collaborator add/remove

3. **Statistics Cache**:
   - Cache key: `list:{listId}:stats`
   - TTL: 1 minute
   - Invalidate on: Item purchased status change, item add/delete

**Note**: Caching deferred until performance issues identified (premature optimization).

---

## Domain Events

**Current**: No domain events implemented

**Recommended** (for real-time updates in Feature 007):
- `ListCreatedEvent`: Published when list is created
- `ListUpdatedEvent`: Published when list name/description changed
- `ListArchivedEvent`: Published when list is archived
- `ListUnarchivedEvent`: Published when list is unarchived
- `ListDeletedEvent`: Published when list is soft-deleted

**Usage**: SignalR broadcasts these events to connected clients for real-time UI updates.

---

## Error Handling

### Common Exceptions

| Exception | Status Code | Scenario |
|-----------|-------------|----------|
| `NotFoundException` | 404 | List doesn't exist or is deleted |
| `ForbiddenException` | 403 | User doesn't have permission to access/modify list |
| `ValidationException` | 400 | Invalid input (e.g., name too long, empty name) |
| `UnauthorizedException` | 401 | User not authenticated (no JWT token) |

**Example Error Responses**:

```json
// 404 Not Found
{
  "error": {
    "code": "LIST_NOT_FOUND",
    "message": "List not found or has been deleted"
  }
}

// 403 Forbidden
{
  "error": {
    "code": "INSUFFICIENT_PERMISSIONS",
    "message": "You don't have permission to delete this list. Only the owner can delete lists."
  }
}

// 400 Bad Request (Validation)
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "Name",
        "message": "List name must be 200 characters or less"
      }
    ]
  }
}
```

---

## Security Considerations

1. **Authorization Checks**: Every command/query verifies user has appropriate permission
2. **Query Filtering**: Queries only return lists user has access to (owner or collaborator)
3. **Owner-Only Actions**: Delete, archive, share restricted to owner
4. **Soft Delete**: Allows recovery if needed, prevents accidental permanent data loss
5. **Audit Trail**: CreatedBy, UpdatedBy, DeletedBy track all modifications
6. **Input Validation**: FluentValidation prevents injection attacks and data integrity issues

---

**Data Model Status**: ✅ Complete - Ready for frontend integration

**Next Steps**: 
1. Generate API contracts (JSON schemas) in `contracts/`
2. Generate `quickstart.md` with integration examples
3. Begin frontend integration (replace mock data with API calls)

