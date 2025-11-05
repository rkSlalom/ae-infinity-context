# API Reference

**Base URL**: `http://localhost:5233/api` (Development)  
**Authentication**: Bearer JWT Token  
**API Version**: v1  
**Tech Stack**: ASP.NET Core 9.0, SQLite, Entity Framework Core 9.0

---

## 📖 Quick Links

- 🚀 **[Getting Started](./GETTING_STARTED.md)** - Quick setup guide
- 🏛️ **[Architecture](./ARCHITECTURE.md)** - System design
- 📋 **[Feature Catalog](./specs/README.md)** - All feature specifications
- 🔐 **[Authentication Spec](./specs/001-user-authentication/spec.md)** - Auth requirements
- 👤 **[Profile Spec](./specs/002-user-profile-management/spec.md)** - Profile requirements

---

## 🌐 Live API Documentation

**Swagger UI**: [http://localhost:5233/index.html](http://localhost:5233/index.html)

The live Swagger documentation provides:
- ✅ Interactive API exploration
- ✅ Request/response schemas
- ✅ "Try it out" functionality
- ✅ Authentication flow testing

**Note**: This document provides a high-level overview. For detailed contracts, see each feature's `contracts/` directory.

---

## 🔐 Authentication

All endpoints (except `/auth/register` and `/auth/login`) require authentication.

### **Include JWT Token**

```http
Authorization: Bearer <your_jwt_token>
```

### **Token Expiration**
- Tokens expire after **24 hours**
- When expired, login again to get a new token
- Future: Refresh token mechanism (Feature 001, P2)

---

## 📚 API Endpoints by Feature

### **Feature 001: User Authentication** ✅ Implemented (80%)

**Documentation**: [spec.md](./specs/001-user-authentication/spec.md) | [plan.md](./specs/001-user-authentication/plan.md) | [contracts/](./specs/001-user-authentication/contracts/)

| Endpoint | Method | Auth | Description | Status |
|----------|--------|------|-------------|--------|
| `/auth/register` | POST | No | Register new user account | ✅ Implemented |
| `/auth/login` | POST | No | Login and receive JWT token | ✅ Implemented |
| `/auth/logout` | POST | Yes | Logout (client-side token removal) | ✅ Implemented |
| `/users/me` | GET | Yes | Get current user profile | ✅ Implemented |
| `/auth/forgot-password` | POST | No | Request password reset email | 📋 Planned (P2) |
| `/auth/reset-password` | POST | No | Reset password with token | 📋 Planned (P2) |
| `/auth/verify-email` | POST | Yes | Verify email address with token | 📋 Planned (P2) |

#### **Register User**

```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "displayName": "John Doe",
  "password": "SecurePassword123!"
}
```

**Response**: `200 OK`
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresAt": "2025-11-06T12:00:00Z",
  "user": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "email": "user@example.com",
    "displayName": "John Doe",
    "avatarUrl": null,
    "isEmailVerified": false,
    "createdAt": "2025-11-05T12:00:00Z"
  }
}
```

**Contract**: [login-response.json](./specs/001-user-authentication/contracts/login-response.json)

---

#### **Login**

```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response**: `200 OK` (same as register)

**Test Accounts**:
- `sarah@example.com` / `Password123!` - Owner
- `alex@example.com` / `Password123!` - Collaborator
- `mike@example.com` / `Password123!` - Viewer

**Contract**: [login-request.json](./specs/001-user-authentication/contracts/login-request.json), [login-response.json](./specs/001-user-authentication/contracts/login-response.json)

---

#### **Get Current User**

```http
GET /users/me
Authorization: Bearer <token>
```

**Response**: `200 OK`
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "email": "user@example.com",
  "displayName": "John Doe",
  "avatarUrl": "https://example.com/avatar.jpg",
  "isEmailVerified": true,
  "lastLoginAt": "2025-11-05T12:00:00Z",
  "createdAt": "2025-11-04T10:00:00Z"
}
```

**Contract**: [user.json](./specs/001-user-authentication/contracts/user.json)

---

### **Feature 002: User Profile Management** ✅ Specified, 📋 Planned

**Documentation**: [spec.md](./specs/002-user-profile-management/spec.md) | [plan.md](./specs/002-user-profile-management/plan.md) | [contracts/](./specs/002-user-profile-management/contracts/)

| Endpoint | Method | Auth | Description | Status |
|----------|--------|------|-------------|--------|
| `/users/me` | PATCH | Yes | Update display name and avatar | 📋 Planned (P1) |
| `/users/me/stats` | GET | Yes | Get user activity statistics | 📋 Planned (P2) |
| `/users/{userId}` | GET | Yes | View public profile (collaborators) | 📋 Planned (P3) |

#### **Update Profile**

```http
PATCH /users/me
Authorization: Bearer <token>
Content-Type: application/json

{
  "displayName": "Jane Doe",
  "avatarUrl": "https://example.com/new-avatar.jpg"
}
```

**Response**: `200 OK`
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "email": "user@example.com",
  "displayName": "Jane Doe",
  "avatarUrl": "https://example.com/new-avatar.jpg",
  "isEmailVerified": true,
  "lastLoginAt": "2025-11-05T12:00:00Z",
  "createdAt": "2025-11-04T10:00:00Z"
}
```

**Contract**: [update-profile-request.json](./specs/002-user-profile-management/contracts/update-profile-request.json)

---

#### **Get User Statistics**

```http
GET /users/me/stats
Authorization: Bearer <token>
```

**Response**: `200 OK`
```json
{
  "totalListsOwned": 5,
  "totalListsShared": 3,
  "totalItemsCreated": 42,
  "totalItemsPurchased": 28,
  "totalActiveCollaborations": 2,
  "lastActivityAt": "2025-11-05T11:30:00Z"
}
```

**Contract**: [user-stats-response.json](./specs/002-user-profile-management/contracts/user-stats-response.json)

---

### **Feature 003: Shopping Lists CRUD** 📋 To Specify

**Expected Endpoints**:

| Endpoint | Method | Auth | Description | Status |
|----------|--------|------|-------------|--------|
| `/lists` | GET | Yes | Get all lists (owned + shared) | 📋 To Specify |
| `/lists` | POST | Yes | Create new shopping list | 📋 To Specify |
| `/lists/{listId}` | GET | Yes | Get list details with items | 📋 To Specify |
| `/lists/{listId}` | PUT | Yes | Update list name/description | 📋 To Specify |
| `/lists/{listId}` | DELETE | Yes | Delete list permanently (owner only) | 📋 To Specify |
| `/lists/{listId}/archive` | POST | Yes | Archive list (owner only) | 📋 To Specify |
| `/lists/{listId}/unarchive` | POST | Yes | Restore archived list | 📋 To Specify |

**Consolidate From**: `old_documents/API_SPEC.md`, `old_documents/schemas/list*.json`

---

### **Feature 004: List Items Management** 📋 To Specify

**Expected Endpoints**:

| Endpoint | Method | Auth | Description | Status |
|----------|--------|------|-------------|--------|
| `/lists/{listId}/items` | GET | Yes | Get all items in list | 📋 To Specify |
| `/lists/{listId}/items` | POST | Yes | Add new item to list | 📋 To Specify |
| `/lists/{listId}/items/{itemId}` | PUT | Yes | Update item details | 📋 To Specify |
| `/lists/{listId}/items/{itemId}` | DELETE | Yes | Remove item from list | 📋 To Specify |
| `/lists/{listId}/items/{itemId}/purchased` | PATCH | Yes | Toggle purchased status | 📋 To Specify |
| `/lists/{listId}/items/reorder` | POST | Yes | Reorder items (drag-and-drop) | 📋 To Specify |

**Consolidate From**: `old_documents/API_SPEC.md`, `old_documents/schemas/list-item*.json`

---

### **Feature 005: Categories System** 📋 To Specify

**Expected Endpoints**:

| Endpoint | Method | Auth | Description | Status |
|----------|--------|------|-------------|--------|
| `/categories` | GET | Yes | Get all categories (default + custom) | 📋 To Specify |
| `/categories` | POST | Yes | Create custom category | 📋 To Specify |
| `/categories/default` | GET | Yes | Get default categories only | 📋 To Specify |

**Consolidate From**: `old_documents/API_SPEC.md`, `old_documents/schemas/category.json`

---

### **Feature 006: Basic Search** 📋 To Specify

**Expected Endpoints**:

| Endpoint | Method | Auth | Description | Status |
|----------|--------|------|-------------|--------|
| `/search` | GET | Yes | Search lists and items by name | 📋 To Specify |
| `/search/lists` | GET | Yes | Search lists only | 📋 To Specify |
| `/search/items` | GET | Yes | Search items only | 📋 To Specify |

**Consolidate From**: `old_documents/API_SPEC.md`, `old_documents/schemas/search-result.json`

---

### **Feature 007: Real-time Collaboration** 📋 To Specify

**SignalR Hub**: `/hubs/shopping-list`

**Expected Methods**:
- `JoinList(listId)` - Subscribe to list updates
- `LeaveList(listId)` - Unsubscribe from list updates
- `UpdatePresence(listId)` - Update active status

**Events** (Server → Client):
- `ItemAdded` - New item added to list
- `ItemUpdated` - Item details changed
- `ItemDeleted` - Item removed from list
- `ItemPurchased` - Item marked as purchased
- `ListUpdated` - List name/description changed
- `CollaboratorJoined` - New collaborator added
- `PresenceChanged` - User went online/offline

**Consolidate From**: `old_documents/ARCHITECTURE.md` (Real-time Communication section)

---

### **Feature 008: Invitations & Permissions** 📋 To Specify

**Expected Endpoints**:

| Endpoint | Method | Auth | Description | Status |
|----------|--------|------|-------------|--------|
| `/lists/{listId}/share` | POST | Yes | Invite users by email | 📋 To Specify |
| `/lists/{listId}/collaborators` | GET | Yes | Get all collaborators | 📋 To Specify |
| `/lists/{listId}/collaborators/{userId}` | PATCH | Yes | Update collaborator permission | 📋 To Specify |
| `/lists/{listId}/collaborators/{userId}` | DELETE | Yes | Remove collaborator | 📋 To Specify |
| `/invitations/{token}/accept` | POST | Yes | Accept invitation | 📋 To Specify |

**Consolidate From**: `old_documents/API_SPEC.md`, `old_documents/schemas/invitation.json`, `old_documents/schemas/collaborator.json`

---

## 📊 Common Patterns

### **Pagination**

Lists and collections support pagination:

```http
GET /lists?page=1&pageSize=20
```

**Response Headers**:
```
X-Total-Count: 100
X-Page: 1
X-Page-Size: 20
X-Total-Pages: 5
```

**Response Body**:
```json
{
  "items": [...],
  "pagination": {
    "currentPage": 1,
    "pageSize": 20,
    "totalItems": 100,
    "totalPages": 5
  }
}
```

---

### **Filtering**

```http
GET /lists?status=active&sort=createdAt:desc
```

**Common Filters**:
- `status` - `active`, `archived`, `all`
- `sort` - Field name + direction: `createdAt:desc`, `name:asc`
- `q` - Search query (full-text search)

---

### **Error Responses**

All errors follow this format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "displayName",
        "message": "Display name must be between 2 and 100 characters"
      }
    ]
  }
}
```

**Common Status Codes**:
- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success with no response body
- `400 Bad Request` - Validation error
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Duplicate resource (e.g., email already exists)
- `500 Internal Server Error` - Server error

---

## 🔒 Authorization

### **Roles & Permissions**

**Owner**:
- ✅ Full control (edit, delete, archive, share list)
- ✅ Manage collaborators (invite, remove, change permissions)
- ✅ Manage items (add, edit, delete, mark purchased)

**Editor**:
- ✅ Manage items (add, edit, delete, mark purchased)
- ✅ Edit list name/description
- ❌ Cannot delete or archive list
- ❌ Cannot manage collaborators

**Viewer**:
- ✅ View list and items
- ✅ Mark items as purchased
- ❌ Cannot add, edit, or delete items
- ❌ Cannot edit list details
- ❌ Cannot manage collaborators

**See**: [Permission Matrix](./old_documents/personas/permission-matrix.md) for complete details

---

## 🧪 Testing the API

### **1. Using Swagger UI**

1. Navigate to [http://localhost:5233/index.html](http://localhost:5233/index.html)
2. Click "Authorize" button
3. Enter JWT token: `Bearer <your_token>`
4. Try endpoints interactively

### **2. Using cURL**

**Register**:
```bash
curl -X POST http://localhost:5233/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "displayName": "Test User",
    "password": "Password123!"
  }'
```

**Login**:
```bash
curl -X POST http://localhost:5233/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sarah@example.com",
    "password": "Password123!"
  }'
```

**Get User (with token)**:
```bash
curl -X GET http://localhost:5233/api/users/me \
  -H "Authorization: Bearer <your_token>"
```

### **3. Using Postman**

1. Import collection (future: provide Postman collection JSON)
2. Set environment variable `base_url` = `http://localhost:5233/api`
3. Set environment variable `token` = `<your_jwt_token>`
4. Run requests

### **4. Using REST Client (VS Code Extension)**

Create a `.http` file:

```http
### Register User
POST http://localhost:5233/api/auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "displayName": "Test User",
  "password": "Password123!"
}

### Login
POST http://localhost:5233/api/auth/login
Content-Type: application/json

{
  "email": "sarah@example.com",
  "password": "Password123!"
}

### Get Current User
GET http://localhost:5233/api/users/me
Authorization: Bearer {{token}}
```

---

## 📝 Contract Schemas

Each feature has JSON Schema files in its `contracts/` directory:

### **Feature 001: User Authentication**
- [login-request.json](./specs/001-user-authentication/contracts/login-request.json)
- [login-response.json](./specs/001-user-authentication/contracts/login-response.json)
- [user.json](./specs/001-user-authentication/contracts/user.json)
- [user-basic.json](./specs/001-user-authentication/contracts/user-basic.json)

### **Feature 002: User Profile Management**
- [update-profile-request.json](./specs/002-user-profile-management/contracts/update-profile-request.json)
- [user-stats-response.json](./specs/002-user-profile-management/contracts/user-stats-response.json)
- [public-user-profile.json](./specs/002-user-profile-management/contracts/public-user-profile.json)

### **Feature 003+**: To be generated when specified

---

## 🚀 API Development Workflow

### **For New Endpoints**

1. **Specify Feature**: Use `/speckit.specify "feature description"`
2. **Generate Plan**: Use `/speckit.plan XXX-feature-name`
3. **Review Contracts**: Check `specs/XXX-feature/contracts/` for JSON schemas
4. **Implement Backend**: Follow `specs/XXX-feature/quickstart.md`
5. **Test Endpoints**: Use Swagger UI or cURL
6. **Integrate Frontend**: Services in `ae-infinity-ui/src/services/`
7. **Verify**: Use `/speckit.analyze XXX-feature-name`

### **For Contract Changes**

1. Update JSON schema in `specs/XXX-feature/contracts/`
2. Update corresponding DTO in backend (`ae-infinity-api`)
3. Update types in frontend (`ae-infinity-ui/src/types/`)
4. Update validation rules (FluentValidation backend, React Hook Form frontend)
5. Update tests

---

## 📚 Additional Resources

- **Swagger**: [http://localhost:5233/index.html](http://localhost:5233/index.html)
- **Constitution**: [Development Principles](./.specify/memory/constitution.md)
- **Architecture**: [System Design](./ARCHITECTURE.md)
- **Getting Started**: [Quick Setup](./GETTING_STARTED.md)
- **Contributing**: [Development Workflow](./CONTRIBUTING.md)
- **Feature Catalog**: [All Features](./specs/README.md)

---

## 📞 Support

- **Documentation Issues**: Create issue in this repository
- **API Bugs**: Report in `ae-infinity-api` repository
- **Feature Requests**: Use `/speckit.specify` to create specification first

---

**Last Updated**: November 5, 2025  
**Next Update**: After Feature 003 specification (Shopping Lists CRUD)

