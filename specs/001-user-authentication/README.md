# Feature: User Authentication

**Feature ID**: 001-user-authentication  
**Created**: 2025-11-05  
**Status**: Specification Complete, Ready for Planning  
**Implementation**: Backend 80%, Frontend 80%, Integration 0%

---

## Overview

Core authentication and session management for the AE Infinity shopping list application. Users can register, login, logout, and manage their profiles using JWT-based authentication with secure password hashing.

---

## Quick Links

| Document | Purpose | Status |
|----------|---------|--------|
| **[spec.md](./spec.md)** | Business requirements, user scenarios, success criteria | ✅ Complete |
| **[checklists/requirements.md](./checklists/requirements.md)** | Specification quality validation | ✅ Passed |
| **[contracts/](./contracts/)** | JSON schemas for API contracts | ✅ Complete |
| **plan.md** | Technical implementation plan | ⏳ Not yet created (use `/speckit.plan`) |
| **data-model.md** | Entity definitions and relationships | ⏳ Not yet created (use `/speckit.plan`) |
| **tasks.md** | Implementation task breakdown | ⏳ Not yet created (use `/speckit.tasks`) |

---

## Key Capabilities

### ✅ Implemented (Backend)
- JWT token generation and validation (HMAC-SHA256, 24hr expiration)
- User login with BCrypt password verification
- User logout with audit logging
- Get current user info endpoint
- Case-insensitive email lookup
- Security: Generic error messages, normalized emails, audit trail

### ❌ Missing (Backend)
- User registration endpoint
- Password reset flow (request + reset)
- Email verification
- Token refresh mechanism
- Profile update endpoints

### ✅ Implemented (Frontend)
- Login page with validation
- Registration page with password strength indicator
- Forgot password page
- Profile viewing and settings pages
- AuthService with all methods ready
- JWT token storage in localStorage

### ❌ Missing (Frontend)
- AuthContext integration with real API (currently using mock)
- Token expiration handling and auto-refresh
- Real-time validation feedback

---

## User Stories

1. **User Login** (P1) - Authenticate with email/password, receive JWT token
2. **User Registration** (P1) - Create new account with validated credentials
3. **User Logout** (P1) - Securely end session and clear token
4. **Password Reset** (P2) - Recover account via email verification
5. **Get Current User** (P1) - Retrieve authenticated user profile
6. **Email Verification** (P3) - Verify email ownership for security

---

## Success Metrics

- Login completes in <5 seconds
- Registration completes in <2 minutes
- 95% of auth requests complete in <500ms
- Zero plaintext passwords (100% BCrypt)
- 100% of protected endpoints require valid JWT
- Token expiration enforced at 24 hours

---

## API Contracts

### Endpoints

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| POST | `/auth/login` | Authenticate user, return JWT | ✅ Implemented |
| POST | `/auth/logout` | End session (audit log) | ✅ Implemented |
| POST | `/auth/register` | Create new user account | ❌ Missing |
| POST | `/auth/forgot-password` | Request password reset | ❌ Missing |
| POST | `/auth/reset-password` | Reset password with token | ❌ Missing |
| POST | `/auth/verify-email` | Verify email address | ❌ Missing |
| GET | `/users/me` | Get current user profile | ✅ Implemented |
| PUT | `/users/me` | Update user profile | ❌ Missing |
| POST | `/users/me/password` | Change password | ❌ Missing |

### Schemas

See `contracts/` directory:
- `login-request.json` - Login credentials
- `login-response.json` - JWT token + user data
- `user.json` - Complete user profile
- `user-basic.json` - Minimal user reference

---

## Dependencies

**Depends on**: None (foundational feature)  
**Required by**: All other features (003-shopping-lists-crud, 004-shopping-items-management, etc.)

---

## Tech Stack

**Backend**:
- .NET 8 Web API
- JWT Bearer authentication (Microsoft.IdentityModel.Tokens)
- BCrypt.Net-Next for password hashing
- Entity Framework Core for data access
- SQL Server / PostgreSQL database

**Frontend**:
- React 19 + TypeScript
- Vite build tool
- Context API for auth state
- React Router for navigation
- Tailwind CSS for styling

---

## Security Considerations

- **Password Hashing**: BCrypt with automatic salts
- **JWT Algorithm**: HMAC-SHA256 (HS256)
- **Token Expiration**: 24 hours
- **Email Lookup**: Case-insensitive (normalized field)
- **Error Messages**: Generic for failed auth (prevent enumeration)
- **Rate Limiting**: Planned (5 login/min, 3 register/hour, 3 reset/hour)
- **Transport**: HTTPS required in production

---

## Test Data (Development)

Seeded users for testing:
- **sarah@example.com** / Password123!
- **alex@example.com** / Password123!
- **mike@example.com** / Password123!

---

## Next Steps

1. **Run** `/speckit.plan` to generate implementation plan
2. **Complete** missing backend endpoints (registration, password reset)
3. **Update** AuthContext to use real authService
4. **Test** end-to-end authentication flow
5. **Integrate** with other features (lists, items, collaboration)

---

## Related Documentation

- **Constitution**: [/.specify/memory/constitution.md](../../.specify/memory/constitution.md)
- **Old Documentation**: [/old_documents/features/authentication/](../../old_documents/features/authentication/)
- **API Spec**: [/old_documents/API_SPEC.md](../../old_documents/API_SPEC.md) (lines 26-115)
- **Architecture**: [/old_documents/ARCHITECTURE.md](../../old_documents/ARCHITECTURE.md) (security section)
- **Personas**: [/old_documents/personas/](../../old_documents/personas/)

---

**Ready for**: Planning phase - use `/speckit.plan` command to generate technical implementation plan

