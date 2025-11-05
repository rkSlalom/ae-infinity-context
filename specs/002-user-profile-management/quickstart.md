# Quickstart Guide: User Profile Management

**Feature**: 002-user-profile-management  
**For**: Developers implementing this feature  
**Prerequisites**: Feature 001 (User Authentication) complete  
**Estimated Time**: 8-10 days (P1+P2), +2 days (P3)

---

## 🎯 What You're Building

Users can:
- ✅ View their complete profile (name, email, avatar, account info, statistics)
- ✅ Edit their display name and avatar URL
- ✅ See activity statistics (lists, items, collaborations)
- 📋 View public profiles of collaborators (P3 - optional)

**Not in scope**: Password changes, email changes, account deletion

---

## 📋 Prerequisites Check

Before starting, ensure you have:

- [x] Feature 001 complete (JWT authentication, GET /users/me endpoint)
- [x] User entity exists with DisplayName and AvatarUrl fields
- [x] SignalR CollaborationHub exists for real-time broadcasts
- [x] MediatR and FluentValidation configured
- [x] Development environment running (API + UI)

**Test existing functionality**:

```bash
# Terminal 1: Start API
cd ../ae-infinity-api
dotnet run --project AeInfinity.API

# Terminal 2: Start UI
cd ../ae-infinity-ui
npm run dev

# Test GET /users/me endpoint
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  http://localhost:5233/api/users/me
```

If this works, you're ready to proceed!

---

## 🏗️ Implementation Roadmap

### Phase 1: Backend Profile Update (3-4 days)

**Priority**: P1 (Must have)

**Tasks**:
1. Create DTOs and validation
2. Create MediatR command handler
3. Add PATCH /users/me endpoint
4. Add SignalR ProfileUpdated broadcast
5. Write unit and integration tests

### Phase 2: Frontend Profile Edit (3-4 days)

**Priority**: P1 (Must have)

**Tasks**:
1. Create profile UI components
2. Integrate React Hook Form
3. Add API calls and custom hooks
4. Update Header with avatar/name
5. Add SignalR listener for profile updates
6. Write component tests

### Phase 3: Statistics (2 days)

**Priority**: P2 (Should have)

**Tasks**:
1. Create statistics query handler
2. Add caching service
3. Create statistics UI component
4. Write tests

### Phase 4: Public Profiles (2 days)

**Priority**: P3 (Nice to have - deferrable)

**Tasks**:
1. Create public profile query handler
2. Create public profile page component
3. Add links from collaborator lists
4. Write tests

---

## 🔨 Step-by-Step Implementation

### Step 1: Create DTOs (30 minutes)

**Location**: `../ae-infinity-api/AeInfinity.Application/Users/DTOs/`

**Files to create**:

**UpdateProfileDto.cs**:

```csharp
namespace AeInfinity.Application.Users.DTOs;

public class UpdateProfileDto
{
    public string DisplayName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
}
```

**UserStatsDto.cs**:

```csharp
namespace AeInfinity.Application.Users.DTOs;

public class UserStatsDto
{
    public int TotalListsOwned { get; set; }
    public int TotalListsShared { get; set; }
    public int TotalItemsCreated { get; set; }
    public int TotalItemsPurchased { get; set; }
    public int TotalActiveCollaborations { get; set; }
    public DateTime? LastActivityAt { get; set; }
}
```

**PublicUserProfileDto.cs** (P3):

```csharp
namespace AeInfinity.Application.Users.DTOs;

public class PublicUserProfileDto
{
    public Guid Id { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

---

### Step 2: Create MediatR Command (1 hour)

**Location**: `../ae-infinity-api/AeInfinity.Application/Users/Commands/UpdateProfile/`

**UpdateProfileCommand.cs**:

```csharp
using AeInfinity.Application.Common;
using AeInfinity.Application.Users.DTOs;
using MediatR;

namespace AeInfinity.Application.Users.Commands.UpdateProfile;

public record UpdateProfileCommand : IRequest<Result<UserDto>>
{
    public Guid UserId { get; init; }
    public string DisplayName { get; init; } = string.Empty;
    public string? AvatarUrl { get; init; }
}
```

**UpdateProfileCommandHandler.cs**:

```csharp
using AeInfinity.Application.Common;
using AeInfinity.Application.Users.DTOs;
using AeInfinity.Domain.Events;
using AeInfinity.Infrastructure.Data;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace AeInfinity.Application.Users.Commands.UpdateProfile;

public class UpdateProfileCommandHandler 
    : IRequestHandler<UpdateProfileCommand, Result<UserDto>>
{
    private readonly AeInfinityDbContext _context;
    private readonly IMediator _mediator;
    private readonly ILogger<UpdateProfileCommandHandler> _logger;

    public UpdateProfileCommandHandler(
        AeInfinityDbContext context,
        IMediator mediator,
        ILogger<UpdateProfileCommandHandler> logger)
    {
        _context = context;
        _mediator = mediator;
        _logger = logger;
    }

    public async Task<Result<UserDto>> Handle(
        UpdateProfileCommand request,
        CancellationToken cancellationToken)
    {
        // 1. Fetch user
        var user = await _context.Users
            .FirstOrDefaultAsync(
                u => u.Id == request.UserId,
                cancellationToken);

        if (user == null)
        {
            _logger.LogWarning("User {UserId} not found for profile update", request.UserId);
            return Result<UserDto>.Failure("User not found");
        }

        // 2. Update editable fields
        user.DisplayName = request.DisplayName.Trim();
        user.AvatarUrl = string.IsNullOrWhiteSpace(request.AvatarUrl)
            ? null
            : request.AvatarUrl.Trim();
        user.UpdatedAt = DateTime.UtcNow;
        user.UpdatedBy = request.UserId.ToString();

        // 3. Save changes
        await _context.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "User {UserId} updated profile. DisplayName: {DisplayName}",
            user.Id,
            user.DisplayName);

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
}
```

**UpdateProfileCommandValidator.cs**:

```csharp
using FluentValidation;

namespace AeInfinity.Application.Users.Commands.UpdateProfile;

public class UpdateProfileCommandValidator 
    : AbstractValidator<UpdateProfileCommand>
{
    public UpdateProfileCommandValidator()
    {
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
    }

    private bool BeValidUriOrNull(string? url)
    {
        if (string.IsNullOrWhiteSpace(url))
            return true;

        return Uri.TryCreate(url, UriKind.Absolute, out var uri)
            && (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps);
    }
}
```

---

### Step 3: Add API Endpoint (30 minutes)

**Location**: `../ae-infinity-api/AeInfinity.API/Controllers/UsersController.cs`

**Add PATCH endpoint**:

```csharp
using AeInfinity.Application.Users.Commands.UpdateProfile;
using AeInfinity.Application.Users.DTOs;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AeInfinity.API.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;

    public UsersController(IMediator mediator)
    {
        _mediator = mediator;
    }

    // Existing GET /users/me endpoint (from feature 001)

    /// <summary>
    /// Update current user's profile
    /// </summary>
    /// <param name="dto">Updated profile information</param>
    /// <returns>Updated user profile</returns>
    [HttpPatch("me")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileDto dto)
    {
        // Extract user ID from JWT claims
        var userIdClaim = User.FindFirst("sub")?.Value;
        if (!Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var command = new UpdateProfileCommand
        {
            UserId = userId,
            DisplayName = dto.DisplayName,
            AvatarUrl = dto.AvatarUrl
        };

        var result = await _mediator.Send(command);

        if (!result.IsSuccess)
        {
            return BadRequest(new { message = result.Error });
        }

        return Ok(result.Value);
    }
}
```

**Test the endpoint**:

```bash
# Test with curl
curl -X PATCH http://localhost:5233/api/users/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "displayName": "New Name",
    "avatarUrl": "https://example.com/avatar.jpg"
  }'
```

---

### Step 4: Add SignalR Broadcast (30 minutes)

**ProfileUpdatedEvent.cs**:

```csharp
using MediatR;

namespace AeInfinity.Domain.Events;

public record ProfileUpdatedEvent : INotification
{
    public Guid UserId { get; init; }
    public string DisplayName { get; init; } = string.Empty;
    public string? AvatarUrl { get; init; }
    public DateTime UpdatedAt { get; init; } = DateTime.UtcNow;
}
```

**ProfileUpdatedEventHandler.cs**:

```csharp
using AeInfinity.Domain.Events;
using AeInfinity.Infrastructure.SignalR;
using MediatR;
using Microsoft.AspNetCore.SignalR;

namespace AeInfinity.Application.Users.EventHandlers;

public class ProfileUpdatedEventHandler 
    : INotificationHandler<ProfileUpdatedEvent>
{
    private readonly IHubContext<CollaborationHub> _hubContext;
    private readonly ILogger<ProfileUpdatedEventHandler> _logger;

    public ProfileUpdatedEventHandler(
        IHubContext<CollaborationHub> hubContext,
        ILogger<ProfileUpdatedEventHandler> logger)
    {
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task Handle(
        ProfileUpdatedEvent notification,
        CancellationToken cancellationToken)
    {
        // Broadcast to all connected clients
        await _hubContext.Clients.All.SendAsync(
            "ProfileUpdated",
            new
            {
                userId = notification.UserId,
                displayName = notification.DisplayName,
                avatarUrl = notification.AvatarUrl,
                updatedAt = notification.UpdatedAt
            },
            cancellationToken);

        _logger.LogInformation(
            "Broadcasted ProfileUpdated event for User {UserId}",
            notification.UserId);
    }
}
```

---

### Step 5: Write Backend Tests (2-3 hours)

**UpdateProfileCommandHandlerTests.cs**:

```csharp
using AeInfinity.Application.Users.Commands.UpdateProfile;
using AeInfinity.Application.Users.DTOs;
using AeInfinity.Tests.TestHelpers;
using FluentAssertions;
using Xunit;

namespace AeInfinity.Tests.Unit.Users;

public class UpdateProfileCommandHandlerTests : TestBase
{
    [Fact]
    public async Task Handle_ValidRequest_UpdatesProfile()
    {
        // Arrange
        var user = UserFactory.Create();
        await Context.Users.AddAsync(user);
        await Context.SaveChangesAsync();

        var command = new UpdateProfileCommand
        {
            UserId = user.Id,
            DisplayName = "New Name",
            AvatarUrl = "https://example.com/new-avatar.jpg"
        };

        var handler = new UpdateProfileCommandHandler(Context, Mediator, Logger);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Value.DisplayName.Should().Be("New Name");
        result.Value.AvatarUrl.Should().Be("https://example.com/new-avatar.jpg");

        var updatedUser = await Context.Users.FindAsync(user.Id);
        updatedUser!.DisplayName.Should().Be("New Name");
        updatedUser.AvatarUrl.Should().Be("https://example.com/new-avatar.jpg");
    }

    [Fact]
    public async Task Handle_NullAvatarUrl_ClearsAvatar()
    {
        // Arrange
        var user = UserFactory.Create(avatarUrl: "https://example.com/old.jpg");
        await Context.Users.AddAsync(user);
        await Context.SaveChangesAsync();

        var command = new UpdateProfileCommand
        {
            UserId = user.Id,
            DisplayName = "Same Name",
            AvatarUrl = null
        };

        var handler = new UpdateProfileCommandHandler(Context, Mediator, Logger);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Value.AvatarUrl.Should().BeNull();
    }

    [Fact]
    public async Task Handle_UserNotFound_ReturnsFailure()
    {
        // Arrange
        var command = new UpdateProfileCommand
        {
            UserId = Guid.NewGuid(),
            DisplayName = "Any Name"
        };

        var handler = new UpdateProfileCommandHandler(Context, Mediator, Logger);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeFalse();
        result.Error.Should().Be("User not found");
    }
}
```

**UpdateProfileCommandValidatorTests.cs**:

```csharp
using AeInfinity.Application.Users.Commands.UpdateProfile;
using FluentValidation.TestHelper;
using Xunit;

namespace AeInfinity.Tests.Unit.Users;

public class UpdateProfileCommandValidatorTests
{
    private readonly UpdateProfileCommandValidator _validator = new();

    [Fact]
    public void Validate_ValidCommand_PassesValidation()
    {
        var command = new UpdateProfileCommand
        {
            UserId = Guid.NewGuid(),
            DisplayName = "John Doe",
            AvatarUrl = "https://example.com/avatar.jpg"
        };

        var result = _validator.TestValidate(command);

        result.ShouldNotHaveAnyValidationErrors();
    }

    [Fact]
    public void Validate_DisplayNameTooShort_FailsValidation()
    {
        var command = new UpdateProfileCommand
        {
            UserId = Guid.NewGuid(),
            DisplayName = "A"
        };

        var result = _validator.TestValidate(command);

        result.ShouldHaveValidationErrorFor(x => x.DisplayName)
            .WithErrorMessage("Display name must be at least 2 characters");
    }

    [Fact]
    public void Validate_InvalidAvatarUrl_FailsValidation()
    {
        var command = new UpdateProfileCommand
        {
            UserId = Guid.NewGuid(),
            DisplayName = "John Doe",
            AvatarUrl = "not-a-valid-url"
        };

        var result = _validator.TestValidate(command);

        result.ShouldHaveValidationErrorFor(x => x.AvatarUrl)
            .WithErrorMessage("Avatar URL must be a valid URL or empty");
    }
}
```

**Run tests**:

```bash
cd ../ae-infinity-api
dotnet test --filter "FullyQualifiedName~UpdateProfile"
```

---

### Step 6: Create Frontend Components (3-4 hours)

**profileApi.ts**:

```typescript
// ../ae-infinity-ui/src/features/profile/profileApi.ts
import { UserDto, UpdateProfileDto, UserStatsDto } from '../../types';

const API_BASE = import.meta.env.VITE_API_BASE_URL;

export async function getProfile(token: string): Promise<UserDto> {
  const response = await fetch(`${API_BASE}/users/me`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error('Failed to fetch profile');
  }

  return response.json();
}

export async function updateProfile(
  token: string,
  data: UpdateProfileDto
): Promise<UserDto> {
  const response = await fetch(`${API_BASE}/users/me`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Failed to update profile');
  }

  return response.json();
}

export async function getUserStats(token: string): Promise<UserStatsDto> {
  const response = await fetch(`${API_BASE}/users/me/stats`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    throw new Error('Failed to fetch statistics');
  }

  return response.json();
}
```

**useProfile.ts**:

```typescript
// ../ae-infinity-ui/src/features/profile/useProfile.ts
import { useState } from 'react';
import { useAuth } from '../../hooks/useAuth';
import { getProfile, updateProfile } from './profileApi';
import type { UserDto, UpdateProfileDto } from '../../types';

export function useProfile() {
  const { token } = useAuth();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const fetchProfile = async (): Promise<UserDto | null> => {
    if (!token) return null;

    setLoading(true);
    setError(null);

    try {
      const profile = await getProfile(token);
      return profile;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load profile');
      return null;
    } finally {
      setLoading(false);
    }
  };

  const updateUserProfile = async (
    data: UpdateProfileDto
  ): Promise<UserDto | null> => {
    if (!token) return null;

    setLoading(true);
    setError(null);

    try {
      const updated = await updateProfile(token, data);
      return updated;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to update profile');
      return null;
    } finally {
      setLoading(false);
    }
  };

  return {
    fetchProfile,
    updateUserProfile,
    loading,
    error,
  };
}
```

**ProfilePage.tsx**:

```typescript
// ../ae-infinity-ui/src/features/profile/ProfilePage.tsx
import { useState, useEffect } from 'react';
import { useProfile } from './useProfile';
import { ProfileEditForm } from './ProfileEditForm';
import { AvatarImage } from './AvatarImage';
import type { UserDto } from '../../types';

export function ProfilePage() {
  const { fetchProfile, loading } = useProfile();
  const [user, setUser] = useState<UserDto | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  useEffect(() => {
    loadProfile();
  }, []);

  const loadProfile = async () => {
    const profile = await fetchProfile();
    if (profile) {
      setUser(profile);
    }
  };

  const handleUpdateSuccess = (updated: UserDto) => {
    setUser(updated);
    setIsEditing(false);
  };

  if (loading) {
    return <div className="p-4">Loading profile...</div>;
  }

  if (!user) {
    return <div className="p-4 text-red-600">Failed to load profile</div>;
  }

  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex items-center gap-4 mb-6">
          <AvatarImage
            src={user.avatarUrl}
            alt={user.displayName}
            size="large"
          />
          <div>
            <h1 className="text-2xl font-bold">{user.displayName}</h1>
            <p className="text-gray-600">{user.email}</p>
          </div>
        </div>

        {!isEditing ? (
          <div>
            <dl className="space-y-2">
              <div>
                <dt className="font-semibold">Account Created</dt>
                <dd>{new Date(user.createdAt).toLocaleDateString()}</dd>
              </div>
              {user.lastLoginAt && (
                <div>
                  <dt className="font-semibold">Last Login</dt>
                  <dd>{new Date(user.lastLoginAt).toLocaleDateString()}</dd>
                </div>
              )}
              <div>
                <dt className="font-semibold">Email Verified</dt>
                <dd>{user.isEmailVerified ? 'Yes' : 'No'}</dd>
              </div>
            </dl>

            <button
              onClick={() => setIsEditing(true)}
              className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            >
              Edit Profile
            </button>
          </div>
        ) : (
          <ProfileEditForm
            initialData={user}
            onSuccess={handleUpdateSuccess}
            onCancel={() => setIsEditing(false)}
          />
        )}
      </div>
    </div>
  );
}
```

**ProfileEditForm.tsx**:

```typescript
// ../ae-infinity-ui/src/features/profile/ProfileEditForm.tsx
import { useForm } from 'react-hook-form';
import { useProfile } from './useProfile';
import type { UserDto, UpdateProfileDto } from '../../types';

interface Props {
  initialData: UserDto;
  onSuccess: (updated: UserDto) => void;
  onCancel: () => void;
}

export function ProfileEditForm({ initialData, onSuccess, onCancel }: Props) {
  const { updateUserProfile, loading, error } = useProfile();
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<UpdateProfileDto>({
    defaultValues: {
      displayName: initialData.displayName,
      avatarUrl: initialData.avatarUrl || '',
    },
  });

  const onSubmit = async (data: UpdateProfileDto) => {
    const updated = await updateUserProfile({
      displayName: data.displayName,
      avatarUrl: data.avatarUrl || null,
    });

    if (updated) {
      onSuccess(updated);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-1">Display Name</label>
        <input
          {...register('displayName', {
            required: 'Display name is required',
            minLength: {
              value: 2,
              message: 'Display name must be at least 2 characters',
            },
            maxLength: {
              value: 100,
              message: 'Display name must not exceed 100 characters',
            },
          })}
          className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
        />
        {errors.displayName && (
          <p className="text-red-600 text-sm mt-1">
            {errors.displayName.message}
          </p>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium mb-1">Avatar URL</label>
        <input
          {...register('avatarUrl', {
            pattern: {
              value: /^https?:\/\/.+/,
              message: 'Please provide a valid URL',
            },
            maxLength: {
              value: 500,
              message: 'URL must not exceed 500 characters',
            },
          })}
          placeholder="https://example.com/avatar.jpg"
          className="w-full px-3 py-2 border rounded focus:ring-2 focus:ring-blue-500"
        />
        {errors.avatarUrl && (
          <p className="text-red-600 text-sm mt-1">{errors.avatarUrl.message}</p>
        )}
      </div>

      {error && <p className="text-red-600 text-sm">{error}</p>}

      <div className="flex gap-2">
        <button
          type="submit"
          disabled={loading}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Saving...' : 'Save Changes'}
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400"
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
```

**AvatarImage.tsx**:

```typescript
// ../ae-infinity-ui/src/features/profile/AvatarImage.tsx
import { useState } from 'react';

interface Props {
  src: string | null;
  alt: string;
  size?: 'small' | 'medium' | 'large';
}

export function AvatarImage({ src, alt, size = 'medium' }: Props) {
  const [hasError, setHasError] = useState(false);

  const sizeClasses = {
    small: 'w-8 h-8',
    medium: 'w-12 h-12',
    large: 'w-24 h-24',
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  if (!src || hasError) {
    return (
      <div
        className={`${sizeClasses[size]} rounded-full bg-blue-500 text-white flex items-center justify-center font-semibold`}
      >
        {getInitials(alt)}
      </div>
    );
  }

  return (
    <img
      src={src}
      alt={alt}
      onError={() => setHasError(true)}
      className={`${sizeClasses[size]} rounded-full object-cover`}
    />
  );
}
```

---

### Step 7: Add Route and Navigation (15 minutes)

**App.tsx** (add route):

```typescript
import { Route } from 'react-router-dom';
import { ProfilePage } from './features/profile/ProfilePage';

// In your router configuration:
<Route path="/profile" element={<ProfilePage />} />
```

**Header.tsx** (add profile link):

```typescript
import { Link } from 'react-router-dom';
import { AvatarImage } from '../features/profile/AvatarImage';
import { useAuth } from '../hooks/useAuth';

export function Header() {
  const { user } = useAuth();

  return (
    <header className="bg-white shadow">
      <div className="flex items-center justify-between p-4">
        <h1>AE Infinity</h1>
        {user && (
          <Link to="/profile" className="flex items-center gap-2">
            <AvatarImage
              src={user.avatarUrl}
              alt={user.displayName}
              size="small"
            />
            <span>{user.displayName}</span>
          </Link>
        )}
      </div>
    </header>
  );
}
```

---

### Step 8: Add SignalR Listener (30 minutes)

**useSignalR.ts**:

```typescript
// Add to existing SignalR hook
connection.on('ProfileUpdated', (data: ProfileUpdatedPayload) => {
  console.log('Profile updated:', data);

  // Update cached user info if it's the current user
  if (data.userId === currentUserId) {
    updateCurrentUser({
      ...currentUser,
      displayName: data.displayName,
      avatarUrl: data.avatarUrl,
    });
  }

  // Trigger refresh of collaborator lists if needed
  // refetchCollaborators();
});
```

---

## 🧪 Testing Guide

### Backend Tests

```bash
# Run all profile-related tests
cd ../ae-infinity-api
dotnet test --filter "FullyQualifiedName~UpdateProfile"
dotnet test --filter "FullyQualifiedName~UserStats"

# Run with coverage
dotnet test /p:CollectCoverage=true /p:CoverageReportsDirectory=./coverage
```

### Frontend Tests

```bash
# Run component tests
cd ../ae-infinity-ui
npm test -- --run ProfilePage
npm test -- --run ProfileEditForm
npm test -- --run AvatarImage

# Run with coverage
npm test -- --coverage
```

### Manual Testing Checklist

- [ ] Can view profile page
- [ ] Can edit display name and save
- [ ] Can edit avatar URL and save
- [ ] Can clear avatar (set to null)
- [ ] Display name validation works (< 2 chars, > 100 chars)
- [ ] Avatar URL validation works (invalid URL)
- [ ] Avatar fallback works for broken URLs
- [ ] Profile updates persist across page refresh
- [ ] Header updates when profile changes
- [ ] Can cancel edit without saving
- [ ] Error messages display for API failures

---

## 📊 Performance Targets

Track these metrics:

- ✅ Profile load time: < 2 seconds
- ✅ Profile update time: < 500ms
- ✅ Form validation feedback: < 200ms
- ✅ Avatar fallback displays: < 100ms
- ✅ SignalR broadcast latency: < 100ms

---

## 🐛 Common Issues & Solutions

### Issue: PATCH endpoint returns 401

**Solution**: Ensure JWT token is included in Authorization header.

```typescript
headers: {
  Authorization: `Bearer ${token}`,
}
```

### Issue: Avatar image doesn't display

**Solution**: Check CORS settings. Avatar URLs must be accessible from browser.

### Issue: Validation errors not displayed

**Solution**: Ensure FluentValidation middleware is configured in backend.

```csharp
// In Program.cs
builder.Services.AddValidatorsFromAssemblyContaining<UpdateProfileCommandValidator>();
```

### Issue: Profile changes don't broadcast

**Solution**: Verify SignalR hub is registered and ProfileUpdatedEvent handler exists.

---

## ✅ Definition of Done

Before marking this feature as complete, ensure:

- [ ] All P1 tasks implemented and tested
- [ ] Backend unit tests pass (≥80% coverage)
- [ ] Backend integration tests pass
- [ ] Frontend component tests pass (≥80% coverage)
- [ ] Manual testing checklist complete
- [ ] Performance targets met
- [ ] No TypeScript `any` types
- [ ] No console errors in browser
- [ ] Accessibility tested (keyboard navigation, screen readers)
- [ ] Code review approved
- [ ] Documentation updated (API_SPEC.md, Swagger)
- [ ] Feature deployed to staging

---

## 📚 Additional Resources

- [spec.md](./spec.md) - Business requirements
- [plan.md](./plan.md) - Implementation strategy
- [data-model.md](./data-model.md) - Entity definitions
- [contracts/](./contracts/) - API JSON schemas
- [Feature 001: User Authentication](../001-user-authentication/) - Prerequisite feature
- [Constitution](../../.specify/memory/constitution.md) - Development standards

---

## 🚀 Next Steps

After completing this feature:

1. Generate tasks with `/speckit.tasks` command
2. Implement Phase 2: Statistics (P2)
3. Consider Phase 3: Public profiles (P3 - optional)
4. Move to Feature 003: Shopping Lists CRUD

---

**Last Updated**: 2025-11-05  
**Questions?** Check spec.md or ask the team!

