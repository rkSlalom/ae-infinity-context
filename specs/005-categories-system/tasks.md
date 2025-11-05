# Tasks: Categories System

**Input**: Design documents from `/specs/005-categories-system/`  
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Test tasks are included based on TDD approach specified in constitution and quickstart.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

**Implementation Status**: Backend 100% complete, Frontend 100% complete, Integration 0% - tasks focus on verification, integration, and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Backend**: `ae-infinity-api/` (separate repository)
- **Frontend**: `ae-infinity-ui/` (separate repository)
- Paths shown below use repository-relative paths as per plan.md structure

---

## Phase 1: Setup (Verification & Configuration)

**Purpose**: Verify existing implementation and prepare for integration testing

- [ ] T001 Verify backend repository structure in ae-infinity-api/ matches plan.md
- [ ] T002 Verify frontend repository structure in ae-infinity-ui/ matches plan.md
- [ ] T003 [P] Verify Category entity exists in ae-infinity-api/src/AeInfinity.Core/Entities/Category.cs
- [ ] T004 [P] Verify CategoriesController exists in ae-infinity-api/src/AeInfinity.Api/Controllers/CategoriesController.cs
- [ ] T005 [P] Verify categoriesService exists in ae-infinity-ui/src/services/categoriesService.ts
- [ ] T006 [P] Verify default category seeding logic exists in ae-infinity-api/src/AeInfinity.Infrastructure/Persistence/ApplicationDbContextSeed.cs
- [ ] T007 Verify database connection configuration in ae-infinity-api/src/AeInfinity.Api/appsettings.json
- [ ] T008 [P] Verify API base URL configuration in ae-infinity-ui/src/services/api.ts
- [ ] T009 [P] Set up test database for integration testing (SQLite or in-memory)
- [ ] T010 [P] Verify JWT authentication is configured and working in ae-infinity-api/

---

## Phase 2: Foundational (Test Infrastructure)

**Purpose**: Core test infrastructure that MUST be complete before ANY user story testing can begin

**⚠️ CRITICAL**: No user story testing can begin until this phase is complete

- [ ] T011 Create backend integration test project structure in ae-infinity-api/tests/AeInfinity.IntegrationTests/
- [ ] T012 [P] Configure WebApplicationFactory for integration tests in ae-infinity-api/tests/AeInfinity.IntegrationTests/
- [ ] T013 [P] Create test helpers for authentication in ae-infinity-api/tests/AeInfinity.IntegrationTests/Helpers/AuthHelper.cs
- [ ] T014 [P] Create test database seeder in ae-infinity-api/tests/AeInfinity.IntegrationTests/Helpers/TestDataSeeder.cs
- [ ] T015 [P] Set up frontend test environment with Vitest in ae-infinity-ui/vitest.config.ts
- [ ] T016 [P] Create test utilities for React Testing Library in ae-infinity-ui/tests/utils/test-utils.tsx
- [ ] T017 [P] Mock categoriesService for frontend tests in ae-infinity-ui/tests/mocks/categoriesServiceMock.ts

**Checkpoint**: Foundation ready - user story testing can now begin in parallel

---

## Phase 3: User Story 1 - View Default Categories (Priority: P1) 🎯 MVP

**Goal**: Verify 10 default categories are seeded and retrievable via GET /categories endpoint

**Independent Test**: Start backend, verify GET /categories returns 10 default categories with correct names, icons, and colors

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before any fixes**

- [ ] T018 [P] [US1] Backend integration test: GET /categories unauthenticated returns 10 defaults in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/GetCategoriesTests.cs
- [ ] T019 [P] [US1] Backend integration test: Verify default category seeding on startup in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/CategorySeedingTests.cs
- [ ] T020 [P] [US1] Backend integration test: Verify each default category has correct name, icon, color in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/DefaultCategoriesTests.cs
- [ ] T021 [P] [US1] Frontend component test: CategoryPicker displays categories in ae-infinity-ui/tests/components/CategoryPicker.test.tsx
- [ ] T022 [P] [US1] Frontend service test: categoriesService.getAllCategories returns data in ae-infinity-ui/tests/services/categoriesService.test.ts

### Implementation for User Story 1

- [ ] T023 [US1] Verify default category seeding in ae-infinity-api/src/AeInfinity.Infrastructure/Persistence/ApplicationDbContextSeed.cs (fix if broken)
- [ ] T024 [US1] Verify seeding is called on startup in ae-infinity-api/src/AeInfinity.Api/Program.cs (add if missing)
- [ ] T025 [US1] Run backend and verify database contains 10 default categories with correct data
- [ ] T026 [US1] Test GET /categories endpoint manually with curl/Postman (unauthenticated)
- [ ] T027 [US1] Verify GetCategoriesQuery handler filters defaults correctly in ae-infinity-api/src/AeInfinity.Application/Categories/Queries/GetCategories/GetCategoriesHandler.cs
- [ ] T028 [US1] Fix any issues with default category data (icons, colors, names)
- [ ] T029 [US1] Run all US1 backend integration tests and verify they pass
- [ ] T030 [US1] Verify frontend categoriesService connects to real API in ae-infinity-ui/src/services/categoriesService.ts
- [ ] T031 [US1] Verify CategoryPicker component displays categories in ae-infinity-ui/src/components/CategoryPicker.tsx
- [ ] T032 [US1] Run all US1 frontend tests and verify they pass
- [ ] T033 [US1] Manual E2E test: Open frontend, verify category picker shows 10 defaults

**Checkpoint**: At this point, User Story 1 should be fully functional - default categories load and display correctly

---

## Phase 4: User Story 2 - Create Custom Category (Priority: P1)

**Goal**: Enable authenticated users to create custom categories with validation

**Independent Test**: Login, POST /categories with valid data, verify category is created and persisted

### Tests for User Story 2

- [ ] T034 [P] [US2] Backend integration test: POST /categories with valid data returns 201 in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/CreateCategoryTests.cs
- [ ] T035 [P] [US2] Backend integration test: POST /categories duplicate name returns 400 in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/CreateCategoryValidationTests.cs
- [ ] T036 [P] [US2] Backend integration test: POST /categories invalid color format returns 400 in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/CreateCategoryValidationTests.cs
- [ ] T037 [P] [US2] Backend integration test: POST /categories unauthenticated returns 401 in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/CreateCategoryAuthTests.cs
- [ ] T038 [P] [US2] Backend unit test: CreateCategoryValidator validates name length in ae-infinity-api/tests/AeInfinity.Application.Tests/Categories/CreateCategoryValidatorTests.cs
- [ ] T039 [P] [US2] Backend unit test: CreateCategoryValidator validates icon format in ae-infinity-api/tests/AeInfinity.Application.Tests/Categories/CreateCategoryValidatorTests.cs
- [ ] T040 [P] [US2] Backend unit test: CreateCategoryValidator validates color hex format in ae-infinity-api/tests/AeInfinity.Application.Tests/Categories/CreateCategoryValidatorTests.cs
- [ ] T041 [P] [US2] Frontend component test: CreateCategoryModal submits valid data in ae-infinity-ui/tests/components/CreateCategoryModal.test.tsx
- [ ] T042 [P] [US2] Frontend component test: CreateCategoryModal displays validation errors in ae-infinity-ui/tests/components/CreateCategoryModal.test.tsx

### Implementation for User Story 2

- [ ] T043 [US2] Verify CreateCategoryCommand handler in ae-infinity-api/src/AeInfinity.Application/Categories/Commands/CreateCategory/CreateCategoryHandler.cs
- [ ] T044 [US2] Verify CreateCategoryValidator rules in ae-infinity-api/src/AeInfinity.Application/Categories/Commands/CreateCategory/CreateCategoryValidator.cs
- [ ] T045 [US2] Verify uniqueness check (case-insensitive) in CreateCategoryValidator
- [ ] T046 [US2] Test POST /categories with Postman/curl (authenticated, valid data)
- [ ] T047 [US2] Test POST /categories validation scenarios (duplicate, invalid icon, invalid color)
- [ ] T048 [US2] Verify authentication requirement in ae-infinity-api/src/AeInfinity.Api/Controllers/CategoriesController.cs
- [ ] T049 [US2] Run all US2 backend tests and verify they pass
- [ ] T050 [US2] Verify CreateCategoryModal component in ae-infinity-ui/src/components/CreateCategoryModal.tsx
- [ ] T051 [US2] Verify createCategory method in categoriesService in ae-infinity-ui/src/services/categoriesService.ts
- [ ] T052 [US2] Test category creation UI flow manually (open modal, fill form, submit)
- [ ] T053 [US2] Verify error handling for validation failures in frontend
- [ ] T054 [US2] Run all US2 frontend tests and verify they pass
- [ ] T055 [US2] Manual E2E test: Login, create custom category, verify it appears in list

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently - users can view defaults and create custom categories

---

## Phase 5: User Story 3 - Filter Categories (Priority: P2)

**Goal**: Enable filtering categories by includeCustom query parameter

**Independent Test**: GET /categories?includeCustom=false returns only defaults, includeCustom=true returns defaults+custom

### Tests for User Story 3

- [ ] T056 [P] [US3] Backend integration test: GET /categories?includeCustom=false returns only defaults in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/FilterCategoriesTests.cs
- [ ] T057 [P] [US3] Backend integration test: GET /categories?includeCustom=true returns defaults+custom in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/FilterCategoriesTests.cs
- [ ] T058 [P] [US3] Backend integration test: Authenticated user with custom categories sees both when includeCustom=true in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/FilterCategoriesTests.cs

### Implementation for User Story 3

- [ ] T059 [US3] Verify includeCustom query parameter in GetCategoriesQuery in ae-infinity-api/src/AeInfinity.Application/Categories/Queries/GetCategories/GetCategoriesQuery.cs
- [ ] T060 [US3] Verify filter logic in GetCategoriesHandler in ae-infinity-api/src/AeInfinity.Application/Categories/Queries/GetCategories/GetCategoriesHandler.cs
- [ ] T061 [US3] Test GET /categories with includeCustom=false (should return only 10 defaults)
- [ ] T062 [US3] Create custom category, test GET /categories?includeCustom=true (should return 11 categories)
- [ ] T063 [US3] Run all US3 backend tests and verify they pass
- [ ] T064 [US3] Verify frontend can pass includeCustom parameter in categoriesService.getAllCategories in ae-infinity-ui/src/services/categoriesService.ts
- [ ] T065 [US3] Manual E2E test: Verify filter toggle (if UI exists) or API parameter works correctly

**Checkpoint**: All filtering functionality works correctly - users can filter category lists

---

## Phase 6: User Story 4 - Assign Categories to Items (Priority: P1)

**Goal**: Enable assigning categories to shopping list items with visual badges

**Independent Test**: Create item with categoryId, verify item displays with category badge (icon, name, color)

**NOTE**: This story depends on Feature 004 (List Items Management). Tasks assume items feature is already implemented.

### Tests for User Story 4

- [ ] T066 [P] [US4] Backend integration test: Create item with categoryId saves relationship in ae-infinity-api/tests/AeInfinity.IntegrationTests/Items/ItemCategoryTests.cs
- [ ] T067 [P] [US4] Backend integration test: Get item includes category reference in response in ae-infinity-api/tests/AeInfinity.IntegrationTests/Items/ItemCategoryTests.cs
- [ ] T068 [P] [US4] Backend integration test: Update item categoryId updates relationship in ae-infinity-api/tests/AeInfinity.IntegrationTests/Items/ItemCategoryTests.cs
- [ ] T069 [P] [US4] Backend integration test: Set item categoryId to null removes category in ae-infinity-api/tests/AeInfinity.IntegrationTests/Items/ItemCategoryTests.cs
- [ ] T070 [P] [US4] Frontend component test: CategoryBadge displays icon, name, color in ae-infinity-ui/tests/components/CategoryBadge.test.tsx
- [ ] T071 [P] [US4] Frontend component test: ItemCard displays category badge when category exists in ae-infinity-ui/tests/components/ItemCard.test.tsx

### Implementation for User Story 4

- [ ] T072 [US4] Verify ListItem entity has CategoryId property in ae-infinity-api/src/AeInfinity.Core/Entities/ListItem.cs
- [ ] T073 [US4] Verify Category navigation property exists in ListItem entity
- [ ] T074 [US4] Verify CreateItemCommand accepts categoryId in ae-infinity-api/src/AeInfinity.Application/Items/Commands/CreateItem/
- [ ] T075 [US4] Verify UpdateItemCommand accepts categoryId in ae-infinity-api/src/AeInfinity.Application/Items/Commands/UpdateItem/
- [ ] T076 [US4] Verify GetItemQuery includes category in response in ae-infinity-api/src/AeInfinity.Application/Items/Queries/GetItem/
- [ ] T077 [US4] Test creating item with categoryId via API (POST /items with categoryId field)
- [ ] T078 [US4] Test retrieving item with category (GET /items/{id} includes category reference)
- [ ] T079 [US4] Run all US4 backend tests and verify they pass
- [ ] T080 [US4] Verify CategoryBadge component in ae-infinity-ui/src/components/CategoryBadge.tsx
- [ ] T081 [US4] Verify ItemCard/ItemRow displays CategoryBadge in ae-infinity-ui/src/components/ItemCard.tsx
- [ ] T082 [US4] Verify ItemForm includes category picker in ae-infinity-ui/src/components/ItemForm.tsx
- [ ] T083 [US4] Manual E2E test: Create item with category, verify badge displays correctly
- [ ] T084 [US4] Manual E2E test: Edit item category, verify badge updates
- [ ] T085 [US4] Manual E2E test: Remove category from item, verify badge disappears
- [ ] T086 [US4] Run all US4 frontend tests and verify they pass

**Checkpoint**: Items can be categorized and display category badges correctly

---

## Phase 7: User Story 5 - Filter List Items by Category (Priority: P2)

**Goal**: Enable client-side filtering of list items by selected category

**Independent Test**: Select category filter, verify only items with that category are displayed

### Tests for User Story 5

- [ ] T087 [P] [US5] Frontend component test: ListDetail filters items by category in ae-infinity-ui/tests/pages/ListDetail.test.tsx
- [ ] T088 [P] [US5] Frontend component test: CategoryFilter updates selected category in ae-infinity-ui/tests/components/CategoryFilter.test.tsx
- [ ] T089 [P] [US5] Frontend component test: Filter shows count per category in ae-infinity-ui/tests/components/CategoryFilter.test.tsx

### Implementation for User Story 5

- [ ] T090 [US5] Verify CategoryFilter component exists in ae-infinity-ui/src/components/CategoryFilter.tsx
- [ ] T091 [US5] Verify ListDetail page implements category filtering in ae-infinity-ui/src/pages/ListDetail.tsx
- [ ] T092 [US5] Verify client-side filter logic: `items.filter(item => item.category?.id === categoryId)`
- [ ] T093 [US5] Verify "All Categories" option clears filter
- [ ] T094 [US5] Verify item count per category is displayed
- [ ] T095 [US5] Manual E2E test: Create items in multiple categories, test filtering
- [ ] T096 [US5] Manual E2E test: Verify filter updates instantly (< 100ms)
- [ ] T097 [US5] Manual E2E test: Verify "No items" message when filter has no results
- [ ] T098 [US5] Run all US5 frontend tests and verify they pass

**Checkpoint**: All user stories should now be independently functional - complete categories system with filtering

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T099 [P] Add performance monitoring for category API endpoints in ae-infinity-api/
- [ ] T100 [P] Add category-specific logging: log category creation with userId, categoryId, name, timestamp at Information level in ae-infinity-api/src/AeInfinity.Application/Categories/Commands/CreateCategory/CreateCategoryHandler.cs
- [ ] T101 [P] Optimize GetCategoriesQuery with caching for defaults in ae-infinity-api/src/AeInfinity.Application/Categories/Queries/GetCategories/
- [ ] T102 [P] Add API documentation (XML comments) to CategoriesController in ae-infinity-api/src/AeInfinity.Api/Controllers/CategoriesController.cs
- [ ] T103 [P] Verify Swagger documentation for category endpoints is accurate
- [ ] T104 [P] Add accessibility labels to CategoryBadge component in ae-infinity-ui/src/components/CategoryBadge.tsx
- [ ] T105 [P] Add keyboard navigation support to CategoryPicker in ae-infinity-ui/src/components/CategoryPicker.tsx
- [ ] T105a [P] Implement search/filter functionality in CategoryPicker when category list exceeds 20 items in ae-infinity-ui/src/components/CategoryPicker.tsx
- [ ] T106 [P] Optimize CategoryContext to prevent unnecessary re-renders in ae-infinity-ui/src/contexts/CategoryContext.tsx
- [ ] T107 [P] Add error boundaries for category components in ae-infinity-ui/
- [ ] T107a [P] Verify Category entity has IsDeleted, DeletedAt, DeletedById fields in ae-infinity-api/src/AeInfinity.Core/Entities/Category.cs
- [ ] T107b [P] Add database migration for soft delete fields (IsDeleted, DeletedAt, DeletedById) in ae-infinity-api/
- [ ] T107c [P] Implement soft delete logic in DeleteCategoryCommand handler (if DELETE endpoint exists) in ae-infinity-api/src/AeInfinity.Application/Categories/Commands/DeleteCategory/
- [ ] T107d [P] Add validation to prevent deletion of categories assigned to items in ae-infinity-api/
- [ ] T107e [P] Update GetCategoriesQuery to filter out soft-deleted categories (WHERE IsDeleted = 0) in ae-infinity-api/src/AeInfinity.Application/Categories/Queries/GetCategories/GetCategoriesHandler.cs
- [ ] T107f [P] Add backend integration test: verify soft delete prevents permanent data removal in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/SoftDeleteTests.cs
- [ ] T107g [P] Add backend integration test: verify deletion blocked when items reference category in ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/DeletePreventionTests.cs
- [ ] T108 Code cleanup: Remove any mock data from categoriesService in ae-infinity-ui/src/services/categoriesService.ts
- [ ] T109 Code cleanup: Remove unused imports and console.logs across all category files
- [ ] T110 Run quickstart.md validation (follow all steps in quickstart.md and verify success)
- [ ] T111 Performance testing: Verify category retrieval < 300ms (p95)
- [ ] T112 Performance testing: Verify category creation < 500ms (p95)
- [ ] T113 Performance testing: Verify client-side filtering < 100ms
- [ ] T114 Security audit: Verify authentication is enforced for POST /categories
- [ ] T115 Security audit: Verify input validation prevents XSS in category names
- [ ] T116 [P] Update FEATURES.md to mark categories as "Integrated"
- [ ] T117 [P] Update README.md with categories feature status

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 (View Defaults): Can start after Foundational - No dependencies on other stories
  - US2 (Create Custom): Can start after Foundational - No dependencies on other stories (parallel with US1)
  - US3 (Filter Categories): Depends on US2 (need custom categories to test) - Can start after US2
  - US4 (Assign to Items): Depends on US1 (need categories) + Feature 004 (need items) - Can start after US1 if items exist
  - US5 (Filter Items): Depends on US4 (need categorized items) - Can start after US4
- **Polish (Phase 8)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories (PARALLEL with US1)
- **User Story 3 (P2)**: Can start after US2 - Needs custom categories to test filtering
- **User Story 4 (P1)**: Can start after US1 - Also requires Feature 004 (items) to be implemented
- **User Story 5 (P2)**: Can start after US4 - Needs categorized items to filter

### Within Each User Story

- Tests MUST be written and FAIL before implementation fixes
- Backend integration tests before backend verification
- Frontend tests before frontend verification
- Verification and fixes in sequence
- Manual E2E tests after automated tests pass
- Story complete before moving to next priority

### Parallel Opportunities

- **Setup Phase**: T003, T004, T005, T006, T008, T009, T010 can all run in parallel
- **Foundational Phase**: T012, T013, T014, T015, T016, T017 can run in parallel after T011
- **US1 Tests**: T018, T019, T020, T021, T022 can all run in parallel
- **US2 Tests**: T034-T042 can all run in parallel
- **US3 Tests**: T056, T057, T058 can run in parallel
- **US4 Tests**: T066-T071 can all run in parallel
- **US5 Tests**: T087, T088, T089 can run in parallel
- **Polish Phase**: Most tasks (T099-T109, T116-T117) can run in parallel
- **Cross-Story Parallelism**: US1 and US2 can be worked on simultaneously after Foundational phase

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Backend integration test: GET /categories unauthenticated" (T018)
Task: "Backend integration test: Verify default category seeding" (T019)
Task: "Backend integration test: Verify default category data" (T020)
Task: "Frontend component test: CategoryPicker displays categories" (T021)
Task: "Frontend service test: categoriesService.getAllCategories" (T022)

# Then proceed with sequential implementation verification:
Task: "Verify default category seeding" (T023)
Task: "Verify seeding is called on startup" (T024)
# ...and so on
```

---

## Parallel Example: User Story 2

```bash
# Launch all tests for User Story 2 together:
Task: "Backend integration test: POST /categories valid data" (T034)
Task: "Backend integration test: POST /categories duplicate name" (T035)
Task: "Backend integration test: POST /categories invalid color" (T036)
Task: "Backend integration test: POST /categories unauthenticated" (T037)
Task: "Backend unit test: CreateCategoryValidator name length" (T038)
Task: "Backend unit test: CreateCategoryValidator icon format" (T039)
Task: "Backend unit test: CreateCategoryValidator color format" (T040)
Task: "Frontend component test: CreateCategoryModal submits" (T041)
Task: "Frontend component test: CreateCategoryModal validation" (T042)
```

---

## Implementation Strategy

### MVP First (User Stories 1, 2, 4 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (View Defaults)
4. Complete Phase 4: User Story 2 (Create Custom)
5. Complete Phase 6: User Story 4 (Assign to Items)
6. **STOP and VALIDATE**: Test US1, US2, US4 independently
7. Deploy/demo MVP

**Note**: US4 requires Feature 004 (items) to be implemented first

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 4 → Test independently → Deploy/Demo (MVP!)
5. Add User Story 3 → Test independently → Deploy/Demo (filtering enhancement)
6. Add User Story 5 → Test independently → Deploy/Demo (item filtering enhancement)
7. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Tests T018-T022, Implementation T023-T033)
   - Developer B: User Story 2 (Tests T034-T042, Implementation T043-T055)
   - Developer C: User Story 4 prep (if items feature ready)
3. Stories complete and integrate independently
4. Then proceed with US3 and US5 sequentially (enhancement features)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing fixes
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- **CRITICAL**: Backend and frontend are already 100% implemented - focus on VERIFICATION, TESTING, and INTEGRATION
- **DEPENDENCY**: User Story 4 requires Feature 004 (items) to be complete
- Avoid: breaking existing implementation, skipping tests, cross-story dependencies that break independence

---

## Task Count Summary

- **Total Tasks**: 126
- **Setup (Phase 1)**: 10 tasks
- **Foundational (Phase 2)**: 7 tasks
- **User Story 1**: 16 tasks (5 tests + 11 implementation)
- **User Story 2**: 22 tasks (9 tests + 13 implementation)
- **User Story 3**: 7 tasks (3 tests + 4 implementation)
- **User Story 4**: 21 tasks (6 tests + 15 implementation)
- **User Story 5**: 9 tasks (3 tests + 6 implementation)
- **Polish (Phase 8)**: 28 tasks (includes soft delete, logging, search enhancements)

**Parallel Opportunities**: 50+ tasks can be executed in parallel (marked with [P])

**MVP Scope**: User Stories 1, 2, and 4 (54 tasks) - complete categories system with item integration

**Soft Delete & Enhancements**: 9 additional tasks (T105a, T107a-T107g) for FR-021, FR-022, FR-023, FR-024 compliance

**Estimated Timeline**: 6-9 days (per plan.md updated with soft delete) with single developer, 4-6 days with parallel team


