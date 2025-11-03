# Architecture Documentation

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Layer (Browser)                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         React App (TypeScript + Vite)                  │ │
│  │  - UI Components (React 19)                            │ │
│  │  - State Management (Context/Redux)                    │ │
│  │  - Real-time Client (SignalR)                          │ │
│  │  - Service Worker (PWA/Offline)                        │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ↕ HTTPS/WSS
┌─────────────────────────────────────────────────────────────┐
│                   API Gateway / Load Balancer                │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                Application Layer (.NET 8)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  Web API     │  │  SignalR Hub │  │  Background Jobs │  │
│  │  Controllers │  │  (Real-time) │  │  (Cleanup, etc.) │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Business Logic Layer                      │ │
│  │  - Services (ListService, ItemService, etc.)          │ │
│  │  - Domain Models                                       │ │
│  │  - Validators                                          │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Data Access Layer                         │ │
│  │  - Entity Framework Core                               │ │
│  │  - Repositories                                        │ │
│  │  - Unit of Work                                        │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ↕
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  SQL Server/ │  │   Redis      │  │  Blob Storage    │  │
│  │  PostgreSQL  │  │  (Cache)     │  │  (Images)        │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Frontend Architecture

### Directory Structure
```
ae-infinity-ui/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── common/         # Buttons, inputs, modals
│   │   ├── layout/         # Header, sidebar, footer
│   │   ├── lists/          # List-related components
│   │   └── items/          # Item-related components
│   ├── pages/              # Route-level components
│   │   ├── Home.tsx
│   │   ├── ListDetail.tsx
│   │   ├── Login.tsx
│   │   └── Profile.tsx
│   ├── hooks/              # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useLists.ts
│   │   ├── useRealtime.ts
│   │   └── useOptimistic.ts
│   ├── services/           # API and business logic
│   │   ├── api/
│   │   │   ├── authApi.ts
│   │   │   ├── listsApi.ts
│   │   │   └── itemsApi.ts
│   │   ├── signalr/
│   │   │   └── hubConnection.ts
│   │   └── storage/
│   │       └── localStore.ts
│   ├── context/            # React Context providers
│   │   ├── AuthContext.tsx
│   │   ├── ListsContext.tsx
│   │   └── RealtimeContext.tsx
│   ├── types/              # TypeScript type definitions
│   │   ├── api.ts
│   │   ├── models.ts
│   │   └── events.ts
│   ├── utils/              # Helper functions
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   └── constants.ts
│   ├── styles/             # Global styles
│   ├── App.tsx
│   └── main.tsx
├── public/
├── index.html
├── vite.config.ts
├── tsconfig.json
└── package.json
```

### State Management Strategy

**Local Component State**
- Form inputs
- UI toggles (modals, dropdowns)
- Transient animation states

**Context API**
- Authentication state and user info
- Theme preferences
- Global notifications

**Server State (React Query/SWR)**
- Shopping lists
- Shopping items
- User data
- Cache invalidation on mutations

**Optimistic Updates**
- Immediately reflect user actions
- Rollback on server error
- Queue for offline mode

### Key Frontend Patterns

1. **Component Composition**: Small, focused components
2. **Custom Hooks**: Encapsulate complex logic
3. **Error Boundaries**: Graceful error handling
4. **Code Splitting**: Route-based lazy loading
5. **Memoization**: Prevent unnecessary re-renders

## Backend Architecture

### Project Structure
```
AeInfinity.Api/
├── Controllers/
│   ├── AuthController.cs
│   ├── ListsController.cs
│   ├── ItemsController.cs
│   └── UsersController.cs
├── Hubs/
│   └── ShoppingListHub.cs
├── Middleware/
│   ├── ErrorHandlingMiddleware.cs
│   ├── AuthenticationMiddleware.cs
│   └── RateLimitingMiddleware.cs
├── Program.cs
└── appsettings.json

AeInfinity.Core/
├── Domain/
│   ├── Entities/
│   │   ├── User.cs
│   │   ├── ShoppingList.cs
│   │   ├── ShoppingItem.cs
│   │   ├── ListCollaborator.cs
│   │   └── Category.cs
│   ├── Enums/
│   │   ├── PermissionLevel.cs
│   │   └── ItemStatus.cs
│   └── ValueObjects/
│       └── Email.cs
├── Interfaces/
│   ├── Repositories/
│   │   ├── IListRepository.cs
│   │   ├── IItemRepository.cs
│   │   └── IUserRepository.cs
│   └── Services/
│       ├── IListService.cs
│       ├── IItemService.cs
│       ├── IAuthService.cs
│       └── IRealtimeService.cs
└── Exceptions/
    ├── NotFoundException.cs
    ├── UnauthorizedException.cs
    └── ValidationException.cs

AeInfinity.Application/
├── Services/
│   ├── ListService.cs
│   ├── ItemService.cs
│   ├── AuthService.cs
│   └── RealtimeService.cs
├── DTOs/
│   ├── Requests/
│   │   ├── CreateListRequest.cs
│   │   ├── UpdateListRequest.cs
│   │   ├── CreateItemRequest.cs
│   │   └── ShareListRequest.cs
│   └── Responses/
│       ├── ListResponse.cs
│       ├── ItemResponse.cs
│       └── UserResponse.cs
├── Mappings/
│   └── AutoMapperProfile.cs
└── Validators/
    ├── CreateListValidator.cs
    └── CreateItemValidator.cs

AeInfinity.Infrastructure/
├── Data/
│   ├── AppDbContext.cs
│   ├── Repositories/
│   │   ├── ListRepository.cs
│   │   ├── ItemRepository.cs
│   │   └── UserRepository.cs
│   └── Migrations/
├── Caching/
│   └── RedisCacheService.cs
├── Storage/
│   └── BlobStorageService.cs
└── Configuration/
    └── DatabaseConfiguration.cs
```

### API Design Principles

1. **RESTful Conventions**
   - Proper HTTP verbs (GET, POST, PUT, DELETE, PATCH)
   - Meaningful status codes
   - Resource-based URLs

2. **Versioning**
   - URL versioning: `/api/v1/lists`
   - Backward compatibility for 2 versions

3. **Pagination**
   - Cursor-based for real-time data
   - Offset-based for static data
   - Default page size: 20

4. **Filtering and Sorting**
   - Query parameters: `?status=active&sort=createdAt:desc`
   - Support multiple sort fields

5. **Error Responses**
   ```json
   {
     "error": {
       "code": "VALIDATION_ERROR",
       "message": "Invalid input data",
       "details": [
         {
           "field": "name",
           "message": "Name is required"
         }
       ]
     }
   }
   ```

## Data Model

### Core Entities

**User**
- Id (Guid)
- Email (string, unique)
- DisplayName (string)
- PasswordHash (string)
- AvatarUrl (string, nullable)
- CreatedAt (DateTime)
- UpdatedAt (DateTime)

**ShoppingList**
- Id (Guid)
- Name (string)
- Description (string, nullable)
- OwnerId (Guid, FK to User)
- IsArchived (bool)
- CreatedAt (DateTime)
- UpdatedAt (DateTime)
- Collaborators (List<ListCollaborator>)
- Items (List<ShoppingItem>)

**ShoppingItem**
- Id (Guid)
- ListId (Guid, FK to ShoppingList)
- Name (string)
- Quantity (decimal)
- Unit (string, nullable)
- CategoryId (Guid, FK to Category)
- Notes (string, nullable)
- ImageUrl (string, nullable)
- IsPurchased (bool)
- Position (int)
- CreatedBy (Guid, FK to User)
- CreatedAt (DateTime)
- UpdatedAt (DateTime)
- PurchasedAt (DateTime, nullable)
- PurchasedBy (Guid, nullable, FK to User)

**ListCollaborator**
- Id (Guid)
- ListId (Guid, FK to ShoppingList)
- UserId (Guid, FK to User)
- PermissionLevel (enum: Owner, Editor, Viewer)
- InvitedBy (Guid, FK to User)
- InvitedAt (DateTime)
- AcceptedAt (DateTime, nullable)

**Category**
- Id (Guid)
- Name (string)
- Icon (string)
- Color (string)
- IsDefault (bool)
- CreatedBy (Guid, nullable, FK to User)

## Real-time Communication

### SignalR Hub Methods

**Client → Server**
- `JoinList(listId)`: Subscribe to list updates
- `LeaveList(listId)`: Unsubscribe from list updates
- `UpdatePresence(listId)`: Update user's active status

**Server → Client**
- `ItemAdded(item)`: New item added
- `ItemUpdated(item)`: Item modified
- `ItemDeleted(itemId)`: Item removed
- `ItemPurchased(itemId, userId)`: Item marked as purchased
- `ListUpdated(list)`: List details changed
- `CollaboratorJoined(userId, listId)`: New collaborator
- `PresenceChanged(userId, isActive)`: User went online/offline

### Conflict Resolution Strategy

1. **Last-Write-Wins**: Use timestamps for simple updates
2. **Optimistic Locking**: Version numbers for critical operations
3. **Merge Strategy**: For concurrent edits to different fields
4. **User Notification**: Alert on conflict detection

## Security Architecture

### Authentication Flow
1. User submits credentials
2. Server validates and generates JWT
3. Client stores JWT in httpOnly cookie
4. Client includes JWT in Authorization header
5. Server validates JWT on each request

### Authorization
- Role-Based Access Control (RBAC) at list level
- Permission checks in middleware
- Resource ownership validation

### Security Measures
- HTTPS enforcement
- CORS configuration
- Content Security Policy headers
- Rate limiting (100 requests/minute per user)
- Input validation and sanitization
- SQL injection prevention (parameterized queries)
- XSS prevention (output encoding)

## Performance Optimization

### Frontend
- Code splitting by route
- Lazy loading of components
- Image optimization (WebP, lazy loading)
- Debouncing search and filters
- Virtual scrolling for long lists
- Service Worker caching

### Backend
- Redis caching for frequently accessed data
- Database query optimization (indexes, pagination)
- Response compression (gzip/brotli)
- Connection pooling
- Async/await throughout
- Batch operations for multiple updates

### Database
- Indexes on foreign keys and frequently queried columns
- Materialized views for complex queries
- Partitioning for large tables
- Regular maintenance (vacuum, analyze)

## Monitoring and Observability

### Logging
- Structured logging (Serilog)
- Log levels: Trace, Debug, Info, Warning, Error, Critical
- Centralized logging (ELK stack or Application Insights)

### Metrics
- Request/response times
- Error rates
- Active users
- Database query performance
- Cache hit rates

### Tracing
- Distributed tracing across services
- Correlation IDs for request tracking

## Deployment Architecture

### Environments
- **Development**: Local development machines
- **Staging**: Pre-production testing
- **Production**: Live environment

### Infrastructure
- Container orchestration (Kubernetes/Docker)
- Auto-scaling based on load
- Health checks and self-healing
- Blue-green deployment
- Automated rollback on failure

### CI/CD Pipeline
1. Code push to Git
2. Automated tests (unit, integration)
3. Build Docker images
4. Push to container registry
5. Deploy to staging
6. Automated smoke tests
7. Manual approval
8. Deploy to production
9. Monitor and alert

