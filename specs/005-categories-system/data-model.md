# Data Model: Categories System

**Feature**: 005-categories-system  
**Date**: 2025-11-05  
**Phase**: Phase 1 - Data Model & Contracts

## Overview

This document defines the complete data model for the Categories System, including entities, DTOs, database schema, relationships, and validation rules.

---

## Entities

### Category (Core Entity)

**Purpose**: Represents a classification for shopping items, either system-defined (default) or user-created (custom).

**Properties**:

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `Id` | Guid | Yes | Primary key, unique identifier |
| `Name` | string(50) | Yes | Category name (1-50 chars) |
| `Icon` | string(10) | Yes | Emoji icon (1-10 chars for sequences) |
| `Color` | string(7) | Yes | Hex color code (#RRGGBB or #RGB) |
| `IsDefault` | bool | Yes | True for system categories, false for user-created |
| `CreatedById` | Guid? | No | Foreign key to User (null for defaults) |
| `CreatedAt` | DateTime | Yes | Timestamp of creation (audit) |
| `UpdatedAt` | DateTime? | No | Timestamp of last update (audit) |

**Relationships**:
- **Many-to-One**: Category → User (Creator) via `CreatedById`
  - Navigation: `CreatedBy` (User entity)
  - Cascade: `ON DELETE RESTRICT` (cannot delete user with categories)
- **One-to-Many**: Category → ListItem (Items using this category)
  - Navigation: `Items` (collection of ListItem entities)
  - Cascade: `ON DELETE RESTRICT` (cannot delete category with assigned items)

**Validation Rules**:
- `Name`:
  - Required, cannot be null or empty
  - Length: 1-50 characters
  - Unique per user (case-insensitive)
  - Trimmed of leading/trailing whitespace
- `Icon`:
  - Required, cannot be null or empty
  - Length: 1-10 characters (accommodates emoji sequences)
  - Typically emoji, but no strict validation
- `Color`:
  - Required, cannot be null or empty
  - Format: `^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$`
  - Examples: `#4CAF50`, `#F44`, `#FF5722`
- `IsDefault`:
  - Auto-set: `false` for user-created, `true` for seeded defaults
  - Immutable after creation
- `CreatedById`:
  - Required for custom categories (`IsDefault = false`)
  - Null for default categories (`IsDefault = true`)
  - Must reference existing User

**Indexes**:
```sql
-- Primary key
CREATE UNIQUE INDEX PK_Categories ON Categories (Id);

-- Unique name per user (case-insensitive)
CREATE UNIQUE INDEX IX_Categories_User_Name 
  ON Categories (CreatedById, LOWER(Name))
  WHERE CreatedById IS NOT NULL;

-- Fast queries for default categories
CREATE INDEX IX_Categories_IsDefault 
  ON Categories (IsDefault);

-- Fast queries for user's custom categories
CREATE INDEX IX_Categories_CreatedBy 
  ON Categories (CreatedById)
  WHERE CreatedById IS NOT NULL;
```

**Entity Framework Configuration**:
```csharp
public class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> builder)
    {
        builder.ToTable("Categories");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Name)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(c => c.Icon)
            .IsRequired()
            .HasMaxLength(10);

        builder.Property(c => c.Color)
            .IsRequired()
            .HasMaxLength(7);

        builder.Property(c => c.IsDefault)
            .IsRequired()
            .HasDefaultValue(false);

        builder.Property(c => c.CreatedAt)
            .IsRequired();

        // Relationship: Category -> User (Creator)
        builder.HasOne(c => c.CreatedBy)
            .WithMany()
            .HasForeignKey(c => c.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);

        // Unique index: Name per user (case-insensitive)
        builder.HasIndex(c => new { c.CreatedById, c.Name })
            .IsUnique()
            .HasDatabaseName("IX_Categories_User_Name");

        // Index: Fast queries for defaults
        builder.HasIndex(c => c.IsDefault)
            .HasDatabaseName("IX_Categories_IsDefault");

        // Index: Fast queries for user categories
        builder.HasIndex(c => c.CreatedById)
            .HasDatabaseName("IX_Categories_CreatedBy");
    }
}
```

---

## DTOs (Data Transfer Objects)

### CategoryDto (Output)

**Purpose**: Full category representation returned to clients.

**Properties**:
```csharp
public record CategoryDto
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string Icon { get; init; } = string.Empty;
    public string Color { get; init; } = string.Empty;
    public bool IsDefault { get; init; }
    public UserBasicDto? CreatedBy { get; init; }
}
```

**Mapping** (from `Category` entity):
```csharp
public static CategoryDto ToDto(this Category category)
{
    return new CategoryDto
    {
        Id = category.Id,
        Name = category.Name,
        Icon = category.Icon,
        Color = category.Color,
        IsDefault = category.IsDefault,
        CreatedBy = category.CreatedBy?.ToBasicDto()
    };
}
```

**JSON Example**:
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "name": "Produce",
  "icon": "🥬",
  "color": "#4CAF50",
  "isDefault": true,
  "createdBy": null
}
```

---

### CreateCategoryDto (Input)

**Purpose**: Request payload for creating custom categories.

**Properties**:
```csharp
public record CreateCategoryDto
{
    [Required(ErrorMessage = "Category name is required")]
    [StringLength(50, MinimumLength = 1, ErrorMessage = "Category name must be 1-50 characters")]
    public string Name { get; init; } = string.Empty;

    [Required(ErrorMessage = "Category icon is required")]
    [StringLength(10, MinimumLength = 1, ErrorMessage = "Icon must be 1-10 characters")]
    public string Icon { get; init; } = string.Empty;

    [Required(ErrorMessage = "Category color is required")]
    [RegularExpression(@"^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$", 
        ErrorMessage = "Color must be a valid hex code (e.g., #4CAF50 or #FFF)")]
    public string Color { get; init; } = string.Empty;
}
```

**Validation** (FluentValidation):
```csharp
public class CreateCategoryDtoValidator : AbstractValidator<CreateCategoryDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public CreateCategoryDtoValidator(
        IApplicationDbContext context,
        ICurrentUserService currentUser)
    {
        _context = context;
        _currentUser = currentUser;

        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Category name is required")
            .Length(1, 50).WithMessage("Category name must be 1-50 characters")
            .MustAsync(BeUniqueName).WithMessage("A category with this name already exists");

        RuleFor(x => x.Icon)
            .NotEmpty().WithMessage("Category icon is required")
            .Length(1, 10).WithMessage("Icon must be 1-10 characters");

        RuleFor(x => x.Color)
            .NotEmpty().WithMessage("Category color is required")
            .Matches(@"^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$")
            .WithMessage("Color must be a valid hex code (e.g., #4CAF50 or #FFF)");
    }

    private async Task<bool> BeUniqueName(string name, CancellationToken cancellationToken)
    {
        var userId = _currentUser.UserId;
        var exists = await _context.Categories
            .AnyAsync(c => c.CreatedById == userId && 
                           EF.Functions.Like(c.Name.ToLower(), name.ToLower()), 
                      cancellationToken);
        return !exists;
    }
}
```

**JSON Example**:
```json
{
  "name": "Pet Supplies",
  "icon": "🐾",
  "color": "#8B4513"
}
```

---

### CategoryRefDto (Lightweight Reference)

**Purpose**: Minimal category representation used in ListItem DTOs.

**Properties**:
```csharp
public record CategoryRefDto
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string Icon { get; init; } = string.Empty;
    public string Color { get; init; } = string.Empty;
}
```

**Mapping** (from `Category` entity):
```csharp
public static CategoryRefDto ToRefDto(this Category category)
{
    return new CategoryRefDto
    {
        Id = category.Id,
        Name = category.Name,
        Icon = category.Icon,
        Color = category.Color
    };
}
```

**JSON Example**:
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "name": "Produce",
  "icon": "🥬",
  "color": "#4CAF50"
}
```

---

### GetCategoriesResponseDto (Output)

**Purpose**: Response wrapper for category list endpoint.

**Properties**:
```csharp
public record GetCategoriesResponseDto
{
    public List<CategoryDto> Categories { get; init; } = new();
}
```

**JSON Example**:
```json
{
  "categories": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": "Produce",
      "icon": "🥬",
      "color": "#4CAF50",
      "isDefault": true,
      "createdBy": null
    },
    {
      "id": "5fa85f64-5717-4562-b3fc-2c963f66afa8",
      "name": "Pet Supplies",
      "icon": "🐾",
      "color": "#8B4513",
      "isDefault": false,
      "createdBy": {
        "id": "7fa85f64-5717-4562-b3fc-2c963f66afa9",
        "displayName": "Sarah Thompson",
        "email": "sarah@example.com"
      }
    }
  ]
}
```

---

## Database Schema

### Categories Table

```sql
CREATE TABLE Categories (
    Id                  uniqueidentifier    NOT NULL PRIMARY KEY,
    Name                nvarchar(50)        NOT NULL,
    Icon                nvarchar(10)        NOT NULL,
    Color               nvarchar(7)         NOT NULL,
    IsDefault           bit                 NOT NULL DEFAULT 0,
    CreatedById         uniqueidentifier    NULL,
    CreatedAt           datetime2           NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt           datetime2           NULL,
    
    CONSTRAINT FK_Categories_Users 
        FOREIGN KEY (CreatedById) 
        REFERENCES Users(Id) 
        ON DELETE NO ACTION
);

-- Indexes
CREATE UNIQUE INDEX IX_Categories_User_Name 
    ON Categories (CreatedById, LOWER(Name))
    WHERE CreatedById IS NOT NULL;

CREATE INDEX IX_Categories_IsDefault 
    ON Categories (IsDefault);

CREATE INDEX IX_Categories_CreatedBy 
    ON Categories (CreatedById)
    WHERE CreatedById IS NOT NULL;
```

---

## Default Categories Seed Data

**Purpose**: Pre-populate database with 10 default categories on application startup.

**Seed Logic** (`ApplicationDbContextSeed.cs`):
```csharp
public static class ApplicationDbContextSeed
{
    public static async Task SeedDefaultCategoriesAsync(ApplicationDbContext context)
    {
        // Check if default categories already exist
        if (await context.Categories.AnyAsync(c => c.IsDefault))
        {
            return; // Already seeded
        }

        var defaultCategories = new[]
        {
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Produce",
                Icon = "🥬",
                Color = "#4CAF50",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Dairy",
                Icon = "🥛",
                Color = "#2196F3",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Meat",
                Icon = "🥩",
                Color = "#F44336",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Seafood",
                Icon = "🐟",
                Color = "#00BCD4",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Bakery",
                Icon = "🍞",
                Color = "#FF9800",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Frozen",
                Icon = "❄️",
                Color = "#03A9F4",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Beverages",
                Icon = "🥤",
                Color = "#9C27B0",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Snacks",
                Icon = "🍿",
                Color = "#FF5722",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Household",
                Icon = "🧼",
                Color = "#607D8B",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            },
            new Category
            {
                Id = Guid.NewGuid(),
                Name = "Personal Care",
                Icon = "🧴",
                Color = "#E91E63",
                IsDefault = true,
                CreatedById = null,
                CreatedAt = DateTime.UtcNow
            }
        };

        context.Categories.AddRange(defaultCategories);
        await context.SaveChangesAsync();
    }
}
```

**Invocation** (in `Program.cs` or `Startup.cs`):
```csharp
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await ApplicationDbContextSeed.SeedDefaultCategoriesAsync(context);
}
```

---

## Relationships & Dependencies

### Related Entities

**User**:
- One user can create many custom categories
- Relationship: `User.Categories` (collection)

**ListItem**:
- Each item can have one category (optional)
- Relationship: `ListItem.Category` (navigation property)
- Foreign key: `ListItem.CategoryId` (nullable)

---

## State Transitions

### Category Lifecycle

```
[Created] → (validation) → [Persisted]
                              ↓
                         [In Use] ← (assigned to items)
                              ↓
                       [Cannot Delete] (if items exist)
                              ↓
                       (reassign items)
                              ↓
                       [Can Delete] → [Deleted]
```

**States**:
- **Created**: Category object instantiated, validation pending
- **Persisted**: Saved to database, available for use
- **In Use**: Assigned to one or more ListItem entities
- **Cannot Delete**: Has foreign key constraints from ListItem
- **Can Delete**: No items assigned, safe to delete
- **Deleted**: Removed from database (soft delete not implemented)

---

## Validation Summary

### Server-Side Validation

| Field | Rule | Error Message |
|-------|------|---------------|
| `Name` | Required | "Category name is required" |
| `Name` | Length 1-50 | "Category name must be 1-50 characters" |
| `Name` | Unique per user | "A category with this name already exists" |
| `Icon` | Required | "Category icon is required" |
| `Icon` | Length 1-10 | "Icon must be 1-10 characters" |
| `Color` | Required | "Category color is required" |
| `Color` | Hex format | "Color must be a valid hex code (e.g., #4CAF50 or #FFF)" |

### Client-Side Validation

```typescript
export const validateCreateCategory = (data: CreateCategoryRequest): string[] => {
  const errors: string[] = [];

  if (!data.name || data.name.trim().length === 0) {
    errors.push('Category name is required');
  } else if (data.name.length < 1 || data.name.length > 50) {
    errors.push('Category name must be 1-50 characters');
  }

  if (!data.icon || data.icon.trim().length === 0) {
    errors.push('Category icon is required');
  } else if (data.icon.length < 1 || data.icon.length > 10) {
    errors.push('Icon must be 1-10 characters');
  }

  if (!data.color) {
    errors.push('Category color is required');
  } else if (!/^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$/.test(data.color)) {
    errors.push('Color must be a valid hex code (e.g., #4CAF50 or #FFF)');
  }

  return errors;
};
```

---

## Frontend TypeScript Types

```typescript
// Category types
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

// Query parameters
export interface GetCategoriesParams {
  includeCustom?: boolean
}

// User reference (from auth feature)
export interface UserBasic {
  id: string
  displayName: string
  email: string
}
```

---

## CQRS Commands & Queries

### GetCategoriesQuery

**Purpose**: Retrieve categories (default + custom) for current user.

**Handler**:
```csharp
public class GetCategoriesQueryHandler : IRequestHandler<GetCategoriesQuery, GetCategoriesResponseDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public async Task<GetCategoriesResponseDto> Handle(
        GetCategoriesQuery request, 
        CancellationToken cancellationToken)
    {
        var query = _context.Categories.AsQueryable();

        // Filter by default or include custom
        if (!request.IncludeCustom || _currentUser.UserId == null)
        {
            query = query.Where(c => c.IsDefault);
        }
        else
        {
            query = query.Where(c => c.IsDefault || c.CreatedById == _currentUser.UserId);
        }

        var categories = await query
            .Include(c => c.CreatedBy)
            .OrderByDescending(c => c.IsDefault)
            .ThenBy(c => c.Name)
            .ToListAsync(cancellationToken);

        return new GetCategoriesResponseDto
        {
            Categories = categories.Select(c => c.ToDto()).ToList()
        };
    }
}
```

---

### CreateCategoryCommand

**Purpose**: Create a new custom category for the authenticated user.

**Handler**:
```csharp
public class CreateCategoryCommandHandler : IRequestHandler<CreateCategoryCommand, CategoryDto>
{
    private readonly IApplicationDbContext _context;
    private readonly ICurrentUserService _currentUser;

    public async Task<CategoryDto> Handle(
        CreateCategoryCommand request, 
        CancellationToken cancellationToken)
    {
        // Check uniqueness (case-insensitive)
        var exists = await _context.Categories
            .AnyAsync(c => c.CreatedById == _currentUser.UserId && 
                           EF.Functions.Like(c.Name.ToLower(), request.Name.ToLower()), 
                      cancellationToken);

        if (exists)
        {
            throw new ValidationException("A category with this name already exists");
        }

        // Create category
        var category = new Category
        {
            Id = Guid.NewGuid(),
            Name = request.Name.Trim(),
            Icon = request.Icon,
            Color = request.Color,
            IsDefault = false,
            CreatedById = _currentUser.UserId,
            CreatedAt = DateTime.UtcNow
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync(cancellationToken);

        // Load creator for DTO
        await _context.Entry(category)
            .Reference(c => c.CreatedBy)
            .LoadAsync(cancellationToken);

        return category.ToDto();
    }
}
```

---

## Error Handling

### Common Error Responses

**400 Bad Request** (Validation failure):
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Name": ["A category with this name already exists"],
    "Color": ["Color must be a valid hex code (e.g., #4CAF50 or #FFF)"]
  }
}
```

**401 Unauthorized** (No JWT token):
```json
{
  "type": "https://tools.ietf.org/html/rfc7235#section-3.1",
  "title": "Unauthorized",
  "status": 401
}
```

**404 Not Found** (Category not found):
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Category not found",
  "status": 404
}
```

---

## Performance Considerations

### Database Optimization
- Indexed queries for defaults (`IsDefault = true`)
- Indexed queries for user categories (`CreatedById = userId`)
- Composite unique index for name uniqueness check
- Avoid N+1 queries with `Include(c => c.CreatedBy)` when needed

### Caching Strategy
- Cache default categories in memory (1 hour TTL, they never change)
- User categories fetched per request (small dataset, <50 rows)
- No pagination needed (categories <100 per user)

### Query Performance
- `GET /categories` targets: <300ms (p95)
- `POST /categories` targets: <500ms (p95)
- Uniqueness check: <100ms (indexed query)

---

**Data Model Status**: ✅ Complete  
**Next**: Generate quickstart.md for developer guide


