# API Diagnostic Script

## Run this in Browser Console

Open your browser console (F12) and run this script to diagnose why API calls aren't showing:

```javascript
// ========================================
// API Diagnostic Script
// ========================================

console.log('🔍 Running API Diagnostics...\n');

// 1. Check Authentication
const token = localStorage.getItem('auth_token');
console.log('1️⃣ Authentication:');
console.log('   Token exists:', !!token);
console.log('   Token value:', token ? token.substring(0, 20) + '...' : 'null');

// 2. Check API Base URL
const apiUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5233/api';
console.log('\n2️⃣ API Configuration:');
console.log('   Base URL:', apiUrl);
console.log('   Full lists endpoint:', apiUrl + '/lists');

// 3. Test Manual API Call
console.log('\n3️⃣ Testing Manual API Call...');
fetch(apiUrl + '/lists', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
})
  .then(response => {
    console.log('   Response Status:', response.status, response.statusText);
    return response.json();
  })
  .then(data => {
    console.log('   Response Data:', data);
    console.log('   ✅ API is working! Got', data.length, 'lists');
  })
  .catch(error => {
    console.error('   ❌ API call failed:', error);
  });

// 4. Check if on correct page
console.log('\n4️⃣ Current Page:');
console.log('   URL:', window.location.href);
console.log('   Path:', window.location.pathname);

// 5. Check Network Tab Instructions
console.log('\n📋 Network Tab Checklist:');
console.log('   1. Open DevTools Network tab');
console.log('   2. Make sure "Preserve log" is checked');
console.log('   3. Filter by "Fetch/XHR"');
console.log('   4. Navigate to /lists page');
console.log('   5. Look for: GET request to http://localhost:5233/api/lists');

console.log('\n✅ Diagnostic complete!');
```

## What to Look For:

### ✅ Expected Output (Everything Working):
```
🔍 Running API Diagnostics...

1️⃣ Authentication:
   Token exists: true
   Token value: eyJhbGciOiJIUzI1N...

2️⃣ API Configuration:
   Base URL: http://localhost:5233/api
   Full lists endpoint: http://localhost:5233/api/lists

3️⃣ Testing Manual API Call...
   Response Status: 200 OK
   Response Data: [{id: "...", name: "My List", ...}]
   ✅ API is working! Got 3 lists

4️⃣ Current Page:
   URL: http://localhost:5173/lists
   Path: /lists
```

### ❌ Problem: No Token
```
1️⃣ Authentication:
   Token exists: false
   Token value: null
```
**Fix:** You're not logged in. Go to /login and sign in.

### ❌ Problem: 401 Unauthorized
```
3️⃣ Testing Manual API Call...
   Response Status: 401 Unauthorized
```
**Fix:** Token is expired or invalid. Logout and login again.

### ❌ Problem: Network Error
```
3️⃣ Testing Manual API Call...
   ❌ API call failed: TypeError: Failed to fetch
```
**Fix:** Backend is not running or not accessible. Start the backend.

### ❌ Problem: Wrong URL
```
2️⃣ API Configuration:
   Base URL: http://localhost:5000/api  ❌ WRONG PORT!
```
**Fix:** Update `.env.development` to use correct port (5233).

---

## Manual API Test (Alternative)

If the script doesn't work, test manually with curl:

```bash
# Get your token from browser console
TOKEN=$(node -e "console.log(localStorage.getItem('auth_token'))")

# Test the API
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     http://localhost:5233/api/lists

# Should return JSON array of lists
```

---

## Check Network Tab

### Make Sure These Settings Are Enabled:

1. **Open DevTools** (F12)
2. **Go to Network Tab**
3. **Check "Preserve log"** ✓
4. **Filter by "Fetch/XHR"**
5. **Disable cache** (optional, but helps)

### What You Should See:

When you navigate to `/lists` page:

```
Name                    Status  Type        Size    Time
─────────────────────────────────────────────────────────
lists?includeArchived=  200     xhr         2.1 KB  150ms
```

**Request Details:**
- URL: `http://localhost:5233/api/lists?includeArchived=false`
- Method: GET
- Status: 200 OK
- Response: Array of lists

### If You Don't See It:

**Possible Causes:**

1. **Already cached** - Clear cache and hard refresh (Ctrl+Shift+R)
2. **Filter wrong** - Make sure "Fetch/XHR" filter is selected
3. **Page didn't load** - Check if ListsDashboard component mounted
4. **Error before API call** - Check browser console for errors
5. **Using mock data** - Frontend might be using fallback mock data

---

## Check Console for Errors

Look for these error messages:

### ❌ "Failed to fetch lists"
```javascript
Failed to fetch lists: Error: ...
```
This means the API call was attempted but failed.

### ❌ Network errors
```javascript
TypeError: Failed to fetch
net::ERR_CONNECTION_REFUSED
```
Backend is not running or wrong URL.

### ❌ CORS errors
```javascript
Access to fetch at 'http://localhost:5233/api/lists' from origin 'http://localhost:5173'
has been blocked by CORS policy
```
Backend CORS not configured (but we already fixed this).

---

## Verify .env.development File

Make sure you have this file:

**Location:** `/ae-infinity-ui/.env.development`

**Contents:**
```
VITE_API_BASE_URL=http://localhost:5233/api
VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/shopping-list
```

**If missing:**
```bash
cd /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-ui

cat > .env.development << 'EOF'
VITE_API_BASE_URL=http://localhost:5233/api
VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/shopping-list
EOF

# Then restart frontend
npm run dev
```

---

## Test API Directly

Test if backend is actually responding:

```bash
# Test 1: Backend is up
curl -i http://localhost:5233

# Expected: HTTP/1.1 200 OK (Swagger page)

# Test 2: Auth endpoint works
curl -X POST http://localhost:5233/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"Email":"test@example.com","Password":"Test123!"}'

# Expected: { "token": "eyJ...", "user": {...} }

# Test 3: Lists endpoint (needs token)
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://localhost:5233/api/lists

# Expected: [ {...}, {...} ] (array of lists)
```

---

## Common Issues & Fixes

### Issue 1: "API calls don't appear in Network tab"

**Possible causes:**
1. ✅ Using mock data instead of real API
2. ✅ Network tab filter hiding requests
3. ✅ Request happened before opening DevTools
4. ✅ Service worker intercepting requests

**Fix:**
- Clear browser cache
- Hard refresh (Ctrl+Shift+R)
- Check "Preserve log" in Network tab
- Navigate to /lists page AFTER opening Network tab

### Issue 2: "Lists page is empty but no errors"

**Possible causes:**
1. API returns empty array `[]`
2. Token is valid but user has no lists
3. API filtering out lists

**Fix:**
- Check API response in Network tab
- Verify backend database has lists
- Try creating a new list

### Issue 3: "Page loads but shows old data"

**Possible causes:**
1. Browser caching responses
2. Service worker caching
3. React state not updating

**Fix:**
```javascript
// Clear all storage
localStorage.clear();
sessionStorage.clear();

// Unregister service workers
navigator.serviceWorker.getRegistrations()
  .then(registrations => {
    registrations.forEach(r => r.unregister());
  });

// Hard refresh
location.reload();
```

---

## Quick Test Checklist

Run through this checklist:

- [ ] Backend running on port 5233
- [ ] Can access Swagger at http://localhost:5233
- [ ] Frontend running on port 5173
- [ ] `.env.development` file exists with correct URLs
- [ ] Logged in (token in localStorage)
- [ ] Token not expired (check `token_expires_at`)
- [ ] Network tab open with "Preserve log" checked
- [ ] No console errors
- [ ] Navigate to /lists page
- [ ] See GET request to `/api/lists` in Network tab

---

## Still Not Working?

If you've tried everything and still don't see API calls:

### Option 1: Add Debug Logging

Temporarily add this to `apiClient.ts`:

```typescript
// In the get() method, add this before fetch:
async get<T>(endpoint: string, options: RequestOptions = {}): Promise<T> {
  const { params, requiresAuth = true, ...fetchOptions } = options
  const url = this.buildUrl(endpoint, params)
  
  // 🔍 DEBUG
  console.log('🌐 API GET:', url);
  console.log('   Headers:', this.buildHeaders(requiresAuth));
  
  const response = await fetch(url, {
    ...fetchOptions,
    method: 'GET',
    headers: this.buildHeaders(requiresAuth),
  })
  
  // 🔍 DEBUG
  console.log('📥 Response:', response.status, response.statusText);
  
  return this.handleResponse<T>(response)
}
```

### Option 2: Test with Postman/Insomnia

1. Get your token from localStorage
2. Make GET request to `http://localhost:5233/api/lists`
3. Add header: `Authorization: Bearer YOUR_TOKEN`
4. Should return array of lists

If Postman works but browser doesn't:
- Problem is in frontend code
- Check browser console for errors
- Check if React component is even mounting

If Postman doesn't work:
- Problem is in backend
- Check backend logs
- Verify database has data
- Check authentication configuration

---

**Next Step:** Run the diagnostic script above and share the output!

