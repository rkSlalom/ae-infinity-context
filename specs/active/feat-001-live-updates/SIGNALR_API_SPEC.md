# SignalR API Specification

**Version**: 1.0  
**Last Updated**: November 4, 2025  
**Status**: API Specification - Ready for Implementation  
**Authors**: Development Team

---

## Table of Contents

1. [Overview](#overview)
2. [Connection](#connection)
3. [Hub Methods (Client → Server)](#hub-methods-client--server)
4. [Events (Server → Client)](#events-server--client)
5. [Error Responses](#error-responses)
6. [Message Format](#message-format)
7. [Protocol Details](#protocol-details)
8. [Testing](#testing)

---

## Overview

This document specifies the SignalR Hub API for real-time updates in the AE Infinity application.

### Hub Endpoint

**Development**: `ws://localhost:5233/hubs/shopping-list`  
**Production**: `wss://api.ae-infinity.com/hubs/shopping-list`

### Transport

- **Primary**: WebSocket (WSS in production)
- **Fallback 1**: Server-Sent Events (SSE)
- **Fallback 2**: Long Polling

### Authentication

All connections require JWT Bearer token authentication.

```typescript
const connection = new HubConnectionBuilder()
  .withUrl('/hubs/shopping-list', {
    accessTokenFactory: () => getJwtToken()
  })
  .build();
```

---

## Connection

### Establishing Connection

#### Request

**Protocol**: WebSocket handshake  
**URL**: `/hubs/shopping-list`  
**Headers**:
```http
Authorization: Bearer <jwt_token>
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: <generated>
Sec-WebSocket-Version: 13
```

#### Response

**Success (101 Switching Protocols)**:
```http
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: <generated>
```

Connection ID will be assigned by server and available via `connection.connectionId` on client.

**Failure (401 Unauthorized)**:
```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "error": "Unauthorized",
  "message": "JWT token is invalid or expired"
}
```

**Failure (403 Forbidden)**:
```http
HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "error": "Forbidden",
  "message": "Access denied"
}
```

### Connection Lifecycle Events

#### Connected

**Client-side Handler**:
```typescript
connection.onconnected = (connectionId?: string) => {
  console.log('Connected with ID:', connectionId);
};
```

**Triggered**: After successful connection establishment

#### Reconnecting

**Client-side Handler**:
```typescript
connection.onreconnecting = (error?: Error) => {
  console.log('Connection lost, reconnecting...', error);
};
```

**Triggered**: When connection is lost and auto-reconnect begins

#### Reconnected

**Client-side Handler**:
```typescript
connection.onreconnected = (connectionId?: string) => {
  console.log('Reconnected with ID:', connectionId);
};
```

**Triggered**: After successful reconnection

#### Closed

**Client-side Handler**:
```typescript
connection.onclose = (error?: Error) => {
  console.log('Connection closed', error);
};
```

**Triggered**: When connection is permanently closed

---

## Hub Methods (Client → Server)

These are methods that clients can invoke on the server.

### 1. JoinList

Join a list room to start receiving real-time updates for that list.

#### Method Signature

```typescript
async joinList(listId: string): Promise<void>
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| listId | string (GUID) | Yes | The ID of the list to join |

#### Request Example

**TypeScript Client**:
```typescript
await connection.invoke('JoinList', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
```

**C# Server Handler**:
```csharp
public async Task JoinList(Guid listId)
{
    // Implementation
}
```

#### Success Response

**Status**: No explicit response (Promise resolves)

**Side Effects**:
1. Connection added to list group
2. `UserJoined` event broadcast to other users in list
3. `PresenceUpdate` event sent to caller with current active users

#### Error Responses

**Access Denied (HubException)**:
```json
{
  "type": "HubException",
  "message": "Access denied",
  "stackTrace": null
}
```

**Scenarios**:
- User does not have access to the list
- User's access was revoked
- List does not exist

**Invalid List ID**:
```json
{
  "type": "HubException",
  "message": "Invalid list ID",
  "stackTrace": null
}
```

#### Authorization

- User MUST have any permission (Owner, Editor, or Viewer) on the list
- Permission is checked using `IListPermissionService.HasAccessAsync()`

#### Notes

- User can join multiple lists simultaneously
- Same user can have multiple connections (different tabs/devices)
- Connection tracking is per-connection, not per-user

---

### 2. LeaveList

Leave a list room to stop receiving updates for that list.

#### Method Signature

```typescript
async leaveList(listId: string): Promise<void>
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| listId | string (GUID) | Yes | The ID of the list to leave |

#### Request Example

**TypeScript Client**:
```typescript
await connection.invoke('LeaveList', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
```

**C# Server Handler**:
```csharp
public async Task LeaveList(Guid listId)
{
    // Implementation
}
```

#### Success Response

**Status**: No explicit response (Promise resolves)

**Side Effects**:
1. Connection removed from list group
2. `UserLeft` event broadcast to other users in list

#### Error Responses

Generally does not throw errors. If user is not in the list group, silently succeeds.

#### Notes

- Called automatically on disconnect
- Safe to call even if not in the list group
- Called when navigating away from list detail page

---

### 3. UpdatePresence

Send heartbeat to indicate user is still active on the list.

#### Method Signature

```typescript
async updatePresence(listId: string): Promise<void>
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| listId | string (GUID) | Yes | The ID of the list being viewed |

#### Request Example

**TypeScript Client**:
```typescript
// Called every 30 seconds while user is on list page
setInterval(() => {
  connection.invoke('UpdatePresence', listId);
}, 30000);
```

**C# Server Handler**:
```csharp
public async Task UpdatePresence(Guid listId)
{
    // Implementation
}
```

#### Success Response

**Status**: No explicit response (Promise resolves)

**Side Effects**:
1. Last seen timestamp updated for connection
2. Presence status refreshed

#### Error Responses

Generally does not throw errors.

**Special Case**: If user no longer has access to list, they are automatically removed from the group:
```json
{
  "type": "HubException",
  "message": "Access denied - you have been removed from this list",
  "stackTrace": null
}
```

#### Authorization

- Re-checks user access on each call
- If access revoked, user is automatically removed from list group

#### Notes

- Should be called every 30 seconds
- Used to maintain "active" status
- Users inactive for >45 seconds are considered offline
- Lightweight operation (updates timestamp only)

---

## Events (Server → Client)

These are events that the server broadcasts to connected clients.

### Event Message Format

All events follow this structure:

```typescript
{
  eventType: string,        // Event type identifier
  listId: string,           // List ID (GUID)
  timestamp: string,        // ISO 8601 datetime (UTC)
  ...                       // Event-specific payload
}
```

### Listening for Events

**TypeScript Client**:
```typescript
connection.on('EventName', (event: EventType) => {
  console.log('Received event:', event);
  // Handle event
});
```

---

### Item Events

#### ItemAdded

Broadcast when a new item is added to the list.

**Event Name**: `ItemAdded`

**Payload**:
```typescript
{
  eventType: "ItemAdded",
  listId: "guid",
  item: {
    id: "guid",
    listId: "guid",
    name: "string",
    quantity: number,
    unit: "string | null",
    categoryId: "guid",
    category: {
      id: "guid",
      name: "string",
      icon: "string",
      color: "string"
    },
    notes: "string | null",
    imageUrl: "string | null",
    isPurchased: false,
    position: number,
    createdBy: {
      id: "guid",
      displayName: "string",
      avatarUrl: "string | null"
    },
    createdAt: "ISO8601 datetime",
    updatedAt: "ISO8601 datetime"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "ItemAdded",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "item": {
    "id": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
    "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Organic Milk",
    "quantity": 2,
    "unit": "gallons",
    "categoryId": "c3d4e5f6-g7h8-9012-cdef-gh3456789012",
    "category": {
      "id": "c3d4e5f6-g7h8-9012-cdef-gh3456789012",
      "name": "Dairy",
      "icon": "🥛",
      "color": "#E3F2FD"
    },
    "notes": "Whole milk preferred",
    "imageUrl": null,
    "isPurchased": false,
    "position": 13,
    "createdBy": {
      "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
      "displayName": "Sarah Johnson",
      "avatarUrl": null
    },
    "createdAt": "2025-11-04T10:30:00Z",
    "updatedAt": "2025-11-04T10:30:00Z"
  },
  "timestamp": "2025-11-04T10:30:00.123Z"
}
```

**Broadcast To**: All users in list group (except the user who created the item gets it via REST API response)

**Client Handling**:
```typescript
connection.on('ItemAdded', (event: ItemAddedEvent) => {
  // Add item to local state
  setItems(prev => [...prev, event.item]);
  
  // Show notification
  showToast(`${event.item.createdBy.displayName} added ${event.item.name}`);
  
  // Animate new item
  animateItemAdded(event.item.id);
});
```

---

#### ItemUpdated

Broadcast when an item is modified.

**Event Name**: `ItemUpdated`

**Payload**:
```typescript
{
  eventType: "ItemUpdated",
  listId: "guid",
  item: {
    id: "guid",
    listId: "guid",
    name: "string",
    quantity: number,
    unit: "string | null",
    categoryId: "guid",
    category: {
      id: "guid",
      name: "string",
      icon: "string",
      color: "string"
    },
    notes: "string | null",
    imageUrl: "string | null",
    isPurchased: boolean,
    position: number,
    createdBy: {
      id: "guid",
      displayName: "string"
    },
    updatedAt: "ISO8601 datetime",
    updatedBy: {
      id: "guid",
      displayName: "string",
      avatarUrl: "string | null"
    }
  },
  changedFields: ["name", "quantity", "categoryId"], // Array of changed field names
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "ItemUpdated",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "item": {
    "id": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
    "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Organic Whole Milk",
    "quantity": 3,
    "unit": "gallons",
    "categoryId": "c3d4e5f6-g7h8-9012-cdef-gh3456789012",
    "category": {
      "id": "c3d4e5f6-g7h8-9012-cdef-gh3456789012",
      "name": "Dairy",
      "icon": "🥛",
      "color": "#E3F2FD"
    },
    "notes": "Whole milk preferred",
    "imageUrl": null,
    "isPurchased": false,
    "position": 13,
    "createdBy": {
      "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
      "displayName": "Sarah Johnson"
    },
    "updatedAt": "2025-11-04T10:35:00Z",
    "updatedBy": {
      "id": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
      "displayName": "Mike Chen",
      "avatarUrl": null
    }
  },
  "changedFields": ["name", "quantity"],
  "timestamp": "2025-11-04T10:35:00.456Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('ItemUpdated', (event: ItemUpdatedEvent) => {
  // Check for conflict (user is editing this item)
  if (editingItemId === event.item.id) {
    showConflictWarning(event);
    return;
  }
  
  // Update item in local state
  setItems(prev => prev.map(item => 
    item.id === event.item.id ? event.item : item
  ));
  
  // Show notification
  showToast(`${event.item.updatedBy.displayName} updated ${event.item.name}`);
  
  // Highlight changed item
  highlightItem(event.item.id);
});
```

---

#### ItemDeleted

Broadcast when an item is deleted from the list.

**Event Name**: `ItemDeleted`

**Payload**:
```typescript
{
  eventType: "ItemDeleted",
  listId: "guid",
  itemId: "guid",
  deletedBy: {
    id: "guid",
    displayName: "string",
    avatarUrl: "string | null"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "ItemDeleted",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "itemId": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
  "deletedBy": {
    "id": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
    "displayName": "Mike Chen",
    "avatarUrl": null
  },
  "timestamp": "2025-11-04T10:40:00.789Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('ItemDeleted', (event: ItemDeletedEvent) => {
  // Remove item from local state
  setItems(prev => prev.filter(item => item.id !== event.itemId));
  
  // Show notification
  showToast(`${event.deletedBy.displayName} deleted an item`);
  
  // Animate removal
  animateItemRemoved(event.itemId);
});
```

---

#### ItemPurchasedStatusChanged

Broadcast when an item's purchased status is toggled.

**Event Name**: `ItemPurchasedStatusChanged`

**Payload**:
```typescript
{
  eventType: "ItemPurchasedStatusChanged",
  listId: "guid",
  itemId: "guid",
  isPurchased: boolean,
  purchasedAt: "ISO8601 datetime | null",
  purchasedBy: {
    id: "guid",
    displayName: "string",
    avatarUrl: "string | null"
  } | null,
  timestamp: "ISO8601 datetime"
}
```

**Example** (Marked as Purchased):
```json
{
  "eventType": "ItemPurchasedStatusChanged",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "itemId": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
  "isPurchased": true,
  "purchasedAt": "2025-11-04T10:45:00Z",
  "purchasedBy": {
    "id": "f6g7h8i9-j0k1-2345-fghi-jk6789012345",
    "displayName": "Alex Rivera",
    "avatarUrl": null
  },
  "timestamp": "2025-11-04T10:45:00.234Z"
}
```

**Example** (Marked as Not Purchased):
```json
{
  "eventType": "ItemPurchasedStatusChanged",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "itemId": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
  "isPurchased": false,
  "purchasedAt": null,
  "purchasedBy": null,
  "timestamp": "2025-11-04T10:50:00.567Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('ItemPurchasedStatusChanged', (event: ItemPurchasedStatusChangedEvent) => {
  // Update item's purchased status
  setItems(prev => prev.map(item => 
    item.id === event.itemId 
      ? { 
          ...item, 
          isPurchased: event.isPurchased,
          purchasedAt: event.purchasedAt,
          purchasedBy: event.purchasedBy
        }
      : item
  ));
  
  // Show notification
  if (event.isPurchased) {
    showToast(`${event.purchasedBy?.displayName} marked item as purchased`);
  }
  
  // Update progress indicators
  updateProgress();
});
```

---

### List Events

#### ListUpdated

Broadcast when list details (name or description) are updated.

**Event Name**: `ListUpdated`

**Payload**:
```typescript
{
  eventType: "ListUpdated",
  listId: "guid",
  changes: {
    name?: "string",
    description?: "string"
  },
  updatedBy: {
    id: "guid",
    displayName: "string",
    avatarUrl: "string | null"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "ListUpdated",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "changes": {
    "name": "Weekly Groceries - Updated",
    "description": "Our weekly shopping list for the family"
  },
  "updatedBy": {
    "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
    "displayName": "Sarah Johnson",
    "avatarUrl": null
  },
  "timestamp": "2025-11-04T11:00:00.890Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('ListUpdated', (event: ListUpdatedEvent) => {
  // Update list details
  setList(prev => ({
    ...prev,
    ...event.changes
  }));
  
  // Update browser tab title if name changed
  if (event.changes.name) {
    document.title = event.changes.name;
  }
  
  // Show notification
  showToast(`${event.updatedBy.displayName} updated the list`);
});
```

---

#### ListArchived

Broadcast when list is archived or unarchived.

**Event Name**: `ListArchived`

**Payload**:
```typescript
{
  eventType: "ListArchived",
  listId: "guid",
  isArchived: boolean,
  archivedBy: {
    id: "guid",
    displayName: "string"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "ListArchived",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "isArchived": true,
  "archivedBy": {
    "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
    "displayName": "Sarah Johnson"
  },
  "timestamp": "2025-11-04T11:05:00.123Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('ListArchived', (event: ListArchivedEvent) => {
  // Update list status
  setList(prev => ({
    ...prev,
    isArchived: event.isArchived
  }));
  
  // Show banner notification
  if (event.isArchived) {
    showBanner(`This list was archived by ${event.archivedBy.displayName}`);
    makeReadOnly();
  } else {
    showBanner(`This list was unarchived by ${event.archivedBy.displayName}`);
    makeEditable();
  }
});
```

---

#### ItemsReordered

Broadcast when items are reordered (drag-and-drop).

**Event Name**: `ItemsReordered`

**Payload**:
```typescript
{
  eventType: "ItemsReordered",
  listId: "guid",
  itemPositions: [
    {
      itemId: "guid",
      position: number
    }
  ],
  reorderedBy: {
    id: "guid",
    displayName: "string"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "ItemsReordered",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "itemPositions": [
    { "itemId": "b2c3d4e5-f6g7-8901-bcde-fg2345678901", "position": 1 },
    { "itemId": "c3d4e5f6-g7h8-9012-cdef-gh3456789012", "position": 2 },
    { "itemId": "d4e5f6g7-h8i9-0123-defg-hi4567890123", "position": 3 }
  ],
  "reorderedBy": {
    "id": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
    "displayName": "Mike Chen"
  },
  "timestamp": "2025-11-04T11:10:00.456Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('ItemsReordered', (event: ItemsReorderedEvent) => {
  // Update positions
  setItems(prev => {
    const positionMap = new Map(
      event.itemPositions.map(p => [p.itemId, p.position])
    );
    
    return prev
      .map(item => ({
        ...item,
        position: positionMap.get(item.id) ?? item.position
      }))
      .sort((a, b) => a.position - b.position);
  });
  
  // Optional: Show subtle notification
  // (Don't show for every reorder as it can be noisy)
});
```

---

### Collaboration Events

#### CollaboratorAdded

Broadcast when a new collaborator is added to the list.

**Event Name**: `CollaboratorAdded`

**Payload**:
```typescript
{
  eventType: "CollaboratorAdded",
  listId: "guid",
  collaborator: {
    userId: "guid",
    displayName: "string",
    avatarUrl: "string | null",
    email: "string",
    permission: "Owner" | "Editor" | "Viewer",
    invitedAt: "ISO8601 datetime",
    acceptedAt: "ISO8601 datetime | null"
  },
  invitedBy: {
    id: "guid",
    displayName: "string"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "CollaboratorAdded",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "collaborator": {
    "userId": "g7h8i9j0-k1l2-3456-ghij-kl7890123456",
    "displayName": "Emma Davis",
    "avatarUrl": null,
    "email": "emma@example.com",
    "permission": "Editor",
    "invitedAt": "2025-11-04T11:15:00Z",
    "acceptedAt": "2025-11-04T11:16:30Z"
  },
  "invitedBy": {
    "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
    "displayName": "Sarah Johnson"
  },
  "timestamp": "2025-11-04T11:16:30.789Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('CollaboratorAdded', (event: CollaboratorAddedEvent) => {
  // Add to collaborators list
  setCollaborators(prev => [...prev, event.collaborator]);
  
  // Show notification
  showToast(`${event.invitedBy.displayName} added ${event.collaborator.displayName} to the list`);
  
  // Update collaborator count
  updateCollaboratorCount();
});
```

---

#### CollaboratorRemoved

Broadcast when a collaborator is removed from the list.

**Event Name**: `CollaboratorRemoved`

**Payload**:
```typescript
{
  eventType: "CollaboratorRemoved",
  listId: "guid",
  userId: "guid",
  displayName: "string",
  removedBy: {
    id: "guid",
    displayName: "string"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "CollaboratorRemoved",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "userId": "g7h8i9j0-k1l2-3456-ghij-kl7890123456",
  "displayName": "Emma Davis",
  "removedBy": {
    "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
    "displayName": "Sarah Johnson"
  },
  "timestamp": "2025-11-04T11:20:00.123Z"
}
```

**Broadcast To**: All users in list group (including the removed user)

**Client Handling**:
```typescript
connection.on('CollaboratorRemoved', (event: CollaboratorRemovedEvent) => {
  // Remove from collaborators list
  setCollaborators(prev => prev.filter(c => c.userId !== event.userId));
  
  // If current user was removed, redirect
  if (event.userId === currentUserId) {
    showError('You have been removed from this list');
    navigate('/lists');
    return;
  }
  
  // Show notification
  showToast(`${event.removedBy.displayName} removed ${event.displayName} from the list`);
});
```

---

#### CollaboratorPermissionChanged

Broadcast when a collaborator's permission level is changed.

**Event Name**: `CollaboratorPermissionChanged`

**Payload**:
```typescript
{
  eventType: "CollaboratorPermissionChanged",
  listId: "guid",
  userId: "guid",
  displayName: "string",
  oldPermission: "Owner" | "Editor" | "Viewer",
  newPermission: "Owner" | "Editor" | "Viewer",
  changedBy: {
    id: "guid",
    displayName: "string"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "CollaboratorPermissionChanged",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "userId": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
  "displayName": "Mike Chen",
  "oldPermission": "Editor",
  "newPermission": "Viewer",
  "changedBy": {
    "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
    "displayName": "Sarah Johnson"
  },
  "timestamp": "2025-11-04T11:25:00.456Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('CollaboratorPermissionChanged', (event: CollaboratorPermissionChangedEvent) => {
  // Update collaborator permission
  setCollaborators(prev => prev.map(c =>
    c.userId === event.userId
      ? { ...c, permission: event.newPermission }
      : c
  ));
  
  // If current user's permission changed, update UI
  if (event.userId === currentUserId) {
    updatePermissions(event.newPermission);
    
    if (event.newPermission === 'Viewer') {
      makeReadOnly();
      showWarning(`Your permission changed to Viewer. You can no longer edit items.`);
    }
  } else {
    showToast(`${event.changedBy.displayName} changed ${event.displayName}'s permission to ${event.newPermission}`);
  }
});
```

---

### Presence Events

#### UserJoined

Broadcast when a user joins the list (starts viewing).

**Event Name**: `UserJoined`

**Payload**:
```typescript
{
  eventType: "UserJoined",
  listId: "guid",
  user: {
    id: "guid",
    displayName: "string",
    avatarUrl: "string | null"
  },
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "UserJoined",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "user": {
    "id": "f6g7h8i9-j0k1-2345-fghi-jk6789012345",
    "displayName": "Alex Rivera",
    "avatarUrl": null
  },
  "timestamp": "2025-11-04T11:30:00.789Z"
}
```

**Broadcast To**: All users in list group (except the user who joined)

**Client Handling**:
```typescript
connection.on('UserJoined', (event: UserJoinedEvent) => {
  // Add to active users
  setActiveUsers(prev => [...prev, event.user]);
  
  // Show subtle notification
  showToast(`${event.user.displayName} is viewing this list`, { duration: 2000 });
  
  // Update presence indicator
  updatePresenceIndicator();
});
```

---

#### UserLeft

Broadcast when a user leaves the list (stops viewing).

**Event Name**: `UserLeft`

**Payload**:
```typescript
{
  eventType: "UserLeft",
  listId: "guid",
  userId: "guid",
  displayName: "string",
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "UserLeft",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "userId": "f6g7h8i9-j0k1-2345-fghi-jk6789012345",
  "displayName": "Alex Rivera",
  "timestamp": "2025-11-04T11:35:00.123Z"
}
```

**Broadcast To**: All users in list group

**Client Handling**:
```typescript
connection.on('UserLeft', (event: UserLeftEvent) => {
  // Remove from active users
  setActiveUsers(prev => prev.filter(u => u.id !== event.userId));
  
  // Update presence indicator
  updatePresenceIndicator();
  
  // Optional: Show notification (can be noisy)
  // showToast(`${event.displayName} left`, { duration: 2000 });
});
```

---

#### PresenceUpdate

Sent to newly joined user with snapshot of all currently active users.

**Event Name**: `PresenceUpdate`

**Payload**:
```typescript
{
  eventType: "PresenceUpdate",
  listId: "guid",
  activeUsers: [
    {
      id: "guid",
      displayName: "string",
      avatarUrl: "string | null",
      joinedAt: "ISO8601 datetime"
    }
  ],
  timestamp: "ISO8601 datetime"
}
```

**Example**:
```json
{
  "eventType": "PresenceUpdate",
  "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "activeUsers": [
    {
      "id": "d4e5f6g7-h8i9-0123-defg-hi4567890123",
      "displayName": "Sarah Johnson",
      "avatarUrl": null,
      "joinedAt": "2025-11-04T10:00:00Z"
    },
    {
      "id": "e5f6g7h8-i9j0-1234-efgh-ij5678901234",
      "displayName": "Mike Chen",
      "avatarUrl": null,
      "joinedAt": "2025-11-04T11:15:00Z"
    }
  ],
  "timestamp": "2025-11-04T11:40:00.456Z"
}
```

**Sent To**: Individual caller (when they join a list)

**Client Handling**:
```typescript
connection.on('PresenceUpdate', (event: PresenceUpdateEvent) => {
  // Set active users (replacing any existing)
  setActiveUsers(event.activeUsers);
  
  // Update presence indicator
  updatePresenceIndicator();
  
  // Show count
  if (event.activeUsers.length > 0) {
    showInfo(`${event.activeUsers.length} ${pluralize('person', event.activeUsers.length)} viewing`);
  }
});
```

---

## Error Responses

### HubException

All Hub method errors are thrown as `HubException` and caught on the client.

**Format**:
```typescript
{
  type: "HubException",
  message: string,
  stackTrace?: string
}
```

### Common Error Messages

#### Access Denied
```json
{
  "type": "HubException",
  "message": "Access denied"
}
```

**When**: User doesn't have permission to access the list

**Client Handling**:
```typescript
try {
  await connection.invoke('JoinList', listId);
} catch (error: any) {
  if (error.message === 'Access denied') {
    showError('You don\'t have access to this list');
    navigate('/lists');
  }
}
```

#### User Not Authenticated
```json
{
  "type": "HubException",
  "message": "User not authenticated"
}
```

**When**: JWT token is missing or invalid

**Client Handling**: Redirect to login

#### Invalid List ID
```json
{
  "type": "HubException",
  "message": "Invalid list ID"
}
```

**When**: List ID is malformed or list doesn't exist

#### Rate Limit Exceeded
```json
{
  "type": "HubException",
  "message": "Rate limit exceeded. Please try again later."
}
```

**When**: User exceeds 100 requests per minute

---

## Message Format

### JSON Protocol

Default protocol for SignalR is JSON.

**Message Types**:
1. **Invocation** - Client calling server method
2. **StreamInvocation** - Not used
3. **StreamItem** - Not used
4. **Completion** - Server method result
5. **Ping/Pong** - Keep-alive
6. **Close** - Connection closed

**Example Invocation Message** (Client → Server):
```json
{
  "type": 1,
  "invocationId": "1",
  "target": "JoinList",
  "arguments": ["a1b2c3d4-e5f6-7890-abcd-ef1234567890"]
}
```

**Example Event Message** (Server → Client):
```json
{
  "type": 1,
  "target": "ItemAdded",
  "arguments": [{
    "eventType": "ItemAdded",
    "listId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "item": { /* ... */ },
    "timestamp": "2025-11-04T10:30:00.123Z"
  }]
}
```

### MessagePack Protocol (Optional)

For better performance, MessagePack protocol can be used.

**Benefits**:
- 30-50% smaller message size
- Faster serialization/deserialization
- Binary format

**Server Configuration**:
```csharp
builder.Services.AddSignalR()
    .AddMessagePackProtocol();
```

**Client Configuration**:
```typescript
import { MessagePackHubProtocol } from '@microsoft/signalr-protocol-msgpack';

const connection = new HubConnectionBuilder()
  .withUrl('/hubs/shopping-list')
  .withHubProtocol(new MessagePackHubProtocol())
  .build();
```

---

## Protocol Details

### Keep-Alive

**Server Configuration**:
```csharp
builder.Services.AddSignalR(options =>
{
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
});
```

**Behavior**:
- Server sends ping every 15 seconds if no other messages sent
- Client must respond with pong
- If client doesn't respond within 30 seconds, connection is closed
- Client automatically sends pong (handled by SignalR library)

### Reconnection

**Client Configuration**:
```typescript
const connection = new HubConnectionBuilder()
  .withUrl('/hubs/shopping-list')
  .withAutomaticReconnect({
    nextRetryDelayInMilliseconds: (retryContext) => {
      const delays = [1000, 2000, 5000, 10000, 30000];
      return delays[retryContext.previousRetryCount] || null;
    }
  })
  .build();
```

**Behavior**:
- Automatic reconnection attempts with exponential backoff
- After 5 failed attempts, stops trying
- Returns `null` to stop reconnection
- On successful reconnection, `onreconnected` event fires

### Buffer Limits

**Server Configuration**:
```csharp
builder.Services.AddSignalR(options =>
{
    options.MaximumReceiveMessageSize = 32 * 1024; // 32 KB
});
```

**Client Configuration**:
```typescript
const connection = new HubConnectionBuilder()
  .withUrl('/hubs/shopping-list', {
    maxMessageSize: 32 * 1024 // 32 KB
  })
  .build();
```

---

## Testing

### Manual Testing with JavaScript Console

**Connect**:
```javascript
const connection = new signalR.HubConnectionBuilder()
  .withUrl('/hubs/shopping-list', {
    accessTokenFactory: () => 'your-jwt-token-here'
  })
  .build();

await connection.start();
console.log('Connected');
```

**Join List**:
```javascript
await connection.invoke('JoinList', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
console.log('Joined list');
```

**Listen for Events**:
```javascript
connection.on('ItemAdded', (event) => {
  console.log('Item added:', event);
});

connection.on('ItemUpdated', (event) => {
  console.log('Item updated:', event);
});
```

**Update Presence**:
```javascript
await connection.invoke('UpdatePresence', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
console.log('Presence updated');
```

**Leave List**:
```javascript
await connection.invoke('LeaveList', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
console.log('Left list');
```

**Disconnect**:
```javascript
await connection.stop();
console.log('Disconnected');
```

### Integration Testing

**C# Integration Test Example**:
```csharp
public class SignalRHubTests : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task JoinList_WithValidAccess_SendsPresenceUpdate()
    {
        // Arrange
        var connection = CreateConnection();
        await connection.StartAsync();
        
        var presenceReceived = new TaskCompletionSource<PresenceUpdateEvent>();
        connection.On<PresenceUpdateEvent>("PresenceUpdate", (evt) => 
        {
            presenceReceived.SetResult(evt);
        });
        
        // Act
        await connection.InvokeAsync("JoinList", TestData.ListId);
        
        // Assert
        var result = await presenceReceived.Task.WaitAsync(TimeSpan.FromSeconds(5));
        Assert.NotNull(result);
        Assert.Equal(TestData.ListId, result.ListId);
    }
}
```

### Load Testing

**Artillery.io Example**:
```yaml
config:
  target: "ws://localhost:5233"
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 300
      arrivalRate: 50
      name: "Sustained load"
  engines:
    ws: {}

scenarios:
  - name: "Join list and receive events"
    engine: ws
    flow:
      - connect:
          url: "/hubs/shopping-list"
          headers:
            Authorization: "Bearer {{ $randomJWT }}"
      - send:
          type: 1
          target: "JoinList"
          arguments: ["{{ $randomListId }}"]
      - think: 300
      - send:
          type: 1
          target: "UpdatePresence"
          arguments: ["{{ $randomListId }}"]
      - think: 30
      - send:
          type: 1
          target: "LeaveList"
          arguments: ["{{ $randomListId }}"]
```

---

## Appendix: TypeScript Event Type Definitions

### Complete Type Definitions

```typescript
// src/types/signalr-events.ts

export interface ItemAddedEvent {
  eventType: 'ItemAdded';
  listId: string;
  item: ShoppingItem;
  timestamp: string;
}

export interface ItemUpdatedEvent {
  eventType: 'ItemUpdated';
  listId: string;
  item: ShoppingItem;
  changedFields: string[];
  timestamp: string;
}

export interface ItemDeletedEvent {
  eventType: 'ItemDeleted';
  listId: string;
  itemId: string;
  deletedBy: UserRef;
  timestamp: string;
}

export interface ItemPurchasedStatusChangedEvent {
  eventType: 'ItemPurchasedStatusChanged';
  listId: string;
  itemId: string;
  isPurchased: boolean;
  purchasedAt: string | null;
  purchasedBy: UserRef | null;
  timestamp: string;
}

export interface ListUpdatedEvent {
  eventType: 'ListUpdated';
  listId: string;
  changes: {
    name?: string;
    description?: string;
  };
  updatedBy: UserRef;
  timestamp: string;
}

export interface ListArchivedEvent {
  eventType: 'ListArchived';
  listId: string;
  isArchived: boolean;
  archivedBy: UserRef;
  timestamp: string;
}

export interface ItemsReorderedEvent {
  eventType: 'ItemsReordered';
  listId: string;
  itemPositions: Array<{
    itemId: string;
    position: number;
  }>;
  reorderedBy: UserRef;
  timestamp: string;
}

export interface CollaboratorAddedEvent {
  eventType: 'CollaboratorAdded';
  listId: string;
  collaborator: Collaborator;
  invitedBy: UserRef;
  timestamp: string;
}

export interface CollaboratorRemovedEvent {
  eventType: 'CollaboratorRemoved';
  listId: string;
  userId: string;
  displayName: string;
  removedBy: UserRef;
  timestamp: string;
}

export interface CollaboratorPermissionChangedEvent {
  eventType: 'CollaboratorPermissionChanged';
  listId: string;
  userId: string;
  displayName: string;
  oldPermission: Permission;
  newPermission: Permission;
  changedBy: UserRef;
  timestamp: string;
}

export interface UserJoinedEvent {
  eventType: 'UserJoined';
  listId: string;
  user: ActiveUser;
  timestamp: string;
}

export interface UserLeftEvent {
  eventType: 'UserLeft';
  listId: string;
  userId: string;
  displayName: string;
  timestamp: string;
}

export interface PresenceUpdateEvent {
  eventType: 'PresenceUpdate';
  listId: string;
  activeUsers: ActiveUser[];
  timestamp: string;
}

// Union type for all events
export type SignalREvent =
  | ItemAddedEvent
  | ItemUpdatedEvent
  | ItemDeletedEvent
  | ItemPurchasedStatusChangedEvent
  | ListUpdatedEvent
  | ListArchivedEvent
  | ItemsReorderedEvent
  | CollaboratorAddedEvent
  | CollaboratorRemovedEvent
  | CollaboratorPermissionChangedEvent
  | UserJoinedEvent
  | UserLeftEvent
  | PresenceUpdateEvent;
```

---

**Document Status**: ✅ Complete and ready for implementation

**Next Document**: See LIVE_UPDATES_IMPLEMENTATION_GUIDE.md for step-by-step implementation instructions.

