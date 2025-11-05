# Implementation Plan: User Authentication

**Branch**: `001-user-authentication` | **Date**: 2025-11-05 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-user-authentication/spec.md`

## Summary

Complete user authentication system with JWT tokens, secure password hashing, and profile management. This plan addresses the current 80% implementation status by completing missing endpoints, strengthening backend validation to match contract standards, and integrating frontend with real API.

**Current State**: Backend 80% (missing registration, password reset), Frontend 80% (using mock data), Integration 0%  
**Target State**: Full authentication system with strict validation matching JSON contracts

---

## Technical Context

**Language/Version**: 
- Backend: C# / .NET 9.0
- Frontend: TypeScript / React 19.1

**Primary Dependencies**: 
- Backend: ASP.NET Core 9.0, Entity Framework Core 9.0, BCrypt 4.0, JWT Bearer Authentication 9.0, MediatR 12.4, FluentValidation 11.9
- Frontend: React 19.1, React Router 7.9, Vite 7.1, Tailwind CSS 3.4

**Storage**: SQL Server / PostgreSQL (via Entity Framework Core)

**Testing**: 
- Backend: xUnit, Moq, WebApplicationFactory (integration tests)
- Frontend: Vitest, React Testing Library

**Target Platform**: 
- Backend: Linux/Windows server, Docker containers
- Frontend: Modern browsers (Chrome 90+, Firefox 88+, Safari 14+)

**Project Type**: Web application (separate frontend/backend repositories)

**Performance Goals**: 
- Login response time: <500ms (p95)
- Registration: <1 second (p95)
- JWT validation: <50ms
- Support 10,000 concurrent authenticated users

**Constraints**: 
- JWT tokens expire after 24 hours (no server-side token storage/blacklist in v1)
- Passwords must meet complexity requirements (8+ chars, upper, lower, number, special)
- Email addresses must be unique (case-insensitive)
- HTTPS required in production

**Scale/Scope**: 
- Expected users: 10,000+ registered users
- Concurrent sessions: 1,000-10,000
- Authentication requests: 100 req/sec peak

---

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ Specification-First Development
- [x] Feature fully specified in spec.md before implementation
- [x] Requirements documented with acceptance criteria
- [x] Success criteria defined and measurable
- **Status**: PASS - Comprehensive specification exists

### ✅ Test-Driven Development
- [x] Unit tests required for all services (AuthService, UserService)
- [x] Integration tests required for API endpoints (Login, Logout, Register)
- [x] Frontend component tests for auth pages (Login.tsx, Register.tsx)
- [ ] Tests written before completing missing features (Registration, Password Reset)
- **Status**: PASS with condition - Tests must be written for new features

### ✅ Security & Privacy by Design
- [x] JWT authentication with HMAC-SHA256
- [x] BCrypt password hashing implemented
- [x] Case-insensitive email lookup (prevents timing attacks)
- [x] Generic error messages (prevents user enumeration)
- [ ] Rate limiting not yet implemented (planned)
- [ ] Backend DTO validation needs strengthening
- **Status**: PASS with improvements needed - Core security in place, validation gaps to address

### ⚠️ API Design Principles
- [x] RESTful endpoints following conventions
- [x] Proper HTTP status codes (200, 400, 401, 404)
- [ ] Backend DTOs allow nullable fields that should be required
- **Violation**: Backend Swagger shows `nullable: true` for critical fields (email, password, token, displayName)
- **Justification**: Current implementation works but lacks strict validation
- **Mitigation**: Phase 1 will add `[Required]` attributes to C# DTOs

### Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Backend DTOs too permissive | Current implementation already deployed | Could require all fields, but need backward compatibility during migration |

**Decision**: Update DTOs with proper validation attributes in Phase 1. No breaking API changes since validation was always intended.

---

## Project Structure

### Documentation (this feature)

```text
specs/001-user-authentication/
├── spec.md                 # ✅ Business specification (complete)
├── plan.md                 # This file (implementation plan)
├── data-model.md           # To be created in Phase 1
├── quickstart.md           # To be created in Phase 1
├── contracts/              # ✅ JSON schemas (complete)
│   ├── login-request.json
│   ├── login-response.json
│   ├── user.json
│   └── user-basic.json
├── checklists/
│   └── requirements.md     # ✅ Quality validation (passed)
└── tasks.md                # To be created with /speckit.tasks command
```

### Source Code (existing repositories)

**Backend**: `ae-infinity-api/`
```text
src/
├── AeInfinity.Api/
│   ├── Controllers/
│   │   ├── AuthController.cs          # ✅ Login, Logout (complete)
│   │   └── UsersController.cs         # ✅ Get current user (complete)
│   └── Program.cs                     # ✅ JWT configuration
│
├── AeInfinity.Application/
│   ├── Features/
│   │   ├── Auth/
│   │   │   ├── Login/
│   │   │   │   ├── LoginCommand.cs    # ✅ Complete
│   │   │   │   └── LoginHandler.cs    # ✅ Complete
│   │   │   ├── Logout/
│   │   │   │   ├── LogoutCommand.cs   # ✅ Complete
│   │   │   │   └── LogoutHandler.cs   # ✅ Complete
│   │   │   ├── Register/              # ❌ MISSING - Phase 2
│   │   │   ├── ForgotPassword/        # ❌ MISSING - Phase 2
│   │   │   └── ResetPassword/         # ❌ MISSING - Phase 2
│   │   └── Users/
│   │       ├── GetCurrentUser/
│   │       │   ├── GetCurrentUserQuery.cs   # ✅ Complete
│   │       │   └── GetCurrentUserHandler.cs # ✅ Complete
│   │       ├── UpdateProfile/         # ❌ MISSING - Phase 2
│   │       └── ChangePassword/        # ❌ MISSING - Phase 2
│   └── DTOs/
│       ├── LoginRequest.cs            # ⚠️ Needs validation attributes
│       ├── LoginResponse.cs           # ⚠️ Needs validation attributes
│       ├── UserDto.cs                 # ⚠️ Needs validation attributes
│       └── UserBasicDto.cs            # ⚠️ Needs validation attributes
│
├── AeInfinity.Core/
│   ├── Entities/
│   │   └── User.cs                    # ✅ Complete
│   └── Interfaces/
│       └── IAuthService.cs            # ✅ Complete
│
└── AeInfinity.Infrastructure/
    ├── Data/
    │   ├── AppDbContext.cs            # ✅ Complete
    │   └── Repositories/
    │       └── UserRepository.cs      # ✅ Complete
    └── Services/
        └── JwtTokenService.cs         # ✅ Complete

tests/
├── AeInfinity.Application.Tests/
│   ├── Auth/
│   │   ├── LoginHandlerTests.cs       # ✅ Exists
│   │   ├── RegisterHandlerTests.cs    # ❌ MISSING - Phase 2
│   │   └── PasswordResetTests.cs      # ❌ MISSING - Phase 2
│   └── Users/
│       └── GetCurrentUserTests.cs     # ✅ Exists
│
└── AeInfinity.Api.IntegrationTests/
    ├── AuthControllerTests.cs         # ✅ Exists (login/logout)
    └── UsersControllerTests.cs        # ✅ Exists (get current user)
```

**Frontend**: `ae-infinity-ui/`
```text
src/
├── components/
│   └── layout/
│       ├── Header.tsx                 # ✅ Uses auth context
│       └── Sidebar.tsx                # ✅ Uses auth context
│
├── contexts/
│   └── AuthContext.tsx                # ⚠️ Using mock data - Phase 2 integration
│
├── hooks/
│   └── useAuth.ts                     # ✅ Hook wrapper
│
├── pages/
│   ├── auth/
│   │   ├── Login.tsx                  # ✅ UI complete, needs API integration
│   │   ├── Register.tsx               # ✅ UI complete, needs API integration
│   │   └── ForgotPassword.tsx         # ✅ UI complete, needs API integration
│   └── profile/
│       ├── Profile.tsx                # ✅ UI complete, needs API integration
│       ├── ProfileSettings.tsx        # ✅ UI complete, needs API integration
│       └── NotificationSettings.tsx   # ✅ UI complete
│
├── services/
│   └── authService.ts                 # ✅ All methods implemented
│
├── types/
│   └── index.ts                       # ✅ Auth types defined
│
└── utils/
    └── apiClient.ts                   # ✅ JWT token management

tests/
├── components/
│   └── auth/
│       ├── Login.test.tsx             # ❌ MISSING - Phase 2
│       └── Register.test.tsx          # ❌ MISSING - Phase 2
└── services/
    └── authService.test.ts            # ❌ MISSING - Phase 2
```

**Structure Decision**: Using separate backend/frontend repositories (web application pattern). Backend follows Clean Architecture with CQRS pattern. Frontend uses React with Context API for state management.

---

## Implementation Phases

### Phase 0: Current State Analysis & Planning ✅

**Status**: COMPLETE

**What Exists**:
1. ✅ Backend: Login, Logout, Get Current User endpoints
2. ✅ Backend: JWT token generation/validation
3. ✅ Backend: BCrypt password hashing
4. ✅ Backend: User entity with all fields
5. ✅ Frontend: All UI pages (Login, Register, ForgotPassword, Profile)
6. ✅ Frontend: AuthService with all API methods
7. ✅ Frontend: AuthContext structure (using mock data)
8. ✅ Contracts: JSON schemas for all DTOs

**What's Missing**:
1. ❌ Backend: Registration endpoint
2. ❌ Backend: Password reset flow (request + reset endpoints)
3. ❌ Backend: Email verification
4. ❌ Backend: Profile update endpoints
5. ❌ Backend: Proper DTO validation attributes
6. ❌ Frontend: AuthContext connected to real API
7. ❌ Integration: Frontend-to-backend wiring
8. ❌ Tests: Missing tests for new features

---

### Phase 1: Backend DTO Validation Strengthening

**Goal**: Update C# DTOs to match strict JSON contract validation

**Tasks**:

1. **Update LoginRequest.cs**
```csharp
public class LoginRequest
{
    [Required(ErrorMessage = "Email is required")]
    [EmailAddress(ErrorMessage = "Invalid email format")]
    public string Email { get; set; } = null!;

    [Required(ErrorMessage = "Password is required")]
    [MinLength(1, ErrorMessage = "Password cannot be empty")]
    public string Password { get; set; } = null!;
}
```

2. **Update LoginResponse.cs**
```csharp
public class LoginResponse
{
    [Required]
    public string Token { get; set; } = null!;

    [Required]
    public DateTime ExpiresAt { get; set; }

    [Required]
    public UserDto User { get; set; } = null!;
}
```

3. **Update UserDto.cs**
```csharp
public class UserDto
{
    [Required]
    public Guid Id { get; set; }

    [Required]
    [EmailAddress]
    public string Email { get; set; } = null!;

    [Required]
    [MinLength(2)]
    [MaxLength(100)]
    public string DisplayName { get; set; } = null!;

    [Url]
    public string? AvatarUrl { get; set; }

    [Required]
    public bool IsEmailVerified { get; set; }

    public DateTime? LastLoginAt { get; set; }

    [Required]
    public DateTime CreatedAt { get; set; }
}
```

4. **Update UserBasicDto.cs**
```csharp
public class UserBasicDto
{
    [Required]
    public Guid Id { get; set; }

    [Required]
    [MinLength(1)]
    public string DisplayName { get; set; } = null!;

    [Url]
    public string? AvatarUrl { get; set; }
}
```

5. **Enable FluentValidation** (if not already configured)
   - Ensure `services.AddControllers().AddFluentValidation()` in Program.cs
   - Validation errors automatically return 400 with details

**Testing**:
- Unit test each DTO with invalid data
- Integration test endpoints reject invalid requests
- Verify error messages are clear

**Output**: All DTOs match JSON contract strictness

---

### Phase 2: Complete Missing Backend Features

**Goal**: Implement registration, password reset, and profile management

#### 2.1 User Registration

**Create**:
```text
AeInfinity.Application/Features/Auth/Register/
├── RegisterCommand.cs
├── RegisterHandler.cs
├── RegisterValidator.cs (FluentValidation)
└── RegisterRequest.cs (DTO)
```

**Implementation**:
1. Validate email uniqueness (case-insensitive)
2. Hash password with BCrypt
3. Create user entity
4. Generate JWT token
5. Return LoginResponse (auto-login)
6. Update `lastLoginAt` timestamp

**Tests**:
- Unit: RegisterHandler with valid/invalid data
- Unit: Email uniqueness validation
- Unit: Password hashing verification
- Integration: POST /api/auth/register endpoint

#### 2.2 Password Reset Flow

**Create**:
```text
AeInfinity.Application/Features/Auth/ForgotPassword/
├── ForgotPasswordCommand.cs
├── ForgotPasswordHandler.cs
└── ForgotPasswordRequest.cs

AeInfinity.Application/Features/Auth/ResetPassword/
├── ResetPasswordCommand.cs
├── ResetPasswordHandler.cs
└── ResetPasswordRequest.cs

AeInfinity.Core/Entities/
└── PasswordResetToken.cs (new entity)
```

**Implementation**:
1. **ForgotPassword**: Generate unique token, save with 1hr expiration, send email
2. **ResetPassword**: Validate token, check expiration, hash new password, invalidate token
3. Add email service interface + mock implementation
4. Add PasswordResetToken repository

**Tests**:
- Unit: Token generation and validation
- Unit: Token expiration check
- Unit: Password update flow
- Integration: POST /api/auth/forgot-password
- Integration: POST /api/auth/reset-password

#### 2.3 Profile Management

**Create**:
```text
AeInfinity.Application/Features/Users/UpdateProfile/
├── UpdateProfileCommand.cs
├── UpdateProfileHandler.cs
└── UpdateProfileRequest.cs

AeInfinity.Application/Features/Users/ChangePassword/
├── ChangePasswordCommand.cs
├── ChangePasswordHandler.cs
└── ChangePasswordRequest.cs
```

**Implementation**:
1. **UpdateProfile**: Update displayName, avatarUrl
2. **ChangePassword**: Verify current password, hash and save new password
3. Both require authentication (extract user from JWT)

**Tests**:
- Unit: Profile update logic
- Unit: Password change with verification
- Integration: PUT /api/users/me
- Integration: POST /api/users/me/password

**Output**: All missing backend endpoints implemented and tested

---

### Phase 3: Frontend Integration

**Goal**: Connect frontend AuthContext to real backend API

#### 3.1 Update AuthContext

**File**: `src/contexts/AuthContext.tsx`

**Changes**:
```typescript
// BEFORE: Mock implementation
const login = async (email: string, password: string) => {
  // Mock localStorage logic
};

// AFTER: Real API integration
const login = async (email: string, password: string) => {
  try {
    const response = await authService.login(email, password);
    setUser(response.user);
    setIsAuthenticated(true);
    // Token already stored by authService
  } catch (error) {
    throw error; // Let UI handle error display
  }
};
```

**Implement**:
1. Replace all mock functions with authService calls
2. Add token expiration handling (401 → logout + redirect)
3. Load user on app mount with `authService.getCurrentUser()`
4. Clear user state on logout
5. Handle network errors gracefully

#### 3.2 Add Error Handling

**Create**: `src/hooks/useAuthErrors.ts`

**Features**:
- Map API errors to user-friendly messages
- Handle 401 (expired token → redirect to login)
- Handle 400 (validation errors → show field-specific messages)
- Handle network errors (show retry option)

#### 3.3 Add Loading States

**Update**: All auth pages to show loading spinners during API calls

**Pattern**:
```typescript
const [isLoading, setIsLoading] = useState(false);
const [error, setError] = useState<string | null>(null);

const handleLogin = async () => {
  setIsLoading(true);
  setError(null);
  try {
    await login(email, password);
    navigate('/lists');
  } catch (err) {
    setError(err.message);
  } finally {
    setIsLoading(false);
  }
};
```

**Testing**:
- Component tests with mocked authService
- Test loading states
- Test error handling
- Test successful flows

**Output**: Frontend fully integrated with backend API

---

### Phase 4: End-to-End Testing

**Goal**: Verify complete authentication flows work correctly

**Test Scenarios**:

1. **Complete Registration Flow**
   - Submit registration form
   - Verify account created in database
   - Verify auto-login works
   - Verify redirected to dashboard

2. **Complete Login Flow**
   - Enter valid credentials
   - Verify JWT token received and stored
   - Verify redirected to dashboard
   - Verify protected routes accessible

3. **Complete Logout Flow**
   - Click logout button
   - Verify token cleared from storage
   - Verify redirected to landing page
   - Verify protected routes inaccessible

4. **Token Expiration Flow**
   - Login successfully
   - Manually expire token (set time to 25 hours ago)
   - Make API request
   - Verify 401 response
   - Verify redirected to login
   - Verify return URL preserved

5. **Password Reset Flow**
   - Request password reset
   - Verify email sent (mock)
   - Click reset link
   - Enter new password
   - Verify password updated
   - Verify auto-login works

**Tools**:
- Playwright or Cypress for E2E tests
- Real database (test instance)
- Mock email service

**Output**: All user stories validated end-to-end

---

## Data Model

See [data-model.md](./data-model.md) (to be created with detailed entity definitions)

**Summary**:
- **User**: Main entity with email, displayName, passwordHash, etc.
- **PasswordResetToken**: Token tracking for password resets
- **JWT Token**: Stateless (not stored in database)

---

## Security Considerations

### Already Implemented ✅
- BCrypt password hashing with automatic salts
- JWT tokens with HMAC-SHA256
- 24-hour token expiration
- Case-insensitive email lookup (normalized field)
- Generic error messages for failed authentication
- Audit logging for login/logout

### To Be Implemented ⚠️
- Rate limiting (5 login attempts/min per IP)
- Email verification flow
- Token refresh mechanism (future enhancement)
- HTTPS enforcement in production
- CSP headers configuration
- Server-side token blacklist (future enhancement)

---

## Deployment Plan

### Phase 2 Deployment (Backend Updates)
1. Deploy DTO validation updates (non-breaking)
2. Deploy new endpoints (registration, password reset)
3. Run database migrations (if needed for PasswordResetToken)
4. Verify backward compatibility

### Phase 3 Deployment (Frontend Integration)
1. Deploy frontend with environment variable pointing to backend
2. Enable feature flag for real API (if using flags)
3. Monitor for errors
4. Gradual rollout (10% → 50% → 100%)

### Rollback Plan
- Frontend: Revert to mock data implementation
- Backend: Previous container image
- Database: No schema changes expected (additive only)

---

## Success Metrics

Track these metrics post-deployment:

- **Login Success Rate**: Target >95%
- **Registration Completion Rate**: Target >80%
- **Average Login Time**: Target <500ms
- **Authentication Errors**: Target <5% of requests
- **Token Expiration Handling**: Zero crashes, clean redirects

---

## Next Steps

1. ✅ **Phase 0**: Complete (current state analysis)
2. **Phase 1**: Update backend DTOs with validation attributes
3. **Phase 2**: Implement missing backend features (registration, password reset)
4. **Phase 3**: Integrate frontend with real API
5. **Phase 4**: End-to-end testing
6. **Use** `/speckit.tasks` to generate detailed implementation checklist

---

**Ready for**: Task breakdown - use `/speckit.tasks` command to generate implementation checklist

