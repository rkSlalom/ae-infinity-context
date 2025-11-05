# Data Model: List Items Management

**Feature**: 004-list-items-management  
**Date**: 2025-11-05  
**References**: [spec.md](./spec.md), [plan.md](./plan.md), [research.md](./research.md)

---

## Overview

This document defines the data structures, entities, DTOs, and validation rules for the List Items Management feature. It covers:
- Domain entities (database models)
- Data Transfer Objects (DTOs for API requests/responses)
- Validation rules
- Database schema and migrations
- Query patterns and indexes

---

## Domain Entities

### ListItem Entity

**Purpose**: Represents a single shopping item within a list (e.g., "Milk", "Bananas")

**File**: `Domain/Entities/ListItem.cs`

```csharp
public class ListItem
{
    // Primary Key
    public Guid Id { get; set; }
    
    // Foreign Keys
    public Guid ListId { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid CreatedById { get; set; }
    public Guid? PurchasedById { get; set; }
    
    // Core Properties
    public string Name { get; set; } = string.Empty; // Required, 1-100 chars
    public decimal Quantity { get; set; } = 1; // Positive number, default 1
    public string? Unit { get; set; } // Optional (e.g., "gallons", "pieces")
    public string? Notes { get; set; } // Optional, max 500 chars
    public string? ImageUrl { get; set; } // Optional (future feature)
    
    // Status & Ordering
    public bool IsPurchased { get; set; } = false;
    public int Position { get; set; } = 0; // Display order (0-based)
    
    // Soft Delete (Constitution compliant)
    public bool IsDeleted { get; set; } = false;
    public DateTime? DeletedAt { get; set; } // Null if not deleted
    public Guid? DeletedById { get; set; } // User who deleted
    
    // Timestamps
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public DateTime? PurchasedAt { get; set; } // Null if not purchased
    
    // Navigation Properties
    public ShoppingList List { get; set; } = null!;
    public Category? Category { get; set; }
    public User CreatedBy { get; set; } = null!;
    public User? PurchasedBy { get; set; }
    public User? DeletedBy { get; set; }
}
```

**Validation Rules**:
- `Name`: Required, 1-100 characters
- `Quantity`: Must be > 0 (positive number)
- `Unit`: Optional, max 50 characters
- `Notes`: Optional, max 500 characters
- `Position`: Must be >= 0
- `ListId`: Must reference existing list
- `CategoryId`: If provided, must reference existing category
- `CreatedById`: Must reference existing user

**Constraints**:
- A list item must belong to a list (required foreign key)
- Position must be unique within a list (enforced at application level)
- Soft delete cascades from parent list (when list is soft-deleted, all items are soft-deleted)
- Query filters automatically exclude soft-deleted items (IsDeleted = false)

---

## Data Transfer Objects (DTOs)

### Request DTOs

#### CreateItemRequest

**Purpose**: Add new item to a shopping list

**Endpoint**: POST `/api/v1/lists/{listId}/items`

```csharp
public class CreateItemRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal Quantity { get; set; } = 1;
    public string? Unit { get; set; }
    public Guid? CategoryId { get; set; }
    public string? Notes { get; set; }
    public string? ImageUrl { get; set; }
}
```

**Validation**:
```csharp
public class CreateItemRequestValidator : AbstractValidator<CreateItemRequest>
{
    public CreateItemRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Item name is required")
            .Length(1, 100).WithMessage("Item name must be between 1 and 100 characters");
        
        RuleFor(x => x.Quantity)
            .GreaterThan(0).WithMessage("Quantity must be greater than 0");
        
        RuleFor(x => x.Unit)
            .MaximumLength(50).WithMessage("Unit must be 50 characters or less")
            .When(x => !string.IsNullOrEmpty(x.Unit));
        
        RuleFor(x => x.Notes)
            .MaximumLength(500).WithMessage("Notes must be 500 characters or less")
            .When(x => !string.IsNullOrEmpty(x.Notes));
    }
}
```

---

#### UpdateItemRequest

**Purpose**: Edit existing item details

**Endpoint**: PUT `/api/v1/lists/{listId}/items/{itemId}`

```csharp
public class UpdateItemRequest
{
    public string Name { get; set; } = string.Empty;
    public decimal Quantity { get; set; } = 1;
    public string? Unit { get; set; }
    public Guid? CategoryId { get; set; }
    public string? Notes { get; set; }
    public string? ImageUrl { get; set; }
}
```

**Validation**: Same as `CreateItemRequest` (reuse validator)

---

#### TogglePurchasedRequest

**Purpose**: Mark item as purchased or unpurchased

**Endpoint**: PATCH `/api/v1/lists/{listId}/items/{itemId}/purchased`

```csharp
public class TogglePurchasedRequest
{
    public bool IsPurchased { get; set; }
}
```

**Validation**: None required (boolean value)

---

#### ReorderItemsRequest

**Purpose**: Update positions for drag-and-drop reordering

**Endpoint**: PATCH `/api/v1/lists/{listId}/items/reorder`

```csharp
public class ReorderItemsRequest
{
    public List<ItemPosition> ItemPositions { get; set; } = new();
}

public class ItemPosition
{
    public Guid ItemId { get; set; }
    public int Position { get; set; }
}
```

**Validation**:
```csharp
public class ReorderItemsRequestValidator : AbstractValidator<ReorderItemsRequest>
{
    public ReorderItemsRequestValidator()
    {
        RuleFor(x => x.ItemPositions)
            .NotEmpty().WithMessage("At least one item position required");
        
        RuleForEach(x => x.ItemPositions).ChildRules(position => {
            position.RuleFor(p => p.Position)
                .GreaterThanOrEqualTo(0).WithMessage("Position must be >= 0");
        });
        
        // Custom rule: positions must be unique
        RuleFor(x => x.ItemPositions)
            .Must(positions => positions.Select(p => p.Position).Distinct().Count() == positions.Count)
            .WithMessage("Positions must be unique");
        
        // Custom rule: all items must belong to same list (checked in handler)
    }
}
```

---

### Response DTOs

#### ItemResponse

**Purpose**: Single item details for API responses

**Endpoints**: POST, PUT, GET (single item)

```csharp
public class ItemResponse
{
    public Guid Id { get; set; }
    public Guid ListId { get; set; }
    
    public string Name { get; set; } = string.Empty;
    public decimal Quantity { get; set; }
    public string? Unit { get; set; }
    public string? Notes { get; set; }
    public string? ImageUrl { get; set; }
    
    public CategoryResponse? Category { get; set; }
    
    public bool IsPurchased { get; set; }
    public int Position { get; set; }
    
    public UserBasicResponse CreatedBy { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    public DateTime? PurchasedAt { get; set; }
    public UserBasicResponse? PurchasedBy { get; set; }
}

public class CategoryResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
}

public class UserBasicResponse
{
    public Guid Id { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
}
```

---

#### ItemsListResponse

**Purpose**: List of items with metadata

**Endpoint**: GET `/api/v1/lists/{listId}/items`

```csharp
public class ItemsListResponse
{
    public List<ItemResponse> Items { get; set; } = new();
    public ItemsMetadata Metadata { get; set; } = null!;
    public string Permission { get; set; } = string.Empty; // "Owner", "Editor", "Viewer"
}

public class ItemsMetadata
{
    public int TotalCount { get; set; }
    public int PurchasedCount { get; set; }
    public int UnpurchasedCount { get; set; }
    public bool AllPurchased { get; set; }
}
```

---

#### AutocompleteResponse

**Purpose**: Autocomplete suggestions from previous items

**Endpoint**: GET `/api/v1/lists/items/autocomplete?query={text}`

```csharp
public class AutocompleteResponse
{
    public List<AutocompleteSuggestion> Suggestions { get; set; } = new();
}

public class AutocompleteSuggestion
{
    public string Name { get; set; } = string.Empty;
    public decimal Quantity { get; set; }
    public string? Unit { get; set; }
    public Guid? CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public int Frequency { get; set; } // How many times user added this item
}
```

---

## Database Schema

### ListItems Table

**SQLite Schema** (Entity Framework Migration):

```sql
CREATE TABLE "ListItems" (
    "Id" TEXT NOT NULL PRIMARY KEY,
    "ListId" TEXT NOT NULL,
    "CategoryId" TEXT,
    "CreatedById" TEXT NOT NULL,
    "PurchasedById" TEXT,
    "DeletedById" TEXT,
    
    "Name" TEXT NOT NULL CHECK(length("Name") >= 1 AND length("Name") <= 100),
    "Quantity" REAL NOT NULL DEFAULT 1 CHECK("Quantity" > 0),
    "Unit" TEXT CHECK(length("Unit") <= 50),
    "Notes" TEXT CHECK(length("Notes") <= 500),
    "ImageUrl" TEXT,
    
    "IsPurchased" INTEGER NOT NULL DEFAULT 0,
    "Position" INTEGER NOT NULL DEFAULT 0 CHECK("Position" >= 0),
    
    "IsDeleted" INTEGER NOT NULL DEFAULT 0,
    "DeletedAt" TEXT,
    
    "CreatedAt" TEXT NOT NULL,
    "UpdatedAt" TEXT NOT NULL,
    "PurchasedAt" TEXT,
    
    FOREIGN KEY ("ListId") REFERENCES "Lists"("Id") ON DELETE CASCADE,
    FOREIGN KEY ("CategoryId") REFERENCES "Categories"("Id") ON DELETE SET NULL,
    FOREIGN KEY ("CreatedById") REFERENCES "Users"("Id"),
    FOREIGN KEY ("PurchasedById") REFERENCES "Users"("Id"),
    FOREIGN KEY ("DeletedById") REFERENCES "Users"("Id")
);
```

### Indexes

**Performance-critical indexes**:

```sql
-- Primary queries (exclude soft-deleted)
CREATE INDEX "IX_ListItems_ListId" ON "ListItems"("ListId") WHERE "IsDeleted" = 0;

-- Soft delete filtering
CREATE INDEX "IX_ListItems_IsDeleted" ON "ListItems"("IsDeleted");

-- Filter by category
CREATE INDEX "IX_ListItems_ListId_CategoryId" ON "ListItems"("ListId", "CategoryId") WHERE "IsDeleted" = 0;

-- Filter by purchased status
CREATE INDEX "IX_ListItems_ListId_IsPurchased" ON "ListItems"("ListId", "IsPurchased") WHERE "IsDeleted" = 0;

-- Sort by position (default order)
CREATE INDEX "IX_ListItems_ListId_Position" ON "ListItems"("ListId", "Position") WHERE "IsDeleted" = 0;

-- Autocomplete queries (find user's items)
CREATE INDEX "IX_ListItems_CreatedById_Name" ON "ListItems"("CreatedById", "Name") WHERE "IsDeleted" = 0;
```

---

## Entity Framework Configuration

**File**: `Infrastructure/Persistence/Configurations/ListItemConfiguration.cs`

```csharp
public class ListItemConfiguration : IEntityTypeConfiguration<ListItem>
{
    public void Configure(EntityTypeBuilder<ListItem> builder)
    {
        builder.ToTable("ListItems");
        
        builder.HasKey(i => i.Id);
        
        // Properties
        builder.Property(i => i.Name)
            .IsRequired()
            .HasMaxLength(100);
        
        builder.Property(i => i.Quantity)
            .IsRequired()
            .HasDefaultValue(1);
        
        builder.Property(i => i.Unit)
            .HasMaxLength(50);
        
        builder.Property(i => i.Notes)
            .HasMaxLength(500);
        
        builder.Property(i => i.IsPurchased)
            .IsRequired()
            .HasDefaultValue(false);
        
        builder.Property(i => i.Position)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(i => i.CreatedAt)
            .IsRequired();
        
        builder.Property(i => i.UpdatedAt)
            .IsRequired();
        
        // Relationships
        builder.HasOne(i => i.List)
            .WithMany(l => l.Items)
            .HasForeignKey(i => i.ListId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasOne(i => i.Category)
            .WithMany()
            .HasForeignKey(i => i.CategoryId)
            .OnDelete(DeleteBehavior.SetNull);
        
        builder.HasOne(i => i.CreatedBy)
            .WithMany()
            .HasForeignKey(i => i.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);
        
        builder.HasOne(i => i.PurchasedBy)
            .WithMany()
            .HasForeignKey(i => i.PurchasedById)
            .OnDelete(DeleteBehavior.SetNull);
        
        // Indexes
        builder.HasIndex(i => i.ListId)
            .HasDatabaseName("IX_ListItems_ListId");
        
        builder.HasIndex(i => new { i.ListId, i.CategoryId })
            .HasDatabaseName("IX_ListItems_ListId_CategoryId");
        
        builder.HasIndex(i => new { i.ListId, i.IsPurchased })
            .HasDatabaseName("IX_ListItems_ListId_IsPurchased");
        
        builder.HasIndex(i => new { i.ListId, i.Position })
            .HasDatabaseName("IX_ListItems_ListId_Position");
        
        builder.HasIndex(i => new { i.CreatedById, i.Name })
            .HasDatabaseName("IX_ListItems_CreatedById_Name");
    }
}
```

---

## Repository Pattern

### IListItemRepository

**File**: `Application/Common/Interfaces/IListItemRepository.cs`

```csharp
public interface IListItemRepository
{
    // CRUD Operations
    Task<ListItem> CreateAsync(ListItem item);
    Task<ListItem?> GetByIdAsync(Guid itemId);
    Task<List<ListItem>> GetByListIdAsync(Guid listId, GetItemsFilter? filter = null);
    Task UpdateAsync(ListItem item);
    Task DeleteAsync(Guid itemId);
    
    // Specialized Operations
    Task<bool> ExistsAsync(Guid itemId);
    Task<int> GetNextPositionAsync(Guid listId);
    Task ReorderAsync(List<ItemPosition> positions);
    
    // Autocomplete
    Task<List<AutocompleteSuggestion>> GetAutocompleteAsync(Guid userId, string query);
}

public class GetItemsFilter
{
    public Guid? CategoryId { get; set; }
    public bool? IsPurchased { get; set; }
    public string SortBy { get; set; } = "position"; // "name", "createdAt", "category"
    public string SortOrder { get; set; } = "asc"; // "asc", "desc"
}
```

---

## Query Patterns

### Get Items with Filters

```csharp
public async Task<List<ListItem>> GetByListIdAsync(Guid listId, GetItemsFilter? filter = null)
{
    var query = _context.ListItems
        .Include(i => i.Category)
        .Include(i => i.CreatedBy)
        .Include(i => i.PurchasedBy)
        .Where(i => i.ListId == listId);
    
    // Apply filters
    if (filter?.CategoryId != null)
        query = query.Where(i => i.CategoryId == filter.CategoryId);
    
    if (filter?.IsPurchased != null)
        query = query.Where(i => i.IsPurchased == filter.IsPurchased);
    
    // Apply sorting
    query = filter?.SortBy switch
    {
        "name" => query.OrderBy(i => i.Name),
        "createdAt" => query.OrderBy(i => i.CreatedAt),
        "category" => query.OrderBy(i => i.Category != null ? i.Category.Name : ""),
        _ => query.OrderBy(i => i.Position) // default
    };
    
    if (filter?.SortOrder == "desc")
        query = ((IOrderedQueryable<ListItem>)query).Reverse();
    
    return await query.ToListAsync();
}
```

### Autocomplete Query

```csharp
public async Task<List<AutocompleteSuggestion>> GetAutocompleteAsync(Guid userId, string query)
{
    var results = await _context.ListItems
        .Where(i => i.CreatedById == userId && i.Name.Contains(query))
        .GroupBy(i => new { i.Name, i.Quantity, i.Unit, i.CategoryId })
        .Select(g => new AutocompleteSuggestion
        {
            Name = g.Key.Name,
            Quantity = g.Key.Quantity,
            Unit = g.Key.Unit,
            CategoryId = g.Key.CategoryId,
            CategoryName = g.First().Category != null ? g.First().Category.Name : null,
            Frequency = g.Count()
        })
        .OrderByDescending(s => s.Frequency)
        .ThenBy(s => s.Name)
        .Take(10)
        .ToListAsync();
    
    return results;
}
```

---

## Frontend TypeScript Types

**File**: `src/types/index.ts`

```typescript
export interface ListItem {
  id: string;
  listId: string;
  name: string;
  quantity: number;
  unit: string | null;
  notes: string | null;
  imageUrl: string | null;
  category: Category | null;
  isPurchased: boolean;
  position: number;
  createdBy: UserBasic;
  createdAt: string;
  updatedAt: string;
  purchasedAt: string | null;
  purchasedBy: UserBasic | null;
}

export interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
}

export interface UserBasic {
  id: string;
  displayName: string;
  avatarUrl: string | null;
}

export interface ItemsListResponse {
  items: ListItem[];
  metadata: ItemsMetadata;
  permission: 'Owner' | 'Editor' | 'Viewer';
}

export interface ItemsMetadata {
  totalCount: number;
  purchasedCount: number;
  unpurchasedCount: number;
  allPurchased: boolean;
}

export interface CreateItemRequest {
  name: string;
  quantity?: number;
  unit?: string;
  categoryId?: string;
  notes?: string;
  imageUrl?: string;
}

export interface UpdateItemRequest {
  name: string;
  quantity?: number;
  unit?: string;
  categoryId?: string;
  notes?: string;
  imageUrl?: string;
}

export interface TogglePurchasedRequest {
  isPurchased: boolean;
}

export interface ReorderItemsRequest {
  itemPositions: ItemPosition[];
}

export interface ItemPosition {
  itemId: string;
  position: number;
}

export interface AutocompleteSuggestion {
  name: string;
  quantity: number;
  unit: string | null;
  categoryId: string | null;
  categoryName: string | null;
  frequency: number;
}
```

---

## Validation Summary

| Field | Rule | Error Message |
|-------|------|---------------|
| **Name** | Required | "Item name is required" |
| **Name** | 1-100 chars | "Item name must be between 1 and 100 characters" |
| **Quantity** | > 0 | "Quantity must be greater than 0" |
| **Unit** | Max 50 chars | "Unit must be 50 characters or less" |
| **Notes** | Max 500 chars | "Notes must be 500 characters or less" |
| **Position** | >= 0 | "Position must be >= 0" |
| **ItemPositions** | Unique positions | "Positions must be unique" |
| **ListId** | Must exist | "List not found" |
| **CategoryId** | Must exist (if provided) | "Category not found" |

---

## State Transitions

### Purchase Status Transition

```
[Unpurchased] --toggle--> [Purchased]
     ^                          |
     |                          |
     +--------toggle-------------+

State: Unpurchased
- IsPurchased = false
- PurchasedAt = null
- PurchasedBy = null

State: Purchased
- IsPurchased = true
- PurchasedAt = DateTime.UtcNow
- PurchasedBy = CurrentUser
```

### Position Updates (Reorder)

```
Initial: [Item1:0, Item2:1, Item3:2, Item4:3]

User drags Item3 to position 0:

Step 1: Calculate new positions
- Item3: 0 (moved item)
- Item1: 1 (shifted down)
- Item2: 2 (shifted down)
- Item4: 3 (unchanged)

Step 2: Batch update all positions in transaction

Result: [Item3:0, Item1:1, Item2:2, Item4:3]
```

---

**Data Model Status**: ✅ Complete  
**Next Steps**: Create API contracts (JSON schemas) in `/contracts/` directory

