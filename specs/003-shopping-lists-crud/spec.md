# Feature Specification: Shopping Lists CRUD

**Feature Branch**: `003-shopping-lists-crud`  
**Created**: 2025-11-05  
**Status**: Draft  
**Input**: User description: "003 - Shopping Lists CRUD"

## Implementation Note *(constitution exception)*

**Backend Pre-Implementation**: This feature's backend API was implemented before this specification was written, which deviates from Constitution Principle I (Specification-First Development). This spec serves as:

1. **Verification artifact** - Documents existing API behavior and contracts
2. **Integration guide** - Provides frontend developers with complete API reference
3. **Testing baseline** - Acceptance scenarios verify backend matches expected behavior

**Constitution Compliance**: This deviation is documented and accepted as a legacy exception. All future features MUST follow specification-first development.

**Action Required**: Before frontend integration, Task T003 must verify backend test coverage ≥80% per Constitution Principle V (TDD).

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View My Shopping Lists (Priority: P1)

A logged-in user navigates to the main dashboard to see all their shopping lists (both owned and shared) displayed in an organized grid or list view. Each list card shows the list name, description, item counts, owner information, and when it was last updated.

**Why this priority**: This is the entry point to the entire application. Without being able to view lists, users cannot access any shopping functionality. This provides immediate value by showing users what lists they have access to.

**Independent Test**: Can be fully tested by logging in and viewing the dashboard. Delivers value by showing existing lists and access to create new ones. No dependencies on other stories.

**Acceptance Scenarios**:

1. **Given** a logged-in user with 3 owned lists and 2 shared lists, **When** they navigate to the dashboard, **Then** they see all 5 lists displayed with names, descriptions, item counts, and last updated timestamps
2. **Given** a logged-in user with no lists, **When** they navigate to the dashboard, **Then** they see an empty state message "No lists yet" with a prominent "Create Your First List" button
3. **Given** a user viewing the dashboard, **When** they click on a list card, **Then** they navigate to the list detail page showing all items in that list
4. **Given** a user viewing the dashboard, **When** lists load, **Then** they see owned lists distinguished from shared lists (e.g., with "Owner" or "Shared" badge)
5. **Given** a user with 50+ lists, **When** they scroll to the bottom of the page, **Then** additional lists load automatically (pagination)

---

### User Story 2 - Create a New Shopping List (Priority: P1)

A logged-in user clicks a "Create List" button, enters a name (required) and optionally a description, then saves the list. The new list appears in their dashboard and they can immediately start adding items to it.

**Why this priority**: Creating lists is core functionality - users need at least one list before they can add shopping items. This is the first productive action a new user takes.

**Independent Test**: Can be fully tested by creating a list with a name and verifying it appears in the dashboard. Delivers immediate value as users now have a container for their shopping items.

**Acceptance Scenarios**:

1. **Given** a logged-in user on the dashboard, **When** they click "Create New List", **Then** they see a form with "Name" (required) and "Description" (optional) fields
2. **Given** a user on the create list form, **When** they enter a name "Weekly Groceries" and click "Create", **Then** the list is created and they are navigated to the new list's detail page
3. **Given** a user on the create list form, **When** they click "Create" without entering a name, **Then** they see an error message "List name is required" and the list is not created
4. **Given** a user creating a list, **When** they enter a name longer than 200 characters, **Then** they see an error message "List name must be 200 characters or less"
5. **Given** a user creates a list with name "Birthday Party" and description "Shopping for Sarah's 5th birthday", **When** the list is created, **Then** both name and description are displayed on the list detail page
6. **Given** a newly created list, **When** the user views it in the dashboard, **Then** it shows 0 items, 0 purchased items, and them as the owner

---

### User Story 3 - Edit List Details (Priority: P2)

A user who owns or has editor permission on a list can update the list's name and description. Changes are saved immediately and reflected across all collaborators viewing the list.

**Why this priority**: Users need to refine list names and descriptions as their shopping needs evolve. While not critical for MVP, it's important for list organization and clarity.

**Independent Test**: Can be tested independently by creating a list, editing its details, and verifying changes persist. Delivers value by allowing users to keep list information accurate and organized.

**Acceptance Scenarios**:

1. **Given** a user viewing a list they own, **When** they click "Edit List" in the settings menu, **Then** they see a form pre-filled with the current name and description
2. **Given** a user editing a list, **When** they change the name from "Groceries" to "Weekly Groceries" and click "Save", **Then** the new name is displayed on the list detail page and in the dashboard
3. **Given** a user editing a list, **When** they clear the description field and save, **Then** the description is removed and the list shows no description
4. **Given** a user with viewer-only permission, **When** they view a list, **Then** they do not see an "Edit List" option (insufficient permissions)
5. **Given** a user with editor permission, **When** they edit a list's name and description, **Then** the changes are saved successfully
6. **Given** a user editing a list, **When** they click "Cancel", **Then** no changes are saved and they return to the list detail page

---

### User Story 4 - Delete a Shopping List (Priority: P2)

A list owner can permanently delete a list they no longer need. The system asks for confirmation before deleting. Once deleted, the list and all its items are removed from the database (soft delete with retention for potential recovery).

**Why this priority**: Users need to remove lists they no longer use to keep their dashboard clean. While important for long-term usability, it's not critical for initial MVP launch.

**Independent Test**: Can be tested by creating a list, deleting it with confirmation, and verifying it no longer appears in the dashboard. Delivers value by allowing users to maintain a clutter-free workspace.

**Acceptance Scenarios**:

1. **Given** a user viewing a list they own, **When** they click "Delete List" in the settings menu, **Then** they see a confirmation dialog warning "This will permanently delete the list and all its items. Are you sure?"
2. **Given** a user sees the delete confirmation dialog, **When** they click "Yes, Delete", **Then** the list is deleted and they are redirected to the dashboard
3. **Given** a user sees the delete confirmation dialog, **When** they click "Cancel", **Then** the list is not deleted and they remain on the list detail page
4. **Given** a user with editor or viewer permission, **When** they view a list, **Then** they do not see a "Delete List" option (owner-only action)
5. **Given** a list with 10 items, **When** the owner deletes the list, **Then** all 10 items are also deleted (cascading delete)
6. **Given** a deleted list, **When** anyone tries to access it by direct URL, **Then** they see a "List not found" error message

---

### User Story 5 - Archive and Unarchive Lists (Priority: P2)

A user who owns a list can archive it to hide it from the main dashboard while preserving all data. Archived lists are accessible through an "Archived Lists" page and can be unarchived to restore them to the main dashboard.

**Why this priority**: Archiving provides a middle ground between keeping lists active and deleting them. Users can complete a shopping trip and archive the list for future reference without cluttering their dashboard. This is valuable but not critical for MVP.

**Independent Test**: Can be tested by creating a list, archiving it, verifying it's hidden from the dashboard but accessible in the archived page, then unarchiving it. Delivers value through better organization.

**Acceptance Scenarios**:

1. **Given** a user viewing a list they own, **When** they click "Archive List" in the settings menu, **Then** the list is archived and they are redirected to the dashboard
2. **Given** an archived list, **When** the user views the main dashboard, **Then** the archived list does not appear in the list (unless "Show Archived" filter is enabled)
3. **Given** a user, **When** they navigate to "Archived Lists" page, **Then** they see all their archived lists with an "Unarchive" button on each
4. **Given** a user viewing an archived list in the archived lists page, **When** they click "Unarchive", **Then** the list is restored to active status and appears in the main dashboard
5. **Given** a user with editor or viewer permission on an archived list, **When** they view the list, **Then** they can still view items but see a banner "This list is archived"
6. **Given** a user with editor permission on an archived list, **When** they try to archive it, **Then** the action is blocked (owner-only for archive/unarchive)

---

### User Story 6 - Search, Filter, and Sort Lists (Priority: P3)

A user with many lists can search by list name, filter lists by status (owned/shared/archived), and sort lists by various criteria (name, date created, date updated, item count). This helps users quickly find the list they need.

**Why this priority**: This is a convenience feature that becomes valuable as users accumulate many lists. Not critical for MVP but significantly improves user experience for power users.

**Independent Test**: Can be tested by creating multiple lists with different names and characteristics, then using search/filter/sort controls to verify the correct lists appear. Delivers value through improved findability.

**Acceptance Scenarios**:

1. **Given** a user with 20 lists, **When** they type "groc" in the search box, **Then** only lists with names containing "groc" (case-insensitive) are displayed
2. **Given** a user viewing the dashboard, **When** they select the "Owned by me" filter, **Then** only lists where they are the owner are displayed
3. **Given** a user viewing the dashboard, **When** they select the "Shared with me" filter, **Then** only lists where they are a collaborator (not owner) are displayed
4. **Given** a user viewing the dashboard, **When** they enable the "Include Archived" toggle, **Then** archived lists appear in the list with an "Archived" badge
5. **Given** a user viewing the dashboard, **When** they select "Sort by Name (A-Z)", **Then** lists are displayed in alphabetical order by name
6. **Given** a user viewing the dashboard, **When** they select "Sort by Recently Updated", **Then** lists are displayed with most recently updated first
7. **Given** a user with search/filter/sort settings active, **When** they refresh the page, **Then** their settings are preserved (stored in URL query params or localStorage)

---

### Edge Cases

- **What happens when a user tries to create a list with an empty name?** System displays validation error "List name is required" and does not create the list
- **What happens when a user tries to access a list they don't have permission to view?** System returns a 403 Forbidden error with message "You don't have permission to access this list"
- **What happens when a user tries to access a deleted list via direct URL?** System returns a 404 Not Found error with message "List not found"
- **What happens when a list owner tries to delete a list with 100 items?** System displays confirmation dialog warning about the number of items, then deletes the list and all items if confirmed
- **What happens when a user has 1000+ lists?** Pagination loads lists in batches of 20, with infinite scroll or "Load More" button for additional pages
- **What happens when two editors update the same list name simultaneously?** Last write wins (second save overwrites first). Real-time conflict resolution deferred to Feature 007
- **What happens when a user searches for a list but no results match?** System displays "No lists found matching '[search term]'" with option to clear search
- **What happens when a user tries to archive an already archived list?** System prevents the action (archive button is hidden or disabled) or returns an error message
- **What happens to shared lists when the owner deletes them?** All collaborators lose access to the list immediately. Deferred to Feature 008 (may add email notification)
- **What happens when network request fails (create, update, delete)?** System displays error message "Unable to complete action. Please check your connection and try again" with retry option

---

## Requirements *(mandatory)*

### Functional Requirements

#### List Viewing (User Story 1)

- **FR-001**: System MUST display all lists accessible to the authenticated user (owned + shared) on the main dashboard
- **FR-002**: System MUST show for each list: name, description, owner name, total item count, purchased item count, last updated timestamp, and archived status
- **FR-003**: System MUST distinguish owned lists from shared lists visually (e.g., "Owner" vs "Shared" badge)
- **FR-004**: System MUST display an empty state message with "Create Your First List" button when user has no lists
- **FR-005**: System MUST implement pagination for users with more than 20 lists. Default page size is 20, configurable to 10, 20, 50, or 100 via user preference. Pagination uses cursor-based pagination (last list ID + timestamp) for consistent results during concurrent updates. Infinite scroll UI pattern loads next page when user scrolls within 200px of bottom.
- **FR-006**: System MUST load list detail page when user clicks on a list card

#### List Creation (User Story 2)

- **FR-007**: System MUST provide a "Create New List" button accessible from the main dashboard
- **FR-008**: System MUST require a list name (1-200 characters) for list creation
- **FR-009**: System MUST allow an optional description field for list creation (max 1000 characters)
- **FR-010**: System MUST set the authenticated user as the owner of newly created lists
- **FR-011**: System MUST initialize new lists with 0 items and 0 purchased items
- **FR-012**: System MUST redirect user to the new list's detail page after successful creation
- **FR-013**: System MUST display validation errors if name is empty or exceeds 200 characters

#### List Editing (User Story 3)

- **FR-014**: System MUST allow list owners and editors to update list name and description
- **FR-015**: System MUST prevent viewers from editing list details (read-only access)
- **FR-016**: System MUST validate updated name (1-200 characters) before saving
- **FR-017**: System MUST allow users to remove description by saving an empty description field
- **FR-018**: System MUST update the list's "last updated" timestamp when details are changed
- **FR-019**: System MUST display success confirmation after successful update

#### List Deletion (User Story 4)

- **FR-020**: System MUST allow only list owners to delete lists
- **FR-021**: System MUST display confirmation dialog before deleting a list, warning about permanent deletion of list and all items
- **FR-022**: System MUST soft-delete lists (set DeletedAt timestamp) with 30-day retention period before permanent deletion. Automated cleanup process removes soft-deleted records older than 30 days.
- **FR-023**: System MUST cascade delete all items within a deleted list
- **FR-024**: System MUST remove deleted lists from all user dashboards immediately
- **FR-025**: System MUST redirect user to main dashboard after successful deletion
- **FR-026**: System MUST return 404 Not Found error when accessing a deleted list

#### List Archiving (User Story 5)

- **FR-027**: System MUST allow list owners to archive and unarchive lists
- **FR-028**: System MUST hide archived lists from main dashboard by default
- **FR-029**: System MUST provide an "Archived Lists" page showing all archived lists
- **FR-030**: System MUST allow viewing archived list details (items, collaborators)
- **FR-031**: System MUST allow editors and viewers to access archived lists they have permission for
- **FR-032**: System MUST display an "Archived" badge or banner on archived list detail pages
- **FR-033**: System MUST restore archived lists to active status when unarchived
- **FR-034**: System MUST update the list's "archived at" timestamp when archiving/unarchiving

#### Search, Filter, Sort (User Story 6)

- **FR-035**: System MUST provide a search input that filters lists by name (case-insensitive, partial match)
- **FR-036**: System MUST provide filter options: "All Lists", "Owned by me", "Shared with me"
- **FR-037**: System MUST provide an "Include Archived" toggle to show/hide archived lists. By default, archived lists are excluded from dashboard and search results. When toggle is enabled, archived lists appear with an "Archived" badge.
- **FR-038**: System MUST provide sort options: "Name (A-Z)", "Name (Z-A)", "Recently Updated", "Recently Created", "Most Items"
- **FR-039**: System MUST persist search/filter/sort preferences in URL query parameters for shareable links
- **FR-040**: System MUST display "No lists found" message when search/filter returns zero results
- **FR-041**: System MUST debounce search input to avoid excessive API calls (500ms delay)
- **FR-050**: Search and filter operations MUST work in combination. Example: Searching "grocery" with "Owned by me" filter + "Include Archived" enabled shows only owned, archived lists matching "grocery".

#### Real-time Collaboration (All User Stories)

- **FR-042**: System MUST broadcast list creation events via SignalR to all list collaborators
- **FR-043**: System MUST broadcast list update events (name, description changes) via SignalR to all collaborators
- **FR-044**: System MUST broadcast list deletion events via SignalR to all collaborators
- **FR-045**: System MUST broadcast list archive/unarchive events via SignalR to all collaborators
- **FR-046**: Frontend MUST implement optimistic UI updates for list operations with rollback on errors
- **FR-047**: System MUST display conflict notifications when concurrent edits occur (last-write-wins with user notification). Conflict detection compares UpdatedAt timestamp from SignalR event with local state timestamp. Notification shown if timestamps differ by > 1 second.
- **FR-048**: System MUST update list dashboard in real-time when other users create, update, or delete lists (within 2 seconds)
- **FR-049**: System MUST detect concurrent edits within 2 seconds of the conflicting change being saved by another user

### Key Entities

- **Shopping List**: Represents a collection of shopping items with a name, description, owner, collaborators, and archived status
  - **Name**: 1-200 character text identifying the list
  - **Description**: Optional text (max 1000 characters) describing the list's purpose
  - **Owner**: The user who created the list (has full control)
  - **Archived Status**: Boolean indicating if list is archived
  - **Archived At**: Timestamp when list was archived (null if active)
  - **Created At**: Timestamp when list was created
  - **Updated At**: Timestamp when list was last modified
  - **Deleted At**: Timestamp when list was soft-deleted (null if active)
  - **Item Count**: Total number of items in the list
  - **Purchased Count**: Number of items marked as purchased

- **List Collaborator**: Represents a user's access level to a list (owned, shared via invitation)
  - **User**: The user with access to the list
  - **List**: The shopping list being accessed
  - **Permission Level**: Owner, Editor, or Viewer
  - **Invited At**: Timestamp when user was invited
  - **Accepted At**: Timestamp when user accepted invitation (null if owner/creator)

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can create a new shopping list in under 30 seconds from the dashboard
- **SC-002**: Users can find a specific list among 50+ lists using search in under 5 seconds
- **SC-003**: System displays list dashboard with 20 lists in under 1 second
- **SC-004**: 95% of list creation, editing, and deletion operations complete successfully without errors
- **SC-005**: Users with 100+ lists can navigate and find lists efficiently using pagination and filters
- **SC-006**: Users successfully archive completed lists to maintain organized dashboard
- **SC-007**: List owners can delete unwanted lists with clear confirmation, preventing accidental deletions
- **SC-008**: 90% of users understand the difference between archiving and deleting lists (measured by support ticket volume)
- **SC-009**: Shared list collaborators see accurate list information without permission errors (99.9% success rate)
- **SC-010**: Real-time list updates (create, edit, delete, archive) are broadcast to all collaborators within 2 seconds via SignalR
- **SC-011**: List creation API responds within 500ms under normal load (p95 latency)
- **SC-012**: List update/delete operations complete within 300ms (p95 latency)
- **SC-013**: System supports 10,000+ lists per user without performance degradation in pagination/search

---

## Assumptions

1. **Authentication**: Users are already authenticated via Feature 001 (User Authentication) with valid JWT tokens
2. **Authorization**: Permission checks (Owner, Editor, Viewer) are enforced at API layer and database query level
3. **Data Retention**: Soft-deleted lists are retained for 30 days before permanent deletion (specified in FR-022)
4. **Real-time Collaboration**: List updates (create, edit, delete, archive) ARE broadcast via SignalR to all list collaborators in real-time. Frontend implements optimistic UI updates with rollback on errors (per Constitution Principle III).
5. **Collaborator Management**: Inviting and managing collaborators is handled in Feature 008 (Invitations & Permissions)
6. **Items Management**: Adding, editing, and managing items within lists is handled in Feature 004 (List Items Management)
7. **Default Sorting**: Lists are sorted by "Recently Updated" by default when user first visits dashboard
8. **Pagination Size**: Default page size is 20 lists, configurable by user (10, 20, 50, 100)
9. **Search Performance**: Search is client-side filtering for < 100 lists, server-side for >= 100 lists
10. **Mobile Experience**: All list management features work on mobile devices with touch-friendly UI (responsive design)
11. **List Name Uniqueness**: List names are NOT required to be unique per user. Users can create multiple lists with the same name (e.g., multiple "Grocery" lists for different purposes). Lists are uniquely identified by UUID, not name.

---

## Dependencies

### Required (Blocking)
- **Feature 001**: User Authentication - Needed for JWT tokens, user identity, and ownership

### Enables (Downstream)
- **Feature 004**: List Items Management - Items belong to lists, this feature must exist first
- **Feature 008**: Invitations & Permissions - Sharing lists requires lists to exist
- **Feature 007**: Real-time Collaboration - Real-time list updates build on this foundation

---

## Out of Scope

The following are explicitly NOT included in this feature and will be addressed separately:

1. **Inviting collaborators and managing permissions** - Handled in Feature 008 (Invitations & Permissions)
2. **List items management** (adding, editing, reordering items) - Handled in Feature 004 (List Items Management)
3. **List templates and recurring lists** - Deferred to Feature 012 (Recurring Lists)
4. **Exporting lists** (PDF, CSV) - Future enhancement, not in MVP
5. **List categories or tags** - Future enhancement for advanced organization
6. **List sharing via public link** - Requires additional security considerations, deferred
7. **Bulk operations** (delete multiple lists, bulk archive) - Future enhancement for power users
8. **List history/audit trail** (who changed what, when) - Handled in Feature 009 (Activity Feed)
9. **Offline list creation** (PWA offline support) - Future enhancement for mobile experience

---

**Specification Status**: Ready for validation and planning  
**Next Steps**: 
1. Run quality validation checklist
2. Resolve any [NEEDS CLARIFICATION] markers (none in this spec)
3. Proceed to `/speckit.plan` for implementation planning

