# Architecture Documentation

**Version**: 1.1  
**Last Updated**: November 5, 2025  
**Status**: Reflects Current Implementation (updated for .NET 9.0 and SQLite)

**Note**: Feature-specific architecture details are in each feature's `plan.md`:
- [Feature 001: User Authentication](./specs/001-user-authentication/plan.md)
- [Feature 002: User Profile Management](./specs/002-user-profile-management/plan.md)

See [Constitution](./.specify/memory/constitution.md) for development standards.

---

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
│                Application Layer (.NET 9.0)                  │
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
│  │   SQLite     │  │IMemoryCache  │  │  Blob Storage    │  │
│  │ (app.db file)│  │  (In-Proc)   │  │  (Images)        │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘

**Database**: SQLite embedded database (app.db file, no separate server needed)
```

## Frontend Architecture

### Actual Implemented Directory Structure

```
ae-infinity-ui/
├── src/
│   ├── components/
│   │   ├── common/
│   │   │   └── LoadingSpinner.tsx     ✅ Implemented
│   │   └── layout/
│   │       ├── AppLayout.tsx          ✅ Implemented
│   │       ├── AuthLayout.tsx         ✅ Implemented
│   │       ├── Header.tsx             ✅ Implemented
│   │       └── Sidebar.tsx            ✅ Implemented
│   ├── contexts/
│   │   └── AuthContext.tsx            ✅ Implemented (mock auth)
│   ├── hooks/
│   │   ├── useListItems.ts            ✅ Implemented
│   │   └── useNavigation.ts           ✅ Implemented
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── Login.tsx              ✅ Implemented
│   │   │   ├── Register.tsx           ✅ Implemented
│   │   │   └── ForgotPassword.tsx     ✅ Implemented
│   │   ├── errors/
│   │   │   ├── NotFound.tsx           ✅ Implemented
│   │   │   └── Forbidden.tsx          ✅ Implemented
│   │   ├── lists/
│   │   │   ├── ListsDashboard.tsx     🟡 Implemented (mock data)
│   │   │   ├── ListDetail.tsx         🟡 Implemented (mock data)
│   │   │   ├── CreateList.tsx         🟡 Implemented (mock data)
│   │   │   ├── ListSettings.tsx       🟡 Implemented (mock data)
│   │   │   ├── ShareList.tsx          🟡 Implemented (mock data)
│   │   │   ├── ManageCollaborators.tsx 🟡 Implemented (mock data)
│   │   │   └── ListHistory.tsx        🟡 Implemented (mock data)
│   │   ├── profile/
│   │   │   ├── Profile.tsx            ✅ Implemented
│   │   │   ├── ProfileSettings.tsx    ✅ Implemented
│   │   │   └── NotificationSettings.tsx ✅ Implemented
│   │   ├── AcceptInvite.tsx           ✅ Implemented
│   │   ├── Activity.tsx               ✅ Implemented (mock data)
│   │   ├── ArchivedLists.tsx          ✅ Implemented (mock data)
│   │   ├── Landing.tsx                ✅ Implemented
│   │   ├── People.tsx                 ✅ Implemented (mock data)
│   │   └── SharedLists.tsx            ✅ Implemented (mock data)
│   ├── services/
│   │   ├── authService.ts             ✅ Implemented
│   │   ├── listsService.ts            ✅ Implemented
│   │   ├── itemsService.ts            ✅ Implemented
│   │   ├── categoriesService.ts       ✅ Implemented
│   │   ├── searchService.ts           ✅ Implemented
│   │   └── index.ts                   ✅ Implemented
│   ├── types/
│   │   └── index.ts                   ✅ Implemented (326 lines, complete)
│   ├── utils/
│   │   ├── apiClient.ts               ✅ Implemented
│   │   ├── formatters.ts              ✅ Implemented
│   │   ├── permissions.ts             ✅ Implemented
│   │   └── index.ts                   ✅ Implemented
│   ├── App.tsx                        ✅ Implemented
│   ├── App.css                        ✅ Implemented
│   ├── main.tsx                       ✅ Implemented
│   └── index.css                      ✅ Implemented (Tailwind)
├── public/
│   └── vite.svg
├── index.html                         ✅ Implemented
├── vite.config.ts                     ✅ Implemented
├── tsconfig.json                      ✅ Implemented
├── tsconfig.app.json                  ✅ Implemented
├── tsconfig.node.json                 ✅ Implemented
├── tailwind.config.js                 ✅ Implemented
├── postcss.config.js                  ✅ Implemented
├── eslint.config.js                   ✅ Implemented
├── package.json                       ✅ Implemented
└── package-lock.json                  ✅ Implemented

Legend:
✅ = Fully implemented and production-ready
🟡 = Implemented UI with mock data, ready for API integration
❌ = Not implemented yet
```

### State Management Strategy (Actual Implementation)

**Local Component State** ✅
- Form inputs
- UI toggles (modals, dropdowns)
- Loading states
- Error states
- Mock data (temporary)

**Context API** ✅ Partially Implemented
- **AuthContext** ✅: Authentication state and user info (currently using mock)
- **Theme preferences** ❌: Not implemented
- **Global notifications** ❌: Not implemented

**Server State** ❌ Not Yet Implemented
- Currently using mock data in components
- Services are ready but not called yet
- No React Query or SWR implementation
- Plain fetch via apiClient

**Optimistic Updates** ❌ Not Yet Implemented
- Currently showing loading states only
- No optimistic UI updates
- No rollback mechanism
- No offline queue

### Key Frontend Patterns

1. **Component Composition**: Small, focused components
2. **Custom Hooks**: Encapsulate complex logic (useNavigation, useListItems)
3. **Error Boundaries**: Graceful error handling
4. **Code Splitting**: Route-based lazy loading
5. **Memoization**: Prevent unnecessary re-renders

---

## Frontend Implementation Details

### Type System (326 lines)

**Location**: `src/types/index.ts`

Complete TypeScript definitions covering:

**Core Types**:
- `User`, `UserRef` - User information and references
- `Permission` - Owner, Editor, Viewer roles
- `ListCollaborator` - User permissions on lists
- `ShoppingListSummary`, `ShoppingListDetail` - List data with different detail levels
- `ShoppingItem` - Items with category, notes, purchase status
- `Category`, `CategoryRef` - Item categorization

**API Request Types**:
- `RegisterRequest`, `LoginRequest` - Authentication
- `CreateListRequest`, `UpdateListRequest`, `ShareListRequest` - List management
- `CreateItemRequest`, `UpdateItemRequest`, `UpdatePurchasedStatusRequest` - Item management
- `ReorderItemsRequest`, `UpdateCollaboratorPermissionRequest` - Advanced operations
- `CreateCategoryRequest` - Custom categories

**API Response Types**:
- `AuthResponse` - JWT token and user data
- `ListsResponse`, `ItemsResponse`, `CategoriesResponse` - Collection responses
- `SearchResponse` - Search results with pagination
- `PaginationMetadata` - Page info for all list endpoints

**Query Parameter Types**:
- `GetListsParams`, `GetItemsParams`, `SearchParams`, `GetCategoriesParams`

**Error Types**:
- `ApiError`, `ApiErrorResponse` - Structured error responses

**SignalR Event Types**:
- `ItemAddedEvent`, `ItemUpdatedEvent`, `ItemDeletedEvent`
- `ItemPurchasedEvent`, `ListUpdatedEvent`
- `CollaboratorJoinedEvent`, `CollaboratorLeftEvent`
- `PresenceChangedEvent`

### API Services Layer

**Location**: `src/services/`

#### API Client (`utils/apiClient.ts`)
- JWT token management with localStorage
- HTTP methods: GET, POST, PUT, PATCH, DELETE
- Automatic Bearer token injection
- Query parameter building
- Structured error handling with `ApiClientError` class
- Type-safe generic requests

#### Authentication Service (`authService.ts`)
- `register()` - Create new user account
- `login()` - Authenticate user, store token
- `getCurrentUser()` - Fetch current user info
- `refreshToken()` - Refresh JWT token
- `logout()` - Clear token and session
- `isAuthenticated()` - Check auth status

#### Lists Service (`listsService.ts`)
- `getAllLists(params)` - Fetch all lists with filtering/sorting
- `getListById(id)` - Get detailed list information
- `createList(data)` - Create new list
- `updateList(id, data)` - Update list details
- `deleteList(id)` - Delete list permanently
- `archiveList(id)` / `unarchiveList(id)` - Archive operations
- `shareList(id, data)` - Share list with users by email
- `removeCollaborator(listId, userId)` - Remove user from list
- `updateCollaboratorPermission(listId, userId, data)` - Change permissions

#### Items Service (`itemsService.ts`)
- `getListItems(listId, params)` - Fetch items with filters
- `createItem(listId, data)` - Add new item
- `updateItem(listId, itemId, data)` - Update item details
- `deleteItem(listId, itemId)` - Remove item
- `updatePurchasedStatus(listId, itemId, data)` - Toggle purchased
- `markAsPurchased(listId, itemId)` - Convenience method
- `markAsNotPurchased(listId, itemId)` - Convenience method
- `reorderItems(listId, data)` - Update positions (drag-and-drop)

#### Categories Service (`categoriesService.ts`)
- `getAllCategories(params)` - Fetch all categories
- `createCategory(data)` - Create custom category
- `getDefaultCategories()` - System categories only
- `getAllCategoriesWithCustom()` - All categories including custom

#### Search Service (`searchService.ts`)
- `search(params)` - Search across lists and items
- `searchLists(query)` - Search lists only
- `searchItems(query)` - Search items only

### Utility Functions

**Location**: `src/utils/`

#### Formatters (`formatters.ts`)
- `formatDate(dateString)` - ISO to readable date (e.g., "November 3, 2025")
- `formatRelativeTime(dateString)` - Relative time (e.g., "2 hours ago")
- `formatDateTime(dateString)` - Date with time
- `pluralize(count, singular, plural)` - Smart pluralization
- `truncate(text, maxLength)` - Text truncation with ellipsis
- `getInitials(name)` - Extract initials (e.g., "JD" from "John Doe")
- `formatQuantity(quantity, unit)` - Format with unit (e.g., "2 gallons")
- `formatPercentage(value, total)` - Calculate and format percentage

#### Permissions (`permissions.ts`)
- `isOwner(permission)` - Check if user is owner
- `canEdit(permission)` - Check if user can edit (Owner or Editor)
- `isViewerOnly(permission)` - Check if view-only
- `canManageCollaborators(permission)` - Owner only
- `canDeleteList(permission)` - Owner only
- `canArchiveList(permission)` - Owner only
- `canShareList(permission)` - Owner only
- `canAddItems(permission)` - Owner or Editor
- `canEditItems(permission)` - Owner or Editor
- `canDeleteItems(permission)` - Owner or Editor
- `canMarkPurchased(permission)` - All users (including Viewer)
- `getPermissionColor(permission)` - Tailwind classes for badges
- `getPermissionDescription(permission)` - Human-readable description

### Layout Components

**Location**: `src/components/layout/`

#### AppLayout
- Main application wrapper for authenticated pages
- Contains Header and Sidebar
- Provides consistent layout structure
- Responsive design with mobile menu

#### AuthLayout
- Clean layout for authentication pages
- Centered card design
- Minimal header, no sidebar
- Focused user experience

#### Header
- App branding/logo
- Search functionality (placeholder)
- User menu dropdown with profile links
- Notifications icon (placeholder)
- Mobile menu toggle button
- Logout functionality

#### Sidebar
- Navigation links with icons:
  - My Lists (`/lists`)
  - Shared with Me (`/shared`)
  - Archived (`/archived`)
  - People (`/people`)
  - Activity (`/activity`)
- Active route highlighting
- Create new list button
- Collapsible on mobile
- Responsive behavior

### Context & Hooks

**Location**: `src/contexts/` and `src/hooks/`

#### AuthContext
- Global authentication state
- User information storage
- Login/logout functions
- Currently uses localStorage mock
- Ready for real `authService` integration
- Provides `useAuth()` hook

#### useNavigation Hook
- Centralized navigation logic
- Type-safe route navigation
- Wraps React Router's `useNavigate`
- Consistent navigation patterns

#### useListItems Hook
- Local state management for list items
- CRUD operations on items
- Ready for API service integration
- Optimistic update preparation

### Implemented Pages

All pages use **native HTML elements styled with Tailwind CSS**.

#### Authentication Pages (`/pages/auth/`)
- **Login** - Email/password form, remember me, links to register/forgot password
- **Register** - Email, display name, password with strength indicator
- **ForgotPassword** - Email input for password reset (UI only)

#### Lists Pages (`/pages/lists/`)
- **ListsDashboard** - Grid/list view, filters, sort, search, create button
- **ListDetail** - Items list, quick add form, collaborators sidebar, action buttons
- **CreateList** - Name and description form
- **ListSettings** - Edit list, archive, delete (permission-based)
- **ShareList** - Email input, permission selector, pending invitations
- **ManageCollaborators** - List of collaborators, change permissions, remove
- **ListHistory** - Timeline of purchases (placeholder)

#### Collection Pages
- **SharedLists** (`/shared`) - Grid of lists shared with user (non-owned)
- **ArchivedLists** (`/archived`) - List of archived lists with unarchive/delete

#### Social Pages
- **People** (`/people`) - Contact list, stats, invite section
- **Activity** (`/activity`) - Activity feed with filters and timeline

#### Profile Pages (`/pages/profile/`)
- **Profile** - User info display, quick action cards
- **ProfileSettings** - Edit profile, change password, danger zone
- **NotificationSettings** - Notification preferences with toggles

#### Other Pages
- **Landing** (`/`) - Hero section, auto-redirect if authenticated
- **AcceptInvite** (`/invite/:token`) - Accept invitation flow
- **NotFound** (`/404`) - 404 error page
- **Forbidden** (`/403`) - 403 access denied page

### Routing Structure

**Location**: `src/App.tsx`

- React Router v7 in BrowserRouter mode
- Protected routes wrapped with authentication check
- Public-only routes (redirect if authenticated)
- Layout wrappers for consistent structure
- All 22 pages routed and accessible

### Backend Integration Points

To connect to the real API:

1. **Update Environment Variables**
   - Create `.env` file
   - Set `VITE_API_BASE_URL=http://localhost:5233/api`

2. **Update AuthContext** (`src/contexts/AuthContext.tsx`)
   - Replace localStorage mock with `authService.login()`
   - Store token from API response
   - Fetch user on app load with `authService.getCurrentUser()`
   - Handle token expiration

3. **Replace Mock Data in Pages**
   - All list pages have mock data in `useState` hooks
   - Replace with service calls in `useEffect` hooks
   - Services are already imported and ready to use

4. **Add Error Handling**
   - Wrap service calls in try/catch
   - Display error messages to users
   - Handle 401 (redirect to login)
   - Handle 403 (show forbidden message)

5. **Add Real-time (Future)**
   - Install `@microsoft/signalr`
   - Create SignalR hub connection
   - Subscribe to events in list detail pages
   - Update local state on events

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

#### Login Process
1. **User Submits Credentials**: Email + password via `POST /auth/login`
2. **Server Validation**:
   - Look up user by normalized email (case-insensitive)
   - Verify password using BCrypt hash comparison
   - Return generic error if email or password invalid (security best practice)
3. **JWT Generation**:
   - Create JWT with HMAC-SHA256 algorithm
   - Include claims: User ID (`sub`), Email, Display Name, JWT ID (`jti`)
   - Set expiration to 24 hours from issuance
   - Sign with secret key from configuration
4. **Response**: Return JWT token, expiration time, and user details
5. **Client Storage**: Client stores JWT (typically in memory or localStorage)
6. **Update Audit**: Server updates user's `lastLoginAt` timestamp

#### Authenticated Request Flow
1. **Client Request**: Include JWT in Authorization header: `Bearer <token>`
2. **JWT Validation** (ASP.NET Core JWT Bearer Middleware):
   - Verify signature using secret key
   - Validate issuer, audience, and expiration
   - Extract claims and populate `HttpContext.User`
3. **Authorization Check**: Verify user has permission for requested resource
4. **Process Request**: Execute controller action
5. **Response**: Return data or error

#### Logout Process
1. **Client Request**: `POST /auth/logout` with JWT token
2. **Server Action**: Log logout event (audit purposes)
3. **Client Action**: Remove JWT from storage
4. **Token Behavior**: Token remains technically valid until expiration (24h)

**Note**: Current implementation does not maintain server-side token blacklist. Tokens are stateless and valid until expiration.

### Authentication Implementation Details

**Technology Stack:**
- **ASP.NET Core Authentication Middleware**: JWT Bearer authentication
- **JWT Library**: Microsoft.IdentityModel.Tokens, System.IdentityModel.Tokens.Jwt
- **Password Hashing**: BCrypt via BCrypt.Net-Next

**JWT Configuration** (`appsettings.json`):
```json
{
  "Jwt": {
    "Secret": "[Secret key - change in production]",
    "Issuer": "AeInfinityApi",
    "Audience": "AeInfinityClient"
  }
}
```

**Token Validation Parameters**:
- `ValidateIssuer`: true
- `ValidateAudience`: true
- `ValidateLifetime`: true (expires after 24h)
- `ValidateIssuerSigningKey`: true
- `ClockSkew`: Zero (no grace period)

**Password Security**:
- Minimum length: 8 characters (enforced by validation)
- Hashing: BCrypt with automatic salt generation
- Storage: Only hash stored in `users.password_hash` column
- Verification: Re-hash input and compare to stored hash

### Authorization

**Role-Based Access Control (RBAC):**
- Implemented at list level via `user_to_list` junction table
- Four permission levels: Owner, Editor, Editor-Limited, Viewer
- Permissions stored in `roles` table with capability flags
- Each list collaboration has assigned role

**Authorization Enforcement:**
1. **Middleware Level**: `[Authorize]` attribute on controllers/actions
2. **Business Logic Level**: Permission checks in CQRS command handlers
3. **Database Level**: Queries filtered by user access

**Permission Validation Pattern:**
```csharp
// Get user's role for the list
var userToList = await _context.UserToLists
    .Include(u => u.Role)
    .FirstOrDefaultAsync(u => u.UserId == currentUserId && u.ListId == listId);

if (userToList == null)
    throw new ForbiddenException("You don't have access to this list");

// Check specific capability
if (!userToList.Role.CanManageItems)
    throw new ForbiddenException("You don't have permission to manage items");
```

### Security Measures

**Transport Security:**
- HTTPS enforcement in production
- CORS configured to allow specific origins (currently `AllowAll` for development)
- Secure headers (recommended: add Helmet.js equivalent for .NET)

**Authentication Security:**
- JWT tokens expire after 24 hours
- BCrypt password hashing with automatic salts
- Case-insensitive email lookup prevents timing attacks
- Generic error messages for failed authentication

**Input Validation:**
- FluentValidation for request validation
- Automatic validation via MediatR pipeline behavior
- 400 Bad Request returned for validation failures

**Database Security:**
- Entity Framework Core parameterized queries (prevents SQL injection)
- Soft delete pattern maintains audit trail
- Audit columns track all changes (`created_by`, `modified_by`, `deleted_by`)

**API Security:**
- Rate limiting: Planned (100 requests/minute per user)
- Exception handling middleware catches and sanitizes errors
- Validation on all inputs

**Future Security Enhancements:**
- Refresh tokens for extended sessions
- Token blacklist for instant logout
- Multi-factor authentication (MFA)
- Email verification requirement
- Password reset flow with time-limited tokens
- Rate limiting implementation
- CAPTCHA for login attempts
- Content Security Policy (CSP) headers
- Stricter CORS policy for production

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

