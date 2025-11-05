# Feature Specification: List Items Management

**Feature Branch**: `004-list-items-management`  
**Created**: November 5, 2025  
**Status**: Draft  
**Input**: User description: "004 - List Items Management"

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add Item to Shopping List (Priority: P1)

A user viewing a shopping list clicks "Add Item", enters the item name (required) and optionally quantity, unit, category, and notes, then saves the item. The new item appears at the bottom of the list and can be immediately marked as purchased or edited.

**Why this priority**: Adding items is the core functionality of a shopping list application. Without the ability to add items, lists are empty and provide no value. This is the first action users take after creating a list.

**Independent Test**: Can be fully tested by opening a list, adding an item with just a name, and verifying it appears in the list. Delivers immediate value as users can now build their shopping list.

**Acceptance Scenarios**:

1. **Given** a user viewing an empty shopping list, **When** they click "Add Item", **Then** they see a form with fields for name (required), quantity, unit, category, and notes
2. **Given** a user on the add item form, **When** they enter name "Milk" and click "Save", **Then** the item is added to the list with quantity 1 (default)
3. **Given** a user on the add item form, **When** they enter name "Bananas", quantity "6", unit "pieces", and click "Save", **Then** the item is added with all specified details
4. **Given** a user on the add item form, **When** they click "Save" without entering a name, **Then** they see an error message "Item name is required" and the item is not added
5. **Given** a user adding an item, **When** they enter a name longer than 100 characters, **Then** they see an error message "Item name must be 100 characters or less"
6. **Given** a newly added item, **When** it appears in the list, **Then** it shows the name, quantity + unit, category icon (if assigned), and unchecked purchase status
7. **Given** a user with viewer-only permission, **When** they try to add an item, **Then** the "Add Item" button is disabled or hidden (insufficient permissions)

---

### User Story 2 - Mark Items as Purchased (Priority: P1)

A user shopping with their list can check off items as they purchase them. Checked items remain visible but are visually distinguished (e.g., strikethrough, moved to bottom, or grayed out). The list shows a count of purchased vs total items.

**Why this priority**: Tracking purchase status is essential for using a shopping list in-store. Users need to know what they've already purchased and what remains. This is core functionality that makes the app useful during shopping.

**Independent Test**: Can be fully tested by adding 3 items, marking 2 as purchased, and verifying they appear checked with visual distinction. Delivers value by helping users track shopping progress.

**Acceptance Scenarios**:

1. **Given** a user viewing a list with 5 unpurchased items, **When** they click the checkbox next to "Milk", **Then** the item is marked as purchased and shows with strikethrough text
2. **Given** a user with a purchased item, **When** they click the checkbox again, **Then** the item is marked as unpurchased and the strikethrough is removed
3. **Given** a list with 8 items where 3 are purchased, **When** the user views the list, **Then** they see "3 of 8 items purchased" at the top
4. **Given** a user marks an item as purchased, **When** the status is saved, **Then** the purchasedAt timestamp and purchasedBy user are recorded
5. **Given** a viewer-only user viewing a list, **When** they mark an item as purchased, **Then** the action succeeds (viewers can mark purchased/unpurchased)
6. **Given** a user viewing a list, **When** all items are marked as purchased, **Then** they see "All items purchased! 🎉" message

---

### User Story 3 - Edit Item Details (Priority: P1)

A user who owns or has editor permission on a list can edit any item's details including name, quantity, unit, category, and notes. Changes are saved immediately and visible to all collaborators.

**Why this priority**: Users often need to adjust item details as shopping plans change (e.g., "buy 3 instead of 2", "change to organic milk"). This flexibility is critical for real-world shopping workflows.

**Independent Test**: Can be tested by adding an item, editing its details, and verifying changes persist. Delivers value by allowing users to keep their list accurate as plans evolve.

**Acceptance Scenarios**:

1. **Given** a user viewing an item "Milk (2 gallons)", **When** they click "Edit" on the item, **Then** they see a form pre-filled with the current name, quantity, unit, category, and notes
2. **Given** a user editing an item, **When** they change quantity from "2" to "3" and click "Save", **Then** the item displays "Milk (3 gallons)"
3. **Given** a user editing an item, **When** they change the category from "Dairy" to "Produce", **Then** the item displays with the new category icon and color
4. **Given** a user editing an item, **When** they add notes "Organic only", **Then** the notes appear below the item name with a notes icon
5. **Given** a user editing an item, **When** they clear the quantity field and save, **Then** the quantity defaults to 1
6. **Given** a user with viewer-only permission, **When** they view an item, **Then** they do not see an "Edit" option (insufficient permissions)

---

### User Story 4 - Delete Items (Priority: P1)

A user with owner or editor permission can remove items they no longer need. The system asks for confirmation before deleting. Once deleted, the item is permanently removed from the list.

**Why this priority**: Users need to remove items they added by mistake or no longer need. This keeps lists clean and accurate. Critical for basic list maintenance.

**Independent Test**: Can be tested by adding an item, deleting it with confirmation, and verifying it no longer appears in the list. Delivers value through list cleanup capability.

**Acceptance Scenarios**:

1. **Given** a user viewing an item, **When** they click the delete icon, **Then** they see a confirmation dialog "Delete this item?"
2. **Given** a user sees the delete confirmation, **When** they click "Yes, Delete", **Then** the item is removed from the list immediately
3. **Given** a user sees the delete confirmation, **When** they click "Cancel", **Then** the item remains in the list unchanged
4. **Given** a list with 10 items, **When** a user deletes 1 item, **Then** the list shows "9 items" in the header
5. **Given** a user with viewer-only permission, **When** they view an item, **Then** they do not see a delete option (insufficient permissions)
6. **Given** a user deletes a purchased item, **When** the item is removed, **Then** the purchased count updates correctly (e.g., "2 of 9" becomes "2 of 8")

---

### User Story 5 - Reorder Items by Drag-and-Drop (Priority: P2)

A user can manually reorder items by dragging and dropping them to different positions. This allows organizing items by store layout (produce first, dairy last) or personal preference.

**Why this priority**: Manual ordering helps users organize their list to match their shopping route, making shopping more efficient. While valuable, users can still shop effectively with default ordering, so this is not critical for MVP.

**Independent Test**: Can be tested by adding 5 items, dragging item 3 to position 1, and verifying the order persists. Delivers value through personalized list organization.

**Acceptance Scenarios**:

1. **Given** a user viewing a list with 5 items, **When** they drag "Bananas" from position 3 to position 1, **Then** the item moves to the top and the list reorders accordingly
2. **Given** a user reordering items, **When** they drop an item in a new position, **Then** the new order is saved immediately and persists on page refresh
3. **Given** a user on mobile, **When** they long-press an item, **Then** they can drag it to a new position with touch gestures
4. **Given** a user reordering items, **When** they drag an unpurchased item below purchased items, **Then** the system allows the reorder (no restrictions)
5. **Given** a user with editor permission, **When** they reorder items, **Then** the changes are saved successfully
6. **Given** a user with viewer permission, **When** they view the list, **Then** drag handles are hidden or disabled (cannot reorder)

---

### User Story 6 - Add Notes and Additional Details (Priority: P2)

A user can add detailed notes to items (max 500 characters) such as "get the organic version" or "brand: Chobani". Notes help provide context and shopping instructions for themselves or collaborators.

**Why this priority**: Notes add valuable context for specific brands, preferences, or shopping instructions. While helpful, basic shopping functionality works without notes, making this P2 priority.

**Independent Test**: Can be tested by adding an item with notes, verifying notes display correctly, and editing notes later. Delivers value through enhanced item context.

**Acceptance Scenarios**:

1. **Given** a user adding an item, **When** they enter notes "Organic only, brand: Horizon", **Then** the notes are saved and displayed below the item name
2. **Given** a user viewing an item with notes, **When** they hover over the notes icon, **Then** they see the full notes text in a tooltip or expanded view
3. **Given** a user editing an item, **When** they add notes longer than 500 characters, **Then** they see an error message "Notes must be 500 characters or less"
4. **Given** a user editing an item, **When** they clear the notes field and save, **Then** the notes are removed and no notes icon appears
5. **Given** a user viewing a list on mobile, **When** they tap a notes icon, **Then** the notes expand below the item name
6. **Given** a collaborator viewing a list, **When** another user has added notes to an item, **Then** they can see the notes with attribution "Note from John Doe"

---

### User Story 7 - Quick Add from Previous Lists (Priority: P2)

A user typing in the "Add Item" field sees autocomplete suggestions based on items they've added to other lists. This speeds up adding frequently purchased items.

**Why this priority**: Autocomplete dramatically improves efficiency for repeat items, but users can still manually type items without this feature. Valuable for user experience but not critical for MVP.

**Independent Test**: Can be tested by adding "Milk" to one list, creating a new list, typing "Mi", and seeing "Milk" suggested. Delivers value through faster item entry.

**Acceptance Scenarios**:

1. **Given** a user who previously added "Milk" to another list, **When** they type "Mi" in the add item field, **Then** they see "Milk" suggested with previous quantity and unit
2. **Given** a user sees autocomplete suggestions, **When** they click on a suggestion, **Then** the item details auto-fill with the previous values
3. **Given** a user typing "Ban", **When** multiple matches exist ("Bananas", "Banana Bread"), **Then** they see all matching suggestions ranked by frequency of use
4. **Given** a user who has never added an item, **When** they type in the add item field, **Then** no autocomplete suggestions appear (empty history)
5. **Given** a user sees an autocomplete suggestion, **When** they press Enter without selecting, **Then** the typed text is used as the item name (not auto-selected)
6. **Given** a user adding an item via autocomplete, **When** the item is added, **Then** they can still edit the quantity or other details before saving

---

### User Story 8 - Filter and Sort Items (Priority: P3)

A user viewing a large list can filter items by category or purchased status, and sort by name, position, or date added. This helps manage lists with 50+ items.

**Why this priority**: Filtering and sorting become valuable for power users with large lists, but most users have smaller lists (10-20 items) where these features are less critical. Nice-to-have enhancement.

**Independent Test**: Can be tested by adding 20 items across 3 categories, filtering by "Produce", and verifying only produce items display. Delivers value for large list management.

**Acceptance Scenarios**:

1. **Given** a user viewing a list with 30 items across 5 categories, **When** they select "Filter by: Produce", **Then** only items in the Produce category are displayed
2. **Given** a user viewing a list with 10 purchased and 15 unpurchased items, **When** they select "Show: Unpurchased only", **Then** purchased items are hidden
3. **Given** a user viewing a list, **When** they select "Sort by: Name (A-Z)", **Then** items are displayed in alphabetical order regardless of position
4. **Given** a user viewing a list, **When** they select "Sort by: Category", **Then** items are grouped by category with category headers
5. **Given** a user with filters active, **When** they refresh the page, **Then** their filter/sort preferences are preserved (stored in URL or localStorage)
6. **Given** a user filtering items, **When** no items match the filter, **Then** they see "No items in this category" with option to clear filter

---

### Edge Cases

- **What happens when a user tries to add an item with an empty name?** System displays validation error "Item name is required" and does not create the item
- **What happens when a user tries to add an item to a list they don't have permission to edit?** System returns a 403 Forbidden error with message "You don't have permission to edit this list"
- **What happens when a user enters quantity as text (e.g., "three")?** System displays validation error "Quantity must be a number" or auto-converts common text to numbers
- **What happens when a user adds 100 items to a list?** System loads items with pagination or virtual scrolling for performance, displaying 50 at a time
- **What happens when two users mark the same item as purchased simultaneously?** Last write wins - both see the item as purchased (idempotent operation)
- **What happens when a user drags an item but drops it in an invalid location?** Item returns to original position with visual feedback (e.g., shake animation)
- **What happens when a user deletes an item that another user is currently editing?** The editing user sees "Item not found" error when they try to save, preventing stale data
- **What happens when network request fails (add, update, delete)?** System displays error message "Unable to complete action. Please check your connection and try again" with retry option
- **What happens when a user adds an item with quantity 0 or negative number?** System validates quantity must be positive (>0) and defaults to 1 if invalid
- **What happens when a category is deleted but items still reference it?** Items display with "Uncategorized" label and no category icon
- **What happens when item notes exceed 500 characters?** System truncates input at 500 chars or shows character counter warning as user types

---

## Requirements *(mandatory)*

### Functional Requirements

#### Item Creation (User Story 1)

- **FR-001**: System MUST provide an "Add Item" button or input field accessible from the list detail page
- **FR-002**: System MUST require an item name (1-100 characters) for item creation
- **FR-003**: System MUST allow optional fields: quantity (positive number, default: 1), unit (string), categoryId, notes (max 500 chars), imageUrl
- **FR-004**: System MUST display validation errors if name is empty, exceeds 100 characters, or quantity is invalid
- **FR-005**: System MUST set the authenticated user as the creator (createdBy) of newly added items
- **FR-006**: System MUST initialize new items as unpurchased (isPurchased: false)
- **FR-007**: System MUST assign new items the next available position (last in list)
- **FR-008**: System MUST prevent viewers from adding items (require editor or owner permission)
- **FR-009**: System MUST update the list's item count and last updated timestamp when an item is added

#### Purchase Status Tracking (User Story 2)

- **FR-010**: System MUST display a checkbox or toggle for each item to mark purchased/unpurchased status
- **FR-011**: System MUST visually distinguish purchased items (e.g., strikethrough, grayed out, moved to bottom section)
- **FR-012**: System MUST display a summary count "X of Y items purchased" at the list level
- **FR-013**: System MUST record purchasedAt timestamp and purchasedBy user when an item is marked as purchased
- **FR-014**: System MUST clear purchasedAt and purchasedBy when an item is marked as unpurchased
- **FR-015**: System MUST allow viewers to toggle purchased status (viewers can mark items but not edit details)
- **FR-016**: System MUST display celebration message (e.g., "All items purchased! 🎉") when all items are purchased

#### Item Editing (User Story 3)

- **FR-017**: System MUST allow owners and editors to update item name, quantity, unit, categoryId, and notes
- **FR-018**: System MUST prevent viewers from editing item details (read-only except purchase status)
- **FR-019**: System MUST validate updated name (1-100 characters) and notes (max 500 characters) before saving
- **FR-020**: System MUST update the item's updatedAt timestamp when details are changed
- **FR-021**: System MUST preserve purchased status when editing other item details
- **FR-022**: System MUST display success confirmation after successful update
- **FR-023**: System MUST pre-fill edit form with current item values

#### Item Deletion (User Story 4)

- **FR-024**: System MUST allow owners and editors to delete items
- **FR-025**: System MUST prevent viewers from deleting items
- **FR-026**: System MUST display confirmation dialog before deleting an item
- **FR-027**: System MUST permanently delete items (hard delete, not soft delete for performance)
- **FR-028**: System MUST update the list's item count and purchased count when an item is deleted
- **FR-029**: System MUST update the list's last updated timestamp when an item is deleted
- **FR-030**: System MUST return 404 Not Found error if trying to access a deleted item

#### Item Reordering (User Story 5)

- **FR-031**: System MUST allow owners and editors to reorder items by dragging and dropping
- **FR-032**: System MUST prevent viewers from reordering items
- **FR-033**: System MUST save new item positions immediately when reordered
- **FR-034**: System MUST support touch gestures for drag-and-drop on mobile devices
- **FR-035**: System MUST maintain item positions across page refreshes and sessions
- **FR-036**: System MUST allow reordering items regardless of purchased status

#### Notes and Details (User Story 6)

- **FR-037**: System MUST allow adding notes field (max 500 characters) to items
- **FR-038**: System MUST display notes icon or indicator when an item has notes
- **FR-039**: System MUST show full notes text on hover (desktop) or tap (mobile)
- **FR-040**: System MUST validate notes length does not exceed 500 characters
- **FR-041**: System MUST allow clearing notes by saving an empty notes field
- **FR-042**: System MUST display notes attribution if created by a collaborator

#### Quick Add Autocomplete (User Story 7)

- **FR-043**: System MUST provide autocomplete suggestions based on user's previous items across all lists
- **FR-044**: System MUST rank suggestions by frequency of use (most used first)
- **FR-045**: System MUST auto-fill item details (quantity, unit, category) when a suggestion is selected
- **FR-046**: System MUST allow user to override auto-filled values before saving
- **FR-047**: System MUST debounce autocomplete queries to avoid excessive API calls (300ms delay)
- **FR-048**: System MUST show "No suggestions" if no matches found or user has no item history

#### Filtering and Sorting (User Story 8)

- **FR-049**: System MUST provide filter options: "All items", "Unpurchased only", "Purchased only", "By category"
- **FR-050**: System MUST provide sort options: "Manual order (position)", "Name (A-Z)", "Name (Z-A)", "Date added", "Category"
- **FR-051**: System MUST persist filter/sort preferences in URL query parameters or localStorage
- **FR-052**: System MUST display "No items found" message when filters return zero results
- **FR-053**: System MUST provide a "Clear filters" button when filters are active

### Key Entities

- **List Item**: Represents a single product or item to purchase on a shopping list
  - **Name**: 1-100 character text identifying the item (e.g., "Milk", "Bananas")
  - **Quantity**: Positive number indicating how many to purchase (default: 1)
  - **Unit**: Optional text describing the unit of measurement (e.g., "gallons", "pieces", "lbs")
  - **Category**: Optional reference to a category entity (e.g., "Dairy", "Produce")
  - **Notes**: Optional text (max 500 characters) with additional details or instructions
  - **Image URL**: Optional URL to item image (for future enhancement)
  - **Is Purchased**: Boolean indicating if item has been purchased
  - **Position**: Integer determining display order in the list (1 = first item)
  - **Created By**: User who added the item to the list
  - **Created At**: Timestamp when item was created
  - **Updated At**: Timestamp when item was last modified
  - **Purchased At**: Timestamp when item was marked as purchased (null if unpurchased)
  - **Purchased By**: User who marked the item as purchased (null if unpurchased)

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can add a new item to a list in under 10 seconds using quick add
- **SC-002**: Users can mark 10 items as purchased in under 30 seconds during shopping
- **SC-003**: System displays a list with 50 items in under 1 second
- **SC-004**: 95% of item creation, editing, and deletion operations complete successfully without errors
- **SC-005**: Users can reorder items by drag-and-drop with visual feedback in under 2 seconds per item
- **SC-006**: Autocomplete suggestions appear within 300ms of typing, improving add speed by 50%
- **SC-007**: Users with large lists (100+ items) can find specific items using filters in under 5 seconds
- **SC-008**: 90% of users successfully complete their first shopping trip using the app to track purchases
- **SC-009**: System supports lists with 500+ items without performance degradation in scrolling or search
- **SC-010**: Real-time purchase status updates are reflected to all collaborators within 2 seconds (when Feature 007 is implemented)

---

## Assumptions

1. **Authentication**: Users are already authenticated via Feature 001 (User Authentication) with valid JWT tokens
2. **Authorization**: Permission checks (Owner, Editor, Viewer) are enforced at API layer for all item operations
3. **List Existence**: List Items Management assumes Feature 003 (Shopping Lists CRUD) is fully implemented
4. **Categories**: Category system (Feature 005) may not exist yet - items can have optional categoryId but gracefully handle missing categories
5. **Real-time Sync**: Item changes are NOT synchronized in real-time to other users in this feature (deferred to Feature 007)
6. **Image Upload**: Image URL field exists but image upload functionality is not implemented (future enhancement)
7. **Default Ordering**: Items are displayed by position (manual order) by default, with purchased items optionally shown at bottom
8. **Item Limit**: No enforced limit on items per list, but UI optimizes for lists with 10-100 items
9. **Mobile Experience**: All item management features work on mobile devices with touch-friendly UI (responsive design)
10. **Offline Support**: App requires network connection for item operations - offline support is future enhancement

---

## Dependencies

### Required (Blocking)
- **Feature 001**: User Authentication - Needed for JWT tokens, user identity, and item ownership
- **Feature 003**: Shopping Lists CRUD - Items belong to lists, lists must exist first

### Optional (Enhances)
- **Feature 005**: Categories System - Provides category icons and colors for items, but items work without categories

### Enables (Downstream)
- **Feature 007**: Real-time Collaboration - Real-time item updates build on this foundation
- **Feature 009**: Activity Feed - Item activities (added, purchased, deleted) feed into activity timeline
- **Feature 010**: Purchase History - Item purchase tracking enables historical analysis

---

## Out of Scope

The following are explicitly NOT included in this feature and will be addressed separately:

1. **Real-time synchronization** of item changes across multiple users - Deferred to Feature 007 (Real-time Collaboration)
2. **Category management** (creating, editing categories) - Handled in Feature 005 (Categories System)
3. **Image upload functionality** - Future enhancement, imageUrl field exists but upload not implemented
4. **Barcode scanning** to add items - Future enhancement for mobile experience
5. **Item suggestions based on AI/ML** - Handled in Feature 011 (Item Suggestions)
6. **Purchase history and analytics** - Handled in Feature 010 (Purchase History)
7. **Bulk item operations** (add multiple items at once, bulk delete) - Future enhancement
8. **Item templates or presets** - Handled in Feature 012 (Recurring Lists)
9. **Shopping mode with swipe gestures** - Future mobile enhancement
10. **Offline item creation** (PWA offline support) - Future enhancement
11. **Item sharing across lists** (copy/move items) - Future enhancement
12. **Price tracking and budget management** - Future enhancement for budget-conscious users

---

**Specification Status**: Ready for validation  
**Next Steps**: 
1. Run quality validation checklist
2. Resolve any [NEEDS CLARIFICATION] markers if identified during validation
3. Proceed to `/speckit.plan` for implementation planning

