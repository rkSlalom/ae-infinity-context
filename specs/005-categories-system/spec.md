# Feature Specification: Categories System

**Feature Branch**: `005-categories-system`  
**Created**: 2025-11-05  
**Status**: Consolidation from existing documentation  
**Current Implementation**: Backend 100%, Frontend 100%, Integration 0%

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Default Categories (Priority: P1)

A new user wants to organize their shopping items using pre-defined categories (Produce, Dairy, Meat, etc.) so they can quickly categorize items without setup. The system provides 10 default categories with meaningful icons and colors.

**Why this priority**: Foundation for item organization. Without categories, items lack structure and grouping capabilities. Must be available before items can be categorized.

**Independent Test**: Can be fully tested by retrieving the category list, verifying all 10 default categories are displayed with correct icons and colors. Delivers immediate value for item organization.

**Acceptance Scenarios**:

1. **Given** a user accesses the category list, **When** they request categories, **Then** they see 10 default categories (Produce, Dairy, Meat, Seafood, Bakery, Frozen, Beverages, Snacks, Household, Personal Care)
2. **Given** a user views default categories, **When** categories load, **Then** each category displays with unique emoji icon and hex color code
3. **Given** a user is on the create/edit item form, **When** they select a category, **Then** default categories appear in the dropdown with icons and colors
4. **Given** a user requests categories without being logged in, **When** they access the system, **Then** they can view all default categories
5. **Given** a new system installation, **When** system first starts, **Then** default categories are automatically available without user action

---

### User Story 2 - Create Custom Category (Priority: P1)

A user wants to create their own category (e.g., "Pet Supplies", "Garden", "Baby Items") to organize items in a way that matches their personal shopping needs. The system validates and stores user-specific categories.

**Why this priority**: Essential for personalization and flexibility. Users have diverse shopping needs beyond default categories. Enables custom organization patterns.

**Independent Test**: Can be fully tested by creating a category with name, icon, and color, verifying the category is saved, and confirming it appears in the user's category list.

**Acceptance Scenarios**:

1. **Given** an authenticated user, **When** they create a category with valid name, icon (emoji), and color (hex), **Then** the custom category is saved and associated with their account
2. **Given** a user enters category name "Pet Supplies", **When** they submit with icon "🐾" and color "#8B4513", **Then** the category is created and immediately available in item forms
3. **Given** a user creates a custom category, **When** they view their category list, **Then** they see both default categories and their custom categories
4. **Given** a user enters duplicate category name (case-insensitive), **When** they try to create it, **Then** they see error "A category with this name already exists"
5. **Given** a user enters invalid category name (empty or > 50 chars), **When** they submit, **Then** they see validation error "Category name must be 1-50 characters"
6. **Given** a user provides invalid icon (not a single emoji), **When** they submit, **Then** they see error "Icon must be a valid emoji character"
7. **Given** a user provides invalid color format (not hex), **When** they submit, **Then** they see error "Color must be a valid hex code (e.g., #FF5733)"

---

### User Story 3 - Filter Categories (Priority: P2)

A user wants to view only default categories or only their custom categories to reduce clutter when selecting categories for items. The system supports filtering via query parameters.

**Why this priority**: Improves usability for users with many custom categories. Not blocking MVP but enhances user experience when category lists grow large.

**Independent Test**: Can be fully tested by toggling filter options between "defaults only" and "all categories", and verifying the correct categories are displayed.

**Acceptance Scenarios**:

1. **Given** a user selects "defaults only" filter, **When** categories load, **Then** only default system categories are displayed
2. **Given** a user selects "all categories" filter (or no filter), **When** categories load, **Then** both default and custom categories are displayed
3. **Given** a user has created 5 custom categories, **When** they view all categories, **Then** they see 15 categories total (10 default + 5 custom)
4. **Given** a user has no custom categories, **When** they view all categories, **Then** they see only 10 default categories

---

### User Story 4 - Assign Categories to Items (Priority: P1)

A user wants to assign a category to each shopping item so they can visually organize and filter items by category in their lists. The system displays category badge with icon and color on each item.

**Why this priority**: Core value proposition of categories - organizing items. Must work with item management for meaningful user experience.

**Independent Test**: Can be fully tested by creating an item with a categoryId, verifying the category displays on the item, and testing that items can be filtered by category.

**Acceptance Scenarios**:

1. **Given** a user creates or edits an item, **When** they select a category from dropdown, **Then** the categoryId is saved with the item
2. **Given** a user views an item, **When** item has assigned category, **Then** they see category badge with icon, name, and color
3. **Given** a user views a list, **When** items have different categories, **Then** each item displays its category badge for visual grouping
4. **Given** a user assigns category "Produce 🥬" to "Apples", **When** viewing the item, **Then** badge shows green color (#4CAF50) with produce icon
5. **Given** a user removes category from item (sets to null), **When** item is saved, **Then** no category badge displays

---

### User Story 5 - Filter List Items by Category (Priority: P2)

A user viewing a shopping list wants to filter items by category (e.g., show only "Produce" items) so they can shop section by section in the store. The system filters items instantly by the selected category.

**Why this priority**: Enhances shopping efficiency and user experience. Not critical for MVP but significantly improves usability for longer lists.

**Independent Test**: Can be fully tested by selecting a category filter, verifying only items with that category are displayed, and confirming "All Categories" shows all items.

**Acceptance Scenarios**:

1. **Given** a user views a list with items in multiple categories, **When** they select "Produce" filter, **Then** only produce items are displayed
2. **Given** a user applies category filter, **When** they select "All Categories", **Then** all items are displayed regardless of category
3. **Given** a user filters by "Dairy", **When** no items match, **Then** they see "No dairy items in this list" message
4. **Given** a list with 20 items across 5 categories, **When** user filters by category, **Then** filter updates instantly without delay
5. **Given** filtered view, **When** user adds new item with matching category, **Then** new item appears in filtered list immediately

---

### Edge Cases

- **What happens when** a user deletes a custom category that is assigned to items?  
  → System prevents deletion if category is in use. Alternative: mark as deleted but keep reference, or reassign items to "Uncategorized" default.

- **What happens when** a user creates custom category with same name as default category?  
  → System allows it (unique constraint is per user). User's "Produce" custom category can coexist with default "Produce" (different IDs).

- **What happens when** two users both create "Pet Supplies" category?  
  → Each user has their own custom categories (scoped to their account). No conflict - categories are personal to each user.

- **What happens when** a user provides emoji sequence (👨‍👩‍👧‍👦) instead of single emoji?  
  → System accepts it (Unicode sequences are valid). Display may vary inconsistently across different devices and platforms (documented limitation).

- **What happens when** categories list grows to 100+ custom categories?  
  → System displays all categories. Search/filter functionality in category picker recommended for better usability (future enhancement).

- **What happens when** default categories are missing after installation?  
  → System automatically restores default categories on startup. If manually removed, re-initialization restores them.

- **What happens when** a user requests categories and system is unreachable?  
  → Application displays previously loaded categories if available, or shows error message with retry option. Items default to "Uncategorized" if categories cannot load.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide 10 default categories on initialization: Produce, Dairy, Meat, Seafood, Bakery, Frozen, Beverages, Snacks, Household, Personal Care
- **FR-002**: System MUST automatically make default categories available on first use without user action
- **FR-003**: System MUST allow authenticated users to create custom categories
- **FR-004**: System MUST validate category name: 1-50 characters, required, unique per user (case-insensitive)
- **FR-005**: System MUST validate category icon: required, must be valid emoji character (Unicode)
- **FR-006**: System MUST validate category color: required, valid hex color format (#RRGGBB or #RGB)
- **FR-007**: System MUST associate custom categories with the user who created them
- **FR-008**: System MUST allow non-authenticated users to view default categories
- **FR-009**: System MUST allow authenticated users to view both default and custom categories
- **FR-010**: System MUST support filtering categories: show defaults only, or show all categories
- **FR-011**: System MUST provide category information including: unique identifier, name, icon, color, default flag, and creator
- **FR-012**: System MUST prevent duplicate category names per user (case-insensitive comparison)
- **FR-013**: System MUST display validation errors when category creation fails
- **FR-014**: System MUST confirm successful category creation and display the new category
- **FR-015**: System MUST display category picker in item create/edit forms with icons and colors
- **FR-016**: System MUST display category badge on items showing icon, name, and color
- **FR-017**: System MUST load categories when application starts and keep them available during the session
- **FR-018**: System MUST allow users to filter list items by category
- **FR-019**: System MUST provide "Create Category" option in category picker for custom categories
- **FR-020**: System MUST validate category creation form before submission
- **FR-021**: System SHOULD prevent deletion of categories assigned to items (maintain data integrity)
- **FR-022**: System SHOULD log category creation events for audit purposes
- **FR-023**: System SHOULD provide search/filter in category picker when list exceeds 20 categories

### Key Entities

- **Category**: Represents a classification for shopping items
  - Unique identifier (GUID/UUID)
  - Name (1-50 characters, unique per user)
  - Icon (emoji, single character or sequence)
  - Color (hex code, e.g., #4CAF50)
  - IsDefault flag (true for system categories, false for user-created)
  - Creator reference (null for default categories, userId for custom)
  - Relationships: Assigned to items (one-to-many)

- **Default Categories**: System-provided categories seeded on initialization
  - Produce (🥬, #4CAF50) - Fruits and vegetables
  - Dairy (🥛, #2196F3) - Milk, cheese, yogurt
  - Meat (🥩, #F44336) - Meat and poultry
  - Seafood (🐟, #00BCD4) - Fish and seafood
  - Bakery (🍞, #FF9800) - Bread and baked goods
  - Frozen (❄️, #03A9F4) - Frozen foods
  - Beverages (🥤, #9C27B0) - Drinks
  - Snacks (🍿, #FF5722) - Chips, candy, snacks
  - Household (🧼, #607D8B) - Cleaning supplies
  - Personal Care (🧴, #E91E63) - Hygiene products

- **Category Reference**: Lightweight reference used in item objects
  - Category ID
  - Name
  - Icon
  - Color

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view all available categories (default + custom) in under 1 second from application load
- **SC-002**: Users can create a custom category in under 10 seconds including validation and save
- **SC-003**: 100% of default categories are automatically available after system installation
- **SC-004**: Category picker displays with icons and colors for visual recognition
- **SC-005**: Users can filter list items by category with instant results (under 100 milliseconds)
- **SC-006**: Category validation errors appear within 200 milliseconds of form submission
- **SC-007**: Custom categories persist across sessions and are visible in all user's lists
- **SC-008**: Category badges on items display correctly with icon, name, and color
- **SC-009**: 95% of category operations complete in under 300 milliseconds
- **SC-010**: Category name uniqueness enforced - zero duplicate categories per user
- **SC-011**: Category creation form validates all fields before submission
- **SC-012**: Users with 50+ categories can still navigate category picker efficiently
- **SC-013**: Items without category gracefully display "Uncategorized" or no badge
- **SC-014**: System handles emoji sequences and special Unicode characters without errors


