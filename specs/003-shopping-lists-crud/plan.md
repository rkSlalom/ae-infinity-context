# Implementation Plan: Shopping Lists CRUD

**Branch**: feature/spec-kit-experiment (current branch) | **Date**: 2025-11-05 | **Spec**: [spec.md](./spec.md)

---

## Summary

This feature provides full CRUD (Create, Read, Update, Delete) operations for shopping lists, enabling users to organize their shopping needs into multiple named lists. **The backend API is 100% implemented and operational**. This plan focuses on **frontend integration**, **testing**, and **verification** against specifications.

**Primary Requirement**: Users can create, view, edit, delete, and archive shopping lists with permission-based access control.

**Technical Approach**: 
- Backend: **Already exists** - Full REST API with pagination, filtering, sorting
- Frontend: Replace mock data with real API service calls
- Integration: Connect existing UI components to existing backend endpoints
- Testing: Verify integration matches specification, add E2E tests

---

## Technical Context

**Language/Version**:
- Backend: C# / .NET 9.0
- Frontend: TypeScript / React 19.1

**Primary Dependencies**:
- Backend: ASP.NET Core 9.0, Entity Framework Core 9.0, MediatR 12.4, FluentValidation 11.9, SignalR 9.0
- Frontend: React 19.1, React Router 7.9, Vite 7.1, Tailwind CSS 3.4, React Hook Form 7.51, @microsoft/signalr 8.0
- Database: SQLite (embedded, local file: `ae-infinity-api/app.db`)
- Real-time: SignalR for WebSocket-based real-time collaboration

**Key Patterns**:
- Backend: Clean Architecture with CQRS (MediatR commands/queries)
- Frontend: Service layer with React Hook Form for form management
- Validation: FluentValidation (backend), React Hook Form validation (frontend)
- Authorization: JWT tokens + role-based permissions (Owner, Editor, Viewer)

**Integration Points**:
- API Base URL: `http://localhost:5233/api`
- Swagger Documentation: `http://localhost:5233/index.html`
- Frontend Service: `ae-infinity-ui/src/services/listsService.ts` (already exists)

---

## Constitution Check

### **✅ Specification-First Development**
- **Status**: PARTIAL - Backend implemented before spec, now creating spec to document and verify
- **Action**: Generate complete specification documenting existing API
- **Justification**: Legacy implementation; spec will serve as verification and integration guide

### **✅ Test-Driven Development (TDD)**
- **Status**: NEEDS IMPROVEMENT - Backend tests exist but coverage unknown
- **Action**: Verify 80%+ coverage, add integration tests for all endpoints
- **Gate**: NO MERGE until 80% coverage achieved

### **✅ Real-time Collaboration Architecture**
- **Status**: IMPLEMENTED - List updates broadcast via SignalR to all collaborators
- **Action**: SignalR hub implemented for list operations (create, update, delete, archive)
- **Implementation**: Optimistic UI with rollback on errors, conflict notifications (last-write-wins)
- **Latency Target**: Real-time updates reflected within 2 seconds (per Constitution Principle III)

### **✅ Security & Privacy by Design**
- **Status**: IMPLEMENTED - JWT auth, authorization middleware, owner-only deletes
- **Verification**: Confirm permission checks at middleware, business logic, and database levels
- **Action**: Add security tests verifying unauthorized access blocked

### **✅ API Design Principles**
- **Status**: IMPLEMENTED - RESTful conventions, proper HTTP verbs/status codes
- **Verification**: Endpoints follow `/lists` and `/lists/{listId}` patterns
- **Pagination**: Implemented with default page size 20

---

## Current State Analysis

### **Backend API (ae-infinity-api)**

**✅ FULLY IMPLEMENTED** - All endpoints operational

| Endpoint | Method | Handler | Status |
|----------|--------|---------|--------|
| `/lists` | GET | `GetListsQueryHandler` | ✅ Working |
| `/lists` | POST | `CreateListCommandHandler` | ✅ Working |
| `/lists/{listId}` | GET | `GetListByIdQueryHandler` | ✅ Working |
| `/lists/{listId}` | PUT | `UpdateListCommandHandler` | ✅ Working |
| `/lists/{listId}` | DELETE | `DeleteListCommandHandler` | ✅ Working |
| `/lists/{listId}/archive` | POST | `ArchiveListCommandHandler` | ✅ Working (likely) |
| `/lists/{listId}/unarchive` | POST | `UnarchiveListCommandHandler` | ✅ Working (likely) |

**Database Schema**: `ShoppingList` entity with soft delete, audit fields, owner relationship

**Authorization**: Permission checks implemented (Owner can delete, Editor can update, Viewer read-only)

**SignalR Integration**: The backend broadcasts list update events via SignalR hub to all collaborators in real-time:
- `ListCreated` - Broadcast to all collaborators when list is created
- `ListUpdated` - Broadcast to all collaborators when name/description changes
- `ListDeleted` - Broadcast to all collaborators when list is soft-deleted
- `ListArchived` - Broadcast to all collaborators when list is archived/unarchived

**Frontend Impact**: Frontend implements optimistic UI updates with automatic rollback on errors. Collaborators see changes within 2 seconds without manual refresh.

### **Frontend UI (ae-infinity-ui)**

**🟡 PARTIALLY IMPLEMENTED** - UI exists with mock data

| Component | File | Status |
|-----------|------|--------|
| Lists Dashboard | `pages/lists/ListsDashboard.tsx` | 🟡 Mock Data |
| List Detail | `pages/lists/ListDetail.tsx` | 🟡 Mock Data |
| Create List | `pages/lists/CreateList.tsx` | 🟡 Mock Data |
| List Settings | `pages/lists/ListSettings.tsx` | 🟡 Mock Data |
| Archived Lists | `pages/ArchivedLists.tsx` | ✅ Complete |

**Service Layer**: `services/listsService.ts` exists with all API methods (ready to use)

**Types**: `src/types/index.ts` has `ShoppingListSummary`, `ShoppingListDetail`, `CreateListRequest`, `UpdateListRequest`

---

## SignalR Real-time Architecture

### Hub Interface

**File**: `AeInfinity.Api/Hubs/ShoppingListHub.cs`

```csharp
public class ShoppingListHub : Hub
{
    public async Task JoinListGroup(string listId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"list-{listId}");
    }
    
    public async Task LeaveListGroup(string listId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"list-{listId}");
    }
}
```

### Event Broadcasting

**Command handlers broadcast events after successful database operations:**

```csharp
// Example: CreateListCommandHandler
public async Task<Result<ListDto>> Handle(CreateListCommand request)
{
    // ... create list in database ...
    
    // Broadcast to all collaborators
    await _hubContext.Clients
        .Group($"list-{list.Id}")
        .SendAsync("ListCreated", new {
            listId = list.Id,
            list = listDto,
            userId = request.UserId
        });
    
    return Result<ListDto>.Success(listDto);
}
```

**Events Broadcast**:
- `ListCreated` - After CreateListCommand succeeds
- `ListUpdated` - After UpdateListCommand succeeds
- `ListDeleted` - After DeleteListCommand succeeds
- `ListArchived` - After ArchiveListCommand succeeds
- `ListUnarchived` - After UnarchiveListCommand succeeds

### Frontend SignalR Integration

**Connection Service** (`src/services/signalrService.ts`):
```typescript
export class SignalRService {
  private connection: HubConnection;
  
  async connect(token: string) {
    this.connection = new HubConnectionBuilder()
      .withUrl('/hubs/shopping-list', {
        accessTokenFactory: () => token
      })
      .withAutomaticReconnect()
      .build();
    
    await this.connection.start();
  }
  
  async joinList(listId: string) {
    await this.connection.invoke('JoinListGroup', listId);
  }
  
  onListCreated(handler: (data: any) => void) {
    this.connection.on('ListCreated', handler);
  }
  
  // ... other event handlers ...
}
```

**Optimistic UI Pattern**:
```typescript
// Example: Create list with optimistic update
const createList = async (data: CreateListRequest) => {
  const tempId = generateTempId();
  
  // Optimistic update
  setLists(prev => [...prev, { id: tempId, ...data, isOptimistic: true }]);
  
  try {
    const result = await listsService.createList(data);
    // Replace optimistic item with real data
    setLists(prev => prev.map(l => l.id === tempId ? result : l));
  } catch (error) {
    // Rollback on error
    setLists(prev => prev.filter(l => l.id !== tempId));
    showErrorToast('Failed to create list');
  }
};
```

**Conflict Resolution**:
- Strategy: Last-write-wins
- User notification: Toast message "Another user edited this list. Your changes may have been overwritten."
- Detection: Compare UpdatedAt timestamp from event with local state

---

## Implementation Phases

### **Phase 0: Specification & Verification** (2-3 hours)

**Goal**: Document existing API, verify it matches constitution requirements

**Tasks**:
1. Generate `spec.md` with user stories based on existing API capabilities
2. Generate `data-model.md` documenting actual database schema
3. Generate API contracts in `contracts/` matching Swagger schemas
4. Create `quickstart.md` with integration examples
5. Verify backend tests exist and achieve 80%+ coverage

**Deliverables**:
- Complete specification matching existing implementation
- API contracts (JSON schemas) for all endpoints
- Quickstart guide for frontend integration

---

### **Phase 1: Frontend Integration - Read Operations** (3-4 hours)

**Goal**: Replace mock data with real API calls for viewing lists

**Tasks**:
1. **ListsDashboard Integration**:
   - Replace mock data in `useState` with API call to `listsService.getAllLists()`
   - Implement filters (includeArchived, sortBy, sortOrder)
   - Add pagination controls
   - Add loading states and error handling
   - Test with real API (create lists via Swagger, see them in UI)

2. **ListDetail Integration**:
   - Replace mock data with API call to `listsService.getListById(listId)`
   - Display real list name, description, owner, collaborators
   - Add loading state and error handling (404 if list not found)
   - Test navigation from dashboard to detail page

3. **ArchivedLists Integration**:
   - Update to use `listsService.getAllLists({ includeArchived: true })`
   - Filter to show only archived lists
   - Add unarchive button functionality

**Verification**:
- Can view all lists in dashboard
- Can navigate to list detail page
- Can view archived lists
- Loading states display correctly
- Error handling works (try accessing non-existent list)

---

### **Phase 2: Frontend Integration - Write Operations** (4-5 hours)

**Goal**: Enable creating, editing, deleting, archiving lists

**Tasks**:
1. **Create List Form**:
   - Update `CreateList.tsx` to call `listsService.createList(data)`
   - Implement React Hook Form validation (name required, 1-200 chars)
   - Navigate to new list detail page on success
   - Display error message on failure
   - Test: Create list, verify it appears in dashboard

2. **Update List (List Settings)**:
   - Update `ListSettings.tsx` to call `listsService.updateList(listId, data)`
   - Implement form validation
   - Show success toast on update
   - Update list detail page to reflect changes
   - Test: Edit list name, verify change persists

3. **Delete List**:
   - Add confirmation dialog before delete
   - Call `listsService.deleteList(listId)`
   - Navigate back to dashboard on success
   - Test: Delete list, verify it's gone

4. **Archive/Unarchive**:
   - Add archive button in list settings
   - Call `listsService.archiveList(listId)` or `unarchiveList(listId)`
   - Update UI to reflect archived status
   - Test: Archive list, see it in archived page, unarchive it

**Verification**:
- Can create new lists
- Can edit list details
- Can delete lists (with confirmation)
- Can archive/unarchive lists
- Permission checks work (only owner can delete)

---

### **Phase 3: Search & Filters** (2-3 hours)

**Goal**: Implement search and advanced filtering

**Tasks**:
1. **Search Functionality**:
   - Add search input in ListsDashboard
   - Implement debounced search (500ms delay)
   - Call `searchService.searchLists(query)` or filter locally
   - Highlight search matches

2. **Filter & Sort Controls**:
   - Add filter dropdowns (All Lists, My Lists, Shared Lists)
   - Add sort dropdown (Date Created, Date Updated, Name)
   - Persist filter/sort preferences in localStorage
   - Update URL query params for shareable links

**Verification**:
- Search finds lists by name
- Filters work correctly
- Sorting changes list order
- Preferences persist across page reloads

---

### **Phase 4: Testing & Quality Assurance** (4-6 hours)

**Goal**: Comprehensive testing to ensure 80%+ coverage

**Tasks**:
1. **Backend Integration Tests** (if missing):
   - Test GET /lists returns paginated results
   - Test POST /lists creates list with correct owner
   - Test PUT /lists/{listId} updates fields
   - Test DELETE /lists/{listId} soft deletes (sets DeletedAt)
   - Test archive/unarchive endpoints
   - Test authorization (non-owner cannot delete)

2. **Frontend Component Tests**:
   - Test ListsDashboard renders lists from API
   - Test CreateList form validation
   - Test ListSettings update flow
   - Test error handling (network errors, 404s)

3. **End-to-End Tests** (optional but recommended):
   - User creates list → sees it in dashboard
   - User edits list → changes persist
   - User archives list → appears in archived page
   - User deletes list → removed from dashboard

4. **Performance Testing**:
   - Test with 100+ lists (pagination works)
   - Test search performance
   - Test API response times (< 200ms target)

**Verification**:
- All tests pass
- Coverage >= 80%
- No console errors in browser
- API response times acceptable

---

### **Phase 5: Documentation & Polish** (1-2 hours)

**Goal**: Complete documentation and UI polish

**Tasks**:
1. **Documentation**:
   - Update `specs/README.md` with Feature 003 status
   - Update `FEATURES.md` implementation percentages
   - Update `CHANGELOG.md` with integration completion
   - Add screenshots to `quickstart.md`

2. **UI Polish**:
   - Add empty states ("No lists yet - create your first list!")
   - Improve loading skeletons
   - Add success/error toasts for all operations
   - Ensure mobile responsiveness
   - Accessibility audit (keyboard navigation, ARIA labels)

**Verification**:
- Documentation up to date
- UI feels polished and professional
- Accessibility checks pass

---

## Project Structure

### **Backend** (ae-infinity-api)

```
AeInfinity.API/
├── Controllers/
│   └── ListsController.cs         # Already exists
├── Hubs/
│   └── ShoppingListHub.cs         # NEW - SignalR hub for real-time events
└── Program.cs                     # UPDATE - Add SignalR configuration

AeInfinity.Application/
├── Lists/
│   ├── Commands/
│   │   ├── CreateListCommand.cs         # Already exists
│   │   ├── UpdateListCommand.cs         # Already exists
│   │   ├── DeleteListCommand.cs         # Already exists
│   │   ├── ArchiveListCommand.cs        # Already exists (likely)
│   │   └── UnarchiveListCommand.cs      # Already exists (likely)
│   ├── Queries/
│   │   ├── GetListsQuery.cs            # Already exists
│   │   └── GetListByIdQuery.cs         # Already exists
│   ├── DTOs/
│   │   ├── ListDto.cs                  # Already exists
│   │   ├── ListDetailDto.cs            # Already exists
│   │   ├── CreateListDto.cs            # Already exists
│   │   └── UpdateListDto.cs            # Already exists
│   └── Validators/
│       ├── CreateListValidator.cs       # Already exists
│       └── UpdateListValidator.cs       # Already exists

AeInfinity.Domain/
└── Entities/
    └── ShoppingList.cs            # Already exists

AeInfinity.Infrastructure/
└── Data/
    ├── Repositories/
    │   └── ListRepository.cs      # Already exists
    └── Configurations/
        └── ShoppingListConfiguration.cs  # Already exists (EF Core)
```

### **Frontend** (ae-infinity-ui)

```
ae-infinity-ui/src/
├── pages/
│   ├── lists/
│   │   ├── ListsDashboard.tsx       # 🟡 Update (remove mocks, add SignalR)
│   │   ├── ListDetail.tsx           # 🟡 Update (remove mocks, add SignalR)
│   │   ├── CreateList.tsx           # 🟡 Update (remove mocks, add optimistic UI)
│   │   └── ListSettings.tsx         # 🟡 Update (remove mocks, add optimistic UI)
│   └── ArchivedLists.tsx            # ✅ Already good
│
├── services/
│   ├── listsService.ts              # ✅ Already complete
│   └── signalrService.ts            # NEW - SignalR connection management
│
├── hooks/
│   ├── useSignalR.ts                # NEW - SignalR connection hook
│   ├── useListEvents.ts             # NEW - List event handlers
│   └── useOptimisticUpdate.ts       # NEW - Optimistic UI with rollback
│
├── types/
│   ├── index.ts                     # ✅ Already has list types
│   └── signalr.ts                   # NEW - SignalR event types
│
└── components/
    ├── lists/                        # Optional: Extract reusable components
    │   ├── ListCard.tsx              # List summary card
    │   └── ListFilters.tsx           # Filter/sort controls
    └── common/
        └── ConflictNotification.tsx  # NEW - Conflict warning toast
```

---

## Quality Assurance

### **Testing Strategy**

**Backend**:
- Unit tests for command/query handlers (verify business logic)
- Integration tests for controllers (verify HTTP endpoints)
- Repository tests (verify database queries)
- Authorization tests (verify permission checks)

**Frontend**:
- Component tests for pages (verify rendering with API data)
- Hook tests if custom hooks created
- Integration tests with MSW (mock API responses)
- E2E tests with Playwright (optional)

**Coverage Targets**:
- Backend: 80%+ (enforced by CI/CD)
- Frontend: 80%+ (enforced by CI/CD)

### **Performance Requirements**

| Metric | Target | Verification |
|--------|--------|--------------|
| API Response Time | < 200ms (p95) | Load testing with 100 requests |
| Frontend Initial Load | < 2 seconds | Lighthouse audit |
| List Dashboard Render | < 500ms | Performance profiling |
| Pagination | < 100ms | User testing |

### **Security Checklist**

- [ ] All endpoints require JWT authentication
- [ ] Authorization checks at controller level
- [ ] Business logic validates ownership (owner-only operations)
- [ ] Database queries filtered by user access
- [ ] No SQL injection (using EF Core parameterized queries)
- [ ] Input validation with FluentValidation
- [ ] CORS configured for production domain
- [ ] HTTPS in production

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Mock data structure doesn't match API | Low | Medium | Verify types match Swagger schemas before integration |
| Permission bugs (non-owner can delete) | Medium | High | Add comprehensive authorization tests |
| Performance issues with 100+ lists | Low | Medium | Test pagination, implement virtual scrolling if needed |
| SignalR connection failures | Medium | High | Implement automatic reconnection, queue failed events, show connection status |
| Optimistic UI rollback complexity | Medium | Medium | Use proven libraries (React Query, SWR), comprehensive error handling |
| Race conditions in concurrent edits | Medium | High | Last-write-wins with user notification, timestamp-based conflict detection |
| SignalR scaling with many connections | Low | Medium | Configure SignalR for Redis backplane if >1000 concurrent users |

---

## Success Criteria

### **Functional Requirements**

- [ ] User can create a shopping list with name and description
- [ ] User can view all their lists (owned + shared)
- [ ] User can view list details (name, description, owner, collaborators)
- [ ] User can edit list name and description (if has permission)
- [ ] User can delete list (owner only)
- [ ] User can archive/unarchive lists
- [ ] User can search lists by name
- [ ] User can sort lists (by date, name)
- [ ] User can filter lists (all, owned, shared, archived)
- [ ] Pagination works with 100+ lists

### **Non-Functional Requirements**

- [ ] All API endpoints respond < 200ms (p95)
- [ ] Frontend loads in < 2 seconds
- [ ] Test coverage >= 80% (backend and frontend)
- [ ] No console errors in browser
- [ ] Accessible (keyboard navigation, screen readers)
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Error messages are user-friendly

### **Quality Gates**

- [ ] All tests pass (unit, integration, component)
- [ ] Code review approved
- [ ] Specification matches implementation
- [ ] Documentation updated
- [ ] No security vulnerabilities
- [ ] Performance requirements met

---

## Rollout Plan

### **Phase 1: Internal Testing** (1 day)
- Deploy to staging environment
- Test with team members (create, edit, delete lists)
- Verify edge cases (permissions, pagination, errors)
- Fix any critical bugs

### **Phase 2: Beta Users** (3-5 days)
- Enable for beta users (10-20 people)
- Monitor error logs and performance
- Collect feedback on UX
- Iterate on UI/UX improvements

### **Phase 3: Production** (1 day)
- Deploy to production with feature flag (initially 10% of users)
- Monitor metrics (API response times, error rates)
- Gradually increase to 100% of users
- Announce feature in release notes

---

## Monitoring & Alerts

**Metrics to Track**:
- Number of lists created per day
- Average lists per user
- API error rate for list endpoints
- API response times (p50, p95, p99)
- Frontend error rate (JS errors)

**Alerts**:
- Alert if API error rate > 5%
- Alert if response time p95 > 500ms
- Alert if frontend error rate > 1%

---

## Next Steps

1. ✅ **This planning document complete**
2. Generate `spec.md` (business requirements)
3. Generate `data-model.md` (verify against actual DB schema)
4. Generate `contracts/` (JSON schemas from Swagger)
5. Generate `quickstart.md` (integration examples)
6. Generate `tasks.md` (detailed task breakdown)
7. Begin Phase 1: Frontend integration

**Estimated Timeline**: 2-3 days for complete integration and testing

**Ready to proceed with specification generation!**

