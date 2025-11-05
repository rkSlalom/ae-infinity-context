# Implementation Tasks: User Profile Management

**Feature**: 002-user-profile-management  
**Branch**: `002-user-profile-management`  
**Created**: 2025-11-05  
**Current Status**: 0% (specification complete, ready for implementation)  
**Target**: Complete profile viewing, editing, and statistics with real-time updates

---

## Task Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| Phase 1: Setup | 2 tasks | Environment verification |
| Phase 2: Foundation | 7 tasks | DTOs, caching service, domain events |
| Phase 3: US1+US2 - View/Edit Profile | 18 tasks | Profile page and edit functionality (P1) |
| Phase 4: US3 - Statistics | 9 tasks | Activity statistics calculation and display (P2) |
| Phase 5: US4 - Public Profiles | 7 tasks | Public profile viewing (P3 - optional) |
| Phase 6: Integration | 5 tasks | SignalR, Header updates, real-time sync |
| Phase 7: Polish | 4 tasks | Performance, monitoring, security audit |
| **Total** | **52 tasks** | Estimated: 8-10 days (P1+P2), +2 days (P3) |

---

## Implementation Strategy

### MVP Scope (Days 1-5)
Complete **P1 user stories** only:
- ✅ US1: View My Profile (profile page with data display)
- ✅ US2: Edit My Profile (update display name + avatar)

**MVP Deliverable**: Users can view and edit their profiles with validation and immediate UI updates.

### Phase 2 Scope (Days 6-8)
Add **P2 user story**:
- 🔨 US3: View Activity Statistics (engagement metrics with caching)

### Optional Scope (Days 9-10)
- 📋 US4: View Public Profiles (P3 - deferrable)

---

## Dependency Graph

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundation - DTOs, Caching, Events) ← BLOCKING for all user stories
    ↓
    ├── Phase 3 (US1+US2 - View/Edit Profile) [P1 - Must have]
    │   ├── Backend: Command, Handler, Validator, Endpoint
    │   ├── Frontend: ProfilePage, ProfileEditForm, AvatarImage
    │   └── Tests: Unit, Integration, Component
    │
    ├── Phase 4 (US3 - Statistics) [P2 - Should have, can parallelize with Phase 3]
    │   ├── Backend: Query, Handler, Caching
    │   ├── Frontend: UserStats component
    │   └── Tests: Unit, Integration, Component
    │
    └── Phase 5 (US4 - Public Profiles) [P3 - Optional, depends on Phase 3]
        ├── Backend: Query, Handler
        ├── Frontend: PublicProfilePage
        └── Tests: Unit, Integration, Component
    ↓
Phase 6 (Integration - SignalR, Real-time) ← Needs Phase 3 complete
    ↓
Phase 7 (Polish - Performance, Monitoring)
```

**Key Dependencies**:
- Phase 2 MUST complete before any user story work (DTOs, caching foundation)
- US1+US2 combined into Phase 3 (naturally go together: view → edit)
- US3 (Statistics) can be implemented in parallel with Phase 3 after Phase 2
- US4 (Public Profiles) depends on Phase 3 (reuses profile display components)
- Phase 6 (Integration) needs US1+US2 complete for SignalR ProfileUpdated event
- All user stories are independently testable

---

## Phase 1: Setup & Prerequisites

**Goal**: Verify development environment and dependencies

**Duration**: 15 minutes

### Tasks

- [X] T001 Verify .NET 9.0 SDK installed, ae-infinity-api solution builds, and Feature 001 (User Authentication) is complete with GET /users/me endpoint working

- [X] T002 Verify Node.js 18+, npm installed, ae-infinity-ui builds, and can authenticate users to test profile features

---

## Phase 2: Foundation - DTOs, Caching, and Domain Events

**Goal**: Create shared infrastructure needed by all user stories

**Why**: All profile features need DTOs for API contracts, statistics needs caching service, real-time updates need domain events.

**Duration**: 2-3 hours

### Tasks

#### DTOs

- [X] T003 [P] Create UpdateProfileDto in ae-infinity-api/AeInfinity.Application/Users/DTOs/UpdateProfileDto.cs with properties: DisplayName (string), AvatarUrl (string?) *(already existed as UpdateUserProfileRequest)*

- [X] T004 [P] Create UserStatsDto in ae-infinity-api/AeInfinity.Application/Users/DTOs/UserStatsDto.cs with properties: TotalListsOwned, TotalListsShared, TotalItemsCreated, TotalItemsPurchased, TotalActiveCollaborations, LastActivityAt *(already existed)*

- [X] T005 [P] Create PublicUserProfileDto in ae-infinity-api/AeInfinity.Application/Users/DTOs/PublicUserProfileDto.cs with properties: Id, DisplayName, AvatarUrl, CreatedAt (for P3)

#### Caching Service

- [X] T006 [P] Create ICacheService interface in ae-infinity-api/AeInfinity.Application/Common/Interfaces/ICacheService.cs with methods: GetAsync<T>, SetAsync<T>, RemoveAsync

- [X] T007 Create MemoryCacheService implementation in ae-infinity-api/AeInfinity.Infrastructure/Services/MemoryCacheService.cs using IMemoryCache with TTL support

#### Domain Events

- [X] T008 [P] Create ProfileUpdatedEvent in ae-infinity-api/AeInfinity.Domain/Events/ProfileUpdatedEvent.cs with properties: UserId, DisplayName, AvatarUrl, UpdatedAt

- [X] T009 Create ProfileUpdatedNotification and ProfileUpdatedEventHandler in ae-infinity-api/AeInfinity.Api/EventHandlers/ to broadcast SignalR ProfileUpdated event to all connected clients

**Validation**: Verify all files compile, DTOs are accessible, MemoryCacheService registered in DI container

---

## Phase 3: US1+US2 - View and Edit Profile *(Priority: P1)*

**User Stories**: 
- US1: A logged-in user wants to see their profile information
- US2: A user wants to update their display name or avatar

**Current Status**: Backend ❌ Missing (PATCH /users/me), Frontend ❌ Missing, Tests ❌ Missing

**Independent Test**: 
- US1: GET /users/me returns profile with all fields, frontend displays data correctly
- US2: Update display name/avatar via form, save, verify persistence and real-time update to collaborators

**Duration**: 4-5 hours

### Tasks

#### Backend Implementation

- [X] T010 [US1+US2] Create UpdateProfileCommand in ae-infinity-api/AeInfinity.Application/Users/Commands/UpdateProfile/UpdateProfileCommand.cs with properties: UserId (from JWT), DisplayName, AvatarUrl *(already existed)*

- [X] T011 [US1+US2] Create UpdateProfileCommandValidator using FluentValidation in ae-infinity-api/AeInfinity.Application/Users/Commands/UpdateProfile/UpdateProfileCommandValidator.cs (validate: DisplayName 2-100 chars, AvatarUrl valid URI or null) *(already existed)*

- [X] T012 [US1+US2] Create UpdateProfileCommandHandler in ae-infinity-api/AeInfinity.Application/Users/Commands/UpdateProfile/UpdateProfileCommandHandler.cs (fetch user, update DisplayName/AvatarUrl, save, publish ProfileUpdatedNotification, return UserDto) *(updated to publish notification)*

- [X] T013 [US1+US2] Add PATCH /users/me endpoint to ae-infinity-api/AeInfinity.API/Controllers/UsersController.cs (extract UserId from JWT claims, map UpdateProfileDto to command, return 200 with UserDto) *(changed from PUT to PATCH)*

#### Backend Tests

- [ ] T014 [P] [US1+US2] Write unit tests for UpdateProfileCommandHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Users/UpdateProfileCommandHandlerTests.cs (test: valid update, null avatar clears it, user not found, display name validation)

- [ ] T015 [P] [US1+US2] Write unit tests for UpdateProfileCommandValidator in ae-infinity-api/tests/AeInfinity.Application.Tests/Users/UpdateProfileCommandValidatorTests.cs (test: min/max length, invalid URL, null URL allowed)

- [ ] T016 [P] [US1+US2] Write integration test for PATCH /users/me in ae-infinity-api/tests/AeInfinity.API.IntegrationTests/UsersControllerTests.cs (test: 200 success, 400 validation errors, 401 no token, 403 attempt to edit other user)

#### Frontend Implementation

- [X] T017 [P] [US1+US2] Create ProfilePage component in ae-infinity-ui/src/pages/profile/Profile.tsx (display user info, avatar, account details, toggle edit mode) *(already existed)*

- [X] T018 [P] [US1+US2] Create ProfileEditForm component in ae-infinity-ui/src/pages/profile/ProfileSettings.tsx (form with displayName/avatarUrl inputs, validation, save button) *(updated existing ProfileSettings.tsx)*

- [X] T019 [P] [US1+US2] Create AvatarImage component (display avatar with fallback to initials if URL broken or null) *(inline implementation in Profile.tsx and ProfileSettings.tsx)*

- [X] T020 [US1+US2] Create useProfile custom hook in ae-infinity-ui/src/hooks/useProfile.ts (updateProfile function, loading/error states)

- [X] T021 [US1+US2] Create usersService in ae-infinity-ui/src/services/usersService.ts (updateUserProfile: PATCH /users/me, getCurrentUser: GET /users/me, getUserStats: GET /users/me/stats)

- [X] T022 [US1+US2] Add /profile route in ae-infinity-ui/src/App.tsx and link from Header component (user avatar + name in header links to /profile) *(already existed)*

#### Frontend Tests

- [ ] T023 [P] [US1+US2] Write component tests for ProfilePage in ae-infinity-ui/tests/features/profile/ProfilePage.test.tsx (test: renders user data, shows edit button, switches to edit mode)

- [ ] T024 [P] [US1+US2] Write component tests for ProfileEditForm in ae-infinity-ui/tests/features/profile/ProfileEditForm.test.tsx (test: validation errors display, save button calls updateProfile, cancel button discards changes)

- [ ] T025 [P] [US1+US2] Write component tests for AvatarImage in ae-infinity-ui/tests/features/profile/AvatarImage.test.tsx (test: displays image URL, fallback to initials on error, null URL shows initials)

#### Verification

- [ ] T026 [US1+US2] Manual test: Login, navigate to /profile, verify all user data displayed (name, email, avatar, dates, email verification status)

- [ ] T027 [US1+US2] Manual test: Click "Edit Profile", change display name to "New Name 🎉", save, verify update persists and reflects in Header component

**Acceptance Criteria** (from spec.md):
- ✅ US1: Profile page displays all user fields (id, email, displayName, avatarUrl, timestamps)
- ✅ US1: Default avatar/initials shown if avatarUrl is null
- ✅ US2: Edit form pre-populated with current values
- ✅ US2: Display name validated (2-100 chars, Unicode/emoji support)
- ✅ US2: Avatar URL validated (valid URI or null)
- ✅ US2: Inline validation errors next to fields
- ✅ US2: Save button updates profile and shows success message
- ✅ US2: Avatar fallback works for broken URLs

---

## Phase 4: US3 - View Activity Statistics *(Priority: P2)*

**User Story**: A user wants to see their usage statistics (lists, items, collaborations)

**Current Status**: Backend ❌ Missing, Frontend ❌ Missing, Tests ❌ Missing

**Independent Test**: Create lists and items, mark purchases, refresh profile, verify statistics display accurate counts and update when activity changes.

**Duration**: 3-4 hours

### Tasks

#### Backend Implementation

- [X] T028 [US3] Create GetUserStatsQuery in ae-infinity-api/AeInfinity.Application/Features/Statistics/Queries/GetUserStats/GetUserStatsQuery.cs with property: UserId (from JWT) *(already existed)*

- [X] T029 [US3] Create GetUserStatsQueryHandler in ae-infinity-api/AeInfinity.Application/Features/Statistics/Queries/GetUserStats/GetUserStatsQueryHandler.cs (calculate statistics via LINQ queries, return UserStatsDto) *(already existed, caching to be added)*

- [X] T030 [US3] Add GET /users/me/stats endpoint to ae-infinity-api/AeInfinity.API/Controllers/StatsController.cs (extract UserId from JWT, query statistics, return 200 with UserStatsDto) *(already existed)*

- [ ] T031 [US3] Add cache invalidation to relevant command handlers (CreateListCommand, CreateItemCommand, MarkItemPurchasedCommand) to call _cacheService.RemoveAsync($"user-stats:{userId}") after successful operations *(optional enhancement)*

#### Backend Tests

- [ ] T032 [P] [US3] Write unit tests for GetUserStatsQueryHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Users/GetUserStatsQueryHandlerTests.cs (test: calculate all metrics correctly, cache hit returns cached value, new user has zero stats)

- [ ] T033 [P] [US3] Write integration test for GET /users/me/stats in ae-infinity-api/tests/AeInfinity.API.IntegrationTests/UsersControllerTests.cs (test: 200 success with statistics, 401 no token, cached vs uncached performance)

#### Frontend Implementation

- [X] T034 [P] [US3] Create UserStats component in ae-infinity-ui/src/components/profile/UserStats.tsx (display 6 statistics metrics in card layout, loading indicator, error fallback "Statistics unavailable", refresh button)

- [X] T035 [US3] Create useUserStats custom hook in ae-infinity-ui/src/hooks/useUserStats.ts (fetchStats function, loading/error states, refetch capability)

- [X] T036 [US3] Integrate UserStats component into Profile.tsx, fetch statistics asynchronously (profile loads even if stats fail - graceful degradation)

#### Frontend Tests

- [ ] T037 [P] [US3] Write component tests for UserStats in ae-infinity-ui/tests/features/profile/UserStats.test.tsx (test: renders all metrics, shows loading state, shows error fallback, refetch on button click)

#### Verification

- [ ] T038 [US3] Manual test: View profile, verify statistics displayed with correct counts, create new list, refresh (via refresh button), verify "Total Lists Owned" incremented

**Acceptance Criteria** (from spec.md):
- ✅ Statistics display: totalListsOwned, totalListsShared, totalItemsCreated, totalItemsPurchased, totalActiveCollaborations, lastActivityAt
- ✅ Statistics update within 60 seconds of user actions (via cache invalidation)
- ✅ Queries complete in < 500ms even for users with 100+ lists (caching helps)
- ✅ Statistics load asynchronously (profile page doesn't block)
- ✅ Error fallback displays "Statistics unavailable" without breaking page

---

## Phase 5: US4 - View Other Users' Public Profiles *(Priority: P3 - Optional)*

**User Story**: When viewing collaborators, a user wants to see their public profile (limited information)

**Current Status**: Backend ❌ Missing, Frontend ❌ Missing, Tests ❌ Missing

**Independent Test**: View shared list with collaborators, click collaborator name, navigate to public profile page showing displayName, avatar, createdAt (no email, no full statistics).

**Duration**: 2-3 hours

### Tasks

#### Backend Implementation

- [ ] T039 [US4] Create GetUserByIdQuery in ae-infinity-api/AeInfinity.Application/Users/Queries/GetUserById/GetUserByIdQuery.cs with property: UserId (target user to view)

- [ ] T040 [US4] Create GetUserByIdQueryHandler in ae-infinity-api/AeInfinity.Application/Users/Queries/GetUserById/GetUserByIdQueryHandler.cs (fetch user, map to PublicUserProfileDto with limited fields only, return 404 if not found)

- [ ] T041 [US4] Add GET /users/{userId} endpoint to ae-infinity-api/AeInfinity.API/Controllers/UsersController.cs (validate userId format, query public profile, return 200 with PublicUserProfileDto)

#### Backend Tests

- [ ] T042 [P] [US4] Write unit tests for GetUserByIdQueryHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Users/GetUserByIdQueryHandlerTests.cs (test: returns public data only, 404 for non-existent user, no email exposed)

- [ ] T043 [P] [US4] Write integration test for GET /users/{userId} in ae-infinity-api/tests/AeInfinity.API.IntegrationTests/UsersControllerTests.cs (test: 200 success with limited fields, 404 for invalid ID, 401 no token)

#### Frontend Implementation

- [ ] T044 [P] [US4] Create PublicProfilePage component in ae-infinity-ui/src/features/profile/PublicProfilePage.tsx (display public profile: displayName, avatar, createdAt, "Member since" text, no email)

- [ ] T045 [US4] Add /users/:userId route in ae-infinity-ui/src/App.tsx and add links from collaborator names in list views to /users/:userId

#### Verification

- [ ] T046 [US4] Manual test: View shared list, click collaborator name, navigate to public profile, verify only displayName, avatar, createdAt displayed (no email, no full statistics)

**Acceptance Criteria** (from spec.md):
- ✅ Public profile shows: displayName, avatar, createdAt only
- ✅ Public profile excludes: email, full statistics, sensitive data
- ✅ Returns 404 for non-existent user
- ✅ Navigable from collaborator names in list views

**Note**: This phase is optional (P3). Can be deferred to post-MVP if time constrained.

---

## Phase 6: Integration - Real-time Updates and UI Sync

**Goal**: Connect profile updates to SignalR for real-time collaboration, update Header when profile changes

**Duration**: 2-3 hours

### Tasks

#### SignalR Integration

- [X] T047 Update ShoppingListHub in ae-infinity-api/AeInfinity.Api/Hubs/ShoppingListHub.cs - ProfileUpdatedEventHandler broadcasts ProfileUpdated event to all connected clients via SignalR

- [X] T048 Add SignalR listener in ae-infinity-ui/src/hooks/useProfileSync.ts to subscribe to ProfileUpdated event and update current user state if the updated userId matches authenticated user

#### Header Component Updates

- [X] T049 Update Header component in ae-infinity-ui/src/components/layout/Header.tsx to display user avatar and display name, with avatar fallback to initials, linked to /profile page

- [X] T050 Add real-time update handler in Header via useProfileSync hook to refresh avatar/name when ProfileUpdated event received for current user

#### Verification

- [X] T051 Manual test: Open app in two browser tabs logged in as same user, edit profile in tab 1, verify Header updates immediately in tab 2 without refresh (via SignalR) ✅ VERIFIED - Real-time sync working perfectly!

**Acceptance Criteria** (from spec.md):
- ✅ Profile changes visible to collaborators within 10 seconds (SignalR broadcast)
- ✅ Header displays user avatar and display name
- ✅ Header updates when profile changes (real-time sync)
- ✅ Display name changes reflect in list headers, collaborator lists, activity feeds

---

## Phase 7: Polish & Production Readiness

**Goal**: Performance optimization, monitoring, security audit

**Duration**: 2-3 hours

### Tasks

#### Performance Optimization

- [X] T052 Add performance logging to GetUserStatsQueryHandler with Stopwatch, cache integration (5min TTL), warn if > 500ms, log cache hits/misses, track query performance

#### Monitoring & Logging

- [X] T053 Add structured logging for profile update events in UpdateProfileCommandHandler (logs: userId, displayName changed with old/new values, avatarUrl changed, success/failure with try-catch)

#### Security Audit

- [X] T054 Review authorization enforcement: ✅ UsersController extracts UserId from JWT claims (ClaimTypes.NameIdentifier), ✅ users cannot update other users' profiles (userId from token only), ✅ no admin override endpoints

#### Documentation

- [X] T055 Created comprehensive API_USER_PROFILE.md with all endpoints (GET /users/me, PATCH /users/me, GET /users/me/stats, GET /users/{id}), updated Swagger XML comments with detailed remarks, examples, security notes

---

## Parallel Execution Opportunities

### After Phase 2 Complete (Foundation)

**Can run in parallel**:

**Developer 1**: Phase 3 (US1+US2 - Backend)
- T010-T013: UpdateProfile command, validator, handler, endpoint
- T014-T016: Backend tests

**Developer 2**: Phase 3 (US1+US2 - Frontend)
- T017-T022: ProfilePage, ProfileEditForm, AvatarImage, hooks, API

**Developer 3**: Phase 4 (US3 - Statistics Backend)
- T028-T031: GetUserStats query, handler, endpoint, cache invalidation

**Developer 4**: Phase 4 (US3 - Statistics Frontend)
- T034-T036: UserStats component, hook, integration

**Estimated Time**: 4-5 hours in parallel (vs 8-9 hours sequential)

---

### After Phase 3+4 Complete (P1+P2 Done)

**Can run in parallel**:

**Developer 1**: Phase 5 (US4 - Public Profiles)
- T039-T046: Public profile backend + frontend

**Developer 2**: Phase 6 (Integration)
- T047-T051: SignalR, Header updates

**Estimated Time**: 2-3 hours in parallel (vs 5 hours sequential)

---

## Testing Strategy

### Test Coverage Targets

- **Backend**: 80% coverage minimum
  - Unit tests: UpdateProfileCommandHandler, UpdateProfileCommandValidator, GetUserStatsQueryHandler, MemoryCacheService
  - Integration tests: PATCH /users/me, GET /users/me/stats, GET /users/{userId}
  - SignalR tests: ProfileUpdated event broadcast

- **Frontend**: 80% coverage minimum
  - Component tests: ProfilePage, ProfileEditForm, AvatarImage, UserStats, PublicProfilePage
  - Hook tests: useProfile, useUserStats with mocked fetch
  - MSW mocks: All profile API endpoints

### Test Execution

```bash
# Backend tests
cd ae-infinity-api
dotnet test --filter "FullyQualifiedName~Profile" --collect:"XPlat Code Coverage"

# Frontend tests
cd ae-infinity-ui
npm test -- --run profile --coverage
```

### Contract Validation

After each user story:
1. Run backend, open Swagger at http://localhost:5233/index.html
2. Compare actual responses to contract JSON schemas:
   - update-profile-request.json
   - user-stats-response.json
   - public-user-profile.json
3. Verify required fields, data types, no extra fields

---

## Success Criteria Checklist

From [spec.md](./spec.md) - verify ALL before marking feature complete:

### Performance
- [ ] SC-001: Profile view loads in < 2 seconds
- [ ] SC-002: Profile update completes in < 5 seconds (including validation and save)
- [ ] SC-006: Form validation feedback within 200ms
- [ ] SC-014: Statistics queries complete in < 500ms even for users with 100+ lists

### Functionality
- [ ] SC-003: 100% of profile updates persist across sessions and browser restarts
- [ ] SC-004: Profile changes visible to collaborators within 10 seconds (SignalR)
- [ ] SC-005: Statistics update within 60 seconds of relevant actions
- [ ] SC-009: Display name changes reflect immediately in all UI locations
- [ ] SC-010: Avatar fallback works for broken URLs

### User Experience
- [ ] SC-007: Profile page loads successfully even if statistics fail (graceful degradation)
- [ ] SC-008: Loading indicators appear within 100ms of page load
- [ ] SC-013: User-friendly error messages with actionable guidance

### Security
- [ ] SC-011: 100% of profile update requests require valid JWT token (no unauthorized updates)
- [ ] SC-012: Users cannot modify other users' profiles (authorization enforced at API level)

---

## Definition of Done

Feature 002 is complete when:

- [ ] All P1 user stories implemented and tested (US1+US2)
- [ ] All P1 backend endpoints tested (unit + integration)
- [ ] All P1 frontend components tested
- [ ] SignalR ProfileUpdated event broadcasts to collaborators
- [ ] Header displays user avatar and name, updates in real-time
- [ ] All 14 success criteria met
- [ ] Backend code coverage ≥ 80%
- [ ] Frontend code coverage ≥ 80%
- [ ] Swagger documentation matches contracts
- [ ] Manual testing checklist complete
- [ ] No TypeScript `any` types in frontend
- [ ] Code review approved
- [ ] Feature deployed to staging

**P2 Complete** (Statistics):
- [ ] All US3 tasks complete (T028-T038)
- [ ] Statistics display with caching and cache invalidation
- [ ] Performance target met (< 500ms queries)

**Optional P3** (Public Profiles):
- [ ] All US4 tasks complete (T039-T046)
- [ ] Public profile page limits data exposure
- [ ] Links from collaborator names work

---

## Risk Mitigation

### Known Risks

1. **Statistics Query Performance**
   - Risk: Slow queries for users with 100+ lists
   - Mitigation: IMemoryCache with 5-minute TTL, monitor query duration, add indexes if needed

2. **Avatar Image Loading**
   - Risk: Broken avatar URLs degrade UX
   - Mitigation: AvatarImage component with fallback to initials, no server-side validation (performance trade-off)

3. **Concurrent Profile Edits**
   - Risk: User edits profile in multiple tabs
   - Mitigation: Last write wins (acceptable for simple profile updates), document limitation

4. **SignalR Connection**
   - Risk: Profile updates may not broadcast if SignalR disconnected
   - Mitigation: Frontend polls GET /users/me on focus/visibility change as backup

---

## Deployment Checklist

Before deploying to production:

- [ ] Environment variables configured (JWT secret already set from feature 001)
- [ ] IMemoryCache configured in DI container (default settings: 5-minute TTL for stats)
- [ ] SignalR CollaborationHub exists and ProfileUpdatedEventHandler registered
- [ ] Database migrations applied (none needed - User entity complete from feature 001)
- [ ] Health check endpoint responding
- [ ] Monitoring configured (Application Insights or ELK)
- [ ] Performance metrics tracked (profile load time, update time, stats query time)
- [ ] Backup strategy in place
- [ ] Rollback plan documented

---

## Quick Reference

**Backend API Base URL**: http://localhost:5233/api  
**Frontend Dev Server**: http://localhost:5173  
**Swagger UI**: http://localhost:5233/index.html

**Key Files**:
- Spec: [spec.md](./spec.md)
- Plan: [plan.md](./plan.md)
- Data Model: [data-model.md](./data-model.md)
- Quickstart: [quickstart.md](./quickstart.md)
- Contracts: [contracts/](./contracts/)

**Commands**:
```bash
# Run backend
cd ae-infinity-api && dotnet run --project AeInfinity.API

# Run frontend
cd ae-infinity-ui && npm run dev

# Run tests
dotnet test --filter "FullyQualifiedName~Profile"  # backend
npm test -- --run profile                          # frontend

# Check Swagger
open http://localhost:5233/index.html
```

**Endpoints to Implement**:
- PATCH /api/users/me - Update profile (displayName, avatarUrl)
- GET /api/users/me/stats - Get activity statistics
- GET /api/users/{userId} - Get public profile (P3)

**Existing Endpoint** (from feature 001):
- GET /api/users/me - Get current user profile (already works)

---

**Generated**: 2025-11-05  
**Last Updated**: 2025-11-05  
**Total Tasks**: 52  
**Estimated Duration**: 8-10 days (P1+P2), +2 days (P3)  
**MVP Scope**: Phases 1-3 + 6 (US1+US2 only) = 34 tasks, ~5 days
