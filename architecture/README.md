# System Architecture

This directory contains architecture documentation split by system component for focused reference.

## 📁 Architecture Documentation Files

**Note**: This is the planned structure. Currently, see [../ARCHITECTURE.md](../ARCHITECTURE.md) for complete architecture documentation.

- **[system-overview.md](./system-overview.md)** - High-level system architecture
  - System diagram
  - Technology stack
  - Component interactions
  - Deployment architecture

- **[frontend-architecture.md](./frontend-architecture.md)** - React application structure
  - Directory structure
  - Component organization
  - State management strategy
  - Performance optimization

- **[backend-architecture.md](./backend-architecture.md)** - .NET API structure
  - Project structure
  - Layered architecture
  - Dependency injection
  - Middleware pipeline

- **[data-models.md](./data-models.md)** - ✅ **COMPLETED** - Database schemas and relationships
  - Entity definitions (Users, Lists, Items, Categories, Roles)
  - Complete audit trail and soft delete pattern
  - Relationships and foreign keys
  - Indexes and constraints
  - EF Core implementation details
  - Migration strategy
  - **Source**: [../../ae-infinity-api/docs/DB_SCHEMA.md](../../ae-infinity-api/docs/DB_SCHEMA.md)

- **[state-management.md](./state-management.md)** - Frontend state patterns
  - Local component state
  - Context API usage
  - Server state (React Query)
  - Optimistic updates

- **[realtime-strategy.md](./realtime-strategy.md)** - SignalR implementation
  - Hub architecture
  - Connection management
  - Event broadcasting
  - Conflict resolution

- **[security.md](./security.md)** - Security architecture
  - Authentication flow
  - Authorization model
  - JWT token handling
  - Security measures

- **[performance.md](./performance.md)** - Performance optimization
  - Frontend optimizations
  - Backend optimizations
  - Database optimization
  - Caching strategy

- **[offline-sync.md](./offline-sync.md)** - Offline support
  - Service Worker strategy
  - Offline queue
  - Sync mechanism
  - Conflict handling

## 🎯 Architecture Principles

1. **Separation of Concerns** - Clear boundaries between layers
2. **Single Responsibility** - Each component has one purpose
3. **Dependency Inversion** - Depend on abstractions, not concretions
4. **SOLID Principles** - Applied throughout codebase
5. **API-First** - Backend defines contracts, frontend consumes

## 🏗️ System Layers

```
┌─────────────────────────────┐
│     Client Layer            │ ← React UI
│  - React Components         │
│  - State Management         │
│  - Real-time Client         │
└─────────────────────────────┘
           ↕ HTTPS/WSS
┌─────────────────────────────┐
│   Application Layer         │ ← .NET API
│  - Controllers              │
│  - SignalR Hubs             │
│  - Business Logic           │
└─────────────────────────────┘
           ↕
┌─────────────────────────────┐
│     Data Layer              │ ← Databases
│  - SQL Server/PostgreSQL    │
│  - Redis Cache              │
│  - Blob Storage             │
└─────────────────────────────┘
```

## 🔗 Cross-References

### By Feature

**Real-time Collaboration**:
- Frontend: [state-management.md](./state-management.md)
- Backend: [realtime-strategy.md](./realtime-strategy.md)
- API: [../api/realtime-events.md](../api/realtime-events.md)

**Authentication**:
- Security: [security.md](./security.md)
- API: [../api/authentication.md](../api/authentication.md)
- Frontend: [frontend-architecture.md](./frontend-architecture.md)

**Data Management**:
- Models: [data-models.md](./data-models.md)
- Backend: [backend-architecture.md](./backend-architecture.md)
- API: [../api/lists.md](../api/lists.md)

## 🎨 Technology Stack

### Frontend
- **Framework**: React 19 with TypeScript
- **Build Tool**: Vite
- **State**: React Context + React Query
- **Real-time**: SignalR Client
- **Styling**: TBD (CSS Modules / Tailwind / Styled Components)

### Backend
- **Framework**: .NET 8 Web API
- **ORM**: Entity Framework Core
- **Real-time**: SignalR
- **Auth**: JWT Bearer tokens
- **Validation**: FluentValidation

### Data
- **Primary DB**: SQL Server / PostgreSQL
- **Cache**: Redis
- **Storage**: Azure Blob Storage / S3

### Infrastructure
- **Hosting**: Azure / AWS
- **CI/CD**: GitHub Actions
- **Monitoring**: Application Insights / CloudWatch
- **Containers**: Docker + Kubernetes

**Reference**: [../ARCHITECTURE.md](../ARCHITECTURE.md) lines 18-34

## 🎯 Design Patterns

### Frontend Patterns
- Component composition
- Custom hooks for logic reuse
- Context providers for global state
- Optimistic UI updates
- Error boundaries

### Backend Patterns
- Repository pattern
- Unit of Work pattern
- Dependency injection
- Middleware pipeline
- CQRS (future consideration)

## 📊 Performance Targets

**From PROJECT_SPEC.md**:
- Page load time: < 2 seconds
- Real-time update latency: < 100ms
- Support: 10,000+ concurrent users
- Uptime: 99.9%

**Reference**: [../PROJECT_SPEC.md](../PROJECT_SPEC.md) lines 99-103

## 🔒 Security Measures

- HTTPS enforcement
- JWT authentication
- Role-based access control
- Rate limiting
- Input validation
- SQL injection prevention
- XSS protection
- CORS configuration

**Reference**: [security.md](./security.md) (when created)

## 🔗 Related Documentation

- **API Specifications**: [../api/](../api/) - API contracts
- **User Journeys**: [../journeys/](../journeys/) - See architecture in action
- **Components**: [../components/](../components/) - UI implementation
- **Workflows**: [../workflows/](../workflows/) - Development processes

---

**Current Status**: Architecture documented in [../ARCHITECTURE.md](../ARCHITECTURE.md). Will be split into focused files in future updates.

