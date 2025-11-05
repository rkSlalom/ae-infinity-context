# Feature Specification: User Authentication

**Feature Branch**: `001-user-authentication`  
**Created**: 2025-11-05  
**Status**: Consolidation from existing documentation  
**Current Implementation**: Backend 80%, Frontend 80%, Integration 0%

## User Scenarios & Testing *(mandatory)*

### User Story 1 - User Login (Priority: P1)

A returning user wants to access their shopping lists by logging in with their email and password. The system authenticates them using JWT tokens, stores the session, and grants access to all protected features.

**Why this priority**: Core authentication is foundational - no other features work without it. Must be implemented first.

**Independent Test**: Can be fully tested by providing valid credentials, receiving a JWT token, and accessing protected endpoints. Delivers immediate value by protecting user data.

**Acceptance Scenarios**:

1. **Given** a user with valid credentials, **When** they submit email and password, **Then** they receive a JWT token valid for 24 hours and are redirected to the lists dashboard
2. **Given** a user with invalid credentials, **When** they attempt to login, **Then** they see a generic error message "Invalid email or password" (security best practice)
3. **Given** a logged-in user, **When** they access protected pages, **Then** their JWT token is included in all API requests via Authorization header
4. **Given** a user selects "Remember me", **When** they close and reopen the browser, **Then** their session persists (token stored in localStorage)
5. **Given** a user's token expires after 24 hours, **When** they make an API request, **Then** they receive 401 Unauthorized and are redirected to login

---

### User Story 2 - User Registration (Priority: P1)

A new user wants to create an account so they can start creating and managing shopping lists. The system validates their information, creates a secure account with hashed password, and logs them in automatically.

**Why this priority**: Essential for user acquisition and growth. Without registration, only pre-seeded users can access the system.

**Independent Test**: Can be fully tested by submitting registration form with valid data, verifying account creation in database, and confirming automatic login. Delivers standalone value for onboarding.

**Acceptance Scenarios**:

1. **Given** a new user with unique email, **When** they submit registration form with email, display name, and valid password, **Then** an account is created and they are automatically logged in
2. **Given** a user enters an existing email, **When** they submit registration, **Then** they see error "Email already registered"
3. **Given** a user enters weak password, **When** they submit registration, **Then** they see password requirements (8+ chars, uppercase, lowercase, number, special char)
4. **Given** a user types password, **When** they view the form, **Then** they see a real-time password strength indicator (weak/medium/strong/very strong) calculated using zxcvbn algorithm with debounced updates (300ms delay)
5. **Given** successful registration, **When** account is created, **Then** password is hashed with BCrypt before storage (never stored as plaintext)

---

### User Story 3 - User Logout (Priority: P1)

A logged-in user wants to securely end their session, especially on shared devices. The system clears the authentication token and redirects to the public landing page.

**Why this priority**: Required for security and multi-user scenarios. Must be implemented alongside login.

**Independent Test**: Can be fully tested by logging in, then logging out, and verifying token is cleared and protected pages are inaccessible. Delivers security value independently.

**Acceptance Scenarios**:

1. **Given** a logged-in user, **When** they click logout, **Then** their JWT token is removed from storage and they are redirected to landing page
2. **Given** a user logs out, **When** they try to access protected pages, **Then** they are redirected to login page
3. **Given** a user logs out, **When** backend receives the logout request, **Then** logout event is logged for audit purposes (token remains valid until expiration as no server-side blacklist exists)

---

### User Story 4 - Password Reset (Priority: P2)

A user who forgets their password wants to regain access to their account through email verification. The system sends a time-limited reset link that allows them to set a new password.

**Why this priority**: Important for user retention but not blocking MVP. Can be deferred if needed.

**Independent Test**: Can be fully tested by requesting reset, receiving email with token, and successfully changing password. Delivers standalone account recovery value.

**Acceptance Scenarios**:

1. **Given** a user forgets password, **When** they enter their email on forgot password page, **Then** they receive an email with a time-limited reset link (valid for 1 hour)
2. **Given** a user clicks reset link, **When** link is still valid, **Then** they are presented with a form to enter new password
3. **Given** a user submits new password, **When** password meets requirements, **Then** password is updated and they are automatically logged in
4. **Given** a user tries to use expired reset link, **When** they access the link, **Then** they see error "Reset link expired" and can request a new one
5. **Given** rate limiting, **When** user requests multiple resets, **Then** system allows maximum 3 requests per hour per email address

---

### User Story 5 - Get Current User Info (Priority: P1)

The application needs to retrieve the currently authenticated user's profile information to display in the UI and enforce permissions. The system returns full user details based on the JWT token.

**Why this priority**: Required for personalization, UI display (user name, avatar), and authorization checks throughout the app.

**Independent Test**: Can be fully tested by making authenticated request to /users/me endpoint and receiving complete user profile. Enables personalized UI.

**Acceptance Scenarios**:

1. **Given** an authenticated user, **When** the app loads, **Then** it fetches current user info via GET /users/me and displays name/avatar in header
2. **Given** a request with valid JWT token, **When** backend receives request, **Then** it extracts user ID from token claims and returns full user profile
3. **Given** a request with expired/invalid token, **When** backend validates token, **Then** it returns 401 Unauthorized

---

### User Story 6 - Email Verification (Priority: P3)

The system wants to verify that users own the email addresses they register with to prevent abuse and enable reliable communication. Users receive a verification email with a link to confirm their address.

**Why this priority**: Nice to have for production but not blocking MVP. Can be implemented later.

**Independent Test**: Can be fully tested by registering, receiving verification email, clicking link, and seeing email marked as verified.

**Acceptance Scenarios**:

1. **Given** a new user registers, **When** account is created, **Then** an automated verification email is sent with a unique token link
2. **Given** a user clicks verification link, **When** link is valid, **Then** their isEmailVerified flag is set to true
3. **Given** optional enforcement, **When** email is not verified, **Then** user may see reminders but can still use the app (soft verification)

---

### Edge Cases

- **What happens when** a user enters email with different case (User@example.com vs user@example.com)?  
  → System uses case-insensitive email lookup (normalized email field in database)

- **What happens when** a new user wants to set an avatar during registration?  
  → Registration accepts email, displayName, and password only. Avatar URL can only be set after registration via profile editing (feature 002-user-profile-management). New users see default avatar (initials-based placeholder) until they update their profile.

- **What happens when** a user's session expires mid-action?  
  → API returns 401, frontend redirects to login with return URL, user can resume after re-authenticating

- **What happens when** multiple login requests are made simultaneously with same credentials?  
  → Each request generates a unique JWT token (stateless), all are valid until expiration

- **What happens when** a user changes password while logged in on multiple devices?  
  → Currently: existing tokens remain valid until 24hr expiration. Future: could implement token blacklist or refresh token rotation.

- **What happens when** brute force login attempts are made?  
  → Rate limiting enforced: 5 attempts per minute per IP address (planned, not yet implemented)

- **What happens when** backend is unreachable during login?  
  → Frontend shows network error message, encourages retry, maintains offline-friendly UX

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST authenticate users via email and password using JWT tokens with HMAC-SHA256 algorithm
- **FR-002**: System MUST hash all passwords using BCrypt with automatic salt generation before storage
- **FR-003**: System MUST validate JWT tokens on all protected API endpoints and reject expired/invalid tokens with 401 status
- **FR-004**: System MUST generate JWT tokens that expire after 24 hours from issuance
- **FR-005**: System MUST include user ID (sub), email, display name, and JWT ID (jti) in token claims
- **FR-006**: System MUST perform case-insensitive email lookups using normalized email field
- **FR-007**: System MUST return generic error message "Invalid email or password" for failed authentication (prevent user enumeration)
- **FR-008**: System MUST update lastLoginAt timestamp on successful authentication
- **FR-009**: System MUST validate email format (valid email structure) on registration and login
- **FR-010**: System MUST enforce password requirements: minimum 8 characters, at least one uppercase, one lowercase, one number, one special character
- **FR-011**: System MUST prevent duplicate accounts by checking email uniqueness before registration
- **FR-012**: System MUST automatically log in users after successful registration (return JWT token)
- **FR-013**: System MUST log logout events for audit purposes (note: tokens remain valid until expiration)
- **FR-014**: System MUST clear JWT token from client storage on logout
- **FR-015**: System MUST support password reset via time-limited token (1 hour expiration)
- **FR-016**: System MUST send password reset emails to verified email addresses only
- **FR-017**: System MUST invalidate password reset tokens after successful use or expiration
- **FR-018**: System MUST allow users to retrieve their own profile information via GET /users/me
- **FR-019**: System MUST extract user identity from JWT token claims for authorization
- **FR-020**: Frontend MUST store JWT token in localStorage for session persistence
- **FR-021**: Frontend MUST include JWT token in Authorization header (Bearer scheme) for all authenticated requests
- **FR-022**: Frontend MUST redirect to login page when receiving 401 Unauthorized from API
- **FR-023**: Frontend MUST display password strength indicator during registration
- **FR-024** (Priority: P2): System SHOULD implement rate limiting with fixed 1-minute windows: 5 login attempts per minute per IP (block for 15 minutes after limit), 3 registrations per hour per IP (all attempts count), 3 password resets per hour per email
- **FR-025**: System MUST accept avatarUrl as null on user creation (registration sets avatarUrl to null by default)

### Key Entities

- **User**: Represents a person with an account in the system
  - Unique identifier (GUID/UUID)
  - Email address (unique, case-insensitive)
  - Display name (2-100 characters)
  - Password hash (BCrypt, never plaintext)
  - Avatar URL (optional, nullable, initially null on registration - can be set via profile editing in feature 002)
  - Email verification status (boolean flag)
  - Last login timestamp (for activity tracking)
  - Account creation timestamp (audit trail)
  - Relationships: Owns shopping lists, collaborates on lists

- **Authentication Token (JWT)**: Stateless token representing authenticated session
  - Token string (signed with HMAC-SHA256)
  - Expiration timestamp (24 hours from issuance)
  - Claims: User ID (sub), Email, Display Name, JWT ID (jti)
  - Issuer: "AeInfinityApi"
  - Audience: "AeInfinityClient"

- **Password Reset Token**: Time-limited token for password recovery
  - Unique token string
  - Associated user email
  - Expiration timestamp (1 hour)
  - Used status (single-use, invalidated after password change)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete login in under 5 seconds from entering credentials to seeing dashboard
- **SC-002**: Users can complete registration in under 2 minutes including all required fields
- **SC-003**: 95% of authentication requests complete in under 500 milliseconds
- **SC-004**: Zero passwords stored in plaintext - 100% use BCrypt hashing
- **SC-005**: Token expiration enforced - users cannot access protected resources 24 hours after token issuance
- **SC-006**: Password reset flow completes in under 5 minutes including email delivery
- **SC-007**: System prevents unauthorized access - 100% of requests to protected endpoints require valid JWT token
- **SC-008**: Email uniqueness enforced - zero duplicate accounts with same email address
- **SC-009**: Users see immediate feedback - form validation errors appear within 200 milliseconds
- **SC-010**: Session persistence works - 100% of "Remember me" sessions survive browser restart
- **SC-011**: Secure by default - all authentication traffic encrypted with HTTPS in production
- **SC-012**: Error messages protect privacy - login failures never reveal whether email exists in system

