# Data Model: Basic Search

**Feature**: 006-basic-search  
**Created**: 2025-11-05  
**Status**: Phase 1 Design

---

## Overview

This document defines the data structures for the Basic Search feature, including DTOs (Data Transfer Objects), query parameters, and response models. Search does not persist any data - all entities are ephemeral DTOs mapping from existing ShoppingList and ListItem entities.

---

## Entity Relationships

```
SearchQuery
    ├── User (via JWT, not in DTO)
    └── SearchResponse
            ├── ListSearchResult[] (mapped from ShoppingList entities)
            │       ├── Owner (UserBasicDto)
            │       └── Metadata (counts, timestamps)
            └── ItemSearchResult[] (mapped from ListItem entities)
                    ├── Category (CategoryRefDto, nullable)
                    ├── ParentList (ListRefDto)
                    └── Metadata (quantity, purchase status)
```

---

## 1. Request Models

### 1.1 SearchQueryParams (Query String Parameters)

**Purpose**: Captures user search intent and pagination preferences.

**Backend (C#)**:

```csharp
namespace AeInfinity.Application.DTOs.Search;

public class SearchQueryParams
{
    /// <summary>
    /// Search term to match against list/item names and notes.
    /// </summary>
    [Required(ErrorMessage = "Query is required")]
    [StringLength(200, MinimumLength = 1, ErrorMessage = "Query must be 1-200 characters")]
    public string Query { get; set; } = string.Empty;

    /// <summary>
    /// Search scope: All (lists + items), Lists only, or Items only.
    /// </summary>
    public SearchScope Scope { get; set; } = SearchScope.All;

    /// <summary>
    /// Page number (1-indexed).
    /// </summary>
    [Range(1, int.MaxValue, ErrorMessage = "Page must be at least 1")]
    public int Page { get; set; } = 1;

    /// <summary>
    /// Number of results per page (max 100).
    /// </summary>
    [Range(1, 100, ErrorMessage = "Page size must be between 1 and 100")]
    public int PageSize { get; set; } = 20;

    /// <summary>
    /// Include shared lists in search results.
    /// </summary>
    public bool IncludeShared { get; set; } = true;
}

public enum SearchScope
{
    All,
    Lists,
    Items
}
```

**Frontend (TypeScript)**:

```typescript
export interface SearchQueryParams {
  query: string;                              // Required: 1-200 characters
  scope: 'all' | 'lists' | 'items';          // Default: 'all'
  page: number;                               // Default: 1 (1-indexed)
  pageSize: number;                           // Default: 20, Max: 100
  includeShared: boolean;                     // Default: true
}

export type SearchScope = 'all' | 'lists' | 'items';
```

**Validation Rules**:
- **Query**: Required, 1-200 characters, trimmed whitespace
- **Scope**: Valid enum value (All, Lists, Items)
- **Page**: Minimum 1, no maximum (returns empty if exceeds total pages)
- **PageSize**: 1-100, default 20
- **IncludeShared**: Boolean, default true

---

## 2. Response Models

### 2.1 SearchResponse (Root Response Object)

**Purpose**: Container for all search results with metadata.

**Backend (C#)**:

```csharp
namespace AeInfinity.Application.DTOs.Search;

public class SearchResponse
{
    /// <summary>
    /// The search query that was executed (echoed back).
    /// </summary>
    public string Query { get; set; } = string.Empty;

    /// <summary>
    /// The search scope that was applied.
    /// </summary>
    public SearchScope Scope { get; set; }

    /// <summary>
    /// List search results.
    /// </summary>
    public SearchResultSet<ListSearchResult> Lists { get; set; } = new();

    /// <summary>
    /// Item search results.
    /// </summary>
    public SearchResultSet<ItemSearchResult> Items { get; set; } = new();

    /// <summary>
    /// Pagination metadata.
    /// </summary>
    public PaginationDto Pagination { get; set; } = new();
}

public class SearchResultSet<T>
{
    /// <summary>
    /// Total number of matching results (before pagination).
    /// </summary>
    public int Total { get; set; }

    /// <summary>
    /// Array of result objects for current page.
    /// </summary>
    public List<T> Results { get; set; } = new();
}

public class PaginationDto
{
    /// <summary>
    /// Current page number (1-indexed).
    /// </summary>
    public int Page { get; set; }

    /// <summary>
    /// Number of results per page.
    /// </summary>
    public int PageSize { get; set; }

    /// <summary>
    /// Total number of pages available.
    /// </summary>
    public int TotalPages { get; set; }

    /// <summary>
    /// True if there is a next page.
    /// </summary>
    public bool HasNext { get; set; }

    /// <summary>
    /// True if there is a previous page.
    /// </summary>
    public bool HasPrevious { get; set; }
}
```

**Frontend (TypeScript)**:

```typescript
export interface SearchResponse {
  query: string;
  scope: SearchScope;
  lists: SearchResultSet<ListSearchResult>;
  items: SearchResultSet<ItemSearchResult>;
  pagination: Pagination;
}

export interface SearchResultSet<T> {
  total: number;
  results: T[];
}

export interface Pagination {
  page: number;
  pageSize: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}
```

---

### 2.2 ListSearchResult

**Purpose**: Lightweight list representation for search results.

**Backend (C#)**:

```csharp
namespace AeInfinity.Application.DTOs.Search;

public class ListSearchResult
{
    /// <summary>
    /// Unique identifier for the list.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// List name (matching text highlighted client-side).
    /// </summary>
    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Description preview (first 100 characters, null if no description).
    /// </summary>
    [StringLength(100)]
    public string? Description { get; set; }

    /// <summary>
    /// Owner information.
    /// </summary>
    public UserBasicDto Owner { get; set; } = new();

    /// <summary>
    /// Total number of items in the list.
    /// </summary>
    public int TotalItems { get; set; }

    /// <summary>
    /// Number of purchased items in the list.
    /// </summary>
    public int PurchasedItems { get; set; }

    /// <summary>
    /// True if the current user owns the list.
    /// </summary>
    public bool IsOwner { get; set; }

    /// <summary>
    /// True if the list is archived.
    /// </summary>
    public bool IsArchived { get; set; }

    /// <summary>
    /// ISO 8601 timestamp of last update.
    /// </summary>
    public DateTime LastUpdatedAt { get; set; }
}
```

**Frontend (TypeScript)**:

```typescript
export interface ListSearchResult {
  id: string;                    // UUID
  name: string;                  // 1-200 characters
  description: string | null;    // First 100 chars or null
  owner: UserBasic;              // Owner info
  totalItems: number;            // Total item count
  purchasedItems: number;        // Purchased item count
  isOwner: boolean;              // Current user is owner
  isArchived: boolean;           // List archived status
  lastUpdatedAt: string;         // ISO 8601 timestamp
}
```

**Mapping from Entity**:

```csharp
public static ListSearchResult FromEntity(ShoppingList list, Guid currentUserId)
{
    return new ListSearchResult
    {
        Id = list.Id,
        Name = list.Name,
        Description = list.Description?.Length > 100 
            ? list.Description.Substring(0, 100) 
            : list.Description,
        Owner = UserBasicDto.FromEntity(list.Owner),
        TotalItems = list.Items.Count,
        PurchasedItems = list.Items.Count(i => i.IsPurchased),
        IsOwner = list.OwnerId == currentUserId,
        IsArchived = list.IsArchived,
        LastUpdatedAt = list.UpdatedAt
    };
}
```

---

### 2.3 ItemSearchResult

**Purpose**: Item representation with parent list context.

**Backend (C#)**:

```csharp
namespace AeInfinity.Application.DTOs.Search;

public class ItemSearchResult
{
    /// <summary>
    /// Unique identifier for the item.
    /// </summary>
    public Guid Id { get; set; }

    /// <summary>
    /// Item name (matching text highlighted client-side).
    /// </summary>
    [Required]
    [StringLength(200)]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Item quantity (null if not specified).
    /// </summary>
    public decimal? Quantity { get; set; }

    /// <summary>
    /// Unit of measurement (e.g., 'kg', 'lbs', 'pieces').
    /// </summary>
    [StringLength(50)]
    public string? Unit { get; set; }

    /// <summary>
    /// Notes preview (first 100 characters, null if no notes).
    /// </summary>
    [StringLength(100)]
    public string? Notes { get; set; }

    /// <summary>
    /// True if item is marked as purchased.
    /// </summary>
    public bool IsPurchased { get; set; }

    /// <summary>
    /// Category reference (null if uncategorized).
    /// </summary>
    public CategoryRefDto? Category { get; set; }

    /// <summary>
    /// Parent list context.
    /// </summary>
    public ListRefDto ParentList { get; set; } = new();
}

public class ListRefDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsOwner { get; set; }
    public string? OwnerName { get; set; }
}

public class CategoryRefDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
}
```

**Frontend (TypeScript)**:

```typescript
export interface ItemSearchResult {
  id: string;                    // UUID
  name: string;                  // 1-200 characters
  quantity: number | null;       // Item quantity
  unit: string | null;           // Unit of measurement
  notes: string | null;          // First 100 chars or null
  isPurchased: boolean;          // Purchase status
  category: CategoryRef | null;  // Category or null
  parentList: ListRef;           // Parent list context
}

export interface ListRef {
  id: string;
  name: string;
  isOwner: boolean;
  ownerName?: string;            // Present if not owner
}

export interface CategoryRef {
  id: string;
  name: string;
  icon: string;                  // Emoji
  color: string;                 // Hex color (#RRGGBB)
}
```

**Mapping from Entity**:

```csharp
public static ItemSearchResult FromEntity(ListItem item, Guid currentUserId)
{
    var list = item.ShoppingList;
    var isOwner = list.OwnerId == currentUserId;
    
    return new ItemSearchResult
    {
        Id = item.Id,
        Name = item.Name,
        Quantity = item.Quantity,
        Unit = item.Unit,
        Notes = item.Notes?.Length > 100 
            ? item.Notes.Substring(0, 100) 
            : item.Notes,
        IsPurchased = item.IsPurchased,
        Category = item.Category != null 
            ? CategoryRefDto.FromEntity(item.Category) 
            : null,
        ParentList = new ListRefDto
        {
            Id = list.Id,
            Name = list.Name,
            IsOwner = isOwner,
            OwnerName = !isOwner ? list.Owner.DisplayName : null
        }
    };
}
```

---

## 3. CQRS Command/Query

### 3.1 SearchQuery (MediatR Request)

**Purpose**: Encapsulates search intent for CQRS handler.

```csharp
namespace AeInfinity.Application.Features.Search;

public class SearchQuery : IRequest<SearchResponse>
{
    public string Query { get; set; } = string.Empty;
    public SearchScope Scope { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public bool IncludeShared { get; set; }
    public Guid CurrentUserId { get; set; }  // From JWT claims
}

public class SearchQueryValidator : AbstractValidator<SearchQuery>
{
    public SearchQueryValidator()
    {
        RuleFor(x => x.Query)
            .NotEmpty()
            .Length(1, 200)
            .WithMessage("Query must be 1-200 characters");

        RuleFor(x => x.Page)
            .GreaterThanOrEqualTo(1)
            .WithMessage("Page must be at least 1");

        RuleFor(x => x.PageSize)
            .InclusiveBetween(1, 100)
            .WithMessage("Page size must be between 1 and 100");

        RuleFor(x => x.CurrentUserId)
            .NotEmpty()
            .WithMessage("User ID is required");
    }
}
```

---

## 4. Database Queries (Entity Framework)

### 4.1 Search Lists Query

```csharp
var listsQuery = _context.ShoppingLists
    .Where(list => 
        list.OwnerId == currentUserId ||
        list.Collaborators.Any(c => c.UserId == currentUserId)
    )
    .Where(list => EF.Functions.Like(list.Name, $"%{escapedQuery}%"));
```

### 4.2 Search Items Query

```csharp
var itemsQuery = _context.ListItems
    .Include(item => item.ShoppingList)
        .ThenInclude(list => list.Owner)
    .Include(item => item.Category)
    .Where(item => 
        item.ShoppingList.OwnerId == currentUserId ||
        item.ShoppingList.Collaborators.Any(c => c.UserId == currentUserId)
    )
    .Where(item => 
        EF.Functions.Like(item.Name, $"%{escapedQuery}%") ||
        EF.Functions.Like(item.Notes ?? "", $"%{escapedQuery}%")
    );
```

### 4.3 Pagination

```csharp
var totalCount = await query.CountAsync();
var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

var results = await query
    .OrderBy(x => x.Name)
    .Skip((page - 1) * pageSize)
    .Take(pageSize)
    .ToListAsync();
```

---

## 5. Database Indexes

### Required Indexes for Performance

```sql
-- Lists search performance
CREATE INDEX IX_ShoppingLists_Name 
ON ShoppingLists(Name);

-- Items search performance
CREATE INDEX IX_ListItems_Name 
ON ListItems(Name);

-- Items by list (for joins)
CREATE INDEX IX_ListItems_ShoppingListId 
ON ListItems(ShoppingListId);

-- Collaborators for permission filtering
CREATE INDEX IX_Collaborators_UserId 
ON Collaborators(UserId);

-- Owner for permission filtering
CREATE INDEX IX_ShoppingLists_OwnerId 
ON ShoppingLists(OwnerId);
```

---

## 6. Validation Summary

| Field | Backend Validation | Frontend Validation |
|-------|-------------------|---------------------|
| Query | Required, 1-200 chars, trimmed | Required, 1-200 chars, visual feedback |
| Scope | Enum validation | TypeScript enum type |
| Page | ≥ 1 | ≥ 1, default 1 |
| PageSize | 1-100, default 20 | 1-100, default 20 |
| IncludeShared | Boolean | Boolean, default true |

---

## 7. Error Responses

```typescript
export interface SearchErrorResponse {
  statusCode: number;
  message: string;
  errors?: Record<string, string[]>;
}
```

**Example Errors**:

```json
// 400 Bad Request - Validation error
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": {
    "query": ["Query must be 1-200 characters"],
    "pageSize": ["Page size must be between 1 and 100"]
  }
}

// 401 Unauthorized - Missing/invalid JWT
{
  "statusCode": 401,
  "message": "Unauthorized"
}

// 500 Internal Server Error
{
  "statusCode": 500,
  "message": "An error occurred while processing your search"
}
```

---

## 8. Performance Characteristics

| Operation | Expected Time | Max Acceptable |
|-----------|---------------|----------------|
| Permission filter query | 10-30ms | 100ms |
| List search LIKE query | 50-150ms | 500ms |
| Item search LIKE query | 50-200ms | 500ms |
| Total search (lists + items) | 100-350ms | 1000ms |
| Client-side highlighting | <1ms | 5ms |

**Assumptions**:
- Database size: <100,000 items + <10,000 lists
- Indexes present on Name columns
- SQLite (development) / PostgreSQL (production)

---

## Complete Example

### Request

```http
GET /api/search?query=milk&scope=all&page=1&pageSize=20
Authorization: Bearer eyJhbGc...
```

### Response

```json
{
  "query": "milk",
  "scope": "all",
  "lists": {
    "total": 1,
    "results": [
      {
        "id": "list-123",
        "name": "Grocery Shopping",
        "description": "Weekly groceries and household items",
        "owner": {
          "id": "user-456",
          "displayName": "John Doe"
        },
        "totalItems": 20,
        "purchasedItems": 8,
        "isOwner": true,
        "isArchived": false,
        "lastUpdatedAt": "2025-11-05T10:00:00Z"
      }
    ]
  },
  "items": {
    "total": 3,
    "results": [
      {
        "id": "item-001",
        "name": "Whole Milk",
        "quantity": 1,
        "unit": "gallon",
        "notes": "Organic if available",
        "isPurchased": false,
        "category": {
          "id": "cat-dairy",
          "name": "Dairy",
          "icon": "🥛",
          "color": "#2196F3"
        },
        "parentList": {
          "id": "list-123",
          "name": "Grocery Shopping",
          "isOwner": true
        }
      }
    ]
  },
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalPages": 1,
    "hasNext": false,
    "hasPrevious": false
  }
}
```

---

**Last Updated**: 2025-11-05  
**Status**: Ready for implementation

