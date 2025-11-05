# Research: List Items Management

**Feature**: 004-list-items-management  
**Date**: 2025-11-05  
**Purpose**: Resolve technical unknowns identified in [plan.md](./plan.md) before implementation

---

## Research Task 1: Drag-and-Drop Library Selection

### Context
Need a drag-and-drop library for React that:
- Supports touch devices (mobile)
- Has good TypeScript support
- Is actively maintained
- Works well with lists/arrays

### Options Evaluated

#### Option 1: react-beautiful-dnd
- **Pros**:
  - Beautiful animations out of the box
  - Excellent documentation and examples
  - Built specifically for lists (vertical/horizontal)
  - Strong TypeScript support
  - Accessibility built-in (keyboard navigation)
- **Cons**:
  - ⚠️ Project in maintenance mode (last release 2021)
  - Not actively maintained, no new features
  - No React 18+ concurrent features support

#### Option 2: @dnd-kit
- **Pros**:
  - Modern, actively maintained (2024 releases)
  - Built for React 18+
  - Modular architecture (only import what you need)
  - Excellent TypeScript support
  - Touch and pointer events support
  - Performance optimized (uses transform vs. position)
  - Accessibility features
- **Cons**:
  - Steeper learning curve (more configuration needed)
  - Requires more boilerplate code

#### Option 3: react-dnd
- **Pros**:
  - Very mature and stable
  - Flexible (supports any drag-drop use case)
  - Good TypeScript support
- **Cons**:
  - More complex API (backend/monitor pattern)
  - Overkill for simple list reordering
  - Larger bundle size

### Decision: @dnd-kit

**Rationale**:
- Actively maintained with React 18+ support (our project uses React 19.1)
- Modern architecture aligned with current React best practices
- Performance optimized for lists (critical for 500+ items)
- Modular imports reduce bundle size
- Strong TypeScript support matches our strict mode requirements
- Touch support is first-class (not an afterthought)

**Implementation Packages**:
```bash
npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
```

**Example Usage**:
```typescript
import { DndContext, closestCenter } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';

<DndContext onDragEnd={handleDragEnd} collisionDetection={closestCenter}>
  <SortableContext items={itemIds} strategy={verticalListSortingStrategy}>
    {items.map(item => <SortableItem key={item.id} item={item} />)}
  </SortableContext>
</DndContext>
```

**Alternatives Rejected**:
- react-beautiful-dnd: Maintenance mode is risky for long-term project
- react-dnd: Too complex for our simple list reordering use case

---

## Research Task 2: Position Management Strategy

### Context
Need to determine how to manage item positions in the list (drag-drop order). Two main approaches:

### Option 1: Integer Positions (1, 2, 3, 4...)
- Simple incrementing integers
- When item moves from position 5 to 2: update all positions 2-5 (shift by 1)

**Pros**:
- Simple to understand and implement
- Easy to query (ORDER BY Position ASC)
- No precision issues

**Cons**:
- Requires updating multiple rows on each reorder
- Potential for race conditions if multiple users reorder simultaneously
- Database transaction overhead

### Option 2: Fractional Indexing
- Use fractional positions (e.g., "a0", "a1", "a2"... or numeric decimals)
- When item moves between two items, calculate midpoint position
- Only update the moved item

**Pros**:
- Only 1 row updated on reorder (not N rows)
- Better for concurrent edits (less locking)
- Scales better with large lists

**Cons**:
- More complex implementation
- Precision issues with decimals (float arithmetic)
- Need to "rebalance" positions occasionally

### Decision: Integer Positions with Batch Update

**Rationale**:
- Simplicity trumps optimization for MVP (Constitution: default to simplicity)
- Real-time collaboration (concurrent reorders) deferred to Feature 007
- For MVP: only one user reordering at a time (single session)
- Performance acceptable for 10-100 items (typical use case)
- Database transaction ensures consistency

**Implementation Strategy**:
```csharp
// ReorderItemsCommand
public async Task<Unit> Handle(ReorderItemsCommand request)
{
    using var transaction = await _context.Database.BeginTransactionAsync();
    
    foreach (var itemPosition in request.ItemPositions)
    {
        var item = await _context.ListItems.FindAsync(itemPosition.ItemId);
        item.Position = itemPosition.Position;
    }
    
    await _context.SaveChangesAsync();
    await transaction.CommitAsync();
    
    return Unit.Value;
}
```

**Frontend Optimization**:
- Calculate new positions client-side
- Send batch update to API (single request)
- Optimistic UI update (immediate reorder, rollback on error)

**Future Enhancement** (Feature 007):
- If real-time conflicts become issue, migrate to fractional indexing
- For now: YAGNI (You Ain't Gonna Need It)

**Alternatives Rejected**:
- Fractional indexing: Premature optimization, added complexity without proven need

---

## Research Task 3: Autocomplete Performance

### Context
Autocomplete suggestions from user's previous items across all lists. Concerns:
- User might have 1000+ items across 50+ lists
- Need to rank by frequency (most used items first)
- Need fast response time (<300ms)

### Option 1: Client-side Filtering
- Fetch all user's items once on page load
- Filter/search in JavaScript
- Cache in Redux/Context

**Pros**:
- Instant results (no network latency)
- Works offline

**Cons**:
- Large initial payload (1000 items ≈ 200KB)
- Memory usage on client
- Doesn't work well for new users with many items

### Option 2: Server-side Query with Caching
- API endpoint: GET /lists/items/autocomplete?q={query}
- SQL query with LIKE and GROUP BY for frequency
- Cache results in React Query (5 minute stale time)

**Pros**:
- Small payloads (only matching results)
- Database can use indexes for fast search
- Scales to any number of items

**Cons**:
- Network latency (but debounced to 300ms)
- Requires internet connection

### Option 3: Hybrid (Cache Top 100)
- Fetch top 100 most frequent items on page load
- Use client-side filtering for those
- Fallback to server query if not in cache

### Decision: Server-side Query with Aggressive Caching

**Rationale**:
- Scales to any number of items (no client memory limits)
- Database indexes make queries fast (< 50ms)
- Debouncing (300ms) masks network latency
- React Query cache reduces API calls (only first query hits server)
- Aligns with API-first architecture

**Implementation**:

**Backend** (GetAutocompleteQuery):
```csharp
public async Task<List<AutocompleteResult>> Handle(GetAutocompleteQuery request)
{
    var results = await _context.ListItems
        .Where(i => i.CreatedById == request.UserId && 
                    i.Name.Contains(request.Query))
        .GroupBy(i => new { i.Name, i.Quantity, i.Unit, i.CategoryId })
        .Select(g => new AutocompleteResult {
            Name = g.Key.Name,
            Quantity = g.Key.Quantity,
            Unit = g.Key.Unit,
            CategoryId = g.Key.CategoryId,
            Frequency = g.Count()
        })
        .OrderByDescending(r => r.Frequency)
        .Take(10)
        .ToListAsync();
    
    return results;
}
```

**Frontend** (useItemAutocomplete hook):
```typescript
export const useItemAutocomplete = (query: string) => {
  const debouncedQuery = useDebounce(query, 300);
  
  return useQuery({
    queryKey: ['item-autocomplete', debouncedQuery],
    queryFn: () => fetchAutocomplete(debouncedQuery),
    enabled: debouncedQuery.length >= 2,
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000, // 10 minutes
  });
};
```

**Database Index** (for performance):
```sql
CREATE INDEX IX_ListItems_CreatedBy_Name ON ListItems(CreatedById, Name);
```

**Performance Target**: < 300ms total (50ms query + 250ms network/debounce)

**Alternatives Rejected**:
- Client-side: Doesn't scale, large payloads
- Hybrid: Added complexity without significant benefit

---

## Research Task 4: Filtering/Sorting Implementation

### Context
Users need to filter items by category and purchased status, sort by name/date/category. Concerns:
- Query performance with filters + sorting
- Frontend state management for filters

### Filtering Options

#### Option 1: Client-side Filtering
- Fetch all items, filter in JavaScript

**Pros**: No additional API calls

**Cons**: Doesn't scale to 500+ items, wastes bandwidth

#### Option 2: Server-side Filtering
- Query params: ?categoryId={id}&purchased={bool}&sortBy={field}&sortOrder={asc|desc}

**Pros**: Only fetch what's needed, database indexes help

**Cons**: More API calls

### Decision: Server-side Filtering with URL State

**Rationale**:
- Database indexes make filtered queries fast
- Supports deep linking (shareable URLs)
- Scales to large lists
- Browser back/forward work correctly

**API Design**:
```
GET /lists/{listId}/items?categoryId={id}&purchased={bool|null}&sortBy={name|position|createdAt|category}&sortOrder={asc|desc}
```

**Backend Implementation**:
```csharp
var query = _context.ListItems.Where(i => i.ListId == request.ListId);

if (request.CategoryId != null)
    query = query.Where(i => i.CategoryId == request.CategoryId);

if (request.Purchased != null)
    query = query.Where(i => i.IsPurchased == request.Purchased);

query = request.SortBy switch {
    "name" => query.OrderBy(i => i.Name),
    "createdAt" => query.OrderBy(i => i.CreatedAt),
    "category" => query.OrderBy(i => i.Category.Name),
    _ => query.OrderBy(i => i.Position) // default
};

if (request.SortOrder == "desc")
    query = query.Reverse();
```

**Frontend State**:
```typescript
// Use URL search params for filter/sort state
const [searchParams, setSearchParams] = useSearchParams();
const categoryId = searchParams.get('category');
const purchased = searchParams.get('purchased');
const sortBy = searchParams.get('sortBy') || 'position';

// Fetch items with filters
const { data: items } = useQuery({
  queryKey: ['items', listId, categoryId, purchased, sortBy],
  queryFn: () => fetchItems(listId, { categoryId, purchased, sortBy }),
});
```

**Database Indexes**:
```sql
CREATE INDEX IX_ListItems_ListId_CategoryId ON ListItems(ListId, CategoryId);
CREATE INDEX IX_ListItems_ListId_Purchased ON ListItems(ListId, IsPurchased);
```

**Alternatives Rejected**:
- Client-side: Doesn't scale to 500+ items, wastes bandwidth on mobile

---

## Research Task 5: Permission Check Strategy

### Context
Need to check if user has permission to edit/delete items (based on list ownership/collaboration). Options:

### Option 1: Check Per-Item Operation
- Every item API call checks list permissions
- Query: JOIN lists ON items.ListId = lists.Id WHERE lists has permission

**Pros**: Simple, explicit

**Cons**: Extra database query per operation

### Option 2: Check Once Per Request (Middleware)
- Create middleware that checks list permissions
- Cache permission in request context
- Item operations assume permission checked

### Option 3: Include Permission in Item Response
- GET /lists/{listId}/items returns permission in response
- Frontend caches permission, disables buttons accordingly

### Decision: Middleware + Response Permission

**Rationale**:
- Middleware prevents unauthorized API calls (security)
- Permission in response enables frontend UI (UX)
- Single database query per request (efficient)
- Defense in depth (check both frontend and backend)

**Implementation**:

**Backend Middleware**:
```csharp
public class ListPermissionMiddleware
{
    public async Task InvokeAsync(HttpContext context, IListRepository listRepo)
    {
        var listId = context.Request.RouteValues["listId"]?.ToString();
        var userId = context.User.FindFirst("userId")?.Value;
        
        var permission = await listRepo.GetUserPermissionAsync(listId, userId);
        
        if (permission == null)
            context.Response.StatusCode = 403;
        else
            context.Items["ListPermission"] = permission; // Cache for request
        
        await _next(context);
    }
}
```

**Backend Command Handler**:
```csharp
public class DeleteItemCommandHandler
{
    public async Task<Unit> Handle(DeleteItemCommand request, HttpContext httpContext)
    {
        var permission = httpContext.Items["ListPermission"] as Permission;
        
        if (permission == Permission.Viewer)
            throw new ForbiddenException("Viewers cannot delete items");
        
        // ... delete logic
    }
}
```

**Frontend**:
```typescript
// GET /lists/{listId}/items response includes permission
{
  "items": [...],
  "permission": "Editor" // or "Owner" or "Viewer"
}

// useItems hook caches permission
const { data } = useQuery(['items', listId]);
const canEdit = data?.permission === 'Editor' || data?.permission === 'Owner';

// Conditionally render edit button
{canEdit && <button onClick={handleEdit}>Edit</button>}
```

**Alternatives Rejected**:
- Per-item check: Too many database queries (inefficient)
- Frontend-only: Not secure (users can bypass UI restrictions)

---

## Summary of Decisions

| Research Task | Decision | Rationale |
|---------------|----------|-----------|
| **Drag-Drop Library** | @dnd-kit | Modern, actively maintained, React 18+ support, performance optimized |
| **Position Management** | Integer positions with batch update | Simple, sufficient for MVP, defer fractional indexing until proven need |
| **Autocomplete** | Server-side query with caching | Scales to any number of items, database indexes fast, React Query cache |
| **Filter/Sort** | Server-side with URL state | Database indexed queries fast, deep linking, browser back/forward |
| **Permission Check** | Middleware + response permission | Security at backend (middleware), UX at frontend (cached permission) |

---

## Next Phase

**Phase 1**: Design & Implementation
- Create data-model.md with entity definitions
- Create API contracts in /contracts/ directory
- Create quickstart.md with code examples
- Update agent context with new technologies (@dnd-kit)

**Ready to proceed**: ✅ All research tasks complete, decisions documented

