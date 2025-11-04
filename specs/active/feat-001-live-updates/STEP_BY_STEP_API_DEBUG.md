# Step-by-Step API Debugging Guide

## What We Just Did

Added **console logging** to track the entire API call flow:

1. ✅ **ListsDashboard** - Component mount and fetch start
2. ✅ **listsService** - Service method call  
3. ✅ **apiClient** - HTTP request details and response

---

## 🚀 Testing Instructions

### Step 1: Restart Frontend

```bash
# Stop the dev server (Ctrl+C)
cd /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-ui

# Start fresh
npm run dev
```

### Step 2: Open Browser Console

1. Navigate to `http://localhost:5173`
2. Open DevTools (F12)
3. Go to **Console** tab
4. **Clear console** (🚫 icon or Ctrl+L)

### Step 3: Login and Navigate

1. Login if not already logged in
2. Navigate to `/lists` page

### Step 4: Check Console Output

You should see these messages in order:

#### ✅ Expected Output (API Working):
```
📍 ListsDashboard: Component mounted, starting fetch...
🔍 ListsDashboard: Fetching lists from API...
🌐 API GET: http://localhost:5233/api/lists?includeArchived=false
   Auth required: true
   Token: present
📥 API Response: 200 OK
✅ ListsDashboard: Got 3 lists from API: [{...}, {...}, {...}]
```

#### ❌ Problem Scenario 1: Not Logged In
```
📍 ListsDashboard: Component mounted, starting fetch...
🔍 ListsDashboard: Fetching lists from API...
🌐 API GET: http://localhost:5233/api/lists?includeArchived=false
   Auth required: true
   Token: MISSING  ⬅️ PROBLEM!
📥 API Response: 401 Unauthorized
❌ ListsDashboard: Failed to fetch lists: ApiClientError {...}
```
**Fix:** Login first!

#### ❌ Problem Scenario 2: Backend Not Running
```
📍 ListsDashboard: Component mounted, starting fetch...
🔍 ListsDashboard: Fetching lists from API...
🌐 API GET: http://localhost:5233/api/lists?includeArchived=false
   Auth required: true
   Token: present
❌ ListsDashboard: Failed to fetch lists: TypeError: Failed to fetch
```
**Fix:** Start the backend!

#### ❌ Problem Scenario 3: Component Not Mounting
```
(no console logs at all)
```
**Possible causes:**
- Not on `/lists` page
- React routing issue
- Component crashed before useEffect
- Check for other errors in console

---

## 🔍 What to Check Next

### Check 1: Network Tab

**While console is showing logs:**
1. Open **Network** tab
2. Filter by **"Fetch/XHR"**
3. **Look for** the request to `localhost:5233/api/lists`

**If you see the request:**
- ✅ API call is being made
- Check the response content
- Check if response is being parsed correctly

**If you DON'T see the request:**
- Browser might be caching
- Service worker might be intercepting
- Network tab filter might be hiding it

### Check 2: Response Content

Click on the request in Network tab:

**Headers Tab:**
- Request URL: `http://localhost:5233/api/lists?includeArchived=false`
- Request Method: GET
- Status Code: 200 OK

**Response Tab:**
```json
[
  {
    "id": "guid-here",
    "name": "My Shopping List",
    "description": "Weekly groceries",
    "ownerId": "guid",
    "owner": { "displayName": "John Doe" },
    "isArchived": false,
    "totalItems": 5,
    "purchasedItems": 2,
    "collaboratorsCount": 1,
    "createdAt": "2025-11-04T...",
    "updatedAt": "2025-11-04T..."
  }
]
```

### Check 3: Application State

In console, check React state:

```javascript
// Check if lists are in state
// (This will only work if you have React DevTools)
```

Or manually inspect:
```javascript
// Check localStorage
console.log('Token:', localStorage.getItem('auth_token'));
console.log('Expires:', localStorage.getItem('token_expires_at'));
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Component mounted" but no "Fetching lists"

**Problem:** useEffect not running  
**Possible causes:**
- Component unmounted before async function started
- React strict mode running effect twice
- Error in dependency array

**Debug:**
```javascript
// Add this to see if useEffect runs
useEffect(() => {
  console.log('👀 useEffect FIRED');
  // ... rest of code
}, [filter])
```

### Issue 2: "Fetching lists" but no API GET log

**Problem:** listsService.getAllLists() not reaching apiClient  
**Check:** Is there an error in listsService before apiClient.get()?

**Debug:** Add logging to listsService:
```typescript
async getAllLists(params?: ListsQueryParams): Promise<ShoppingListSummary[]> {
  console.log('📡 listsService.getAllLists called with params:', params);
  const dtos = await apiClient.get<BackendListDto[]>('/lists', { params })
  console.log('📦 listsService got DTOs:', dtos);
  return dtos.map(mapBackendListToSummary)
}
```

### Issue 3: API GET shown but no Response log

**Problem:** fetch() hanging or crashing  
**Possible causes:**
- Network timeout
- CORS preflight failing silently
- Backend crashed

**Check:**
1. Backend terminal - any error logs?
2. Backend still running? Try `curl http://localhost:5233`
3. CORS properly configured?

### Issue 4: Response 200 but "Failed to fetch lists"

**Problem:** Error in response parsing  
**Check:** Response body in Network tab

**Possible causes:**
- Response is not valid JSON
- Response structure doesn't match expected type
- Mapper function throwing error

**Debug:** Look at the exact error message:
```javascript
❌ ListsDashboard: Failed to fetch lists: Error: ...
```

---

## 📋 Diagnostic Checklist

Run through this step-by-step:

- [ ] Console shows "Component mounted"
- [ ] Console shows "Fetching lists from API"
- [ ] Console shows "API GET" with correct URL
- [ ] Console shows "Token: present"
- [ ] Console shows "API Response: 200 OK"
- [ ] Console shows "Got X lists from API"
- [ ] Network tab shows GET request to `/api/lists`
- [ ] Network tab shows 200 OK response
- [ ] Response body is valid JSON array
- [ ] Lists appear on the page

**If all checkmarks:**
✅ API integration is working perfectly!

**If any fail:**
Share which step failed and the exact console output.

---

## 🔧 Quick Fixes

### Fix 1: Clear Everything

```javascript
// Run in console
localStorage.clear();
sessionStorage.clear();
location.reload();
```

Then login again and navigate to `/lists`.

### Fix 2: Hard Refresh

```
Ctrl+Shift+R (Windows/Linux)
Cmd+Shift+R (Mac)
```

### Fix 3: Check .env File

```bash
cd /Users/vyacheslav.kozyrev/Projects/accelerated-engineering/source/ae-infinity-ui
cat .env.development

# Should output:
# VITE_API_BASE_URL=http://localhost:5233/api
# VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/shopping-list
```

If file doesn't exist or has wrong values, create it:

```bash
cat > .env.development << 'EOF'
VITE_API_BASE_URL=http://localhost:5233/api
VITE_SIGNALR_HUB_URL=http://localhost:5233/hubs/shopping-list
EOF
```

Then restart frontend.

### Fix 4: Test Backend Directly

```bash
# Get token from localStorage in browser console
# Then test:

curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     http://localhost:5233/api/lists

# Should return JSON array
```

---

## 📤 What to Report

If it's still not working, please share:

1. **Full console output** (copy/paste the logs)
2. **Network tab screenshot** (showing or not showing the request)
3. **Any error messages** in console
4. **Backend terminal output** (any errors there?)
5. **Response from `curl http://localhost:5233`** (to verify backend is up)

---

## 🎯 Next Steps

Once you see the API calls working:

1. **Test other endpoints:**
   - Navigate to a specific list → should call GET `/api/lists/{id}/items`
   - Add item → should call POST `/api/lists/{id}/items`
   - Delete item → should call DELETE `/api/lists/{id}/items/{id}`

2. **Remove debug logging** (once everything works):
   ```typescript
   // Remove console.log statements from:
   // - ListsDashboard.tsx
   // - apiClient.ts
   ```

3. **Test real-time sync:**
   - Open 2 browser windows
   - Add item in one → should appear in other

---

**Ready to test! Restart frontend and check the console output** 🚀

