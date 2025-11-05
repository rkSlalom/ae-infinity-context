# AE Infinity - Project Context

## Purpose

AE Infinity is a **real-time collaborative shopping list application** that enables multiple users to create, share, and manage shopping lists together with real-time synchronization. The project demonstrates modern web development practices with a focus on:

- **Spec-driven development** with comprehensive documentation
- **Clean Architecture** principles and CQRS pattern
- **Real-time collaboration** with optimistic UI updates
- **AI-assisted development** with LLM-optimized context

## Tech Stack

### Frontend (`ae-infinity-ui/`)
- **React 19.1** with TypeScript
- **Vite 7.1** for build tooling and fast HMR
- **React Router 7.9** for routing
- **Context API** for global state (auth, theme)
- **Tailwind CSS 3.4** for styling
- **ESLint 9.36** with TypeScript ESLint for linting
- **SignalR Client** for real-time communication (planned)
- **React Query/SWR** for server state management (planned)

### Backend (`ae-infinity-api/`)
- **.NET 9.0** Web API
- **Entity Framework Core 9.0** with SQLite (in-memory for development)
- **MediatR 12.4** for CQRS pattern implementation
- **FluentValidation 11.9** for request validation
- **AutoMapper 12.0** for object mapping
- **JWT Bearer Authentication 9.0** with BCrypt 4.0 password hashing
- **Serilog 8.0** for structured logging
- **Swashbuckle 6.8** for Swagger/OpenAPI documentation

### Context Repository (`ae-infinity-context/`)
- **Markdown documentation** for all specifications
- **OpenSpec pattern** for change proposals and spec management
- **Cross-referenced documentation** optimized for AI consumption

## Project Conventions

### Code Style

**Frontend:**
- **ESLint** + **Prettier** for consistent formatting
- **TypeScript strict mode** enabled
- **Functional components** with hooks (no class components)
- **Named exports** preferred over default exports
- **PascalCase** for components, **camelCase** for utilities/hooks
- **File naming**: `ComponentName.tsx`, `utilityName.ts`

**Backend:**
- **.NET coding conventions** (follow Microsoft guidelines)
- **PascalCase** for public members, **camelCase** for private/local
- **File naming**: `EntityName.cs`, one class per file
- **XML documentation** for all public APIs
- **Async/await** for all I/O operations
- **Result pattern** for error handling (no exceptions for business logic)

### Architecture Patterns

**Frontend Architecture:**
- **Component Composition**: Small, focused, reusable components
- **Custom Hooks**: Encapsulate complex logic and side effects
- **Service Layer**: Separate API calls from components (`services/`)
- **Type-first Development**: Define TypeScript types from API spec
- **Optimistic Updates**: Immediate UI feedback with server reconciliation
- **Error Boundaries**: Graceful error handling at route level

**Backend Architecture (Clean Architecture):**

```
┌─────────────────────────────────────────┐
│  Domain Layer (AeInfinity.Domain)      │  ← Core business entities, no dependencies
│  - Entities, Value Objects, Events      │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│  Application Layer (AeInfinity.Application) │  ← Use cases (CQRS)
│  - Commands/Queries (MediatR)           │     - Depends on Domain only
│  - DTOs, Interfaces, Validators         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│  Infrastructure Layer (AeInfinity.Infrastructure) │  ← External concerns
│  - Database (EF Core), Repositories     │     - Implements Application interfaces
│  - Services (JWT, Password Hashing)     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│  API Layer (AeInfinity.Api)             │  ← HTTP/REST interface
│  - Controllers, Middleware              │     - Thin presentation layer
└─────────────────────────────────────────┘
```

**Key Patterns:**
- **CQRS** (Command Query Responsibility Segregation) via MediatR
- **Repository Pattern** for data access abstraction
- **Dependency Injection** throughout all layers
- **Soft Delete** for all entities (audit trail)
- **Optimistic Locking** for conflict resolution (planned)

### State Management Strategy

**Local Component State:**
- Form inputs, UI toggles, animation states
- Use `useState` for transient, component-scoped data

**React Context:**
- Authentication state and current user
- Theme preferences (light/dark)
- Global notifications/toasts
- Real-time connection status

**Server State (React Query/SWR - Planned):**
- Shopping lists and items
- User data and collaborators
- Cache invalidation on mutations
- Background refetching for freshness

**Optimistic Updates:**
- Immediately reflect user actions in UI
- Queue operations during offline mode
- Rollback on server error with user notification
- Reconcile with server truth on reconnection

### Testing Strategy

**Frontend:**
- **Unit Tests**: Vitest for utilities, hooks, pure functions
- **Component Tests**: React Testing Library for UI components
- **Integration Tests**: Test user flows and API interactions
- **E2E Tests** (Planned): Playwright for critical paths

**Backend:**
- **Unit Tests**: xUnit for domain logic, validators, services
- **Integration Tests**: Test controllers with in-memory database
- **Contract Tests**: Validate API responses match OpenAPI spec
- **Architecture Tests**: Ensure layer dependencies are correct

**Test Coverage Targets:**
- Domain/Application logic: 80%+ coverage
- API Controllers: 70%+ coverage
- UI Components: 60%+ coverage (focus on critical paths)

### Git Workflow

**Branching Strategy:**
- `main` - production-ready code
- `develop` - integration branch (if needed for larger features)
- `feature/description` - feature branches (short-lived)
- `fix/description` - bug fix branches
- `docs/description` - documentation updates

**Commit Conventions (Conventional Commits):**
```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks
- `style`: Code style changes (formatting)
- `perf`: Performance improvements

**Examples:**
```
feat(api): add list sharing endpoints
fix(ui): resolve item toggle race condition
docs(context): update authentication flow diagram
refactor(api): extract validation to FluentValidation
```

**PR Process:**
1. Create feature branch from `main`
2. Implement changes following OpenSpec workflow (proposal → implementation → review)
3. Ensure tests pass and linting is clean
4. Submit PR with description referencing OpenSpec change ID
5. Code review (1-2 approvals)
6. Merge to `main`, delete feature branch
7. Archive OpenSpec change after deployment

## Domain Context

### Core Domain Entities

**User** - Authenticated application user
- Unique email, display name, avatar
- Password stored as BCrypt hash
- JWT tokens for authentication (24h expiration)
- Tracks last login for audit

**Shopping List** - Container for shopping items
- Owned by one user, shared with multiple collaborators
- Has name, optional description
- Can be archived (soft deleted)
- Position-ordered items

**List Item** - Individual shopping item
- Belongs to one list
- Name, quantity, unit, notes, optional image
- Categorized (Produce, Dairy, Meat, etc.)
- Purchase status (boolean) with timestamp and purchaser
- Position for custom ordering (drag-and-drop)

**Collaborator (UserToList)** - List sharing relationship
- Links user to list with permission level
- Roles: Owner, Editor, Editor-Limited, Viewer
- Tracks invitation and acceptance timestamps

**Category** - Organization taxonomy
- 10 predefined categories (Produce, Dairy, Meat, Bakery, Beverages, Snacks, Frozen, Household, Personal Care, Other)
- Icon and color for UI representation
- Supports custom user categories

**Role** - Permission definition
- Four levels: Owner, Editor, Editor-Limited, Viewer
- Capability flags: `can_manage_items`, `can_edit_list`, `can_manage_collaborators`, `can_delete_list`

### Business Rules

1. **List Ownership**: Every list has exactly one owner who cannot be removed
2. **Permission Hierarchy**: Owner > Editor > Editor-Limited > Viewer
3. **Soft Delete**: All deletions are soft (set `deleted_at`, `deleted_by`)
4. **Audit Trail**: All entities track created_by, created_at, modified_by, modified_at
5. **Email Uniqueness**: User emails are unique and case-insensitive
6. **Purchase Tracking**: Items track who purchased and when
7. **Position Ordering**: Items maintain sort order via `position` field
8. **Real-time Sync**: All list/item changes broadcast to active collaborators (planned)

### User Roles & Permissions

**Owner (Role ID 1):**
- Full control over list settings
- Add/remove collaborators
- Delete list
- All editor permissions
- Cannot transfer ownership (not yet implemented)

**Editor (Role ID 2):**
- Add, edit, delete items
- Mark items as purchased/unpurchased
- Change list name/description
- Cannot modify collaborators or delete list

**Editor-Limited (Role ID 3):**
- Add, edit items (limited)
- Mark items as purchased/unpurchased
- Cannot delete items or edit list settings

**Viewer (Role ID 4):**
- View list and items
- Receive real-time updates
- Cannot make any modifications

## Important Constraints

### Technical Constraints

1. **In-Memory Database (Development)**: SQLite in-memory database resets on application restart
2. **Stateless Authentication**: JWT tokens valid until expiration (no server-side revocation yet)
3. **Token Expiration**: 24-hour JWT tokens (no refresh tokens implemented)
4. **Single-Page Application**: Frontend must handle all routing client-side
5. **CORS Configuration**: Currently `AllowAll` for development (must restrict for production)
6. **SQLite Limitations**: No advanced SQL features (use caution with complex queries)

### Business Constraints

1. **MVP Scope**: Focus on core list/item management and basic sharing
2. **No Multi-Tenancy**: All users share same database (single deployment)
3. **No Billing/Monetization**: Free application (no payment processing)
4. **English Only**: No internationalization in Phase 1
5. **Email-Based Sharing**: No social login or OAuth (Phase 1)

### Performance Targets

- **Page Load**: < 2 seconds (initial load)
- **API Response**: < 200ms (P95)
- **Real-time Latency**: < 100ms (update propagation)
- **Concurrent Users**: Support 10,000+ active users (production)
- **Database**: Queries must use indexes (no table scans on large tables)

### Security Requirements

1. **HTTPS Only** in production
2. **JWT tokens** in Authorization header: `Bearer <token>`
3. **Password Requirements**: Minimum 8 characters (validated)
4. **BCrypt Hashing**: All passwords hashed with automatic salt
5. **Generic Error Messages**: Don't leak user existence on login failure
6. **SQL Injection Protection**: Use EF Core parameterized queries
7. **CORS Whitelist**: Only allow known frontend origins in production
8. **Rate Limiting** (Planned): 100 requests/minute per user

### Accessibility Requirements

- **WCAG 2.1 AA Compliance** (target)
- **Keyboard Navigation**: All interactive elements accessible via keyboard
- **Screen Reader Support**: Proper ARIA labels and semantic HTML
- **Color Contrast**: Minimum 4.5:1 for text
- **Focus Indicators**: Visible focus states for all interactive elements

## External Dependencies

### Backend Dependencies (NuGet Packages)

**Core Framework:**
- `Microsoft.AspNetCore.App` (.NET 9.0 metapackage)
- `Microsoft.EntityFrameworkCore` 9.0.0
- `Microsoft.EntityFrameworkCore.Sqlite` 9.0.0

**Authentication & Security:**
- `Microsoft.AspNetCore.Authentication.JwtBearer` 9.0.0
- `System.IdentityModel.Tokens.Jwt` 8.2.1
- `BCrypt.Net-Next` 4.0.3 (password hashing)

**CQRS & Validation:**
- `MediatR` 12.4.1
- `FluentValidation` 11.9.2
- `FluentValidation.DependencyInjectionExtensions` 11.9.2

**Utilities:**
- `AutoMapper` 12.0.1
- `AutoMapper.Extensions.Microsoft.DependencyInjection` 12.0.1
- `Serilog.AspNetCore` 8.0.2
- `Serilog.Sinks.Console` 6.0.0
- `Swashbuckle.AspNetCore` 6.8.1 (Swagger/OpenAPI)
- `Microsoft.AspNetCore.OpenApi` 9.0.0

### Frontend Dependencies (npm Packages)

**Core Framework:**
- `react` ^19.1.1
- `react-dom` ^19.1.1
- `react-router` ^7.9.5
- `typescript` ~5.9.3

**Build Tools:**
- `vite` ^7.1.7
- `@vitejs/plugin-react` ^5.0.4

**Styling:**
- `tailwindcss` ^3.4.0
- `autoprefixer` ^10.4.21
- `postcss` ^8.5.6

**Linting:**
- `eslint` ^9.36.0
- `@eslint/js` ^9.36.0
- `eslint-plugin-react-hooks` ^5.2.0
- `eslint-plugin-react-refresh` ^0.4.22
- `typescript-eslint` ^8.45.0
- `globals` ^16.4.0

**Type Definitions:**
- `@types/react` ^19.1.16
- `@types/react-dom` ^19.1.9
- `@types/node` ^24.6.0

### External Services (Planned)

**Development:**
- Local filesystem (no external storage in Phase 1)
- SQLite in-memory database (development)

**Production (Future):**
- **Database**: PostgreSQL or Azure SQL Database
- **Caching**: Redis for session management and real-time state
- **File Storage**: Azure Blob Storage or AWS S3 (for item images)
- **Email Service**: SendGrid or AWS SES (for invitations, notifications)
- **Monitoring**: Application Insights or Datadog
- **Error Tracking**: Sentry or Raygun

### API Contracts

**Internal:**
- Frontend consumes backend via `/api/v1/*` endpoints
- See `ae-infinity-context/API_SPEC.md` for complete contract
- Real-time updates via SignalR at `/hubs/shopping-list` (planned)

**External:**
- None in Phase 1 (fully self-contained application)

## Development Workflow

### Spec-Driven Development (OpenSpec)

All new features and breaking changes follow the **OpenSpec workflow**:

1. **Proposal Stage**: Create change proposal in `openspec/changes/[change-id]/`
   - Write `proposal.md` (why, what, impact)
   - Define spec deltas in `specs/[capability]/spec.md`
   - Create `tasks.md` (implementation checklist)
   - Optional: `design.md` for complex changes
   - Validate with `openspec validate [change-id] --strict`

2. **Implementation Stage**: Execute tasks from `tasks.md`
   - Read proposal, design, and tasks before coding
   - Implement sequentially, mark tasks complete
   - Test each task before moving to next

3. **Archive Stage**: After deployment
   - Run `openspec archive [change-id] --yes`
   - Moves change to `changes/archive/`
   - Updates specs in `specs/[capability]/`

### Context Repository Usage

**Always reference these specs before implementing:**
- `PROJECT_SPEC.md` - Requirements and feature definitions
- `API_SPEC.md` - Complete API contracts with types
- `ARCHITECTURE.md` - System design and patterns
- `COMPONENT_SPEC.md` - UI component specifications
- `personas/` - User roles and permission matrix
- `journeys/` - User workflows and flows

**For AI Assistants:**
Load relevant context files before generating code. All specifications are optimized for LLM consumption with clear structure and cross-references.

### Cross-Repository Coordination

**Three-repo structure:**
1. **ae-infinity-context**: Single source of truth (specs, docs)
2. **ae-infinity-api**: Backend implementation
3. **ae-infinity-ui**: Frontend implementation

**Always sync changes across repos:**
- API contract changes → Update `API_SPEC.md` in context repo
- New features → Create OpenSpec change in context repo first
- Bug fixes → Update specs if behavior differs from documentation

## Project Status

**Current Phase**: MVP Development (Phase 1)

**Completed:**
- ✅ Clean Architecture setup (all four layers)
- ✅ JWT authentication (login, logout)
- ✅ User management (get current user)
- ✅ Database schema (6 tables, seeded data)
- ✅ CQRS pattern with MediatR
- ✅ Validation with FluentValidation
- ✅ Exception handling middleware
- ✅ Swagger documentation
- ✅ Basic frontend routing (React Router v7)
- ✅ Authentication context (frontend)
- ✅ API client utilities (frontend)

**In Progress:**
- 🚧 Shopping list CRUD endpoints
- 🚧 List item CRUD endpoints
- 🚧 List UI components

**Planned:**
- ⏳ List sharing and collaborators
- ⏳ Real-time synchronization (SignalR)
- ⏳ Optimistic UI updates
- ⏳ Search functionality
- ⏳ Category management
- ⏳ Offline support with sync

See `ae-infinity-api/docs/IMPLEMENTATION_PLAN.md` for detailed roadmap.
