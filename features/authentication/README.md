# Authentication & User Management

**Feature Domain**: Authentication & User Management  
**Version**: 1.0  
**Status**: 80% Backend, 80% Frontend, 0% Integrated

---

## Overview

This feature domain covers all user authentication, authorization, and user profile management functionality.

---

## Features

### 🔐 Core Authentication

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| User Login | POST `/auth/login` | ✅ | 🟡 Mock | Ready for Integration |
| User Logout | POST `/auth/logout` | ✅ | 🟡 Mock | Ready for Integration |
| Get Current User | GET `/users/me` | ✅ | 🟡 Service Ready | Ready for Integration |
| JWT Token Management | - | ✅ | ✅ | Ready for Integration |

### 🚧 Not Yet Implemented

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| User Registration | POST `/auth/register` | ❌ | 🟡 UI Ready | Blocked by Backend |
| Refresh Token | POST `/auth/refresh` | ❌ | 🟡 Service Ready | Blocked by Backend |
| Password Reset Request | POST `/auth/forgot-password` | ❌ | ✅ UI Only | Blocked by Backend |
| Password Reset | POST `/auth/reset-password` | ❌ | ❌ | Not Started |
| Email Verification | POST `/auth/verify-email` | ❌ | ❌ | Not Started |

### 👤 User Profile

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| View Profile | GET `/users/me` | ✅ | ✅ | Ready for Integration |
| Update Profile | PUT `/users/me` | ❌ | ✅ UI Complete | Blocked by Backend |
| Change Password | POST `/users/me/password` | ❌ | ✅ UI Complete | Blocked by Backend |
| Upload Avatar | POST `/users/me/avatar` | ❌ | 🟡 UI Placeholder | Blocked by Backend |

---

## API Specification

See [API_SPEC.md](../../API_SPEC.md) sections:
- Lines 26-88: Authentication endpoints
- Lines 92-115: User profile endpoints

---

## Frontend Implementation

### Pages
- **Location**: `ae-infinity-ui/src/pages/auth/`
  - `Login.tsx` ✅ - Email/password form with validation
  - `Register.tsx` ✅ - Registration form with password strength indicator
  - `ForgotPassword.tsx` ✅ - Password reset request form

- **Location**: `ae-infinity-ui/src/pages/profile/`
  - `Profile.tsx` ✅ - User profile display
  - `ProfileSettings.tsx` ✅ - Edit profile and change password
  - `NotificationSettings.tsx` ✅ - Notification preferences

### Services
- **Location**: `ae-infinity-ui/src/services/authService.ts`
  - All auth methods implemented and ready
  - Currently using mock localStorage for development

### Context
- **Location**: `ae-infinity-ui/src/contexts/AuthContext.tsx`
  - Global auth state management
  - Login/logout functions
  - User state persistence
  - **Needs**: Replace mock with real authService calls

---

## Backend Implementation

### Controllers
- **Location**: `ae-infinity-api/src/AeInfinity.Api/Controllers/`
  - `AuthController.cs` ✅ - Login, logout endpoints
  - `UsersController.cs` ✅ - Get current user endpoint

### Features (CQRS)
- **Location**: `ae-infinity-api/src/AeInfinity.Application/Features/Auth/`
  - Login command ✅
  - Logout command ✅
  - **Missing**: Register, password reset, email verification

- **Location**: `ae-infinity-api/src/AeInfinity.Application/Features/Users/`
  - Get current user query ✅
  - **Missing**: Update user, change password

---

## Data Models

### User Entity

```csharp
public class User : BaseAuditableEntity
{
    public string Email { get; set; }
    public string DisplayName { get; set; }
    public string PasswordHash { get; set; }
    public string? AvatarUrl { get; set; }
    public bool IsEmailVerified { get; set; }
    public DateTime? LastLoginAt { get; set; }
}
```

### TypeScript Types

```typescript
interface User {
  id: string
  email: string
  displayName: string
  avatarUrl: string | null
  isEmailVerified: boolean
  lastLoginAt: string | null
  createdAt: string
}

interface AuthResponse {
  token: string
  expiresAt: string
  user: User
}
```

---

## Integration Steps

### 1. Complete Missing Backend Endpoints
- [ ] Implement `POST /auth/register`
- [ ] Implement `POST /auth/refresh`
- [ ] Implement `POST /auth/forgot-password`
- [ ] Implement `POST /auth/reset-password`
- [ ] Implement `PUT /users/me`
- [ ] Implement `POST /users/me/password`

### 2. Update Frontend AuthContext
- [ ] Replace `localStorage` mock with `authService.login()`
- [ ] Store token from API response
- [ ] Implement token refresh logic
- [ ] Handle token expiration (401 responses)
- [ ] Fetch user on app load with `authService.getCurrentUser()`

### 3. Test Authentication Flow
- [ ] Test login with real credentials
- [ ] Test logout clears token
- [ ] Test protected routes redirect to login
- [ ] Test token expiration handling
- [ ] Test registration flow
- [ ] Test password reset flow

---

## User Stories

### Login
```
As a user
I want to log in with my email and password
So that I can access my shopping lists
```

**Acceptance Criteria**:
- Email and password fields with validation
- "Remember me" option
- Error messages for invalid credentials
- Redirect to lists page on success
- Link to registration and password reset

### Registration
```
As a new user
I want to create an account
So that I can start creating shopping lists
```

**Acceptance Criteria**:
- Email, display name, and password fields
- Password strength indicator
- Email format validation
- Duplicate email detection
- Automatic login after registration
- Email verification (optional)

### Profile Management
```
As a logged-in user
I want to update my profile information
So that my account reflects my current details
```

**Acceptance Criteria**:
- View current profile information
- Edit display name
- Upload/change avatar image
- Change password with current password verification
- Save changes with confirmation
- Handle validation errors

---

## Security Considerations

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character

### JWT Tokens
- **Algorithm**: HMAC-SHA256 (HS256)
- **Expiration**: 24 hours
- **Refresh**: Support token refresh before expiration
- **Storage**: localStorage (consider httpOnly cookies for production)

### Rate Limiting
- Login attempts: 5 per minute per IP
- Registration: 3 per hour per IP
- Password reset: 3 per hour per email

---

## Dependencies

### Backend
- ASP.NET Core Identity (or custom)
- JWT Bearer authentication
- BCrypt for password hashing
- Email service for verification/reset

### Frontend
- React Context API for state
- React Router for navigation
- Form validation library (or custom)

---

## Test Credentials (Development)

From backend seed data:
- **User 1**: sarah@example.com / Password123!
- **User 2**: alex@example.com / Password123!
- **User 3**: mike@example.com / Password123!

---

## Next Steps

1. **Priority 1**: Implement registration endpoint
2. **Priority 2**: Connect frontend AuthContext to real API
3. **Priority 3**: Implement password reset flow
4. **Priority 4**: Add email verification
5. **Priority 5**: Implement profile update endpoints

---

## Related Documentation

- [API_SPEC.md](../../API_SPEC.md) - Complete API specification
- [ARCHITECTURE.md](../../ARCHITECTURE.md) - System architecture
- [User Personas](../../personas/) - User types and needs

