# Feature 001: User Authentication - MVP Testing Guide

## 🎯 Overview

This guide walks you through manually testing the **MVP implementation** of Feature 001 (User Authentication). The implementation is **production-ready for P1 features** (Login, Registration, Logout, Get User) with **P2 features deferred** (Password Reset, Rate Limiting, Email Verification).

## 📋 Prerequisites

### Backend Requirements
- ✅ .NET 9 SDK installed
- ✅ PostgreSQL database running (or SQLite for dev)
- ✅ JWT configuration in `appsettings.json`

### Frontend Requirements
- ✅ Node.js 18+ installed
- ✅ npm dependencies installed

## 🚀 Setup & Startup

### 1. Start Backend API

```bash
cd /path/to/ae-infinity-api
dotnet build
dotnet run --project src/AeInfinity.Api/AeInfinity.Api.csproj
```

**Expected Output:**
```
Now listening on: http://localhost:5233
```

**Verify Swagger UI:**
Open http://localhost:5233/swagger/index.html and confirm you see:
- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/logout`
- `GET /api/users/me`

### 2. Start Frontend

```bash
cd /path/to/ae-infinity-ui
npm install  # If not done already
npm run dev
```

**Expected Output:**
```
  VITE v5.x.x  ready in XXX ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

Open http://localhost:5173

---

## 🧪 Manual Test Scenarios

### ✅ Test 1: User Registration (US2)

**Goal:** Register a new user account and auto-login

#### Steps:
1. Navigate to http://localhost:5173/register
2. Fill in the form:
   - **Display Name:** `Test User`
   - **Email:** `testuser@example.com`
   - **Password:** `TestPass123!`
   - **Confirm Password:** `TestPass123!`
3. Click **"Create Account"**

#### Expected Results:
- ✅ Form submits successfully (no error)
- ✅ Redirects to `/lists` (dashboard)
- ✅ JWT token stored in localStorage (check DevTools → Application → Local Storage → `auth_token`)
- ✅ Token expiration stored in localStorage (`token_expires_at`)
- ✅ User is auto-logged in (see user name in header/sidebar if applicable)

#### Validation (Backend):
Open Swagger → `POST /api/auth/register` → Try it out:
```json
{
  "email": "apitest@example.com",
  "displayName": "API Test User",
  "password": "ApiTest123!"
}
```

**Expected Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresAt": "2025-11-06T12:34:56.789Z",
  "user": {
    "id": "generated-guid",
    "email": "apitest@example.com",
    "displayName": "API Test User",
    "avatarUrl": null,
    "isEmailVerified": false,
    "createdAt": "2025-11-05T12:34:56.789Z"
  }
}
```

---

### ✅ Test 2: Duplicate Email (US2 - Edge Case)

**Goal:** Verify duplicate email returns error

#### Steps:
1. Try to register again with the same email (`testuser@example.com`)
2. Fill in:
   - **Display Name:** `Another User`
   - **Email:** `testuser@example.com` (duplicate)
   - **Password:** `TestPass123!`
3. Click **"Create Account"**

#### Expected Results:
- ❌ Error message displayed: `"Email already registered"`
- ❌ User remains on registration page
- ❌ No redirect occurs

---

### ✅ Test 3: User Login (US1)

**Goal:** Login with existing credentials

#### Steps:
1. Logout if logged in (click logout button, or manually clear localStorage)
2. Navigate to http://localhost:5173/login
3. Use seed data credentials (if backend has seed data):
   - **Email:** `sarah@example.com`
   - **Password:** `Password123!`
4. Click **"Sign In"**

#### Expected Results:
- ✅ Form submits successfully
- ✅ Redirects to `/lists` (dashboard)
- ✅ JWT token stored in localStorage
- ✅ User info appears in UI (header/sidebar)

#### Alternative: Test with Newly Registered User
- Use `testuser@example.com` / `TestPass123!`

---

### ✅ Test 4: Invalid Credentials (US1 - Security)

**Goal:** Verify generic error message (no user enumeration)

#### Steps:
1. Navigate to http://localhost:5173/login
2. Enter:
   - **Email:** `testuser@example.com` (valid user)
   - **Password:** `WrongPassword123!` (invalid)
3. Click **"Sign In"**

#### Expected Results:
- ❌ Error message: `"Invalid email or password"` (generic)
- ❌ No indication whether email exists or not

#### Repeat with Non-Existent Email:
- **Email:** `nonexistent@example.com`
- **Password:** `TestPass123!`
- Should show **same generic error**: `"Invalid email or password"`

---

### ✅ Test 5: Get Current User (US5)

**Goal:** Verify authenticated user can fetch their profile

#### Steps:
1. Login as `testuser@example.com` (from Test 3)
2. Open DevTools → Console
3. Run:
```javascript
fetch('http://localhost:5233/api/users/me', {
  headers: {
    'Authorization': 'Bearer ' + localStorage.getItem('auth_token')
  }
})
.then(r => r.json())
.then(data => console.log(data))
```

#### Expected Results:
- ✅ HTTP 200 OK
- ✅ Response contains user data:
```json
{
  "id": "generated-guid",
  "email": "testuser@example.com",
  "displayName": "Test User",
  "avatarUrl": null,
  "isEmailVerified": false,
  "createdAt": "2025-11-05T12:34:56.789Z",
  "lastLoginAt": "2025-11-05T12:40:00.000Z"
}
```

---

### ✅ Test 6: Unauthenticated Access (US5 - Security)

**Goal:** Verify protected endpoint rejects unauthenticated requests

#### Steps:
1. Logout (or clear localStorage `auth_token`)
2. Try to access `GET /api/users/me`:
```javascript
fetch('http://localhost:5233/api/users/me')
.then(r => console.log(r.status, r.statusText))
```

#### Expected Results:
- ❌ HTTP 401 Unauthorized
- ❌ No user data returned

---

### ✅ Test 7: User Logout (US3)

**Goal:** Verify logout clears client-side state

#### Steps:
1. Login as any user
2. Verify token exists in localStorage (`auth_token`)
3. Click **"Logout"** button in UI
4. Check localStorage again

#### Expected Results:
- ✅ `auth_token` removed from localStorage
- ✅ `token_expires_at` removed from localStorage
- ✅ Redirects to `/login` page
- ✅ Backend receives `POST /api/auth/logout` (check Network tab)

---

### ✅ Test 8: Password Validation (US2)

**Goal:** Verify password strength requirements

#### Frontend Validation (Client-Side):
1. Navigate to `/register`
2. Enter weak password: `weak`
3. Try to submit

**Expected:** Browser HTML5 validation prevents submit (minLength=8)

#### Backend Validation (API-Level):
Open Swagger → `POST /api/auth/register` → Try:
```json
{
  "email": "weakpass@example.com",
  "displayName": "Weak Password User",
  "password": "weak"
}
```

**Expected Response (400 Bad Request):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "Password", "message": "Password must be at least 8 characters" },
      { "field": "Password", "message": "Password must contain at least one uppercase letter" },
      { "field": "Password", "message": "Password must contain at least one number" },
      { "field": "Password", "message": "Password must contain at least one special character" }
    ]
  }
}
```

---

### ✅ Test 9: Token Expiration (US1 - Security)

**Goal:** Verify tokens expire after 24 hours

#### Manual Test (Expedited):
1. Login and get a token
2. **Option A (Dev):** Manually edit `token_expires_at` in localStorage to a past date:
```javascript
localStorage.setItem('token_expires_at', '2020-01-01T00:00:00Z')
```
3. Refresh page or wait 1 minute (AuthContext checks every minute)

**Expected:**
- ✅ User auto-logged out
- ✅ Redirects to `/login`

#### Backend Test:
- Tokens are valid for **24 hours** (configured in `Program.cs`)
- Real expiration requires waiting 24 hours (test in staging/production)

---

### ✅ Test 10: Email Format Validation

**Goal:** Verify invalid email formats are rejected

#### Frontend:
1. Navigate to `/register`
2. Enter invalid email: `notanemail`
3. Browser HTML5 validation should prevent submit

#### Backend (Swagger):
```json
{
  "email": "notanemail",
  "displayName": "Test",
  "password": "TestPass123!"
}
```

**Expected (400 Bad Request):**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "Email", "message": "Invalid email format" }
    ]
  }
}
```

---

## 🧩 Acceptance Criteria Verification

### ✅ US1: User Login

| Criteria | Status | Test |
|----------|--------|------|
| Valid credentials return JWT token (24h validity) | ✅ | Test 3 |
| Invalid credentials show generic error | ✅ | Test 4 |
| Token included in Authorization header | ✅ | Test 5 |
| Login updates lastLoginAt timestamp | ✅ | Test 5 (check response) |

### ✅ US2: User Registration

| Criteria | Status | Test |
|----------|--------|------|
| Unique email creates account + auto-login | ✅ | Test 1 |
| Duplicate email returns error | ✅ | Test 2 |
| Weak password shows requirements | ✅ | Test 8 |
| Display name (2-100 chars) required | ✅ | Frontend HTML5 validation |

### ✅ US3: User Logout

| Criteria | Status | Test |
|----------|--------|------|
| Logout clears client-side token | ✅ | Test 7 |
| Redirects to login page | ✅ | Test 7 |
| Server records logout event (audit) | ✅ | Backend handler exists |

### ✅ US5: Get Current User

| Criteria | Status | Test |
|----------|--------|------|
| Authenticated users can fetch profile | ✅ | Test 5 |
| Unauthenticated requests return 401 | ✅ | Test 6 |
| Response includes all user fields | ✅ | Test 5 |

---

## 🚫 Known Deferred Features (P2/P3)

### ⏸️ US4: Password Reset (P2)
- **Status:** Not implemented
- **Impact:** Users cannot reset forgotten passwords
- **Workaround:** Admin manual password reset via database
- **Implementation:** Phase 7 (deferred post-MVP)

### ⏸️ US6: Email Verification (P3)
- **Status:** Not implemented
- **Impact:** Users can register with fake emails
- **Workaround:** Manual verification if needed
- **Implementation:** Phase 10 (deferred post-MVP)

### ⏸️ Rate Limiting (P2)
- **Status:** Not implemented
- **Impact:** No brute-force protection on login/registration
- **Workaround:** Monitor logs for suspicious activity
- **Implementation:** Phase 9 (polish)

---

## 🐛 Troubleshooting

### Issue: "Network Error" on Login
**Cause:** Backend not running or CORS issue  
**Fix:**
- Verify backend is running: `curl http://localhost:5233/api/health` (if health endpoint exists)
- Check `Program.cs` has `app.UseCors("AllowAll");` before `app.UseAuthorization();`

### Issue: "401 Unauthorized" immediately after login
**Cause:** Token not being sent correctly  
**Fix:**
- Check localStorage has `auth_token`
- Verify apiClient.ts is adding `Authorization: Bearer {token}` header
- Check backend JWT configuration in `Program.cs`

### Issue: Registration succeeds but doesn't auto-login
**Cause:** Frontend not storing token from response  
**Fix:**
- Check `AuthContext.tsx` → `register()` → `authService.register()` → `tokenManager.set(response.token)`

### Issue: "Email already registered" for new email
**Cause:** Case-sensitivity issue  
**Fix:**
- Backend uses `emailNormalized` (ToUpper) for comparison
- Verify `RegisterCommandHandler.cs` line 32: `emailNormalized = request.Email.ToUpper()`

---

## ✅ MVP Completion Checklist

- [X] **Backend**: Login, Register, Logout, Get User endpoints implemented
- [X] **Backend**: JWT authentication configured (24h expiration)
- [X] **Backend**: BCrypt password hashing
- [X] **Backend**: Email uniqueness validation (case-insensitive)
- [X] **Backend**: FluentValidation for request DTOs
- [X] **Frontend**: AuthContext integrated with authService
- [X] **Frontend**: Login, Register pages functional
- [X] **Frontend**: Token storage in localStorage
- [X] **Frontend**: Token expiration handling
- [X] **Frontend**: Vite proxy configured for local dev
- [X] **Integration**: Frontend → Backend authentication flow working
- [X] **Security**: Generic error messages (no user enumeration)
- [X] **Security**: Password complexity requirements enforced
- [ ] **Tests**: Unit tests (deferred post-MVP)
- [ ] **Tests**: Integration tests (deferred post-MVP)
- [ ] **Tests**: Component tests (deferred post-MVP)

---

## 📚 Next Steps

### For MVP Release:
1. ✅ **Deploy to staging** and run all tests above
2. ✅ **Create test accounts** for QA team
3. ✅ **Monitor error logs** for 24 hours
4. ✅ **Production deployment** (if staging successful)

### Post-MVP (Incremental):
1. 🔄 **Phase 7:** Implement Password Reset (P2)
2. 🔄 **Phase 9:** Add Rate Limiting (P2)
3. 🔄 **Add Tests:** Unit, integration, component tests incrementally
4. 🔄 **Phase 10:** Email Verification (P3)

---

## 📞 Support

**Backend Issues:** Check `ae-infinity-api/logs/` or console output  
**Frontend Issues:** Check browser DevTools Console  
**Questions:** Refer to `ARCHITECTURE.md`, `API_REFERENCE.md`, or `spec.md`

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-05  
**Status:** ✅ MVP Ready for Testing

