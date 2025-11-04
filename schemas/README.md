# API Schemas

This directory contains JSON Schema definitions for all API request and response objects in the AE Infinity application. These schemas provide validation rules, type information, and documentation for the API contracts.

## Schema Organization

Schemas are organized by domain/resource:

- **Authentication** - Login, logout, and session management
- **Users** - User profiles and account management
- **Lists** - Shopping list CRUD and management
- **List Items** - Shopping list item operations
- **Collaboration** - List sharing, invitations, and collaborators
- **Categories** - Item categorization
- **Roles** - Permission management
- **Search** - Search functionality across lists and items
- **Statistics** - Usage statistics and analytics

## Schema Files

### Authentication
- `login-request.json` - Login credentials
- `login-response.json` - JWT token and user info

### Users
- `user.json` - Full user profile
- `user-basic.json` - Minimal user info (for nested objects)
- `user-stats.json` - User statistics
- `update-user-profile-request.json` - Profile update payload

### Lists
- `list.json` - List summary
- `list-detail.json` - List with items and collaborators
- `list-basic.json` - Minimal list info
- `list-stats.json` - List statistics
- `list-activity.json` - Activity/history entries

### List Items
- `list-item.json` - Full item details
- `list-item-basic.json` - Minimal item info

### Collaboration
- `collaborator.json` - Collaborator information
- `invitation.json` - Invitation details

### Categories & Roles
- `category.json` - Category definition
- `role.json` - Role with permissions

### Search
- `search-result.json` - Combined search results
- `list-search-result.json` - List search match
- `item-search-result.json` - Item search match
- `pagination.json` - Pagination metadata

### History
- `purchase-history.json` - Purchase history entry

## Schema Usage

### In Frontend Development
Use these schemas with libraries like [Ajv](https://ajv.js.org/) or [Zod](https://zod.dev/) for:
- Runtime validation of API responses
- Type generation for TypeScript
- Form validation
- Mock data generation for testing

### In Backend Development
- Validate against these schemas in tests
- Generate API documentation
- Ensure consistency between C# DTOs and JSON contracts

### In Documentation
- Reference these schemas in API documentation
- Use for Swagger/OpenAPI spec generation
- Provide examples in developer guides

## Schema Standards

All schemas follow JSON Schema Draft 7 specification and include:
- `$schema` - JSON Schema version
- `$id` - Unique identifier for the schema
- `title` - Human-readable name
- `description` - Purpose and usage
- `type` - Root type (usually "object")
- `properties` - Field definitions with types and constraints
- `required` - List of required fields
- `additionalProperties` - Whether extra fields are allowed

### Common Patterns

**GUIDs**: Represented as strings with UUID format
```json
{
  "type": "string",
  "format": "uuid"
}
```

**Timestamps**: ISO 8601 date-time strings
```json
{
  "type": "string",
  "format": "date-time"
}
```

**Optional Fields**: Use `"required"` array; omit optional fields from it

**Nested Objects**: Reference other schemas or inline definitions

## Validation Examples

### JavaScript/TypeScript (Ajv)
```typescript
import Ajv from 'ajv';
import userSchema from './schemas/user.json';

const ajv = new Ajv();
const validate = ajv.compile(userSchema);

const isValid = validate(userData);
if (!isValid) {
  console.error(validate.errors);
}
```

### TypeScript Type Generation
```bash
# Using json-schema-to-typescript
npx json-schema-to-typescript schemas/*.json --output src/types/
```

## Maintenance

When updating schemas:
1. Ensure they match the C# DTOs in `ae-infinity-api`
2. Update version numbers if making breaking changes
3. Add examples for complex schemas
4. Test validation with sample data
5. Update this README if adding new schemas

## Related Documentation

- [API Endpoint List](../../ae-infinity-api/docs/API_LIST.md)
- [Database Schema](../../ae-infinity-api/docs/DB_SCHEMA.md)
- [API Integration Guide](../../ae-infinity-ui/docs/API_INTEGRATION_GUIDE.md)

