# Implementation Plan: User Profile Management

**Branch**: `002-user-profile-management` | **Date**: 2025-11-05 | **Spec**: [spec.md](./spec.md)

## Summary

This feature enables users to view and edit their profile information (display name, avatar) and view activity statistics (lists, items, collaborations). It extends the existing User entity from feature 001 by adding a PATCH endpoint for profile updates and a statistics calculation system. The implementation follows Clean Architecture with MediatR commands/queries, FluentValidation, and real-time SignalR broadcasting for profile changes visible to collaborators.

**Primary Requirement**: Users can view and update their profiles with immediate feedback and real-time synchronization to collaborators.

**Technical Approach**: 
- Backend: PATCH /users/me endpoint with FluentValidation, statistics calculated via LINQ queries with caching
- Frontend: Profile page with React Hook Form, optimistic UI updates, avatar fallback handling
- Real-time: SignalR broadcast of profile changes to connected clients viewing shared lists
- Caching: In-memory cache for statistics with 5-minute TTL to reduce database load

## Technical Context

**Language/Version**: 
- Backend: C# / .NET 9.0
- Frontend: TypeScript / React 19.1

**Primary Dependencies**: 
- Backend: ASP.NET Core 9.0, Entity Framework Core 9.0, MediatR 12.4, FluentValidation 11.9, SignalR 9.0
- Frontend: React 19.1, React Router 7.9, React Hook Form 7.51, Vite 7.1, Tailwind CSS 3.4

**Storage**: SQL Server (existing) with User table (from feature 001)

**Testing**: 
- Backend: xUnit, WebApplicationFactory for integration tests, FluentAssertions
- Frontend: Vitest, React Testing Library, MSW for API mocking

**Target Platform**: Web application (browser-based, responsive mobile-first design)

**Project Type**: Web (backend API + frontend SPA)

**Performance Goals**: 
- Profile load: < 2 seconds
- Profile update: < 500ms API response
- Statistics calculation: < 500ms even for users with 100+ lists
- Real-time profile change broadcast: < 100ms latency

**Constraints**: 
- API response time < 200ms (p95) per constitution
- JWT authentication required for all endpoints
- Authorization: users can only edit their own profile
- Statistics must be cacheable to avoid expensive queries
- Graceful degradation if statistics fail to load

**Scale/Scope**: 
- Support 10,000+ concurrent users
- Users can have up to 1000 lists (edge case)
- Statistics queries must scale with user activity
- Avatar URLs up to 500 characters

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ Specification-First Development
- ✅ Complete specification exists at [spec.md](./spec.md)
- ✅ User stories prioritized (P1: view/edit, P2: statistics, P3: public profiles)
- ✅ Success criteria defined (14 measurable outcomes)
- ✅ Quality checklist passed (all validation items complete)

### ✅ Real-time Collaboration Architecture
- ✅ Profile changes must broadcast via SignalR to collaborators viewing shared lists
- ✅ Optimistic UI updates planned for profile edit form
- ✅ Presence not required for profile feature (applies to list views)
- ⚠️ Conflict resolution: Last write wins (profile updates are simple, no complex merging needed)

**Justification for last-write-wins**: Profile updates (display name, avatar) are simple atomic changes. If user edits profile in multiple tabs, the most recent save should prevail. No complex conflict resolution needed unlike collaborative list editing.

### ✅ Security & Privacy by Design
- ✅ JWT authentication required for GET /users/me, PATCH /users/me
- ✅ Authorization enforced: users can only update their own profile (ClaimsPrincipal validation)
- ✅ FluentValidation for display name length (2-100 chars) and avatar URL format
- ✅ No email changes in this feature (security implications, requires verification flow)
- ✅ Public profiles (P3) expose minimal data (displayName, avatarUrl, createdAt - no email)
- ✅ Case-insensitive email lookup maintained from feature 001

### ✅ Test-Driven Development
- ✅ Unit tests planned for: UpdateProfileCommandHandler, GetUserStatsQueryHandler
- ✅ Integration tests planned for: PATCH /users/me, GET /users/me/stats
- ✅ Component tests planned for: ProfilePage, ProfileEditForm, AvatarImage (with fallback)
- ✅ SignalR tests planned for: ProfileUpdated event broadcast to collaborators
- ✅ Target: 80% code coverage minimum

### ✅ Frontend Standards
- ✅ TypeScript strict mode (no `any` types)
- ✅ Functional components with hooks (useAuth, useProfile custom hooks)
- ✅ React Hook Form for profile edit form (validation, error handling)
- ✅ Code splitting: lazy load profile page (not needed on initial app load)
- ✅ Tailwind CSS for styling
- ✅ Accessibility: form labels, ARIA attributes, keyboard navigation

### ✅ Backend Standards
- ✅ Clean Architecture: API → Application (MediatR) → Core (User entity) → Infrastructure (EF Core)
- ✅ Dependency Injection for validators, caching, SignalR hub context
- ✅ Async/await for all database and I/O operations
- ✅ XML documentation comments on public APIs
- ✅ Entity Framework Core for User entity queries (existing from 001)
- ✅ FluentValidation for UpdateProfileCommand

### ✅ API Design Principles
- ✅ RESTful conventions: PATCH /users/me (update own profile)
- ✅ Resource-based URL: /api/users/me (authenticated user context)
- ✅ Consistent error responses: 400 (validation), 401 (auth), 403 (authorization), 404 (not found)
- ✅ No pagination needed (single user profile, not a list)
- ✅ Versioning: /api/v1/ prefix

### 🔄 Performance Requirements
- ✅ Page load < 2 seconds (profile page loads user data + statistics)
- ✅ API response < 200ms (p95) - profile update is simple UPDATE query
- ⚠️ Statistics calculation needs optimization (caching required)

**Statistics Caching Strategy**: Use IMemoryCache with 5-minute TTL. Statistics recalculated on cache miss or when user performs relevant actions (create list, add item, mark purchased). Invalidate cache on user actions via domain events.

## Project Structure

### Documentation (this feature)

```
specs/002-user-profile-management/
├── spec.md                 # ✅ Complete (4 user stories, 24 FRs, 14 success criteria)
├── plan.md                 # ✅ This file (implementation strategy)
├── research.md             # ⏭️ Skipped (no unknowns, all tech decisions clear)
├── data-model.md           # 🔨 Phase 1 (entities, DTOs, validation, queries)
├── quickstart.md           # 🔨 Phase 1 (developer setup guide)
├── contracts/              # 🔨 Phase 1 (JSON schemas for API requests/responses)
│   ├── update-profile-request.json
│   ├── user-stats-response.json
│   └── public-user-profile.json
├── checklists/
│   └── requirements.md     # ✅ Complete (all validation passed)
└── tasks.md                # ⏳ Phase 2 (created by /speckit.tasks command)
```

### Source Code (repository root)

```
# Backend: ../ae-infinity-api/
AeInfinity.API/
├── Controllers/
│   └── UsersController.cs              # 🔨 Add PATCH /users/me endpoint
├── Middleware/
│   └── AuthorizationMiddleware.cs      # ✅ Exists (JWT validation from 001)

AeInfinity.Application/
├── Users/
│   ├── Commands/
│   │   ├── UpdateProfile/
│   │   │   ├── UpdateProfileCommand.cs           # 🔨 New (MediatR command)
│   │   │   ├── UpdateProfileCommandHandler.cs    # 🔨 New (business logic)
│   │   │   └── UpdateProfileCommandValidator.cs  # 🔨 New (FluentValidation)
│   ├── Queries/
│   │   ├── GetUserStats/
│   │   │   ├── GetUserStatsQuery.cs              # 🔨 New (MediatR query)
│   │   │   └── GetUserStatsQueryHandler.cs       # 🔨 New (calculate statistics)
│   │   └── GetUserById/
│   │       ├── GetUserByIdQuery.cs               # 🔨 New (for public profiles P3)
│   │       └── GetUserByIdQueryHandler.cs        # 🔨 New
│   └── DTOs/
│       ├── UpdateProfileDto.cs                   # 🔨 New (request DTO)
│       ├── UserStatsDto.cs                       # 🔨 New (response DTO)
│       └── PublicUserProfileDto.cs               # 🔨 New (P3 - limited fields)

AeInfinity.Domain/
├── Entities/
│   └── User.cs                         # ✅ Exists (from 001, no changes needed)
└── Events/
    └── ProfileUpdatedEvent.cs          # 🔨 New (domain event for SignalR)

AeInfinity.Infrastructure/
├── Data/
│   └── AeInfinityDbContext.cs          # ✅ Exists (User entity configured)
├── Caching/
│   ├── ICacheService.cs                # 🔨 New (interface for statistics caching)
│   └── MemoryCacheService.cs           # 🔨 New (IMemoryCache wrapper)
└── SignalR/
    └── CollaborationHub.cs             # ✅ Exists, 🔨 Add ProfileUpdated method

AeInfinity.Tests/
├── Integration/
│   └── UsersControllerTests.cs         # 🔨 Add PATCH /users/me tests
├── Unit/
│   ├── UpdateProfileCommandHandlerTests.cs   # 🔨 New
│   ├── UpdateProfileCommandValidatorTests.cs # 🔨 New
│   └── GetUserStatsQueryHandlerTests.cs      # 🔨 New
└── TestHelpers/
    └── UserFactory.cs                  # ✅ Exists (create test users)

# Frontend: ../ae-infinity-ui/
src/
├── features/
│   └── profile/
│       ├── ProfilePage.tsx             # 🔨 New (main profile view)
│       ├── ProfileEditForm.tsx         # 🔨 New (edit form with validation)
│       ├── UserStats.tsx               # 🔨 New (statistics display component)
│       ├── AvatarImage.tsx             # 🔨 New (avatar with fallback)
│       ├── useProfile.ts               # 🔨 New (custom hook for profile data)
│       └── profileApi.ts               # 🔨 New (API calls)
├── components/
│   └── layout/
│       └── Header.tsx                  # 🔨 Update (display user avatar + name)
├── hooks/
│   └── useAuth.ts                      # ✅ Exists (JWT token management from 001)
└── types/
    ├── user.ts                         # ✅ Exists, 🔨 Add UserStatsDto type
    └── profile.ts                      # 🔨 New (UpdateProfileDto type)

tests/
├── features/
│   └── profile/
│       ├── ProfilePage.test.tsx        # 🔨 New
│       ├── ProfileEditForm.test.tsx    # 🔨 New
│       └── AvatarImage.test.tsx        # 🔨 New (test fallback behavior)
└── mocks/
    └── profileHandlers.ts              # 🔨 New (MSW handlers for profile endpoints)
```

**Structure Decision**: Web application with separate backend (ASP.NET Core) and frontend (React) repositories. Backend follows Clean Architecture (API → Application → Domain → Infrastructure). Frontend uses feature-based folder structure. This matches the existing project structure from feature 001.

## Complexity Tracking

> No constitution violations requiring justification.

All design decisions align with constitution requirements:
- Statistics caching uses standard IMemoryCache (proven pattern, low complexity)
- Last-write-wins for profile updates (simplest concurrency model for this use case)
- MediatR + FluentValidation (established patterns from feature 001)
- No new abstractions or patterns introduced

## Phase 0: Research & Decisions

**Status**: ⏭️ Skipped - No unknowns or clarifications needed

All technical decisions are clear from constitution and feature 001:
- ✅ Technology stack defined (.NET 9.0, React 19.1, Entity Framework Core, SignalR)
- ✅ Architecture patterns established (Clean Architecture, MediatR, CQRS)
- ✅ Validation approach defined (FluentValidation for backend, React Hook Form for frontend)
- ✅ Authentication/authorization mechanism exists (JWT from feature 001)
- ✅ Caching strategy selected (IMemoryCache with TTL for statistics)
- ✅ Real-time broadcast mechanism exists (SignalR CollaborationHub from existing features)

**Output**: No research.md file needed - proceeding directly to Phase 1 design.

## Phase 1: Design & Contracts

### Deliverables

1. **data-model.md** - Entity definitions, DTOs, validation rules, database queries
2. **contracts/** - JSON schemas for API requests/responses
3. **quickstart.md** - Developer guide for implementing this feature

### Implementation Tasks

#### Backend Tasks

1. **Create DTOs** (`AeInfinity.Application/Users/DTOs/`)
   - UpdateProfileDto (displayName, avatarUrl)
   - UserStatsDto (totalListsOwned, totalListsShared, totalItemsCreated, totalItemsPurchased, totalActiveCollaborations, lastActivityAt)
   - PublicUserProfileDto (displayName, avatarUrl, createdAt) - P3

2. **Create MediatR Commands/Queries**
   - UpdateProfileCommand + Handler + Validator
   - GetUserStatsQuery + Handler
   - GetUserByIdQuery + Handler (P3)

3. **Create Caching Service**
   - ICacheService interface
   - MemoryCacheService implementation with TTL support

4. **Add API Endpoint** (`UsersController`)
   - PATCH /api/users/me (update profile)
   - GET /api/users/me/stats (get statistics) - optional, could embed in /users/me
   - GET /api/users/{userId} (public profile) - P3

5. **Update SignalR Hub** (`CollaborationHub`)
   - Add ProfileUpdated(userId, displayName, avatarUrl) broadcast method
   - Trigger on successful profile update

6. **Create Tests**
   - Unit: UpdateProfileCommandHandler, Validator, GetUserStatsQueryHandler
   - Integration: PATCH /users/me (success, validation errors, authorization)
   - SignalR: ProfileUpdated event broadcast

#### Frontend Tasks

1. **Create Profile Components**
   - ProfilePage (view mode with stats)
   - ProfileEditForm (edit mode with validation)
   - UserStats (statistics display)
   - AvatarImage (with fallback to initials/placeholder)

2. **Create Custom Hooks**
   - useProfile (fetch profile data, update profile, handle loading/errors)
   - useUserStats (fetch statistics, handle caching)

3. **Create API Layer** (`profileApi.ts`)
   - getProfile() - GET /users/me
   - updateProfile(data) - PATCH /users/me
   - getUserStats() - GET /users/me/stats
   - getPublicProfile(userId) - GET /users/{userId} (P3)

4. **Update Header Component**
   - Display user avatar + display name
   - Link to profile page

5. **Add SignalR Listener**
   - Subscribe to ProfileUpdated event
   - Update avatar/name in Header when collaborators update their profiles

6. **Create Tests**
   - Component: ProfilePage, ProfileEditForm, AvatarImage (test fallback)
   - Hook: useProfile (test CRUD operations, error handling)
   - MSW: Mock API handlers for profile endpoints

### API Endpoints

| Method | Endpoint | Auth | Request | Response | Status Codes |
|--------|----------|------|---------|----------|--------------|
| GET | /api/users/me | JWT | - | UserDto (existing from 001) | 200, 401, 404 |
| PATCH | /api/users/me | JWT | UpdateProfileDto | UserDto | 200, 400, 401, 403 |
| GET | /api/users/me/stats | JWT | - | UserStatsDto | 200, 401 |
| GET | /api/users/{userId} | JWT | - | PublicUserProfileDto | 200, 401, 404 |

**Note**: GET /users/me already exists from feature 001. GET /users/me/stats could be embedded in /users/me response or separate endpoint for better caching.

### SignalR Events

| Event | Payload | When | Who Receives |
|-------|---------|------|--------------|
| ProfileUpdated | { userId, displayName, avatarUrl } | User updates profile | All connected clients on shared lists with that user |

## Phase 2: Implementation Tasks

**Status**: ⏳ Pending - Use `/speckit.tasks` command to generate tasks.md

Tasks will be broken down by priority:
1. **P1 Tasks**: View profile, edit profile (display name + avatar)
2. **P2 Tasks**: Statistics calculation and display
3. **P3 Tasks**: Public user profiles (deferrable)

Each task will include:
- Specific file to create/modify
- Acceptance criteria from spec.md
- Test requirements
- Estimated complexity points

## Implementation Phases

### Phase 1.1: Backend Profile Update (Priority: P1)

**Goal**: Users can update their display name and avatar via PATCH /users/me

**Steps**:
1. Create UpdateProfileDto, UpdateProfileCommand, Handler, Validator
2. Add PATCH /users/me endpoint in UsersController
3. Create ProfileUpdatedEvent domain event
4. Update CollaborationHub with ProfileUpdated broadcast method
5. Write unit tests for command handler and validator
6. Write integration tests for PATCH endpoint
7. Write SignalR tests for ProfileUpdated broadcast

**Acceptance Criteria** (from spec.md):
- Display name validates 2-100 characters
- Avatar URL validates format (valid URI or null)
- Unicode/emoji support in display name
- Authorization: user can only update own profile
- Returns 200 with updated UserDto on success
- Returns 400 with validation errors
- Returns 403 if attempting to update another user's profile
- Broadcasts ProfileUpdated event to collaborators

**Testing**:
- Unit: UpdateProfileCommandHandler (happy path, validation, authorization)
- Unit: UpdateProfileCommandValidator (min/max length, URL format)
- Integration: PATCH /users/me (authenticated, success, validation errors, 403 forbidden)
- SignalR: ProfileUpdated broadcast to connected clients

---

### Phase 1.2: Frontend Profile Edit (Priority: P1)

**Goal**: Users can view and edit their profile with immediate feedback

**Steps**:
1. Create ProfilePage component (view mode)
2. Create ProfileEditForm component (React Hook Form validation)
3. Create AvatarImage component (with fallback)
4. Create useProfile custom hook (API integration)
5. Create profileApi.ts (PATCH /users/me)
6. Update Header component (display avatar + name, link to profile)
7. Add route for /profile
8. Add SignalR listener for ProfileUpdated event (update Header)
9. Write component tests
10. Write hook tests with MSW mocks

**Acceptance Criteria** (from spec.md):
- Profile page displays all user fields (name, email, avatar, dates)
- Edit button opens editable form with current values pre-populated
- Validation errors display inline (< 2 chars, > 100 chars, invalid URL)
- Save button updates profile and shows success message
- Optimistic UI update (optional)
- Avatar fallback to placeholder if URL invalid
- Cancel button discards changes
- Retry mechanism if API fails

**Testing**:
- Component: ProfilePage (renders data, edit button)
- Component: ProfileEditForm (validation, submit, cancel, errors)
- Component: AvatarImage (renders image, fallback on error)
- Hook: useProfile (fetch, update, loading, errors)
- MSW: Mock PATCH /users/me (success, validation errors, network errors)

---

### Phase 2.1: Backend Statistics (Priority: P2)

**Goal**: Users can view activity statistics (lists owned/shared, items created/purchased)

**Steps**:
1. Create UserStatsDto
2. Create GetUserStatsQuery + Handler
3. Implement ICacheService interface
4. Implement MemoryCacheService with 5-minute TTL
5. Add statistics calculation queries (LINQ with includes)
6. Cache statistics with invalidation on user actions
7. Add GET /users/me/stats endpoint (or embed in /users/me)
8. Write unit tests for query handler
9. Write integration tests for statistics endpoint
10. Test cache hit/miss scenarios

**Acceptance Criteria** (from spec.md):
- Statistics include: totalListsOwned, totalListsShared, totalItemsCreated, totalItemsPurchased, totalActiveCollaborations
- lastActivityAt tracks most recent user action
- Queries complete in < 500ms even for users with 100+ lists
- Statistics cached for 5 minutes
- Cache invalidated on relevant user actions
- Returns 200 with UserStatsDto
- Returns 401 if not authenticated
- Graceful handling if calculation times out

**Testing**:
- Unit: GetUserStatsQueryHandler (calculate all metrics, handle edge cases)
- Unit: MemoryCacheService (set, get, evict, TTL expiration)
- Integration: GET /users/me/stats (authenticated, cached vs uncached)
- Performance: Test with user having 100+ lists (must be < 500ms)

---

### Phase 2.2: Frontend Statistics Display (Priority: P2)

**Goal**: Users can view their activity statistics on profile page

**Steps**:
1. Create UserStats component
2. Create useUserStats custom hook
3. Add statistics API call to profileApi.ts
4. Integrate UserStats into ProfilePage
5. Add loading indicator for statistics
6. Graceful degradation if statistics fail (show "unavailable")
7. Write component tests
8. Write hook tests with MSW mocks

**Acceptance Criteria** (from spec.md):
- Statistics displayed in card/section on profile page
- Shows all 6 metrics clearly labeled
- Loading indicator while fetching statistics
- Error message "Statistics temporarily unavailable" if API fails
- Statistics do NOT block profile page load (async)
- Statistics update when user creates lists, adds items, marks purchases

**Testing**:
- Component: UserStats (renders all metrics, loading state, error state)
- Hook: useUserStats (fetch, loading, error, refetch)
- MSW: Mock GET /users/me/stats (success, error, timeout)

---

### Phase 3: Public Profiles (Priority: P3 - Deferrable)

**Goal**: Users can view limited public profiles of collaborators

**Steps**:
1. Create PublicUserProfileDto
2. Create GetUserByIdQuery + Handler
3. Add GET /users/{userId} endpoint
4. Create PublicProfilePage component
5. Add route for /users/:userId
6. Add links from collaborator lists to public profiles
7. Write tests

**Acceptance Criteria** (from spec.md):
- Public profile shows: displayName, avatarUrl, createdAt
- Public profile excludes: email, full statistics, sensitive data
- Returns 404 if user not found
- Navigable from collaborator names in list views

**Testing**:
- Unit: GetUserByIdQueryHandler (return public data only)
- Integration: GET /users/{userId} (success, 404, authorization)
- Component: PublicProfilePage (renders limited data)

**Note**: This phase can be deferred to post-MVP if needed.

---

## Quality Assurance

### Testing Strategy

**Backend** (Target: 80% coverage):
- ✅ Unit tests for all command/query handlers
- ✅ Unit tests for validators (FluentValidation rules)
- ✅ Integration tests for all API endpoints
- ✅ SignalR tests for ProfileUpdated broadcast
- ✅ Performance tests for statistics queries (100+ lists scenario)
- ✅ Cache tests (hit/miss, TTL expiration, invalidation)

**Frontend** (Target: 80% coverage):
- ✅ Component tests for all profile UI components
- ✅ Hook tests for useProfile, useUserStats
- ✅ Integration tests for profile page flows (view → edit → save)
- ✅ MSW mocks for all API endpoints
- ✅ Accessibility tests (keyboard navigation, ARIA labels)
- ✅ Avatar fallback tests (broken image URLs)

### Performance Testing

- Profile load time: Measure GET /users/me + GET /users/me/stats (target: < 2s)
- Profile update time: Measure PATCH /users/me (target: < 500ms)
- Statistics query: Test with users having 1, 10, 100, 1000 lists (target: < 500ms at 100+)
- Cache effectiveness: Measure hit rate (target: > 90% for statistics)
- SignalR broadcast latency: Measure ProfileUpdated delivery time (target: < 100ms)

### Security Testing

- ✅ Test PATCH /users/me with missing JWT token (expect 401)
- ✅ Test PATCH /users/me with attempt to update another user (expect 403)
- ✅ Test PATCH /users/me with invalid JWT token (expect 401)
- ✅ Test avatar URL with XSS attempt (validate and sanitize)
- ✅ Test display name with SQL injection attempt (parameterized queries via EF Core)
- ✅ Test public profile endpoint excludes sensitive data (email, full stats)

### Acceptance Testing

Run through all acceptance scenarios from spec.md:
- User Story 1: View profile (5 scenarios)
- User Story 2: Edit profile (7 scenarios)
- User Story 3: Statistics (6 scenarios)
- User Story 4: Public profiles (5 scenarios) - P3

### Edge Cases

Test all edge cases from spec.md:
- Duplicate display names (allowed)
- Broken avatar URLs (fallback)
- Authorization (403 on editing other profiles)
- Concurrent edits (last write wins)
- Statistics timeout (graceful degradation)
- Clearing avatar URL (null handling)
- Unicode/emoji in display name

---

## Deployment & Operations

### Environment Variables

**Backend** (appsettings.json):
```json
{
  "Caching": {
    "UserStats": {
      "ExpirationMinutes": 5,
      "SlidingExpiration": false
    }
  },
  "Performance": {
    "StatisticsQueryTimeoutSeconds": 30
  }
}
```

**Frontend** (.env):
```
VITE_API_BASE_URL=http://localhost:5233/api
VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/collaboration
```

### Database Migrations

**None required** - User entity already exists from feature 001 with all necessary fields (DisplayName, AvatarUrl). No schema changes needed.

### Monitoring & Logging

**Backend Logging** (Serilog):
- Log profile updates (audit trail): `Information: User {UserId} updated profile. DisplayName: {DisplayName}`
- Log statistics cache hits/misses: `Debug: Statistics cache {CacheResult} for User {UserId}`
- Log statistics query performance: `Warning: Statistics query for User {UserId} took {ElapsedMs}ms`
- Log authorization failures: `Warning: User {UserId} attempted to update profile of User {TargetUserId} (Forbidden)`

**Frontend Logging** (console):
- Log profile update success/failure
- Log avatar fallback events
- Log SignalR ProfileUpdated events received

**Metrics to Track**:
- Profile update success rate (target: > 99%)
- Profile load time (target: < 2s p95)
- Statistics query time (target: < 500ms p95)
- Cache hit rate (target: > 90%)
- Avatar fallback rate (indicates broken URLs)

### Rollback Plan

If critical issues arise:
1. Feature flag: `EnableProfileEditing` (disable PATCH /users/me endpoint)
2. Feature flag: `EnableUserStatistics` (hide statistics section)
3. Revert frontend deployment (profile page remains view-only)
4. Revert backend deployment (removes PATCH endpoint)

**Note**: No database rollback needed (no schema changes).

---

## Success Metrics

After deployment, measure against success criteria from spec.md:

- ✅ **SC-001**: Profile view loads in < 2 seconds (measure with Performance API)
- ✅ **SC-002**: Profile updates complete in < 5 seconds (measure end-to-end)
- ✅ **SC-003**: 100% of updates persist (test across sessions/browsers)
- ✅ **SC-004**: Profile changes visible to collaborators in < 10 seconds (SignalR latency)
- ✅ **SC-005**: Statistics update within 60 seconds (cache invalidation works)
- ✅ **SC-006**: Validation feedback in < 200ms (React Hook Form)
- ✅ **SC-007**: Profile loads even if statistics fail (graceful degradation)
- ✅ **SC-008**: Loading indicators appear in < 100ms (spinner/skeleton)
- ✅ **SC-009**: Display name updates reflect in Header, lists, feeds (real-time)
- ✅ **SC-010**: Avatar fallback works (test with broken URLs)
- ✅ **SC-011**: 100% of updates require JWT (401 on missing token)
- ✅ **SC-012**: 100% authorization enforced (403 on editing others)
- ✅ **SC-013**: User-friendly error messages (test validation errors)
- ✅ **SC-014**: Statistics < 500ms for 100+ lists (load test)

**Acceptance Criteria**: At least 12/14 success criteria must be met before marking feature as complete.

---

## Dependencies

### Requires (from other features)
- ✅ **Feature 001: User Authentication** - JWT tokens, GET /users/me endpoint, User entity
- ✅ **Existing SignalR Hub** - CollaborationHub for broadcasting ProfileUpdated events
- ✅ **Existing EF Core DbContext** - User entity queries and updates

### Blocks (other features depending on this)
- None - Profile editing is optional enhancement, no features depend on it

### Optional Integrations
- **Feature 005: List Collaboration** - Display updated user names/avatars in collaborator lists
- **Feature 007: Global Search** - Include user display name in search results
- **Feature 008: Real-time Sync** - Broadcast profile changes to connected clients

---

## Post-Implementation

### Documentation Updates
- [ ] Update API_SPEC.md with PATCH /users/me endpoint
- [ ] Update FEATURES.md status (002-user-profile-management: Implemented)
- [ ] Update ARCHITECTURE.md with caching strategy
- [ ] Update Swagger/OpenAPI documentation
- [ ] Create user guide for profile editing

### Code Review Checklist
- [ ] All tests pass (unit, integration, component)
- [ ] Code coverage ≥ 80%
- [ ] FluentValidation rules match spec requirements
- [ ] Authorization enforced at API level
- [ ] SignalR ProfileUpdated event broadcasts correctly
- [ ] Statistics caching implemented with TTL
- [ ] Avatar fallback works for broken URLs
- [ ] TypeScript strict mode (no `any` types)
- [ ] Accessibility compliance (ARIA labels, keyboard nav)
- [ ] Performance metrics meet targets
- [ ] Error messages user-friendly
- [ ] Logging added for audit trail

### Follow-up Tasks
- [ ] Monitor cache hit rate, adjust TTL if needed
- [ ] Monitor statistics query performance, add indexes if slow
- [ ] Consider avatar image upload (currently URL-only)
- [ ] Consider email change feature (requires verification flow)
- [ ] Consider profile visibility settings (private profiles)
- [ ] Implement Phase 3: Public user profiles (P3, deferrable)

---

**Plan Status**: ✅ Complete - Ready for implementation  
**Next Step**: Run `/speckit.tasks` to generate detailed task breakdown  
**Estimated Effort**: 
- Backend: 3-4 days (P1+P2)
- Frontend: 3-4 days (P1+P2)
- Testing: 2 days
- Total: ~8-10 days for P1+P2, +2 days for P3

**Last Updated**: 2025-11-05

