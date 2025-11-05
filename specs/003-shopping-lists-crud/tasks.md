# Implementation Tasks: Shopping Lists CRUD

**Feature**: 003-shopping-lists-crud  
**Branch**: feature/spec-kit-experiment (current branch)  
**Created**: 2025-11-05  
**Current Status**: 0% (backend 100% implemented, frontend integration needed)  
**Target**: Complete list management with full CRUD operations

---

## Task Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| Phase 1: Setup | 2 tasks | Environment verification |
| Phase 2: Foundation | 3 tasks | Backend verification and service layer prep |
| Phase 3: US1 - View Lists | 8 tasks | Dashboard with list viewing (P1 - MVP) |
| Phase 4: US2 - Create Lists | 6 tasks | List creation functionality (P1 - MVP) |
| Phase 5: US3 - Edit Lists | 5 tasks | List editing (P2) |
| Phase 6: US4 - Delete Lists | 4 tasks | List deletion with confirmation (P2) |
| Phase 7: US5 - Archive Lists | 6 tasks | Archive/unarchive functionality (P2) |
| Phase 8: US6 - Search/Filter/Sort | 7 tasks | Advanced list discovery (P3) |
| Phase 9: Integration | 4 tasks | Cross-story integration and polish |
| **Total** | **45 tasks** | Estimated: 2-3 days for P1+P2, +1 day for P3 |

---

## MVP Scope

**Minimum Viable Product (MVP)** = User Stories 1 + 2 (P1 only)

This delivers:
- ✅ Users can view all their lists (owned + shared)
- ✅ Users can create new lists with name and description
- ✅ Empty state handling
- ✅ Navigation to list details
- ✅ Basic list management

**Independent Test**: User logs in, sees existing lists, creates new list, navigates to it.

**Estimated Effort**: 1-1.5 days

---

## Task Breakdown

### **Phase 1: Setup** (30 minutes)

**Goal**: Verify environment and prerequisites

- [ ] T001 Verify backend API is running at http://localhost:5233 and Swagger accessible
- [ ] T002 Verify frontend is running at http://localhost:5173 and user can login with test account sarah@example.com

**Deliverables**: Both servers running, authenticated user session

---

### **Phase 2: Foundation** (1-2 hours)

**Goal**: Verify backend implementation and prepare frontend service layer

**BLOCKING**: These tasks must complete before user story phases

- [ ] T003 [P] Verify backend tests exist for all list endpoints and achieve 80%+ coverage in ae-infinity-api
- [ ] T004 [P] Verify listsService.ts has all required methods (getAllLists, createList, updateList, deleteList, archiveList, unarchiveList) in ae-infinity-ui/src/services/listsService.ts
- [ ] T005 [P] Verify TypeScript types exist for ShoppingListSummary, ShoppingListDetail, CreateListRequest, UpdateListRequest in ae-infinity-ui/src/types/index.ts

**Deliverables**: Backend verified working, frontend service layer confirmed ready

---

### **Phase 3: US1 - View My Shopping Lists (P1 - MVP)** (3-4 hours)

**Story Goal**: Users can view all accessible lists (owned + shared) in dashboard

**Why P1**: Entry point to application, delivers immediate value showing user's lists

**Independent Test**: Login → see dashboard with lists → click list → navigate to detail page → verify empty state works

**Acceptance Criteria**:
- User sees all owned and shared lists
- Each list card shows name, description, item counts, owner, last updated
- Empty state displays "No lists yet" with create button
- Pagination works for 50+ lists
- Click list card navigates to detail page

**Tasks**:

- [ ] T006 [US1] Replace mock data with API call in ListsDashboard.tsx: Add useEffect to call listsService.getAllLists() in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T007 [US1] Implement loading state in ListsDashboard.tsx: Add loading spinner while fetching lists in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T008 [US1] Implement error handling in ListsDashboard.tsx: Display error message if API call fails in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T009 [US1] Implement empty state in ListsDashboard.tsx: Show "No lists yet" message with create button when lists array is empty in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T010 [US1] Implement list card rendering in ListsDashboard.tsx: Map over lists array and render ListCard components with proper data in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T011 [US1] Add owner/shared badge in ListCard component: Display "Owner" or "Shared" badge based on current user vs ownerId in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T012 [US1] Implement list card click handler in ListsDashboard.tsx: Navigate to /lists/{listId} when user clicks list card in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T013 [US1] Verify US1 acceptance scenarios: Test all 5 scenarios from spec.md (view lists, empty state, navigation, owner badges, pagination)

**Deliverables**:
- Dashboard displays real lists from API
- Loading and error states work
- Empty state displays correctly
- Navigation to list detail works
- All US1 acceptance scenarios pass

---

### **Phase 4: US2 - Create New Shopping List (P1 - MVP)** (2-3 hours)

**Story Goal**: Users can create new lists with name (required) and optional description

**Why P1**: Core action - users need lists before they can add items

**Independent Test**: Navigate to create form → enter name → submit → see new list in dashboard → verify validation works

**Acceptance Criteria**:
- Create button accessible from dashboard
- Form has name (required) and description (optional) fields
- Validation prevents empty names and enforces 200 char max
- Successful creation navigates to new list detail page
- New list appears in dashboard with 0 items

**Tasks**:

- [ ] T014 [US2] Implement form submission in CreateList.tsx: Add handleSubmit to call listsService.createList() in ae-infinity-ui/src/pages/lists/CreateList.tsx
- [ ] T015 [US2] Add form validation in CreateList.tsx: Use React Hook Form to validate name (required, max 200 chars) and description (max 1000 chars) in ae-infinity-ui/src/pages/lists/CreateList.tsx
- [ ] T016 [US2] Implement loading state in CreateList.tsx: Disable submit button and show "Creating..." while API call in progress in ae-infinity-ui/src/pages/lists/CreateList.tsx
- [ ] T017 [US2] Implement success navigation in CreateList.tsx: Navigate to /lists/{newListId} after successful creation in ae-infinity-ui/src/pages/lists/CreateList.tsx
- [ ] T018 [US2] Implement error handling in CreateList.tsx: Display error message if API call fails in ae-infinity-ui/src/pages/lists/CreateList.tsx
- [ ] T019 [US2] Verify US2 acceptance scenarios: Test all 6 scenarios from spec.md (form display, successful creation, validation errors, navigation)

**Deliverables**:
- Create list form fully functional
- Form validation works (required name, length limits)
- Successful creation navigates to list detail
- New list appears in dashboard
- All US2 acceptance scenarios pass

**MVP Checkpoint**: After Phase 4, users can view and create lists - core value delivered

---

### **Phase 5: US3 - Edit List Details (P2)** (2-3 hours)

**Story Goal**: Owners and editors can update list name and description

**Why P2**: Important for list organization but not critical for MVP

**Independent Test**: Navigate to list settings → edit name/description → save → verify changes persist

**Acceptance Criteria**:
- Edit button accessible from list settings menu
- Form pre-filled with current name and description
- Changes save successfully and update UI
- Viewers don't see edit option (permission check)
- Cancel button discards changes

**Tasks**:

- [ ] T020 [US3] Implement edit form in ListSettings.tsx: Add form pre-filled with list.name and list.description in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T021 [US3] Add form submission in ListSettings.tsx: Call listsService.updateList(listId, data) on submit in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T022 [US3] Implement permission check in ListSettings.tsx: Hide edit button if user role is Viewer in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T023 [US3] Add success feedback in ListSettings.tsx: Show toast "List updated successfully" and refresh list data after save in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T024 [US3] Verify US3 acceptance scenarios: Test all 6 scenarios from spec.md (edit form, save changes, permission checks, cancel)

**Deliverables**:
- Edit form functional with pre-filled data
- Changes save and update UI
- Permission checks work (viewers can't edit)
- All US3 acceptance scenarios pass

---

### **Phase 6: US4 - Delete Shopping List (P2)** (1-2 hours)

**Story Goal**: Owners can delete lists with confirmation dialog

**Why P2**: Important for cleanup but not critical for initial launch

**Independent Test**: Navigate to list settings → click delete → confirm → verify list removed from dashboard

**Acceptance Criteria**:
- Delete button accessible from list settings (owner only)
- Confirmation dialog warns about permanent deletion
- Successful deletion redirects to dashboard
- List no longer appears in dashboard or detail pages
- Non-owners don't see delete option

**Tasks**:

- [ ] T025 [US4] Add delete button in ListSettings.tsx: Add delete button with confirmation dialog in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T026 [US4] Implement delete handler in ListSettings.tsx: Call listsService.deleteList(listId) after confirmation in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T027 [US4] Add permission check for delete in ListSettings.tsx: Only show delete button if user role is Owner in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T028 [US4] Verify US4 acceptance scenarios: Test all 6 scenarios from spec.md (confirmation dialog, delete success, permission checks, cascade delete)

**Deliverables**:
- Delete with confirmation works
- Deleted lists removed from UI
- Permission checks enforce owner-only deletion
- All US4 acceptance scenarios pass

---

### **Phase 7: US5 - Archive and Unarchive Lists (P2)** (2-3 hours)

**Story Goal**: Owners can archive lists to hide from main dashboard while preserving data

**Why P2**: Valuable for organization but not critical for MVP

**Independent Test**: Archive list from settings → verify hidden from dashboard → navigate to archived page → unarchive → verify restored

**Acceptance Criteria**:
- Archive button accessible from list settings (owner only)
- Archived lists hidden from main dashboard
- Archived Lists page shows all archived lists
- Unarchive button restores list to active status
- Include Archived toggle in dashboard filters

**Tasks**:

- [ ] T029 [US5] Add archive button in ListSettings.tsx: Add archive button that calls listsService.archiveList(listId) in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T030 [US5] Add permission check for archive in ListSettings.tsx: Only show archive button if user role is Owner in ae-infinity-ui/src/pages/lists/ListSettings.tsx
- [ ] T031 [US5] Update ListsDashboard to exclude archived by default: Pass includeArchived: false to getAllLists() in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T032 [US5] Implement ArchivedLists page integration: Replace mock data with listsService.getAllLists({ includeArchived: true }) filtered to archived only in ae-infinity-ui/src/pages/ArchivedLists.tsx
- [ ] T033 [US5] Add unarchive button in ArchivedLists.tsx: Add unarchive button that calls listsService.unarchiveList(listId) in ae-infinity-ui/src/pages/ArchivedLists.tsx
- [ ] T034 [US5] Verify US5 acceptance scenarios: Test all 6 scenarios from spec.md (archive, hide from dashboard, archived page, unarchive, permission checks)

**Deliverables**:
- Archive/unarchive functionality works
- Archived lists hidden from main dashboard
- Archived Lists page functional
- Permission checks enforce owner-only actions
- All US5 acceptance scenarios pass

---

### **Phase 8: US6 - Search, Filter, and Sort Lists (P3)** (3-4 hours)

**Story Goal**: Users can search, filter, and sort lists for better discovery

**Why P3**: Convenience for power users with many lists, not critical for MVP

**Independent Test**: Search for list by name → filter by owned/shared → sort by date/name → verify results update

**Acceptance Criteria**:
- Search input filters lists by name (case-insensitive)
- Filter options: All, Owned by me, Shared with me
- Include Archived toggle shows archived lists
- Sort options: Name A-Z, Name Z-A, Recently Updated, Recently Created, Most Items
- Settings persist in URL query params or localStorage

**Tasks**:

- [ ] T035 [P] [US6] Add search input in ListsDashboard.tsx: Add debounced search input (500ms delay) that filters lists by name in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T036 [P] [US6] Implement filter dropdown in ListsDashboard.tsx: Add filter dropdown with "All", "Owned by me", "Shared with me" options in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T037 [P] [US6] Add Include Archived toggle in ListsDashboard.tsx: Add toggle that passes includeArchived: true to API call in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T038 [P] [US6] Implement sort dropdown in ListsDashboard.tsx: Add sort dropdown with options (Name A-Z, Recently Updated, etc) that updates sortBy and sortOrder params in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T039 [US6] Implement URL query params for filters in ListsDashboard.tsx: Sync search/filter/sort state with URL query params for shareable links in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T040 [US6] Add "No results" message in ListsDashboard.tsx: Display "No lists found matching '[query]'" when search returns zero results in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T041 [US6] Verify US6 acceptance scenarios: Test all 7 scenarios from spec.md (search, filters, archived toggle, sorting, URL persistence)

**Deliverables**:
- Search filters lists by name
- Filter dropdown works (All, Owned, Shared)
- Include Archived toggle functional
- Sort dropdown updates list order
- Settings persist in URL
- All US6 acceptance scenarios pass

---

### **Phase 9: Integration & Polish** (2-3 hours)

**Goal**: Cross-story integration, performance optimization, and UI polish

**Tasks**:

- [ ] T042 [P] Add toast notifications for all list operations: Implement success/error toasts for create, update, delete, archive actions in ae-infinity-ui/src/pages/lists/
- [ ] T043 [P] Implement loading skeletons in ListsDashboard.tsx: Replace generic spinner with skeleton loaders for list cards in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T044 Add accessibility improvements: Ensure keyboard navigation, ARIA labels, and screen reader support in ae-infinity-ui/src/pages/lists/ListsDashboard.tsx
- [ ] T045 Verify mobile responsiveness: Test all list management pages on mobile viewports and fix layout issues in ae-infinity-ui/src/pages/lists/

**Deliverables**:
- User feedback (toasts) for all operations
- Loading states polished with skeletons
- Accessibility requirements met
- Mobile experience verified

---

## Dependency Graph

### Story Completion Order

```
Phase 1: Setup (BLOCKING ALL)
    ↓
Phase 2: Foundation (BLOCKING ALL USER STORIES)
    ↓
    ├── Phase 3: US1 (View Lists) ─────────────┐
    │       ↓                                   │
    │   Phase 4: US2 (Create Lists)            │
    │       ↓                                   │
    │   ═══════════════════════════════════    │
    │   MVP CHECKPOINT - Core value delivered  │
    │   ═══════════════════════════════════    │
    │                                           │
    ├── Phase 5: US3 (Edit Lists) ←───────────┤
    ├── Phase 6: US4 (Delete Lists) ←─────────┤
    ├── Phase 7: US5 (Archive Lists) ←────────┤
    └── Phase 8: US6 (Search/Filter) ←────────┘
            ↓
    Phase 9: Integration & Polish
```

**Key Dependencies**:
- **US1 (View Lists)** must complete before US2 (need to verify created lists appear)
- **US1 + US2** = MVP (sufficient to launch)
- **US3, US4, US5, US6** are independent of each other (can be done in parallel)
- **Phase 9** depends on all user stories completing

---

## Parallel Execution Opportunities

### Phase 2 - Foundation (ALL parallelizable)
```
├── T003 [P] Backend verification
├── T004 [P] Service layer verification  
└── T005 [P] Types verification
```
**3 tasks can run in parallel** (different verification areas)

### Phase 8 - US6 (4 tasks parallelizable)
```
├── T035 [P] Search input
├── T036 [P] Filter dropdown
├── T037 [P] Archive toggle
└── T038 [P] Sort dropdown
```
**4 UI components can be built in parallel** (no interdependencies)

### Phase 9 - Integration (2 tasks parallelizable)
```
├── T042 [P] Toast notifications
└── T043 [P] Loading skeletons
```
**2 polish tasks can run in parallel** (different UI concerns)

**Total Parallelizable Tasks**: 9 out of 45 tasks (20%)

---

## Testing Strategy

### Per-Story Testing

Each user story phase ends with a verification task testing all acceptance scenarios from spec.md:

- **T013**: Verify US1 (5 scenarios - view lists, empty state, navigation, badges, pagination)
- **T019**: Verify US2 (6 scenarios - form, validation, creation, navigation)
- **T024**: Verify US3 (6 scenarios - edit form, save, permissions, cancel)
- **T028**: Verify US4 (6 scenarios - delete, confirmation, permissions, cascade)
- **T034**: Verify US5 (6 scenarios - archive, unarchive, page navigation, permissions)
- **T041**: Verify US6 (7 scenarios - search, filters, sort, URL persistence)

**Total Acceptance Scenarios**: 36 scenarios across 6 user stories

### Integration Testing

After Phase 9, perform end-to-end testing:

1. **Create → View → Edit → Archive → Unarchive → Delete** flow
2. **Search → Filter → Sort** with various list counts
3. **Permission checks** (viewer vs editor vs owner)
4. **Error scenarios** (network failures, 404s, 403s)
5. **Mobile experience** on various viewports

---

## Implementation Strategy

### Incremental Delivery

**Week 1 - MVP (Phases 1-4)**:
- Day 1: Phase 1 + 2 (Setup and Foundation)
- Day 2-3: Phase 3 + 4 (US1 + US2)
- **Deliverable**: Users can view and create lists

**Week 2 - Core Features (Phases 5-7)**:
- Day 1: Phase 5 (US3 - Edit)
- Day 2: Phase 6 + 7 (US4 + US5 - Delete and Archive)
- **Deliverable**: Complete list management

**Week 3 - Polish (Phases 8-9)**:
- Day 1: Phase 8 (US6 - Search/Filter/Sort)
- Day 2: Phase 9 (Integration and Polish)
- **Deliverable**: Production-ready feature

### Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Backend API doesn't match expectations | T003 verifies backend early (Phase 2) |
| Service layer incomplete | T004-T005 verify service layer early (Phase 2) |
| Performance issues with 100+ lists | Phase 8 adds pagination, Phase 2 verifies it works |
| Permission bugs | Each phase with permissions has explicit permission check tasks |

---

## Definition of Done

### Per Task
- [ ] Code implemented and follows conventions
- [ ] No TypeScript errors or warnings
- [ ] Changes tested manually
- [ ] Related tests updated (if applicable)

### Per User Story Phase
- [ ] All tasks in phase complete
- [ ] Acceptance scenarios verified (spec.md)
- [ ] No console errors in browser
- [ ] Mobile responsive
- [ ] Accessibility checked (keyboard nav, ARIA)

### Overall Feature
- [ ] All 6 user stories complete
- [ ] 36 acceptance scenarios verified
- [ ] Integration testing passed
- [ ] Performance acceptable (dashboard < 1s load)
- [ ] Documentation updated (implementation status)
- [ ] Code review approved
- [ ] Deployed to staging

---

## Notes

### Backend Status
- ✅ All 7 endpoints implemented and working
- ✅ Database schema complete (ShoppingList entity)
- ✅ Authorization implemented (Owner/Editor/Viewer roles)
- ✅ Validation configured (FluentValidation)
- ⚠️ Test coverage unknown (verify in T003)

### Frontend Status
- ✅ UI components exist with mock data
- ✅ Service layer implemented (listsService.ts)
- ✅ Types defined (ShoppingListSummary, etc.)
- ❌ No API integration yet (all tasks in this file)

### Key Files to Modify
- `ae-infinity-ui/src/pages/lists/ListsDashboard.tsx` (US1, US6)
- `ae-infinity-ui/src/pages/lists/CreateList.tsx` (US2)
- `ae-infinity-ui/src/pages/lists/ListSettings.tsx` (US3, US4, US5)
- `ae-infinity-ui/src/pages/ArchivedLists.tsx` (US5)

### Recommended Approach
1. **Start with MVP** (US1 + US2) - provides core value
2. **Verify after each story** - run acceptance scenarios immediately
3. **Use quickstart.md** - code examples for each integration
4. **Test with real data** - create lists via Swagger, verify in UI
5. **Iterate on UX** - collect feedback after MVP, refine in Phase 9

---

**Tasks Status**: Ready for implementation  
**Next Action**: Begin Phase 1 (Setup) → T001 and T002

**Estimated Timeline**: 2-3 days for complete integration (MVP in 1-1.5 days)

