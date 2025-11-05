# AE Infinity - Repository Analysis

**Analysis Date**: November 5, 2025  
**Purpose**: Document repository structure, patterns, and dependencies for agentic development

---

## 📊 Repository Overview

### Three-Repository Architecture

The AE Infinity project follows a **separation of concerns** architecture across three distinct repositories:

```
ae-infinity/
├── ae-infinity-api/         Backend API (Implementation)
├── ae-infinity-ui/          Frontend UI (Implementation)
└── ae-infinity-context/     Documentation & Specs (Source of Truth)
```

---

## 🔧 Repository 1: ae-infinity-api

### Basic Information

| Property | Value |
|----------|-------|
| **Name** | ae-infinity-api |
| **Type** | Backend Web API |
| **Git Origin** | https://github.com/rkSlalom/ae-infinity-api |
| **Primary Language** | C# (.NET 9.0) |
| **Architecture** | Clean Architecture |
| **Author** | rkSlalom (Reecha Kansal) |

### Technology Stack

**Framework & Runtime**
- .NET 9.0 SDK
- ASP.NET Core Web API
- C# 12

**Database**
- SQLite (in-memory with persistent connection)
- Entity Framework Core 9.0
- Code-First migrations

**Patterns & Libraries**
- **CQRS**: MediatR (13.1.0)
- **Validation**: FluentValidation (11.9.0)
- **Mapping**: AutoMapper (13.0.1)
- **Authentication**: JWT Bearer tokens
- **Password Hashing**: BCrypt.Net-Next
- **Logging**: Serilog
- **Documentation**: Swashbuckle (Swagger/OpenAPI)

### Architecture

**Clean Architecture Layers** (Inner → Outer dependency):

```
┌─────────────────────────────────────┐
│     AeInfinity.Api (Presentation)   │ ← Controllers, Middleware
├─────────────────────────────────────┤
│  AeInfinity.Infrastructure          │ ← DbContext, Repositories, Services
├─────────────────────────────────────┤
│    AeInfinity.Application           │ ← CQRS Handlers, DTOs, Interfaces
├─────────────────────────────────────┤
│       AeInfinity.Domain             │ ← Entities, Value Objects, Events
└─────────────────────────────────────┘
```

**Dependency Rules**:
- Domain: Zero dependencies (pure business logic)
- Application: Depends only on Domain
- Infrastructure: Depends on Application + Domain
- API: Depends on Infrastructure + Application

### Project Structure

```
ae-infinity-api/
├── AeInfinity.sln                          # Solution file
│
├── src/
│   ├── AeInfinity.Domain/                  # Core Business Logic
│   │   ├── Common/
│   │   │   ├── BaseEntity.cs              # Base entity with Id
│   │   │   └── BaseAuditableEntity.cs     # Auditing fields
│   │   ├── Entities/
│   │   │   ├── User.cs                    # User entity
│   │   │   ├── Role.cs                    # Role entity (Owner, Editor, Viewer)
│   │   │   ├── List.cs                    # Shopping list entity
│   │   │   ├── ListItem.cs                # List item entity
│   │   │   ├── Category.cs                # Category entity (10 predefined)
│   │   │   └── UserToList.cs              # Join table for collaboration
│   │   └── Exceptions/                    # Domain exceptions
│   │       ├── NotFoundException.cs
│   │       ├── UnauthorizedException.cs
│   │       ├── ValidationException.cs
│   │       └── ForbiddenException.cs
│   │
│   ├── AeInfinity.Application/            # Use Cases & Business Logic
│   │   ├── Common/
│   │   │   ├── Behaviors/
│   │   │   │   └── ValidationBehavior.cs  # MediatR validation pipeline
│   │   │   ├── Interfaces/
│   │   │   │   ├── IApplicationDbContext.cs
│   │   │   │   └── IRepository.cs
│   │   │   ├── Mappings/
│   │   │   │   └── MappingProfile.cs      # AutoMapper configuration
│   │   │   └── Models/
│   │   │       ├── DTOs/                  # Data Transfer Objects
│   │   │       └── Result.cs              # Result pattern implementation
│   │   ├── Features/                      # Feature-based organization (CQRS)
│   │   │   ├── Auth/
│   │   │   │   ├── Commands/
│   │   │   │   │   ├── Login/            # LoginCommand + Handler + Validator
│   │   │   │   │   └── Logout/           # LogoutCommand + Handler
│   │   │   │   └── Queries/
│   │   │   ├── Users/
│   │   │   │   └── Queries/
│   │   │   │       └── GetCurrentUser/   # Query + Handler
│   │   │   ├── Lists/                    # Shopping lists (CRUD)
│   │   │   ├── Items/                    # List items (CRUD)
│   │   │   ├── Categories/               # Category queries
│   │   │   ├── Search/                   # Search functionality
│   │   │   └── Statistics/               # Statistics queries
│   │   └── DependencyInjection.cs        # Register services
│   │
│   ├── AeInfinity.Infrastructure/         # External Concerns
│   │   ├── Persistence/
│   │   │   ├── Configurations/           # EF Core entity configurations
│   │   │   │   ├── UserConfiguration.cs
│   │   │   │   ├── RoleConfiguration.cs
│   │   │   │   ├── ListConfiguration.cs
│   │   │   │   ├── ListItemConfiguration.cs
│   │   │   │   ├── CategoryConfiguration.cs
│   │   │   │   └── UserToListConfiguration.cs
│   │   │   ├── Repositories/
│   │   │   │   └── Repository.cs         # Generic repository
│   │   │   ├── ApplicationDbContext.cs   # EF Core DbContext
│   │   │   ├── DbInitializer.cs          # Database initialization
│   │   │   └── DbSeeder.cs              # Seed data
│   │   ├── Services/
│   │   │   ├── JwtTokenService.cs       # JWT generation
│   │   │   └── PasswordHasher.cs        # BCrypt hashing
│   │   └── DependencyInjection.cs
│   │
│   └── AeInfinity.Api/                   # Presentation Layer
│       ├── Controllers/
│       │   ├── BaseApiController.cs      # Base controller with MediatR
│       │   ├── AuthController.cs         # POST /api/auth/login, /logout
│       │   ├── UsersController.cs        # GET /api/users/me
│       │   ├── ListsController.cs        # CRUD for lists
│       │   ├── ItemsController.cs        # CRUD for items
│       │   ├── CategoriesController.cs   # GET categories
│       │   ├── SearchController.cs       # Search endpoints
│       │   └── StatisticsController.cs   # Statistics endpoints
│       ├── Middleware/
│       │   └── ExceptionHandlingMiddleware.cs  # Global error handler
│       ├── Extensions/
│       │   └── WebApplicationExtensions.cs
│       ├── Program.cs                    # Application entry point
│       ├── appsettings.json             # Configuration
│       └── appsettings.Development.json # Dev configuration
│
├── docs/
│   ├── DB_SCHEMA.md                      # Database schema
│   ├── API_LIST.md                       # API endpoints
│   └── IMPLEMENTATION_PLAN.md            # Development roadmap
│
└── README.md                             # API documentation
```

### Build & Run

**Prerequisites**:
- .NET 9.0 SDK

**Commands**:
```bash
# Restore dependencies
dotnet restore

# Build solution
dotnet build

# Run API
cd src/AeInfinity.Api
dotnet run

# Endpoints
# HTTP:  http://localhost:5233
# HTTPS: https://localhost:7184
# Swagger: http://localhost:5233/
```

### Database Schema

**6 Main Tables** (all with soft delete + audit trail):

1. **users** - User accounts
2. **roles** - Permission levels (Owner, Editor, Editor-Limited, Viewer)
3. **lists** - Shopping lists
4. **list_items** - Items within lists
5. **categories** - 10 predefined categories
6. **user_to_list** - Collaboration/permissions join table

**Common Fields** (all tables):
- `id` (GUID)
- `created_at`, `created_by`
- `modified_at`, `modified_by`
- `deleted_at`, `deleted_by`
- `is_deleted` (soft delete flag)

### Seed Data

Automatically seeded on startup:
- 4 roles (Owner, Editor, Editor-Limited, Viewer)
- 10 categories (Produce, Dairy, Meat, etc.)
- 3 test users (Sarah, Alex, Mike)
- Sample lists and items

### Test Credentials

| Email | Password | Description |
|-------|----------|-------------|
| sarah@example.com | Password123! | List owner |
| alex@example.com | Password123! | Collaborator |
| mike@example.com | Password123! | Collaborator |

### Key Dependencies (.csproj)

```xml
<PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="9.0.0" />
<PackageReference Include="MediatR" Version="13.1.0" />
<PackageReference Include="FluentValidation" Version="11.9.0" />
<PackageReference Include="FluentValidation.DependencyInjectionExtensions" Version="11.9.0" />
<PackageReference Include="AutoMapper" Version="13.0.1" />
<PackageReference Include="AutoMapper.Extensions.Microsoft.DependencyInjection" Version="13.0.1" />
<PackageReference Include="BCrypt.Net-Next" Version="4.0.3" />
<PackageReference Include="Serilog" Version="4.0.0" />
<PackageReference Include="Serilog.AspNetCore" Version="8.0.0" />
<PackageReference Include="Swashbuckle.AspNetCore" Version="7.1.0" />
```

---

## 🎨 Repository 2: ae-infinity-ui

### Basic Information

| Property | Value |
|----------|-------|
| **Name** | ae-infinity-ui |
| **Type** | Frontend Web Application |
| **Git Origin** | https://github.com/dallen4/ae-infinity-ui.git |
| **Primary Language** | TypeScript |
| **Framework** | React 19 |
| **Author** | dallen4 |

### Technology Stack

**Core Framework**
- React 19.1.1
- React DOM 19.1.1
- React Router 7.9.5
- TypeScript 5.9.3

**Build Tools**
- Vite 7.1.7
- @vitejs/plugin-react 5.0.4

**Styling**
- Tailwind CSS 3.4.0
- PostCSS 8.5.6
- Autoprefixer 10.4.21

**Code Quality**
- ESLint 9.36.0
- eslint-plugin-react-hooks 5.2.0
- eslint-plugin-react-refresh 0.4.22
- TypeScript ESLint 8.45.0

### Project Structure

```
ae-infinity-ui/
├── public/
│   └── vite.svg                          # Vite logo
│
├── src/
│   ├── components/                       # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Modal.tsx
│   │   ├── Card.tsx
│   │   └── LoadingSpinner.tsx
│   │
│   ├── pages/                           # Route-level components
│   │   ├── LoginPage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── ListsPage.tsx
│   │   ├── ListDetailPage.tsx
│   │   ├── ItemsPage.tsx
│   │   ├── SearchPage.tsx
│   │   ├── ProfilePage.tsx
│   │   └── NotFoundPage.tsx
│   │
│   ├── services/                        # API and business logic
│   │   ├── api/
│   │   │   ├── authApi.ts              # Auth endpoints
│   │   │   ├── listsApi.ts             # Lists CRUD
│   │   │   ├── itemsApi.ts             # Items CRUD
│   │   │   ├── categoriesApi.ts        # Categories
│   │   │   └── searchApi.ts            # Search
│   │   ├── apiClient.ts                # Axios/fetch wrapper
│   │   └── localStorage.ts             # Local storage utilities
│   │
│   ├── hooks/                           # Custom React hooks
│   │   ├── useAuth.ts                  # Authentication hook
│   │   ├── useLists.ts                 # Lists data hook
│   │   └── useDebounce.ts              # Debounce utility
│   │
│   ├── contexts/                        # React Context providers
│   │   └── AuthContext.tsx             # Auth state management
│   │
│   ├── types/                           # TypeScript definitions
│   │   └── index.ts                    # All type definitions
│   │
│   ├── utils/                           # Helper functions
│   │   ├── formatters.ts               # Date, currency formatting
│   │   ├── validators.ts               # Input validation
│   │   ├── constants.ts                # App constants
│   │   └── helpers.ts                  # Misc utilities
│   │
│   ├── App.tsx                          # Main app component
│   ├── App.css                          # App styles
│   ├── main.tsx                         # Entry point
│   └── index.css                        # Global styles (Tailwind)
│
├── docs/                                # Project documentation
│   ├── API_INTEGRATION_GUIDE.md
│   ├── COMPONENT_PATTERNS.md
│   ├── DEVELOPMENT_PATTERNS.md
│   ├── OPTIMISTIC_UPDATES_GUIDE.md
│   ├── PROJECT_STRUCTURE.md
│   ├── ROUTER_SETUP.md
│   ├── ROUTING_GUIDE.md
│   ├── STATE_MANAGEMENT_GUIDE.md
│   └── TERMINOLOGY.md
│
├── package.json                         # npm dependencies
├── package-lock.json                    # Locked versions
├── tsconfig.json                        # TypeScript config
├── tsconfig.app.json                    # App TS config
├── tsconfig.node.json                   # Node TS config
├── vite.config.ts                       # Vite configuration
├── tailwind.config.js                   # Tailwind config
├── postcss.config.js                    # PostCSS config
├── eslint.config.js                     # ESLint config
├── index.html                           # HTML entry point
└── README.md                            # UI documentation
```

### Build & Run

**Prerequisites**:
- Node.js 20+
- npm 10+

**Commands**:
```bash
# Install dependencies
npm install

# Development server
npm run dev
# Runs at: http://localhost:5173

# Production build
npm run build

# Preview production build
npm run preview

# Linting
npm run lint
```

### Key Dependencies (package.json)

```json
{
  "dependencies": {
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "react-router": "^7.9.5"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^5.0.4",
    "autoprefixer": "^10.4.21",
    "tailwindcss": "^3.4.0",
    "typescript": "~5.9.3",
    "vite": "^7.1.7",
    "eslint": "^9.36.0"
  }
}
```

### State Management Strategy

**Local State**: React useState/useReducer
- Form inputs
- UI toggles
- Component-specific state

**Context API**: React Context
- Authentication state
- User profile
- Theme preferences
- Notifications

**Server State**: TanStack Query (planned) or SWR
- Lists data
- Items data
- Search results
- Statistics

**Optimistic Updates**:
- Immediate UI updates
- Rollback on error
- Background sync

### Routing Structure

Using React Router 7:

```
/                           → DashboardPage
/login                      → LoginPage
/lists                      → ListsPage
/lists/:listId              → ListDetailPage
/lists/:listId/items/:id    → ItemDetailPage (if needed)
/search                     → SearchPage
/profile                    → ProfilePage
/settings                   → SettingsPage (planned)
/404                        → NotFoundPage
```

### Environment Variables

```env
VITE_API_BASE_URL=http://localhost:5233/api
VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/shopping-list
VITE_ENVIRONMENT=development
```

---

## 📚 Repository 3: ae-infinity-context

### Basic Information

| Property | Value |
|----------|-------|
| **Name** | ae-infinity-context |
| **Type** | Documentation & Specifications |
| **Git Origin** | https://github.com/rkSlalom/ae-infinity-context.git |
| **Primary Language** | Markdown |
| **Purpose** | Single source of truth for project specs |
| **Author** | rkSlalom (Reecha Kansal) |

### Purpose

This repository is **NOT CODE**. It's the complete specification and documentation that drives development of the API and UI repositories.

### Content Structure

```
ae-infinity-context/
├── Core Specifications
│   ├── PROJECT_SPEC.md              # Complete project requirements
│   ├── API_SPEC.md                  # REST API contract (500+ lines)
│   ├── ARCHITECTURE.md              # System architecture
│   ├── COMPONENT_SPEC.md            # UI component specifications
│   ├── DEVELOPMENT_GUIDE.md         # Development workflow
│   └── FEATURES.md                  # Feature tracker with status
│
├── User-Centric Documentation
│   ├── personas/                    # User personas
│   │   ├── list-creator.md         # Owner persona (Sarah)
│   │   ├── active-collaborator.md  # Editor persona (Mike)
│   │   ├── passive-viewer.md       # Viewer persona (Emma)
│   │   └── permission-matrix.md    # Permission comparison
│   │
│   └── journeys/                    # User workflows
│       ├── creating-first-list.md
│       ├── shopping-together.md
│       └── managing-permissions.md
│
├── Feature Documentation
│   └── features/                    # Feature-driven docs (9 domains)
│       ├── authentication/
│       ├── lists/
│       ├── items/
│       ├── collaboration/
│       ├── categories/
│       ├── search/
│       ├── realtime/
│       ├── ui-components/
│       └── infrastructure/
│
├── API Contracts
│   └── schemas/                     # JSON Schema definitions
│       ├── user.json
│       ├── list.json
│       ├── list-item.json
│       ├── category.json
│       ├── login-request.json
│       ├── login-response.json
│       ├── collaborator.json
│       ├── search-result.json
│       └── pagination.json
│
├── OpenSpec Integration
│   └── openspec/                    # OpenSpec framework
│       ├── AGENTS.md               # AI agent instructions
│       ├── project.md              # Project metadata
│       └── specs/                  # Spec proposals
│
├── Working Directory Setup (NEW!)
│   ├── setup-working-directory.sh  # Automated setup script
│   ├── WORKING_DIRECTORY_GUIDE.md  # Complete setup guide
│   └── QUICK_SETUP.md             # Quick reference
│
└── Additional Documentation
    ├── docs/
    │   ├── CROSS_REPO_REFERENCES.md
    │   ├── README.md
    │   └── REFERENCE_EXAMPLES.md
    │
    ├── README.md                    # Context repo overview
    ├── CHANGELOG.md                 # Change history
    └── data-models.md              # Data model definitions
```

### Key Documents

| Document | Lines | Purpose |
|----------|-------|---------|
| PROJECT_SPEC.md | 800+ | Complete project requirements and features |
| API_SPEC.md | 700+ | Full REST API specification with examples |
| ARCHITECTURE.md | 600+ | System architecture and technical decisions |
| COMPONENT_SPEC.md | 500+ | UI component library and design system |
| DEVELOPMENT_GUIDE.md | 400+ | Development workflow and standards |

### Specification Coverage

**Authentication & Users**
- Login/logout flows
- JWT token handling
- User profile management
- Password reset (planned)
- Email verification (planned)

**Shopping Lists**
- CRUD operations
- Archive/restore
- Soft delete
- Ownership transfer
- List templates (planned)

**List Items**
- CRUD operations
- Purchase tracking
- Category assignment
- Quantity management
- Notes and attachments

**Collaboration**
- Share lists
- Invite collaborators
- Permission levels (Owner, Editor, Viewer)
- Accept/decline invitations
- Remove collaborators

**Search**
- Global search (lists + items)
- Filters by category
- Sorting options
- Pagination

**Statistics**
- User stats (total lists, items, etc.)
- List activity
- Purchase history
- Spending tracking (planned)

**Real-time (Planned)**
- SignalR hub
- Live updates
- Presence indicators
- Conflict resolution

### JSON Schemas

All API contracts defined as JSON Schema (Draft 7):

```
schemas/
├── Authentication
│   ├── login-request.json
│   └── login-response.json
├── Users
│   ├── user.json
│   ├── user-basic.json
│   └── user-stats.json
├── Lists
│   ├── list.json
│   ├── list-basic.json
│   ├── list-detail.json
│   └── list-search-result.json
├── Items
│   ├── list-item.json
│   ├── list-item-basic.json
│   └── item-search-result.json
├── Collaboration
│   ├── collaborator.json
│   └── invitation.json
├── Categories
│   └── category.json
├── Misc
│   ├── pagination.json
│   └── search-result.json
└── README.md                # Schema documentation
```

### No Build Required

This repository contains only documentation:
- Markdown files
- JSON schemas
- Bash scripts (for automation)
- No compilation or build steps needed

---

## 🔄 Cross-Repository Patterns

### Shared Concepts

**1. Soft Delete Pattern**
- All entities support soft delete
- `is_deleted` flag
- `deleted_at` timestamp
- `deleted_by` user reference

**2. Audit Trail**
- `created_at`, `created_by`
- `modified_at`, `modified_by`
- `deleted_at`, `deleted_by`

**3. GUID Primary Keys**
- All entities use GUID/UUID
- Backend: `Guid` type in C#
- Frontend: `string` type in TypeScript
- Database: TEXT (SQLite)

**4. Result Pattern**
- Backend: `Result<T>` wrapper
- Success/Failure indication
- Error messages
- No exceptions for flow control

**5. Pagination**
- Consistent across all list endpoints
- `page` (1-based)
- `pageSize` (default 20, max 100)
- `totalCount`, `totalPages`
- `hasNextPage`, `hasPreviousPage`

### Naming Conventions

**API Endpoints**:
- Base: `/api/v1/...` (future-proofing)
- Current: `/api/...` (v1 implicit)
- REST conventions: GET, POST, PUT, DELETE
- Plural nouns: `/lists`, `/items`, `/users`

**Database Tables**:
- Snake case: `user_to_list`, `list_items`
- Plural: `users`, `lists`, `categories`

**C# Naming**:
- PascalCase: Classes, Methods, Properties
- camelCase: Local variables, parameters
- Interfaces: `I` prefix (`IRepository`)

**TypeScript Naming**:
- PascalCase: Components, Interfaces, Types
- camelCase: Functions, variables
- UPPER_SNAKE_CASE: Constants

### Communication Patterns

**API → UI**:
- JSON over HTTP/HTTPS
- JWT Bearer token in Authorization header
- RESTful endpoints
- SignalR for real-time (planned)

**UI → API**:
- Axios or Fetch for HTTP requests
- Token refresh logic (planned)
- Retry logic with exponential backoff
- Optimistic updates with rollback

---

## 🤖 Agentic Development Considerations

### Why Three Repositories?

1. **Separation of Concerns**
   - Backend and frontend can evolve independently
   - Different languages and ecosystems
   - Clear boundaries

2. **Specification First**
   - Context repo is the contract
   - Both implementation repos reference specs
   - Changes start in context, flow to implementations

3. **Independent Deployment**
   - API can be deployed separately
   - UI can be deployed separately
   - Different release cycles possible

4. **Team Collaboration**
   - Backend team works in API repo
   - Frontend team works in UI repo
   - Product/design team maintains context repo

### Working Directory Pattern

**Purpose**: Create isolated, reproducible environment for AI agents to iterate

**Benefits**:
- ✅ Clean slate every time
- ✅ No impact on main development
- ✅ All dependencies installed
- ✅ All repos at same commits
- ✅ Easy to reset and retry
- ✅ Safe experimentation

**Usage Pattern**:
```
1. Setup working directory (automated)
2. Agent reads context repo specs
3. Agent implements in API/UI repos
4. Agent tests locally
5. Human reviews changes
6. If good → merge to main repos
7. If not good → discard working dir
8. Repeat
```

### Context Loading Strategy for AI

**Step 1: Load Project Overview**
- Read `PROJECT_SPEC.md`
- Understand goals, features, requirements

**Step 2: Load Relevant Persona**
- Identify which user persona is relevant
- Load persona file from `personas/`

**Step 3: Load User Journey**
- Identify relevant user journey
- Load journey file from `journeys/`

**Step 4: Load API Contract**
- Read `API_SPEC.md` for endpoints
- Load relevant JSON schemas from `schemas/`

**Step 5: Load Architecture**
- Read `ARCHITECTURE.md`
- Understand patterns and decisions

**Step 6: Load Feature Details**
- Read from `features/[domain]/`
- Get implementation specifics

**Step 7: Implement**
- Write code in API or UI repo
- Follow patterns from loaded context

**Step 8: Verify**
- Build and test
- Check against specifications

### Best Practices for Agents

**DO**:
- ✅ Read specifications first
- ✅ Follow existing patterns
- ✅ Use working directory for experimentation
- ✅ Test thoroughly
- ✅ Handle errors gracefully
- ✅ Add comments explaining complex logic

**DON'T**:
- ❌ Make up API endpoints (check API_SPEC.md)
- ❌ Invent new patterns (follow ARCHITECTURE.md)
- ❌ Skip validation
- ❌ Ignore error handling
- ❌ Commit sensitive data
- ❌ Push directly to main

---

## 📊 Dependency Graph

```
User/Agent
    │
    ├─→ setup-working-directory.sh (creates clean workspace)
    │
    ├─→ ae-infinity-context (reads specifications)
    │   ├── PROJECT_SPEC.md
    │   ├── API_SPEC.md
    │   ├── ARCHITECTURE.md
    │   └── [other specs]
    │
    ├─→ ae-infinity-api (implements backend)
    │   ├── Requires: .NET 9.0 SDK
    │   ├── Dependencies: EF Core, MediatR, etc.
    │   ├── References: Context repo for specs
    │   └── Exposes: REST API at localhost:5233
    │
    └─→ ae-infinity-ui (implements frontend)
        ├── Requires: Node.js 20+, npm
        ├── Dependencies: React, Vite, Tailwind, etc.
        ├── References: Context repo for specs
        ├── Consumes: API at localhost:5233
        └── Serves: UI at localhost:5173
```

---

## 🔐 Security Patterns

### Authentication Flow

```
1. User enters credentials (email + password)
2. UI → POST /api/auth/login
3. API validates credentials
4. API generates JWT token (1 hour expiry)
5. API returns token + user info
6. UI stores token (localStorage or secure cookie)
7. UI includes token in subsequent requests
8. API validates token on each request
9. API returns 401 if token expired
10. UI redirects to login
```

### Authorization Levels

| Role | Permissions |
|------|-------------|
| **Owner** | Full control, can delete list, manage collaborators |
| **Editor** | Add/edit/delete items, cannot manage list or collaborators |
| **Editor-Limited** | Add/edit own items only |
| **Viewer** | Read-only access |

---

## 🚀 Quick Start Summary

### For Backend Development

```bash
cd work/ae-infinity-api
dotnet restore
dotnet build
cd src/AeInfinity.Api
dotnet run
# API at http://localhost:5233
```

### For Frontend Development

```bash
cd work/ae-infinity-ui
npm install
npm run dev
# UI at http://localhost:5173
```

### For Documentation

```bash
cd work/ae-infinity-context
cat PROJECT_SPEC.md
cat API_SPEC.md
# No build needed
```

---

## 📈 Implementation Status

### Backend API
- ✅ Clean Architecture setup
- ✅ Authentication (login, logout, current user)
- ✅ Users endpoints
- ✅ Lists CRUD
- ✅ Items CRUD
- ✅ Categories endpoints
- ✅ Search endpoints
- ✅ Statistics endpoints
- ✅ Soft delete
- ✅ Audit trail
- ❌ Real-time (SignalR) - planned

### Frontend UI
- ✅ React 19 setup
- ✅ TypeScript configured
- ✅ Tailwind CSS integrated
- ✅ React Router configured
- ✅ All page components created
- ✅ Service layer structure
- 🟡 API integration (using mock data currently)
- ❌ Real-time updates - planned

### Documentation
- ✅ Complete project specifications
- ✅ Full API contract
- ✅ Architecture documentation
- ✅ UI component specs
- ✅ User personas
- ✅ User journeys
- ✅ JSON schemas
- ✅ Working directory automation

---

## 🎯 Next Steps for Agentic Development

1. **Test the setup script**
   ```bash
   cd ae-infinity-context
   ./setup-working-directory.sh test-workspace
   ```

2. **Verify all repos cloned**
   ```bash
   ls -la test-workspace/
   ```

3. **Start both services**
   ```bash
   # Terminal 1
   cd test-workspace/ae-infinity-api/src/AeInfinity.Api
   dotnet run
   
   # Terminal 2
   cd test-workspace/ae-infinity-ui
   npm run dev
   ```

4. **Load context into agent**
   - Read PROJECT_SPEC.md
   - Read API_SPEC.md
   - Read relevant feature docs

5. **Begin implementation**
   - Make changes in test-workspace
   - Test locally
   - Review results

6. **Cleanup or commit**
   - If successful → merge to main repos
   - If not → delete test-workspace and try again

---

**Analysis Complete**  
**Ready for Agentic Development** ✅

