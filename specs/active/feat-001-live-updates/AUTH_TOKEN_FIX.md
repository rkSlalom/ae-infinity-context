# Authentication Token Fix - 401 Error Resolved

## Problem
Getting **401 Unauthorized** error when connecting to SignalR:
```
http://localhost:5233/hubs/shopping-list/negotiate?negotiateVersion=1 401
```

## Root Cause
The `RealtimeWrapper` was using a mock token (`'mock-jwt-token-' + user.id`) instead of the real JWT token from the authentication service.

## Solution Applied

### 1. ✅ Updated AuthContext to Expose getToken
**File:** `src/contexts/AuthContext.tsx`

**Changes:**
```typescript
// Added to AuthContextType interface
interface AuthContextType {
  // ... existing fields
  getToken: () => string | null  // ← NEW
}

// Added getToken function
const getToken = () => {
  return authService.getToken()
}

// Added to context value
const value: AuthContextType = {
  // ... existing fields
  getToken,  // ← NEW
}
```

### 2. ✅ Updated RealtimeWrapper to Use Real Token
**File:** `src/components/realtime/RealtimeWrapper.tsx`

**Before:**
```typescript
const { user } = useAuth();
const token = user ? 'mock-jwt-token-' + user.id : null;  // ❌ MOCK
```

**After:**
```typescript
const { user, getToken } = useAuth();
const token = user ? getToken() : null;  // ✅ REAL TOKEN
```

## How to Test

### 1. Restart Frontend (IMPORTANT!)
```bash
# Stop the dev server (Ctrl+C)
cd /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-ui

# Restart it
npm run dev
```

**Why restart?** The token is fetched when the RealtimeProvider initializes. We need a fresh app instance.

### 2. Clear Browser Storage (Recommended)
1. Open DevTools (F12)
2. Go to **Application** tab
3. Click **Local Storage** → `http://localhost:5173`
4. Right-click → **Clear**
5. Refresh the page (F5)

### 3. Login Again
1. Navigate to login page
2. Enter credentials
3. Login

### 4. Check Connection
Open browser console and look for:

**✅ Success:**
```javascript
SignalR Connected! Connection ID: abc123...
[Backend logs] User 12345-67890-... connected with connection abc123
```

**❌ Still 401:**
```javascript
Failed to start the connection: Error: Error during negotiate: 401 Unauthorized
```

## Troubleshooting

### Still Getting 401?

#### Check 1: Is Token Being Sent?
1. Open **DevTools → Network** tab
2. Filter by "WS" (WebSocket)
3. Find the SignalR connection attempt
4. Check **Request URL**, should include `access_token` parameter:

**✅ Good:**
```
ws://localhost:5233/hubs/shopping-list?access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**❌ Bad:**
```
ws://localhost:5233/hubs/shopping-list?access_token=mock-jwt-token-12345
```

**❌ Bad:**
```
ws://localhost:5233/hubs/shopping-list  (no access_token parameter)
```

#### Check 2: Is Token Valid?
Test the token directly:

```bash
# Get your token from browser console:
# localStorage.getItem('authToken')

# Then test it against the API:
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     http://localhost:5233/api/users/me

# Should return 200 with user details if valid
# Should return 401 if invalid/expired
```

#### Check 3: Is Token in LocalStorage?
In browser console:
```javascript
// Check if token exists
localStorage.getItem('authToken')

// Should output: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
// If null, you're not logged in properly
```

#### Check 4: Is Token Expired?
In browser console:
```javascript
// Check token expiration
const expiresAt = localStorage.getItem('token_expires_at');
const isExpired = new Date(expiresAt) < new Date();
console.log('Token expired:', isExpired);

// If true, logout and login again
```

#### Check 5: Backend JWT Configuration
Verify `appsettings.Development.json` has valid JWT settings:

```json
{
  "Jwt": {
    "Secret": "your-secret-key-min-32-chars",
    "Issuer": "AeInfinityApi",
    "Audience": "AeInfinityClient",
    "ExpirationMinutes": 60
  }
}
```

### Backend Logs for Debugging

Check backend console for authentication errors:

**✅ Success:**
```
info: AeInfinity.Api.Hubs.ShoppingListHub[0]
      User 12345-67890-... connected with connection abc123
```

**❌ Authentication Failed:**
```
warn: Microsoft.AspNetCore.Authorization[0]
      Authorization failed for user: (null)
      
fail: Microsoft.AspNetCore.SignalR[0]
      Failed to invoke hub method 'OnConnectedAsync'
```

## Token Flow Diagram

```
┌─────────────┐
│   Login     │
│   Page      │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────┐
│  authService.login()        │
│  - Calls backend /auth/login│
│  - Receives JWT token       │
│  - Stores in localStorage   │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  AuthContext                │
│  - Detects token exists     │
│  - Sets user in state       │
│  - Exposes getToken()       │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  RealtimeWrapper            │
│  - Calls getToken()         │
│  - Passes to RealtimeProvider│
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  signalrService             │
│  - Uses token in connection │
│  - Sends as access_token    │
│    query parameter          │
└──────┬──────────────────────┘
       │
       ▼
┌─────────────────────────────┐
│  Backend ShoppingListHub    │
│  - Validates JWT            │
│  - Extracts user ID         │
│  - Allows connection        │
└─────────────────────────────┘
```

## Common Scenarios

### Scenario 1: Fresh Login
```
1. User logs in
2. Token stored in localStorage
3. AuthContext loads user
4. RealtimeWrapper gets token
5. SignalR connects successfully ✅
```

### Scenario 2: Page Refresh
```
1. Page reloads
2. AuthContext checks localStorage
3. Token found and still valid
4. User loaded from /users/me
5. SignalR connects successfully ✅
```

### Scenario 3: Token Expired
```
1. Page loads
2. AuthContext checks localStorage
3. Token expired
4. User NOT loaded
5. SignalR does NOT connect ⚠️
6. User redirected to login
```

### Scenario 4: Logout
```
1. User clicks logout
2. Token removed from localStorage
3. AuthContext sets user to null
4. SignalR disconnects
5. RealtimeProvider stops trying ✅
```

## Verification Checklist

After applying the fix, verify:

- [ ] Frontend restarts successfully
- [ ] Can login without errors
- [ ] Token stored in localStorage (`authToken` key)
- [ ] Token expiration stored (`token_expires_at` key)
- [ ] Console shows "SignalR Connected!"
- [ ] Network tab shows WebSocket with `access_token` param
- [ ] Backend logs show user connected
- [ ] No 401 errors in console
- [ ] No CORS errors in console

## Next Steps

Once authentication is working:

1. **Test real-time events:**
   - Open 2 browser tabs
   - Add item in one → should appear in other

2. **Test reconnection:**
   - Disconnect internet
   - Reconnect
   - Should auto-reconnect

3. **Test permissions:**
   - Add permission checks in `JoinList` method
   - Verify users can only join lists they have access to

## Code Changes Summary

| File | Change | Status |
|------|--------|--------|
| `AuthContext.tsx` | Added `getToken` to interface | ✅ |
| `AuthContext.tsx` | Added `getToken` function | ✅ |
| `AuthContext.tsx` | Added `getToken` to context value | ✅ |
| `AuthContext.tsx` | Fixed ReactNode import (type-only) | ✅ |
| `RealtimeWrapper.tsx` | Replaced mock token with real token | ✅ |

## Build Status

- ✅ Backend: Compiles successfully
- ✅ Frontend: No new errors (12 pre-existing unrelated errors)
- ✅ Real-time code: All files compile

---

**Status:** ✅ Ready to test  
**Last Updated:** November 4, 2025  
**Next:** Restart frontend and verify SignalR connection

