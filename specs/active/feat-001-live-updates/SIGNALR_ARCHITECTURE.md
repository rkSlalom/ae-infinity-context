# SignalR Real-time Architecture

**Version**: 1.0  
**Last Updated**: November 4, 2025  
**Status**: Architecture Design - Ready for Implementation  
**Authors**: Development Team

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [System Components](#system-components)
4. [Backend Architecture (.NET SignalR Hub)](#backend-architecture-net-signalr-hub)
5. [Frontend Architecture (React SignalR Client)](#frontend-architecture-react-signalr-client)
6. [Connection Management](#connection-management)
7. [Authentication and Authorization](#authentication-and-authorization)
8. [Event Flow](#event-flow)
9. [State Management](#state-management)
10. [Scalability Architecture](#scalability-architecture)
11. [Error Handling and Resilience](#error-handling-and-resilience)
12. [Performance Optimization](#performance-optimization)
13. [Monitoring and Observability](#monitoring-and-observability)
14. [Security Architecture](#security-architecture)

---

## Overview

This document describes the technical architecture for implementing real-time live updates in the AE Infinity collaborative shopping list application using SignalR.

### Technology Stack

**Backend**:
- ASP.NET Core 9.0 SignalR Hub
- WebSocket transport (with fallback to Server-Sent Events and Long Polling)
- In-process memory for connection tracking (Phase 1)
- Redis backplane for scale-out (Phase 2)

**Frontend**:
- @microsoft/signalr (TypeScript client library)
- React 19 for UI rendering
- React Context API for connection state
- Custom hooks for real-time data management

### Communication Pattern

```
┌─────────────────────────────────────────────────────────┐
│                    Browser Client                        │
│  ┌────────────────────────────────────────────────────┐ │
│  │     React Application (TypeScript)                 │ │
│  │  ┌──────────────────────────────────────────────┐  │ │
│  │  │  SignalR Client (@microsoft/signalr)         │  │ │
│  │  │  - HubConnectionBuilder                       │  │ │
│  │  │  - Event Listeners                            │  │ │
│  │  │  - Connection State Management                │  │ │
│  │  └──────────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────┘ │
└───────────────┬─────────────────────────────────────────┘
                │
                │ WebSocket (WSS) / SSE / Long Polling
                │ Authorization: Bearer JWT
                │
┌───────────────▼─────────────────────────────────────────┐
│              .NET API Server                             │
│  ┌────────────────────────────────────────────────────┐ │
│  │   SignalR Hub (ShoppingListHub)                    │ │
│  │  - JoinList(listId)                                │ │
│  │  - LeaveList(listId)                               │ │
│  │  - UpdatePresence(listId)                          │ │
│  └─────┬──────────────────────────────────────────────┘ │
│        │                                                  │
│  ┌─────▼──────────────────────────────────────────────┐ │
│  │   Application Layer (CQRS Handlers)                │ │
│  │  - CreateItemCommandHandler                        │ │
│  │  - UpdateItemCommandHandler                        │ │
│  │  - DeleteItemCommandHandler                        │ │
│  │  + Broadcast events via IHubContext                │ │
│  └─────┬──────────────────────────────────────────────┘ │
│        │                                                  │
│  ┌─────▼──────────────────────────────────────────────┐ │
│  │   Infrastructure Layer                             │ │
│  │  - ApplicationDbContext                            │ │
│  │  - IListPermissionService (Authorization)          │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Architecture Principles

### Principle 1: Separation of Concerns
- **SignalR Hub** handles only real-time communication and connection management
- **Business Logic** remains in CQRS command/query handlers
- **Hub** acts as a thin transport layer, not business logic layer

### Principle 2: Clean Architecture Compliance
- Hub resides in API layer (Presentation)
- Hub uses Application layer services via interfaces
- No direct database access from Hub
- Domain logic stays in Domain layer

### Principle 3: Event-Driven Communication
- All updates are event-based (not RPC-style)
- Events are broadcast to groups (list subscribers)
- Events contain complete data payloads (no additional fetches)
- Events are idempotent

### Principle 4: Authorization at Every Layer
- Connection must be authenticated
- Group join must be authorized (user has list access)
- Event broadcasting respects permissions
- Permission changes immediately affect delivery

### Principle 5: Resilience and Graceful Degradation
- Auto-reconnection on connection loss
- Optimistic updates on client
- Fallback to REST API if WebSocket unavailable
- Queue events during reconnection

### Principle 6: Scalability First
- Stateless hub design
- Group-based messaging (not individual connections)
- Redis backplane ready (even if not used initially)
- Connection tracking externalized

---

## System Components

### Backend Components

#### 1. SignalR Hub (`ShoppingListHub.cs`)
**Location**: `src/AeInfinity.Api/Hubs/ShoppingListHub.cs`

**Responsibilities**:
- Accept and manage WebSocket connections
- Authenticate connections via JWT
- Manage group subscriptions (list rooms)
- Handle presence updates
- Provide connection lifecycle methods

**Does NOT**:
- Contain business logic
- Directly access database
- Perform validation (validation in command handlers)
- Make authorization decisions (uses IListPermissionService)

#### 2. Hub Context Wrapper (`IRealtimeNotificationService`)
**Location**: `src/AeInfinity.Application/Common/Interfaces/IRealtimeNotificationService.cs`

**Responsibilities**:
- Abstract SignalR-specific APIs from Application layer
- Provide domain-friendly event broadcasting methods
- Encapsulate group management
- Allow Application layer to be SignalR-agnostic

**Interface**:
```csharp
public interface IRealtimeNotificationService
{
    Task NotifyItemAddedAsync(Guid listId, ListItemDto item, CancellationToken cancellationToken = default);
    Task NotifyItemUpdatedAsync(Guid listId, ListItemDto item, string[] changedFields, CancellationToken cancellationToken = default);
    Task NotifyItemDeletedAsync(Guid listId, Guid itemId, UserRefDto deletedBy, CancellationToken cancellationToken = default);
    Task NotifyItemPurchasedStatusChangedAsync(Guid listId, Guid itemId, bool isPurchased, UserRefDto? purchasedBy, DateTime? purchasedAt, CancellationToken cancellationToken = default);
    Task NotifyListUpdatedAsync(Guid listId, ListDto list, string[] changedFields, CancellationToken cancellationToken = default);
    Task NotifyCollaboratorAddedAsync(Guid listId, CollaboratorDto collaborator, UserRefDto invitedBy, CancellationToken cancellationToken = default);
    Task NotifyCollaboratorRemovedAsync(Guid listId, Guid userId, string displayName, UserRefDto removedBy, CancellationToken cancellationToken = default);
    Task NotifyPresenceUpdateAsync(Guid listId, List<ActiveUserDto> activeUsers, CancellationToken cancellationToken = default);
}
```

#### 3. Connection Manager (`IConnectionManager`)
**Location**: `src/AeInfinity.Infrastructure/Services/ConnectionManager.cs`

**Responsibilities**:
- Track active connections per user
- Track active connections per list
- Manage presence information
- Provide connection lookup capabilities

**Storage** (Phase 1):
- In-memory `ConcurrentDictionary<ConnectionId, ConnectionInfo>`
- In-memory `ConcurrentDictionary<ListId, HashSet<ConnectionId>>`

**Storage** (Phase 2):
- Redis for distributed state
- Pub/sub for cross-server communication

#### 4. Permission Check Middleware
**Integration**: Within Hub methods and command handlers

**Responsibilities**:
- Verify user has access to list before joining group
- Check user permission level for actions
- Re-check permissions on every operation (not cached)

### Frontend Components

#### 1. SignalR Hub Connection (`hubConnection`)
**Location**: `src/services/signalRService.ts`

**Responsibilities**:
- Establish and manage connection to SignalR Hub
- Authenticate connection with JWT
- Handle reconnection logic
- Provide typed methods for server calls

#### 2. Real-time Context (`RealtimeContext`)
**Location**: `src/contexts/RealtimeContext.tsx`

**Responsibilities**:
- Provide global SignalR connection state
- Expose connection status to components
- Handle connection lifecycle (connect on mount, disconnect on unmount)
- Provide methods to join/leave list rooms

#### 3. List Real-time Hook (`useListRealtime`)
**Location**: `src/hooks/useListRealtime.ts`

**Responsibilities**:
- Subscribe to list-specific events
- Update local state on event receipt
- Handle optimistic updates
- Detect and resolve conflicts

#### 4. Connection Status Component (`ConnectionStatus`)
**Location**: `src/components/common/ConnectionStatus.tsx`

**Responsibilities**:
- Display connection state indicator
- Show reconnection progress
- Provide manual reconnection button

---

## Backend Architecture (.NET SignalR Hub)

### Hub Implementation

#### ShoppingListHub.cs

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using AeInfinity.Application.Common.Interfaces;
using System.Security.Claims;

namespace AeInfinity.Api.Hubs;

[Authorize] // Require JWT authentication
public class ShoppingListHub : Hub
{
    private readonly IListPermissionService _permissionService;
    private readonly IConnectionManager _connectionManager;
    private readonly ILogger<ShoppingListHub> _logger;

    public ShoppingListHub(
        IListPermissionService permissionService,
        IConnectionManager connectionManager,
        ILogger<ShoppingListHub> logger)
    {
        _permissionService = permissionService;
        _connectionManager = connectionManager;
        _logger = logger;
    }

    // Called when client connects
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        
        if (userId != null && Guid.TryParse(userId, out var userGuid))
        {
            await _connectionManager.AddConnectionAsync(
                Context.ConnectionId,
                userGuid,
                Context.User?.FindFirst(ClaimTypes.Name)?.Value ?? "Unknown"
            );
            
            _logger.LogInformation(
                "User {UserId} connected with ConnectionId {ConnectionId}",
                userId,
                Context.ConnectionId
            );
        }

        await base.OnConnectedAsync();
    }

    // Called when client disconnects
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var connectionInfo = await _connectionManager.GetConnectionInfoAsync(Context.ConnectionId);
        
        if (connectionInfo != null)
        {
            // Leave all groups this connection was part of
            foreach (var listId in connectionInfo.ListIds)
            {
                await LeaveListInternal(listId);
            }

            await _connectionManager.RemoveConnectionAsync(Context.ConnectionId);
            
            _logger.LogInformation(
                "User {UserId} disconnected. ConnectionId: {ConnectionId}",
                connectionInfo.UserId,
                Context.ConnectionId
            );
        }

        await base.OnDisconnectedAsync(exception);
    }

    // Client calls this to join a list room
    public async Task JoinList(Guid listId)
    {
        var userId = GetCurrentUserId();
        
        // Authorize: Check if user has access to this list
        var hasAccess = await _permissionService.HasAccessAsync(userId, listId);
        if (!hasAccess)
        {
            _logger.LogWarning(
                "User {UserId} attempted to join list {ListId} without permission",
                userId,
                listId
            );
            throw new HubException("Access denied");
        }

        // Add connection to group
        await Groups.AddToGroupAsync(Context.ConnectionId, GetGroupName(listId));
        
        // Track in connection manager
        await _connectionManager.AddConnectionToListAsync(Context.ConnectionId, listId);

        // Notify others in the list
        var userInfo = await _connectionManager.GetConnectionInfoAsync(Context.ConnectionId);
        if (userInfo != null)
        {
            await Clients.OthersInGroup(GetGroupName(listId)).SendAsync(
                "UserJoined",
                new
                {
                    EventType = "UserJoined",
                    ListId = listId,
                    User = new
                    {
                        Id = userInfo.UserId,
                        DisplayName = userInfo.DisplayName,
                        AvatarUrl = userInfo.AvatarUrl
                    },
                    Timestamp = DateTime.UtcNow
                }
            );

            // Send current presence to new joiner
            var activeUsers = await _connectionManager.GetActiveUsersForListAsync(listId);
            await Clients.Caller.SendAsync(
                "PresenceUpdate",
                new
                {
                    EventType = "PresenceUpdate",
                    ListId = listId,
                    ActiveUsers = activeUsers,
                    Timestamp = DateTime.UtcNow
                }
            );
        }

        _logger.LogInformation(
            "User {UserId} joined list {ListId}",
            userId,
            listId
        );
    }

    // Client calls this to leave a list room
    public async Task LeaveList(Guid listId)
    {
        await LeaveListInternal(listId);
    }

    // Client calls this to update presence (heartbeat)
    public async Task UpdatePresence(Guid listId)
    {
        var userId = GetCurrentUserId();
        
        // Verify still has access
        var hasAccess = await _permissionService.HasAccessAsync(userId, listId);
        if (!hasAccess)
        {
            await LeaveListInternal(listId);
            return;
        }

        // Update last seen timestamp
        await _connectionManager.UpdatePresenceAsync(Context.ConnectionId, listId);
    }

    // Private helper methods
    private async Task LeaveListInternal(Guid listId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, GetGroupName(listId));
        await _connectionManager.RemoveConnectionFromListAsync(Context.ConnectionId, listId);

        var userInfo = await _connectionManager.GetConnectionInfoAsync(Context.ConnectionId);
        if (userInfo != null)
        {
            await Clients.OthersInGroup(GetGroupName(listId)).SendAsync(
                "UserLeft",
                new
                {
                    EventType = "UserLeft",
                    ListId = listId,
                    UserId = userInfo.UserId,
                    DisplayName = userInfo.DisplayName,
                    Timestamp = DateTime.UtcNow
                }
            );
        }

        _logger.LogInformation(
            "User {UserId} left list {ListId}",
            userInfo?.UserId,
            listId
        );
    }

    private Guid GetCurrentUserId()
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId == null || !Guid.TryParse(userId, out var userGuid))
        {
            throw new HubException("User not authenticated");
        }
        return userGuid;
    }

    private static string GetGroupName(Guid listId) => $"list_{listId}";
}
```

### Broadcasting Events from Command Handlers

#### Example: CreateItemCommandHandler

```csharp
public class CreateItemCommandHandler : IRequestHandler<CreateItemCommand, ListItemDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IListPermissionService _permissionService;
    private readonly IRealtimeNotificationService _realtimeService; // NEW
    private readonly IMapper _mapper;
    private readonly ILogger<CreateItemCommandHandler> _logger;

    public CreateItemCommandHandler(
        IApplicationDbContext context,
        IListPermissionService permissionService,
        IRealtimeNotificationService realtimeService, // NEW
        IMapper mapper,
        ILogger<CreateItemCommandHandler> logger)
    {
        _context = context;
        _permissionService = permissionService;
        _realtimeService = realtimeService; // NEW
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<ListItemDto> Handle(CreateItemCommand request, CancellationToken cancellationToken)
    {
        // 1. Authorization check
        await _permissionService.EnsureCanManageItemsAsync(request.UserId, request.ListId, cancellationToken);

        // 2. Validation (via FluentValidation pipeline behavior)
        
        // 3. Business logic - Create item
        var item = new ListItem
        {
            Id = Guid.NewGuid(),
            ListId = request.ListId,
            Name = request.Name,
            Quantity = request.Quantity,
            Unit = request.Unit,
            CategoryId = request.CategoryId,
            Notes = request.Notes,
            ImageUrl = request.ImageUrl,
            IsPurchased = false,
            Position = await GetNextPositionAsync(request.ListId, cancellationToken),
            CreatedBy = request.UserId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.ListItems.Add(item);
        await _context.SaveChangesAsync(cancellationToken);

        // 4. Map to DTO
        var itemDto = _mapper.Map<ListItemDto>(item);

        // 5. Broadcast event to all list subscribers (NEW)
        await _realtimeService.NotifyItemAddedAsync(
            request.ListId,
            itemDto,
            cancellationToken
        );

        _logger.LogInformation(
            "Item {ItemId} created in list {ListId} by user {UserId}",
            item.Id,
            request.ListId,
            request.UserId
        );

        return itemDto;
    }

    private async Task<int> GetNextPositionAsync(Guid listId, CancellationToken cancellationToken)
    {
        var maxPosition = await _context.ListItems
            .Where(x => x.ListId == listId && !x.IsDeleted)
            .MaxAsync(x => (int?)x.Position, cancellationToken);

        return (maxPosition ?? 0) + 1;
    }
}
```

### Realtime Notification Service Implementation

```csharp
public class RealtimeNotificationService : IRealtimeNotificationService
{
    private readonly IHubContext<ShoppingListHub> _hubContext;
    private readonly ILogger<RealtimeNotificationService> _logger;

    public RealtimeNotificationService(
        IHubContext<ShoppingListHub> hubContext,
        ILogger<RealtimeNotificationService> logger)
    {
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task NotifyItemAddedAsync(
        Guid listId,
        ListItemDto item,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "ItemAdded",
                    new
                    {
                        EventType = "ItemAdded",
                        ListId = listId,
                        Item = item,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken
                );

            _logger.LogDebug(
                "Broadcasted ItemAdded event for item {ItemId} in list {ListId}",
                item.Id,
                listId
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemAdded event for item {ItemId} in list {ListId}",
                item.Id,
                listId
            );
            // Don't throw - broadcasting failure shouldn't fail the operation
        }
    }

    public async Task NotifyItemUpdatedAsync(
        Guid listId,
        ListItemDto item,
        string[] changedFields,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "ItemUpdated",
                    new
                    {
                        EventType = "ItemUpdated",
                        ListId = listId,
                        Item = item,
                        ChangedFields = changedFields,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken
                );

            _logger.LogDebug(
                "Broadcasted ItemUpdated event for item {ItemId} in list {ListId}. Changed fields: {ChangedFields}",
                item.Id,
                listId,
                string.Join(", ", changedFields)
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemUpdated event for item {ItemId} in list {ListId}",
                item.Id,
                listId
            );
        }
    }

    public async Task NotifyItemDeletedAsync(
        Guid listId,
        Guid itemId,
        UserRefDto deletedBy,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "ItemDeleted",
                    new
                    {
                        EventType = "ItemDeleted",
                        ListId = listId,
                        ItemId = itemId,
                        DeletedBy = deletedBy,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken
                );

            _logger.LogDebug(
                "Broadcasted ItemDeleted event for item {ItemId} in list {ListId}",
                itemId,
                listId
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemDeleted event for item {ItemId} in list {ListId}",
                itemId,
                listId
            );
        }
    }

    // ... other notification methods ...

    private static string GetGroupName(Guid listId) => $"list_{listId}";
}
```

### Program.cs Configuration

```csharp
// Add SignalR
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
    options.HandshakeTimeout = TimeSpan.FromSeconds(15);
    options.MaximumReceiveMessageSize = 32 * 1024; // 32KB
});

// Map hub endpoint
app.MapHub<ShoppingListHub>("/hubs/shopping-list");
```

---

## Frontend Architecture (React SignalR Client)

### SignalR Service

#### signalRService.ts

```typescript
import * as signalR from '@microsoft/signalr';
import { authService } from './authService';

class SignalRService {
  private connection: signalR.HubConnection | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelays = [1000, 2000, 5000, 10000, 30000]; // Exponential backoff

  /**
   * Initialize and start the SignalR connection
   */
  async connect(): Promise<void> {
    if (this.connection?.state === signalR.HubConnectionState.Connected) {
      console.log('Already connected');
      return;
    }

    const token = authService.getToken();
    if (!token) {
      throw new Error('No authentication token available');
    }

    this.connection = new signalR.HubConnectionBuilder()
      .withUrl(`${import.meta.env.VITE_API_BASE_URL}/hubs/shopping-list`, {
        accessTokenFactory: () => token,
        transport: signalR.HttpTransportType.WebSockets | 
                   signalR.HttpTransportType.ServerSentEvents |
                   signalR.HttpTransportType.LongPolling,
      })
      .withAutomaticReconnect({
        nextRetryDelayInMilliseconds: (retryContext) => {
          if (retryContext.previousRetryCount >= this.maxReconnectAttempts) {
            return null; // Stop reconnecting
          }
          return this.reconnectDelays[retryContext.previousRetryCount] || 30000;
        },
      })
      .configureLogging(signalR.LogLevel.Information)
      .build();

    // Connection lifecycle handlers
    this.connection.onreconnecting((error) => {
      console.log('Reconnecting...', error);
      this.reconnectAttempts++;
    });

    this.connection.onreconnected((connectionId) => {
      console.log('Reconnected successfully', connectionId);
      this.reconnectAttempts = 0;
    });

    this.connection.onclose((error) => {
      console.log('Connection closed', error);
    });

    try {
      await this.connection.start();
      console.log('SignalR connected');
      this.reconnectAttempts = 0;
    } catch (error) {
      console.error('Failed to connect:', error);
      throw error;
    }
  }

  /**
   * Stop the connection
   */
  async disconnect(): Promise<void> {
    if (this.connection) {
      await this.connection.stop();
      this.connection = null;
    }
  }

  /**
   * Join a list room to receive updates
   */
  async joinList(listId: string): Promise<void> {
    if (!this.connection || this.connection.state !== signalR.HubConnectionState.Connected) {
      throw new Error('Not connected');
    }

    try {
      await this.connection.invoke('JoinList', listId);
      console.log(`Joined list ${listId}`);
    } catch (error) {
      console.error(`Failed to join list ${listId}:`, error);
      throw error;
    }
  }

  /**
   * Leave a list room
   */
  async leaveList(listId: string): Promise<void> {
    if (!this.connection || this.connection.state !== signalR.HubConnectionState.Connected) {
      return; // Already disconnected
    }

    try {
      await this.connection.invoke('LeaveList', listId);
      console.log(`Left list ${listId}`);
    } catch (error) {
      console.error(`Failed to leave list ${listId}:`, error);
    }
  }

  /**
   * Update presence (heartbeat)
   */
  async updatePresence(listId: string): Promise<void> {
    if (!this.connection || this.connection.state !== signalR.HubConnectionState.Connected) {
      return;
    }

    try {
      await this.connection.invoke('UpdatePresence', listId);
    } catch (error) {
      console.error(`Failed to update presence for list ${listId}:`, error);
    }
  }

  /**
   * Register event handler
   */
  on<T = any>(eventName: string, callback: (data: T) => void): void {
    if (!this.connection) {
      throw new Error('Connection not initialized');
    }
    this.connection.on(eventName, callback);
  }

  /**
   * Unregister event handler
   */
  off(eventName: string, callback?: (...args: any[]) => void): void {
    if (this.connection) {
      this.connection.off(eventName, callback);
    }
  }

  /**
   * Get connection state
   */
  getState(): signalR.HubConnectionState {
    return this.connection?.state ?? signalR.HubConnectionState.Disconnected;
  }

  /**
   * Get connection ID
   */
  getConnectionId(): string | null {
    return this.connection?.connectionId ?? null;
  }
}

export const signalRService = new SignalRService();
export { signalR }; // Re-export for HubConnectionState enum
```

### Real-time Context

#### RealtimeContext.tsx

```typescript
import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { signalRService, signalR } from '../services/signalRService';
import { useAuth } from './AuthContext';

interface RealtimeContextValue {
  connectionState: signalR.HubConnectionState;
  isConnected: boolean;
  isConnecting: boolean;
  isReconnecting: boolean;
  error: Error | null;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
  joinList: (listId: string) => Promise<void>;
  leaveList: (listId: string) => Promise<void>;
}

const RealtimeContext = createContext<RealtimeContextValue | undefined>(undefined);

export const RealtimeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated } = useAuth();
  const [connectionState, setConnectionState] = useState<signalR.HubConnectionState>(
    signalR.HubConnectionState.Disconnected
  );
  const [error, setError] = useState<Error | null>(null);

  const connect = useCallback(async () => {
    if (!isAuthenticated) {
      console.log('Not authenticated, skipping connection');
      return;
    }

    try {
      setError(null);
      await signalRService.connect();
      setConnectionState(signalRService.getState());
    } catch (err) {
      setError(err as Error);
      console.error('Failed to connect:', err);
    }
  }, [isAuthenticated]);

  const disconnect = useCallback(async () => {
    try {
      await signalRService.disconnect();
      setConnectionState(signalR.HubConnectionState.Disconnected);
    } catch (err) {
      console.error('Failed to disconnect:', err);
    }
  }, []);

  const joinList = useCallback(async (listId: string) => {
    try {
      await signalRService.joinList(listId);
    } catch (err) {
      console.error(`Failed to join list ${listId}:`, err);
      throw err;
    }
  }, []);

  const leaveList = useCallback(async (listId: string) => {
    try {
      await signalRService.leaveList(listId);
    } catch (err) {
      console.error(`Failed to leave list ${listId}:`, err);
    }
  }, []);

  // Auto-connect on mount if authenticated
  useEffect(() => {
    if (isAuthenticated) {
      connect();
    }

    return () => {
      disconnect();
    };
  }, [isAuthenticated]);

  // Poll connection state
  useEffect(() => {
    const interval = setInterval(() => {
      const state = signalRService.getState();
      if (state !== connectionState) {
        setConnectionState(state);
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [connectionState]);

  const value: RealtimeContextValue = {
    connectionState,
    isConnected: connectionState === signalR.HubConnectionState.Connected,
    isConnecting: connectionState === signalR.HubConnectionState.Connecting,
    isReconnecting: connectionState === signalR.HubConnectionState.Reconnecting,
    error,
    connect,
    disconnect,
    joinList,
    leaveList,
  };

  return <RealtimeContext.Provider value={value}>{children}</RealtimeContext.Provider>;
};

export const useRealtime = (): RealtimeContextValue => {
  const context = useContext(RealtimeContext);
  if (!context) {
    throw new Error('useRealtime must be used within RealtimeProvider');
  }
  return context;
};
```

### List Realtime Hook

#### useListRealtime.ts

```typescript
import { useEffect, useCallback, useRef } from 'react';
import { signalRService } from '../services/signalRService';
import { useRealtime } from '../contexts/RealtimeContext';
import type {
  ShoppingItem,
  ItemAddedEvent,
  ItemUpdatedEvent,
  ItemDeletedEvent,
  ItemPurchasedStatusChangedEvent,
  ListUpdatedEvent,
  CollaboratorAddedEvent,
  CollaboratorRemovedEvent,
  UserJoinedEvent,
  UserLeftEvent,
  PresenceUpdateEvent,
} from '../types';

interface UseListRealtimeOptions {
  listId: string;
  onItemAdded?: (event: ItemAddedEvent) => void;
  onItemUpdated?: (event: ItemUpdatedEvent) => void;
  onItemDeleted?: (event: ItemDeletedEvent) => void;
  onItemPurchasedStatusChanged?: (event: ItemPurchasedStatusChangedEvent) => void;
  onListUpdated?: (event: ListUpdatedEvent) => void;
  onCollaboratorAdded?: (event: CollaboratorAddedEvent) => void;
  onCollaboratorRemoved?: (event: CollaboratorRemovedEvent) => void;
  onUserJoined?: (event: UserJoinedEvent) => void;
  onUserLeft?: (event: UserLeftEvent) => void;
  onPresenceUpdate?: (event: PresenceUpdateEvent) => void;
}

export const useListRealtime = (options: UseListRealtimeOptions) => {
  const { listId, ...eventHandlers } = options;
  const { isConnected, joinList, leaveList } = useRealtime();
  const hasJoinedRef = useRef(false);
  const presenceIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // Join list when connected
  useEffect(() => {
    if (isConnected && !hasJoinedRef.current) {
      joinList(listId)
        .then(() => {
          hasJoinedRef.current = true;
          
          // Start presence heartbeat
          presenceIntervalRef.current = setInterval(() => {
            signalRService.updatePresence(listId);
          }, 30000); // Every 30 seconds
        })
        .catch((error) => {
          console.error('Failed to join list:', error);
        });
    }

    return () => {
      if (hasJoinedRef.current) {
        leaveList(listId);
        hasJoinedRef.current = false;
      }
      
      if (presenceIntervalRef.current) {
        clearInterval(presenceIntervalRef.current);
        presenceIntervalRef.current = null;
      }
    };
  }, [isConnected, listId, joinList, leaveList]);

  // Register event handlers
  useEffect(() => {
    if (!isConnected) return;

    // Item events
    if (eventHandlers.onItemAdded) {
      signalRService.on('ItemAdded', eventHandlers.onItemAdded);
    }
    if (eventHandlers.onItemUpdated) {
      signalRService.on('ItemUpdated', eventHandlers.onItemUpdated);
    }
    if (eventHandlers.onItemDeleted) {
      signalRService.on('ItemDeleted', eventHandlers.onItemDeleted);
    }
    if (eventHandlers.onItemPurchasedStatusChanged) {
      signalRService.on('ItemPurchasedStatusChanged', eventHandlers.onItemPurchasedStatusChanged);
    }

    // List events
    if (eventHandlers.onListUpdated) {
      signalRService.on('ListUpdated', eventHandlers.onListUpdated);
    }

    // Collaboration events
    if (eventHandlers.onCollaboratorAdded) {
      signalRService.on('CollaboratorAdded', eventHandlers.onCollaboratorAdded);
    }
    if (eventHandlers.onCollaboratorRemoved) {
      signalRService.on('CollaboratorRemoved', eventHandlers.onCollaboratorRemoved);
    }

    // Presence events
    if (eventHandlers.onUserJoined) {
      signalRService.on('UserJoined', eventHandlers.onUserJoined);
    }
    if (eventHandlers.onUserLeft) {
      signalRService.on('UserLeft', eventHandlers.onUserLeft);
    }
    if (eventHandlers.onPresenceUpdate) {
      signalRService.on('PresenceUpdate', eventHandlers.onPresenceUpdate);
    }

    // Cleanup: Unregister all event handlers
    return () => {
      signalRService.off('ItemAdded', eventHandlers.onItemAdded);
      signalRService.off('ItemUpdated', eventHandlers.onItemUpdated);
      signalRService.off('ItemDeleted', eventHandlers.onItemDeleted);
      signalRService.off('ItemPurchasedStatusChanged', eventHandlers.onItemPurchasedStatusChanged);
      signalRService.off('ListUpdated', eventHandlers.onListUpdated);
      signalRService.off('CollaboratorAdded', eventHandlers.onCollaboratorAdded);
      signalRService.off('CollaboratorRemoved', eventHandlers.onCollaboratorRemoved);
      signalRService.off('UserJoined', eventHandlers.onUserJoined);
      signalRService.off('UserLeft', eventHandlers.onUserLeft);
      signalRService.off('PresenceUpdate', eventHandlers.onPresenceUpdate);
    };
  }, [isConnected, eventHandlers]);
};
```

### Usage in ListDetail Component

```typescript
import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { useListRealtime } from '../../hooks/useListRealtime';
import { listsService, itemsService } from '../../services';
import type { ShoppingListDetail, ShoppingItem } from '../../types';

export const ListDetail: React.FC = () => {
  const { listId } = useParams<{ listId: string }>();
  const [list, setList] = useState<ShoppingListDetail | null>(null);
  const [items, setItems] = useState<ShoppingItem[]>([]);

  // Load initial data
  useEffect(() => {
    if (!listId) return;

    Promise.all([
      listsService.getListById(listId),
      itemsService.getListItems(listId, {}),
    ]).then(([listData, itemsData]) => {
      setList(listData);
      setItems(itemsData.items);
    });
  }, [listId]);

  // Set up real-time updates
  useListRealtime({
    listId: listId!,
    onItemAdded: (event) => {
      console.log('Item added:', event);
      setItems((prev) => [...prev, event.item]);
      // Show toast notification
      showToast(`${event.item.createdBy.displayName} added ${event.item.name}`);
    },
    onItemUpdated: (event) => {
      console.log('Item updated:', event);
      setItems((prev) =>
        prev.map((item) => (item.id === event.item.id ? event.item : item))
      );
      showToast(`${event.item.updatedBy?.displayName} updated ${event.item.name}`);
    },
    onItemDeleted: (event) => {
      console.log('Item deleted:', event);
      setItems((prev) => prev.filter((item) => item.id !== event.itemId));
      showToast(`${event.deletedBy.displayName} deleted an item`);
    },
    onItemPurchasedStatusChanged: (event) => {
      console.log('Purchase status changed:', event);
      setItems((prev) =>
        prev.map((item) =>
          item.id === event.itemId
            ? {
                ...item,
                isPurchased: event.isPurchased,
                purchasedAt: event.purchasedAt,
                purchasedBy: event.purchasedBy,
              }
            : item
        )
      );
    },
    onListUpdated: (event) => {
      console.log('List updated:', event);
      if (list) {
        setList({
          ...list,
          ...event.changes,
        });
      }
    },
  });

  // ... rest of component
};
```

---

## Connection Management

### Connection Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│                  Connection States                       │
└─────────────────────────────────────────────────────────┘

Disconnected
    │
    │ connect()
    ▼
Connecting
    │
    │ Success
    ▼
Connected ◄──────────────┐
    │                    │
    │ Network loss       │ Reconnected
    ▼                    │
Reconnecting ────────────┘
    │
    │ Max retries exceeded
    ▼
Disconnected
```

### Reconnection Strategy

**Exponential Backoff**:
- Attempt 1: Wait 1 second
- Attempt 2: Wait 2 seconds
- Attempt 3: Wait 5 seconds
- Attempt 4: Wait 10 seconds
- Attempt 5: Wait 30 seconds
- After 5 attempts: Stop and prompt user

**On Successful Reconnection**:
1. Re-join all previously joined list groups
2. Request presence update for each list
3. Optionally request full state refresh if disconnected >5 minutes
4. Reset reconnection attempt counter

### Presence Tracking

**Heartbeat Mechanism**:
- Client sends `UpdatePresence(listId)` every 30 seconds
- Server updates `last_seen` timestamp for connection
- Server considers connection inactive after 45 seconds (1.5x heartbeat)

**Active User List**:
- Server maintains set of active users per list
- On `JoinList`: Add user to active set
- On `LeaveList`: Remove user from active set
- On disconnect: Remove from all active sets
- On timeout (45s): Mark as inactive

**Presence Events**:
- `UserJoined`: Broadcast when user joins list
- `UserLeft`: Broadcast when user leaves list
- `PresenceUpdate`: Full snapshot of active users (sent to new joiners)

---

## Authentication and Authorization

### Connection Authentication

**JWT Token in WebSocket**:
```typescript
new signalR.HubConnectionBuilder()
  .withUrl('/hubs/shopping-list', {
    accessTokenFactory: () => getJwtToken(), // Function returning token
  })
```

**Server-side Validation**:
```csharp
[Authorize] // Validates JWT on connection
public class ShoppingListHub : Hub
{
    // Connection automatically rejected if JWT invalid
}
```

### Authorization Flow

```
┌──────────────────────────────────────────────────────────┐
│              Authorization Flow                           │
└──────────────────────────────────────────────────────────┘

Client: JoinList(listId)
    │
    ▼
Hub: GetCurrentUserId() from JWT
    │
    ▼
Hub: _permissionService.HasAccessAsync(userId, listId)
    │
    ├─► No Access → throw HubException("Access denied")
    │
    └─► Has Access
            │
            ▼
        Groups.AddToGroupAsync(connectionId, "list_{listId}")
            │
            ▼
        Success - user joined
```

### Permission Re-validation

**On Permission Change**:
1. Owner removes collaborator OR changes permission to Viewer
2. Command handler broadcasts `CollaboratorRemoved` or `CollaboratorPermissionChanged`
3. Affected user receives event
4. Next `UpdatePresence` heartbeat fails authorization check
5. Server calls `LeaveListInternal` to disconnect user from group
6. User no longer receives events for that list

**Continuous Validation**:
- Every Hub method verifies current user permissions
- Permissions are NOT cached in Hub
- Always query `IListPermissionService`

---

## Event Flow

### End-to-End Event Flow Example: Item Created

```
┌─────────────────────────────────────────────────────────┐
│            User A creates item                           │
└─────────────────────────────────────────────────────────┘

1. User A: Click "Add Item" button
   └─► Client: Optimistic update (add item to local state)
   └─► Client: POST /api/lists/{listId}/items

2. API Controller: Receives request
   └─► MediatR: Send CreateItemCommand

3. CreateItemCommandHandler:
   ├─► Check permissions (can user manage items?)
   ├─► Validate input (FluentValidation)
   ├─► Create item in database
   ├─► Save changes
   ├─► Map to DTO
   └─► Call _realtimeService.NotifyItemAddedAsync()

4. RealtimeNotificationService:
   └─► _hubContext.Clients.Group("list_{listId}").SendAsync("ItemAdded", payload)

5. SignalR Hub:
   └─► Broadcast to all connections in group

6. User A Client:
   ├─► Receives "ItemAdded" event
   ├─► Ignores (already has optimistic update)
   └─► Confirms optimistic update (remove "pending" flag)

7. User B Client:
   ├─► Receives "ItemAdded" event
   ├─► Adds item to local state
   ├─► Triggers animation
   └─► Shows toast notification

8. User C Client:
   ├─► Receives "ItemAdded" event
   └─► (Same as User B)
```

### Event Ordering

**Guaranteed Order**:
- Events from same user to same list are delivered in order
- SignalR maintains message order per connection

**No Guaranteed Order**:
- Events from different users may arrive out of order
- Use timestamps to detect out-of-order events

**Client-side Ordering**:
```typescript
const events = useRef<Map<string, any>>(new Map());

const handleEvent = (event: any) => {
  const existing = events.current.get(event.itemId);
  
  // If we have newer data, ignore old event
  if (existing && new Date(existing.timestamp) > new Date(event.timestamp)) {
    console.log('Ignoring stale event');
    return;
  }
  
  events.current.set(event.itemId, event);
  applyEvent(event);
};
```

---

## State Management

### Client-Side State Architecture

```
┌───────────────────────────────────────────────────────────┐
│                  State Layers                              │
└───────────────────────────────────────────────────────────┘

Layer 1: Server State (Source of Truth)
   │
   │ Initial Load: REST API GET request
   ▼
Layer 2: Local State (useState/useReducer)
   │
   │ Real-time Updates: SignalR events
   │ User Actions: Optimistic updates
   ▼
Layer 3: UI State (Derived)
   │
   │ Computed: Filters, sorting, grouping
   ▼
Layer 4: Rendered UI
```

### Optimistic Update Pattern

```typescript
const addItem = async (itemData: CreateItemRequest) => {
  // 1. Generate temporary ID
  const tempId = `temp_${Date.now()}`;
  
  // 2. Optimistic update
  const optimisticItem: ShoppingItem = {
    id: tempId,
    ...itemData,
    isPending: true, // Mark as pending
    createdAt: new Date().toISOString(),
  };
  
  setItems((prev) => [...prev, optimisticItem]);
  
  try {
    // 3. API call
    const createdItem = await itemsService.createItem(listId, itemData);
    
    // 4. Replace optimistic with real data
    setItems((prev) =>
      prev.map((item) => (item.id === tempId ? createdItem : item))
    );
    
    return createdItem;
  } catch (error) {
    // 5. Rollback on error
    setItems((prev) => prev.filter((item) => item.id !== tempId));
    
    // Show error notification
    showToast('Failed to add item. Please try again.');
    
    throw error;
  }
};
```

### Conflict Detection

```typescript
const handleItemUpdated = (event: ItemUpdatedEvent) => {
  const localItem = items.find((item) => item.id === event.item.id);
  
  if (!localItem) {
    // Item doesn't exist locally, just add it
    setItems((prev) => [...prev, event.item]);
    return;
  }
  
  // Check if user is currently editing this item
  if (editingItemId === event.item.id) {
    // Show conflict warning
    setConflict({
      itemId: event.item.id,
      theirChanges: event.item,
      theirUser: event.item.updatedBy,
      changedFields: event.changedFields,
    });
    return;
  }
  
  // No conflict, apply update
  setItems((prev) =>
    prev.map((item) => (item.id === event.item.id ? event.item : item))
  );
};
```

---

## Scalability Architecture

### Single Server (Phase 1)

```
┌──────────────────────────────────────────────────┐
│              Single Server                        │
│  ┌─────────────────────────────────────────────┐ │
│  │  SignalR Hub                                 │ │
│  │  - In-memory connection tracking             │ │
│  │  - In-memory group management                │ │
│  └─────────────────────────────────────────────┘ │
│                                                    │
│  Capacity: ~1,000 concurrent connections         │
└──────────────────────────────────────────────────┘
```

### Multi-Server with Redis Backplane (Phase 2)

```
┌────────────────────────────────────────────────────────────┐
│                   Load Balancer                             │
│          (Sticky sessions if using Server-Sent Events)      │
└──────┬─────────────────────────────────────────────────────┘
       │
       ├────────────────────┬──────────────────────┬──────────
       │                    │                      │
┌──────▼──────┐      ┌──────▼──────┐      ┌──────▼──────┐
│  Server 1   │      │  Server 2   │      │  Server 3   │
│  SignalR    │      │  SignalR    │      │  SignalR    │
└──────┬──────┘      └──────┬──────┘      └──────┬──────┘
       │                    │                      │
       └────────────────────┼──────────────────────┘
                            │
                     ┌──────▼───────┐
                     │  Redis       │
                     │  Backplane   │
                     │  - Pub/Sub   │
                     │  - State     │
                     └──────────────┘
```

**Configuration**:
```csharp
builder.Services.AddSignalR()
    .AddStackExchangeRedis(configuration.GetConnectionString("Redis"), options =>
    {
        options.Configuration.ChannelPrefix = "AeInfinity";
    });
```

**Redis Pub/Sub**:
- Each server subscribes to Redis channels
- When server broadcasts event, it publishes to Redis
- Redis broadcasts to all subscribed servers
- Each server delivers to its own connected clients

**Connection State in Redis**:
```csharp
public class RedisConnectionManager : IConnectionManager
{
    private readonly IConnectionMultiplexer _redis;
    
    public async Task AddConnectionAsync(string connectionId, Guid userId, string displayName)
    {
        var db = _redis.GetDatabase();
        
        // Store connection info
        await db.StringSetAsync(
            $"connection:{connectionId}",
            JsonSerializer.Serialize(new ConnectionInfo { UserId = userId, DisplayName = displayName }),
            expiry: TimeSpan.FromHours(24)
        );
        
        // Add to user's connections set
        await db.SetAddAsync($"user:{userId}:connections", connectionId);
    }
    
    public async Task AddConnectionToListAsync(string connectionId, Guid listId)
    {
        var db = _redis.GetDatabase();
        
        // Add to list's connections set
        await db.SetAddAsync($"list:{listId}:connections", connectionId);
        
        // Update last seen
        await db.StringSetAsync(
            $"connection:{connectionId}:list:{listId}:lastseen",
            DateTime.UtcNow.Ticks.ToString(),
            expiry: TimeSpan.FromMinutes(2)
        );
    }
    
    public async Task<List<ActiveUserDto>> GetActiveUsersForListAsync(Guid listId)
    {
        var db = _redis.GetDatabase();
        
        // Get all connections for this list
        var connectionIds = await db.SetMembersAsync($"list:{listId}:connections");
        
        var activeUsers = new List<ActiveUserDto>();
        
        foreach (var connectionId in connectionIds)
        {
            // Check if connection is still active (has recent heartbeat)
            var lastSeen = await db.StringGetAsync($"connection:{connectionId}:list:{listId}:lastseen");
            
            if (lastSeen.HasValue)
            {
                var lastSeenTime = new DateTime(long.Parse(lastSeen));
                if (DateTime.UtcNow - lastSeenTime < TimeSpan.FromSeconds(45))
                {
                    // Connection is active
                    var connectionInfo = await db.StringGetAsync($"connection:{connectionId}");
                    if (connectionInfo.HasValue)
                    {
                        var info = JsonSerializer.Deserialize<ConnectionInfo>(connectionInfo);
                        
                        // Deduplicate users (user may have multiple tabs open)
                        if (!activeUsers.Any(u => u.Id == info.UserId))
                        {
                            activeUsers.Add(new ActiveUserDto
                            {
                                Id = info.UserId,
                                DisplayName = info.DisplayName,
                                AvatarUrl = info.AvatarUrl,
                                JoinedAt = lastSeenTime
                            });
                        }
                    }
                }
            }
        }
        
        return activeUsers;
    }
}
```

### Capacity Planning

**Per Server**:
- Connections: 1,000 concurrent
- Events: 100/second sustained, 500/second burst
- Memory: ~1MB per connection = 1GB for connections
- CPU: < 50% at capacity

**Scaling Strategy**:
- Horizontal scaling with Redis backplane
- Add servers as needed based on connection count
- Target: 70% capacity utilization per server
- Auto-scaling based on CPU and connection metrics

---

## Error Handling and Resilience

### Connection Error Handling

**Client-Side**:
```typescript
connection.onclose((error) => {
  if (error) {
    console.error('Connection closed with error:', error);
    
    // Check if authentication error
    if (error.message.includes('401') || error.message.includes('Unauthorized')) {
      // Token expired, redirect to login
      authService.logout();
      navigate('/login');
      return;
    }
    
    // Other errors - show notification
    showError('Connection lost. Trying to reconnect...');
  }
});

connection.onreconnecting((error) => {
  console.log('Reconnecting...', error);
  showInfo('Reconnecting...');
});

connection.onreconnected(() => {
  console.log('Reconnected successfully');
  showSuccess('Reconnected!');
  
  // Re-join lists
  rejoinActiveLists();
});
```

### Event Processing Errors

**Server-Side**:
```csharp
public async Task NotifyItemAddedAsync(Guid listId, ListItemDto item, CancellationToken cancellationToken)
{
    try
    {
        await _hubContext.Clients
            .Group(GetGroupName(listId))
            .SendAsync("ItemAdded", new { EventType = "ItemAdded", ListId = listId, Item = item, Timestamp = DateTime.UtcNow }, cancellationToken);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to broadcast ItemAdded event");
        
        // Log to error tracking service (e.g., Sentry)
        // ErrorTracker.CaptureException(ex);
        
        // Don't throw - broadcasting failure shouldn't fail the operation
    }
}
```

**Client-Side**:
```typescript
signalRService.on('ItemAdded', (event) => {
  try {
    // Validate event structure
    if (!event.item || !event.item.id) {
      console.error('Invalid ItemAdded event:', event);
      return;
    }
    
    // Process event
    handleItemAdded(event);
  } catch (error) {
    console.error('Error processing ItemAdded event:', error);
    
    // Log to error tracking
    // Sentry.captureException(error);
    
    // Show generic error to user
    showError('Failed to process update. Please refresh the page.');
  }
});
```

### Circuit Breaker Pattern

**For High-Frequency Events**:
```typescript
class EventCircuitBreaker {
  private failureCount = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private lastFailure: Date | null = null;
  
  private readonly maxFailures = 5;
  private readonly resetTimeout = 30000; // 30 seconds
  
  async execute<T>(fn: () => T): Promise<T | null> {
    if (this.state === 'open') {
      // Check if should transition to half-open
      if (this.lastFailure && Date.now() - this.lastFailure.getTime() > this.resetTimeout) {
        this.state = 'half-open';
      } else {
        console.log('Circuit breaker is open, skipping operation');
        return null;
      }
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  private onSuccess() {
    this.failureCount = 0;
    this.state = 'closed';
  }
  
  private onFailure() {
    this.failureCount++;
    this.lastFailure = new Date();
    
    if (this.failureCount >= this.maxFailures) {
      this.state = 'open';
      console.error('Circuit breaker opened after', this.maxFailures, 'failures');
      
      // Trigger full page refresh after circuit opens
      showError('Too many errors. Please refresh the page.');
    }
  }
}
```

---

## Performance Optimization

### Message Batching

**Client-Side Batching**:
```typescript
class EventBatcher {
  private queue: any[] = [];
  private timer: NodeJS.Timeout | null = null;
  private readonly batchDelay = 100; // ms
  private readonly maxBatchSize = 10;
  
  enqueue(event: any, handler: (events: any[]) => void) {
    this.queue.push(event);
    
    if (this.queue.length >= this.maxBatchSize) {
      this.flush(handler);
    } else if (!this.timer) {
      this.timer = setTimeout(() => this.flush(handler), this.batchDelay);
    }
  }
  
  private flush(handler: (events: any[]) => void) {
    if (this.queue.length > 0) {
      handler(this.queue);
      this.queue = [];
    }
    
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }
  }
}

// Usage
const batcher = new EventBatcher();

signalRService.on('ItemAdded', (event) => {
  batcher.enqueue(event, (events) => {
    // Process batch of events
    const items = events.map(e => e.item);
    setItems(prev => [...prev, ...items]);
    
    if (events.length > 5) {
      showToast(`${events.length} items added`);
    } else {
      events.forEach(e => showToast(`${e.item.createdBy.displayName} added ${e.item.name}`));
    }
  });
});
```

### Message Compression

**Server-Side**:
```csharp
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
})
.AddMessagePackProtocol(); // Use MessagePack instead of JSON (smaller, faster)
```

**Client-Side**:
```typescript
import { HubConnectionBuilder, HttpTransportType, MessagePackHubProtocol } from '@microsoft/signalr';
import { MessagePackHubProtocol } from '@microsoft/signalr-protocol-msgpack';

const connection = new HubConnectionBuilder()
  .withUrl('/hubs/shopping-list')
  .withHubProtocol(new MessagePackHubProtocol())
  .build();
```

### Throttling and Debouncing

**Presence Updates**:
```typescript
const debouncedUpdatePresence = debounce((listId: string) => {
  signalRService.updatePresence(listId);
}, 5000); // Wait 5 seconds after last activity

// Call on user interaction
const handleUserActivity = () => {
  debouncedUpdatePresence(listId);
};
```

---

## Monitoring and Observability

### Logging

**Server-Side**:
```csharp
public class ShoppingListHub : Hub
{
    private readonly ILogger<ShoppingListHub> _logger;
    
    public override async Task OnConnectedAsync()
    {
        _logger.LogInformation(
            "SignalR connection established. ConnectionId: {ConnectionId}, User: {UserId}",
            Context.ConnectionId,
            GetCurrentUserId()
        );
        
        await base.OnConnectedAsync();
    }
    
    public async Task JoinList(Guid listId)
    {
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            // ... implementation ...
            
            stopwatch.Stop();
            _logger.LogInformation(
                "User {UserId} joined list {ListId} in {Duration}ms",
                GetCurrentUserId(),
                listId,
                stopwatch.ElapsedMilliseconds
            );
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Error joining list {ListId} for user {UserId}",
                listId,
                GetCurrentUserId()
            );
            throw;
        }
    }
}
```

### Metrics

**Key Metrics to Track**:
1. Active connections count
2. Messages sent per second
3. Message latency (server timestamp to client receipt)
4. Connection duration
5. Reconnection frequency
6. Event processing errors

**Implementation**:
```csharp
public class SignalRMetrics
{
    private static readonly Counter ConnectionsTotal = Metrics
        .CreateCounter("signalr_connections_total", "Total SignalR connections");
    
    private static readonly Gauge ActiveConnections = Metrics
        .CreateGauge("signalr_connections_active", "Current active SignalR connections");
    
    private static readonly Counter MessagesSent = Metrics
        .CreateCounter("signalr_messages_sent_total", "Total messages sent");
    
    private static readonly Histogram MessageLatency = Metrics
        .CreateHistogram("signalr_message_latency_seconds", "Message delivery latency");
    
    public static void RecordConnection()
    {
        ConnectionsTotal.Inc();
        ActiveConnections.Inc();
    }
    
    public static void RecordDisconnection()
    {
        ActiveConnections.Dec();
    }
    
    public static void RecordMessageSent()
    {
        MessagesSent.Inc();
    }
    
    public static void RecordMessageLatency(TimeSpan latency)
    {
        MessageLatency.Observe(latency.TotalSeconds);
    }
}
```

### Health Checks

```csharp
builder.Services.AddHealthChecks()
    .AddCheck("signalr", () =>
    {
        var activeConnections = SignalRMetrics.GetActiveConnections();
        
        if (activeConnections > 1000)
        {
            return HealthCheckResult.Degraded($"High connection count: {activeConnections}");
        }
        
        return HealthCheckResult.Healthy($"Active connections: {activeConnections}");
    });
```

---

## Security Architecture

### Threat Model

**Threats**:
1. Unauthorized access to lists
2. Eavesdropping on WebSocket traffic
3. Message injection/spoofing
4. Denial of service (connection flooding)
5. XSS via malicious event payloads

**Mitigations**:
1. JWT authentication + permission checks
2. WSS (WebSocket Secure) in production
3. Server-side event broadcasting only (clients can't send events directly)
4. Rate limiting + connection limits
5. Input sanitization on all string fields

### Rate Limiting

```csharp
public class RateLimitingHub : Hub
{
    private static readonly ConcurrentDictionary<string, (int count, DateTime resetTime)> _rateLimits = new();
    
    private const int MaxRequestsPerMinute = 100;
    
    protected async Task<bool> CheckRateLimitAsync()
    {
        var userId = GetCurrentUserId().ToString();
        var now = DateTime.UtcNow;
        
        var (count, resetTime) = _rateLimits.GetOrAdd(userId, _ => (0, now.AddMinutes(1)));
        
        if (now > resetTime)
        {
            // Reset window
            _rateLimits[userId] = (1, now.AddMinutes(1));
            return true;
        }
        
        if (count >= MaxRequestsPerMinute)
        {
            _logger.LogWarning("Rate limit exceeded for user {UserId}", userId);
            throw new HubException("Rate limit exceeded. Please try again later.");
        }
        
        _rateLimits[userId] = (count + 1, resetTime);
        return true;
    }
    
    public async Task JoinList(Guid listId)
    {
        await CheckRateLimitAsync();
        
        // ... rest of implementation ...
    }
}
```

### Input Sanitization

```csharp
public class SanitizationService
{
    public string SanitizeHtml(string input)
    {
        if (string.IsNullOrEmpty(input))
            return input;
        
        // Remove HTML tags
        return Regex.Replace(input, "<.*?>", string.Empty);
    }
    
    public string SanitizeForDisplay(string input)
    {
        if (string.IsNullOrEmpty(input))
            return input;
        
        return input
            .Replace("<", "&lt;")
            .Replace(">", "&gt;")
            .Replace("\"", "&quot;")
            .Replace("'", "&#x27;")
            .Replace("/", "&#x2F;");
    }
}
```

---

## Next Steps

1. Review this architecture document with the team
2. Proceed to **SIGNALR_API_SPEC.md** for detailed API specifications
3. After API spec review, proceed to **LIVE_UPDATES_IMPLEMENTATION_GUIDE.md** for step-by-step implementation

---

**Document Status**: ✅ Complete and ready for review

