# Data Model Analysis: Actual vs Documented

**Date**: 2025-11-05  
**Feature**: 001-user-authentication  
**Analyst**: Review of ae-infinity-api codebase

---

## 🔍 **Summary**

Analyzed the actual API implementation in `../ae-infinity-api` and found **significant discrepancies** between the documented data-model.md and actual implementation.

---

## ❌ **Major Discrepancies**

### 1. **PasswordResetToken Entity - DOES NOT EXIST**

**Documented** (`data-model.md`):
- Separate `PasswordResetToken` entity with its own table
- Fields: Id, UserId, Token, ExpiresAt, IsUsed, UsedAt, CreatedAt
- Foreign key relationship to User

**Actual** (`User.cs`):
- ✅ Password reset tokens stored INLINE in User entity
- Fields: `PasswordResetToken` (string), `PasswordResetExpiresAt` (DateTime?)
- No separate table, no IsUsed flag
- Simpler design: one token per user at a time

**Impact**: HIGH - Architectural difference

---

### 2. **User Entity - Missing Fields**

**Documented Fields**:
- Id, Email, EmailNormalized, DisplayName, PasswordHash, AvatarUrl, IsEmailVerified, LastLoginAt, CreatedAt, UpdatedAt

**Missing in Documentation**:
- ✅ `EmailVerificationToken` (string?) - Token for email verification
- ✅ `PasswordResetToken` (string?) - Token for password reset (inline)
- ✅ `PasswordResetExpiresAt` (DateTime?) - Expiration for reset token
- ✅ `CreatedBy`, `UpdatedBy`, `DeletedBy` (Guid?) - Audit fields from BaseAuditableEntity
- ✅ `DeletedAt` (DateTime?) - Soft delete timestamp
- ✅ `IsDeleted` (bool) - Soft delete flag

**Impact**: MEDIUM - Missing several important fields

---

### 3. **Base Entity Inheritance - Not Documented**

**Actual Implementation**:
```
BaseEntity (abstract)
├── Id: Guid
├── CreatedAt: DateTime
├── UpdatedAt: DateTime?
├── DeletedAt: DateTime?
└── IsDeleted: bool

    ↓ extends

BaseAuditableEntity (abstract)
├── CreatedBy: Guid?
├── UpdatedBy: Guid?
└── DeletedBy: Guid?

    ↓ extends

User (concrete)
├── Email: string
├── EmailNormalized: string
├── DisplayName: string
├── PasswordHash: string
├── AvatarUrl: string?
├── IsEmailVerified: bool
├── EmailVerificationToken: string?
├── PasswordResetToken: string?
├── PasswordResetExpiresAt: DateTime?
└── LastLoginAt: DateTime?
```

**Impact**: HIGH - Fundamental architecture not explained

---

### 4. **DTOs - No Validation Attributes**

**Documented** (`data-model.md`):
```csharp
public class LoginRequest
{
    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string Email { get; set; } = null!;
}
```

**Actual** (`LoginRequest.cs`):
```csharp
public class LoginRequest
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}
```

**Impact**: HIGH - Validation happens elsewhere (FluentValidation), not via attributes

---

### 5. **Field Size Discrepancies**

| Field | Documented | Actual | Difference |
|-------|-----------|--------|------------|
| AvatarUrl | MaxLength 2048 | MaxLength 500 | ❌ 4x larger |
| PasswordResetToken | 64 chars | 255 chars | ❌ 4x larger |
| EmailVerificationToken | Not documented | 255 chars | ❌ Missing |

**Impact**: LOW - Implementation is more permissive, no breaking issues

---

### 6. **Soft Delete Implementation**

**Not Documented** but **Implemented**:
- All entities use soft delete pattern
- `IsDeleted` flag, `DeletedAt` timestamp, `DeletedBy` user
- Query filter: `builder.HasQueryFilter(u => !u.IsDeleted)`
- Unique index on EmailNormalized has filter: `WHERE is_deleted = false`

**Impact**: MEDIUM - Critical pattern not explained

---

## ✅ **What Was Correct**

1. ✅ UserDto structure matches (minus validation attributes)
2. ✅ UserBasicDto structure matches
3. ✅ LoginResponse structure matches
4. ✅ Email normalization for case-insensitive lookup
5. ✅ BCrypt password hashing
6. ✅ JWT token structure and claims
7. ✅ Navigation properties (OwnedLists, ListCollaborations, CreatedItems, CustomCategories)
8. ✅ EF Core configuration approach

---

## 📊 **Accuracy Score**

| Category | Score | Notes |
|----------|-------|-------|
| Entity Structure | 60% | Missing inheritance, soft delete, extra fields |
| DTOs | 80% | Structure correct, validation approach wrong |
| Relationships | 100% | Navigation properties accurate |
| Database Schema | 40% | Missing PasswordResetToken table issue, soft delete columns |
| Security | 100% | JWT, BCrypt, email normalization all correct |
| **Overall** | **70%** | Good foundation, missing implementation details |

---

## 🔧 **Recommendations**

### Immediate Actions

1. **Update data-model.md** with:
   - Correct User entity fields (add EmailVerificationToken, PasswordResetToken, PasswordResetExpiresAt)
   - Document BaseEntity and BaseAuditableEntity inheritance
   - Document soft delete pattern
   - Remove separate PasswordResetToken entity
   - Correct field sizes (AvatarUrl: 500, not 2048)

2. **Update DTOs section** to reflect:
   - Validation happens via FluentValidation, not data annotations
   - DTOs are plain POCOs
   - Plan.md Phase 1 should add FluentValidation, not attributes

3. **Add section** on soft delete:
   - How it works
   - Query filters
   - Impact on unique constraints

---

## 📝 **Corrected User Entity Definition**

**Actual Implementation**:

```csharp
public class User : BaseAuditableEntity // ← extends BaseAuditableEntity
{
    // Login credentials
    public string Email { get; set; } = string.Empty;
    public string EmailNormalized { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    
    // Profile information
    public string DisplayName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    
    // Email verification
    public bool IsEmailVerified { get; set; }
    public string? EmailVerificationToken { get; set; } // ← MISSING IN DOC
    
    // Password reset (inline, not separate table)
    public string? PasswordResetToken { get; set; } // ← INLINE, NOT SEPARATE TABLE
    public DateTime? PasswordResetExpiresAt { get; set; } // ← MISSING IN DOC
    
    // Activity tracking
    public DateTime? LastLoginAt { get; set; }
    
    // Navigation Properties
    public ICollection<List> OwnedLists { get; set; } = new List<List>();
    public ICollection<UserToList> ListCollaborations { get; set; } = new List<UserToList>();
    public ICollection<ListItem> CreatedItems { get; set; } = new List<ListItem>();
    public ICollection<Category> CustomCategories { get; set; } = new List<Category>();
}

// Inherited from BaseAuditableEntity:
// - Guid? CreatedBy
// - Guid? UpdatedBy
// - Guid? DeletedBy

// Inherited from BaseEntity:
// - Guid Id
// - DateTime CreatedAt
// - DateTime? UpdatedAt
// - DateTime? DeletedAt
// - bool IsDeleted
```

---

## 🎯 **Next Steps**

1. ✅ Create this ANALYSIS.md (done)
2. ⏳ Update data-model.md with correct information
3. ⏳ Update plan.md Phase 1 to use FluentValidation instead of data annotations
4. ⏳ Document soft delete pattern properly
5. ⏳ Add note about password reset token being inline, not separate table

---

**Conclusion**: The documentation captured the general architecture well but missed several implementation details. The actual codebase is simpler in some areas (inline password reset) and more complex in others (soft delete, audit trails). All corrections should be applied to data-model.md.

