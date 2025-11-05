# Implementation Plan: List Items Management

**Branch**: `004-list-items-management` | **Date**: 2025-11-05 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/004-list-items-management/spec.md`

## Summary

Complete list items management system enabling users to add, edit, delete, reorder, and track purchase status of items within shopping lists. Items include rich details (name, quantity, unit, category, notes) and support drag-and-drop reordering, autocomplete suggestions, and filtering/sorting capabilities.

**Current State**: Backend 90% (all CRUD endpoints exist), Frontend 70% (UI ready with mock data), Integration 0%  
**Target State**: Fully integrated items management with strict validation, permission checks, and real-world item operations

---

## Technical Context

**Language/Version**: 
- Backend: C# / .NET 9.0
- Frontend: TypeScript / React 19.1

**Primary Dependencies**: 
- Backend: ASP.NET Core 9.0, Entity Framework Core 9.0, MediatR 12.4, FluentValidation 11.9, AutoMapper 12.0, Serilog 8.0, SignalR 9.0
- Frontend: React 19.1, React Router 7.9, Vite 7.1, Tailwind CSS 3.4, React Hook Form 7.51, @microsoft/signalr 8.0
- Real-time: SignalR for WebSocket-based collaborative item management

**Storage**: SQLite (embedded database via Entity Framework Core 9.0, file: `app.db`)

**Testing**: 
- Backend: xUnit, Moq, WebApplicationFactory (integration tests)
- Frontend: Vitest, React Testing Library, MSW (Mock Service Worker)

**Target Platform**: 
- Backend: Linux/Windows server, Docker containers
- Frontend: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+), mobile-responsive

**Project Type**: Web application (separate frontend/backend repositories)

**Performance Goals**: 
- Item operations (add/edit/delete) response time: <200ms (p95)
- List with 50 items render time: <1 second
- Drag-and-drop reorder: <100ms perceived latency
- Autocomplete suggestions: <300ms
- Support 500+ items per list without degradation

**Constraints**: 
- Item name: 1-100 characters (required)
- Item notes: max 500 characters (optional)
- Quantity: positive number, default 1
- Viewers can mark purchased but cannot edit/delete items
- Hard delete (not soft) for performance with large lists

**Scale/Scope**: 
- Expected lists: 10,000+ lists across all users
- Items per list: 10-100 typical, 500 maximum supported
- Concurrent users: 1,000-10,000
- Real-time updates: deferred to Feature 007 (not in this scope)

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

### Core Principles Compliance

✅ **Specification-First Development** (Principle I)
- Complete specification exists in `spec.md` with 8 user stories, 39 acceptance scenarios, 53 functional requirements
- This plan.md documents technical approach before implementation
- All acceptance criteria are testable

✅ **Test-Driven Development** (Principle V)
- Unit tests will be written before implementation (services, validators, utilities)
- Integration tests for all API endpoints (WebApplicationFactory)
- Component tests for React components (React Testing Library)
- Minimum 80% coverage target enforced

✅ **Security & Privacy by Design** (Principle IV)
- JWT authentication required for all item endpoints
- Permission checks: Owner/Editor can CRUD, Viewer can only mark purchased
- Input validation with FluentValidation (name length, quantity positive, notes max 500)
- Parameterized queries via Entity Framework Core prevent SQL injection

✅ **Real-time Collaboration Architecture** (Principle III)
- **Status**: IMPLEMENTED - Item updates broadcast via SignalR to all list collaborators
- **Implementation**: SignalR hub extended for item operations (create, update, delete, purchase, reorder)
- **Optimistic UI**: Frontend implements optimistic updates with rollback on errors
- **Latency Target**: Real-time item updates reflected within 2 seconds (per Constitution Principle III)

✅ **OpenSpec Change Management** (Principle II)
- This feature follows specification workflow (spec → plan → implementation)
- New feature, not a breaking change to existing system
- No OpenSpec proposal required (new capability, not modifying existing)

### Technical Standards Compliance

✅ **Frontend Standards**
- TypeScript strict mode enabled (no `any` types)
- Functional components with hooks (no class components)
- Code splitting by route with lazy loading
- Tailwind CSS utility-first approach
- WCAG 2.1 AA accessibility compliance

✅ **Backend Standards**
- Clean Architecture: API → Application → Domain → Infrastructure
- Dependency Injection throughout
- Async/await for all I/O operations
- Entity Framework Core for data access (no raw SQL)
- SOLID principles enforced

✅ **API Design Principles**
- RESTful conventions: POST `/lists/{listId}/items`, PUT `/lists/{listId}/items/{itemId}`
- Proper HTTP verbs: GET (read), POST (create), PUT (update), DELETE (delete), PATCH (partial update)
- Consistent error responses: 400 (validation), 403 (permissions), 404 (not found)
- Filtering and sorting via query parameters

### Gates Result

**Status**: ✅ **PASSED** - All constitution checks satisfied

**Exceptions**: Real-time collaboration deferred to Feature 007 (documented in spec.md Out of Scope section)

---

## Project Structure

### Documentation (this feature)

```text
specs/004-list-items-management/
├── plan.md              # This file (Phase 0: Planning)
├── research.md          # Phase 0: Research findings and decisions
├── data-model.md        # Phase 1: Entity definitions, DTOs, validation
├── quickstart.md        # Phase 1: Step-by-step developer guide
├── contracts/           # Phase 1: API JSON schemas
│   ├── create-item-request.json
│   ├── update-item-request.json
│   ├── item-response.json
│   ├── items-list-response.json
│   ├── toggle-purchased-request.json
│   ├── reorder-items-request.json
│   └── autocomplete-response.json
├── tasks.md             # Phase 2: Implementation checklist (NOT created by /speckit.plan)
└── checklists/
    └── requirements.md  # Quality validation (already completed ✅)
```

### Source Code (repository root)

**Backend** (`ae-infinity-api/`):
```text
src/
├── API/
│   ├── Controllers/
│   │   └── ListItemsController.cs       # PATCH for purchased, reorder
│   ├── Hubs/
│   │   └── ShoppingListHub.cs           # EXTEND - Add item event methods (from Feature 003)
│   └── Program.cs                       # VERIFY - SignalR already configured in Feature 003
├── Application/
│   ├── ListItems/
│   │   ├── Commands/
│   │   │   ├── CreateItemCommand.cs     # Add item to list
│   │   │   ├── UpdateItemCommand.cs     # Edit item details
│   │   │   ├── DeleteItemCommand.cs     # Remove item
│   │   │   ├── TogglePurchasedCommand.cs # Mark purchased/unpurchased
│   │   │   └── ReorderItemsCommand.cs   # Drag-and-drop positions
│   │   ├── Queries/
│   │   │   ├── GetItemsQuery.cs         # List all items with filters
│   │   │   └── GetAutocompleteQuery.cs  # Suggestions from history
│   │   └── Validators/
│   │       ├── CreateItemValidator.cs   # FluentValidation rules
│   │       ├── UpdateItemValidator.cs
│   │       └── ReorderItemsValidator.cs
│   └── Common/
│       └── Interfaces/
│           └── IListItemRepository.cs   # Repository interface
├── Domain/
│   └── Entities/
│       └── ListItem.cs                  # Entity with nav properties
└── Infrastructure/
    └── Persistence/
        └── Repositories/
            └── ListItemRepository.cs    # EF Core queries
```

**Frontend** (`ae-infinity-ui/`):
```text
src/
├── components/
│   ├── items/
│   │   ├── ItemCard.tsx                 # Individual item display + optimistic UI
│   │   ├── ItemForm.tsx                 # Add/Edit item form + optimistic UI
│   │   ├── ItemList.tsx                 # List of items with drag-drop + SignalR events
│   │   ├── QuickAddInput.tsx            # Quick add with autocomplete
│   │   ├── ItemFilters.tsx              # Category/status filters
│   │   └── ItemPurchaseCheckbox.tsx     # Purchase status toggle + optimistic UI
│   └── common/
│       ├── ConfirmDialog.tsx            # Delete confirmation
│       ├── AutocompleteInput.tsx        # Reusable autocomplete
│       └── ConflictNotification.tsx     # NEW - Conflict warning toast
├── hooks/
│   ├── useItems.ts                      # Items CRUD operations + optimistic updates
│   ├── useItemEvents.ts                 # NEW - SignalR item event handlers
│   ├── useItemAutocomplete.ts           # Autocomplete suggestions
│   ├── useItemDragDrop.ts               # Drag-and-drop logic
│   └── useSignalR.ts                    # REUSE - From Feature 003 (connection management)
├── services/
│   ├── itemsService.ts                  # API client (already exists ✅)
│   └── signalrService.ts                # REUSE - From Feature 003
└── types/
    ├── index.ts                         # TypeScript interfaces
    └── signalr.ts                       # EXTEND - Add item event types
```

**Test Files** (backend):
```text
tests/
├── Application.Tests/
│   └── ListItems/
│       ├── Commands/
│       │   ├── CreateItemCommandTests.cs
│       │   ├── UpdateItemCommandTests.cs
│       │   ├── DeleteItemCommandTests.cs
│       │   ├── TogglePurchasedCommandTests.cs
│       │   └── ReorderItemsCommandTests.cs
│       └── Queries/
│           ├── GetItemsQueryTests.cs
│           └── GetAutocompleteQueryTests.cs
└── API.Tests/
    └── Controllers/
        └── ListItemsControllerTests.cs  # Integration tests
```

**Test Files** (frontend):
```text
src/
├── components/items/__tests__/
│   ├── ItemCard.test.tsx
│   ├── ItemForm.test.tsx
│   ├── ItemList.test.tsx
│   └── QuickAddInput.test.tsx
└── hooks/__tests__/
    ├── useItems.test.ts
    ├── useItemAutocomplete.test.ts
    └── useItemDragDrop.test.ts
```

**Structure Decision**: Web application (Option 2) with separate backend and frontend repositories. Backend follows Clean Architecture with CQRS pattern (MediatR commands/queries). Frontend uses feature-based component organization with shared hooks for logic reuse.

---

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| *(None)* | *(All constitution checks passed)* | *(No violations to justify)* |

**Notes**: 
- No additional complexity introduced beyond project standards
- CQRS pattern already established in Feature 001 (User Authentication)
- Drag-and-drop library (react-beautiful-dnd or @dnd-kit) is industry standard, not custom implementation
- Autocomplete uses existing patterns from other features

---

## Phase 0: Research & Decisions

### Research Tasks

1. **Drag-and-Drop Library Selection**
   - **Task**: Evaluate drag-and-drop libraries for React (react-beautiful-dnd, @dnd-kit, react-dnd)
   - **Goal**: Choose library that supports touch devices, has good TypeScript support, and is actively maintained

2. **Position Management Strategy**
   - **Task**: Research best practices for managing item positions (integer positions vs. fractional indexing)
   - **Goal**: Determine if simple integer positions (1, 2, 3...) are sufficient or if fractional indexing needed

3. **Autocomplete Performance**
   - **Task**: Evaluate autocomplete strategies (client-side vs. server-side, caching approaches)
   - **Goal**: Determine optimal approach for autocomplete with 1000+ historical items across all user's lists

4. **Filtering/Sorting Implementation**
   - **Task**: Research query optimization for filtering by category and sorting by multiple fields
   - **Goal**: Ensure database indexes are properly configured for common filter/sort combinations

5. **Permission Check Strategy**
   - **Task**: Verify how to efficiently check list permissions when operating on items
   - **Goal**: Determine if permission check should be at list level (fetch once) or item level (check each operation)

### Key Decisions

*(These will be documented in research.md during Phase 0 execution)*

---

## Phase 1: Design & Implementation

### Backend Design

#### Entities

**ListItem** (Domain/Entities/ListItem.cs):
- Properties: Id, ListId, Name, Quantity, Unit, CategoryId, Notes, ImageUrl, IsPurchased, Position, CreatedById, CreatedAt, UpdatedAt, PurchasedAt, PurchasedById
- Relationships: Belongs to List (many-to-one), Belongs to Category (optional), Created by User, Purchased by User (optional)
- Validation: Name 1-100 chars, Quantity > 0, Notes max 500 chars, Position ≥ 0

#### Commands

1. **CreateItemCommand**: Add item with name, quantity, unit, categoryId, notes
2. **UpdateItemCommand**: Edit item details (all fields except position/purchased)
3. **DeleteItemCommand**: Remove item permanently (hard delete)
4. **TogglePurchasedCommand**: Set IsPurchased, record PurchasedAt and PurchasedById
5. **ReorderItemsCommand**: Update positions for multiple items in one transaction

#### Queries

1. **GetItemsQuery**: Fetch all items for a list with filters (categoryId, purchased status) and sort options
2. **GetAutocompleteQuery**: Fetch unique item names from user's previous items across all lists

#### Validators

- **CreateItemValidator**: Name required, 1-100 chars; Quantity > 0; Notes max 500 chars
- **UpdateItemValidator**: Same as create
- **ReorderItemsValidator**: All itemIds must belong to the same list, positions must be unique

### Frontend Design

#### Components

1. **ItemList**: Container component with drag-drop context, renders ItemCard components
2. **ItemCard**: Display single item with checkbox, name, quantity, category icon, notes icon, edit/delete buttons
3. **ItemForm**: Modal form for add/edit with fields for name, quantity, unit, category dropdown, notes textarea
4. **QuickAddInput**: Inline input with autocomplete dropdown, optimized for fast item entry
5. **ItemFilters**: Filter buttons for category and purchased status, sort dropdown
6. **ConfirmDialog**: Generic delete confirmation modal

#### Hooks

1. **useItems**: CRUD operations (add, update, delete, toggle purchased), local state management with optimistic updates
2. **useItemAutocomplete**: Fetch and cache autocomplete suggestions, debounced search
3. **useItemDragDrop**: Handle drag start/end events, update positions via API

#### State Management

- **Local State**: Each ItemCard manages its own hover/focus state
- **React Query / SWR**: Server state for items list (caching, refetching)
- **Optimistic Updates**: Immediate UI update for toggle purchased, rollback on error

### API Contracts

All contracts will be defined in `/contracts/` directory as JSON Schema files:

1. `create-item-request.json`: POST /lists/{listId}/items body
2. `update-item-request.json`: PUT /lists/{listId}/items/{itemId} body
3. `item-response.json`: Single item response shape
4. `items-list-response.json`: GET /lists/{listId}/items response
5. `toggle-purchased-request.json`: PATCH /lists/{listId}/items/{itemId}/purchased body
6. `reorder-items-request.json`: PATCH /lists/{listId}/items/reorder body
7. `autocomplete-response.json`: GET /lists/items/autocomplete response

### Testing Strategy

#### Backend Tests (TDD Approach)

1. **Unit Tests** (Application.Tests):
   - Test each command handler in isolation with mocked repository
   - Test validators with invalid inputs (empty name, negative quantity, long notes)
   - Test queries with various filter/sort combinations
   - Coverage target: 90%+ for business logic

2. **Integration Tests** (API.Tests):
   - Test full request/response cycle using WebApplicationFactory
   - Test permission checks (viewer cannot edit, editor can)
   - Test database persistence (item created, position updated)
   - Test edge cases (delete non-existent item, reorder with invalid positions)
   - Coverage target: 80%+ for API layer

#### Frontend Tests

1. **Component Tests** (Vitest + React Testing Library):
   - Test ItemForm validation (empty name shows error)
   - Test ItemCard checkbox toggles purchased status
   - Test ItemList displays items in correct order
   - Test QuickAddInput shows autocomplete suggestions
   - Coverage target: 80%+ for components

2. **Hook Tests** (Vitest):
   - Test useItems CRUD operations with MSW mocked API
   - Test useItemAutocomplete debounce and caching
   - Test useItemDragDrop position calculation
   - Coverage target: 85%+ for hooks

3. **Integration Tests** (Vitest + MSW):
   - Test full add item flow (form submission → API call → list update)
   - Test permission-based UI (viewer sees no edit button)
   - Test error handling (API failure shows error message)

### Database Schema

**ListItems Table** (Entity Framework migration):
```sql
CREATE TABLE ListItems (
    Id TEXT PRIMARY KEY,
    ListId TEXT NOT NULL,
    Name TEXT NOT NULL CHECK(length(Name) >= 1 AND length(Name) <= 100),
    Quantity REAL NOT NULL DEFAULT 1 CHECK(Quantity > 0),
    Unit TEXT,
    CategoryId TEXT,
    Notes TEXT CHECK(length(Notes) <= 500),
    ImageUrl TEXT,
    IsPurchased INTEGER NOT NULL DEFAULT 0,
    Position INTEGER NOT NULL DEFAULT 0,
    CreatedById TEXT NOT NULL,
    CreatedAt TEXT NOT NULL,
    UpdatedAt TEXT NOT NULL,
    PurchasedAt TEXT,
    PurchasedById TEXT,
    FOREIGN KEY (ListId) REFERENCES Lists(Id) ON DELETE CASCADE,
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id) ON DELETE SET NULL,
    FOREIGN KEY (CreatedById) REFERENCES Users(Id),
    FOREIGN KEY (PurchasedById) REFERENCES Users(Id)
);

CREATE INDEX IX_ListItems_ListId ON ListItems(ListId);
CREATE INDEX IX_ListItems_CategoryId ON ListItems(CategoryId);
CREATE INDEX IX_ListItems_Position ON ListItems(ListId, Position);
CREATE INDEX IX_ListItems_CreatedById ON ListItems(CreatedById);
```

### Caching Strategy

1. **Backend**: No caching for items (always fresh data to support future real-time updates)
2. **Frontend**: React Query cache with 5-minute stale time, invalidate on mutations

---

## SignalR Real-time Architecture

### Hub Extension

**File**: `AeInfinity.Api/Hubs/ShoppingListHub.cs` (extends existing hub from Feature 003)

```csharp
public class ShoppingListHub : Hub
{
    // ... existing list methods from Feature 003 ...
    
    // Item-specific methods
    public async Task JoinItemsView(string listId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"list-items-{listId}");
    }
    
    public async Task LeaveItemsView(string listId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"list-items-{listId}");
    }
}
```

### Event Broadcasting

**Item command handlers broadcast events after successful database operations:**

```csharp
// Example: CreateItemCommandHandler
public async Task<Result<ItemResponse>> Handle(CreateItemCommand request)
{
    // ... create item in database ...
    
    // Broadcast to all list collaborators
    await _hubContext.Clients
        .Group($"list-items-{item.ListId}")
        .SendAsync("ItemCreated", new {
            listId = item.ListId,
            item = itemDto,
            userId = request.UserId
        });
    
    return Result<ItemResponse>.Success(itemDto);
}
```

**Events Broadcast**:
- `ItemCreated` - After CreateItemCommand succeeds
- `ItemUpdated` - After UpdateItemCommand succeeds
- `ItemDeleted` - After DeleteItemCommand succeeds (soft delete)
- `ItemPurchased` - After TogglePurchasedCommand succeeds (isPurchased = true)
- `ItemUnpurchased` - After TogglePurchasedCommand succeeds (isPurchased = false)
- `ItemsReordered` - After ReorderItemsCommand succeeds (batch position update)

### Frontend SignalR Integration

**Item Event Handlers** (`src/hooks/useItemEvents.ts`):
```typescript
export function useItemEvents(listId: string) {
  const { connection } = useSignalR();
  const queryClient = useQueryClient();
  
  useEffect(() => {
    if (!connection) return;
    
    connection.on('ItemCreated', (data) => {
      // Invalidate query to refetch items
      queryClient.invalidateQueries(['items', listId]);
      
      // Show toast notification
      toast.info(`${data.userId} added "${data.item.name}"`);
    });
    
    connection.on('ItemPurchased', (data) => {
      // Optimistic update in cache
      queryClient.setQueryData(['items', listId], (old) =>
        old.map(item => 
          item.id === data.itemId 
            ? { ...item, isPurchased: true, purchasedAt: data.timestamp }
            : item
        )
      );
    });
    
    // ... other event handlers ...
    
    return () => {
      connection.off('ItemCreated');
      connection.off('ItemPurchased');
      // ... cleanup other handlers ...
    };
  }, [connection, listId]);
}
```

**Optimistic UI Pattern for Purchase Toggle**:
```typescript
const togglePurchased = useMutation({
  mutationFn: (itemId: string) => itemsService.togglePurchased(listId, itemId),
  
  // Optimistic update
  onMutate: async (itemId) => {
    await queryClient.cancelQueries(['items', listId]);
    const previousItems = queryClient.getQueryData(['items', listId]);
    
    queryClient.setQueryData(['items', listId], (old) =>
      old.map(item =>
        item.id === itemId
          ? { ...item, isPurchased: !item.isPurchased }
          : item
      )
    );
    
    return { previousItems };
  },
  
  // Rollback on error
  onError: (err, itemId, context) => {
    queryClient.setQueryData(['items', listId], context.previousItems);
    toast.error('Failed to update item. Changes reverted.');
  },
  
  // Confirm success
  onSuccess: () => {
    // SignalR will broadcast to other users
  }
});
```

**Conflict Resolution**:
- Strategy: Last-write-wins for item edits
- Optimistic UI: Immediate purchase toggle, rollback on error
- User notification: Toast message "Another user updated this item"
- Detection: Compare UpdatedAt timestamp from SignalR event with local state

---

## Phase 2: Implementation Sequence

### Iteration 1: Core CRUD (P1 - Critical)

**User Stories**: 1 (Add), 3 (Edit), 4 (Delete)

**Backend Tasks**:
1. Create ListItem entity with all properties
2. Create CreateItemCommand with validator
3. Create UpdateItemCommand with validator
4. Create DeleteItemCommand
5. Create ListItemRepository with CRUD methods
6. Create GetItemsQuery (basic, no filters yet)
7. Write unit tests for commands/queries
8. Write integration tests for API endpoints

**Frontend Tasks**:
1. Create ItemForm component (add/edit modes)
2. Create useItems hook with add/update/delete operations
3. Create ItemCard component with edit/delete buttons
4. Create ItemList component (basic display)
5. Create ConfirmDialog component
6. Wire up ItemForm to useItems hook
7. Write component tests for ItemForm, ItemCard
8. Write hook tests for useItems

**Acceptance Criteria**:
- User can add item with name only (defaults: quantity 1, no category/notes)
- User can add item with all fields (name, quantity, unit, category, notes)
- User can edit existing item and changes persist
- User can delete item with confirmation dialog
- Validation errors shown for empty name, long name, negative quantity
- Viewer cannot see edit/delete buttons (permission check)

---

### Iteration 2: Purchase Tracking (P1 - Critical)

**User Stories**: 2 (Mark Purchased)

**Backend Tasks**:
1. Create TogglePurchasedCommand with validator
2. Update GetItemsQuery to include purchase status
3. Add logic to record PurchasedAt and PurchasedById
4. Write unit tests for toggle command
5. Write integration tests for purchase endpoint

**Frontend Tasks**:
1. Create ItemPurchaseCheckbox component
2. Update useItems hook with togglePurchased operation
3. Add visual distinction for purchased items (strikethrough, grayed)
4. Display "X of Y items purchased" summary
5. Show celebration message when all items purchased
6. Write component tests for purchase checkbox
7. Write integration test for purchase flow

**Acceptance Criteria**:
- User can check item to mark as purchased (timestamp recorded)
- User can uncheck item to mark as unpurchased (timestamp cleared)
- Purchased items show with strikethrough text
- List header shows correct purchased count (e.g., "3 of 8")
- Viewer can toggle purchased status (permission allowed)
- All items purchased shows celebration message

---

### Iteration 3: Reordering (P2 - Important)

**User Stories**: 5 (Drag-and-Drop)

**Backend Tasks**:
1. Create ReorderItemsCommand with validator
2. Implement position update logic (transaction for multiple items)
3. Write unit tests for reorder command
4. Write integration tests for reorder endpoint

**Frontend Tasks**:
1. Install and configure drag-and-drop library (from research decision)
2. Create useItemDragDrop hook
3. Update ItemList component with drag-drop context
4. Add drag handles to ItemCard component
5. Implement position calculation on drop
6. Add visual feedback during drag (preview, drop zone)
7. Write tests for drag-drop logic
8. Test touch gestures on mobile devices

**Acceptance Criteria**:
- User can drag item to new position and order persists
- Drag works on desktop (mouse) and mobile (touch)
- Visual feedback during drag (item preview, drop target)
- Other items shift to make space during drag
- Viewer cannot reorder items (drag disabled)
- Order persists on page refresh

---

### Iteration 4: Notes & Filters (P2/P3 - Enhancement)

**User Stories**: 6 (Notes), 8 (Filter/Sort)

**Backend Tasks**:
1. Update validators to enforce 500 char notes limit
2. Update GetItemsQuery to support filters (categoryId, isPurchased)
3. Update GetItemsQuery to support sorting (name, position, createdAt, category)
4. Add database indexes for filter/sort performance
5. Write tests for filtered/sorted queries

**Frontend Tasks**:
1. Update ItemForm to include notes textarea with character counter
2. Create ItemFilters component (category dropdown, status radio, sort dropdown)
3. Update useItems hook to support filters and sorting
4. Display notes icon on ItemCard when notes exist
5. Show notes in tooltip/expand on hover/tap
6. Persist filter/sort preferences in URL query params
7. Write tests for filters and sorting

**Acceptance Criteria**:
- User can add notes up to 500 characters
- Character counter shows remaining characters
- Notes display with icon indicator on item card
- User can filter by category (only show Produce items)
- User can filter by status (show unpurchased only)
- User can sort by name (A-Z, Z-A), date, category
- Filter/sort preferences persist in URL
- "No items found" message when filters return zero results

---

### Iteration 5: Autocomplete (P2 - Enhancement)

**User Stories**: 7 (Quick Add)

**Backend Tasks**:
1. Create GetAutocompleteQuery to fetch unique item names
2. Query items across all user's lists (createdById = currentUserId)
3. Rank results by frequency (count how many times each name appears)
4. Return top 10 suggestions with previous quantity/unit/category
5. Write tests for autocomplete query

**Frontend Tasks**:
1. Create QuickAddInput component with autocomplete dropdown
2. Create useItemAutocomplete hook with debouncing (300ms)
3. Display suggestions ranked by frequency
4. Auto-fill quantity/unit/category when suggestion selected
5. Allow user to override auto-filled values
6. Cache autocomplete results in React Query
7. Write tests for autocomplete logic

**Acceptance Criteria**:
- User types "Mi" and sees "Milk" suggested if previously added
- Selecting suggestion auto-fills quantity, unit, category
- User can override auto-filled values before saving
- Suggestions debounced to avoid excessive API calls
- No suggestions shown if user has no item history
- Autocomplete works in both QuickAddInput and ItemForm

---

## Phase 3: Integration & Polish

### Integration Tasks

1. **Backend-Frontend Integration**:
   - Replace mock data in frontend with real API calls
   - Configure API base URL (environment variable)
   - Handle authentication (JWT token in headers)
   - Test all CRUD operations end-to-end

2. **Permission Integration**:
   - Fetch user's permission for list from backend
   - Conditionally show/hide edit/delete buttons based on permission
   - Disable drag-drop for viewers
   - Test permission enforcement on API (backend returns 403)

3. **Error Handling**:
   - Display validation errors from backend in form
   - Show toast notifications for success/error operations
   - Handle network failures gracefully (retry button)
   - Test offline behavior (show error message)

4. **Performance Optimization**:
   - Add loading skeletons for item list
   - Implement virtual scrolling for 100+ items (react-window)
   - Optimize re-renders (React.memo, useMemo, useCallback)
   - Test with 500 items to verify performance goals met

### Polish Tasks

1. **Accessibility**:
   - Add ARIA labels to all interactive elements
   - Keyboard navigation for drag-drop (arrow keys)
   - Screen reader announcements for item operations
   - Focus management (return focus after modal close)
   - Test with WAVE and axe tools

2. **Mobile Responsiveness**:
   - Test touch gestures for drag-drop
   - Ensure buttons are touch-friendly (44x44px min)
   - Test forms on small screens (inline vs. modal)
   - Test on iOS Safari and Android Chrome

3. **Visual Polish**:
   - Add loading spinners during API calls
   - Add success animations (checkmark for purchased)
   - Add empty state illustrations
   - Add error state illustrations
   - Ensure consistent spacing and typography

4. **Documentation**:
   - Update API_REFERENCE.md with item endpoints
   - Update ARCHITECTURE.md with items feature details
   - Create quickstart.md with code examples
   - Document common issues and solutions

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| **Drag-drop library incompatibility** | High (P2 feature blocked) | Low | Evaluate 3 libraries in research phase, choose most mature |
| **Performance with 500+ items** | High (user experience) | Medium | Implement virtual scrolling (react-window), test early |
| **Permission checks slow down queries** | Medium (API latency) | Low | Cache list permissions, check once per request |
| **Autocomplete query too slow** | Medium (bad UX) | Low | Add database index on CreatedById, limit to top 10 results |
| **SignalR connection failures** | High (real-time broken) | Medium | Implement automatic reconnection, queue failed events, show connection status |
| **Optimistic UI rollback complexity** | Medium (bad UX) | Medium | Use React Query for built-in optimistic updates, comprehensive error handling |
| **Race conditions in concurrent edits** | High (data loss) | Medium | Last-write-wins with user notification, timestamp-based conflict detection |
| **Purchase toggle conflicts** | Medium (confusion) | High | Optimistic UI with instant feedback, rollback on error, broadcast to others |
| **Mobile drag-drop doesn't work** | High (mobile users blocked) | Medium | Test on real devices early, fallback to edit mode for position |
| **SignalR scaling with many items** | Medium (performance) | Low | Configure SignalR for Redis backplane if >1000 concurrent users per list |

---

## Success Criteria Validation

| Success Criterion | Validation Method | Target |
|-------------------|-------------------|--------|
| **SC-001**: Add item < 10 seconds | Manual timing + analytics | ✅ < 10s average |
| **SC-002**: Mark 10 items < 30 seconds | Manual timing during shopping scenario | ✅ < 30s (3s per item) |
| **SC-003**: 50 items load < 1 second | Performance profiling + Lighthouse | ✅ < 1s |
| **SC-004**: 95% operation success rate | API monitoring + error tracking | ✅ > 95% |
| **SC-005**: Drag-drop < 2 seconds | Manual timing + user testing | ✅ < 2s per item |
| **SC-006**: Autocomplete 50% faster | Before/after timing comparison | ✅ 50% improvement |
| **SC-007**: Filter < 5 seconds | Manual timing + user testing | ✅ < 5s |
| **SC-008**: 90% complete first shopping trip | User testing + analytics | ✅ > 90% |
| **SC-009**: 500 items no degradation | Load testing + performance profiling | ✅ No lag |
| **SC-010**: Real-time < 2 seconds | N/A (out of scope, deferred to Feature 007) | ⏸️ Deferred |

---

## Definition of Done

### Backend
- [ ] All commands/queries implemented with MediatR
- [ ] All validators pass FluentValidation tests
- [ ] Repository methods implemented with EF Core
- [ ] SignalR hub extended with item event methods (JoinItemsView, LeaveItemsView)
- [ ] Event broadcasting added to all command handlers (ItemCreated, ItemUpdated, etc.)
- [ ] Unit tests written and passing (90%+ coverage)
- [ ] Integration tests written and passing (80%+ coverage)
- [ ] SignalR integration tests for event broadcasting
- [ ] API endpoints documented in Swagger/OpenAPI
- [ ] Database migrations created and tested (including soft delete fields)
- [ ] Permission checks enforced (viewer vs. editor)

### Frontend
- [ ] All components implemented with TypeScript
- [ ] All hooks implemented with proper error handling
- [ ] SignalR event handlers implemented (useItemEvents hook)
- [ ] Optimistic UI updates with rollback for all operations
- [ ] Conflict notifications displayed for concurrent edits
- [ ] Connection status indicator implemented
- [ ] Component tests written and passing (80%+ coverage)
- [ ] Hook tests written and passing (85%+ coverage)
- [ ] Integration tests with MSW passing
- [ ] SignalR event handling tested (mock hub connection)
- [ ] Accessibility tested (WAVE, axe, keyboard nav)
- [ ] Mobile tested on iOS and Android
- [ ] Loading/error states implemented

### Integration
- [ ] Backend API endpoints called from frontend
- [ ] SignalR connection established and maintained
- [ ] Real-time events broadcast and received correctly
- [ ] Optimistic UI updates synchronize with SignalR events
- [ ] Authentication working (JWT in headers + SignalR token)
- [ ] Permission-based UI working (viewer restrictions)
- [ ] Error messages displayed correctly
- [ ] Success notifications shown
- [ ] Conflict notifications shown when concurrent edits occur
- [ ] Performance goals met (all 10 success criteria including SC-010 real-time < 2s)

### Documentation
- [ ] quickstart.md created with examples
- [ ] data-model.md documented
- [ ] API contracts (JSON schemas) defined
- [ ] ARCHITECTURE.md updated
- [ ] API_REFERENCE.md updated
- [ ] tasks.md generated (via `/speckit.tasks`)

---

**Plan Status**: ✅ Complete - Ready for Phase 0 Research  
**Next Command**: Execute Phase 0 research to resolve key decisions (drag-drop library, position strategy, autocomplete approach)

