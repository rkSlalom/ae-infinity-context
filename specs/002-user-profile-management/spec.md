# Feature Specification: User Profile Management

**Feature Branch**: `002-user-profile-management`  
**Created**: 2025-11-05  
**Status**: Draft  
**Input**: User description: "User profile viewing and editing capabilities"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View My Profile (Priority: P1)

A logged-in user wants to see their own profile information including display name, email, avatar, account creation date, and activity statistics. The system displays a comprehensive profile page with all relevant information.

**Why this priority**: Essential for user identity verification and account awareness. Users need to know what information is associated with their account and how they're represented to collaborators.

**Independent Test**: Can be fully tested by logging in, navigating to profile page, and verifying all user data is displayed correctly. Delivers immediate value for account transparency.

**Acceptance Scenarios**:

1. **Given** an authenticated user, **When** they navigate to their profile page, **Then** they see their display name, email, avatar, account creation date, last login time, and email verification status
2. **Given** an authenticated user, **When** they view their profile, **Then** they see activity statistics including total lists owned, lists shared with them, items created, items purchased, and active collaborations
3. **Given** an authenticated user with no avatar set, **When** they view their profile, **Then** they see a default avatar or initials-based placeholder
4. **Given** an authenticated user, **When** profile data loads, **Then** all information is fetched from GET /users/me endpoint
5. **Given** profile data fails to load, **When** API is unreachable, **Then** user sees error message with retry option

---

### User Story 2 - Edit My Profile (Priority: P1)

A user wants to update their display name or avatar to personalize their account and how they appear to collaborators on shared lists. The system validates changes and updates the profile immediately.

**Why this priority**: Critical for user personalization and collaboration transparency. Display name is shown to all collaborators, so users must be able to control this identity.

**Independent Test**: Can be fully tested by updating display name or avatar URL, saving changes, and verifying the update persists across sessions and is visible to collaborators.

**Acceptance Scenarios**:

1. **Given** a user on their profile page, **When** they click "Edit Profile", **Then** they see an editable form with current display name and avatar URL (avatar URL field is empty if user has not set one during registration, which is expected since registration doesn't accept avatarUrl)
2. **Given** a user editing their profile, **When** they change display name (2-100 characters) and click "Save", **Then** changes are saved and reflected immediately in the UI
3. **Given** a user editing their profile, **When** they provide a new avatar URL, **Then** the avatar updates and is visible to all collaborators on shared lists
4. **Given** a user enters invalid display name (less than 2 characters or more than 100), **When** they try to save, **Then** they see validation error "Display name must be 2-100 characters"
5. **Given** a user enters invalid avatar URL format, **When** they try to save, **Then** they see validation error "Please provide a valid image URL"
6. **Given** a user updates their profile, **When** changes are saved, **Then** the updated display name appears in list headers, collaborator lists, and activity feeds
7. **Given** profile update fails, **When** API returns error, **Then** user sees error message and can retry, with form retaining their edits

---

### User Story 3 - View Activity Statistics (Priority: P2)

A user wants to see their usage statistics to understand their engagement with the application, including how many lists they own, collaborate on, and total items created/purchased. The system displays comprehensive metrics.

**Why this priority**: Nice to have for user engagement and gamification potential. Not blocking MVP but enhances user experience and retention.

**Independent Test**: Can be fully tested by creating lists, adding items, marking purchases, and verifying statistics update accurately.

**Acceptance Scenarios**:

1. **Given** a user views their profile, **When** statistics load, **Then** they see total lists owned, total lists shared with them, total items created, total items purchased, active collaborations count, and last activity timestamp
2. **Given** a user creates a new list, **When** they refresh their profile, **Then** "Total Lists Owned" increments by 1
3. **Given** a user is invited to a list, **When** they accept and view profile, **Then** "Total Lists Shared" increments by 1
4. **Given** a user marks an item as purchased, **When** they view profile statistics, **Then** "Total Items Purchased" increments by 1 (if user marks same item as purchased again later, counter increments again - counts purchase events, not unique items)
5. **Given** a new user with no activity, **When** they view statistics, **Then** all counts show 0 and lastActivityAt is null
6. **Given** statistics fail to load, **When** API is unreachable, **Then** user sees "Statistics unavailable" message without breaking the profile page

---

### User Story 4 - View Other Users' Public Profiles (Priority: P3)

When viewing collaborators on shared lists, a user wants to click on a collaborator's name to see their public profile (display name, avatar, join date, public statistics). The system shows limited, privacy-respecting information.

**Why this priority**: Enhances collaboration transparency but not essential for MVP. Can be deferred to later phase.

**Independent Test**: Can be fully tested by viewing a shared list, clicking on a collaborator's name, and seeing their public profile information.

**Acceptance Scenarios**:

1. **Given** a user views a shared list, **When** they click on a collaborator's display name, **Then** they are navigated to that user's public profile page
2. **Given** a user views another user's public profile, **When** page loads, **Then** they see display name, avatar, account creation date (not email or sensitive data)
3. **Given** a user views another user's public profile, **When** statistics are visible, **Then** they see public metrics like "Active on X lists" and "Member since [date]" (not full statistics)
4. **Given** a user tries to view profile of non-existent user, **When** they navigate to invalid user ID, **Then** they see "User not found" error page
5. **Given** privacy settings (future), **When** a user has restricted their profile visibility, **Then** other users see minimal information or "Profile private" message

---

### Edge Cases

- **What happens when** a user updates their display name to one already used by another user?  
  → System allows duplicate display names (display name is not unique identifier). Only email must be unique.

- **What happens when** a user who just registered wants to set their avatar?  
  → Users cannot set avatar during registration (feature 001). They must edit their profile (feature 002) to add an avatar URL. This is by design to keep registration flow simple and focused.

- **What happens when** a user provides an avatar URL that points to a broken/missing image?  
  → Frontend shows fallback placeholder avatar. No server-side validation of image availability (performance trade-off).

- **What happens when** a user tries to edit another user's profile?  
  → API enforces authorization - users can only update their own profile via PATCH /users/me. Attempting to modify /users/{otherId} returns 403 Forbidden.

- **What happens when** profile update conflicts with concurrent session?  
  → Last write wins (optimistic concurrency). If user has multiple tabs open, most recent save overwrites previous changes.

- **What happens when** statistics calculation is slow or times out?  
  → Statistics load asynchronously with loading indicator. If timeout occurs, show "Statistics temporarily unavailable" without blocking profile view.

- **What happens when** a user clears their avatar URL (sets to null)?  
  → System accepts null avatarUrl and displays default avatar placeholder (initials or icon).

- **What happens when** display name contains special characters or emojis?  
  → System accepts Unicode characters including emojis (validated max length is character count, not bytes).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow authenticated users to view their own complete profile via GET /users/me endpoint
- **FR-002**: System MUST display user profile fields: id, email, displayName, avatarUrl, isEmailVerified, lastLoginAt, createdAt
- **FR-003**: System MUST allow authenticated users to update their own display name via PATCH /users/me endpoint
- **FR-004**: System MUST allow authenticated users to update their own avatar URL via PATCH /users/me endpoint
- **FR-005**: System MUST validate display name length: minimum 2 characters, maximum 100 characters
- **FR-006**: System MUST validate avatar URL format when provided (valid URI with max 500 characters), but allow null values (null clears existing avatar)
- **FR-007**: System MUST accept displayName with Unicode characters including emojis (character count, not byte length)
- **FR-008**: System MUST enforce authorization: users can only update their own profile (not other users')
- **FR-009**: System MUST provide user activity statistics via dedicated endpoint GET /api/users/me/stats (separate from profile endpoint for independent caching and graceful degradation)
- **FR-010**: System MUST calculate statistics:
  - **totalListsOwned**: Count of lists where user is owner
  - **totalListsShared**: Count of lists where user is collaborator (not owner)
  - **totalItemsCreated**: Sum of items created by user across all lists
  - **totalItemsPurchased**: Sum of purchase events by user (each time user marks any item as purchased, regardless if same item marked multiple times)
  - **totalActiveCollaborations**: Count of non-archived lists where user is collaborator
- **FR-011**: System MUST track lastActivityAt timestamp for user engagement metrics (computed as maximum of: User.lastLoginAt, User.updatedAt, max createdAt across user's lists and items)
- **FR-012**: System MUST cache statistics with 5-minute TTL (Time To Live), with immediate cache invalidation when user performs actions that affect their own statistics (create list, add item, mark purchased)
- **FR-013**: Frontend MUST display editable profile form with current values pre-populated
- **FR-014**: Frontend MUST show validation errors inline next to the relevant form field
- **FR-015**: Frontend MUST display loading indicator while profile data is being fetched
- **FR-016**: Frontend MUST show fallback placeholder when avatarUrl is null or image fails to load
- **FR-017**: Frontend MUST update UI immediately after successful profile update (optimistic update optional)
- **FR-018**: Frontend MUST display user's display name and avatar in application header/navigation
- **FR-019**: System SHOULD support viewing other users' public profiles via GET /users/{userId} (minimal information only)
- **FR-020**: System SHOULD restrict public profile to non-sensitive fields: displayName, avatarUrl, createdAt (exclude email)
- **FR-021**: System MUST return 404 Not Found when requesting profile of non-existent user
- **FR-022**: System MUST return 403 Forbidden when user attempts to update another user's profile
- **FR-023**: System MUST log profile update events for audit purposes
- **FR-024**: System SHOULD cache statistics to avoid expensive database queries on every profile view

### Key Entities

- **User Profile**: Extended view of User entity with additional computed fields
  - Core fields: id, email, displayName, avatarUrl, isEmailVerified, lastLoginAt, createdAt
  - Computed fields: activity statistics
  - Relationships: Linked to all User-owned lists and collaborations

- **User Statistics**: Aggregated metrics about user engagement
  - Total lists owned (count of lists where user is owner)
  - Total lists shared (count of lists where user is collaborator but not owner)
  - Total items created (sum of items created by user across all lists)
  - Total items purchased (sum of items marked purchased by user)
  - Total active collaborations (count of non-archived lists where user collaborates)
  - Last activity timestamp (most recent action by user)

- **Profile Update Request**: Request payload for updating profile
  - displayName: string (2-100 chars, required)
  - avatarUrl: string | null (valid URI, optional)

- **Public User Profile**: Limited view of user information for other users
  - displayName, avatarUrl, createdAt only
  - No email, no personal statistics, no sensitive data

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their complete profile information in under 2 seconds from navigation
- **SC-002**: Users can update their display name or avatar in under 5 seconds including validation and save
- **SC-003**: 100% of profile updates persist across sessions and browser restarts
- **SC-004**: Profile changes are visible to collaborators within 10 seconds of update (real-time sync)
- **SC-005**: User activity statistics update within 5 minutes of relevant actions, with immediate cache invalidation for the user's own actions
- **SC-006**: Form validation provides immediate feedback within 200 milliseconds of user input
- **SC-007**: Profile page loads successfully even if statistics fail to load (graceful degradation)
- **SC-008**: Users with slow connections see loading indicators within 100 milliseconds of page load
- **SC-009**: Display name changes reflect immediately in all UI locations (header, lists, activity feeds)
- **SC-010**: Avatar images load with fallback placeholder if source URL is invalid or unavailable
- **SC-011**: 100% of profile update requests require valid authentication token (no unauthorized updates)
- **SC-012**: Users cannot modify other users' profiles (authorization enforced at API level)
- **SC-013**: Profile update errors display user-friendly messages with actionable guidance
- **SC-014**: Statistics queries complete in under 500 milliseconds even for users with 100+ lists

