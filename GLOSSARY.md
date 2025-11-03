# AE Infinity - Glossary & Terminology

Comprehensive glossary of terms, jargon, and concepts used throughout the AE Infinity project.

## 📖 Purpose

This document provides consistent terminology for:
- **Developers** - Understanding domain concepts
- **Product Managers** - Aligning on feature naming
- **Designers** - Using correct terminology in UI
- **AI Agents** - Interpreting context correctly

## 🗂️ Domain Concepts

### Shopping List Management

**List**
- **Definition**: A collection of shopping items created by a user
- **Synonyms**: Shopping list
- **Not**: "Cart" (that implies e-commerce checkout)
- **Database**: `lists` table
- **API**: `/api/v1/lists`
- **UI**: "Weekly Groceries", "Party Shopping"

**Item**
- **Definition**: A single product or good to be purchased on a shopping list
- **Synonyms**: Shopping item, list item, product
- **Not**: "Task" (items aren't tasks)
- **Database**: `list_items` table
- **API**: `/api/v1/lists/{listId}/items`
- **UI**: "Milk", "Bananas", "Chicken Breast"

**Owner**
- **Definition**: The user who created a list and has full control
- **Role**: Highest permission level
- **Capabilities**: All permissions (see [personas/permission-matrix.md](./personas/permission-matrix.md))
- **Database**: `lists.owner_id`, role in `user_to_list` table
- **Note**: There is exactly one owner per list
- **Can**: Transfer ownership to another collaborator

**Collaborator**
- **Definition**: Any user with access to a list (including owner)
- **Synonyms**: List member, participant
- **Database**: `user_to_list` table
- **Types**: Owner, Editor, Editor-Limited, Viewer
- **Note**: Owner is a special type of collaborator

**Editor**
- **Definition**: Collaborator who can modify items but not list settings
- **Role**: Medium permission level
- **Capabilities**: Add, edit, delete items; mark purchased
- **Cannot**: Modify list details, manage collaborators, delete list
- **Database**: Role in `user_to_list` table

**Editor-Limited**
- **Definition**: Collaborator who can add items and edit only their own items
- **Role**: Restricted editor permission
- **Use Case**: Trust-building (teenager learning responsibility)
- **Capabilities**: Add items, edit own items only, mark purchased
- **Cannot**: Edit others' items, modify list, manage collaborators

**Viewer**
- **Definition**: Collaborator with read-only access
- **Role**: Lowest permission level
- **Capabilities**: View list and items, see real-time updates
- **Cannot**: Make any modifications
- **Database**: Role in `user_to_list` table

### Collaboration Features

**Sharing** / **Inviting**
- **Definition**: Process of granting another user access to a list
- **Action**: Owner or Editor with permissions invites user by email
- **Result**: Creates pending record in `user_to_list` table
- **Workflow**: Invite → Accept → Active Collaborator

**Invitation**
- **Definition**: Pending request for user to access a list
- **Status**: `is_pending = true` in `user_to_list`
- **States**: Pending → Accepted (or Declined/Expired)
- **Accepting**: Sets `is_pending = false`, populates `accepted_at`

**Permission** / **Role**
- **Definition**: Level of access a collaborator has to a list
- **Types**: Owner, Editor, Editor-Limited, Viewer
- **Database**: `roles` table with capability flags
- **Assignment**: Via `user_to_list.role_id`
- **Changing**: Owner can update collaborator's role

**Transfer Ownership**
- **Definition**: Changing list owner to different collaborator
- **Action**: Current owner assigns Owner role to another user
- **Result**: Updates `lists.owner_id`, maintains audit trail
- **Note**: Previous owner typically becomes Editor unless removed

### Item Management

**Purchased** / **Checked**
- **Definition**: Item has been bought and placed in cart
- **Status**: `is_purchased = true` in database
- **Tracking**: Records who (`purchased_by`) and when (`purchased_at`)
- **UI**: Checked checkbox, strikethrough text
- **Action**: Toggle purchased status

**Unpurchased**
- **Definition**: Item still needs to be bought
- **Status**: `is_purchased = false`
- **Default**: New items are unpurchased

**Position**
- **Definition**: Display order of items within a list
- **Type**: Integer (0, 1, 2, ...)
- **Purpose**: User-defined ordering, drag-and-drop
- **Database**: `list_items.position`
- **Auto-assigned**: `MAX(position) + 1` for new items

**Category**
- **Definition**: Organizational grouping for items
- **Types**: Default (system-defined) or Custom (user-created)
- **Examples**: Produce, Dairy, Meat, Bakery
- **Purpose**: Group items by store section, filter/sort
- **Database**: `categories` table

**Quantity** & **Unit**
- **Quantity**: Amount to purchase (e.g., 2)
- **Unit**: Unit of measurement (e.g., "gallons", "lbs", "ea")
- **Example**: "2 gallons" of milk

**Notes**
- **Definition**: Additional specifications or preferences for an item
- **Examples**: "Organic only", "Brand X preferred", "On sale this week"
- **Character Limit**: Typically 500 characters

### List States

**Active**
- **Definition**: List is being used for current/future shopping
- **Status**: `is_archived = false`, `is_deleted = false`
- **Default**: New lists are active

**Archived**
- **Definition**: List is completed and saved for reference
- **Status**: `is_archived = true` in database
- **Purpose**: Keep historical lists without cluttering active view
- **Reversible**: Can be unarchived
- **Example**: Last year's holiday party list

**Deleted** (Soft Delete)
- **Definition**: List is marked for deletion but not physically removed
- **Status**: `is_deleted = true` in database
- **Purpose**: Maintain audit trail, allow restoration
- **Query Filter**: Excluded from normal queries
- **Restoration**: Possible by clearing `is_deleted`, `deleted_at`, `deleted_by`

## 🔧 Technical Concepts

### Authentication & Security

**Authentication**
- **Definition**: Process of verifying a user's identity
- **Method**: Email + password → JWT token
- **Implementation**: BCrypt password hashing, JWT Bearer tokens
- **Flow**: Login → Receive token → Include in Authorization header

**Password Hash**
- **Definition**: One-way encryption of user passwords
- **Algorithm**: BCrypt (recommended) or Argon2
- **Storage**: Only hashed password stored in database, never plain text
- **Verification**: Password input is hashed and compared to stored hash
- **Salt**: Random data added before hashing to prevent rainbow table attacks

**JWT Claims**
- **Definition**: Key-value pairs embedded in JWT token payload
- **Standard Claims**: 
  - `sub` (Subject): User ID
  - `email`: User's email address
  - `jti` (JWT ID): Unique token identifier
  - `exp` (Expiration): Token expiry timestamp
  - `iss` (Issuer): "AeInfinityApi"
  - `aud` (Audience): "AeInfinityClient"
- **Purpose**: Carry user identity and metadata without database lookup

**Token Expiration**
- **Definition**: Timestamp when JWT becomes invalid
- **Duration**: 24 hours from issuance
- **Behavior**: After expiration, user must login again
- **Security**: Limits impact of stolen tokens
- **Validation**: Checked on every API request

**Bearer Authentication**
- **Definition**: HTTP authentication scheme using tokens
- **Format**: `Authorization: Bearer eyJhbGciOi...`
- **Usage**: Included in every authenticated API request
- **Standard**: RFC 6750 (OAuth 2.0 Bearer Token Usage)

**Authorization**
- **Definition**: Determining what an authenticated user can access
- **Implementation**: Role-based permissions at list level
- **Check Location**: Middleware and business logic layer
- **Permissions**: Owner, Editor, Editor-Limited, Viewer

### Database Patterns

**Soft Delete**
- **Definition**: Logical deletion without physical removal from database
- **Implementation**: `is_deleted` flag, `deleted_at` timestamp, `deleted_by` user ID
- **Pattern**: All tables implement soft delete
- **Rationale**: Maintain audit trail, enable restoration, comply with regulations

**Audit Trail**
- **Definition**: Complete tracking of who created, modified, and deleted records
- **Columns**: `created_by`, `created_at`, `modified_by`, `modified_at`, `deleted_by`, `deleted_at`
- **Purpose**: Accountability, debugging, compliance
- **Immutability**: Audit data should never be altered

**GUID** / **UUID**
- **Definition**: Globally Unique Identifier (128-bit number)
- **Format**: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- **Usage**: Primary keys for all tables
- **Benefits**: No collision, distributed systems friendly, non-sequential (security)

**Foreign Key** (FK)
- **Definition**: Column referencing primary key in another table
- **Purpose**: Enforce referential integrity
- **Notation**: `FK → table.column`
- **Example**: `lists.owner_id` (FK → `users.id`)

**Junction Table**
- **Definition**: Table managing many-to-many relationships
- **Example**: `user_to_list` (users ↔ lists)
- **Contains**: Foreign keys to both related tables plus relationship metadata

### Architecture Patterns

**Clean Architecture**
- **Definition**: Layered architecture with clear separation of concerns
- **Layers**: Domain → Application → Infrastructure → Presentation (API)
- **Benefit**: Testable, maintainable, technology-agnostic core

**Repository Pattern**
- **Definition**: Abstraction layer over data access
- **Purpose**: Decouple business logic from data access implementation
- **Interface**: `IRepository<T>`
- **Implementation**: `Repository<T>` in Infrastructure layer

**CQRS** (Future)
- **Definition**: Command Query Responsibility Segregation
- **Concept**: Separate read and write operations
- **Benefit**: Optimized queries, scalability
- **Status**: Consideration for future

**Entity Framework (EF) Core**
- **Definition**: Object-Relational Mapper (ORM) for .NET
- **Purpose**: Map C# objects to database tables
- **Benefits**: Type-safe queries, migrations, change tracking

**DbContext**
- **Definition**: EF Core class representing database session
- **Class**: `ApplicationDbContext`
- **Purpose**: Configure entities, execute queries, track changes

**Migration**
- **Definition**: Version-controlled database schema changes
- **Format**: C# code that EF Core can apply/rollback
- **Command**: `dotnet ef migrations add MigrationName`

### API Concepts

**REST** (REpresentational State Transfer)
- **Definition**: Architectural style for web APIs
- **Principles**: Stateless, resource-based URLs, HTTP verbs

**Endpoint**
- **Definition**: Specific API URL and HTTP method combination
- **Example**: `GET /api/v1/lists/{listId}`
- **Parts**: HTTP Method + Path + Query Parameters

**HTTP Verbs**
- **GET**: Retrieve data (read)
- **POST**: Create new resource
- **PUT**: Update entire resource
- **PATCH**: Partial update
- **DELETE**: Remove resource

**JWT** (JSON Web Token)
- **Definition**: Compact, URL-safe token for authentication
- **Structure**: Header.Payload.Signature
- **Usage**: Bearer token in Authorization header
- **Contains**: User ID, claims, expiration

**Bearer Token**
- **Definition**: Access token passed in HTTP Authorization header
- **Format**: `Authorization: Bearer <token>`
- **Purpose**: Authenticate API requests

**Rate Limiting**
- **Definition**: Restricting number of API requests per time period
- **Limits**: 100 req/min (authenticated), 20 req/min (anonymous)
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Real-time Concepts

**SignalR**
- **Definition**: ASP.NET Core library for real-time web functionality
- **Protocol**: WebSockets (with fallbacks)
- **Purpose**: Server-to-client push notifications

**Hub**
- **Definition**: SignalR server-side component managing connections
- **Class**: `ShoppingListHub`
- **Methods**: Define client-to-server and server-to-client communication

**Connection**
- **Definition**: WebSocket connection between client and server
- **Lifecycle**: Connect → Join rooms → Send/receive → Disconnect
- **Management**: Automatic reconnection on failure

**Broadcast**
- **Definition**: Sending message to multiple connected clients
- **Example**: When item purchased, notify all users viewing that list
- **Scope**: Can be to all clients, specific room, or specific users

**Presence**
- **Definition**: Indication of whether user is active/online
- **Purpose**: Show who's currently viewing/shopping
- **UI**: "Sarah is shopping now" indicator
- **Implementation**: Join/leave list events, heartbeat

**Optimistic Update**
- **Definition**: Update UI immediately before server confirms
- **Pattern**: Update → API call → Confirm (or Rollback on error)
- **Purpose**: Perceived performance, instant feedback
- **Risk**: Must handle rollback on failure

**Conflict Resolution**
- **Strategy**: Last-Write-Wins (use timestamps)
- **Alternative**: Optimistic Locking (version numbers)
- **Notification**: Alert user on detected conflicts

### Frontend Concepts

**Context API**
- **Definition**: React's built-in state management
- **Purpose**: Share state across component tree
- **Usage**: AuthContext, ThemeContext, NotificationContext

**React Query** / **SWR**
- **Definition**: Data-fetching and caching libraries for React
- **Purpose**: Manage server state (API data)
- **Features**: Caching, refetching, optimistic updates

**Custom Hook**
- **Definition**: Reusable React function starting with "use"
- **Purpose**: Encapsulate logic (data fetching, subscriptions)
- **Examples**: `useAuth()`, `useLists()`, `useRealtime()`

**Component Composition**
- **Definition**: Building complex UIs from smaller components
- **Pattern**: Parent components compose child components
- **Benefit**: Reusability, testability, separation of concerns

## 🔤 Naming Conventions

### Database Tables

**Format**: Lowercase, plural, snake_case  
**Examples**: `users`, `lists`, `list_items`, `user_to_list`

**Junction Tables**: `entity1_to_entity2`  
**Example**: `user_to_list` (not `user_list` or `list_users`)

### Database Columns

**Format**: Lowercase, snake_case  
**Examples**: `created_at`, `is_deleted`, `owner_id`

**Foreign Keys**: `{entity}_id`  
**Example**: `owner_id`, `category_id`, `list_id`

**Booleans**: `is_{condition}` or `has_{attribute}`  
**Examples**: `is_deleted`, `is_archived`, `is_pending`

**Timestamps**: `{action}_at`  
**Examples**: `created_at`, `purchased_at`, `archived_at`

### API Endpoints

**Format**: kebab-case, REST conventions  
**Pattern**: `/api/v{version}/{resource}/{id}/{sub-resource}`

**Examples**:
- `/api/v1/lists` - List collection
- `/api/v1/lists/{listId}` - Specific list
- `/api/v1/lists/{listId}/items` - Items in list
- `/api/v1/lists/{listId}/items/{itemId}/purchased` - Item purchase status

### C# Code

**Classes**: PascalCase  
**Example**: `ShoppingList`, `ListItem`, `ApplicationDbContext`

**Interfaces**: `I` prefix + PascalCase  
**Example**: `IRepository<T>`, `IApplicationDbContext`

**Properties**: PascalCase  
**Example**: `CreatedAt`, `IsDeleted`, `OwnerId`

**Methods**: PascalCase, verb-based  
**Example**: `GetListsAsync()`, `CreateItemAsync()`, `MarkAsPurchased()`

**Private Fields**: `_camelCase`  
**Example**: `_dbContext`, `_logger`

### TypeScript/React

**Components**: PascalCase  
**Example**: `ShoppingListCard`, `ItemRow`, `ShareDialog`

**Hooks**: camelCase, `use` prefix  
**Example**: `useAuth()`, `useLists()`, `useRealtime()`

**Functions**: camelCase  
**Example**: `formatDate()`, `validateEmail()`, `debounce()`

**Constants**: UPPER_SNAKE_CASE  
**Example**: `API_BASE_URL`, `MAX_RETRIES`

## 🔗 Cross-References

- **Data Models**: [architecture/data-models.md](./architecture/data-models.md) - Complete schema
- **Permissions**: [personas/permission-matrix.md](./personas/permission-matrix.md) - Role definitions
- **API**: [API_SPEC.md](./API_SPEC.md) - Endpoint specifications
- **Backend Schema**: [../ae-infinity-api/docs/DB_SCHEMA.md](../ae-infinity-api/docs/DB_SCHEMA.md)

---

**Note**: When in doubt about terminology, refer to this glossary. Consistency is key for clear communication across the team and in code.

