# API Specifications

This directory contains REST API specifications split by domain for easier consumption and maintenance.

## 📁 API Documentation Files

**Note**: This is the planned structure. Currently, see [../API_SPEC.md](../API_SPEC.md) for complete API documentation. Files will be split from the monolithic spec over time.

- **[authentication.md](./authentication.md)** - Authentication and authorization
  - User registration
  - Login and JWT tokens
  - Token refresh
  - Permission checking

- **[lists.md](./lists.md)** - Shopping list operations
  - Create, read, update, delete lists
  - List sharing and collaboration
  - Permission management
  - Archive/restore operations

- **[items.md](./items.md)** - Shopping item management
  - Add, edit, delete items
  - Mark as purchased
  - Reorder items
  - Item history

- **[categories.md](./categories.md)** - Category management
  - Default categories
  - Custom categories
  - Category CRUD operations

- **[search.md](./search.md)** - Search functionality
  - Search across lists
  - Search items
  - Filter and sort results

- **[realtime-events.md](./realtime-events.md)** - SignalR real-time events
  - Hub connection setup
  - Client → Server methods
  - Server → Client events
  - Presence indicators

- **[error-handling.md](./error-handling.md)** - Error responses
  - Error response format
  - Common error codes
  - HTTP status codes
  - Error handling best practices

## 🔗 Base Configuration

**Base URLs**:
- Development: `http://localhost:5000/api/v1`
- Production: `https://api.ae-infinity.com/api/v1`

**Authentication**: JWT Bearer tokens required for all endpoints except register/login

**Reference**: [../API_SPEC.md](../API_SPEC.md) lines 4-13

## 📖 Document Structure

Each API document follows this structure:

1. **Overview** - Purpose and scope
2. **Endpoints** - Complete endpoint listing
3. **Request/Response Examples** - Detailed examples
4. **Error Handling** - Specific error cases
5. **Related Documentation** - Cross-references

## 🔗 Cross-References

### By User Journey

**Creating First List** → [lists.md](./lists.md), [items.md](./items.md)  
**Shopping Together** → [items.md](./items.md), [realtime-events.md](./realtime-events.md)  
**Sharing List** → [lists.md](./lists.md), [authentication.md](./authentication.md)

### By Architecture Component

**Frontend State** → [../architecture/state-management.md](../architecture/state-management.md)  
**Backend Services** → [../architecture/backend-architecture.md](../architecture/backend-architecture.md)  
**Database Models** → [../architecture/data-models.md](../architecture/data-models.md)

## 🎯 Using These Specs

**For Frontend Developers**:
1. Read endpoint specification
2. Generate TypeScript types
3. Create API client functions
4. Handle errors per error-handling.md

**For Backend Developers**:
1. Implement endpoints per specification
2. Match request/response formats exactly
3. Return correct HTTP status codes
4. Follow error handling standards

**For API Consumers**:
1. Review authentication requirements
2. Check rate limits
3. Handle pagination
4. Implement retry logic

## 📊 API Versioning

Current version: `v1`

Versioning strategy:
- URL-based versioning (`/api/v1/...`)
- Backward compatibility for 2 versions
- Deprecation notices 6 months in advance

## 🔒 Security

All API endpoints follow these security principles:
- JWT authentication required (except auth endpoints)
- Role-based access control (RBAC)
- Rate limiting per user
- Input validation and sanitization
- HTTPS enforcement in production

**Reference**: [../architecture/security.md](../architecture/security.md)

## 📝 Standards

**Request Format**:
- JSON body for POST/PUT/PATCH
- Query parameters for GET
- Path parameters for resource IDs

**Response Format**:
- JSON responses
- Consistent error format
- Pagination metadata included
- Rate limit headers

**HTTP Methods**:
- GET: Read operations
- POST: Create operations
- PUT: Full update operations
- PATCH: Partial update operations
- DELETE: Delete operations

## 🔗 Related Documentation

- **Journeys**: [../journeys/](../journeys/) - See API usage in context
- **Architecture**: [../architecture/](../architecture/) - Implementation details
- **Data Models**: [../architecture/data-models.md](../architecture/data-models.md) - Database schemas

---

**Current Status**: Specifications documented in [../API_SPEC.md](../API_SPEC.md). Will be split into individual files in future updates.

