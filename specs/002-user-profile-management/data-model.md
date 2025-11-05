# Data Model: User Profile Management

**Feature**: 002-user-profile-management  
**Created**: 2025-11-05  
**Status**: Design Complete  
**Related**: [spec.md](./spec.md) | [plan.md](./plan.md)

---

## Overview

This feature extends the existing User entity from feature 001 by adding profile update capabilities and statistics calculation. No database schema changes are required - all necessary fields (DisplayName, AvatarUrl) already exist. This document defines the DTOs, validation rules, and queries needed to implement profile viewing, editing, and statistics.

**Key Design Decisions**:
- Reuse existing User entity (no new tables)
- Statistics calculated via LINQ queries, cached in memory (5-min TTL)
- Profile updates broadcast via SignalR to collaborators
- Last-write-wins for concurrent profile edits (simple, atomic changes)

---

## Entity Definitions

###User Entity (Existing from Feature 001)

**Purpose**: Represents a registered user account with authentication and profile information.

**Location**: `AeInfinity.Domain/Entities/User.cs`

**Inheritance**: `User` extends `BaseAuditableEntity` extends `BaseEntity`

#### Fields

**Direct Fields** (owned by User):

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Email` | string | Required, Max 255, Lowercase | User's email for login |
| `EmailNormalized` | string | Required, Unique, Max 255, Indexed | Case-insensitive lookup |
| `DisplayName` | string | Required, Min 2, Max 100 | User's display name ⭐ Editable |
| `PasswordHash` | string | Required, Max 255 | BCrypt hashed password |
| `AvatarUrl` | string? | Optional, Max 500 | Profile picture URL ⭐ Editable |
| `IsEmailVerified` | bool | Required, Default: false | Email verification status |
| `EmailVerificationToken` | string? | Optional, Max 255 | Verification token |
| `PasswordResetToken` | string? | Optional, Max 255 | Reset token |
| `PasswordResetExpiresAt` | DateTime? | Optional, UTC | Reset expiration |
| `LastLoginAt` | DateTime? | Optional, UTC | Last successful login |

**Inherited from BaseAuditableEntity**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `CreatedAt` | DateTime | Required, UTC | Account creation timestamp |
| `CreatedBy` | string? | Optional, Max 255 | Creator user ID |
| `UpdatedAt` | DateTime | Required, UTC | Last modification timestamp |
| `UpdatedBy` | string? | Optional, Max 255 | Last modifier user ID |

**Inherited from BaseEntity**:

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `Id` | Guid | Primary Key | Unique identifier |
| `IsDeleted` | bool | Required, Default: false | Soft delete flag |
| `DeletedAt` | DateTime? | Optional, UTC | Deletion timestamp |

**Navigation Properties**:

| Property | Type | Relationship | Description |
|----------|------|--------------|-------------|
| `OwnedLists` | ICollection\<ShoppingList\> | One-to-Many | Lists created by user |
| `Collaborations` | ICollection\<Collaborator\> | One-to-Many | Collaborations on shared lists |
| `CreatedItems` | ICollection\<ListItem\> | One-to-Many | Items created by user |

**EF Core Configuration** (from feature 001):

```csharp
// AeInfinity.Infrastructure/Data/Configurations/UserConfiguration.cs
builder.Property(u => u.Email)
    .IsRequired()
    .HasMaxLength(255);

builder.Property(u => u.EmailNormalized)
    .IsRequired()
    .HasMaxLength(255);

builder.HasIndex(u => u.EmailNormalized)
    .IsUnique();

builder.Property(u => u.DisplayName)
    .IsRequired()
    .HasMaxLength(100);  // ⭐ Editable field

builder.Property(u => u.AvatarUrl)
    .HasMaxLength(500);  // ⭐ Editable field, nullable

builder.Property(u => u.PasswordHash)
    .IsRequired()
    .HasMaxLength(255);

builder.Property(u => u.IsEmailVerified)
    .IsRequired()
    .HasDefaultValue(false);

// Soft delete query filter
builder.HasQueryFilter(u => !u.IsDeleted);
```

**Notes**:
- DisplayName and AvatarUrl are the ONLY editable fields in this feature
- Email changes NOT supported (security implications, requires verification)
- Password changes handled by feature 001 (separate flow)
- No database migrations needed for this feature

---

## Data Transfer Objects (DTOs)

### UpdateProfileDto (Request)

**Purpose**: Request payload for updating user profile

**Location**: `AeInfinity.Application/Users/DTOs/UpdateProfileDto.cs`

**Fields**:

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `DisplayName` | string | Yes | Min 2, Max 100 chars | New display name |
| `AvatarUrl` | string? | No | Valid URI or null, Max 500 | New avatar URL |

**Validation Rules** (FluentValidation):

```csharp
// UpdateProfileDtoValidator.cs
RuleFor(x => x.DisplayName)
    .NotEmpty()
    .WithMessage("Display name is required")
    .MinimumLength(2)
    .WithMessage("Display name must be at least 2 characters")
    .MaximumLength(100)
    .WithMessage("Display name must not exceed 100 characters");

RuleFor(x => x.AvatarUrl)
    .Must(BeValidUriOrNull)
    .WithMessage("Avatar URL must be a valid URL or empty")
    .MaximumLength(500)
    .When(x => !string.IsNullOrWhiteSpace(x.AvatarUrl))
    .WithMessage("Avatar URL must not exceed 500 characters");

private bool BeValidUriOrNull(string? url)
{
    if (string.IsNullOrWhiteSpace(url))
        return true; // Null/empty is valid (clears avatar)
    
    return Uri.TryCreate(url, UriKind.Absolute, out var uri)
        && (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps);
}
```

**Example JSON**:

```json
{
  "displayName": "John Doe 🎉",
  "avatarUrl": "https://example.com/avatars/john.jpg"
}
```

**Example JSON** (clear avatar):

```json
{
  "displayName": "Jane Smith",
  "avatarUrl": null
}
```

---

### UserDto (Response - Existing from Feature 001)

**Purpose**: Complete user profile information returned from GET /users/me and PATCH /users/me

**Location**: `AeInfinity.Application/Users/DTOs/UserDto.cs`

**Fields**:

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `Id` | Guid | No | Unique user identifier |
| `Email` | string | No | User's email address |
| `DisplayName` | string | No | User's display name |
| `AvatarUrl` | string? | Yes | Avatar image URL |
| `IsEmailVerified` | bool | No | Email verification status |
| `LastLoginAt` | DateTime? | Yes | Last login timestamp (UTC) |
| `CreatedAt` | DateTime | No | Account creation timestamp (UTC) |

**Example JSON**:

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "email": "user@example.com",
  "displayName": "John Doe",
  "avatarUrl": "https://example.com/avatars/john.jpg",
  "isEmailVerified": true,
  "lastLoginAt": "2025-11-05T10:30:00Z",
  "createdAt": "2025-01-01T10:00:00Z"
}
```

**Mapping** (AutoMapper or manual):

```csharp
public static UserDto FromEntity(User user)
{
    return new UserDto
    {
        Id = user.Id,
        Email = user.Email,
        DisplayName = user.DisplayName,
        AvatarUrl = user.AvatarUrl,
        IsEmailVerified = user.IsEmailVerified,
        LastLoginAt = user.LastLoginAt,
        CreatedAt = user.CreatedAt
    };
}
```

---

### UserStatsDto (Response)

**Purpose**: User activity and engagement statistics

**Location**: `AeInfinity.Application/Users/DTOs/UserStatsDto.cs`

**Fields**:

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `TotalListsOwned` | int | No | Count of lists where user is owner |
| `TotalListsShared` | int | No | Count of lists shared with user (collaborator) |
| `TotalItemsCreated` | int | No | Count of items created by user across all lists |
| `TotalItemsPurchased` | int | No | Count of items marked purchased by user |
| `TotalActiveCollaborations` | int | No | Count of active (non-archived) collaborative lists |
| `LastActivityAt` | DateTime? | Yes | Most recent user action timestamp (UTC) |

**Example JSON**:

```json
{
  "totalListsOwned": 5,
  "totalListsShared": 12,
  "totalItemsCreated": 87,
  "totalItemsPurchased": 54,
  "totalActiveCollaborations": 8,
  "lastActivityAt": "2025-11-05T14:22:00Z"
}
```

**Calculation Logic** (see Query Definitions below for implementation)

---

### PublicUserProfileDto (Response - P3)

**Purpose**: Limited user information for public profiles (collaborators viewing each other)

**Location**: `AeInfinity.Application/Users/DTOs/PublicUserProfileDto.cs`

**Fields**:

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `Id` | Guid | No | Unique user identifier |
| `DisplayName` | string | No | User's display name |
| `AvatarUrl` | string? | Yes | Avatar image URL |
| `CreatedAt` | DateTime | No | Account creation timestamp (UTC) |

**Example JSON**:

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "displayName": "John Doe",
  "avatarUrl": "https://example.com/avatars/john.jpg",
  "createdAt": "2025-01-01T10:00:00Z"
}
```

**Privacy Note**: Email, full statistics, and sensitive data excluded from public profiles.

---

## MediatR Commands & Queries

### UpdateProfileCommand

**Purpose**: Update authenticated user's profile (display name and/or avatar)

**Location**: `AeInfinity.Application/Users/Commands/UpdateProfile/UpdateProfileCommand.cs`

**Properties**:

```csharp
public record UpdateProfileCommand : IRequest<Result<UserDto>>
{
    public Guid UserId { get; init; }           // From JWT claims
    public string DisplayName { get; init; } = string.Empty;
    public string? AvatarUrl { get; init; }
}
```

**Handler Logic** (`UpdateProfileCommandHandler.cs`):

```csharp
public async Task<Result<UserDto>> Handle(
    UpdateProfileCommand request,
    CancellationToken cancellationToken)
{
    // 1. Fetch user by ID (from JWT claims)
    var user = await _context.Users
        .FirstOrDefaultAsync(u => u.Id == request.UserId, cancellationToken);
    
    if (user == null)
        return Result<UserDto>.Failure("User not found");
    
    // 2. Update editable fields
    user.DisplayName = request.DisplayName.Trim();
    user.AvatarUrl = string.IsNullOrWhiteSpace(request.AvatarUrl) 
        ? null 
        : request.AvatarUrl.Trim();
    user.UpdatedAt = DateTime.UtcNow;
    user.UpdatedBy = request.UserId.ToString();
    
    // 3. Save changes
    await _context.SaveChangesAsync(cancellationToken);
    
    // 4. Publish domain event for SignalR broadcast
    await _mediator.Publish(new ProfileUpdatedEvent
    {
        UserId = user.Id,
        DisplayName = user.DisplayName,
        AvatarUrl = user.AvatarUrl
    }, cancellationToken);
    
    // 5. Return updated UserDto
    return Result<UserDto>.Success(UserDto.FromEntity(user));
}
```

**Validation**: Handled by `UpdateProfileCommandValidator` (FluentValidation) - see UpdateProfileDto section above.

**Authorization**: Enforced at controller level (JWT claims UserId must match request.UserId).

---

### GetUserStatsQuery

**Purpose**: Calculate user activity statistics with caching

**Location**: `AeInfinity.Application/Users/Queries/GetUserStats/GetUserStatsQuery.cs`

**Properties**:

```csharp
public record GetUserStatsQuery : IRequest<Result<UserStatsDto>>
{
    public Guid UserId { get; init; }  // From JWT claims
}
```

**Handler Logic** (`GetUserStatsQueryHandler.cs`):

```csharp
public async Task<Result<UserStatsDto>> Handle(
    GetUserStatsQuery request,
    CancellationToken cancellationToken)
{
    // 1. Check cache first (5-minute TTL)
    var cacheKey = $"user-stats:{request.UserId}";
    var cached = await _cacheService.GetAsync<UserStatsDto>(cacheKey);
    if (cached != null)
    {
        _logger.LogDebug("Statistics cache HIT for User {UserId}", request.UserId);
        return Result<UserStatsDto>.Success(cached);
    }
    
    _logger.LogDebug("Statistics cache MISS for User {UserId}", request.UserId);
    
    // 2. Calculate statistics (see Query Definitions below for LINQ)
    var stats = new UserStatsDto
    {
        TotalListsOwned = await _context.ShoppingLists
            .CountAsync(l => l.OwnerId == request.UserId && !l.IsDeleted, cancellationToken),
        
        TotalListsShared = await _context.Collaborators
            .CountAsync(c => c.UserId == request.UserId && !c.List.IsDeleted, cancellationToken),
        
        TotalItemsCreated = await _context.ListItems
            .CountAsync(i => i.CreatedBy == request.UserId.ToString() && !i.IsDeleted, cancellationToken),
        
        TotalItemsPurchased = await _context.ListItems
            .CountAsync(i => i.PurchasedBy == request.UserId && i.IsPurchased && !i.IsDeleted, cancellationToken),
        
        TotalActiveCollaborations = await _context.Collaborators
            .CountAsync(c => c.UserId == request.UserId && !c.List.IsArchived && !c.List.IsDeleted, cancellationToken),
        
        LastActivityAt = await GetLastActivityTimestamp(request.UserId, cancellationToken)
    };
    
    // 3. Cache for 5 minutes
    await _cacheService.SetAsync(cacheKey, stats, TimeSpan.FromMinutes(5));
    
    return Result<UserStatsDto>.Success(stats);
}

private async Task<DateTime?> GetLastActivityTimestamp(Guid userId, CancellationToken ct)
{
    var timestamps = new List<DateTime?>();
    
    // Check latest list creation
    var lastListCreated = await _context.ShoppingLists
        .Where(l => l.OwnerId == userId && !l.IsDeleted)
        .OrderByDescending(l => l.CreatedAt)
        .Select(l => l.CreatedAt)
        .FirstOrDefaultAsync(ct);
    if (lastListCreated != default)
        timestamps.Add(lastListCreated);
    
    // Check latest item creation
    var lastItemCreated = await _context.ListItems
        .Where(i => i.CreatedBy == userId.ToString() && !i.IsDeleted)
        .OrderByDescending(i => i.CreatedAt)
        .Select(i => i.CreatedAt)
        .FirstOrDefaultAsync(ct);
    if (lastItemCreated != default)
        timestamps.Add(lastItemCreated);
    
    // Check latest item purchase
    var lastPurchase = await _context.ListItems
        .Where(i => i.PurchasedBy == userId && i.IsPurchased && !i.IsDeleted)
        .OrderByDescending(i => i.PurchasedAt)
        .Select(i => i.PurchasedAt)
        .FirstOrDefaultAsync(ct);
    if (lastPurchase != null)
        timestamps.Add(lastPurchase);
    
    // Return most recent timestamp
    return timestamps.Any() ? timestamps.Max() : null;
}
```

**Performance Optimization**:
- Cache statistics for 5 minutes (reduces DB load)
- Use separate CountAsync queries (faster than single complex query)
- Invalidate cache on user actions (create list, add item, mark purchased)

**Cache Invalidation Events**:
- User creates a list → invalidate `user-stats:{userId}`
- User adds item to list → invalidate `user-stats:{userId}`
- User marks item purchased → invalidate `user-stats:{userId}`
- User accepts collaboration → invalidate `user-stats:{userId}`

---

### lastActivityAt Computation

The `lastActivityAt` field in `UserStatsDto` is a **computed field**, not a stored database column. It represents the most recent timestamp across all user activities:

**Calculation Logic**:
```csharp
lastActivityAt = Max(
    User.lastLoginAt,           // From feature 001 (updated on login)
    User.updatedAt,             // Updated when profile changes
    Lists.Max(createdAt),       // Most recent list created by user
    Items.Max(createdAt)        // Most recent item created by user
)
```

**Implementation Notes**:
- No separate `UserActivities` event log table required for MVP
- Computation happens in `GetUserStatsQueryHandler`
- Cached with 5-minute TTL to avoid expensive queries
- Returns `null` for users with no activity (new accounts)

**Future Enhancement**: If granular activity tracking is needed (e.g., "viewed list", "marked item purchased"), introduce `UserActivities` event log table in a later feature.

---

### GetUserByIdQuery (P3)

**Purpose**: Retrieve public profile of another user (minimal information)

**Location**: `AeInfinity.Application/Users/Queries/GetUserById/GetUserByIdQuery.cs`

**Properties**:

```csharp
public record GetUserByIdQuery : IRequest<Result<PublicUserProfileDto>>
{
    public Guid UserId { get; init; }  // Target user to view
}
```

**Handler Logic**:

```csharp
public async Task<Result<PublicUserProfileDto>> Handle(
    GetUserByIdQuery request,
    CancellationToken cancellationToken)
{
    var user = await _context.Users
        .Where(u => u.Id == request.UserId && !u.IsDeleted)
        .Select(u => new PublicUserProfileDto
        {
            Id = u.Id,
            DisplayName = u.DisplayName,
            AvatarUrl = u.AvatarUrl,
            CreatedAt = u.CreatedAt
        })
        .FirstOrDefaultAsync(cancellationToken);
    
    if (user == null)
        return Result<PublicUserProfileDto>.Failure("User not found");
    
    return Result<PublicUserProfileDto>.Success(user);
}
```

**Privacy**: Only returns DisplayName, AvatarUrl, CreatedAt (no email, no full statistics).

---

## Domain Events

### ProfileUpdatedEvent

**Purpose**: Notify system that user's profile changed (for SignalR broadcast)

**Location**: `AeInfinity.Domain/Events/ProfileUpdatedEvent.cs`

**Properties**:

```csharp
public record ProfileUpdatedEvent : INotification
{
    public Guid UserId { get; init; }
    public string DisplayName { get; init; } = string.Empty;
    public string? AvatarUrl { get; init; }
    public DateTime UpdatedAt { get; init; } = DateTime.UtcNow;
}
```

**Handler** (`ProfileUpdatedEventHandler.cs`):

```csharp
public class ProfileUpdatedEventHandler : INotificationHandler<ProfileUpdatedEvent>
{
    private readonly IHubContext<CollaborationHub> _hubContext;
    private readonly ILogger<ProfileUpdatedEventHandler> _logger;
    
    public async Task Handle(ProfileUpdatedEvent notification, CancellationToken ct)
    {
        // Broadcast to all connected clients that collaborate with this user
        await _hubContext.Clients.All.SendAsync(
            "ProfileUpdated",
            new
            {
                userId = notification.UserId,
                displayName = notification.DisplayName,
                avatarUrl = notification.AvatarUrl,
                updatedAt = notification.UpdatedAt
            },
            ct);
        
        _logger.LogInformation(
            "Broadcasted ProfileUpdated event for User {UserId}", 
            notification.UserId);
    }
}
```

**SignalR Client Handling** (Frontend):

```typescript
// In useSignalR.ts or similar
connection.on("ProfileUpdated", (data: ProfileUpdatedPayload) => {
  console.log(`User ${data.userId} updated profile:`, data.displayName);
  
  // Update user info in Header component
  // Update collaborator list if user is on shared lists
  // Refresh any cached user data
});
```

---

## Query Definitions

### Get User Profile (Existing from Feature 001)

**Endpoint**: GET /api/users/me

**Query**:

```csharp
var user = await _context.Users
    .Where(u => u.Id == userId && !u.IsDeleted)
    .Select(u => new UserDto
    {
        Id = u.Id,
        Email = u.Email,
        DisplayName = u.DisplayName,
        AvatarUrl = u.AvatarUrl,
        IsEmailVerified = u.IsEmailVerified,
        LastLoginAt = u.LastLoginAt,
        CreatedAt = u.CreatedAt
    })
    .FirstOrDefaultAsync(cancellationToken);
```

**Performance**: Single PK lookup, indexed query, < 10ms

---

### Update User Profile

**Endpoint**: PATCH /api/users/me

**Query**:

```csharp
var user = await _context.Users
    .FirstOrDefaultAsync(u => u.Id == userId && !u.IsDeleted, cancellationToken);

if (user != null)
{
    user.DisplayName = newDisplayName;
    user.AvatarUrl = newAvatarUrl;
    user.UpdatedAt = DateTime.UtcNow;
    user.UpdatedBy = userId.ToString();
    
    await _context.SaveChangesAsync(cancellationToken);
}
```

**Performance**: Single PK lookup + UPDATE, < 50ms

---

### Calculate Total Lists Owned

**Query**:

```csharp
var count = await _context.ShoppingLists
    .CountAsync(l => l.OwnerId == userId && !l.IsDeleted, cancellationToken);
```

**Indexes Required**:
- `IX_ShoppingLists_OwnerId` (existing from list features)
- `IX_ShoppingLists_IsDeleted` (part of soft delete pattern)

**Performance**: Indexed COUNT, < 50ms even for 1000+ lists

---

### Calculate Total Lists Shared

**Query**:

```csharp
var count = await _context.Collaborators
    .CountAsync(c => c.UserId == userId && !c.List.IsDeleted, cancellationToken);
```

**Indexes Required**:
- `IX_Collaborators_UserId` (existing from collaboration features)
- `IX_ShoppingLists_IsDeleted` (join filter)

**Performance**: Indexed COUNT with join, < 100ms

---

### Calculate Total Items Created

**Query**:

```csharp
var count = await _context.ListItems
    .CountAsync(i => i.CreatedBy == userId.ToString() && !i.IsDeleted, cancellationToken);
```

**Indexes Required**:
- `IX_ListItems_CreatedBy` (audit field, should be indexed)
- `IX_ListItems_IsDeleted` (soft delete filter)

**Performance**: Indexed COUNT, < 100ms even for 10,000+ items

---

### Calculate Total Items Purchased

**Query**:

```csharp
var count = await _context.ListItems
    .CountAsync(i => i.PurchasedBy == userId 
                  && i.IsPurchased 
                  && !i.IsDeleted, cancellationToken);
```

**Indexes Required**:
- `IX_ListItems_PurchasedBy` (should be indexed)
- `IX_ListItems_IsPurchased` (filter on boolean)
- `IX_ListItems_IsDeleted` (soft delete filter)

**Performance**: Indexed COUNT with multiple filters, < 150ms

---

### Calculate Total Active Collaborations

**Query**:

```csharp
var count = await _context.Collaborators
    .CountAsync(c => c.UserId == userId 
                  && !c.List.IsArchived 
                  && !c.List.IsDeleted, cancellationToken);
```

**Indexes Required**:
- `IX_Collaborators_UserId`
- `IX_ShoppingLists_IsArchived`
- `IX_ShoppingLists_IsDeleted`

**Performance**: Indexed COUNT with join + filters, < 100ms

---

### Get Last Activity Timestamp

**Composite Query** (union of latest timestamps):

```csharp
// Latest list creation
var lastListCreated = await _context.ShoppingLists
    .Where(l => l.OwnerId == userId && !l.IsDeleted)
    .OrderByDescending(l => l.CreatedAt)
    .Select(l => l.CreatedAt)
    .FirstOrDefaultAsync(ct);

// Latest item creation
var lastItemCreated = await _context.ListItems
    .Where(i => i.CreatedBy == userId.ToString() && !i.IsDeleted)
    .OrderByDescending(i => i.CreatedAt)
    .Select(i => i.CreatedAt)
    .FirstOrDefaultAsync(ct);

// Latest item purchase
var lastPurchase = await _context.ListItems
    .Where(i => i.PurchasedBy == userId && i.IsPurchased && !i.IsDeleted)
    .OrderByDescending(i => i.PurchasedAt)
    .Select(i => i.PurchasedAt)
    .FirstOrDefaultAsync(ct);

// Return maximum timestamp
return new[] { lastListCreated, lastItemCreated, lastPurchase }
    .Where(t => t != default && t != null)
    .OrderByDescending(t => t)
    .FirstOrDefault();
```

**Performance**: 3 separate queries with ORDER BY + LIMIT 1, < 50ms total

---

## Caching Strategy

### ICacheService Interface

**Location**: `AeInfinity.Application/Common/Interfaces/ICacheService.cs`

```csharp
public interface ICacheService
{
    Task<T?> GetAsync<T>(string key) where T : class;
    Task SetAsync<T>(string key, T value, TimeSpan expiration) where T : class;
    Task RemoveAsync(string key);
    Task RemoveByPrefixAsync(string prefix);
}
```

### MemoryCacheService Implementation

**Location**: `AeInfinity.Infrastructure/Caching/MemoryCacheService.cs`

```csharp
public class MemoryCacheService : ICacheService
{
    private readonly IMemoryCache _memoryCache;
    private readonly ILogger<MemoryCacheService> _logger;
    
    public async Task<T?> GetAsync<T>(string key) where T : class
    {
        if (_memoryCache.TryGetValue(key, out T? value))
        {
            _logger.LogDebug("Cache HIT for key: {CacheKey}", key);
            return value;
        }
        
        _logger.LogDebug("Cache MISS for key: {CacheKey}", key);
        return null;
    }
    
    public async Task SetAsync<T>(string key, T value, TimeSpan expiration) where T : class
    {
        var cacheOptions = new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = expiration
        };
        
        _memoryCache.Set(key, value, cacheOptions);
        _logger.LogDebug("Cache SET for key: {CacheKey}, TTL: {Expiration}", key, expiration);
        
        await Task.CompletedTask;
    }
    
    public async Task RemoveAsync(string key)
    {
        _memoryCache.Remove(key);
        _logger.LogDebug("Cache REMOVE for key: {CacheKey}", key);
        await Task.CompletedTask;
    }
    
    public async Task RemoveByPrefixAsync(string prefix)
    {
        // IMemoryCache doesn't support prefix removal
        // Consider using distributed cache (Redis) for this feature
        _logger.LogWarning("RemoveByPrefix not supported for IMemoryCache: {Prefix}", prefix);
        await Task.CompletedTask;
    }
}
```

### Cache Keys

| Cache Key | Value Type | TTL | Invalidation Trigger |
|-----------|-----------|-----|----------------------|
| `user-stats:{userId}` | UserStatsDto | 5 minutes | User creates list, adds item, marks purchase |

### Cache Invalidation

Invalidate user statistics cache when:

```csharp
// In CreateListCommandHandler:
await _cacheService.RemoveAsync($"user-stats:{command.UserId}");

// In CreateItemCommandHandler:
await _cacheService.RemoveAsync($"user-stats:{command.UserId}");

// In MarkItemPurchasedCommandHandler:
await _cacheService.RemoveAsync($"user-stats:{command.UserId}");

// In AcceptCollaborationCommandHandler:
await _cacheService.RemoveAsync($"user-stats:{command.UserId}");
```

---

## Database Indexes

**No new indexes required** - all necessary indexes exist from previous features (001, 003, 004, 005):

| Table | Index | Columns | Purpose |
|-------|-------|---------|---------|
| Users | PK_Users | Id | Primary key lookup |
| Users | IX_Users_EmailNormalized | EmailNormalized (unique) | Login lookup |
| ShoppingLists | IX_ShoppingLists_OwnerId | OwnerId | Count lists owned |
| ShoppingLists | IX_ShoppingLists_IsDeleted | IsDeleted | Soft delete filter |
| ShoppingLists | IX_ShoppingLists_IsArchived | IsArchived | Filter archived lists |
| Collaborators | IX_Collaborators_UserId | UserId | Count collaborations |
| ListItems | IX_ListItems_CreatedBy | CreatedBy | Count items created |
| ListItems | IX_ListItems_PurchasedBy | PurchasedBy | Count items purchased |
| ListItems | IX_ListItems_IsPurchased | IsPurchased | Filter purchased items |
| ListItems | IX_ListItems_IsDeleted | IsDeleted | Soft delete filter |

**Performance Note**: All statistics queries use indexed columns. Estimated worst-case query time with 1000 lists and 10,000 items: ~500ms (within target).

---

## Error Handling

### Validation Errors

**Status Code**: 400 Bad Request

**Response Format**:

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "DisplayName": ["Display name must be at least 2 characters"],
    "AvatarUrl": ["Avatar URL must be a valid URL or empty"]
  }
}
```

### Authorization Errors

**Status Code**: 403 Forbidden

**Response**:

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.3",
  "title": "Forbidden",
  "status": 403,
  "detail": "You are not authorized to update this profile"
}
```

### Not Found Errors

**Status Code**: 404 Not Found

**Response**:

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Not Found",
  "status": 404,
  "detail": "User not found"
}
```

---

## Testing Scenarios

### UpdateProfileCommand Tests

```csharp
[Fact]
public async Task Handle_ValidRequest_UpdatesProfile()
{
    // Arrange
    var user = UserFactory.Create();
    await _context.Users.AddAsync(user);
    await _context.SaveChangesAsync();
    
    var command = new UpdateProfileCommand
    {
        UserId = user.Id,
        DisplayName = "New Name",
        AvatarUrl = "https://example.com/new-avatar.jpg"
    };
    
    // Act
    var result = await _handler.Handle(command, CancellationToken.None);
    
    // Assert
    result.IsSuccess.Should().BeTrue();
    result.Value.DisplayName.Should().Be("New Name");
    result.Value.AvatarUrl.Should().Be("https://example.com/new-avatar.jpg");
    
    var updatedUser = await _context.Users.FindAsync(user.Id);
    updatedUser!.DisplayName.Should().Be("New Name");
    updatedUser.AvatarUrl.Should().Be("https://example.com/new-avatar.jpg");
}

[Fact]
public async Task Handle_NullAvatarUrl_ClearsAvatar()
{
    // Arrange
    var user = UserFactory.Create(avatarUrl: "https://example.com/old.jpg");
    await _context.Users.AddAsync(user);
    await _context.SaveChangesAsync();
    
    var command = new UpdateProfileCommand
    {
        UserId = user.Id,
        DisplayName = "Same Name",
        AvatarUrl = null
    };
    
    // Act
    var result = await _handler.Handle(command, CancellationToken.None);
    
    // Assert
    result.IsSuccess.Should().BeTrue();
    result.Value.AvatarUrl.Should().BeNull();
}
```

### GetUserStatsQuery Tests

```csharp
[Fact]
public async Task Handle_UserWithActivity_ReturnsCorrectStatistics()
{
    // Arrange
    var user = UserFactory.Create();
    var list1 = ShoppingListFactory.Create(ownerId: user.Id);
    var list2 = ShoppingListFactory.Create(ownerId: user.Id);
    var collaboration = CollaboratorFactory.Create(userId: user.Id);
    var item = ListItemFactory.Create(createdBy: user.Id, purchasedBy: user.Id, isPurchased: true);
    
    await _context.AddRangeAsync(user, list1, list2, collaboration, item);
    await _context.SaveChangesAsync();
    
    var query = new GetUserStatsQuery { UserId = user.Id };
    
    // Act
    var result = await _handler.Handle(query, CancellationToken.None);
    
    // Assert
    result.IsSuccess.Should().BeTrue();
    result.Value.TotalListsOwned.Should().Be(2);
    result.Value.TotalListsShared.Should().Be(1);
    result.Value.TotalItemsCreated.Should().Be(1);
    result.Value.TotalItemsPurchased.Should().Be(1);
}

[Fact]
public async Task Handle_CachedStatistics_ReturnsCachedValue()
{
    // Arrange
    var userId = Guid.NewGuid();
    var cachedStats = new UserStatsDto { TotalListsOwned = 42 };
    await _cacheService.SetAsync($"user-stats:{userId}", cachedStats, TimeSpan.FromMinutes(5));
    
    var query = new GetUserStatsQuery { UserId = userId };
    
    // Act
    var result = await _handler.Handle(query, CancellationToken.None);
    
    // Assert
    result.IsSuccess.Should().BeTrue();
    result.Value.TotalListsOwned.Should().Be(42);
    // Verify no database queries were executed (mock verification)
}
```

---

## Summary

This feature requires:
- ✅ **No database migrations** (User entity complete from feature 001)
- 🔨 **3 new DTOs**: UpdateProfileDto, UserStatsDto, PublicUserProfileDto
- 🔨 **3 new commands/queries**: UpdateProfileCommand, GetUserStatsQuery, GetUserByIdQuery
- 🔨 **1 domain event**: ProfileUpdatedEvent (for SignalR)
- 🔨 **1 caching service**: ICacheService + MemoryCacheService
- 🔨 **1 SignalR method**: ProfileUpdated broadcast
- ✅ **Existing indexes sufficient** for performance
- 🎯 **Target performance**: < 500ms for all operations

**Next Step**: Generate API contracts (JSON schemas) in `/contracts/` folder.

---

**Last Updated**: 2025-11-05

