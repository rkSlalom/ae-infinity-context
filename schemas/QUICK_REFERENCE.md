# Schemas Quick Reference

Quick guide to the most commonly used schemas and their relationships.

## 🔑 Core Entity Schemas

### User
```
user.json              → Full user profile (email, displayName, etc.)
user-basic.json        → Minimal info (id, displayName, avatarUrl)
user-stats.json        → Activity statistics
```

### List
```
list.json              → List summary with stats
list-detail.json       → Complete list (extends list.json)
                         ├── items: ListItemDto[]
                         ├── collaborators: CollaboratorDto[]
                         └── userRole: string
list-basic.json        → Minimal info (id, name, isArchived)
```

### List Item
```
list-item.json         → Full item with category and creator
                         ├── category: CategoryDto
                         ├── creator: UserBasicDto
                         └── purchasedByUser: UserBasicDto
list-item-basic.json   → Minimal info (id, name, quantity, position)
```

## 🔗 Schema Relationships

```
LoginResponse
├── token: string
├── expiresAt: datetime
└── user: UserDto

ListDetailDto
├── id, name, description
├── owner: UserBasicDto
├── items: ListItemDto[]
│   └── category: CategoryDto
│       └── creator: UserBasicDto
└── collaborators: CollaboratorDto[]
    └── role: RoleDto

CollaboratorDto
├── userId, userDisplayName, userAvatarUrl
├── roleId, roleName
├── role: RoleDto (full permissions)
├── isPending, invitedAt, acceptedAt
└── invitedBy, invitedByDisplayName

SearchResultDto
├── lists: ListSearchResultDto[]
├── items: ItemSearchResultDto[]
└── pagination: PaginationDto
```

## 📋 Request/Response Schemas

### Authentication
| Endpoint | Request | Response |
|----------|---------|----------|
| POST /auth/login | `login-request.json` | `login-response.json` |
| PUT /users/me | `update-user-profile-request.json` | `user.json` |

### Lists
| Endpoint | Response Schema |
|----------|----------------|
| GET /lists | `list.json[]` |
| GET /lists/{id} | `list-detail.json` |
| GET /lists/{id}/stats | `list-stats.json` |
| GET /lists/{id}/activity | `list-activity.json[]` |

### Items
| Endpoint | Response Schema |
|----------|----------------|
| GET /lists/{id}/items | `list-item.json[]` |
| GET /lists/{id}/items/{itemId} | `list-item.json` |

### Collaboration
| Endpoint | Response Schema |
|----------|----------------|
| GET /lists/{id}/collaborators | `collaborator.json[]` |
| GET /invitations | `invitation.json[]` |

### Search
| Endpoint | Response Schema |
|----------|----------------|
| GET /search | `search-result.json` |
| GET /search/lists | `list-search-result.json[]` + `pagination.json` |
| GET /search/items | `item-search-result.json[]` + `pagination.json` |

### Statistics
| Endpoint | Response Schema |
|----------|----------------|
| GET /users/me/stats | `user-stats.json` |
| GET /users/me/history | `purchase-history.json[]` |

## 🎨 Common Property Patterns

### Identifiers
```json
{
  "id": { "type": "string", "format": "uuid" },
  "userId": { "type": "string", "format": "uuid" },
  "listId": { "type": "string", "format": "uuid" }
}
```

### Timestamps
```json
{
  "createdAt": { "type": "string", "format": "date-time" },
  "updatedAt": { "type": ["string", "null"], "format": "date-time" },
  "archivedAt": { "type": ["string", "null"], "format": "date-time" }
}
```

### User References
```json
{
  "createdBy": { "type": "string", "format": "uuid" },
  "creator": { 
    "type": ["object", "null"],
    "$ref": "user-basic.json"
  }
}
```

### Nullable Fields
```json
{
  "description": { "type": ["string", "null"] },
  "avatarUrl": { "type": ["string", "null"], "format": "uri" }
}
```

## 🛠️ Usage Examples

### TypeScript Type Generation

```bash
# Install json-schema-to-typescript
npm install -D json-schema-to-typescript

# Generate types
npx json-schema-to-typescript schemas/*.json \
  --output src/types/generated/
```

### Runtime Validation (Ajv)

```typescript
import Ajv from 'ajv';
import addFormats from 'ajv-formats';
import listDetailSchema from '@/schemas/list-detail.json';

const ajv = new Ajv();
addFormats(ajv);

const validate = ajv.compile(listDetailSchema);

if (!validate(apiResponse)) {
  console.error(validate.errors);
  throw new Error('Invalid response format');
}
```

### Zod Schema Generation

```typescript
import { z } from 'zod';

// Generated from user.json
export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  displayName: z.string().min(2).max(100),
  avatarUrl: z.string().url().nullable(),
  isEmailVerified: z.boolean(),
  lastLoginAt: z.string().datetime().nullable(),
  createdAt: z.string().datetime(),
});

export type User = z.infer<typeof UserSchema>;
```

### Mock Data Generation

```typescript
import { faker } from '@faker-js/faker';

// Mock data matching user.json schema
export const mockUser = (): User => ({
  id: faker.string.uuid(),
  email: faker.internet.email(),
  displayName: faker.person.fullName(),
  avatarUrl: faker.image.avatar(),
  isEmailVerified: faker.datatype.boolean(),
  lastLoginAt: faker.date.recent().toISOString(),
  createdAt: faker.date.past().toISOString(),
});
```

## 🔍 Finding the Right Schema

**Need to...**

| Task | Schema |
|------|--------|
| Validate login response | `login-response.json` |
| Type a list with items | `list-detail.json` |
| Type a single item | `list-item.json` |
| Show user avatar | `user-basic.json` |
| Display search results | `search-result.json` |
| Show collaborators | `collaborator.json` |
| Check permissions | `role.json` |
| Handle pagination | `pagination.json` |
| Track purchases | `purchase-history.json` |

## 📚 Related Documentation

- **[schemas/README.md](./README.md)** - Full schema documentation
- **[API_LIST.md](../../ae-infinity-api/docs/API_LIST.md)** - All API endpoints
- **[DB_SCHEMA.md](../../ae-infinity-api/docs/DB_SCHEMA.md)** - Database structure
- **[API Integration Guide](../../ae-infinity-ui/docs/API_INTEGRATION_GUIDE.md)** - Frontend usage

## 💡 Tips

1. **Always use TypeScript types** generated from schemas for type safety
2. **Validate API responses** in development mode to catch contract changes
3. **Reference schemas** in your API documentation
4. **Update schemas first** when changing DTOs
5. **Generate mocks** from schemas for consistent test data

## ⚠️ Important Notes

- All IDs are UUIDs (format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)
- All timestamps are ISO 8601 UTC strings
- Nullable fields use `["type", "null"]` syntax
- Optional fields are omitted from `required` array
- Cross-references use relative paths (e.g., `"$ref": "user.json"`)

