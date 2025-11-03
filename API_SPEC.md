# API Specification

## Base URL
```
Development: http://localhost:5000/api/v1
Production: https://api.ae-infinity.com/api/v1
```

## Authentication
All endpoints (except `/auth/register` and `/auth/login`) require a JWT token in the Authorization header:
```
Authorization: Bearer <jwt_token>
```

---

## Authentication Endpoints

### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "password": "SecurePass123!"
}
```

**Success Response (201 Created):**
```json
{
  "user": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "email": "user@example.com",
    "displayName": "John Doe",
    "avatarUrl": null,
    "createdAt": "2025-11-03T10:30:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses:**
- `400 Bad Request`: Invalid input data
- `409 Conflict`: Email already exists

---

### POST /auth/login
Authenticate user and receive JWT token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Success Response (200 OK):**
```json
{
  "user": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "email": "user@example.com",
    "displayName": "John Doe",
    "avatarUrl": "https://storage.com/avatars/user.jpg"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses:**
- `401 Unauthorized`: Invalid credentials
- `400 Bad Request`: Missing fields

---

### POST /auth/refresh
Refresh JWT token before expiration.

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### GET /auth/me
Get current authenticated user information.

**Success Response (200 OK):**
```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "email": "user@example.com",
  "displayName": "John Doe",
  "avatarUrl": "https://storage.com/avatars/user.jpg",
  "createdAt": "2025-01-01T10:00:00Z"
}
```

---

## Shopping Lists Endpoints

### GET /lists
Retrieve all shopping lists for the authenticated user.

**Query Parameters:**
- `includeArchived` (boolean, default: false): Include archived lists
- `page` (integer, default: 1): Page number
- `pageSize` (integer, default: 20, max: 100): Items per page
- `sortBy` (string, default: "updatedAt"): Field to sort by
- `sortOrder` (string, default: "desc"): "asc" or "desc"

**Success Response (200 OK):**
```json
{
  "lists": [
    {
      "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "name": "Weekly Groceries",
      "description": "Our regular weekly shopping list",
      "ownerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "ownerName": "John Doe",
      "isArchived": false,
      "itemCount": 12,
      "purchasedCount": 5,
      "collaboratorCount": 3,
      "myPermission": "Owner",
      "createdAt": "2025-10-01T10:00:00Z",
      "updatedAt": "2025-11-03T14:30:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "pageSize": 20,
    "totalPages": 1,
    "totalCount": 1
  }
}
```

---

### POST /lists
Create a new shopping list.

**Request Body:**
```json
{
  "name": "Weekend BBQ",
  "description": "Shopping for the weekend barbecue party"
}
```

**Success Response (201 Created):**
```json
{
  "id": "8d0e7890-8536-51ef-c4gd-3d184g2a01bf8",
  "name": "Weekend BBQ",
  "description": "Shopping for the weekend barbecue party",
  "ownerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "ownerName": "John Doe",
  "isArchived": false,
  "itemCount": 0,
  "purchasedCount": 0,
  "collaboratorCount": 1,
  "myPermission": "Owner",
  "createdAt": "2025-11-03T15:00:00Z",
  "updatedAt": "2025-11-03T15:00:00Z"
}
```

**Error Responses:**
- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Not authenticated

---

### GET /lists/{listId}
Get detailed information about a specific list.

**Success Response (200 OK):**
```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "name": "Weekly Groceries",
  "description": "Our regular weekly shopping list",
  "ownerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "ownerName": "John Doe",
  "isArchived": false,
  "myPermission": "Owner",
  "collaborators": [
    {
      "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "displayName": "John Doe",
      "avatarUrl": null,
      "permission": "Owner",
      "invitedAt": "2025-10-01T10:00:00Z",
      "acceptedAt": "2025-10-01T10:00:00Z"
    },
    {
      "userId": "9fb95g75-6828-5673-c4gd-3d184g2a01bf8",
      "displayName": "Jane Smith",
      "avatarUrl": null,
      "permission": "Editor",
      "invitedAt": "2025-10-02T14:00:00Z",
      "acceptedAt": "2025-10-02T15:30:00Z"
    }
  ],
  "createdAt": "2025-10-01T10:00:00Z",
  "updatedAt": "2025-11-03T14:30:00Z"
}
```

**Error Responses:**
- `404 Not Found`: List doesn't exist
- `403 Forbidden`: User doesn't have access

---

### PUT /lists/{listId}
Update list details.

**Request Body:**
```json
{
  "name": "Weekly Groceries - Updated",
  "description": "Our updated weekly shopping list",
  "isArchived": false
}
```

**Success Response (200 OK):**
```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "name": "Weekly Groceries - Updated",
  "description": "Our updated weekly shopping list",
  "ownerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "ownerName": "John Doe",
  "isArchived": false,
  "itemCount": 12,
  "purchasedCount": 5,
  "collaboratorCount": 3,
  "myPermission": "Owner",
  "createdAt": "2025-10-01T10:00:00Z",
  "updatedAt": "2025-11-03T15:30:00Z"
}
```

**Error Responses:**
- `404 Not Found`: List doesn't exist
- `403 Forbidden`: Insufficient permissions
- `400 Bad Request`: Invalid input data

---

### DELETE /lists/{listId}
Permanently delete a shopping list.

**Success Response (204 No Content)**

**Error Responses:**
- `404 Not Found`: List doesn't exist
- `403 Forbidden`: Only owners can delete lists

---

### POST /lists/{listId}/share
Share a list with another user.

**Request Body:**
```json
{
  "email": "friend@example.com",
  "permission": "Editor"
}
```

**Success Response (200 OK):**
```json
{
  "inviteId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "email": "friend@example.com",
  "permission": "Editor",
  "invitedAt": "2025-11-03T15:30:00Z",
  "status": "Pending"
}
```

**Error Responses:**
- `404 Not Found`: List or user doesn't exist
- `403 Forbidden`: Insufficient permissions
- `400 Bad Request`: Invalid permission level
- `409 Conflict`: User already has access

---

### DELETE /lists/{listId}/collaborators/{userId}
Remove a collaborator from a list.

**Success Response (204 No Content)**

**Error Responses:**
- `404 Not Found`: List or collaborator doesn't exist
- `403 Forbidden`: Insufficient permissions
- `400 Bad Request`: Cannot remove owner

---

### PATCH /lists/{listId}/collaborators/{userId}/permission
Update a collaborator's permission level.

**Request Body:**
```json
{
  "permission": "Viewer"
}
```

**Success Response (200 OK):**
```json
{
  "userId": "9fb95g75-6828-5673-c4gd-3d184g2a01bf8",
  "displayName": "Jane Smith",
  "permission": "Viewer",
  "updatedAt": "2025-11-03T16:00:00Z"
}
```

---

## Shopping Items Endpoints

### GET /lists/{listId}/items
Get all items in a shopping list.

**Query Parameters:**
- `includeCompleted` (boolean, default: true): Include purchased items
- `categoryId` (string, optional): Filter by category
- `sortBy` (string, default: "position"): Sort field
- `sortOrder` (string, default: "asc"): Sort direction

**Success Response (200 OK):**
```json
{
  "items": [
    {
      "id": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
      "listId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "name": "Milk",
      "quantity": 2,
      "unit": "gallons",
      "category": {
        "id": "c3d4e5f6-g7h8-9012-cdef-gh3456789012",
        "name": "Dairy",
        "icon": "🥛",
        "color": "#E3F2FD"
      },
      "notes": "Whole milk preferred",
      "imageUrl": null,
      "isPurchased": false,
      "position": 1,
      "createdBy": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "displayName": "John Doe"
      },
      "createdAt": "2025-11-01T10:00:00Z",
      "updatedAt": "2025-11-01T10:00:00Z",
      "purchasedAt": null,
      "purchasedBy": null
    }
  ]
}
```

---

### POST /lists/{listId}/items
Add a new item to the shopping list.

**Request Body:**
```json
{
  "name": "Bananas",
  "quantity": 6,
  "unit": "pieces",
  "categoryId": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
  "notes": "Not too ripe",
  "imageUrl": null
}
```

**Success Response (201 Created):**
```json
{
  "id": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
  "listId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "name": "Bananas",
  "quantity": 6,
  "unit": "pieces",
  "category": {
    "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
    "name": "Produce",
    "icon": "🍎",
    "color": "#C8E6C9"
  },
  "notes": "Not too ripe",
  "imageUrl": null,
  "isPurchased": false,
  "position": 13,
  "createdBy": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "displayName": "John Doe"
  },
  "createdAt": "2025-11-03T16:00:00Z",
  "updatedAt": "2025-11-03T16:00:00Z",
  "purchasedAt": null,
  "purchasedBy": null
}
```

**Error Responses:**
- `404 Not Found`: List doesn't exist
- `403 Forbidden`: Insufficient permissions (Viewer role)
- `400 Bad Request`: Invalid input data

---

### PUT /lists/{listId}/items/{itemId}
Update an existing item.

**Request Body:**
```json
{
  "name": "Bananas - Organic",
  "quantity": 8,
  "unit": "pieces",
  "categoryId": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
  "notes": "Organic only",
  "imageUrl": null
}
```

**Success Response (200 OK):**
```json
{
  "id": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
  "listId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "name": "Bananas - Organic",
  "quantity": 8,
  "unit": "pieces",
  "category": {
    "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
    "name": "Produce",
    "icon": "🍎",
    "color": "#C8E6C9"
  },
  "notes": "Organic only",
  "imageUrl": null,
  "isPurchased": false,
  "position": 13,
  "createdBy": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "displayName": "John Doe"
  },
  "createdAt": "2025-11-03T16:00:00Z",
  "updatedAt": "2025-11-03T16:15:00Z",
  "purchasedAt": null,
  "purchasedBy": null
}
```

---

### PATCH /lists/{listId}/items/{itemId}/purchased
Toggle item purchased status.

**Request Body:**
```json
{
  "isPurchased": true
}
```

**Success Response (200 OK):**
```json
{
  "id": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
  "isPurchased": true,
  "purchasedAt": "2025-11-03T16:30:00Z",
  "purchasedBy": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "displayName": "John Doe"
  }
}
```

---

### DELETE /lists/{listId}/items/{itemId}
Delete an item from the list.

**Success Response (204 No Content)**

**Error Responses:**
- `404 Not Found`: Item doesn't exist
- `403 Forbidden`: Insufficient permissions

---

### PATCH /lists/{listId}/items/reorder
Update positions of multiple items (for drag-and-drop).

**Request Body:**
```json
{
  "itemPositions": [
    {
      "itemId": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
      "position": 1
    },
    {
      "itemId": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
      "position": 2
    }
  ]
}
```

**Success Response (200 OK):**
```json
{
  "message": "Items reordered successfully",
  "updatedCount": 2
}
```

---

## Categories Endpoints

### GET /categories
Get all available categories.

**Query Parameters:**
- `includeCustom` (boolean, default: true): Include user-created categories

**Success Response (200 OK):**
```json
{
  "categories": [
    {
      "id": "c3d4e5f6-g7h8-9012-cdef-gh3456789012",
      "name": "Dairy",
      "icon": "🥛",
      "color": "#E3F2FD",
      "isDefault": true,
      "createdBy": null
    },
    {
      "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
      "name": "Produce",
      "icon": "🍎",
      "color": "#C8E6C9",
      "isDefault": true,
      "createdBy": null
    }
  ]
}
```

---

### POST /categories
Create a custom category.

**Request Body:**
```json
{
  "name": "Pet Supplies",
  "icon": "🐾",
  "color": "#FFE0B2"
}
```

**Success Response (201 Created):**
```json
{
  "id": "f7g8h9i0-j1k2-3456-ghij-kl7890123456",
  "name": "Pet Supplies",
  "icon": "🐾",
  "color": "#FFE0B2",
  "isDefault": false,
  "createdBy": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "displayName": "John Doe"
  }
}
```

---

## Search Endpoint

### GET /search
Search across lists and items.

**Query Parameters:**
- `q` (string, required): Search query
- `scope` (string, default: "all"): "lists", "items", or "all"
- `page` (integer, default: 1)
- `pageSize` (integer, default: 20)

**Success Response (200 OK):**
```json
{
  "lists": [
    {
      "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "name": "Weekly Groceries",
      "description": "Our regular weekly shopping list",
      "matchType": "name"
    }
  ],
  "items": [
    {
      "id": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
      "listId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "listName": "Weekly Groceries",
      "name": "Milk",
      "matchType": "name"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "pageSize": 20,
    "totalPages": 1,
    "totalCount": 2
  }
}
```

---

## SignalR Hub Events

### Client → Server Methods

**JoinList(string listId)**
Subscribe to real-time updates for a specific list.

**LeaveList(string listId)**
Unsubscribe from list updates.

**UpdatePresence(string listId, bool isActive)**
Update user's active/viewing status on a list.

---

### Server → Client Events

**ItemAdded(ItemResponse item)**
Broadcast when a new item is added to the list.

**ItemUpdated(ItemResponse item)**
Broadcast when an item is modified.

**ItemDeleted(string itemId)**
Broadcast when an item is deleted.

**ItemPurchased(string itemId, string userId, DateTime purchasedAt)**
Broadcast when an item is marked as purchased.

**ListUpdated(ListResponse list)**
Broadcast when list details are changed.

**CollaboratorJoined(string userId, string displayName, string listId)**
Broadcast when a new collaborator is added.

**CollaboratorLeft(string userId, string listId)**
Broadcast when a collaborator is removed.

**PresenceChanged(string userId, bool isActive, string listId)**
Broadcast when a user's presence status changes.

---

## Error Response Format

All error responses follow this structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [
      {
        "field": "fieldName",
        "message": "Field-specific error message"
      }
    ],
    "timestamp": "2025-11-03T16:30:00Z",
    "traceId": "abc123-def456-ghi789"
  }
}
```

### Common Error Codes
- `VALIDATION_ERROR`: Invalid input data
- `NOT_FOUND`: Resource doesn't exist
- `UNAUTHORIZED`: Authentication required
- `FORBIDDEN`: Insufficient permissions
- `CONFLICT`: Resource conflict (e.g., duplicate)
- `RATE_LIMIT_EXCEEDED`: Too many requests
- `INTERNAL_ERROR`: Server error

---

## Rate Limiting

- **Authenticated Users**: 100 requests per minute
- **Anonymous Users**: 20 requests per minute

Rate limit headers included in all responses:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1730649000
```

---

## Pagination

All list endpoints support pagination with the following parameters:
- `page`: Page number (1-based)
- `pageSize`: Items per page (default: 20, max: 100)

Response includes pagination metadata:
```json
{
  "pagination": {
    "currentPage": 1,
    "pageSize": 20,
    "totalPages": 5,
    "totalCount": 95,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

