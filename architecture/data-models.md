# Data Models & Database Schema

Complete database schema and entity definitions for AE Infinity.

## 📖 Source Reference

**Primary Documentation**: [../../ae-infinity-api/docs/DB_SCHEMA.md](../../ae-infinity-api/docs/DB_SCHEMA.md)

This document provides a summary and cross-references. For complete database specifications, see the backend repository documentation.

## 🎯 Database Architecture Principles

### 1. Soft Delete Pattern
- **All tables** implement soft delete functionality
- Records are **never physically deleted** from the database
- DELETE operations set `is_deleted = true` with timestamp and user tracking
- All queries MUST filter by `WHERE is_deleted = false`
- Deleted records can be restored by clearing soft delete flags

### 2. Comprehensive Audit Trail
All tables include complete audit columns:
- `created_by` - User who created the record
- `created_at` - Creation timestamp (UTC)
- `modified_by` - User who last modified
- `modified_at` - Last modification timestamp
- `deleted_by` - User who soft-deleted
- `deleted_at` - Soft deletion timestamp
- `is_deleted` - Soft delete flag

### 3. Primary Keys
- **Type**: GUID (UUID)
- **Format**: Auto-generated on insert
- **Column Name**: `id` (consistent across all tables)

### 4. Foreign Key Relationships
- Enforce referential integrity
- Cascade rules respect soft delete pattern
- Self-referential FKs for audit trails

## 📊 Core Entities

### 1. Users
**Table**: `users`

**Purpose**: User account information for authentication and identification

**Key Fields**:
- `id` - GUID, Primary Key
- `email` - VARCHAR(255), Unique, lowercase, normalized
- `display_name` - VARCHAR(100), User's display name
- `password_hash` - VARCHAR(255), Hashed password (bcrypt/argon2)
- `avatar_url` - VARCHAR(500), Optional profile picture
- `is_email_verified` - Boolean, Email verification status
- `last_login_at` - DateTime, Last successful login

**Business Rules**:
- Email must be unique and lowercase
- Display name must be 2-100 characters
- Password must be hashed (never store plaintext)
- System user (ID: all zeros) for seed data operations

**Reference**: Backend DB_SCHEMA.md lines 43-92

---

### 2. Roles
**Table**: `roles`

**Purpose**: Define permission levels for list collaboration

**Key Fields**:
- `id` - GUID, Primary Key
- `name` - VARCHAR(50), Unique (Owner, Editor, Editor-Limited, Viewer)
- `description` - VARCHAR(500), Role description
- **Permission Flags**:
  - `can_create_items` - Can add items to list
  - `can_edit_items` - Can modify items
  - `can_delete_items` - Can remove items
  - `can_edit_own_items_only` - Restrict edits to items user created
  - `can_mark_purchased` - Can toggle purchased status
  - `can_edit_list_details` - Can modify list name/description
  - `can_manage_collaborators` - Can add/remove collaborators
  - `can_delete_list` - Can delete entire list
  - `can_archive_list` - Can archive/unarchive list
- `priority_order` - INT, Display order (lower = higher priority)

**Predefined Roles**:

| Role | ID (GUID) | Permissions |
|------|-----------|-------------|
| Owner | `11111111-1111-...` | All permissions enabled |
| Editor | `22222222-2222-...` | Can manage items, NOT list or collaborators |
| Editor-Limited | `33333333-3333-...` | Can add items, edit own only, mark purchased |
| Viewer | `44444444-4444-...` | All permissions disabled (read-only) |

**Cross-Reference**: [../personas/permission-matrix.md](../personas/permission-matrix.md)

**Reference**: Backend DB_SCHEMA.md lines 95-171

---

### 3. Lists
**Table**: `lists`

**Purpose**: Shopping lists created by users

**Key Fields**:
- `id` - GUID, Primary Key
- `name` - VARCHAR(200), Required, List name
- `description` - TEXT, Optional description
- `owner_id` - GUID, FK → users.id, List creator and owner
- `is_archived` - Boolean, Archive status
- `archived_at` - DateTime, When archived
- `archived_by` - GUID, FK → users.id, Who archived

**Business Rules**:
- Name must be 1-200 characters
- Owner cannot be removed from list
- Owner must be the creator (`owner_id = created_by`)
- Deleting list cascades to soft-delete all items and collaborators
- Owner can transfer ownership (audit trail maintained)

**Indexes**:
- `idx_lists_owner_id` - For querying user's lists
- `idx_lists_created_at` - For sorting by date
- `idx_lists_is_archived` - For filtering archived lists
- `idx_lists_name` - For search functionality

**Cross-Reference**: [../api/lists.md](../api/lists.md) (when created)

**Reference**: Backend DB_SCHEMA.md lines 175-218

---

### 4. User to List (Collaborators)
**Table**: `user_to_list`

**Purpose**: Junction table managing list collaboration and permissions

**Key Fields**:
- `id` - GUID, Primary Key
- `list_id` - GUID, FK → lists.id
- `user_id` - GUID, FK → users.id
- `role_id` - GUID, FK → roles.id, Permission level
- `invited_by` - GUID, FK → users.id, Who sent invitation
- `invited_at` - DateTime, Invitation timestamp
- `accepted_at` - DateTime, When user accepted
- `is_pending` - Boolean, Invitation status

**Business Rules**:
- User can only have one active role per list (UNIQUE constraint)
- Owner must always have active record with Owner role
- Cannot remove owner without ownership transfer
- User cannot invite themselves
- Accepting invitation sets `is_pending = false` and `accepted_at`
- `invited_at` must be <= `accepted_at`

**Indexes**:
- Unique index on (`list_id`, `user_id`) where not deleted
- Index on `is_pending` for invitation queries

**Cross-Reference**: 
- [../personas/permission-matrix.md](../personas/permission-matrix.md)
- [../journeys/sharing-list.md](../journeys/sharing-list.md)

**Reference**: Backend DB_SCHEMA.md lines 221-266

---

### 5. Categories
**Table**: `categories`

**Purpose**: Organize shopping items by category

**Key Fields**:
- `id` - GUID, Primary Key
- `name` - VARCHAR(100), Category name
- `icon` - VARCHAR(50), Emoji or icon identifier
- `color` - VARCHAR(7), Hex color code (#RRGGBB)
- `is_default` - Boolean, System-defined category
- `is_custom` - Boolean, User-created category
- `custom_owner_id` - GUID, FK → users.id (if custom)
- `sort_order` - INT, Display order

**Predefined Default Categories**:

| Name | Icon | Color | Sort Order |
|------|------|-------|------------|
| Produce | 🍎 | #C8E6C9 | 1 |
| Dairy | 🥛 | #E3F2FD | 2 |
| Meat | 🥩 | #FFCDD2 | 3 |
| Bakery | 🍞 | #FFE0B2 | 4 |
| Beverages | 🥤 | #F3E5F5 | 5 |
| Snacks | 🍪 | #FFF9C4 | 6 |
| Frozen | ❄️ | #E0F7FA | 7 |
| Household | 🧹 | #F5F5F5 | 8 |
| Personal Care | 🧴 | #FCE4EC | 9 |
| Other | 📦 | #ECEFF1 | 999 |

**Business Rules**:
- Custom categories require `custom_owner_id`
- Cannot be both `is_default` and `is_custom`
- Color must be valid hex format (#RRGGBB)

**Cross-Reference**: [../components/item-components.md](../components/item-components.md) (CategoryBadge)

**Reference**: Backend DB_SCHEMA.md lines 269-322

---

### 6. List Items
**Table**: `list_items`

**Purpose**: Individual items within shopping lists

**Key Fields**:
- `id` - GUID, Primary Key
- `list_id` - GUID, FK → lists.id, Parent list
- `name` - VARCHAR(200), Required, Item name
- `quantity` - DECIMAL(10,2), Amount to purchase (default 1.0)
- `unit` - VARCHAR(50), Unit of measurement (lbs, oz, ea, etc.)
- `category_id` - GUID, FK → categories.id, Item category
- `notes` - TEXT, Additional specifications
- `image_url` - VARCHAR(500), Optional item image
- `is_purchased` - Boolean, Purchase status
- `purchased_at` - DateTime, When marked purchased
- `purchased_by` - GUID, FK → users.id, Who purchased
- `position` - INT, Display order within list

**Business Rules**:
- Name must be 1-200 characters
- Quantity must be > 0
- Position auto-assigned as MAX(position) + 1 for new items
- Marking purchased requires setting: `is_purchased`, `purchased_at`, `purchased_by` (atomic operation)
- Unmarking purchased clears all purchase-related fields
- Soft-deleting list cascades to items

**Indexes**:
- `idx_list_items_list_id` - For querying list items
- `idx_list_items_category_id` - For category filtering
- `idx_list_items_is_purchased` - For purchase status filtering
- `idx_list_items_position` - For sorting
- `idx_list_items_name` - For search functionality
- `idx_list_items_created_by` - For filtering user's items

**Cross-Reference**: 
- [../journeys/shopping-together.md](../journeys/shopping-together.md)
- [../api/items.md](../api/items.md) (when created)

**Reference**: Backend DB_SCHEMA.md lines 325-378

---

## 🔗 Relationship Summary

```
users (1) ──→ (M) lists [owner_id]
users (1) ──→ (M) user_to_list [user_id]
users (1) ──→ (M) list_items [created_by, purchased_by]
users (1) ──→ (M) categories [custom_owner_id]

lists (1) ──→ (M) list_items [list_id]
lists (1) ──→ (M) user_to_list [list_id]

roles (1) ──→ (M) user_to_list [role_id]

categories (1) ──→ (M) list_items [category_id]
```

## 🏗️ Entity Framework Implementation

### Base Classes

**BaseEntity** (src/AeInfinity.Domain/Common/BaseEntity.cs):
```csharp
public abstract class BaseEntity
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
```

**BaseAuditableEntity** (src/AeInfinity.Domain/Common/BaseAuditableEntity.cs):
```csharp
public abstract class BaseAuditableEntity : BaseEntity
{
    public string? CreatedBy { get; set; }
    public string? UpdatedBy { get; set; }
}
```

### DbContext

**ApplicationDbContext** (src/AeInfinity.Infrastructure/Persistence/ApplicationDbContext.cs):
- Automatic timestamp handling in `SaveChangesAsync`
- Sets `CreatedAt` on insert (EntityState.Added)
- Sets `UpdatedAt` on update (EntityState.Modified)
- Loads entity configurations from assembly

### Configuration Pattern

Fluent API configurations in separate files:
- `ProductConfiguration.cs` - Example configuration
- Future: `UserConfiguration.cs`, `ListConfiguration.cs`, etc.

Each configuration:
- Defines primary keys
- Sets property constraints (required, max length, precision)
- Configures relationships
- Seeds initial data

## 📚 Implementation Status

### ✅ Implemented
- Clean Architecture structure (Domain, Application, Infrastructure)
- Base entity classes with audit support
- ApplicationDbContext with automatic timestamps
- Configuration pattern with Fluent API
- Example Product entity (placeholder)

### 🚧 To Be Implemented
Based on DB_SCHEMA.md, these entities need to be created:

- [ ] **User** entity
- [ ] **Role** entity
- [ ] **List** entity
- [ ] **UserToList** entity (junction table)
- [ ] **Category** entity
- [ ] **ListItem** entity
- [ ] Soft delete implementation in base entity
- [ ] Full audit trail (created_by, modified_by, deleted_by)
- [ ] Entity configurations for each domain entity
- [ ] Seed data for roles and categories
- [ ] Database migrations

**Note**: Current `Product` entity is a placeholder/example and will be replaced with shopping list domain entities.

## 🔐 Security Considerations

### Password Storage
- **Never return** `password_hash` in API responses
- Hash using bcrypt or Argon2 (minimum 12 rounds)
- Store only hashed passwords, never plaintext

### Soft Delete Filtering
- **Never return** soft-deleted records unless explicitly authorized
- Application queries MUST filter: `WHERE is_deleted = false`
- Consider using global query filters in EF Core

### Access Control
- Verify permissions through `user_to_list` join
- Owner check: `lists.owner_id = current_user_id`
- Collaborator check: JOIN `user_to_list` with role validation
- Prevent privilege escalation: Only owners can grant Owner role

### Audit Trail Integrity
- All audit columns must be populated on every operation
- Audit logs should be immutable (append-only)
- Retain deleted records for compliance (GDPR, data retention)

## 🎯 Query Performance

### Indexing Strategy
- **Primary keys**: Clustered index
- **Foreign keys**: Non-clustered index
- **Audit columns**: Index on `created_at`, `is_deleted`
- **Frequently queried**: Additional indexes per table

### Caching Strategy
- Cache active user sessions (Redis)
- Cache list collaborators for permission checks
- Cache default categories (rarely change)
- Cache user profiles

### Query Optimization
- Always filter by `is_deleted = false`
- Use covering indexes for common queries
- Consider partitioning large tables by date
- Implement pagination for large result sets

## 🔗 Related Documentation

- **Backend Schema**: [../../ae-infinity-api/docs/DB_SCHEMA.md](../../ae-infinity-api/docs/DB_SCHEMA.md) - Complete database specification
- **API Endpoints**: [../api/](../api/) - REST API that operates on these models
- **Personas**: [../personas/permission-matrix.md](../personas/permission-matrix.md) - Permission model
- **User Journeys**: [../journeys/](../journeys/) - How these entities are used
- **Security**: [./security.md](./security.md) - Security architecture

---

**Last Updated**: Based on backend DB_SCHEMA.md analysis  
**Implementation Status**: Schema documented, entities in progress

