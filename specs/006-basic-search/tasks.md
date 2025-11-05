# Tasks: Basic Search

**Input**: Design documents from `/specs/006-basic-search/`  
**Prerequisites**: plan.md ✅, spec.md ✅, data-model.md ✅, contracts/ ✅, research.md ✅, quickstart.md ✅

**Tests**: Included (TDD approach per Constitution requirement)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

**Web application** (separate repositories):
- Backend: `ae-infinity-api/src/`
- Frontend: `ae-infinity-ui/src/`
- Backend tests: `ae-infinity-api/tests/`
- Frontend tests: `ae-infinity-ui/tests/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and search-specific structure

- [ ] T001 Verify backend repository `ae-infinity-api` is cloned and building
- [ ] T002 Verify frontend repository `ae-infinity-ui` is cloned and building
- [ ] T003 [P] Create backend search DTOs directory: `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/`
- [ ] T004 [P] Create backend search features directory: `ae-infinity-api/src/AeInfinity.Application/Features/Search/`
- [ ] T005 [P] Create frontend search components directory: `ae-infinity-ui/src/components/search/`
- [ ] T006 [P] Create frontend search hooks directory: `ae-infinity-ui/src/hooks/`
- [ ] T007 [P] Create frontend search types file: `ae-infinity-ui/src/types/search.ts`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core search infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Backend Foundation

- [ ] T008 Create SearchQueryParams DTO in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/SearchQueryParams.cs`
- [ ] T009 [P] Create SearchScope enum in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/SearchScope.cs`
- [ ] T010 [P] Create PaginationDto in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/PaginationDto.cs`
- [ ] T011 [P] Create SearchResultSet<T> generic DTO in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/SearchResultSet.cs`
- [ ] T012 Create SearchResponse DTO in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/SearchResponse.cs`
- [ ] T013 Create SearchQuery CQRS command in `ae-infinity-api/src/AeInfinity.Application/Features/Search/SearchQuery.cs`
- [ ] T014 Create SearchQueryValidator (FluentValidation) in `ae-infinity-api/src/AeInfinity.Application/Features/Search/SearchQueryValidator.cs`
- [ ] T015 Add database migration for search indexes in `ae-infinity-api/src/AeInfinity.Infrastructure/Data/Migrations/YYYYMMDDHHMMSS_AddSearchIndexes.cs`
- [ ] T016 Apply database migration and verify indexes on ShoppingLists.Name and ListItems.Name

### Frontend Foundation

- [ ] T017 [P] Create TypeScript search types in `ae-infinity-ui/src/types/search.ts`
- [ ] T018 [P] Create searchService in `ae-infinity-ui/src/services/searchService.ts`
- [ ] T019 [P] Create useDebounce hook in `ae-infinity-ui/src/hooks/useDebounce.ts`
- [ ] T020 Create useSearch hook in `ae-infinity-ui/src/hooks/useSearch.ts`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Search for Lists by Name (Priority: P1) 🎯 MVP

**Goal**: Users can quickly find lists by typing partial text, with results displayed instantly and highlighted

**Independent Test**: Create 10 lists with different names, search for "week", verify "Weekly Groceries" and "Weekend Camping" appear with "week" highlighted

### Tests for User Story 1 (TDD)

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T021 [P] [US1] Unit test for SearchQueryValidator in `ae-infinity-api/tests/AeInfinity.Application.Tests/Search/SearchQueryValidatorTests.cs`
- [ ] T022 [P] [US1] Integration test for SearchController (list search) in `ae-infinity-api/tests/AeInfinity.Api.IntegrationTests/SearchControllerTests.cs`
- [ ] T023 [P] [US1] Component test for SearchBar in `ae-infinity-ui/tests/components/search/SearchBar.test.tsx`

### Implementation for User Story 1

**Backend**:

- [ ] T024 [P] [US1] Create ListSearchResult DTO in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/ListSearchResult.cs`
- [ ] T025 [US1] Implement SearchHandler with list search logic in `ae-infinity-api/src/AeInfinity.Application/Features/Search/SearchHandler.cs`
- [ ] T026 [US1] Create SearchController with GET /api/search endpoint in `ae-infinity-api/src/AeInfinity.Api/Controllers/SearchController.cs`
- [ ] T027 [US1] Add permission filtering for accessible lists in SearchHandler
- [ ] T028 [US1] Add LIKE pattern escaping for special characters in SearchHandler
- [ ] T029 [US1] Add pagination logic for list results in SearchHandler

**Frontend**:

- [ ] T030 [P] [US1] Create SearchBar component in `ae-infinity-ui/src/components/search/SearchBar.tsx`
- [ ] T031 [P] [US1] Create ListSearchResult component in `ae-infinity-ui/src/components/search/ListSearchResult.tsx`
- [ ] T032 [US1] Create SearchResults component (lists section) in `ae-infinity-ui/src/components/search/SearchResults.tsx`
- [ ] T033 [US1] Create SearchPage with SearchBar integration in `ae-infinity-ui/src/pages/SearchPage.tsx`
- [ ] T034 [US1] Add /search route to App.tsx in `ae-infinity-ui/src/App.tsx`
- [ ] T035 [US1] Add search link to Header navigation in `ae-infinity-ui/src/components/layout/Header.tsx`

**Checkpoint**: At this point, list search should be fully functional - users can search for lists by name with debouncing, pagination, and permission filtering

---

## Phase 4: User Story 2 - Search for Items by Name (Priority: P1)

**Goal**: Users can find specific items across all accessible lists without manually checking each list

**Independent Test**: Create 3 lists with items, search for "milk", verify items from both "Weekly Groceries" and "Costco Trip" appear with parent list names

### Tests for User Story 2 (TDD)

- [ ] T036 [P] [US2] Integration test for item search in `ae-infinity-api/tests/AeInfinity.Api.IntegrationTests/SearchControllerTests.cs` (add test method)
- [ ] T037 [P] [US2] Component test for ItemSearchResult in `ae-infinity-ui/tests/components/search/ItemSearchResult.test.tsx`

### Implementation for User Story 2

**Backend**:

- [ ] T038 [P] [US2] Create ItemSearchResult DTO in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/ItemSearchResult.cs`
- [ ] T039 [P] [US2] Create ListRefDto in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/ListRefDto.cs`
- [ ] T040 [P] [US2] Create CategoryRefDto in `ae-infinity-api/src/AeInfinity.Application/DTOs/Search/CategoryRefDto.cs`
- [ ] T041 [US2] Add item search logic to SearchHandler in `ae-infinity-api/src/AeInfinity.Application/Features/Search/SearchHandler.cs`
- [ ] T042 [US2] Add search in item names and notes in SearchHandler
- [ ] T043 [US2] Add parent list context to item results in SearchHandler
- [ ] T044 [US2] Add pagination logic for item results in SearchHandler

**Frontend**:

- [ ] T045 [P] [US2] Create ItemSearchResult component in `ae-infinity-ui/src/components/search/ItemSearchResult.tsx`
- [ ] T046 [US2] Update SearchResults component to display items section in `ae-infinity-ui/src/components/search/SearchResults.tsx`
- [ ] T047 [US2] Add item click handler to navigate to parent list in ItemSearchResult component
- [ ] T048 [US2] Update useSearch hook to handle item results in `ae-infinity-ui/src/hooks/useSearch.ts`

**Checkpoint**: At this point, both list and item search should work - users can find items across all accessible lists with parent list context

---

## Phase 5: User Story 6 - Search Shared Lists and Items (Priority: P1)

**Goal**: Search includes all accessible content (owned + shared) with clear ownership indicators

**Independent Test**: Share a list with another user, have that user search for items in the shared list, verify they appear with "Shared by [Owner Name]" indicator

### Tests for User Story 6 (TDD)

- [ ] T049 [P] [US6] Integration test for shared list search in `ae-infinity-api/tests/AeInfinity.Api.IntegrationTests/SearchControllerTests.cs` (add test method)
- [ ] T050 [P] [US6] Integration test verifying permission filtering in `ae-infinity-api/tests/AeInfinity.Api.IntegrationTests/SearchControllerTests.cs` (add test method)

### Implementation for User Story 6

**Backend**:

- [ ] T051 [US6] Verify Collaborator relationship filtering in SearchHandler (should already be implemented from T027)
- [ ] T052 [US6] Add ownership indicators (isOwner, ownerName) to ListSearchResult mapping
- [ ] T053 [US6] Add ownership indicators to ItemSearchResult mapping
- [ ] T054 [US6] Add unit test for GetAccessibleListIds method in SearchHandler

**Frontend**:

- [ ] T055 [P] [US6] Add "Owner" or "Shared by [Name]" badge to ListSearchResult component
- [ ] T056 [P] [US6] Add owner indicator to ItemSearchResult parent list display
- [ ] T057 [US6] Update SearchResults component to show ownership badges
- [ ] T058 [US6] Add visual distinction between owned and shared results

**Checkpoint**: Search now includes shared content with clear ownership indicators - users see items from both owned and shared lists

---

## Phase 6: User Story 3 - Combined Search (Lists and Items) (Priority: P2)

**Goal**: Users see both matching lists and items in unified experience with grouped results

**Independent Test**: Create list "Groceries" and item "Grocery bags", search for "grocer", verify both appear in grouped sections

### Tests for User Story 3 (TDD)

- [ ] T059 [P] [US3] Integration test for combined search (scope=all) in `ae-infinity-api/tests/AeInfinity.Api.IntegrationTests/SearchControllerTests.cs` (add test method)
- [ ] T060 [P] [US3] Component test for SearchResults grouping in `ae-infinity-ui/tests/components/search/SearchResults.test.tsx`

### Implementation for User Story 3

**Backend**:

- [ ] T061 [US3] Verify SearchHandler returns both lists and items when scope=all (should already work from US1 + US2)
- [ ] T062 [US3] Add total count calculations for both result types in SearchResponse
- [ ] T063 [US3] Optimize combined search queries (consider performance)

**Frontend**:

- [ ] T064 [P] [US3] Add scope filter dropdown to SearchBar (All/Lists only/Items only)
- [ ] T065 [US3] Update SearchResults to show grouped sections with counts (e.g., "Lists (2)")
- [ ] T066 [US3] Add filter toggle buttons in SearchResults component
- [ ] T067 [US3] Update useSearch hook to handle scope parameter
- [ ] T068 [US3] Add "Show more items" button for limited combined results

**Checkpoint**: Combined search displays both lists and items with clear grouping and filtering options

---

## Phase 7: User Story 4 - Search Result Pagination (Priority: P2)

**Goal**: Users can navigate through large result sets efficiently without losing search context

**Independent Test**: Create 50 items with similar names, search to trigger pagination, navigate through pages while verifying page state is maintained in URL

### Tests for User Story 4 (TDD)

- [ ] T069 [P] [US4] Integration test for pagination (page 2, page 3) in `ae-infinity-api/tests/AeInfinity.Api.IntegrationTests/SearchControllerTests.cs` (add test method)
- [ ] T070 [P] [US4] Component test for SearchPagination in `ae-infinity-ui/tests/components/search/SearchPagination.test.tsx`

### Implementation for User Story 4

**Backend**:

- [ ] T071 [US4] Verify pagination logic in SearchHandler (should already work from T029, T044)
- [ ] T072 [US4] Add totalPages calculation in PaginationDto
- [ ] T073 [US4] Add hasNext and hasPrevious boolean flags
- [ ] T074 [US4] Handle edge cases (page exceeds total, page < 1)

**Frontend**:

- [ ] T075 [P] [US4] Create SearchPagination component in `ae-infinity-ui/src/components/search/SearchPagination.tsx`
- [ ] T076 [US4] Add pagination controls to SearchResults component
- [ ] T077 [US4] Update useSearch hook to preserve page state in URL query parameters
- [ ] T078 [US4] Add page number click handlers (jump to specific page)
- [ ] T079 [US4] Add Next/Previous button handlers
- [ ] T080 [US4] Add loading spinner during pagination

**Checkpoint**: Pagination works correctly for large result sets with state preserved in URL

---

## Phase 8: User Story 5 - Search Result Highlighting (Priority: P2)

**Goal**: Users easily identify which part of list/item names match their search term

**Independent Test**: Search for "gro", verify matching text "gro" in "Groceries" is highlighted with yellow background

### Tests for User Story 5 (TDD)

- [ ] T081 [P] [US5] Unit test for SearchHighlight component in `ae-infinity-ui/tests/components/search/SearchHighlight.test.tsx`
- [ ] T082 [P] [US5] Test special character escaping in SearchHighlight

### Implementation for User Story 5

**Backend**:

- [ ] T083 [US5] Verify special character escaping in SearchHandler (should already work from T028)

**Frontend**:

- [ ] T084 [P] [US5] Create SearchHighlight component with <mark> tag in `ae-infinity-ui/src/components/search/SearchHighlight.tsx`
- [ ] T085 [P] [US5] Create escapeRegex utility function in SearchHighlight
- [ ] T086 [US5] Apply SearchHighlight to list names in ListSearchResult component
- [ ] T087 [US5] Apply SearchHighlight to item names in ItemSearchResult component
- [ ] T088 [US5] Apply SearchHighlight to item notes preview (if matched)
- [ ] T089 [US5] Add WCAG AA compliant styling (yellow background #FFEB3B with dark text)
- [ ] T090 [US5] Add aria-label for screen reader support
- [ ] T091 [US5] Handle multi-word queries (highlight each word independently)

**Checkpoint**: Search results display highlighted matching text with accessibility support

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final validation

### Error Handling & Edge Cases

- [ ] T092 [P] Add empty query handling (display all results) in SearchHandler
- [ ] T093 [P] Add query length validation (max 200 chars) in SearchQueryValidator
- [ ] T094 [P] Add error boundary for SearchPage in `ae-infinity-ui/src/pages/SearchPage.tsx`
- [ ] T095 [P] Add offline error handling in searchService
- [ ] T096 [P] Add timeout error handling (10 seconds) in useSearch hook
- [ ] T097 Add "No results found" empty state in SearchResults component
- [ ] T098 Add loading spinner in SearchResults component

### Performance Optimization

- [ ] T099 [P] Verify database indexes exist and are used (query plan analysis)
- [ ] T100 [P] Add client-side result caching (5 minutes) in useSearch hook
- [ ] T101 [P] Measure and log slow queries (> 2 seconds) in SearchHandler
- [ ] T102 Performance test with 10,000 items, verify <500ms response time
- [ ] T103 Verify debouncing reduces API calls by 80% (before/after metrics)

### Documentation & Integration

- [ ] T104 [P] Update FEATURES.md - set Feature 006 to 100% complete
- [ ] T105 [P] Update API_REFERENCE.md with GET /api/search endpoint documentation
- [ ] T106 [P] Add search demo screenshot to README.md
- [ ] T107 [P] Run quickstart.md validation checklist
- [ ] T108 Update ARCHITECTURE.md with search implementation details

### Final Validation

- [ ] T109 Run all backend tests (unit + integration) - must pass 100%
- [ ] T110 Run all frontend tests (component + integration) - must pass 100%
- [ ] T111 Verify test coverage meets 80% minimum (backend + frontend)
- [ ] T112 End-to-end test: Complete user journey from login → search → navigate to list
- [ ] T113 Accessibility test: Screen reader announcement, keyboard navigation, color contrast
- [ ] T114 Cross-browser testing (Chrome, Firefox, Safari)
- [ ] T115 Mobile responsiveness testing

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phases 3-8)**: All depend on Foundational phase completion
  - US1 (Phase 3): List search - No dependencies on other stories
  - US2 (Phase 4): Item search - No dependencies on other stories (can parallel with US1)
  - US6 (Phase 5): Shared content - Builds on US1+US2 (extends them)
  - US3 (Phase 6): Combined search - Depends on US1+US2 being functional
  - US4 (Phase 7): Pagination - Depends on US1+US2 being functional
  - US5 (Phase 8): Highlighting - Can parallel with any story (UI-only)
- **Polish (Phase 9)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - Independently testable ✅
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - Independently testable ✅
- **User Story 6 (P1)**: Can start after US1+US2 (extends permission filtering) - Independently testable ✅
- **User Story 3 (P2)**: Depends on US1+US2 functional (combines them) - Independently testable ✅
- **User Story 4 (P2)**: Depends on US1+US2 functional (paginates them) - Independently testable ✅
- **User Story 5 (P2)**: Can parallel with any story (UI enhancement) - Independently testable ✅

### Within Each User Story

- Tests MUST be written and FAIL before implementation (TDD)
- DTOs before CQRS handlers
- CQRS handlers before controllers
- Backend before frontend
- Components before integration
- Story complete before moving to next priority

### Parallel Opportunities

**Setup Phase (Phase 1)**:
- T003, T004, T005, T006, T007 can all run in parallel

**Foundational Phase (Phase 2)**:
- Backend: T009, T010, T011 can run in parallel (independent DTOs)
- Frontend: T017, T018, T019 can run in parallel (independent files)

**User Story Phases**:
- After Foundational complete, US1 and US2 can be developed in parallel (independent stories)
- US5 (highlighting) can be developed in parallel with any other story (UI-only)

**Within Each Story**:
- All tests for a story can be written in parallel (T021, T022, T023 for US1)
- All DTOs for a story can be created in parallel (T024 for US1; T038, T039, T040 for US2)
- All frontend components for a story can be built in parallel after services exist

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (TDD - write tests first):
T021: "Unit test for SearchQueryValidator"
T022: "Integration test for SearchController (list search)"
T023: "Component test for SearchBar"

# Run tests - VERIFY THEY FAIL before implementation

# Launch backend DTOs in parallel:
T024: "Create ListSearchResult DTO"
# (No other DTOs needed for US1)

# Launch frontend components in parallel (after backend services exist):
T030: "Create SearchBar component"
T031: "Create ListSearchResult component"
```

---

## Parallel Example: User Story 2

```bash
# Tests first (TDD):
T036: "Integration test for item search"
T037: "Component test for ItemSearchResult"

# Backend DTOs in parallel:
T038: "Create ItemSearchResult DTO"
T039: "Create ListRefDto"
T040: "Create CategoryRefDto"

# Frontend components in parallel:
T045: "Create ItemSearchResult component"
```

---

## Implementation Strategy

### MVP First (User Stories 1, 2, 6 Only - All P1)

**Estimated Time: 2-3 days**

1. Complete Phase 1: Setup (0.5 hours)
2. Complete Phase 2: Foundational (4-6 hours - CRITICAL)
3. Complete Phase 3: User Story 1 - List Search (4-6 hours)
4. Complete Phase 4: User Story 2 - Item Search (4-6 hours)
5. Complete Phase 5: User Story 6 - Shared Content (2-3 hours)
6. **STOP and VALIDATE**: Test all P1 stories independently
7. Deploy/demo MVP

**MVP Deliverable**: Users can search for lists and items (including shared) with debouncing, pagination, and permission filtering. This is a complete, production-ready feature.

### Incremental Delivery (Add P2 Stories)

**Estimated Time: +1-2 days for P2 features**

1. Complete MVP (US1, US2, US6) → Foundation ready ✅
2. Add User Story 3: Combined Search (4 hours) → Test independently → Deploy/Demo
3. Add User Story 4: Pagination UI (2-3 hours) → Test independently → Deploy/Demo
4. Add User Story 5: Highlighting (2-3 hours) → Test independently → Deploy/Demo
5. Complete Phase 9: Polish (4-6 hours) → Final validation

**Full Feature Deliverable**: Complete search experience with grouped results, pagination UI, and highlighting.

### Parallel Team Strategy

With 2-3 developers:

1. **Together**: Complete Setup (Phase 1) + Foundational (Phase 2) - **CRITICAL** ✅
2. **Once Foundational is done** (parallel development):
   - Developer A: User Story 1 (List Search)
   - Developer B: User Story 2 (Item Search)
3. **After US1+US2 complete**:
   - Developer A: User Story 6 (Shared Content - extends US1+US2)
   - Developer B: User Story 5 (Highlighting - independent)
   - Developer C (if available): User Story 4 (Pagination - independent)
4. **After P1 complete**:
   - Developer A or B: User Story 3 (Combined Search)
5. **All together**: Phase 9 (Polish & Validation)

---

## Task Summary

### By Phase

| Phase | Tasks | Parallel Tasks | Estimated Time |
|-------|-------|----------------|----------------|
| Phase 1: Setup | 7 | 5 (T003-T007) | 0.5 hours |
| Phase 2: Foundational | 13 | 8 (T009-T011, T017-T019) | 4-6 hours |
| Phase 3: US1 (P1) | 15 | 5 (T021-T023, T030-T031) | 4-6 hours |
| Phase 4: US2 (P1) | 13 | 6 (T036-T037, T038-T040, T045) | 4-6 hours |
| Phase 5: US6 (P1) | 8 | 4 (T049-T050, T055-T056) | 2-3 hours |
| Phase 6: US3 (P2) | 8 | 1 (T064) | 3-4 hours |
| Phase 7: US4 (P2) | 12 | 2 (T069-T070, T075) | 3-4 hours |
| Phase 8: US5 (P2) | 9 | 4 (T081-T082, T084-T085) | 2-3 hours |
| Phase 9: Polish | 24 | 12 (marked [P]) | 4-6 hours |
| **TOTAL** | **109 tasks** | **47 parallel** | **27-39 hours** |

### By Priority

| Priority | User Stories | Tasks | Estimated Time |
|----------|--------------|-------|----------------|
| **P1 (MVP)** | US1, US2, US6 | 56 tasks (Phases 1-5) | 15-21 hours (2-3 days) |
| **P2 (Enhanced)** | US3, US4, US5 | 29 tasks (Phases 6-8) | 8-11 hours (1-1.5 days) |
| **Polish** | Cross-cutting | 24 tasks (Phase 9) | 4-6 hours (0.5-1 day) |
| **TOTAL** | 6 stories | 109 tasks | 27-39 hours (3.5-5 days) |

### Independent Testing

Each user story has clear independent test criteria:

- ✅ **US1**: Search "week" in 10 lists, verify "Weekly Groceries" and "Weekend Camping" appear
- ✅ **US2**: Search "milk" in 3 lists, verify items from multiple lists appear with parent list names
- ✅ **US6**: Share list, search as collaborator, verify shared items appear with "Shared by [Name]"
- ✅ **US3**: Search "grocer", verify both list "Groceries" and item "Grocery bags" appear grouped
- ✅ **US4**: Trigger pagination with 50 items, navigate pages, verify state in URL
- ✅ **US5**: Search "gro", verify "gro" highlighted in "Groceries" with yellow background

---

## Notes

- **[P] tasks** = different files, no dependencies, can run in parallel
- **[Story] label** maps task to specific user story for traceability
- **TDD enforced**: Tests must be written and fail before implementation (per Constitution)
- **Each user story is independently testable**: Can validate story works without others
- **MVP = P1 stories only**: Focus on US1, US2, US6 for production-ready feature
- **Foundational phase is CRITICAL**: No user stories can start until Phase 2 complete
- **Backend before frontend**: Complete backend for a story before starting frontend
- **Commit frequently**: After each task or logical group
- **Stop at checkpoints**: Validate story independently before moving to next
- **Performance targets**: <500ms search response, 80% API call reduction via debouncing

---

**Total Tasks**: 109  
**Parallel Opportunities**: 47 tasks marked [P]  
**Estimated Duration**: 3.5-5 days (with MVP in 2-3 days)  
**MVP Scope**: Phases 1-5 (User Stories 1, 2, 6)  
**Ready to implement**: ✅ YES

