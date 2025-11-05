# Tasks: List Items Management

**Input**: Design documents from `/specs/004-list-items-management/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅

**Tests**: TDD approach - tests are written BEFORE implementation per Constitution Principle V (80% coverage target)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Backend**: `ae-infinity-api/src/`
- **Frontend**: `ae-infinity-ui/src/`
- **Backend Tests**: `ae-infinity-api/tests/`
- **Frontend Tests**: `ae-infinity-ui/src/` (co-located with components/hooks)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and dependency installation

- [X] T001 Install @dnd-kit packages in ae-infinity-ui/ (npm install @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities)
- [X] T001a Install @microsoft/signalr in ae-infinity-ui/ (npm install @microsoft/signalr) - Already installed from Feature 003
- [X] T002 [P] Install React Query in ae-infinity-ui/ if not already present (npm install @tanstack/react-query)
- [X] T003 [P] Verify FluentValidation and MediatR packages in ae-infinity-api/src/Application/ - Already present
- [X] T004 Create contracts directory structure ae-infinity-api/src/Application/ListItems/Contracts/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Backend Foundation

- [X] T005 Create ListItem entity with soft delete fields in ae-infinity-api/src/Domain/Entities/ListItem.cs
- [X] T006 Create EF Core configuration with soft delete filter in ae-infinity-api/src/Infrastructure/Persistence/Configurations/ListItemConfiguration.cs
- [X] T007 Create database migration for ListItems table with indexes (include IsDeleted, DeletedAt, DeletedById)
- [X] T007a [P] VERIFY ShoppingListHub exists from Feature 003 in ae-infinity-api/src/AeInfinity.Api/Hubs/ShoppingListHub.cs
- [X] T007b Extend ShoppingListHub with JoinItemsView/LeaveItemsView methods - NOT NEEDED (reuse existing list groups)
- [X] T007c [P] VERIFY SignalR configured in Program.cs from Feature 003
- [X] T008 [P] Create IListItemRepository interface in ae-infinity-api/src/Application/Common/Interfaces/IListItemRepository.cs
- [X] T009 Implement ListItemRepository in ae-infinity-api/src/Infrastructure/Persistence/Repositories/ListItemRepository.cs
- [X] T010 [P] Create ItemResponse DTO in ae-infinity-api/src/Application/ListItems/Contracts/ItemResponse.cs - Already exists as ListItemDto
- [X] T011 [P] Create ItemsListResponse DTO in ae-infinity-api/src/Application/ListItems/Contracts/ItemsListResponse.cs
- [X] T012 [P] Setup AutoMapper profiles for ListItem entity in ae-infinity-api/src/Application/Common/Mappings/ListItemMappingProfile.cs

### Frontend Foundation

- [X] T013 [P] Define ListItem TypeScript type in ae-infinity-ui/src/types/index.ts - Already exists as ShoppingItem
- [X] T014 [P] Define request/response TypeScript types in ae-infinity-ui/src/types/index.ts - Already exists
- [X] T014a [P] VERIFY signalrService.ts exists from Feature 003 in ae-infinity-ui/src/services/signalrService.ts
- [X] T014b [P] VERIFY useSignalR hook exists from Feature 003 in ae-infinity-ui/src/hooks/useSignalR.ts
- [X] T014c Extend signalr.ts with item event type definitions in ae-infinity-ui/src/types/signalr.ts - Already exists
- [ ] T014d Create useItemEvents hook for item-specific SignalR handlers in ae-infinity-ui/src/hooks/useItemEvents.ts
- [X] T015 Update itemsService.ts with base API methods in ae-infinity-ui/src/services/itemsService.ts - Already exists, added autocomplete
- [X] T016 [P] Create ConfirmDialog component in ae-infinity-ui/src/components/common/ConfirmDialog.tsx
- [X] T016a Create ConflictNotification component in ae-infinity-ui/src/components/common/ConflictNotification.tsx

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Add Item to Shopping List (Priority: P1) 🎯 MVP

**Goal**: Enable users to add new items to a shopping list with name, quantity, unit, category, and notes

**Independent Test**: Open a list, click "Add Item", enter "Milk", save, and verify it appears in the list with quantity 1

### Tests for User Story 1 (TDD - Write FIRST)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

#### Backend Tests
- [ ] T017 [P] [US1] Unit test for CreateItemCommand validation in ae-infinity-api/tests/Application.Tests/ListItems/Commands/CreateItemCommandValidatorTests.cs
- [ ] T018 [P] [US1] Unit test for CreateItemCommandHandler success case in ae-infinity-api/tests/Application.Tests/ListItems/Commands/CreateItemCommandHandlerTests.cs
- [ ] T019 [P] [US1] Unit test for CreateItemCommandHandler permission check in ae-infinity-api/tests/Application.Tests/ListItems/Commands/CreateItemCommandHandlerTests.cs
- [ ] T020 [P] [US1] Integration test for POST /lists/{listId}/items in ae-infinity-api/tests/API.Tests/Controllers/ListItemsControllerTests.cs

#### Frontend Tests
- [ ] T021 [P] [US1] Component test for ItemForm add mode in ae-infinity-ui/src/components/items/__tests__/ItemForm.test.tsx
- [ ] T022 [P] [US1] Hook test for useItems createItem in ae-infinity-ui/src/hooks/__tests__/useItems.test.ts

### Implementation for User Story 1

#### Backend Implementation
- [X] T023 [US1] Create CreateItemRequest DTO in ae-infinity-api/src/Application/ListItems/Contracts/CreateItemRequest.cs
- [X] T024 [US1] Create CreateItemRequestValidator with FluentValidation rules in ae-infinity-api/src/Application/ListItems/Commands/CreateItemValidator.cs
- [X] T025 [US1] Create CreateItemCommand in ae-infinity-api/src/Application/ListItems/Commands/CreateItemCommand.cs
- [X] T026 [US1] Implement CreateItemCommandHandler with permission checks in ae-infinity-api/src/Application/ListItems/Commands/CreateItemCommandHandler.cs
- [X] T027 [US1] Add POST /lists/{listId}/items endpoint in ae-infinity-api/src/API/Controllers/ListItemsController.cs
- [ ] T028 [US1] Run tests to verify all US1 backend tests pass

#### Frontend Implementation
- [X] T029 [P] [US1] Create ItemForm component for add mode in ae-infinity-ui/src/components/items/ItemForm.tsx
- [X] T030 [P] [US1] Create useItems hook with createItem mutation and optimistic updates in ae-infinity-ui/src/hooks/useItems.ts - Used existing useListItems hook
- [X] T031 [US1] Wire ItemForm to useItems hook in ae-infinity-ui/src/pages/lists/ListDetail.tsx
- [X] T032 [US1] Add form validation errors display in ItemForm component
- [X] T033 [US1] Add loading states and success/error toasts for item creation
- [ ] T034 [US1] Run tests to verify all US1 frontend tests pass

#### SignalR Integration for User Story 1
- [X] T034a [P] [US1] Add ItemCreated event broadcasting in CreateItemCommandHandler after successful save
- [X] T034b [US1] Add ItemCreated event handler in useItemEvents hook: prepend new item to list - Already implemented in useListRealtime
- [X] T034c [US1] Implement optimistic UI: add temporary item immediately, replace with real data on success - Already in useListItems
- [X] T034d [US1] Add rollback logic: remove optimistic item on API error - Already in useListItems
- [ ] T034e [US1] Test real-time item creation: verify other collaborators see new item within 2 seconds

**Checkpoint**: At this point, User Story 1 should be fully functional with real-time broadcasting. Users can add items with all fields, and all collaborators see updates instantly.

---

## Phase 4: User Story 2 - Mark Items as Purchased (Priority: P1)

**Goal**: Enable users to check off items as purchased, with visual distinction and summary count

**Independent Test**: Add 3 items, mark 2 as purchased, verify strikethrough styling and "2 of 3 items purchased" summary

### Tests for User Story 2 (TDD - Write FIRST)

#### Backend Tests
- [ ] T035 [P] [US2] Unit test for TogglePurchasedCommand in ae-infinity-api/tests/Application.Tests/ListItems/Commands/TogglePurchasedCommandHandlerTests.cs
- [ ] T036 [P] [US2] Integration test for PATCH /lists/{listId}/items/{itemId}/purchased in ae-infinity-api/tests/API.Tests/Controllers/ListItemsControllerTests.cs
- [ ] T037 [P] [US2] Unit test for GetItemsQuery with metadata calculation in ae-infinity-api/tests/Application.Tests/ListItems/Queries/GetItemsQueryHandlerTests.cs

#### Frontend Tests
- [ ] T038 [P] [US2] Component test for ItemPurchaseCheckbox in ae-infinity-ui/src/components/items/__tests__/ItemPurchaseCheckbox.test.tsx
- [ ] T039 [P] [US2] Component test for ItemCard with purchased styling in ae-infinity-ui/src/components/items/__tests__/ItemCard.test.tsx

### Implementation for User Story 2

#### Backend Implementation
- [ ] T040 [US2] Create TogglePurchasedRequest DTO in ae-infinity-api/src/Application/ListItems/Contracts/TogglePurchasedRequest.cs
- [ ] T041 [US2] Create TogglePurchasedCommand in ae-infinity-api/src/Application/ListItems/Commands/TogglePurchasedCommand.cs
- [ ] T042 [US2] Implement TogglePurchasedCommandHandler with purchasedAt/purchasedBy logic in ae-infinity-api/src/Application/ListItems/Commands/TogglePurchasedCommandHandler.cs
- [ ] T043 [US2] Create GetItemsQuery in ae-infinity-api/src/Application/ListItems/Queries/GetItemsQuery.cs
- [ ] T044 [US2] Implement GetItemsQueryHandler with metadata calculation in ae-infinity-api/src/Application/ListItems/Queries/GetItemsQueryHandler.cs
- [ ] T045 [US2] Add PATCH /lists/{listId}/items/{itemId}/purchased endpoint in ae-infinity-api/src/API/Controllers/ListItemsController.cs
- [ ] T046 [US2] Add GET /lists/{listId}/items endpoint in ae-infinity-api/src/API/Controllers/ListItemsController.cs
- [ ] T047 [US2] Run tests to verify all US2 backend tests pass

#### Frontend Implementation
- [ ] T048 [P] [US2] Create ItemPurchaseCheckbox component with optimistic UI in ae-infinity-ui/src/components/items/ItemPurchaseCheckbox.tsx
- [ ] T049 [P] [US2] Create ItemCard component with purchased styling in ae-infinity-ui/src/components/items/ItemCard.tsx
- [ ] T050 [US2] Add togglePurchased mutation with optimistic updates in ae-infinity-ui/src/hooks/useItems.ts
- [ ] T051 [US2] Add items metadata summary display (X of Y purchased) in ListDetail header
- [ ] T052 [US2] Add celebration message for all items purchased in ae-infinity-ui/src/pages/lists/ListDetail.tsx
- [ ] T053 [US2] Run tests to verify all US2 frontend tests pass

#### SignalR Integration for User Story 2
- [ ] T053a [P] [US2] Add ItemPurchased event broadcasting in TogglePurchasedCommandHandler after status change
- [ ] T053b [US2] Add ItemPurchased event handler in useItemEvents hook: update item's isPurchased state
- [ ] T053c [US2] Implement optimistic checkbox toggle: instant visual feedback, rollback on error
- [ ] T053d [US2] Update metadata summary when ItemPurchased event received from other users
- [ ] T053e [US2] Test purchase toggle conflicts: two users toggle same item simultaneously, verify last-write-wins

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently with real-time sync. Users can add items and mark them as purchased, all collaborators see updates instantly.

---

## Phase 5: User Story 3 - Edit Item Details (Priority: P1)

**Goal**: Enable owners and editors to update item details (name, quantity, unit, category, notes)

**Independent Test**: Add an item "Milk (2 gallons)", click Edit, change quantity to 3, save, verify "Milk (3 gallons)" displays

### Tests for User Story 3 (TDD - Write FIRST)

#### Backend Tests
- [ ] T054 [P] [US3] Unit test for UpdateItemCommand validation in ae-infinity-api/tests/Application.Tests/ListItems/Commands/UpdateItemCommandValidatorTests.cs
- [ ] T055 [P] [US3] Unit test for UpdateItemCommandHandler in ae-infinity-api/tests/Application.Tests/ListItems/Commands/UpdateItemCommandHandlerTests.cs
- [ ] T056 [P] [US3] Integration test for PUT /lists/{listId}/items/{itemId} in ae-infinity-api/tests/API.Tests/Controllers/ListItemsControllerTests.cs

#### Frontend Tests
- [ ] T057 [P] [US3] Component test for ItemForm edit mode in ae-infinity-ui/src/components/items/__tests__/ItemForm.test.tsx
- [ ] T058 [P] [US3] Hook test for useItems updateItem in ae-infinity-ui/src/hooks/__tests__/useItems.test.ts

### Implementation for User Story 3

#### Backend Implementation
- [ ] T059 [US3] Create UpdateItemRequest DTO in ae-infinity-api/src/Application/ListItems/Contracts/UpdateItemRequest.cs
- [ ] T060 [US3] Create UpdateItemCommand in ae-infinity-api/src/Application/ListItems/Commands/UpdateItemCommand.cs
- [ ] T061 [US3] Implement UpdateItemCommandHandler with permission checks in ae-infinity-api/src/Application/ListItems/Commands/UpdateItemCommandHandler.cs
- [ ] T062 [US3] Add PUT /lists/{listId}/items/{itemId} endpoint in ae-infinity-api/src/API/Controllers/ListItemsController.cs
- [ ] T063 [US3] Run tests to verify all US3 backend tests pass

#### Frontend Implementation
- [ ] T064 [US3] Update ItemForm component to support edit mode with pre-filled values in ae-infinity-ui/src/components/items/ItemForm.tsx
- [ ] T065 [US3] Add updateItem mutation with optimistic updates in useItems hook in ae-infinity-ui/src/hooks/useItems.ts
- [ ] T066 [US3] Add Edit button to ItemCard component (permission-based) in ae-infinity-ui/src/components/items/ItemCard.tsx
- [ ] T067 [US3] Wire edit flow to open ItemForm modal with existing item data
- [ ] T068 [US3] Run tests to verify all US3 frontend tests pass

#### SignalR Integration for User Story 3
- [ ] T068a [P] [US3] Add ItemUpdated event broadcasting in UpdateItemCommandHandler after successful save
- [ ] T068b [US3] Add ItemUpdated event handler in useItemEvents hook: update item in list with new data
- [ ] T068c [US3] Add conflict detection: compare UpdatedAt timestamp from SignalR event with local state
- [ ] T068d [US3] Show ConflictNotification toast when concurrent edit detected: "Another user edited this item. Refresh to see changes."
- [ ] T068e [US3] Test concurrent edit scenario: two users edit same item simultaneously, verify last-write-wins with notification

**Checkpoint**: At this point, User Stories 1, 2, AND 3 should all work independently with real-time sync and conflict detection. Users can add, mark as purchased, and edit items.

---

## Phase 6: User Story 4 - Delete Items (Priority: P1)

**Goal**: Enable owners and editors to delete items with confirmation dialog

**Independent Test**: Add an item, click Delete, confirm in dialog, verify item is removed from list

### Tests for User Story 4 (TDD - Write FIRST)

#### Backend Tests
- [ ] T069 [P] [US4] Unit test for DeleteItemCommand in ae-infinity-api/tests/Application.Tests/ListItems/Commands/DeleteItemCommandHandlerTests.cs
- [ ] T070 [P] [US4] Integration test for DELETE /lists/{listId}/items/{itemId} in ae-infinity-api/tests/API.Tests/Controllers/ListItemsControllerTests.cs
- [ ] T071 [P] [US4] Test metadata update when item deleted in ae-infinity-api/tests/Application.Tests/ListItems/Commands/DeleteItemCommandHandlerTests.cs

#### Frontend Tests
- [ ] T072 [P] [US4] Component test for ItemCard delete with confirmation in ae-infinity-ui/src/components/items/__tests__/ItemCard.test.tsx
- [ ] T073 [P] [US4] Component test for ConfirmDialog in ae-infinity-ui/src/components/common/__tests__/ConfirmDialog.test.tsx

### Implementation for User Story 4

#### Backend Implementation
- [ ] T074 [US4] Create DeleteItemCommand in ae-infinity-api/src/Application/ListItems/Commands/DeleteItemCommand.cs
- [ ] T075 [US4] Implement DeleteItemCommandHandler with permission checks in ae-infinity-api/src/Application/ListItems/Commands/DeleteItemCommandHandler.cs
- [ ] T076 [US4] Add DELETE /lists/{listId}/items/{itemId} endpoint in ae-infinity-api/src/API/Controllers/ListItemsController.cs
- [ ] T077 [US4] Run tests to verify all US4 backend tests pass

#### Frontend Implementation
- [ ] T078 [US4] Add deleteItem mutation with optimistic removal in useItems hook in ae-infinity-ui/src/hooks/useItems.ts
- [ ] T079 [US4] Add Delete button to ItemCard with ConfirmDialog integration in ae-infinity-ui/src/components/items/ItemCard.tsx
- [ ] T080 [US4] Wire delete confirmation to deleteItem mutation
- [ ] T081 [US4] Update metadata display after item deletion
- [ ] T082 [US4] Run tests to verify all US4 frontend tests pass

#### SignalR Integration for User Story 4
- [ ] T082a [P] [US4] Add ItemDeleted event broadcasting in DeleteItemCommandHandler after soft delete
- [ ] T082b [US4] Add ItemDeleted event handler in useItemEvents hook: remove item from list
- [ ] T082c [US4] Implement optimistic UI: remove item immediately, restore on error
- [ ] T082d [US4] Update metadata summary when ItemDeleted event received from other users
- [ ] T082e [US4] Test real-time deletion: verify other collaborators see item removed within 2 seconds

**Checkpoint**: At this point, all P1 user stories (1-4) are complete with real-time sync. Users have full CRUD operations on items with instant collaboration.

---

## Phase 7: User Story 5 - Reorder Items by Drag-and-Drop (Priority: P2)

**Goal**: Enable owners and editors to reorder items via drag-and-drop, persisting positions

**Independent Test**: Add 5 items, drag item 3 to position 1, refresh page, verify order persists

### Tests for User Story 5 (TDD - Write FIRST)

#### Backend Tests
- [ ] T083 [P] [US5] Unit test for ReorderItemsCommand validation in ae-infinity-api/tests/Application.Tests/ListItems/Commands/ReorderItemsCommandValidatorTests.cs
- [ ] T084 [P] [US5] Unit test for ReorderItemsCommandHandler in ae-infinity-api/tests/Application.Tests/ListItems/Commands/ReorderItemsCommandHandlerTests.cs
- [ ] T085 [P] [US5] Integration test for PATCH /lists/{listId}/items/reorder in ae-infinity-api/tests/API.Tests/Controllers/ListItemsControllerTests.cs

#### Frontend Tests
- [ ] T086 [P] [US5] Hook test for useItemDragDrop in ae-infinity-ui/src/hooks/__tests__/useItemDragDrop.test.ts
- [ ] T087 [P] [US5] Component test for ItemList with drag-drop in ae-infinity-ui/src/components/items/__tests__/ItemList.test.tsx

### Implementation for User Story 5

#### Backend Implementation
- [ ] T088 [US5] Create ReorderItemsRequest DTO in ae-infinity-api/src/Application/ListItems/Contracts/ReorderItemsRequest.cs
- [ ] T089 [US5] Create ReorderItemsRequestValidator with unique positions check in ae-infinity-api/src/Application/ListItems/Commands/ReorderItemsValidator.cs
- [ ] T090 [US5] Create ReorderItemsCommand in ae-infinity-api/src/Application/ListItems/Commands/ReorderItemsCommand.cs
- [ ] T091 [US5] Implement ReorderItemsCommandHandler with transaction for batch update in ae-infinity-api/src/Application/ListItems/Commands/ReorderItemsCommandHandler.cs
- [ ] T092 [US5] Add PATCH /lists/{listId}/items/reorder endpoint in ae-infinity-api/src/API/Controllers/ListItemsController.cs
- [ ] T093 [US5] Run tests to verify all US5 backend tests pass

#### Frontend Implementation
- [ ] T094 [US5] Create useItemDragDrop hook with @dnd-kit integration in ae-infinity-ui/src/hooks/useItemDragDrop.ts
- [ ] T095 [US5] Create ItemList component with DndContext and SortableContext in ae-infinity-ui/src/components/items/ItemList.tsx
- [ ] T096 [US5] Update ItemCard to be sortable with drag handle in ae-infinity-ui/src/components/items/ItemCard.tsx
- [ ] T097 [US5] Add reorderItems mutation with optimistic updates in useItems hook in ae-infinity-ui/src/hooks/useItems.ts
- [ ] T098 [US5] Wire drag-drop sensors for touch support (mobile) in ae-infinity-ui/src/hooks/useItemDragDrop.ts
- [ ] T099 [US5] Add visual feedback during drag (preview, drop zone) in ItemList component
- [ ] T100 [US5] Disable drag for viewers (permission check) in ItemList component
- [ ] T101 [US5] Run tests to verify all US5 frontend tests pass

#### SignalR Integration for User Story 5
- [ ] T101a [P] [US5] Add ItemsReordered event broadcasting in ReorderItemsCommandHandler after batch update
- [ ] T101b [US5] Add ItemsReordered event handler in useItemEvents hook: update all item positions in list
- [ ] T101c [US5] Implement optimistic UI: reorder items immediately on drag, rollback on error
- [ ] T101d [US5] Show notification when another user reorders: "List was reordered by {username}"
- [ ] T101e [US5] Test concurrent reorder: two users drag items simultaneously, verify last-write-wins

**Checkpoint**: At this point, User Stories 1-5 are complete with real-time sync. Users can reorder items via drag-and-drop with instant collaboration.

---

## Phase 8: User Story 6 - Add Notes and Additional Details (Priority: P2)

**Goal**: Enable users to add detailed notes (max 500 chars) to items with attribution

**Independent Test**: Add item with notes "Organic only, brand: Horizon", verify notes display with icon, tap/hover to see full text

### Tests for User Story 6 (TDD - Write FIRST)

> **NOTE**: Notes field is already in CreateItemRequest/UpdateItemRequest from US1/US3, so no new backend tests needed. Frontend tests focus on UI/UX.

#### Frontend Tests
- [ ] T102 [P] [US6] Component test for ItemCard notes display in ae-infinity-ui/src/components/items/__tests__/ItemCard.test.tsx
- [ ] T103 [P] [US6] Component test for ItemForm notes textarea with character counter in ae-infinity-ui/src/components/items/__tests__/ItemForm.test.tsx

### Implementation for User Story 6

#### Backend Implementation
> **NOTE**: Backend implementation already complete in US1 (CreateItemCommand) and US3 (UpdateItemCommand). No new backend tasks.

#### Frontend Implementation
- [ ] T104 [US6] Add notes textarea with 500 character counter to ItemForm in ae-infinity-ui/src/components/items/ItemForm.tsx
- [ ] T105 [US6] Add notes icon indicator to ItemCard when notes exist in ae-infinity-ui/src/components/items/ItemCard.tsx
- [ ] T106 [US6] Implement notes tooltip on hover (desktop) in ItemCard component
- [ ] T107 [US6] Implement notes expand on tap (mobile) in ItemCard component
- [ ] T108 [US6] Add notes attribution (createdBy) display in notes tooltip/expanded view
- [ ] T109 [US6] Run tests to verify all US6 frontend tests pass

**Checkpoint**: At this point, User Stories 1-6 are complete. Users can add notes to items.

---

## Phase 9: User Story 7 - Quick Add from Previous Lists (Autocomplete) (Priority: P2)

**Goal**: Provide autocomplete suggestions based on user's previous items, ranked by frequency

**Independent Test**: Add "Milk" to one list, create new list, type "Mi" in add field, see "Milk" suggested with quantity 2

### Tests for User Story 7 (TDD - Write FIRST)

#### Backend Tests
- [ ] T110 [P] [US7] Unit test for GetAutocompleteQuery in ae-infinity-api/tests/Application.Tests/ListItems/Queries/GetAutocompleteQueryHandlerTests.cs
- [ ] T111 [P] [US7] Integration test for GET /lists/items/autocomplete in ae-infinity-api/tests/API.Tests/Controllers/ListItemsControllerTests.cs
- [ ] T112 [P] [US7] Test autocomplete ranking by frequency in GetAutocompleteQueryHandlerTests.cs

#### Frontend Tests
- [ ] T113 [P] [US7] Hook test for useItemAutocomplete with debouncing in ae-infinity-ui/src/hooks/__tests__/useItemAutocomplete.test.ts
- [ ] T114 [P] [US7] Component test for QuickAddInput with autocomplete dropdown in ae-infinity-ui/src/components/items/__tests__/QuickAddInput.test.tsx

### Implementation for User Story 7

#### Backend Implementation
- [ ] T115 [US7] Create AutocompleteResponse DTO in ae-infinity-api/src/Application/ListItems/Contracts/AutocompleteResponse.cs
- [ ] T116 [US7] Create GetAutocompleteQuery in ae-infinity-api/src/Application/ListItems/Queries/GetAutocompleteQuery.cs
- [ ] T117 [US7] Implement GetAutocompleteQueryHandler with frequency ranking in ae-infinity-api/src/Application/ListItems/Queries/GetAutocompleteQueryHandler.cs
- [ ] T118 [US7] Add database index on CreatedById + Name in ListItems migration
- [ ] T119 [US7] Add GET /lists/items/autocomplete endpoint in ae-infinity-api/src/API/Controllers/ListItemsController.cs
- [ ] T120 [US7] Run tests to verify all US7 backend tests pass

#### Frontend Implementation
- [ ] T121 [US7] Create useItemAutocomplete hook with 300ms debouncing in ae-infinity-ui/src/hooks/useItemAutocomplete.ts
- [ ] T122 [US7] Create QuickAddInput component with autocomplete dropdown in ae-infinity-ui/src/components/items/QuickAddInput.tsx
- [ ] T123 [US7] Update itemsService with getAutocomplete method in ae-infinity-ui/src/services/itemsService.ts
- [ ] T124 [US7] Implement suggestion selection to auto-fill ItemForm fields
- [ ] T125 [US7] Add visual ranking indicator (frequency badge) to suggestions
- [ ] T126 [US7] Add empty state for no suggestions (first-time users)
- [ ] T127 [US7] Run tests to verify all US7 frontend tests pass

**Checkpoint**: At this point, User Stories 1-7 are complete. Users have autocomplete for faster item entry.

---

## Phase 10: User Story 8 - Filter and Sort Items (Priority: P3)

**Goal**: Enable filtering by category/purchased status and sorting by name/position/date

**Independent Test**: Add 20 items across 3 categories, filter by "Produce", verify only produce items display

### Tests for User Story 8 (TDD - Write FIRST)

#### Backend Tests
- [ ] T128 [P] [US8] Unit test for GetItemsQuery with categoryId filter in ae-infinity-api/tests/Application.Tests/ListItems/Queries/GetItemsQueryHandlerTests.cs
- [ ] T129 [P] [US8] Unit test for GetItemsQuery with purchased filter in ae-infinity-api/tests/Application.Tests/ListItems/Queries/GetItemsQueryHandlerTests.cs
- [ ] T130 [P] [US8] Unit test for GetItemsQuery with sortBy options in ae-infinity-api/tests/Application.Tests/ListItems/Queries/GetItemsQueryHandlerTests.cs

#### Frontend Tests
- [ ] T131 [P] [US8] Component test for ItemFilters in ae-infinity-ui/src/components/items/__tests__/ItemFilters.test.tsx
- [ ] T132 [P] [US8] Integration test for filter/sort with URL persistence in ae-infinity-ui/src/pages/lists/__tests__/ListDetail.test.tsx

### Implementation for User Story 8

#### Backend Implementation
> **NOTE**: Backend filtering/sorting already implemented in GetItemsQuery (US2). Just need to verify query parameters work.

- [ ] T133 [US8] Update GetItemsQuery to accept categoryId, purchased, sortBy, sortOrder parameters (already in US2, verify)
- [ ] T134 [US8] Add database indexes for ListId + CategoryId and ListId + IsPurchased in migration
- [ ] T135 [US8] Run tests to verify all US8 backend tests pass

#### Frontend Implementation
- [ ] T136 [US8] Create ItemFilters component with category/status/sort dropdowns in ae-infinity-ui/src/components/items/ItemFilters.tsx
- [ ] T137 [US8] Update useItems hook to accept filter/sort parameters in ae-infinity-ui/src/hooks/useItems.ts
- [ ] T138 [US8] Add URL query parameter management (useSearchParams) in ListDetail page
- [ ] T139 [US8] Wire ItemFilters to update URL params and refetch items
- [ ] T140 [US8] Add "No items found" message when filters return empty in ItemList component
- [ ] T141 [US8] Add "Clear filters" button when filters active in ItemFilters component
- [ ] T142 [US8] Persist filter preferences in URL for shareable links
- [ ] T143 [US8] Run tests to verify all US8 frontend tests pass

**Checkpoint**: All user stories (1-8) are now complete. Users have full item management capabilities.

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

### Performance & Optimization
- [ ] T144 [P] Add virtual scrolling for lists with 100+ items using react-window in ae-infinity-ui/src/components/items/ItemList.tsx
- [ ] T145 [P] Add loading skeletons for item list in ae-infinity-ui/src/components/items/ItemListSkeleton.tsx
- [ ] T146 [P] Optimize ItemCard re-renders with React.memo in ae-infinity-ui/src/components/items/ItemCard.tsx
- [ ] T147 [P] Add database query performance logging in ae-infinity-api/src/Application/ListItems/

### Accessibility & Mobile
- [ ] T148 [P] Add ARIA labels to all interactive elements in ItemCard, ItemForm, ItemFilters
- [ ] T149 [P] Test keyboard navigation for drag-drop (arrow keys) in ItemList
- [ ] T150 [P] Test screen reader announcements for item operations in ItemCard
- [ ] T151 [P] Verify touch targets are 44x44px minimum on mobile in ItemCard, ItemForm
- [ ] T152 Test on iOS Safari and Android Chrome for drag-drop gestures

### Error Handling & Edge Cases
- [ ] T153 [P] Add network error retry mechanism in ae-infinity-ui/src/hooks/useItems.ts
- [ ] T154 [P] Add optimistic UI rollback on errors in useItems togglePurchased
- [ ] T155 [P] Handle 403 Forbidden errors (viewer permissions) in itemsService.ts
- [ ] T156 Add stale data checks (edit conflicts) in UpdateItemCommandHandler

### SignalR Real-time Integration & Testing
- [ ] T156a [P] Add connection status indicator in header: "Connected", "Disconnected", "Reconnecting" badge
- [ ] T156b [P] Test SignalR connection establishment and JWT authentication on list page load
- [ ] T156c [P] Test automatic reconnection after network disruption (disconnect WiFi, reconnect, verify events)
- [ ] T156d [P] Integration test: create/update/delete/purchase/reorder item in browser A, verify received in browser B within 2s
- [ ] T156e [P] Test optimistic UI rollback: disconnect network, toggle purchase, verify rollback and error toast
- [ ] T156f Test concurrent edit conflict notification: two users edit same item simultaneously, verify notification
- [ ] T156g Test concurrent purchase toggle: two users toggle same item, verify last-write-wins with sync
- [ ] T156h Test concurrent reorder: two users drag items simultaneously, verify last-write-wins with notification
- [ ] T156i Test SignalR performance with 50+ items: verify all events broadcast within 2-second latency target
- [ ] T156j [P] Add SignalR integration tests in backend: verify events broadcast to correct groups

### Documentation
- [ ] T157 [P] Update API_REFERENCE.md with all item endpoints in /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-context/API_REFERENCE.md
- [ ] T158 [P] Update ARCHITECTURE.md with items feature details in /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-context/ARCHITECTURE.md
- [ ] T159 [P] Validate quickstart.md examples work end-to-end in /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-context/specs/004-list-items-management/quickstart.md
- [ ] T160 [P] Update FEATURES.md status for Feature 004 to "Implemented" in /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-context/FEATURES.md

### Final Validation
- [ ] T161 Run full test suite (backend + frontend) and verify 80%+ coverage
- [ ] T162 Test all 39 acceptance scenarios from spec.md manually
- [ ] T163 Test all 11 edge cases from spec.md
- [ ] T164 Verify all 10 success criteria from spec.md are met
- [ ] T165 Performance testing: 500 items per list without degradation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-10)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Phase 11)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational - Depends on US1 for items to exist
- **User Story 3 (P1)**: Can start after Foundational - Depends on US1 for items to exist
- **User Story 4 (P1)**: Can start after Foundational - Depends on US1 for items to exist
- **User Story 5 (P2)**: Can start after Foundational - Depends on US1, US2 for item display
- **User Story 6 (P2)**: Can start after US1, US3 - Extends create/edit forms
- **User Story 7 (P2)**: Can start after Foundational - Independent (autocomplete from history)
- **User Story 8 (P3)**: Can start after US2 - Extends GetItemsQuery with filters

### Within Each User Story

- Tests (TDD) MUST be written and FAIL before implementation
- Backend: DTOs → Validators → Commands/Queries → Handlers → Endpoints → Tests Pass
- Frontend: Types → Components → Hooks → Integration → Tests Pass
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models/DTOs within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (TDD - these should FAIL initially):
Task T017: "Unit test for CreateItemCommand validation"
Task T018: "Unit test for CreateItemCommandHandler success case"
Task T019: "Unit test for CreateItemCommandHandler permission check"
Task T020: "Integration test for POST /lists/{listId}/items"
Task T021: "Component test for ItemForm add mode"
Task T022: "Hook test for useItems createItem"

# After tests are written and failing, implement in parallel:
Task T023: "Create CreateItemRequest DTO"
Task T024: "Create CreateItemRequestValidator"
Task T029: "Create ItemForm component"
Task T030: "Create useItems hook"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T004)
2. Complete Phase 2: Foundational (T005-T016) - CRITICAL
3. Complete Phase 3: User Story 1 (T017-T034)
4. **STOP and VALIDATE**: Test User Story 1 independently (add items with all fields)
5. Deploy/demo if ready

**Estimated Time**: 8-12 hours

### P1 Stories (Critical Features)

1. Complete Setup + Foundational → Foundation ready (4-6 hours)
2. Add User Story 1 (Add Items) → Test independently → Deploy (4-6 hours)
3. Add User Story 2 (Mark Purchased) → Test independently → Deploy (3-4 hours)
4. Add User Story 3 (Edit Items) → Test independently → Deploy (2-3 hours)
5. Add User Story 4 (Delete Items) → Test independently → Deploy (2 hours)

**Total P1 Time**: 15-21 hours
**Deliverable**: Full CRUD operations on items

### P2 Stories (Important Features)

6. Add User Story 5 (Drag-Drop Reorder) → Test independently → Deploy (4-5 hours)
7. Add User Story 6 (Notes) → Test independently → Deploy (2 hours)
8. Add User Story 7 (Autocomplete) → Test independently → Deploy (3-4 hours)

**Total P1+P2 Time**: 24-32 hours
**Deliverable**: Full item management with efficiency features

### Full Feature Set

9. Add User Story 8 (Filter/Sort) → Test independently → Deploy (2-3 hours)
10. Complete Phase 11: Polish (4-6 hours)

**Total Time**: 30-41 hours (backend + frontend + tests)

### Parallel Team Strategy

With 2 developers:

1. Team completes Setup + Foundational together (4-6 hours)
2. Once Foundational is done:
   - Developer A: User Stories 1, 3, 5, 7 (Add, Edit, Reorder, Autocomplete)
   - Developer B: User Stories 2, 4, 6, 8 (Purchase, Delete, Notes, Filters)
3. Stories complete and integrate independently

**Parallel Time**: 20-25 hours

---

## Notes

- [P] tasks = different files, no dependencies, can run in parallel
- [US#] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- TDD approach: Write tests FIRST, ensure they FAIL, then implement
- Commit after each task or logical group (e.g., all DTOs, all tests)
- Stop at any checkpoint to validate story independently
- 80% test coverage target enforced per Constitution
- Real-time collaboration via SignalR is INCLUDED (per Constitution Principle III)
- MVP = User Story 1 only with SignalR (10-14 hours)
- Full P1 features = User Stories 1-4 with real-time sync (22-30 hours)

**Total Tasks**: 209 tasks (includes 44 SignalR/real-time tasks)
**Total Estimated Time**: 40-55 hours (single developer, sequential)  
**Parallel Time**: 28-38 hours (2 developers, parallel user stories)

