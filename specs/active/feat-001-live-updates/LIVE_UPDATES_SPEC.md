# Live Updates Feature Specification

**Version**: 1.0  
**Last Updated**: November 4, 2025  
**Status**: Specification - Ready for Implementation  
**Authors**: Development Team

---

## Table of Contents

1. [Overview](#overview)
2. [Goals and Objectives](#goals-and-objectives)
3. [User Stories](#user-stories)
4. [Functional Requirements](#functional-requirements)
5. [Event Types and Payloads](#event-types-and-payloads)
6. [User Experience Requirements](#user-experience-requirements)
7. [Performance Requirements](#performance-requirements)
8. [Security Requirements](#security-requirements)
9. [Error Handling](#error-handling)
10. [Edge Cases](#edge-cases)
11. [Success Metrics](#success-metrics)
12. [Out of Scope](#out-of-scope)

---

## Overview

The Live Updates feature enables real-time synchronization of shopping list changes across all connected users. When any user with access to a list makes a change (adds, updates, deletes, or marks an item as purchased), all other users viewing that list will see the update immediately without needing to refresh the page.

This feature implements WebSocket-based real-time communication using:
- **Backend**: SignalR Hub in .NET 9.0 API
- **Frontend**: SignalR Client in React TypeScript application

### Key Capabilities

1. **Real-time Item Operations**
   - Item added to list
   - Item updated (name, quantity, category, notes)
   - Item deleted from list
   - Item marked as purchased/unpurchased

2. **Real-time List Operations**
   - List details updated (name, description)
   - List archived/unarchived
   - Items reordered (drag-and-drop)

3. **Real-time Collaboration**
   - Collaborator added to list
   - Collaborator removed from list
   - Collaborator permission changed
   - User presence indicators

4. **Connection Management**
   - Automatic connection on list view
   - Automatic reconnection on disconnect
   - Connection status indicators
   - Graceful degradation when offline

---

## Goals and Objectives

### Primary Goals

1. **Seamless Collaboration**: Enable multiple users to work on the same shopping list simultaneously without conflicts or confusion
2. **Real-time Feedback**: Provide immediate visual feedback when changes occur, with clear indication of who made the change
3. **Reliability**: Ensure updates are delivered reliably with automatic reconnection and error recovery
4. **Performance**: Maintain low latency (<200ms) for update delivery and minimal impact on UI performance
5. **Scalability**: Support multiple concurrent lists and users without performance degradation

### Secondary Goals

1. **User Awareness**: Show which users are currently viewing the list (presence)
2. **Conflict Prevention**: Prevent or gracefully handle simultaneous edits to the same item
3. **Offline Support**: Queue changes when offline and sync when connection is restored
4. **Bandwidth Efficiency**: Minimize data transfer by sending only changed data

---

## User Stories

### US-1: Real-time Item Addition
**As a** list viewer  
**I want** to see new items appear immediately when other collaborators add them  
**So that** I have an up-to-date view of what needs to be purchased

**Acceptance Criteria:**
- ✅ New items appear within 200ms of being added
- ✅ Visual animation indicates the item was just added
- ✅ Creator's name is displayed with the new item
- ✅ Items appear in the correct position (sorted by position field)
- ✅ No page refresh required

### US-2: Real-time Item Update
**As a** list viewer  
**I want** to see item changes immediately when other collaborators edit them  
**So that** I don't work with outdated information

**Acceptance Criteria:**
- ✅ Updates to name, quantity, unit, category, or notes appear immediately
- ✅ Brief highlight animation shows which item changed
- ✅ Editor's name is shown in a tooltip or notification
- ✅ My current focus/selection is not disrupted by updates
- ✅ If I'm editing the same item, I see a conflict warning

### US-3: Real-time Item Deletion
**As a** list viewer  
**I want** to see items disappear immediately when collaborators delete them  
**So that** I don't try to interact with deleted items

**Acceptance Criteria:**
- ✅ Deleted items fade out with smooth animation
- ✅ Brief notification shows who deleted the item
- ✅ If I'm viewing the deleted item's details, I'm notified and redirected
- ✅ List item count updates immediately

### US-4: Real-time Purchase Status
**As a** list viewer  
**I want** to see when items are marked as purchased by other shoppers  
**So that** I don't duplicate purchases

**Acceptance Criteria:**
- ✅ Purchased status changes appear immediately
- ✅ Visual indication shows who marked the item as purchased
- ✅ Item moves to purchased section if filtered view is active
- ✅ Purchased count and progress bar update immediately
- ✅ Timestamp shows when item was purchased

### US-5: Real-time List Updates
**As a** list viewer  
**I want** to see when list details are updated by collaborators  
**So that** I always see the current list name and description

**Acceptance Criteria:**
- ✅ List name updates appear in header immediately
- ✅ List description updates appear immediately
- ✅ Brief notification shows who made the change
- ✅ Browser tab title updates if list name changed

### US-6: Real-time Collaborator Changes
**As a** list viewer  
**I want** to be notified when collaborators are added or removed  
**So that** I know who has access to the list

**Acceptance Criteria:**
- ✅ New collaborators appear in the collaborators sidebar immediately
- ✅ Removed collaborators disappear immediately
- ✅ Notification shows when someone joins or leaves
- ✅ Collaborator count updates immediately
- ✅ Permission changes are reflected immediately

### US-7: User Presence Awareness
**As a** list viewer  
**I want** to see which collaborators are currently viewing the list  
**So that** I can coordinate with them in real-time

**Acceptance Criteria:**
- ✅ Active users show a green dot or "online" indicator
- ✅ User avatars in sidebar show presence status
- ✅ Tooltip shows "Viewing now" for active users
- ✅ Presence updates within 5 seconds of user joining/leaving
- ✅ "X people viewing" counter displays in header

### US-8: Connection Status Feedback
**As a** list viewer  
**I want** to know when I'm disconnected from real-time updates  
**So that** I understand my view might be stale

**Acceptance Criteria:**
- ✅ Connection status indicator visible in UI
- ✅ Warning message when disconnected
- ✅ Automatic reconnection attempts
- ✅ Success message when reconnected
- ✅ Option to manually refresh if reconnection fails

### US-9: Optimistic Updates
**As a** list editor  
**I want** my changes to appear immediately in my own view  
**So that** the interface feels responsive

**Acceptance Criteria:**
- ✅ My changes appear instantly (optimistic update)
- ✅ Change is confirmed when server acknowledges
- ✅ If server rejects, change is rolled back with error message
- ✅ Loading indicators only shown for slow operations (>500ms)
- ✅ No jarring UI jumps or flickers

### US-10: Conflict Resolution
**As a** list editor  
**I want** to be warned when editing an item that someone else just changed  
**So that** I don't accidentally overwrite their changes

**Acceptance Criteria:**
- ✅ Warning shown if item was modified while I'm editing
- ✅ Option to see what changed and merge or overwrite
- ✅ Clear indication of who made the conflicting change
- ✅ Option to cancel my edit and accept their change
- ✅ Conflict detected within 1 second of occurrence

---

## Functional Requirements

### FR-1: Connection Management

#### FR-1.1: Automatic Connection
- System SHALL automatically establish WebSocket connection when user views a list detail page
- Connection SHALL be authenticated using the user's JWT token
- Connection SHALL join the specific list's group/room

#### FR-1.2: Connection Lifecycle
- System SHALL maintain connection state: Disconnected, Connecting, Connected, Reconnecting
- System SHALL display connection status in UI
- System SHALL log connection events for debugging

#### FR-1.3: Automatic Reconnection
- System SHALL automatically attempt reconnection when connection is lost
- Reconnection attempts SHALL use exponential backoff: 1s, 2s, 5s, 10s, 30s
- System SHALL stop reconnection attempts after 5 failures and prompt user
- On successful reconnection, system SHALL re-join the list group

#### FR-1.4: Graceful Disconnection
- System SHALL properly disconnect when user navigates away from list
- System SHALL leave the list group on disconnect
- System SHALL clean up event listeners on disconnect

### FR-2: Event Broadcasting

#### FR-2.1: Item Events
- System SHALL broadcast `ItemAdded` event when item is created
- System SHALL broadcast `ItemUpdated` event when item is modified
- System SHALL broadcast `ItemDeleted` event when item is removed
- System SHALL broadcast `ItemPurchasedStatusChanged` event when purchase status changes
- Events SHALL include full item data and metadata (user, timestamp)

#### FR-2.2: List Events
- System SHALL broadcast `ListUpdated` event when list details change
- System SHALL broadcast `ListArchived` event when list is archived
- System SHALL broadcast `ItemsReordered` event when items are reordered
- Events SHALL include only changed data and list identifier

#### FR-2.3: Collaboration Events
- System SHALL broadcast `CollaboratorAdded` event when user is added
- System SHALL broadcast `CollaboratorRemoved` event when user is removed
- System SHALL broadcast `CollaboratorPermissionChanged` event when permissions change
- Events SHALL include user information and permission details

#### FR-2.4: Presence Events
- System SHALL broadcast `UserJoined` event when user starts viewing list
- System SHALL broadcast `UserLeft` event when user stops viewing list
- System SHALL send periodic heartbeat to maintain presence
- System SHALL consider user inactive after 30 seconds without heartbeat

### FR-3: Authorization and Security

#### FR-3.1: Connection Authorization
- System SHALL verify JWT token before accepting connection
- System SHALL reject connections with invalid or expired tokens
- System SHALL verify user has access to list before allowing join

#### FR-3.2: Event Authorization
- System SHALL only broadcast events to users with access to the list
- System SHALL verify user permissions before allowing actions
- System SHALL not expose data from lists user doesn't have access to

#### FR-3.3: Data Validation
- System SHALL validate all event data before broadcasting
- System SHALL sanitize user-provided data to prevent XSS
- System SHALL enforce maximum payload sizes

### FR-4: Client-Side Event Handling

#### FR-4.1: Event Reception
- Client SHALL listen for all relevant event types
- Client SHALL update local state immediately on event receipt
- Client SHALL maintain event order based on timestamps

#### FR-4.2: UI Updates
- Client SHALL animate changes for user awareness
- Client SHALL use different animations for different event types
- Client SHALL batch multiple rapid updates to prevent UI thrashing

#### FR-4.3: Optimistic Updates
- Client SHALL apply changes optimistically for user's own actions
- Client SHALL mark optimistic changes as "pending"
- Client SHALL confirm optimistic changes on server acknowledgment
- Client SHALL rollback optimistic changes on server rejection

#### FR-4.4: Conflict Detection
- Client SHALL detect when editing an item that was recently modified
- Client SHALL warn user of conflicts before saving
- Client SHALL provide options to merge, overwrite, or cancel

### FR-5: Error Handling and Recovery

#### FR-5.1: Connection Errors
- System SHALL handle WebSocket errors gracefully
- System SHALL display user-friendly error messages
- System SHALL provide manual reconnection option

#### FR-5.2: Event Errors
- System SHALL log failed event broadcasts
- System SHALL retry failed event deliveries (up to 3 times)
- System SHALL handle malformed event data without crashing

#### FR-5.3: State Synchronization
- System SHALL provide full state refresh mechanism
- Client SHALL request full refresh after prolonged disconnection
- System SHALL detect and resolve state inconsistencies

---

## Event Types and Payloads

### Item Events

#### ItemAdded
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

#### ItemUpdated
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

#### ItemDeleted
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

#### ItemPurchasedStatusChanged
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

### List Events

#### ListUpdated
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

#### ListArchived
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

#### ItemsReordered
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

### Collaboration Events

#### CollaboratorAdded
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

#### CollaboratorRemoved
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

#### CollaboratorPermissionChanged
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

### Presence Events

#### UserJoined
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

#### UserLeft
```typescript
{
  eventType: "UserLeft",
  listId: "guid",
  userId: "guid",
  displayName: "string",
  timestamp: "ISO8601 datetime"
}
```

#### PresenceUpdate
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

---

## User Experience Requirements

### UX-1: Visual Feedback

#### Animations
- **Item Added**: Slide in from top with gentle bounce, 300ms duration
- **Item Updated**: Brief yellow highlight fade, 500ms duration
- **Item Deleted**: Fade out and collapse, 400ms duration
- **Purchase Status**: Checkbox animation + item strike-through/highlight

#### Colors
- **Success**: Green (#10B981) - Item added, purchase marked
- **Warning**: Yellow (#F59E0B) - Item updated, conflict detected
- **Danger**: Red (#EF4444) - Item deleted, error occurred
- **Info**: Blue (#3B82F6) - Collaborator joined, presence update

### UX-2: Notifications

#### Toast Notifications
- Display for 4 seconds by default
- Allow dismiss by click or swipe
- Stack maximum 3 notifications
- Position: Top-right corner

#### Notification Types
- **Item Changes**: "{User} added {ItemName}"
- **Collaborator**: "{User} joined the list"
- **Connection**: "Reconnected successfully"
- **Error**: "Failed to update item. Retrying..."

### UX-3: Connection Status Indicator

#### States
- **Connected**: Small green dot in header, no intrusive message
- **Connecting**: Yellow pulsing dot, small message "Connecting..."
- **Disconnected**: Red dot, warning banner "Disconnected - trying to reconnect"
- **Reconnecting**: Yellow dot, message "Reconnecting... (Attempt X/5)"

#### Placement
- Header: Small status indicator next to list name
- Banner: Full-width warning banner for disconnected state
- Footer: Detailed connection info (for debugging)

### UX-4: Presence Display

#### Active Users
- Display in collaborators sidebar
- Show green dot next to active users
- Show "X people viewing" in header
- Limit display to 10 users (show "+X more" if exceeded)

#### User Avatars
- Stack first 3 avatars in header
- Show initials if no avatar image
- Hover tooltip shows full name and "Viewing now"

### UX-5: Conflict Handling

#### Edit Conflict Modal
```
Title: "Item was just updated"
Message: "{User} updated this item while you were editing."

Changes made by {User}:
- Name changed from "Milk" to "Whole Milk"
- Quantity changed from 1 to 2

Your unsaved changes:
- Name: "Organic Milk"

Actions:
[Cancel My Changes] [Keep My Changes]
```

---

## Performance Requirements

### PR-1: Latency
- Event delivery: < 200ms (95th percentile)
- Connection establishment: < 1 second
- Reconnection: < 3 seconds
- UI update after event: < 50ms

### PR-2: Throughput
- Support 1,000 concurrent connections per server instance
- Handle 100 events/second per list without degradation
- Batch updates if >10 events received within 100ms

### PR-3: Resource Usage

#### Client-Side
- Maximum 5MB memory overhead for SignalR client
- No memory leaks during long sessions (8+ hours)
- CPU usage < 5% during idle state
- CPU spike < 20% during high-frequency updates

#### Server-Side
- Maximum 1MB memory per connection
- CPU usage < 70% at 1,000 concurrent connections
- Message queue depth < 100 messages

### PR-4: Scalability
- Horizontal scaling: Support Redis backplane for multi-server deployment
- Support 10,000+ total concurrent users across cluster
- Linear performance degradation with load

### PR-5: Bandwidth
- Average message size: < 1KB
- Connection overhead: < 10KB
- Heartbeat: 1 message every 30 seconds (< 100 bytes)
- Total bandwidth per user: < 5KB/minute during normal usage

---

## Security Requirements

### SEC-1: Authentication
- All WebSocket connections MUST be authenticated
- JWT token MUST be validated on connection
- Token expiration MUST be checked continuously
- Expired tokens MUST trigger disconnection and reauth prompt

### SEC-2: Authorization
- Users can ONLY join lists they have access to
- Event broadcasting MUST respect list permissions
- Permission changes MUST immediately affect event delivery
- Removed collaborators MUST be immediately disconnected

### SEC-3: Data Protection
- All WebSocket traffic MUST use WSS (WebSocket Secure)
- Messages MUST NOT contain sensitive data (passwords, tokens)
- User emails MUST be omitted from events (only show display names)
- Error messages MUST NOT leak implementation details

### SEC-4: Rate Limiting
- Maximum 100 events per user per minute
- Exceeding limit triggers 429 Too Many Requests
- Repeated violations result in temporary ban (5 minutes)
- Rate limiting per connection and per user

### SEC-5: Input Validation
- All event payloads MUST be validated
- Field lengths MUST be enforced (same as REST API)
- Malformed events MUST be rejected with error
- XSS prevention on all string fields

---

## Error Handling

### Error Categories

#### ERR-1: Connection Errors
**ConnectionFailed**
- Code: `CONNECTION_FAILED`
- Message: "Failed to establish connection"
- Action: Retry with exponential backoff

**ConnectionLost**
- Code: `CONNECTION_LOST`
- Message: "Connection lost"
- Action: Automatic reconnection attempts

**AuthenticationFailed**
- Code: `AUTH_FAILED`
- Message: "Authentication failed"
- Action: Redirect to login

**AuthorizationFailed**
- Code: `ACCESS_DENIED`
- Message: "You don't have access to this list"
- Action: Redirect to lists dashboard

#### ERR-2: Event Errors
**InvalidEventData**
- Code: `INVALID_EVENT`
- Message: "Invalid event data received"
- Action: Log error, ignore event

**EventProcessingFailed**
- Code: `EVENT_FAILED`
- Message: "Failed to process event"
- Action: Log error, show notification, retry

**StateDesync**
- Code: `STATE_DESYNC`
- Message: "Data out of sync"
- Action: Trigger full refresh

#### ERR-3: Server Errors
**ServerError**
- Code: `SERVER_ERROR`
- Message: "Server error occurred"
- Action: Show error, attempt reconnection

**ServiceUnavailable**
- Code: `SERVICE_UNAVAILABLE`
- Message: "Service temporarily unavailable"
- Action: Retry after delay

**RateLimitExceeded**
- Code: `RATE_LIMIT`
- Message: "Too many requests"
- Action: Throttle user actions, show warning

### Error Handling Strategy

1. **Client-Side Errors**: Log, show user-friendly message, attempt recovery
2. **Server-Side Errors**: Log with context, send error event to user
3. **Network Errors**: Automatic retry with backoff
4. **Auth Errors**: Clear session, redirect to login
5. **Validation Errors**: Show specific field errors, prevent action

---

## Edge Cases

### EDGE-1: Simultaneous Edits
**Scenario**: Two users edit the same item simultaneously

**Handling**:
1. Both users see optimistic updates immediately
2. First request to reach server wins (Last-Write-Wins)
3. Second user receives `ItemUpdated` event with winning changes
4. Second user sees conflict warning: "Item was updated by {User}"
5. Second user can choose to overwrite or cancel

### EDGE-2: Item Deleted While Editing
**Scenario**: User is editing an item that another user deletes

**Handling**:
1. Editor receives `ItemDeleted` event
2. Edit form shows error: "{User} deleted this item"
3. Form is disabled with option to restore (create new) or cancel
4. If user submits anyway, server returns 404 Not Found
5. Client rolls back optimistic update

### EDGE-3: Permission Downgraded While Editing
**Scenario**: User's permission changes from Editor to Viewer while editing

**Handling**:
1. User receives `CollaboratorPermissionChanged` event
2. UI immediately becomes read-only
3. Current edit is discarded with notification
4. User sees: "Your permission changed to Viewer"

### EDGE-4: List Archived While Viewing
**Scenario**: List is archived by owner while user is viewing

**Handling**:
1. All viewers receive `ListArchived` event
2. Banner shows: "This list was archived by {User}"
3. UI becomes read-only
4. Option to unarchive (if owner) or navigate away

### EDGE-5: Prolonged Disconnection
**Scenario**: User is disconnected for >5 minutes

**Handling**:
1. On reconnection, client requests full state refresh
2. Server returns complete current state
3. Client replaces local state with server state
4. Notification: "Reconnected. List refreshed."
5. Any pending optimistic updates are discarded

### EDGE-6: Rapid Item Additions
**Scenario**: User or automation adds 50 items rapidly

**Handling**:
1. Client batches updates every 100ms
2. Instead of 50 separate animations, show batch notification
3. Notification: "25 items added by {User}"
4. Items appear in bulk without individual animations
5. Performance remains smooth

### EDGE-7: Network Switching
**Scenario**: Mobile user switches from WiFi to cellular

**Handling**:
1. WebSocket connection drops
2. Client detects network change event
3. Immediate reconnection attempt (no backoff)
4. Seamless reconnection within 1-2 seconds
5. User sees brief "Reconnecting..." message

### EDGE-8: Browser Tab Backgrounded
**Scenario**: User switches to different browser tab for extended time

**Handling**:
1. Heartbeat continues in background
2. Events are queued if tab is throttled
3. On tab focus, queued events are processed
4. If >100 events queued, trigger full refresh instead
5. Presence is maintained (user still shown as active)

### EDGE-9: Multiple Tabs Same User
**Scenario**: User opens same list in multiple browser tabs

**Handling**:
1. Each tab establishes separate connection
2. Each tab receives all events
3. Events originating from one tab update other tabs
4. No special handling needed (works naturally)
5. User shown once in presence list (server deduplicates)

### EDGE-10: Server Restart
**Scenario**: Server restarts during active usage

**Handling**:
1. All connections are dropped
2. Clients attempt reconnection (exponential backoff)
3. Clients reconnect once server is back up
4. Clients request full state refresh
5. Notification: "Reconnected after server maintenance"

---

## Success Metrics

### Metric 1: Latency
- **Target**: 95th percentile event delivery < 200ms
- **Measurement**: Log timestamp on server and client, calculate delta
- **Success Criteria**: 95% of events delivered within 200ms

### Metric 2: Reliability
- **Target**: 99.9% event delivery success rate
- **Measurement**: Track sent events vs acknowledged events
- **Success Criteria**: <0.1% event loss rate

### Metric 3: Connection Stability
- **Target**: 99% uptime during user session
- **Measurement**: Track connection state changes per session
- **Success Criteria**: <1% of session time in disconnected state

### Metric 4: Reconnection Speed
- **Target**: 90% of reconnections succeed within 3 seconds
- **Measurement**: Time from disconnect to successful reconnection
- **Success Criteria**: Median reconnection time < 2 seconds

### Metric 5: User Satisfaction
- **Target**: >90% users find real-time updates helpful
- **Measurement**: User surveys and feedback
- **Success Criteria**: Positive sentiment in user feedback

### Metric 6: Performance Impact
- **Target**: <5% increase in page load time
- **Measurement**: Compare page load with/without WebSocket
- **Success Criteria**: Minimal performance degradation

### Metric 7: Scalability
- **Target**: Support 1,000 concurrent users per server
- **Measurement**: Load testing with gradual user increase
- **Success Criteria**: Linear performance up to 1,000 users

---

## Out of Scope

### Phase 1 (This Implementation)

The following features are **NOT** included in the initial live updates implementation:

1. **Typing Indicators**: Show "User is typing..." when someone is editing
2. **Cursor Position Sharing**: Show where other users are focused
3. **Pessimistic Locking**: Lock items being edited by another user
4. **Change History in Real-time**: Show complete edit history live
5. **Voice/Video Integration**: Audio/video calls between collaborators
6. **Screen Sharing**: Share screen while shopping
7. **Offline Queue**: Queue changes when offline and sync later
8. **Conflict Resolution UI**: Merge tool for conflicting edits
9. **Real-time Search**: Live search results as collaborators add items
10. **Mobile Push Notifications**: Native push notifications for mobile devices
11. **Email Notifications**: Email digest of changes
12. **Webhook Support**: Trigger webhooks on list changes
13. **Analytics Events**: Track user behavior through WebSocket
14. **Custom Event Types**: User-defined custom events

### Future Enhancements

These features may be considered for future phases:

1. **Operational Transform**: Advanced conflict resolution using OT
2. **CRDT Support**: Conflict-free replicated data types
3. **Event Sourcing**: Complete event log for auditing
4. **Time Travel**: Rewind/replay list changes
5. **Collaborative Filtering**: Smart item suggestions based on team behavior
6. **Integration Events**: Events from external systems (e.g., store APIs)

---

## Acceptance Criteria - Definition of Done

### Functional Completeness
- ✅ All event types are implemented and working
- ✅ Connection management handles all edge cases
- ✅ Authorization is enforced for all operations
- ✅ Error handling covers all failure scenarios

### Performance
- ✅ Event latency < 200ms (95th percentile)
- ✅ Supports 1,000 concurrent users
- ✅ No memory leaks during 8-hour sessions
- ✅ Reconnection < 3 seconds (90th percentile)

### User Experience
- ✅ Smooth animations without jank
- ✅ Clear connection status indicators
- ✅ Intuitive conflict resolution
- ✅ Mobile-friendly presence display

### Quality
- ✅ 90%+ unit test coverage
- ✅ Integration tests for all events
- ✅ Load testing passes at target scale
- ✅ Security audit passes
- ✅ Accessibility requirements met (WCAG 2.1 AA)

### Documentation
- ✅ API documentation complete
- ✅ Architecture documentation complete
- ✅ User guide includes real-time features
- ✅ Troubleshooting guide for common issues

### Monitoring
- ✅ Logging captures all events and errors
- ✅ Metrics dashboard shows key indicators
- ✅ Alerts configured for critical issues
- ✅ Connection health monitoring active

---

**Next Steps**: Review this specification with the team, then proceed to SIGNALR_ARCHITECTURE.md for technical design details.

