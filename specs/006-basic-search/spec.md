# Feature Specification: Basic Search

**Feature Branch**: `006-basic-search`  
**Created**: November 5, 2025  
**Status**: Draft  
**Input**: User description: "006 - Basic Search"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Search for Lists by Name (Priority: P1)

A user with multiple shopping lists wants to quickly find a specific list (e.g., "Birthday Party", "Weekly Groceries") by typing part of the list name into a search bar. The system displays matching lists instantly with the search term highlighted in results.

**Why this priority**: Users accumulate many lists over time. Without search, finding a specific list becomes tedious when scrolling through dozens or hundreds of lists. This is the foundation of search functionality.

**Independent Test**: Can be fully tested by creating 10 lists with different names, searching for partial text (e.g., "week" to find "Weekly Groceries"), and verifying matching lists appear with highlighting. Delivers immediate value for list discovery.

**Acceptance Scenarios**:

1. **Given** a user has lists named "Weekly Groceries", "Monthly Budget", and "Weekend Camping", **When** they type "week" in the search box, **Then** they see "Weekly Groceries" and "Weekend Camping" with "week" highlighted in the names
2. **Given** a user searches for "groceries" (lowercase), **When** results load, **Then** they see "Weekly Groceries" regardless of case (case-insensitive search)
3. **Given** a user searches for "XYZ123", **When** no lists match, **Then** they see "No lists found matching 'XYZ123'" message with option to clear search
4. **Given** a user types in the search box, **When** they pause typing for 300ms, **Then** the search executes automatically (debounced input)
5. **Given** a user has 50 lists matching "grocery", **When** search results load, **Then** the first 20 results are displayed with pagination controls ("Showing 1-20 of 50 results")
6. **Given** a user views search results, **When** they click "Clear Search" button, **Then** search is reset and all lists are displayed
7. **Given** a user searches for a list, **When** they click on a result, **Then** they navigate to the list detail page

---

### User Story 2 - Search for Items by Name (Priority: P1)

A user wants to find specific items (e.g., "milk", "bread", "apples") across all their shopping lists without manually checking each list. The system searches through all items in all accessible lists and returns matching items with their parent list context.

**Why this priority**: Users often remember the item they need but not which list it's in. Searching items across all lists saves time and prevents duplicate items in different lists. Essential for managing multiple shopping lists effectively.

**Independent Test**: Can be fully tested by creating 3 lists with various items, searching for an item name that appears in multiple lists, and verifying results show the item with its parent list context.

**Acceptance Scenarios**:

1. **Given** a user has "milk" in "Weekly Groceries" and "Costco Trip" lists, **When** they search for "milk", **Then** they see both items displayed with their respective list names
2. **Given** a user searches for "appl" (partial text), **When** results load, **Then** they see all items containing "appl" like "Apples", "Applesauce", "Apple Juice" with matching text highlighted
3. **Given** a user has items with notes containing "organic", **When** they search for "organic", **Then** items with "organic" in name OR notes appear in results
4. **Given** a user searches for items, **When** results display, **Then** each item shows: name, parent list name, category badge, purchase status, and quantity
5. **Given** a user finds an item in search results, **When** they click on the item, **Then** they navigate to the parent list with that item highlighted or scrolled into view
6. **Given** a user has 100 items matching "bread", **When** search results load, **Then** the first 20 items are displayed with pagination ("Showing 1-20 of 100 items")
7. **Given** a user searches for items, **When** only purchased items match, **Then** purchased items appear in results (search includes all items regardless of purchase status)

---

### User Story 3 - Combined Search (Lists and Items) (Priority: P2)

A user wants to search for a term and see both matching lists and matching items in a unified search experience. The system displays results grouped by type (Lists, Items) with counts and quick filters to toggle between result types.

**Why this priority**: Provides a comprehensive search experience where users don't need to know whether they're looking for a list or an item. While not critical for MVP, it significantly improves user experience by reducing cognitive load.

**Independent Test**: Can be tested by creating lists and items with overlapping names (e.g., list "Groceries" and item "Grocery bags"), searching for "grocer", and verifying both appear in grouped results.

**Acceptance Scenarios**:

1. **Given** a user searches for "party", **When** results load, **Then** they see results grouped as "Lists (2)" and "Items (5)" with totals displayed
2. **Given** a user views combined search results, **When** they click "Lists only" filter, **Then** only matching lists are displayed
3. **Given** a user views combined search results, **When** they click "Items only" filter, **Then** only matching items are displayed
4. **Given** combined search returns 3 lists and 15 items, **When** results display, **Then** lists are shown first (all 3), followed by items (first 10 with "Show more items" button)
5. **Given** a user searches for "milk", **When** results show both lists and items, **Then** each result type is clearly separated with section headers and different styling
6. **Given** a user has search results filtered to "Lists only", **When** they clear the filter, **Then** both lists and items appear again

---

### User Story 4 - Search Result Pagination (Priority: P2)

A user whose search returns more than 20 results (lists or items) can navigate through pages of results using pagination controls. The system loads additional results efficiently without losing search context.

**Why this priority**: Essential for users with large numbers of lists or items. Without pagination, long result sets would overwhelm the UI and cause performance issues. Important but can follow after basic search functionality.

**Independent Test**: Can be tested by creating 50 items with similar names, searching to trigger pagination, and navigating through pages while verifying results persist and page state is maintained.

**Acceptance Scenarios**:

1. **Given** a search returns 45 items, **When** results load, **Then** the user sees "Page 1 of 3" with "Next" and "Previous" buttons (20 per page)
2. **Given** a user is on page 1 of search results, **When** they click "Next", **Then** page 2 loads showing items 21-40 with updated page indicator
3. **Given** a user is on page 2 of search results, **When** they click "Previous", **Then** page 1 loads showing items 1-20
4. **Given** a user is on page 2 of search results, **When** they click a page number "3", **Then** page 3 loads showing items 41-45
5. **Given** a user navigates to page 3, **When** they click on an item to view details, then return to search, **Then** they return to page 3 of results (state preserved in URL)
6. **Given** a user has 100+ results, **When** they scroll to the bottom of the page, **Then** the next page of results loads automatically (infinite scroll as alternative to pagination buttons)
7. **Given** a search is loading results, **When** user sees pagination controls, **Then** a loading spinner indicates data is being fetched

---

### User Story 5 - Search Result Highlighting (Priority: P2)

A user viewing search results can easily identify which part of a list or item name matches their search term. The system highlights matching text in a visually distinct way (e.g., bold, yellow background, or colored text).

**Why this priority**: Improves usability by helping users quickly scan results and verify relevance. Particularly valuable when partial matches return many results. Enhances user experience but not blocking MVP.

**Independent Test**: Can be tested by searching for partial text (e.g., "gro") and verifying the matching portion ("gro" in "Groceries") is visually highlighted in all result items.

**Acceptance Scenarios**:

1. **Given** a user searches for "appl", **When** results display "Apples" and "Applesauce", **Then** "appl" is highlighted in yellow in both item names
2. **Given** a user searches for "milk" (case-insensitive), **When** results display "MILK" and "Milk", **Then** the matching text is highlighted regardless of case
3. **Given** a user searches for "organic" and item has "organic" in notes, **When** results display, **Then** "organic" is highlighted in both item name (if present) and notes preview
4. **Given** a user searches for multiple words "weekly groceries", **When** results display, **Then** both "weekly" and "groceries" are highlighted independently
5. **Given** a user searches for special characters "c++" or "c#", **When** results display, **Then** special characters are properly escaped and highlighted
6. **Given** highlighted search results, **When** user clears search, **Then** highlighting is removed from all displayed items

---

### User Story 6 - Search Shared Lists and Items (Priority: P1)

A user searches for lists and items not only in their owned lists but also in lists shared with them. The system includes all accessible content (owned + shared) in search results with clear ownership indicators.

**Why this priority**: Core functionality for collaborative shopping. Users need to find items in shared family or team lists. Without this, search would be incomplete and frustrating for collaboration use cases.

**Independent Test**: Can be tested by sharing a list with another user, having that user search for items in the shared list, and verifying they appear in results with "Shared by [Owner Name]" indicator.

**Acceptance Scenarios**:

1. **Given** a user has access to 3 owned lists and 2 shared lists, **When** they search for "milk", **Then** results include items from all 5 lists
2. **Given** a user views search results, **When** results include items from shared lists, **Then** each item displays "Shared by [Owner Name]" badge or indicator
3. **Given** a user searches for lists, **When** results include both owned and shared lists, **Then** owned lists show "Owner" badge and shared lists show "Shared" badge
4. **Given** a user has viewer-only permission on a shared list, **When** they search and find items in that list, **Then** items are displayed (permissions don't block search, only actions)
5. **Given** a user clicks on a search result from a shared list, **When** they navigate to the list, **Then** appropriate permissions are enforced (viewer can't edit, etc.)

---

### Edge Cases

- **What happens when a user searches for an empty string or only whitespace?**  
  → System treats it as "no search" and displays all lists/items without filtering (default view)

- **What happens when a user searches for special regex characters like ".", "*", "[", "]"?**  
  → System escapes special characters to treat them as literal text. Search for "*" finds items with asterisks in the name

- **What happens when a user searches and API request takes longer than 5 seconds?**  
  → System displays a loading spinner for up to 10 seconds, then shows "Search is taking longer than expected. Please try again." with retry button

- **What happens when a user searches for very long text (500+ characters)?**  
  → System truncates search query to 200 characters and displays warning "Search query too long. Using first 200 characters."

- **What happens when search returns 10,000+ results?**  
  → System limits results to first 1,000 matches and displays "Showing first 1,000 of 10,000+ results. Try a more specific search term."

- **What happens when a user performs multiple rapid searches (typing fast)?**  
  → System debounces input (300ms delay) and cancels previous pending search requests to avoid race conditions and excessive API calls

- **What happens when a user searches while offline?**  
  → System displays "You're offline. Search requires an internet connection." message. Future: search cached data locally

- **What happens when user searches for emojis (e.g., "🍎")?**  
  → System searches for emoji Unicode characters. Items with "🍎 Apples" in name will match

- **What happens when user navigates away during search and returns?**  
  → Search query and results are preserved in URL query parameters. User returns to same search state

- **What happens when a list or item is deleted while user is viewing search results?**  
  → Clicking on deleted item shows "This item has been removed" error. Refreshing search removes it from results

- **What happens when user has permission to view a list but it contains items they can't see?**  
  → All items in accessible lists are searchable. Permissions are list-level, not item-level (per feature 008 specification)

---

## Requirements *(mandatory)*

### Functional Requirements

#### List Search (User Story 1)

- **FR-001**: System MUST allow users to search for lists by name using partial text matching (case-insensitive)
- **FR-002**: System MUST debounce search input with 300ms delay to reduce API calls
- **FR-003**: System MUST support search across both owned lists and lists shared with the user
- **FR-004**: System MUST display "No lists found matching '[query]'" message when no lists match search
- **FR-005**: System MUST provide "Clear Search" button to reset search and display all lists
- **FR-006**: System MUST paginate list search results with 20 items per page
- **FR-007**: System MUST display result count (e.g., "Showing 1-20 of 45 lists")
- **FR-008**: System MUST highlight matching text in list names in search results
- **FR-009**: System MUST preserve search query in URL query parameters for shareable/bookmarkable searches

#### Item Search (User Story 2)

- **FR-010**: System MUST allow users to search for items by name across all accessible lists
- **FR-011**: System MUST search item names and item notes for matching text
- **FR-012**: System MUST display parent list name with each item in search results
- **FR-013**: System MUST display item details in results: name, quantity, category, purchase status, parent list
- **FR-014**: System MUST allow clicking on item result to navigate to parent list with item highlighted
- **FR-015**: System MUST include purchased and unpurchased items in search results
- **FR-016**: System MUST paginate item search results with 20 items per page
- **FR-017**: System MUST display result count (e.g., "Showing 1-20 of 100 items")

#### Combined Search (User Story 3)

- **FR-018**: System MUST support combined search returning both lists and items in one query
- **FR-019**: System MUST group results by type: "Lists (N)" and "Items (M)" with counts
- **FR-020**: System MUST display lists first, followed by items in combined results
- **FR-021**: System MUST provide filter toggle buttons: "All", "Lists only", "Items only"
- **FR-022**: System MUST limit combined search to display all matching lists (up to 20) and first 10 items
- **FR-023**: System MUST provide "Show more items" button in combined view to expand item results

#### Pagination (User Story 4)

- **FR-024**: System MUST display pagination controls when results exceed 20 items
- **FR-025**: System MUST support "Next" and "Previous" buttons for page navigation
- **FR-026**: System MUST display current page number and total pages (e.g., "Page 2 of 5")
- **FR-027**: System MUST allow clicking specific page numbers to jump to that page
- **FR-028**: System MUST preserve pagination state in URL query parameters (e.g., ?page=3)
- **FR-029**: System MUST support infinite scroll as alternative pagination UX (configurable)
- **FR-030**: System MUST display loading indicator when fetching paginated results

#### Highlighting (User Story 5)

- **FR-031**: System MUST highlight matching search terms in list names and item names
- **FR-032**: System MUST highlight matching terms in item notes preview (first 100 characters)
- **FR-033**: System MUST use visually distinct highlighting (yellow background or bold text)
- **FR-034**: System MUST perform case-insensitive highlighting (match "milk" in "MILK")
- **FR-035**: System MUST escape special regex characters in search query before highlighting
- **FR-036**: System MUST support highlighting multiple independent words in multi-word searches

#### Permissions & Shared Content (User Story 6)

- **FR-037**: System MUST search both owned lists and lists shared with the user (all accessible content)
- **FR-038**: System MUST display ownership indicator on search results: "Owner" or "Shared by [Name]"
- **FR-039**: System MUST respect list permissions when user navigates from search result to list detail
- **FR-040**: System MUST include items from shared lists in item search results
- **FR-041**: System MUST NOT expose lists or items the user doesn't have permission to access

#### Search Input & Validation

- **FR-042**: System MUST treat empty or whitespace-only search as "no search" (show all results)
- **FR-043**: System MUST truncate search queries longer than 200 characters and display warning
- **FR-044**: System MUST escape special regex characters (".", "*", "[", "]", etc.) in search queries
- **FR-045**: System MUST support Unicode characters including emojis in search queries
- **FR-046**: System MUST limit total search results to 1,000 items and display "first 1,000 of N+" message

#### Performance & Error Handling

- **FR-047**: System MUST cancel pending search requests when new search is initiated (prevent race conditions)
- **FR-048**: System MUST display loading spinner during search API calls
- **FR-049**: System MUST display timeout error if search takes longer than 10 seconds
- **FR-050**: System MUST display offline error message when network is unavailable
- **FR-051**: System MUST handle deleted items in cached results gracefully (show "Item removed" on click)
- **FR-052**: System SHOULD implement client-side caching of search results for 5 minutes
- **FR-053**: System SHOULD log slow search queries (> 2 seconds) for performance monitoring

### Key Entities

- **Search Query**: Represents a user's search request
  - Query text (1-200 characters)
  - Search scope (lists, items, or both)
  - Pagination parameters (page number, page size)
  - Filter options (lists only, items only)
  - User context (for permission filtering)

- **List Search Result**: Lightweight list representation in search results
  - List ID
  - List name (with highlighted matching text)
  - Description preview (first 100 characters)
  - Owner information (name, ID)
  - Item counts (total, purchased)
  - Ownership indicator (owned vs shared)
  - Last updated timestamp

- **Item Search Result**: Item representation with parent list context
  - Item ID
  - Item name (with highlighted matching text)
  - Quantity and unit
  - Category reference (name, icon, color)
  - Purchase status (purchased/unpurchased)
  - Notes preview (first 100 characters, highlighted if matched)
  - Parent list ID and name
  - Ownership indicator (owned list vs shared list)

- **Combined Search Result**: Container for grouped search results
  - Total lists found (count)
  - Total items found (count)
  - List results (array of List Search Result)
  - Item results (array of Item Search Result)
  - Pagination metadata (page, total pages, total results)
  - Active filters (all/lists only/items only)

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find a specific list among 100+ lists in under 3 seconds using search
- **SC-002**: Users can find a specific item across 50+ lists in under 5 seconds using search
- **SC-003**: Search results appear within 500 milliseconds for databases with up to 10,000 items
- **SC-004**: 95% of search queries return results in under 1 second
- **SC-005**: Search correctly handles 100% of special characters and Unicode (including emojis) without errors
- **SC-006**: Users can navigate through 500+ search results using pagination without performance degradation
- **SC-007**: Search input is debounced, reducing API calls by 80% compared to non-debounced implementation
- **SC-008**: Highlighted search terms are visible and distinguishable in 100% of results
- **SC-009**: Search includes items from shared lists, covering 100% of accessible content for the user
- **SC-010**: Users successfully navigate from search results to list detail pages 100% of the time without errors
- **SC-011**: Search state (query, page, filters) persists across page refreshes via URL parameters
- **SC-012**: Combined search displays both lists and items with clear grouping and counts
- **SC-013**: 90% of users successfully find lists or items on their first search attempt
- **SC-014**: Search handles network errors gracefully with clear error messages and retry options
- **SC-015**: Search performs equally well on mobile devices (< 500ms delay from typing to results)

---

## Assumptions

1. **Search Scope**: Search queries are executed server-side via GET /search endpoint with query parameters
2. **Authentication**: All search requests require authenticated users (JWT token in Authorization header)
3. **Permissions**: Search results are filtered server-side to only include lists/items the user has access to
4. **Search Algorithm**: Uses SQL LIKE operator with wildcards (e.g., %query%) for pattern matching (not full-text search)
5. **Pagination Default**: Default page size is 20 results; maximum page size is 100
6. **Performance Target**: Search endpoint returns results in under 500ms for up to 10,000 items/lists
7. **Caching Strategy**: Search results are NOT cached server-side; client may cache for 5 minutes to reduce API calls
8. **Highlighting**: Implemented client-side using JavaScript to wrap matching text in `<mark>` tags
9. **Debounce Timing**: 300ms debounce delay balances responsiveness and API call reduction
10. **Mobile Experience**: Search UI is fully responsive and works on mobile devices with touch-optimized controls

---

## Dependencies

### Required (Blocking)
- **Feature 001**: User Authentication - Needed for JWT tokens and user identity
- **Feature 003**: Shopping Lists CRUD - Lists must exist to be searchable
- **Feature 004**: List Items Management - Items must exist to be searchable

### Enables (Downstream)
- **Feature 013**: Advanced Search & Filters - Builds on basic search with faceted filtering

---

## Out of Scope

The following are explicitly NOT included in this feature and will be addressed separately:

1. **Advanced filtering** (by category, purchase status, date range, collaborator) - Deferred to Feature 013 (Advanced Search & Filters)
2. **Full-text search** with stemming, synonyms, or fuzzy matching - Basic LIKE pattern matching only
3. **Search suggestions or autocomplete** - Future enhancement for improved UX
4. **Search history or saved searches** - Deferred to Feature 013
5. **Search analytics** (most searched terms, popular items) - Future analytics feature
6. **Offline search** (searching cached data when offline) - Future PWA enhancement
7. **Voice search** (speech-to-text search input) - Future mobile enhancement
8. **Search within specific lists** (scoped search) - Future enhancement; this feature searches all accessible lists
9. **Search for collaborators or users** - Not applicable to current feature scope
10. **Search performance optimization** (Elasticsearch, full-text indexing) - Future scalability enhancement

---

**Specification Status**: Ready for validation and planning  
**Next Steps**: 
1. Run quality validation checklist
2. Resolve any [NEEDS CLARIFICATION] markers (none in this spec)
3. Proceed to `/speckit.plan` for implementation planning
