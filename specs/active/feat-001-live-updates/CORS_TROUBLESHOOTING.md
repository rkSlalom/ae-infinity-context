# SignalR CORS Troubleshooting Guide

## Quick Fix Summary

### Changes Made to Fix CORS:

1. **✅ Fixed Backend Port** - Updated frontend to use port `5233` (matches `launchSettings.json`)
2. **✅ Moved CORS Earlier** - `app.UseCors()` now before authentication
3. **✅ Added Explicit Hub CORS** - Hub endpoint now explicitly requires CORS policy
4. **✅ Disabled HTTPS Redirect** - In development only, to simplify testing

---

## Step-by-Step Testing

### 1. Start the Backend

```bash
cd /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-api
dotnet run
```

**Expected output:**
```
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://localhost:5233
...
Starting AE Infinity API with SignalR support...
```

**✅ Verify:** Backend is running on **port 5233**

### 2. Create Frontend .env File

Since `.env` files are gitignored, you need to create them manually:

```bash
cd /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-ui

# Create .env.development file
cat > .env.development << 'EOF'
# API Configuration
VITE_API_BASE_URL=http://localhost:5233

# SignalR Configuration
VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/shopping-list
EOF
```

**Or manually create** `.env.development` with these contents:
```
VITE_API_BASE_URL=http://localhost:5233
VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/shopping-list
```

### 3. Start the Frontend

```bash
cd /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-ui
npm run dev
```

**Expected output:**
```
VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:5173/
```

**✅ Verify:** Frontend is running on **port 5173**

### 4. Test SignalR Connection

1. Open browser to `http://localhost:5173`
2. Open **Developer Console** (F12)
3. Log in to the app
4. Look for SignalR connection logs

**✅ Expected Console Output:**
```
SignalR Connected! Connection ID: xyz123...
User connected with connection xyz123
```

**❌ If you see CORS errors:**
```
Access to XMLHttpRequest at 'http://localhost:5233/hubs/shopping-list/negotiate?negotiateVersion=1' 
from origin 'http://localhost:5173' has been blocked by CORS policy
```

---

## CORS Error Debugging Checklist

### ✅ Check 1: Correct Backend Port

**Issue:** Frontend trying to connect to wrong port

**Check:**
```bash
# In backend, verify what port is actually running
lsof -i :5233
# OR
netstat -an | grep 5233
```

**Fix:** Make sure `VITE_SIGNALR_HUB_URL` in `.env.development` matches the backend port

### ✅ Check 2: CORS Policy Applied

**Issue:** CORS middleware not applied correctly

**Verify in browser Network tab:**
1. Open DevTools → Network tab
2. Try to connect to SignalR
3. Look for the OPTIONS request (preflight) to `/hubs/shopping-list/negotiate`
4. Check the response headers

**Expected Response Headers:**
```
Access-Control-Allow-Origin: http://localhost:5173
Access-Control-Allow-Credentials: true
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: *
```

**❌ If missing these headers:**
- Backend CORS is not configured properly
- Check `Program.cs` has correct CORS policy
- Verify `app.UseCors("AllowAll")` is called BEFORE `app.UseAuthentication()`

### ✅ Check 3: Frontend Origin Matches

**Issue:** Frontend running on different port than CORS allows

**Check your CORS policy in `Program.cs`:**
```csharp
policy.WithOrigins("http://localhost:5173", "http://localhost:3000")
```

**If your frontend is on a different port:**
- Add it to the `WithOrigins()` list
- Or use `.AllowAnyOrigin()` (NOT recommended for production)

### ✅ Check 4: Authentication Token

**Issue:** JWT token not being sent or is invalid

**Check in browser Network tab:**
1. Find the WebSocket connection request
2. Look at Request Headers
3. Verify `access_token` query parameter is present

**Expected:**
```
Request URL: ws://localhost:5233/hubs/shopping-list?access_token=eyJ...
```

**❌ If token is missing:**
- Check `AuthContext` is providing the token
- Verify `RealtimeWrapper.tsx` is passing token to `RealtimeProvider`

**Current Limitation:** The code uses a mock token. You need to update `RealtimeWrapper.tsx`:

```typescript
// TEMPORARY FIX - Replace mock token
const { user, getToken } = useAuth();
const token = user ? getToken() : null; // Use actual token from auth
```

### ✅ Check 5: Browser Console Errors

**Look for specific error messages:**

#### Error: "Failed to start the connection: Error: WebSocket failed to connect"
**Cause:** Backend not running or wrong URL
**Fix:** 
- Verify backend is running on port 5233
- Check firewall/antivirus not blocking

#### Error: "Error during negotiate: 401 Unauthorized"
**Cause:** JWT token invalid or missing
**Fix:**
- Implement real token in `AuthContext`
- Check token expiry

#### Error: "Connection closed with an error"
**Cause:** SignalR hub throwing exception
**Fix:**
- Check backend logs for exception details
- Verify `GetUserId()` can parse user ID from token

---

## Testing Without Authentication (Temporary)

If you want to test the connection without auth first, temporarily modify the hub:

### Option A: Remove [Authorize] Attribute (TESTING ONLY!)

In `ShoppingListHub.cs`:
```csharp
// [Authorize] // <-- Comment this out temporarily
public class ShoppingListHub : Hub
```

**⚠️ WARNING:** This removes all security! Only for local testing. Revert immediately after.

### Option B: Use Anonymous CORS Policy

In `Program.cs`:
```csharp
options.AddPolicy("AllowAll", policy =>
{
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader();
    // Remove .AllowCredentials() when using AllowAnyOrigin()
});
```

**⚠️ WARNING:** Less secure, development only.

---

## Verification Script

Run this to verify your configuration:

```bash
# Check backend is running
curl -I http://localhost:5233

# Check SignalR negotiate endpoint (should get 401 without auth, not CORS error)
curl -X POST http://localhost:5233/hubs/shopping-list/negotiate \
  -H "Origin: http://localhost:5173" \
  -v

# Check preflight OPTIONS request
curl -X OPTIONS http://localhost:5233/hubs/shopping-list/negotiate \
  -H "Origin: http://localhost:5173" \
  -H "Access-Control-Request-Method: POST" \
  -v
```

**Expected:** 
- First curl: Should return 200 OK (API is up)
- Second curl: Should return 401 Unauthorized (auth required, but CORS is OK)
- Third curl: Should return 204 No Content with CORS headers

**❌ If you get:**
- Connection refused → Backend not running
- CORS error in response → CORS policy not applied

---

## Current Implementation Status

### ✅ Working:
- Backend builds successfully
- SignalR hub configured
- CORS policy defined
- Connection manager implemented
- Hub methods (JoinList, LeaveList, UpdatePresence) implemented

### ⚠️ Known Issues:
1. **Mock JWT Token** - `RealtimeWrapper.tsx` uses placeholder token
   - **Impact:** Real authentication won't work
   - **Fix:** Update `AuthContext` to expose `getToken()` method
   
2. **No .env File** - Frontend doesn't have `.env.development` by default
   - **Impact:** Will default to wrong port (5000 instead of 5233)
   - **Fix:** Create `.env.development` as shown above

3. **Pre-existing TS Errors** - 12 TypeScript errors in unrelated files
   - **Impact:** None on runtime, but build fails in CI/CD
   - **Fix:** Address separately (not blocking for testing)

---

## Success Indicators

### ✅ Connection Successful:
```
[Browser Console]
SignalR Connected! Connection ID: abc123...

[Backend Logs]
info: AeInfinity.Api.Hubs.ShoppingListHub[0]
      User 12345-67890... connected with connection abc123
```

### ✅ Can Join List:
```
[Browser Console]
User joined list successfully

[Backend Logs]
info: AeInfinity.Api.Hubs.ShoppingListHub[0]
      User 12345... joining list 98765...
      User 12345... joined list 98765... successfully
```

### ✅ Receiving Real-Time Events:
```
[Browser Console]
Real-time: Item added {id: "...", name: "Milk", ...}
```

---

## Quick Reference

### Backend Configuration
- **File:** `src/AeInfinity.Api/Program.cs`
- **Port:** 5233 (http)
- **CORS:** Lines 98-107
- **Hub Mapping:** Lines 140-141

### Frontend Configuration
- **File:** `src/services/realtime/signalrService.ts`
- **Default URL:** `http://localhost:5233/hubs/shopping-list`
- **Override:** Set `VITE_SIGNALR_HUB_URL` in `.env.development`

### Middleware Order (CRITICAL!)
```csharp
app.UseCors("AllowAll");          // ← Must be FIRST
app.UseAuthentication();
app.UseAuthorization();
app.MapHub<ShoppingListHub>(...); // ← Must use .RequireCors()
```

---

## Still Having Issues?

### Check Backend Logs
```bash
# Run backend with detailed logging
cd ae-infinity-api
ASPNETCORE_ENVIRONMENT=Development dotnet run --urls "http://localhost:5233"
```

Look for:
- SignalR connection attempts
- CORS rejections
- Authentication failures
- Hub exceptions

### Enable SignalR Client Logging
In `signalrService.ts`:
```typescript
.configureLogging(signalR.LogLevel.Debug) // Change from Information to Debug
```

### Test from Different Browser
- Try Chrome Incognito
- Try Firefox
- Check browser console for CORS policy errors

### Network Tab Analysis
1. Open DevTools → Network
2. Filter: "WS" (WebSocket)
3. Find the SignalR connection
4. Check:
   - Request Headers (Origin, access_token)
   - Response Headers (CORS headers)
   - Messages tab (see SignalR frames)

---

## Next Steps After CORS is Fixed

1. ✅ Verify connection establishes
2. ✅ Test JoinList method
3. ✅ Test real-time events (add item in one tab, see in another)
4. ✅ Implement real JWT token from AuthContext
5. ✅ Add permission checks to JoinList method
6. ✅ Test with multiple users
7. ✅ Test reconnection after network interruption

---

**Last Updated:** November 4, 2025  
**Status:** CORS configuration updated - Ready for testing

