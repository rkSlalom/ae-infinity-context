# Implementation Tasks: User Authentication

**Feature**: 001-user-authentication  
**Branch**: `001-user-authentication`  
**Created**: 2025-11-05  
**Current Status**: Backend 80%, Frontend 80%, Integration 0%  
**Target**: Complete MVP authentication system with strict validation

---

## Task Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| Phase 1: Setup | 3 tasks | Environment configuration |
| Phase 2: Foundation | 4 tasks | DTO validation strengthening |
| Phase 3: US1 - Login | 5 tasks | Complete login flow with testing |
| Phase 4: US5 - Get User | 3 tasks | Complete current user endpoint |
| Phase 5: US2 - Registration | 9 tasks | Implement registration flow |
| Phase 6: US3 - Logout | 2 tasks | Verify logout functionality |
| Phase 7: US4 - Password Reset | 10 tasks | Implement password reset flow (P2) |
| Phase 8: Integration | 7 tasks | Connect frontend to real API |
| Phase 9: Polish | 6 tasks | Cross-cutting concerns |
| **Total** | **49 tasks** | Estimated: 6-8 days |

---

## Implementation Strategy

### MVP Scope (Days 1-3)
Complete **P1 user stories** only:
- ✅ User Story 1: Login (mostly complete, needs tests)
- ✅ User Story 5: Get Current User (complete)
- 🔨 User Story 2: Registration (needs backend + tests)
- ✅ User Story 3: Logout (complete, needs verification)

**MVP Deliverable**: Users can register, login, logout, and access protected pages.

### Phase 2 Scope (Days 4-5)
Add **P2 user story**:
- 🔨 User Story 4: Password Reset (needs full implementation)

### Optional Scope (Day 6+)
- 📋 User Story 6: Email Verification (P3 - deferrable)
- 📋 Rate limiting implementation
- 📋 Advanced monitoring

---

## Dependency Graph

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundation - DTOs) ← BLOCKING for all user stories
    ↓
    ├── Phase 3 (US1 - Login) [PARALLEL]
    ├── Phase 4 (US5 - Get User) [PARALLEL]
    ├── Phase 5 (US2 - Registration) [PARALLEL]
    └── Phase 6 (US3 - Logout) [PARALLEL]
    ↓
Phase 7 (US4 - Password Reset) ← Can start once US2 complete
    ↓
Phase 8 (Integration) ← Needs US1, US2, US5 complete
    ↓
Phase 9 (Polish)
```

**Key Dependencies**:
- Phase 2 MUST complete before any user story work
- US1, US5, US2, US3 can be implemented in parallel after Phase 2
- US4 (Password Reset) depends on US2 (uses similar registration patterns)
- Integration phase needs US1, US2, US5 complete
- All user stories are independently testable

---

## Phase 1: Setup & Prerequisites

**Goal**: Configure development environment and verify existing infrastructure

**Duration**: 30 minutes

### Tasks

- [ ] T001 Verify .NET 9.0 SDK installed and ae-infinity-api solution builds successfully
- [ ] T002 Verify Node.js 18+ and npm installed, ae-infinity-ui project builds and runs
- [ ] T003 [P] Review existing JWT configuration in ae-infinity-api/AeInfinity.API/Program.cs and verify authentication middleware order

---

## Phase 2: Foundation - DTO Validation Strengthening

**Goal**: Fix validation gaps in existing DTOs to match contract specifications

**Why**: Current Swagger shows `nullable: true` for critical fields. Must strengthen validation before implementing new features.

**Duration**: 1-2 hours

### Tasks

- [ ] T004 [P] Add [Required] attributes to LoginRequestDto in ae-infinity-api/AeInfinity.Application/DTOs/LoginRequestDto.cs
- [ ] T005 [P] Add [Required] attributes to LoginResponseDto in ae-infinity-api/AeInfinity.Application/DTOs/LoginResponseDto.cs  
- [ ] T006 [P] Add [Required] attributes to UserDto in ae-infinity-api/AeInfinity.Application/DTOs/UserDto.cs
- [ ] T007 [P] Add [Required] attributes to UserBasicDto in ae-infinity-api/AeInfinity.Application/DTOs/UserBasicDto.cs

**Validation**: Run backend, check Swagger at http://localhost:5233/index.html - all critical fields should show `nullable: false`

---

## Phase 3: US1 - User Login *(Priority: P1)*

**User Story**: A returning user wants to access their shopping lists by logging in with their email and password.

**Current Status**: Backend ✅ Complete, Frontend ✅ Complete, Tests ❌ Missing

**Independent Test**: Provide valid credentials, receive JWT token, access /lists endpoint successfully.

**Duration**: 2-3 hours

### Tasks

#### Backend Tests

- [ ] T008 [P] [US1] Write unit tests for LoginHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Auth/LoginHandlerTests.cs (test valid login, invalid credentials, missing fields)

- [ ] T009 [P] [US1] Write integration test for POST /auth/login in ae-infinity-api/tests/AeInfinity.API.IntegrationTests/AuthControllerTests.cs (test 200 success, 401 invalid, 400 validation)

#### Frontend Tests

- [ ] T010 [P] [US1] Write component tests for Login.tsx in ae-infinity-ui/tests/components/auth/Login.test.tsx (test form submission, validation, error display)

#### Verification

- [ ] T011 [US1] Manual test: Login with valid credentials, verify JWT token returned and stored in localStorage

- [ ] T012 [US1] Manual test: Login with invalid credentials, verify generic error message "Invalid email or password" displayed

**Acceptance Criteria** (from spec.md):
- ✅ Valid credentials return JWT token valid for 24 hours
- ✅ Invalid credentials show generic error (no user enumeration)
- ✅ Token included in Authorization header for protected requests
- ✅ "Remember me" persists session in localStorage
- ✅ Expired tokens trigger 401 and redirect to login

---

## Phase 4: US5 - Get Current User Info *(Priority: P1)*

**User Story**: The application needs to retrieve the currently authenticated user's profile information.

**Current Status**: Backend ✅ Complete, Frontend ✅ Complete, Tests ❌ Missing

**Independent Test**: Make authenticated GET /users/me request, receive complete user profile with id, email, displayName, avatarUrl, timestamps.

**Duration**: 1 hour

### Tasks

#### Backend Tests

- [ ] T013 [P] [US5] Write unit tests for GetCurrentUserHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Users/GetCurrentUserHandlerTests.cs (test valid token, expired token, user not found)

- [ ] T014 [P] [US5] Write integration test for GET /users/me in ae-infinity-api/tests/AeInfinity.API.IntegrationTests/UsersControllerTests.cs (test 200 success, 401 no token, 404 user deleted)

#### Verification

- [ ] T015 [US5] Manual test: Access /users/me with valid JWT, verify full user profile returned (excluding passwordHash)

**Acceptance Criteria** (from spec.md):
- ✅ Authenticated request returns full user profile
- ✅ User ID extracted from JWT claims (sub)
- ✅ Invalid/expired token returns 401 Unauthorized
- ✅ User profile displays in Header component

---

## Phase 5: US2 - User Registration *(Priority: P1)*

**User Story**: A new user wants to create an account to start managing shopping lists.

**Current Status**: Backend ❌ Missing, Frontend ✅ UI Complete, Tests ❌ Missing

**Independent Test**: Submit registration form with unique email, valid password, and display name. Verify account created in database and user automatically logged in with JWT token.

**Duration**: 4-5 hours

### Tasks

#### Backend Implementation

- [ ] T016 [US2] Create RegisterCommand.cs in ae-infinity-api/AeInfinity.Application/Features/Auth/Register/RegisterCommand.cs (properties: Email, Password, DisplayName)

- [ ] T017 [US2] Create RegisterCommandValidator.cs using FluentValidation in ae-infinity-api/AeInfinity.Application/Features/Auth/Register/RegisterCommandValidator.cs (validate email format, password complexity, displayName length)

- [ ] T018 [US2] Create RegisterCommandHandler.cs in ae-infinity-api/AeInfinity.Application/Features/Auth/Register/RegisterCommandHandler.cs (check email uniqueness, hash password with BCrypt, create user, return JWT token)

- [ ] T019 [US2] Create RegisterRequestDto.cs in ae-infinity-api/AeInfinity.Application/DTOs/RegisterRequestDto.cs (Email, Password, DisplayName with [Required] attributes)

- [ ] T020 [US2] Add POST /auth/register endpoint to ae-infinity-api/AeInfinity.API/Controllers/AuthController.cs (map DTO to command, return 201 Created with LoginResponse)

#### Backend Tests

- [ ] T021 [P] [US2] Write unit tests for RegisterHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Auth/RegisterHandlerTests.cs (test unique email, duplicate email, weak password, missing fields)

- [ ] T022 [P] [US2] Write integration test for POST /auth/register in ae-infinity-api/tests/AeInfinity.API.IntegrationTests/AuthControllerTests.cs (test 201 success, 400 duplicate email, 400 validation errors)

#### Password Strength Indicator

- [ ] T021a [US2] Add zxcvbn library to frontend package.json (npm install zxcvbn @types/zxcvbn)

- [ ] T021b [US2] Create passwordStrength utility in ae-infinity-ui/src/utils/passwordStrength.ts wrapping zxcvbn with 4-level scoring (weak/medium/strong/very strong)

- [ ] T021c [US2] Update Register.tsx to display password strength indicator with color-coded bar (red/yellow/green/blue) and debounced calculation (300ms)

#### Frontend Tests

#### Verification

- [ ] T023 [US2] Manual test: Register with unique email, verify account created and automatic login with JWT token

- [ ] T024 [US2] Manual test: Attempt registration with existing email, verify error "Email already registered"

**Acceptance Criteria** (from spec.md):
- ✅ Unique email creates account and auto-logs in user
- ✅ Duplicate email returns error "Email already registered"
- ✅ Weak password shows requirements (8+ chars, upper, lower, number, special)
- ✅ Password hashed with BCrypt before storage
- ✅ Display name validated (2-100 chars)

---

## Phase 6: US3 - User Logout *(Priority: P1)*

**User Story**: A logged-in user wants to securely end their session.

**Current Status**: Backend ✅ Complete, Frontend ✅ Complete, Tests ✅ Exists

**Independent Test**: Log in, then log out. Verify JWT token removed from localStorage and protected pages redirect to login.

**Duration**: 30 minutes

### Tasks

#### Verification

- [ ] T025 [US3] Manual test: Login, logout, attempt to access /lists, verify redirect to login page

- [ ] T026 [US3] Manual test: Verify logout event logged in backend for audit purposes

**Acceptance Criteria** (from spec.md):
- ✅ Logout removes JWT token from localStorage
- ✅ After logout, protected pages redirect to login
- ✅ Logout event logged (token remains valid until expiration - no server-side blacklist)

**Note**: Logout is fully implemented. These tasks are verification only.

---

## Phase 7: US4 - Password Reset Flow *(Priority: P2)*

**User Story**: A user who forgets their password wants to regain access through email verification.

**Current Status**: Backend ❌ Missing, Frontend ✅ UI Complete, Tests ❌ Missing

**Independent Test**: Request password reset for registered email. Verify reset email sent (or token generated). Use token to reset password. Verify login with new password succeeds.

**Duration**: 4-5 hours

### Tasks

#### Backend Implementation - Request Reset

- [ ] T027 [US4] Create ForgotPasswordCommand.cs in ae-infinity-api/AeInfinity.Application/Features/Auth/ForgotPassword/ForgotPasswordCommand.cs (property: Email)

- [ ] T028 [US4] Create ForgotPasswordCommandHandler.cs in ae-infinity-api/AeInfinity.Application/Features/Auth/ForgotPassword/ForgotPasswordCommandHandler.cs (validate email exists, generate reset token, store token+expiry in User entity, return success)

- [ ] T029 [US4] Add POST /auth/forgot-password endpoint to ae-infinity-api/AeInfinity.API/Controllers/AuthController.cs (always return 200 for security, even if email not found)

#### Backend Implementation - Reset Password

- [ ] T030 [US4] Create ResetPasswordCommand.cs in ae-infinity-api/AeInfinity.Application/Features/Auth/ResetPassword/ResetPasswordCommand.cs (properties: Token, NewPassword)

- [ ] T031 [US4] Create ResetPasswordCommandValidator.cs in ae-infinity-api/AeInfinity.Application/Features/Auth/ResetPassword/ResetPasswordCommandValidator.cs (validate password complexity)

- [ ] T032 [US4] Create ResetPasswordCommandHandler.cs in ae-infinity-api/AeInfinity.Application/Features/Auth/ResetPassword/ResetPasswordCommandHandler.cs (validate token exists and not expired, hash new password, clear reset token, return success)

- [ ] T033 [US4] Add POST /auth/reset-password endpoint to ae-infinity-api/AeInfinity.API/Controllers/AuthController.cs (validate token, update password, auto-login user)

#### Backend Tests

- [ ] T034 [P] [US4] Write unit tests for ForgotPasswordHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Auth/ForgotPasswordHandlerTests.cs (test valid email, non-existent email still returns success)

- [ ] T035 [P] [US4] Write unit tests for ResetPasswordHandler in ae-infinity-api/tests/AeInfinity.Application.Tests/Auth/ResetPasswordHandlerTests.cs (test valid token, expired token, invalid token, weak password)

#### Verification

- [ ] T036 [US4] Manual test: Request password reset, verify PasswordResetToken and PasswordResetExpiresAt fields populated in database (no email in MVP - check database directly)

**Acceptance Criteria** (from spec.md):
- ✅ User enters email, receives reset link (1 hour validity)
- ✅ Reset link presents form for new password
- ✅ New password validated and updated
- ✅ Expired reset link shows "Reset link expired"
- ✅ Rate limiting: max 3 requests per hour per email (defer to Phase 9)

**Note**: Email sending not implemented in MVP. Reset tokens stored in database for manual testing/future email integration.

---

## Phase 8: Frontend Integration

**Goal**: Replace mock data with real API calls

**Duration**: 3-4 hours

### Tasks

#### AuthContext Integration

- [ ] T037 Remove mock user data from ae-infinity-ui/src/contexts/AuthContext.tsx and replace with real API calls to authService

- [ ] T038 Update login handler in AuthContext to call authService.login(), store JWT token, and set user state from API response

- [ ] T039 Update register handler in AuthContext to call authService.register(), store JWT token, and auto-login user

- [ ] T040 Add token expiration handling in AuthContext - detect 401 responses, clear token, redirect to login

#### Page Integration

- [ ] T041 Update Register.tsx in ae-infinity-ui/src/pages/auth/Register.tsx to display backend validation errors (duplicate email, weak password)

- [ ] T042 Update ForgotPassword.tsx in ae-infinity-ui/src/pages/auth/ForgotPassword.tsx to call authService.forgotPassword() (P2 - requires Phase 7 complete)

#### Frontend Tests

- [ ] T043 [P] Write service tests for authService in ae-infinity-ui/tests/services/authService.test.ts (mock fetch, test login, register, logout, error handling)

**Verification**:
- Login with real credentials, verify JWT token stored and /lists accessible
- Register new account, verify auto-login and dashboard access
- Logout, verify token cleared and redirect to login

---

## Phase 9: Polish & Cross-Cutting Concerns

**Goal**: Production readiness - rate limiting, error handling, monitoring

**Duration**: 2-3 hours

### Tasks

#### Rate Limiting (Priority: P2 - Not MVP Blocking)

- [ ] T044 [P2] Implement rate limiting middleware in ae-infinity-api/AeInfinity.API/Middleware/RateLimitingMiddleware.cs using fixed 1-minute windows (5 login attempts per minute per IP with 15-minute block, 3 registrations per hour per IP counting all attempts)

- [ ] T045 [P2] Register rate limiting middleware in ae-infinity-api/AeInfinity.API/Program.cs before authentication middleware

**Note**: These tasks are P2 priority and not required for MVP completion. Can be implemented after P1 user stories are complete.

#### Error Handling

- [ ] T046 Add global exception handler in ae-infinity-api/AeInfinity.API/Middleware/ExceptionHandlingMiddleware.cs (log errors, return structured 500 responses without exposing stack traces)

#### Monitoring & Logging

- [ ] T047 Add structured logging for auth events in LoginHandler, RegisterHandler, ResetPasswordHandler (log user ID, email, timestamps, success/failure)

- [ ] T048 Add performance metrics logging for authentication requests (track login duration, token validation duration)

#### Security Audit

- [ ] T049 Review all DTOs have [Required] attributes, verify Swagger shows nullable: false for critical fields, test with missing fields to confirm 400 Bad Request

---

## Parallel Execution Opportunities

### After Phase 2 Complete (DTO Validation)

**Can run in parallel**:

**Developer 1**: Phase 3 (US1 - Login Tests)
- T008: LoginHandler unit tests
- T009: POST /auth/login integration test
- T010: Login.tsx component tests

**Developer 2**: Phase 4 (US5 - Get User Tests)  
- T013: GetCurrentUserHandler unit tests
- T014: GET /users/me integration test

**Developer 3**: Phase 5 (US2 - Registration Implementation)
- T016-T020: Registration command, validator, handler, DTO, endpoint

**Developer 4**: Phase 6 (US3 - Logout Verification)
- T025-T026: Manual testing of logout flow

**Estimated Time**: 3-4 hours in parallel (vs 8-9 hours sequential)

---

### After Phases 3-6 Complete (P1 Stories Done)

**Can run in parallel**:

**Developer 1**: Phase 7 (US4 - Password Reset)
- T027-T036: Forgot/Reset password implementation and tests

**Developer 2**: Phase 8 (Frontend Integration)
- T037-T043: Replace mock data with real API calls

**Estimated Time**: 4-5 hours in parallel (vs 8-10 hours sequential)

---

## Testing Strategy

### Test Coverage Targets

- **Backend**: 80% coverage minimum
  - Unit tests: All command handlers, validators
  - Integration tests: All API endpoints
  - Test fixtures: Use WebApplicationFactory for realistic tests

- **Frontend**: 80% coverage minimum
  - Component tests: All auth pages (Login, Register, ForgotPassword)
  - Service tests: authService with mocked fetch
  - Hook tests: useAuth with mocked context

### Test Execution

```bash
# Backend tests
cd ae-infinity-api
dotnet test --collect:"XPlat Code Coverage"

# Frontend tests
cd ae-infinity-ui
npm test -- --coverage
```

### Contract Validation

After each user story implementation:
1. Run backend, open Swagger at http://localhost:5233/index.html
2. Compare actual API responses to contract JSON schemas in contracts/
3. Verify required fields match, no extra fields, correct data types

---

## Success Criteria Checklist

From [spec.md](./spec.md) - verify ALL before marking feature complete:

### Performance
- [ ] SC-001: Login completes in < 5 seconds from credentials to dashboard
- [ ] SC-002: Registration completes in < 2 minutes
- [ ] SC-003: 95% of auth requests complete in < 500ms
- [ ] SC-007: 100% of protected endpoints require valid JWT token

### Security
- [ ] SC-004: Zero passwords stored in plaintext (100% BCrypt hashing)
- [ ] SC-008: Email uniqueness enforced (zero duplicate accounts)
- [ ] SC-012: Error messages protect privacy (no user enumeration)

### User Experience
- [ ] SC-005: Token expiration enforced (no access after 24 hours)
- [ ] SC-006: Password reset completes in < 5 minutes (P2)
- [ ] SC-009: Form validation errors appear within 200ms
- [ ] SC-010: "Remember me" sessions survive browser restart

### Reliability
- [ ] SC-011: All production traffic encrypted with HTTPS

---

## Definition of Done

Feature 001 is complete when:

- [ ] All P1 user stories implemented (Login, Registration, Logout, Get User)
- [ ] All P1 backend endpoints tested (unit + integration)
- [ ] All P1 frontend components tested
- [ ] Frontend integrated with real API (no mock data)
- [ ] All 14 success criteria met
- [ ] Backend code coverage ≥ 80%
- [ ] Frontend code coverage ≥ 80%
- [ ] Swagger documentation matches contracts
- [ ] Manual testing checklist complete
- [ ] No TypeScript `any` types in frontend
- [ ] No security vulnerabilities in linter output
- [ ] Code review approved
- [ ] Feature deployed to staging environment

**P2 Complete** (Password Reset):
- [ ] All US4 tasks complete (T027-T036)
- [ ] Password reset flow tested end-to-end
- [ ] Rate limiting implemented for reset requests

---

## Phase 10: US6 - Email Verification *(Priority: P3 - Deferred)*

**User Story**: The system wants to verify that users own the email addresses they register with.

**Current Status**: Not implemented, deferred to post-MVP

**Deferral Rationale**: Email verification is P3 (nice to have). MVP allows users to register and use the system without email verification. Can implement later when email service infrastructure is in place.

**Duration**: TBD (deferred)

### Tasks (Deferred to Future Phase)

- [ ] T050 [US6] [DEFERRED] Create email service interface IEmailService in ae-infinity-api/AeInfinity.Application/Common/Interfaces/IEmailService.cs

- [ ] T051 [US6] [DEFERRED] Create EmailVerificationToken entity in ae-infinity-api/AeInfinity.Domain/Entities/EmailVerificationToken.cs (token, userId, expiresAt, createdAt)

- [ ] T052 [US6] [DEFERRED] Create SendVerificationEmailCommand + Handler in ae-infinity-api/AeInfinity.Application/Features/Auth/SendVerificationEmail/ (generate token, send email with link)

- [ ] T053 [US6] [DEFERRED] Create VerifyEmailCommand + Handler in ae-infinity-api/AeInfinity.Application/Features/Auth/VerifyEmail/ (validate token, set isEmailVerified = true)

- [ ] T054 [US6] [DEFERRED] Add POST /auth/verify-email/{token} endpoint to AuthController

- [ ] T055 [US6] [DEFERRED] Add POST /auth/resend-verification endpoint to AuthController

- [ ] T056 [US6] [DEFERRED] Implement mock email service for testing (logs to console)

- [ ] T057 [US6] [DEFERRED] Write unit tests for email verification handlers

- [ ] T058 [US6] [DEFERRED] Write integration tests for email verification endpoints

**Note**: These tasks are explicitly deferred and NOT required for feature 001 completion. Implement in a future phase when email infrastructure is ready.

---

**Optional P3** (Email Verification):
- [ ] Email verification flow implemented
- [ ] Email service integrated
- [ ] Verification tokens tested

---

## Risk Mitigation

### Known Risks

1. **Rate Limiting Complexity**
   - Risk: Distributed rate limiting across multiple servers
   - Mitigation: Start with in-memory rate limiting (single server), plan Redis for multi-server

2. **Token Blacklist**
   - Risk: Users can't invalidate tokens before 24hr expiration
   - Mitigation: Document limitation, plan refresh token rotation for v2

3. **Email Service**
   - Risk: Password reset requires email service not yet configured
   - Mitigation: Store tokens in database, verify via direct DB queries for MVP

4. **Frontend-Backend Mismatch**
   - Risk: Frontend expects fields backend doesn't return
   - Mitigation: Use contract JSON schemas as single source of truth, validate with integration tests

---

## Deployment Checklist

Before deploying to production:

- [ ] Environment variables configured (JWT secret, database connection)
- [ ] HTTPS enforced (redirect HTTP to HTTPS)
- [ ] CORS configured (restrict to known origins)
- [ ] Database migrations applied
- [ ] Health check endpoint responding
- [ ] Monitoring configured (Application Insights or ELK)
- [ ] Rate limiting configured and tested
- [ ] Backup strategy in place
- [ ] Rollback plan documented

---

## Quick Reference

**Backend API Base URL**: http://localhost:5233/api  
**Frontend Dev Server**: http://localhost:5173  
**Swagger UI**: http://localhost:5233/index.html

**Key Files**:
- Spec: [spec.md](./spec.md)
- Plan: [plan.md](./plan.md)
- Data Model: [data-model.md](./data-model.md)
- Quickstart: [quickstart.md](./quickstart.md)
- Contracts: [contracts/](./contracts/)

**Commands**:
```bash
# Run backend
cd ae-infinity-api && dotnet run --project AeInfinity.API

# Run frontend  
cd ae-infinity-ui && npm run dev

# Run tests
dotnet test  # backend
npm test     # frontend
```

---

**Generated**: 2025-11-05  
**Last Updated**: 2025-11-05  
**Total Tasks**: 49  
**Estimated Duration**: 6-8 days (MVP), +1-2 days (P2)

