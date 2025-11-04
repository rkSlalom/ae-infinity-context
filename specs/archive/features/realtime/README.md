# Real-time Features (SignalR)

**Feature Domain**: Real-time Features  
**Version**: 1.0  
**Status**: 0% Backend, Types Only Frontend, 0% Integrated

---

## Overview

Real-time synchronization using SignalR for live updates across collaborators.

---

## Features

| Feature | SignalR Event | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| Item Added | `ItemAdded` | ❌ | ✅ Types Only | Not Started |
| Item Updated | `ItemUpdated` | ❌ | ✅ Types Only | Not Started |
| Item Deleted | `ItemDeleted` | ❌ | ✅ Types Only | Not Started |
| Item Purchased | `ItemPurchased` | ❌ | ✅ Types Only | Not Started |
| List Updated | `ListUpdated` | ❌ | ✅ Types Only | Not Started |
| Collaborator Joined | `CollaboratorJoined` | ❌ | ✅ Types Only | Not Started |
| Collaborator Left | `CollaboratorLeft` | ❌ | ✅ Types Only | Not Started |
| Presence Changed | `PresenceChanged` | ❌ | ✅ Types Only | Not Started |

---

## API Specification

See [API_SPEC.md](../../API_SPEC.md) lines 660-701

### Hub URL
```
ws://localhost:5000/hubs/shopping-list
```

### Client → Server Methods

1. **JoinList(listId: string)**
   - Subscribe to updates for a specific list
   - User joins the list's SignalR group

2. **LeaveList(listId: string)**
   - Unsubscribe from list updates
   - User leaves the list's SignalR group

3. **UpdatePresence(listId: string, isActive: boolean)**
   - Update online/offline status
   - Notify other collaborators of presence

---

### Server → Client Events

#### ItemAdded
Triggered when someone adds an item to the list.

```typescript
interface ItemAddedEvent {
  listId: string
  item: ShoppingItem
}
```

#### ItemUpdated
Triggered when someone updates an item.

```typescript
interface ItemUpdatedEvent {
  listId: string
  item: ShoppingItem
}
```

#### ItemDeleted
Triggered when someone deletes an item.

```typescript
interface ItemDeletedEvent {
  listId: string
  itemId: string
}
```

#### ItemPurchased
Triggered when someone marks an item as purchased/unpurchased.

```typescript
interface ItemPurchasedEvent {
  listId: string
  itemId: string
  isPurchased: boolean
  purchasedBy: UserRef | null
  purchasedAt: string | null
}
```

#### ListUpdated
Triggered when list details change.

```typescript
interface ListUpdatedEvent {
  list: ShoppingListDetail
}
```

#### CollaboratorJoined
Triggered when a new collaborator accepts an invitation.

```typescript
interface CollaboratorJoinedEvent {
  listId: string
  user: UserRef
  permission: Permission
}
```

#### CollaboratorLeft
Triggered when a collaborator is removed.

```typescript
interface CollaboratorLeftEvent {
  listId: string
  userId: string
}
```

#### PresenceChanged
Triggered when a collaborator's online status changes.

```typescript
interface PresenceChangedEvent {
  listId: string
  userId: string
  isActive: boolean
}
```

---

## Frontend Implementation

### Types Defined
**Location**: `ae-infinity-ui/src/types/index.ts` ✅

All event types are defined and ready to use.

### What Needs to be Built

#### 1. SignalR Connection Service
**Location**: `ae-infinity-ui/src/services/signalrService.ts` ❌

```typescript
import * as signalR from '@microsoft/signalr'

const connection = new signalR.HubConnectionBuilder()
  .withUrl('ws://localhost:5000/hubs/shopping-list', {
    accessTokenFactory: () => tokenManager.get() || ''
  })
  .withAutomaticReconnect()
  .build()

// Export connection and methods
export const signalrService = {
  start: () => connection.start(),
  stop: () => connection.stop(),
  joinList: (listId: string) => connection.invoke('JoinList', listId),
  leaveList: (listId: string) => connection.invoke('LeaveList', listId),
  on: (eventName: string, callback: (...args: any[]) => void) => 
    connection.on(eventName, callback),
  off: (eventName: string) => connection.off(eventName)
}
```

#### 2. RealtimeContext
**Location**: `ae-infinity-ui/src/contexts/RealtimeContext.tsx` ❌

```typescript
interface RealtimeContextType {
  isConnected: boolean
  joinList: (listId: string) => void
  leaveList: (listId: string) => void
  activeUsers: Record<string, UserRef[]> // listId -> active users
}
```

#### 3. Update ListDetail Page
Add event listeners and update local state:

```typescript
useEffect(() => {
  // Join list
  signalrService.joinList(listId)

  // Listen for events
  signalrService.on('ItemAdded', (event: ItemAddedEvent) => {
    setItems(prev => [...prev, event.item])
  })

  signalrService.on('ItemUpdated', (event: ItemUpdatedEvent) => {
    setItems(prev => prev.map(item => 
      item.id === event.item.id ? event.item : item
    ))
  })

  signalrService.on('ItemDeleted', (event: ItemDeletedEvent) => {
    setItems(prev => prev.filter(item => item.id !== event.itemId))
  })

  signalrService.on('ItemPurchased', (event: ItemPurchasedEvent) => {
    setItems(prev => prev.map(item => 
      item.id === event.itemId 
        ? { ...item, isPurchased: event.isPurchased, purchasedBy: event.purchasedBy, purchasedAt: event.purchasedAt }
        : item
    ))
  })

  // Cleanup
  return () => {
    signalrService.leaveList(listId)
    signalrService.off('ItemAdded')
    signalrService.off('ItemUpdated')
    signalrService.off('ItemDeleted')
    signalrService.off('ItemPurchased')
  }
}, [listId])
```

---

## Backend Implementation

### Hub
**Location**: `ae-infinity-api/src/AeInfinity.Api/Hubs/ShoppingListHub.cs` ❌

```csharp
public class ShoppingListHub : Hub
{
    public async Task JoinList(string listId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"list:{listId}");
    }

    public async Task LeaveList(string listId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"list:{listId}");
    }

    public async Task UpdatePresence(string listId, bool isActive)
    {
        await Clients.Group($"list:{listId}")
            .SendAsync("PresenceChanged", new {
                ListId = listId,
                UserId = Context.UserIdentifier,
                IsActive = isActive
            });
    }
}
```

### Broadcasting Events
Trigger events from command handlers:

```csharp
// After creating an item
await _hubContext.Clients.Group($"list:{listId}")
    .SendAsync("ItemAdded", new ItemAddedEvent {
        ListId = listId,
        Item = newItem
    });
```

---

## Dependencies

### Frontend
- [ ] Install `@microsoft/signalr`
  ```bash
  npm install @microsoft/signalr
  ```

### Backend
- [ ] Add SignalR to Program.cs
  ```csharp
  builder.Services.AddSignalR();
  app.MapHub<ShoppingListHub>("/hubs/shopping-list");
  ```

---

## Connection Handling

### Reconnection Strategy
- Automatic reconnection with exponential backoff
- Queue pending messages during disconnect
- Rejoin groups after reconnection
- Show connection status to user

### Error Handling
- Handle connection failures gracefully
- Show offline indicator
- Fall back to polling if WebSocket unavailable
- Log connection errors

---

## User Experience

### Presence Indicators
- Show who's currently viewing the list
- Avatar stack at the top of list detail page
- Green dot for online users
- Fade out after user leaves

### Live Updates
- Smooth animations for new items
- Highlight updated items briefly
- Show who made the change
- Optimistic updates with rollback on conflict

---

## Testing Strategy

### Manual Testing
1. Open list in two browser windows
2. Add item in one window
3. Verify it appears in other window
4. Test all event types
5. Test reconnection after disconnect

### Automated Testing
- Unit tests for event handlers
- Integration tests for hub methods
- E2E tests for real-time scenarios

---

## Performance Considerations

### Scalability
- Use Redis backplane for multiple servers
- Limit number of groups per connection
- Implement message throttling
- Use delta updates instead of full objects

### Optimization
- Only send relevant data
- Batch multiple updates
- Compress large messages
- Use binary protocol for better performance

---

## Next Steps

1. 🔄 Install SignalR package (frontend)
2. 🔄 Create ShoppingListHub (backend)
3. 🔄 Add SignalR configuration (backend)
4. 🔄 Create signalrService (frontend)
5. 🔄 Create RealtimeContext (frontend)
6. 🔄 Update ListDetail page to use real-time
7. 🔄 Add presence indicators UI
8. 🔄 Test with multiple users
9. 🔄 Add connection status indicator
10. 🔄 Handle reconnection scenarios

---

## Related Features

- [Items](../items/) - Item CRUD operations
- [Lists](../lists/) - List management
- [Collaboration](../collaboration/) - Who's collaborating

