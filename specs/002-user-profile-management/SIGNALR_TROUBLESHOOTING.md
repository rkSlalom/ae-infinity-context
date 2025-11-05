# SignalR Real-time Profile Updates - Troubleshooting Guide

## Issue
Profile updates (display name, avatar) don't immediately update in the Header component after saving changes in the Profile Settings page.

---

## Root Cause Fixed

**Problem**: The `ProfileUpdatedEventHandler` was in the API layer, but MediatR was only scanning the Application assembly for notification handlers.

**Solution**: Added MediatR registration for the API assembly in `Program.cs`:

```csharp
// Register MediatR notification handlers from API layer (for SignalR event handlers)
builder.Services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly);
});
```

---

## How to Test the Fix

### Step 1: Restart Backend
```bash
cd ae-infinity-api
dotnet run --project src/AeInfinity.Api/AeInfinity.Api.csproj
```

### Step 2: Restart Frontend
```bash
cd ae-infinity-ui
npm run dev
```

### Step 3: Test Real-time Updates

**Option A: Single Browser (requires two tabs)**
1. Open browser tab 1: `http://localhost:5173/profile/settings`
2. Open browser tab 2: `http://localhost:5173/lists` (Header visible)
3. In tab 1: Change display name to "Test User Updated"
4. Click "Save Changes"
5. **Expected**: Tab 2 Header updates immediately (within 1-2 seconds)

**Option B: Two Browsers (recommended)**
1. Browser 1 (Chrome): Login and go to `/profile/settings`
2. Browser 2 (Firefox/Edge): Login as same user, stay on `/lists`
3. In Browser 1: Update profile
4. **Expected**: Browser 2 Header updates immediately

---

## Debugging Checklist

### Backend Logs to Check

When you update a profile, you should see these logs in the backend console:

```
[Information] Profile updated successfully for User {userId}. 
DisplayName changed: true ('Old Name' -> 'New Name'), 
AvatarUrl changed: false (...)

[Debug] ProfileUpdated notification published for User {userId}

[Information] ProfileUpdatedEventHandler invoked for User {userId}. Broadcasting to SignalR...

[Information] Successfully broadcasted ProfileUpdated event for User {userId}. 
Payload: { "userId": "...", "displayName": "New Name", ... }
```

**If you DON'T see "ProfileUpdatedEventHandler invoked"**:
- ❌ MediatR handler not registered correctly
- ✅ Fixed by adding API assembly registration in Program.cs

---

### Frontend Console Logs to Check

When SignalR is working correctly, you should see:

**On page load (Header.tsx mounts)**:
```
[useProfileSync] Effect triggered - isConnected: true, user: 3fa85f64-...
[useProfileSync] Subscribing to ProfileUpdated events for user: 3fa85f64-...
[useProfileSync] Subscription created
```

**When profile is updated**:
```
[useProfileSync] ProfileUpdated event received: {
  userId: "3fa85f64-...",
  displayName: "New Name",
  avatarUrl: "https://...",
  updatedAt: "2025-11-05T..."
}
[useProfileSync] Event is for current user, updating...
[useProfileSync] User updated in context
```

**If you see**:
```
[useProfileSync] Not subscribing - connection or user not ready
```
- ❌ SignalR not connected OR user not authenticated
- ✅ Check SignalR connection state (see below)

---

## Common Issues & Solutions

### Issue 1: Handler Not Invoked
**Symptom**: Backend logs show profile updated, but no "ProfileUpdatedEventHandler invoked"

**Cause**: MediatR not discovering the handler in API assembly

**Solution**: ✅ **FIXED** - Added `builder.Services.AddMediatR()` in Program.cs (line 46-49)

---

### Issue 2: SignalR Not Connected
**Symptom**: Frontend logs show "Not subscribing - connection or user not ready"

**Check**:
1. Open browser DevTools → Console
2. Look for: `SignalR Connected! Connection ID: ...`

**If not connected**:
```bash
# Check backend is running
curl http://localhost:5233/api/health

# Check SignalR hub URL
# Should be: http://localhost:5233/hubs/shopping-list
```

**Common causes**:
- Backend not running
- CORS misconfigured
- JWT token expired
- WebSocket blocked by proxy/firewall

---

### Issue 3: Event Not Received on Frontend
**Symptom**: Backend broadcasts event, but frontend doesn't receive it

**Check browser console for**:
```
[useProfileSync] ProfileUpdated event received: {...}
```

**If NOT received**:
1. Verify SignalR connection is established
2. Check event name matches exactly: `"ProfileUpdated"`
3. Check browser Network tab → WS (WebSocket) → Messages
4. Look for SignalR message with `"target":"ProfileUpdated"`

---

### Issue 4: User ID Mismatch
**Symptom**: Event received but logs show "Event is for different user"

**Check**:
```
[useProfileSync] Event is for different user: abc123... vs def456...
```

**Cause**: Event userId doesn't match current authenticated user

**Verify**:
1. Backend logs show correct userId in payload
2. Frontend `user.id` matches the userId in the event
3. Check if userId is a string vs GUID format issue

**Fix**:
- Ensure backend sends `userId` in the same format frontend expects
- Check ProfileUpdatedNotification.UserId type (should be Guid)
- Check frontend user.id type (should be string)

---

### Issue 5: Header Not Re-rendering
**Symptom**: Event received, context updated, but Header doesn't change

**Check**:
1. Verify `setUser()` is called:
   ```
   [useProfileSync] User updated in context
   ```

2. Check Header component reads from AuthContext:
   ```tsx
   const { user } = useAuth()
   // Should display: user?.displayName
   ```

3. Verify Header uses `useProfileSync()` hook

**Current Implementation**:
```tsx
// Header.tsx
export default function Header({ onMenuToggle }: HeaderProps) {
  const { user, logout } = useAuth()
  const nav = useNavigation()
  
  // Enable real-time profile sync
  useProfileSync()  // ✅ This must be here
  ...
}
```

---

## Verification Commands

### Check MediatR Registration
```bash
cd ae-infinity-api
grep -A 5 "ProfileUpdatedEventHandler" src/AeInfinity.Api/Program.cs
```

Should include:
```csharp
builder.Services.AddMediatR(cfg =>
{
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly);
});
```

### Check Handler Exists
```bash
ls -la src/AeInfinity.Api/EventHandlers/ProfileUpdatedEventHandler.cs
```

### Check Frontend Hook Usage
```bash
cd ae-infinity-ui
grep -r "useProfileSync" src/components/layout/Header.tsx
```

Should show:
```tsx
import { useProfileSync } from '../../hooks/useProfileSync'
...
useProfileSync()
```

---

## Testing Without Two Browsers

If you only have one browser available:

### Option 1: Use Incognito Mode
1. Normal window: Login as user1
2. Incognito window: Login as user1 (same user)
3. Update profile in one, see change in other

### Option 2: Developer Console Testing
```javascript
// In browser console, manually trigger a SignalR event
// (Only works if you have access to the SignalR connection)

// Subscribe to ProfileUpdated manually
window.signalrConnection?.on('ProfileUpdated', (event) => {
  console.log('Manual subscription received:', event)
})
```

### Option 3: Backend Logging Only
- Update profile in UI
- Check backend logs for "Successfully broadcasted"
- If broadcast succeeds, SignalR is working
- Issue is likely on frontend subscription

---

## Expected Flow (Full Stack)

### 1. User Updates Profile
```
Frontend: ProfileSettings.tsx → updateProfile() → PATCH /users/me
```

### 2. Backend Processes Update
```
API: UsersController.UpdateProfile()
  ↓
Application: UpdateUserProfileCommandHandler.Handle()
  ↓
Database: User entity updated
  ↓
Application: _mediator.Publish(ProfileUpdatedNotification)
```

### 3. MediatR Dispatches Notification
```
MediatR scans registered handlers:
  - Application assembly ✅
  - API assembly ✅ (fixed)
  ↓
Invokes: ProfileUpdatedEventHandler.Handle()
```

### 4. SignalR Broadcasts Event
```
API: ProfileUpdatedEventHandler
  ↓
SignalR: _hubContext.Clients.All.SendAsync("ProfileUpdated", payload)
  ↓
All connected clients receive event
```

### 5. Frontend Receives Event
```
SignalR: WebSocket message received
  ↓
RealtimeContext: signalrService.on('ProfileUpdated', handler)
  ↓
useProfileSync: subscribe() callback invoked
  ↓
Check: event.userId === user.id
  ↓
AuthContext: setUser({ ...user, displayName, avatarUrl })
```

### 6. React Re-renders
```
AuthContext state updated
  ↓
Header component subscribed to AuthContext
  ↓
Header.tsx re-renders with new user.displayName
  ↓
✅ User sees updated name immediately!
```

---

## Performance Notes

- **Latency**: Event broadcast should take < 100ms
- **Propagation**: Updates appear within 1-2 seconds
- **SignalR reconnect**: Automatic with exponential backoff
- **Cache**: No caching of profile in Header (always fresh from context)

---

## Next Steps

1. **Restart both backend and frontend** to apply the MediatR registration fix
2. **Test with two browser tabs** as described above
3. **Check console logs** (both backend and frontend) to verify the flow
4. **Report results**: If still not working, provide logs from both sides

---

## Support

If the issue persists after applying this fix:

1. Capture **backend logs** from the moment you click "Save Changes"
2. Capture **frontend console logs** from the browser DevTools
3. Check **Network tab** → WS (WebSocket) for SignalR messages
4. Verify **MediatR registration** in Program.cs (line 46-49)

---

**Last Updated**: November 5, 2025  
**Fix Applied**: MediatR registration for API assembly  
**Status**: ✅ Should be working now - please test!

