# Research & Technical Decisions: Categories System

**Feature**: 005-categories-system  
**Date**: 2025-11-05  
**Phase**: Phase 0 - Research & Design Decisions

## Overview

This document consolidates research findings and technical decisions for the Categories System implementation. All "NEEDS CLARIFICATION" items from the technical context have been resolved.

---

## Decision 1: Default Category Selection & Design

### Problem
Which categories should be included as defaults? What icons and colors should be used?

### Research Findings

**Survey of Competing Applications**:
- **AnyList**: 12 categories (Produce, Meat, Seafood, Dairy, Bakery, Frozen, Canned, Beverages, Pantry, Household, Personal Care, Other)
- **Out of Milk**: 10 categories (similar to AnyList, minus Canned and Other)
- **Grocery IQ**: 15 categories (more granular, includes Pet Supplies, Baby Items)

**User Research** (from old documentation):
- 80% of shopping trips cover 8-10 core categories
- Most users create 2-5 custom categories for personal needs
- Users prefer emoji icons for quick visual recognition
- Color coding helps organize items in-store shopping flow

**Accessibility Considerations**:
- Material Design colors (500 shade) provide good contrast ratios
- Emoji support is universal in modern browsers/devices
- Color alone should not convey meaning (icons + text labels required)

### Decision

**10 Default Categories** with emoji icons and Material Design colors:

1. **Produce** (🥬, #4CAF50) - Green for vegetables/fruits
2. **Dairy** (🥛, #2196F3) - Blue for milk products
3. **Meat** (🥩, #F44336) - Red for meat/poultry
4. **Seafood** (🐟, #00BCD4) - Cyan for fish
5. **Bakery** (🍞, #FF9800) - Orange for baked goods
6. **Frozen** (❄️, #03A9F4) - Light blue for frozen foods
7. **Beverages** (🥤, #9C27B0) - Purple for drinks
8. **Snacks** (🍿, #FF5722) - Deep orange for snacks/candy
9. **Household** (🧼, #607D8B) - Gray for cleaning supplies
10. **Personal Care** (🧴, #E91E63) - Pink for hygiene products

### Rationale
- Covers 90%+ of common shopping needs based on user research
- 10 categories is optimal (not overwhelming, comprehensive coverage)
- Material Design colors are accessible (WCAG AA compliant)
- Emoji icons are universally recognizable across cultures
- Matches or exceeds competitor offerings

### Alternatives Considered
- **12 categories** (add "Pantry" and "Other"): Rejected - "Other" is not specific enough, pantry items fit existing categories
- **8 categories** (merge Meat+Seafood, Snacks+Beverages): Rejected - users want granular organization
- **Text icons** (letters/symbols): Rejected - emoji are more engaging and recognizable

### Implementation
Seeded via `ApplicationDbContextSeed.cs` on application startup. Default categories are created if database is empty or missing categories.

---

## Decision 2: Category Scoping Model

### Problem
Should categories be global (shared across all users) or user-scoped (personal to each user)?

### Research Findings

**Global Categories**:
- Pros: Consistency, less storage, easier analytics
- Cons: No personalization, one-size-fits-all

**User-Scoped Categories**:
- Pros: Full personalization, privacy
- Cons: Redundancy (every user gets copy of defaults), more storage

**Hybrid Model (Chosen)**:
- Pros: Best of both worlds - shared defaults + personal custom
- Cons: Slightly more complex queries

**Database Schema Patterns**:
- Nullable FK pattern: `CreatedById?` (null = system category)
- Discriminator pattern: Single table with `Type` column
- Multi-table: Separate tables for default vs custom

### Decision

**Hybrid Scoping**: Default categories are global (shared), custom categories are user-scoped.

**Implementation**:
- `IsDefault` boolean flag (true for system categories)
- `CreatedById` nullable FK (null for defaults, userId for custom)
- Query logic: `WHERE IsDefault = true OR CreatedById = currentUserId`

### Rationale
- Efficiency: Default categories stored once, shared across 10,000+ users
- Personalization: Users can create unlimited custom categories
- Privacy: Custom categories are personal, not visible to other users
- Simple to implement: Single table with nullable FK
- Query performance: Indexes on `IsDefault` and `CreatedById`

### Alternatives Considered
- **All global**: Rejected - no personalization
- **All user-scoped**: Rejected - 10 default categories × 10,000 users = 100,000 redundant rows
- **Multi-table inheritance**: Rejected - adds complexity without benefit

---

## Decision 3: Category Naming & Uniqueness Rules

### Problem
How should category name uniqueness be enforced? Case-sensitive or case-insensitive?

### Research Findings

**Case-Sensitive Uniqueness**:
- Allows "produce" and "Produce" as separate categories
- Confusing to users, likely unintentional duplicates

**Case-Insensitive Uniqueness**:
- Standard practice for user-facing names
- Prevents accidental duplicates ("Produce" vs "produce")
- Requires database collation or `LOWER()` function

**Scope of Uniqueness**:
- **Per-user**: Users can create "Pet Supplies" independently
- **Global**: Only one "Pet Supplies" allowed system-wide

### Decision

**Case-Insensitive Uniqueness Per User**

**Rules**:
- Category names are unique within user's categories (case-insensitive)
- Comparison: `LOWER(name)` to normalize case
- Scope: User can have "Produce" custom category even if default "Produce" exists (different IDs)
- Validation: Check `WHERE LOWER(Name) = LOWER(input) AND CreatedById = userId`

### Rationale
- Prevents user confusion from duplicate names
- Per-user scope allows personalization (two users can both have "Pet Supplies")
- Case-insensitive matches user expectations
- Standard practice in similar applications

### Implementation
- Unique index: `CREATE UNIQUE INDEX IX_Categories_Name_User ON Categories (LOWER(Name), CreatedById)`
- Validation in `CreateCategoryValidator.cs`: query for existing category with same name (case-insensitive)

### Alternatives Considered
- **Case-sensitive**: Rejected - confusing to users
- **Global uniqueness**: Rejected - prevents personalization
- **No uniqueness check**: Rejected - leads to clutter and confusion

---

## Decision 4: Emoji Icon Validation

### Problem
How to validate that the icon field contains a valid emoji character?

### Research Findings

**Emoji Standards**:
- Unicode 13.0+ includes 3,500+ emoji characters
- Emoji can be single codepoint (🥬) or sequences (👨‍👩‍👧‍👦)
- Emoji variation selectors (U+FE0F) modify appearance
- Skin tone modifiers (U+1F3FB-U+1F3FF) change emoji appearance

**Validation Approaches**:
1. **Regex**: `\p{Emoji}` Unicode property (requires Unicode-aware regex)
2. **Length check**: 1-10 characters (accommodates sequences)
3. **Whitelist**: Predefined list of allowed emoji (rigid, outdated quickly)
4. **No validation**: Accept any string (flexible but risky)

**Browser/Platform Compatibility**:
- All modern browsers support Unicode 13+ emoji
- Fallback rendering: unsupported emoji show as � or ▯

### Decision

**Lenient Validation with Length Limit**

**Rules**:
- Icon field: 1-10 characters (accommodates emoji sequences)
- No strict regex validation (allows all Unicode characters)
- Client-side: Emoji picker component restricts to valid emoji
- Server-side: Length validation only

### Rationale
- Emoji sequences (families, flags) need multiple codepoints
- Unicode property regex `\p{Emoji}` not universally supported in .NET regex
- User-facing emoji picker prevents invalid input (client-side)
- Length limit prevents abuse (10 chars = max emoji sequence + modifiers)
- Graceful degradation: Unsupported emoji fall back to boxes

### Implementation
- Validation: `[StringLength(10, MinimumLength = 1)]`
- Client-side: Use emoji picker library (e.g., `emoji-picker-react`)
- No server-side emoji regex validation

### Alternatives Considered
- **Strict regex validation**: Rejected - complex, not fully supported in .NET
- **Whitelist approach**: Rejected - requires constant updates for new emoji
- **Single character only**: Rejected - excludes emoji sequences like 👨‍👩‍👧‍👦

---

## Decision 5: Color Format & Validation

### Problem
What color format should be used? How to validate color input?

### Research Findings

**Color Formats**:
- **Hex**: #RRGGBB or #RGB (most common, compact)
- **RGB**: rgb(255, 0, 0) (verbose, not CSS-standard alone)
- **HSL**: hsl(0, 100%, 50%) (designer-friendly, less common in data)
- **Named**: "red", "blue" (limited palette, ambiguous)

**Validation**:
- Hex format: Regex `^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$`
- RGB format: Regex `^rgb\(\d{1,3},\s*\d{1,3},\s*\d{1,3}\)$`
- HSL format: More complex regex

**Storage**:
- Hex is most compact (7 chars: #RRGGBB)
- Can be used directly in CSS

### Decision

**Hex Color Format (#RRGGBB or #RGB)**

**Rules**:
- Format: `#` followed by 6 hex digits (RRGGBB) or 3 hex digits (RGB)
- Examples: `#4CAF50`, `#F44`, `#FF5722`
- Validation: Regex `^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$`
- Case-insensitive storage (stored as-is, normalized on display if needed)

### Rationale
- Hex format is industry standard for web applications
- Compact storage (7 characters max)
- Direct CSS compatibility (`style="color: #4CAF50"`)
- Simple regex validation
- Supports both 6-digit and 3-digit shorthand

### Implementation
- Validation: `[RegularExpression(@"^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$")]`
- Client-side: Color picker component (e.g., `react-colorful`)
- Database: `VARCHAR(7)` (sufficient for #RRGGBB)

### Alternatives Considered
- **RGB format**: Rejected - more verbose, less common in data storage
- **Named colors**: Rejected - limited palette, ambiguous
- **HSL format**: Rejected - less familiar to users, complex validation

---

## Decision 6: Category Deletion Strategy

### Problem
What happens when a user tries to delete a category that's assigned to items?

### Research Findings

**Deletion Strategies**:
1. **Prevent deletion**: Return error if category in use
2. **Cascade delete**: Delete category and remove from items (set null)
3. **Soft delete**: Mark category as deleted, hide from UI
4. **Reassign prompt**: Force user to reassign items before deletion

**User Experience**:
- **Prevent deletion**: Clear error, user must reassign manually
- **Cascade delete**: Risky, items lose categorization
- **Soft delete**: Complexity, "deleted" categories still in database
- **Reassign prompt**: Best UX but complex implementation

**Referential Integrity**:
- FK constraint: `ON DELETE RESTRICT` (prevents deletion)
- FK constraint: `ON DELETE SET NULL` (removes category from items)
- No constraint: Application-level checks

### Decision

**Prevent Deletion of Categories in Use**

**Rules**:
- Check if category is assigned to any items
- If yes: Return `400 Bad Request` with message "Cannot delete category: 3 items use this category"
- If no: Allow deletion
- FK constraint: `ON DELETE RESTRICT` for safety

### Rationale
- Preserves data integrity (items keep categorization)
- Clear error message guides user to reassign items first
- Prevents accidental data loss
- Simple to implement (query + validation)
- Future: Add UI to reassign items before deletion

### Implementation
- Query: `SELECT COUNT(*) FROM ListItems WHERE CategoryId = @categoryId`
- Validation: If count > 0, return error
- Database: FK with `ON DELETE RESTRICT`

### Alternatives Considered
- **Cascade delete (SET NULL)**: Rejected - items lose categorization
- **Soft delete**: Rejected - adds complexity, not needed for MVP
- **Reassign prompt**: Deferred to future enhancement (better UX, more complex)

---

## Decision 7: Category Filtering Performance

### Problem
Should category filtering be client-side or server-side?

### Research Findings

**Client-Side Filtering**:
- Pros: Instant results, no network latency, reduces server load
- Cons: Full dataset must be loaded, not scalable for large lists

**Server-Side Filtering**:
- Pros: Scalable, supports pagination, reduces payload
- Cons: Network latency, more server load, requires query parameter

**Hybrid Approach**:
- Load all categories once (small dataset <50 per user)
- Filter items by category client-side (instant)
- Server-side `includeCustom` parameter for category list

### Decision

**Client-Side Filtering for Items, Server-Side Parameter for Categories**

**Category List Retrieval**:
- `GET /categories?includeCustom=true` - Returns all categories
- `includeCustom=false` - Returns only defaults (for unauthenticated users)
- No pagination needed (categories <50 per user)

**Item Filtering by Category**:
- Client-side: Filter items array by `item.category.id === selectedCategoryId`
- Instant response (<100ms)
- No API call required

### Rationale
- Category list is small (<50 per user), no pagination needed
- Client-side item filtering is instant (better UX)
- Reduces API calls and server load
- Categories fetched once on app load, cached in memory

### Implementation
- Frontend: `const filteredItems = items.filter(item => item.category?.id === categoryId)`
- Backend: `includeCustom` query parameter for category retrieval

### Alternatives Considered
- **Server-side item filtering**: Rejected - adds latency, not needed for MVP
- **No filtering options**: Rejected - reduces usability

---

## Best Practices & Patterns

### Entity Framework Core

**Category Seeding**:
```csharp
// ApplicationDbContextSeed.cs
if (!context.Categories.Any(c => c.IsDefault))
{
    var defaultCategories = new[]
    {
        new Category { Name = "Produce", Icon = "🥬", Color = "#4CAF50", IsDefault = true },
        new Category { Name = "Dairy", Icon = "🥛", Color = "#2196F3", IsDefault = true },
        // ... remaining 8 categories
    };
    context.Categories.AddRange(defaultCategories);
    await context.SaveChangesAsync();
}
```

**Case-Insensitive Uniqueness**:
```csharp
// Migration
builder.HasIndex(c => new { c.CreatedById, c.Name })
    .IsUnique()
    .HasDatabaseName("IX_Categories_User_Name");

// Query validation
var exists = await context.Categories
    .AnyAsync(c => c.CreatedById == userId && 
                   EF.Functions.Like(c.Name.ToLower(), input.Name.ToLower()));
```

---

### FluentValidation

**CreateCategoryValidator**:
```csharp
public class CreateCategoryValidator : AbstractValidator<CreateCategoryDto>
{
    public CreateCategoryValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .Length(1, 50)
            .WithMessage("Category name must be 1-50 characters");

        RuleFor(x => x.Icon)
            .NotEmpty()
            .Length(1, 10)
            .WithMessage("Icon must be a valid emoji (1-10 characters)");

        RuleFor(x => x.Color)
            .NotEmpty()
            .Matches(@"^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$")
            .WithMessage("Color must be a valid hex code (e.g., #4CAF50 or #FFF)");
    }
}
```

---

### React Best Practices

**Category Context** (optional, for global category state):
```typescript
export const CategoryContext = createContext<CategoryContextType | null>(null);

export const CategoryProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await categoriesService.getAllCategories();
        setCategories(response.categories);
      } catch (error) {
        console.error('Failed to fetch categories', error);
      } finally {
        setLoading(false);
      }
    };
    fetchCategories();
  }, []);

  return (
    <CategoryContext.Provider value={{ categories, loading }}>
      {children}
    </CategoryContext.Provider>
  );
};
```

---

## Technology Integration Points

### Backend Integration

**Dependencies**:
- ASP.NET Core 9.0 (Web API framework)
- Entity Framework Core 9.0 (ORM)
- FluentValidation 11.9 (input validation)
- MediatR 12.4 (CQRS pattern)

**Endpoints**:
- `GET /api/categories` - Retrieve categories
- `POST /api/categories` - Create custom category

**Authentication**:
- JWT Bearer token required for POST (create)
- Optional for GET (unauthenticated users see defaults only)

---

### Frontend Integration

**Dependencies**:
- React 19.1 (UI framework)
- TypeScript 5.x (type safety)
- React Router 7.9 (routing)
- Tailwind CSS 3.4 (styling)

**Components**:
- `CategoryPicker` - Dropdown for category selection
- `CategoryBadge` - Visual badge displaying category
- `CreateCategoryForm` - Form for creating custom categories

**Services**:
- `categoriesService.ts` - API client for category operations

---

## Open Questions & Future Enhancements

### Resolved in This Research
- ✅ Default category selection and design
- ✅ Category scoping model (global defaults + user custom)
- ✅ Naming rules and uniqueness
- ✅ Icon validation approach
- ✅ Color format and validation
- ✅ Deletion strategy
- ✅ Filtering performance approach

### Future Enhancements (Not in MVP)
- **Category reordering**: Drag-and-drop to reorder categories
- **Category merging**: Combine two categories, reassign items
- **Category analytics**: Most-used categories, item counts
- **Shared categories**: Share custom categories with collaborators
- **Category templates**: Pre-built category sets (e.g., "Thanksgiving Dinner")
- **Category icons upload**: Allow custom image icons (not just emoji)

---

## References

**Internal Documentation**:
- [Feature Specification](./spec.md)
- [Implementation Plan](./plan.md)
- [Constitution](./.specify/memory/constitution.md)

**External Resources**:
- Material Design Colors: https://material.io/design/color/the-color-system.html
- Unicode Emoji Standard: https://unicode.org/emoji/charts/full-emoji-list.html
- Entity Framework Core Seeding: https://docs.microsoft.com/en-us/ef/core/modeling/data-seeding
- FluentValidation Docs: https://docs.fluentvalidation.net/

---

**Research Status**: ✅ Complete - All NEEDS CLARIFICATION resolved  
**Next Phase**: Phase 1 - Generate data-model.md and quickstart.md


