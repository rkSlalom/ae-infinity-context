# Implementation Plan: Basic Search

**Branch**: `006-basic-search` | **Date**: 2025-11-05 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/006-basic-search/spec.md`

## Summary

Full-text search capability across shopping lists and items with pagination, highlighting, and permission-aware filtering. Enables users to quickly find lists or items by typing partial text, with results displayed grouped by type (lists/items) and supporting shared content search.

**Current State**: Backend 100% exists (per FEATURES.md), Frontend ready, Integration 0%  
**Target State**: Fully functional search with client-side highlighting, debounced input, and optimized performance

---

## Technical Context

**Language/Version**: 
- Backend: C# / .NET 9.0
- Frontend: TypeScript / React 19.1

**Primary Dependencies**: 
- Backend: ASP.NET Core 9.0, Entity Framework Core 9.0, MediatR 12.4, FluentValidation 11.9
- Frontend: React 19.1, React Router 7.9, Vite 7.1, Tailwind CSS 3.4

**Storage**: SQLite (development/small production) with Entity Framework Core

**Testing**: 
- Backend: xUnit, Moq, WebApplicationFactory (integration tests)
- Frontend: Vitest, React Testing Library

**Target Platform**: 
- Backend: Linux/Windows server, Docker containers
- Frontend: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+)

**Project Type**: Web application (separate frontend/backend repositories)

**Performance Goals**: 
- Search response time: <500ms for up to 10,000 items/lists (p95)
- 95% of queries return in <1 second
- Search input debounced to 300ms
- Pagination loads <200ms per page

**Constraints**: 
- SQL LIKE pattern matching (not full-text search)
- Maximum 1,000 results returned per query
- Search query length limited to 200 characters
- Default page size: 20 results, max 100
- Client-side result caching: 5 minutes
- JWT authentication required for all search endpoints

**Scale/Scope**: 
- Expected searches: 50-100 searches/user/session
- Concurrent searches: 100-500 req/sec peak
- Database size: Up to 100,000 items + 10,000 lists
- Search result sets: Average 20-50 results, max 1,000

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ Specification-First Development
- [x] Feature fully specified in spec.md before implementation
- [x] 53 functional requirements documented with acceptance criteria
- [x] 15 success criteria defined and measurable
- [x] 6 user stories with 26+ acceptance scenarios
- **Status**: PASS - Comprehensive specification exists with quality validation

### ✅ Test-Driven Development
- [x] Unit tests required for search service (SearchService)
- [x] Integration tests required for search API endpoint (GET /api/search)
- [x] Frontend component tests for search components (SearchBar, SearchResults)
- [ ] Tests must be written before implementation (TDD approach)
- **Status**: PASS with condition - Tests written before implementation

### ✅ Security & Privacy by Design
- [x] JWT authentication required for search endpoints
- [x] Permission-based filtering (user can only search accessible lists/items)
- [x] Input validation (search query length, special characters)
- [x] Parameterized queries via Entity Framework (SQL injection prevention)
- [x] No PII exposed in search results without authorization
- **Status**: PASS - Security requirements met

### ✅ API Design Principles
- [x] RESTful endpoint: GET /api/search with query parameters
- [x] Proper HTTP status codes (200, 400, 401, 500)
- [x] Pagination via query parameters (page, pageSize)
- [x] Filtering via scope parameter (all/lists/items)
- [x] Structured error responses
- **Status**: PASS - RESTful conventions followed

### ⚠️ Real-time Collaboration Architecture
- [x] Search does not require real-time updates (read-only operation)
- [x] Search results reflect current database state at query time
- [ ] Future enhancement: Real-time search result updates when items change
- **Status**: PASS - Real-time not required for search (read-only feature)

### Complexity Tracking

No violations requiring justification. Feature follows clean architecture patterns, uses existing authentication and permission systems, and implements straightforward SQL LIKE queries.

---

## Project Structure

### Documentation (this feature)

```text
specs/006-basic-search/
├── spec.md                       # ✅ Business specification (complete)
├── plan.md                       # This file (implementation plan)
├── research.md                   # To be created in Phase 0
├── data-model.md                 # To be created in Phase 1
├── quickstart.md                 # To be created in Phase 1
├── contracts/                    # ✅ JSON schemas (complete)
│   ├── search-query-params.json
│   ├── list-search-result.json
│   ├── item-search-result.json
│   ├── search-response.json
│   └── README.md
├── checklists/
│   └── requirements.md           # ✅ Quality validation (passed)
└── tasks.md                      # To be created with /speckit.tasks command
```

### Source Code (existing repositories)

**Backend**: `ae-infinity-api/`
```text
src/
├── AeInfinity.Api/
│   ├── Controllers/
│   │   └── SearchController.cs              # ❓ Status unknown - Phase 0 research
│   └── Program.cs                           # ✅ JWT configuration exists
│
├── AeInfinity.Application/
│   ├── Features/
│   │   └── Search/
│   │       ├── SearchQuery.cs               # ❓ Status unknown - Phase 0 research
│   │       └── SearchHandler.cs             # ❓ Status unknown - Phase 0 research
│   └── DTOs/
│       ├── SearchQueryParams.cs             # ❓ Status unknown - Phase 0 research
│       ├── ListSearchResultDto.cs           # ❓ Status unknown - Phase 0 research
│       ├── ItemSearchResultDto.cs           # ❓ Status unknown - Phase 0 research
│       └── SearchResponseDto.cs             # ❓ Status unknown - Phase 0 research
│
├── AeInfinity.Core/
│   ├── Entities/
│   │   ├── ShoppingList.cs                  # ✅ Exists (Feature 003)
│   │   └── ListItem.cs                      # ✅ Exists (Feature 004)
│   └── Interfaces/
│       └── ISearchService.cs                # ❓ Status unknown - Phase 0 research
│
└── AeInfinity.Infrastructure/
    ├── Data/
    │   ├── AppDbContext.cs                  # ✅ Complete
    │   └── Repositories/
    │       └── SearchRepository.cs          # ❓ Status unknown - Phase 0 research
    └── Services/
        └── SearchService.cs                 # ❓ Status unknown - Phase 0 research

tests/
├── AeInfinity.Application.Tests/
│   └── Search/
│       ├── SearchHandlerTests.cs            # ❌ MISSING - Phase 2 (TDD)
│       └── SearchQueryValidationTests.cs    # ❌ MISSING - Phase 2 (TDD)
│
└── AeInfinity.Api.IntegrationTests/
    └── SearchControllerTests.cs             # ❌ MISSING - Phase 2 (TDD)
```

**Frontend**: `ae-infinity-ui/`
```text
src/
├── components/
│   ├── search/
│   │   ├── SearchBar.tsx                    # ❌ MISSING - Phase 2
│   │   ├── SearchResults.tsx                # ❌ MISSING - Phase 2
│   │   ├── ListSearchResult.tsx             # ❌ MISSING - Phase 2
│   │   ├── ItemSearchResult.tsx             # ❌ MISSING - Phase 2
│   │   ├── SearchPagination.tsx             # ❌ MISSING - Phase 2
│   │   └── SearchHighlight.tsx              # ❌ MISSING - Phase 2
│   └── layout/
│       └── Header.tsx                       # ✅ Exists - add search bar
│
├── hooks/
│   ├── useSearch.ts                         # ❌ MISSING - Phase 2
│   ├── useDebounce.ts                       # ❌ MISSING - Phase 2
│   └── useSearchHighlight.ts                # ❌ MISSING - Phase 2
│
├── services/
│   └── searchService.ts                     # ❌ MISSING - Phase 2
│
└── types/
    ├── search.ts                            # ❌ MISSING - Phase 2
    └── index.ts                             # ✅ Exists - export search types

tests/
└── components/
    └── search/
        ├── SearchBar.test.tsx               # ❌ MISSING - Phase 2 (TDD)
        ├── SearchResults.test.tsx           # ❌ MISSING - Phase 2 (TDD)
        └── SearchHighlight.test.tsx         # ❌ MISSING - Phase 2 (TDD)
```

**Structure Decision**: Standard web application with separate backend (Clean Architecture) and frontend (component-based React). Search functionality integrates with existing authentication, list management, and item management features. Backend uses CQRS pattern (MediatR) and frontend follows React hooks + services pattern.

---

## Phase 0: Research & Discovery

**Objective**: Investigate existing backend implementation, identify gaps, and resolve technical unknowns.

### Research Tasks

1. **Backend Implementation Analysis**
   - **Task**: Examine existing SearchController, SearchService, and related code
   - **Questions**: 
     - Does SearchController exist with GET /api/search endpoint?
     - Is search implemented using Entity Framework LINQ queries?
     - Are permission filters applied (user can only search accessible lists)?
     - Is pagination implemented server-side?
     - Does search support scope parameter (all/lists/items)?
   - **Output**: Document current implementation status and gaps in research.md

2. **Database Query Performance**
   - **Task**: Research SQL LIKE query performance with Entity Framework Core
   - **Questions**:
     - Are appropriate indexes present on ShoppingList.Name and ListItem.Name columns?
     - What is current query performance for LIKE queries on 10,000 items?
     - Should we implement query result caching?
   - **Output**: Performance benchmarks and indexing recommendations

3. **Search Result Highlighting Strategy**
   - **Task**: Research client-side vs server-side highlighting approaches
   - **Questions**:
     - Should highlighting be done server-side (sending HTML) or client-side (React)?
     - How to handle special regex characters in search queries?
     - What accessibility considerations for highlighted text (WCAG compliance)?
   - **Output**: Highlighting implementation approach with code examples

4. **Pagination Best Practices**
   - **Task**: Research pagination patterns for search results
   - **Questions**:
     - Offset-based vs cursor-based pagination for search?
     - Should pagination state be in URL query parameters?
     - How to handle "infinite scroll" vs traditional pagination?
   - **Output**: Pagination architecture decision and implementation guide

5. **Debouncing Strategy**
   - **Task**: Research React debouncing patterns for search input
   - **Questions**:
     - Use custom hook vs library (e.g., lodash.debounce, use-debounce)?
     - How to cancel in-flight requests when new search initiated?
     - How to show loading states during debounce delay?
   - **Output**: Debouncing implementation pattern with code example

6. **Permission Filtering**
   - **Task**: Research how to filter search results by user permissions
   - **Questions**:
     - Are list permissions already implemented in database queries?
     - How to efficiently join lists with collaborator permissions?
     - Should permissions be checked in application layer or database layer?
   - **Output**: Permission filtering approach integrated with existing auth system

### Research Output

**File**: `research.md`

```text
# Research: Basic Search Implementation

## Backend Implementation Status

**Decision**: [After examining code]
- SearchController: [EXISTS/MISSING - details]
- Search CQRS handlers: [EXISTS/MISSING - details]
- Database queries: [LINQ implementation status]

**Rationale**: [Why implementation is complete/incomplete]

**Alternatives considered**: [N/A or other approaches]

## Database Performance & Indexing

**Decision**: [Index strategy]
- Add index on ShoppingList.Name: [YES/NO]
- Add index on ListItem.Name: [YES/NO]
- Add composite index on ListItem (ListId, Name): [YES/NO]

**Rationale**: [Performance benchmarks showing need for indexes]

**Alternatives considered**: [Full-text search engines like Elasticsearch - rejected for MVP]

## Search Result Highlighting

**Decision**: Client-side highlighting using React component
- Use `<mark>` tag for semantic HTML
- Escape special regex characters before matching
- Apply WCAG AA compliant colors (yellow background #FFEB3B with dark text)

**Rationale**: 
- Server-side HTML injection has XSS risks
- Client-side allows flexible styling and accessibility
- React component can be tested independently

**Alternatives considered**: Server-side highlighting rejected due to security and flexibility concerns

## Pagination Approach

**Decision**: Offset-based pagination with URL query parameters
- ?page=1&pageSize=20
- Return total count in response for UI page indicators
- Support both traditional pagination and infinite scroll

**Rationale**: 
- Simpler than cursor-based for search results
- Search results are static snapshots (not real-time updating)
- URL parameters allow bookmarking and sharing searches

**Alternatives considered**: Cursor-based pagination rejected as overkill for search use case

## Debouncing Implementation

**Decision**: Custom `useDebounce` hook with AbortController
- 300ms delay before triggering search
- Cancel previous requests using AbortController
- Show loading state during debounce

**Rationale**: 
- Custom hook avoids lodash dependency
- AbortController prevents race conditions
- Loading state provides user feedback

**Alternatives considered**: lodash.debounce rejected to avoid dependency bloat

## Permission Filtering

**Decision**: Filter at database query level using existing Collaborator relationships
- JOIN ShoppingList with Collaborator table
- Filter WHERE Collaborator.UserId = currentUser OR ShoppingList.OwnerId = currentUser
- Use EF Core navigation properties for clean LINQ queries

**Rationale**: 
- Database-level filtering most efficient
- Reuses existing permission infrastructure
- Prevents security holes from application-layer filtering

**Alternatives considered**: Application-layer filtering rejected as less performant and riskier
```

---

## Phase 1: Design & Contracts

**Objective**: Define data models, create API contracts, and generate developer quickstart guide.

### 1.1 Data Model (`data-model.md`)

**Entities**: (Extract from spec.md Key Entities)

- **SearchQuery** (DTO, not persisted)
  - Query text (1-200 characters)
  - Search scope (enum: All, Lists, Items)
  - Pagination parameters (page, pageSize)
  - User context (from JWT token)

- **ListSearchResult** (DTO)
  - List ID (GUID)
  - Name (string, with client-side highlighting)
  - Description preview (100 chars, nullable)
  - Owner (UserBasicDto)
  - Total items count (int)
  - Purchased items count (int)
  - Is owner (bool)
  - Is archived (bool)
  - Last updated timestamp (DateTime)

- **ItemSearchResult** (DTO)
  - Item ID (GUID)
  - Name (string, with client-side highlighting)
  - Quantity (decimal, nullable)
  - Unit (string, nullable)
  - Notes preview (100 chars, nullable, highlighting if matched)
  - Is purchased (bool)
  - Category (CategoryRefDto, nullable)
  - Parent list (ListRefDto with owner info)

- **SearchResponse** (DTO)
  - Query (string, echoed back)
  - Scope (enum)
  - Lists (total count + array of ListSearchResult)
  - Items (total count + array of ItemSearchResult)
  - Pagination (page, pageSize, totalPages, hasNext, hasPrevious)

**Relationships**:
- SearchQuery → User (via JWT authentication)
- ListSearchResult → ShoppingList entity (mapped)
- ItemSearchResult → ListItem entity (mapped) + ShoppingList (parent list)
- SearchResponse contains both ListSearchResult[] and ItemSearchResult[]

**Validation Rules** (FluentValidation):
- Query: required, 1-200 characters, trim whitespace
- Scope: valid enum value (All, Lists, Items)
- Page: minimum 1
- PageSize: 1-100, default 20
- Special characters in query must be escaped for SQL LIKE

### 1.2 API Contracts (`contracts/`)

**Already Created** ✅:
- `search-query-params.json` - Query parameter schema
- `list-search-result.json` - List result DTO schema
- `item-search-result.json` - Item result DTO schema
- `search-response.json` - Complete response schema
- `README.md` - Contract documentation

**Contract Validation**: JSON Schema Draft 07 compliant, validated with spec examples

### 1.3 Quickstart Guide (`quickstart.md`)

**Structure**:
```markdown
# Quickstart: Basic Search

## Backend Setup

### 1. Search CQRS Handler
[Code example: SearchQuery and SearchHandler using MediatR]

### 2. Search Controller
[Code example: SearchController with GET /api/search endpoint]

### 3. Search Service with Permission Filtering
[Code example: SearchService with LINQ queries and permission checks]

### 4. Database Indexing
[Migration code: Add indexes to ShoppingList.Name and ListItem.Name]

## Frontend Setup

### 1. Search Types
[TypeScript interfaces matching API contracts]

### 2. Search Service
[searchService.ts with API call using fetch/axios]

### 3. useSearch Hook
[Custom hook with debouncing and state management]

### 4. SearchBar Component
[React component with input, debouncing, and submit]

### 5. SearchResults Component
[Results display with ListSearchResult and ItemSearchResult children]

### 6. SearchHighlight Component
[Utility component for client-side text highlighting]

## Testing

### Backend Tests
[xUnit examples: SearchHandlerTests, SearchControllerTests]

### Frontend Tests
[Vitest examples: SearchBar.test.tsx, SearchResults.test.tsx]

## Usage Examples

### Basic Search
[curl command and expected response]

### Paginated Search
[curl with page parameters]

### Filtered Search (Lists Only)
[curl with scope=lists]
```

### 1.4 Agent Context Update

**Script**: `.specify/scripts/powershell/update-agent-context.ps1 -AgentType claude`

**Action**: Add technologies to agent context (if not already present):
- SQL LIKE queries with Entity Framework Core
- Client-side search highlighting with React
- Debouncing patterns in React hooks
- Pagination with URL query parameters

---

## Phase 2: Implementation (Not covered by /speckit.plan)

**Note**: Implementation phase is covered by `/speckit.tasks` command, which generates detailed tasks.md file.

**High-level Implementation Steps**:

1. **Backend** (TDD):
   - Write integration tests for SearchController
   - Implement SearchQuery and SearchHandler (CQRS)
   - Add database indexes via migration
   - Implement SearchService with permission filtering
   - Add validation with FluentValidation
   - Test with xUnit and WebApplicationFactory

2. **Frontend** (TDD):
   - Write component tests for SearchBar and SearchResults
   - Implement search types and service
   - Create useSearch and useDebounce hooks
   - Build SearchBar, SearchResults, SearchHighlight components
   - Add search to Header navigation
   - Test with Vitest and React Testing Library

3. **Integration**:
   - Connect frontend to backend API
   - Test end-to-end search flow
   - Verify permission filtering works
   - Test pagination and highlighting
   - Performance testing (500ms target)

4. **Documentation**:
   - Update FEATURES.md implementation status
   - Update API_REFERENCE.md with search endpoint
   - Add search demo to README.md

---

## Dependencies

### Required (Blocking)
- **Feature 001**: User Authentication ✅ (Backend 80%, Frontend 80%)
- **Feature 003**: Shopping Lists CRUD ✅ (Backend 100%, Frontend 70%)
- **Feature 004**: List Items Management ✅ (Backend 100%, Frontend 70%)

### Enables (Downstream)
- **Feature 013**: Advanced Search & Filters (builds on basic search)

---

## Success Metrics

### Performance Targets
- [ ] Search results return in <500ms (p95) for 10,000 items
- [ ] 95% of queries complete in <1 second
- [ ] Debouncing reduces API calls by 80%
- [ ] Pagination page load <200ms

### Functional Completeness
- [ ] Users can search lists by name (case-insensitive)
- [ ] Users can search items by name and notes
- [ ] Combined search displays both lists and items
- [ ] Pagination works for 1,000+ results
- [ ] Search includes shared lists and items
- [ ] Highlighting shows matching text in results
- [ ] Permission filtering prevents unauthorized access

### Quality Gates
- [ ] 80% test coverage (backend + frontend)
- [ ] All 26+ acceptance scenarios pass
- [ ] Zero security vulnerabilities
- [ ] Accessibility: WCAG AA compliant highlighting
- [ ] No API errors or 500 responses in testing

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Performance degrades with large datasets | Medium | High | Add database indexes, limit results to 1,000, test with 10k+ items |
| Special characters break search | Low | Medium | Escape regex characters, validate with integration tests |
| Permission filtering has security holes | Low | Critical | Test with shared lists, verify database-level filtering |
| Highlighting fails with Unicode/emojis | Low | Low | Test with emoji queries, use Unicode-safe regex |
| Debouncing causes UX confusion | Low | Medium | Add loading indicators, test user experience |

---

## Next Steps

1. ✅ **Specification Complete** - spec.md validated
2. ✅ **Implementation Plan Complete** - This file
3. ⏭️ **Phase 0: Research** - Investigate backend status
4. ⏭️ **Phase 1: Design** - Create data-model.md, quickstart.md
5. ⏭️ **Phase 2: Tasks** - Run `/speckit.tasks 006-basic-search`
6. ⏭️ **Phase 3: Implementation** - Build according to tasks.md
7. ⏭️ **Phase 4: Integration & Testing** - End-to-end validation
8. ⏭️ **Phase 5: Documentation** - Update FEATURES.md, API_REFERENCE.md

**Estimated Timeline**: 3-5 days (depending on backend status discovery)

**Ready to proceed**: Run research phase to discover backend implementation status.

