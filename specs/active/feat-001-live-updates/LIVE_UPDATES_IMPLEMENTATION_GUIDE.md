# Live Updates Implementation Guide

**Version**: 1.0  
**Last Updated**: November 4, 2025  
**Status**: Implementation Guide - Ready to Execute  
**Authors**: Development Team

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Implementation Phases](#implementation-phases)
4. [Phase 1: Backend Foundation](#phase-1-backend-foundation)
5. [Phase 2: Backend Event Broadcasting](#phase-2-backend-event-broadcasting)
6. [Phase 3: Frontend Foundation](#phase-3-frontend-foundation)
7. [Phase 4: Frontend Event Handling](#phase-4-frontend-event-handling)
8. [Phase 5: Testing and Refinement](#phase-5-testing-and-refinement)
9. [Phase 6: Production Deployment](#phase-6-production-deployment)
10. [Troubleshooting](#troubleshooting)
11. [Rollback Plan](#rollback-plan)

---

## Overview

This guide provides step-by-step instructions for implementing real-time live updates across the AE Infinity API (.NET) and UI (React) projects.

### Implementation Timeline

- **Phase 1**: Backend Foundation (2-3 days)
- **Phase 2**: Backend Event Broadcasting (2-3 days)
- **Phase 3**: Frontend Foundation (2 days)
- **Phase 4**: Frontend Event Handling (3-4 days)
- **Phase 5**: Testing and Refinement (2-3 days)
- **Phase 6**: Production Deployment (1 day)

**Total Estimated Time**: 12-16 days

### Team Requirements

- 1 Backend Developer (.NET)
- 1 Frontend Developer (React/TypeScript)
- 1 QA Engineer (for testing)

---

## Prerequisites

### Backend Prerequisites

- ✅ .NET 9.0 SDK installed
- ✅ Clean Architecture project structure in place
- ✅ CQRS pattern with MediatR configured
- ✅ JWT authentication working
- ✅ Permission service (`IListPermissionService`) implemented

### Frontend Prerequisites

- ✅ React 19 with TypeScript
- ✅ Authentication context with JWT token management
- ✅ REST API services working
- ✅ Node.js 20+ and npm installed

### Required NuGet Packages (Backend)

```bash
# Already included in .NET 9.0
# No additional packages needed for SignalR
```

### Required npm Packages (Frontend)

```bash
npm install @microsoft/signalr
npm install --save-dev @types/node
```

---

## Implementation Phases

### Phase Overview

```
Phase 1: Backend Foundation
├─ Hub creation
├─ Connection management
├─ Authentication setup
└─ Basic join/leave functionality

Phase 2: Backend Event Broadcasting
├─ Realtime notification service
├─ Integration with command handlers
├─ Event payload formatting
└─ Testing event delivery

Phase 3: Frontend Foundation
├─ SignalR client service
├─ Realtime context
├─ Connection management
└─ Authentication integration

Phase 4: Frontend Event Handling
├─ Event type definitions
├─ List realtime hook
├─ UI updates on events
└─ Optimistic updates

Phase 5: Testing and Refinement
├─ Integration testing
├─ Load testing
├─ Bug fixes
└─ Performance optimization

Phase 6: Production Deployment
├─ Configuration
├─ Monitoring setup
├─ Gradual rollout
└─ Post-deployment verification
```

---

## Phase 1: Backend Foundation

### Duration: 2-3 days

### Step 1.1: Create Hub Class

**File**: `src/AeInfinity.Api/Hubs/ShoppingListHub.cs`

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using AeInfinity.Application.Common.Interfaces;
using System.Security.Claims;

namespace AeInfinity.Api.Hubs;

/// <summary>
/// SignalR Hub for real-time shopping list updates
/// </summary>
[Authorize]
public class ShoppingListHub : Hub
{
    private readonly IListPermissionService _permissionService;
    private readonly ILogger<ShoppingListHub> _logger;

    public ShoppingListHub(
        IListPermissionService permissionService,
        ILogger<ShoppingListHub> logger)
    {
        _permissionService = permissionService;
        _logger = logger;
    }

    public override async Task OnConnectedAsync()
    {
        var userId = GetCurrentUserId();
        
        _logger.LogInformation(
            "User {UserId} connected. ConnectionId: {ConnectionId}",
            userId,
            Context.ConnectionId
        );

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = GetCurrentUserIdOrNull();
        
        _logger.LogInformation(
            "User {UserId} disconnected. ConnectionId: {ConnectionId}",
            userId,
            Context.ConnectionId
        );

        if (exception != null)
        {
            _logger.LogError(
                exception,
                "User {UserId} disconnected with error",
                userId
            );
        }

        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Join a list room to receive real-time updates
    /// </summary>
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
        var groupName = GetGroupName(listId);
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

        _logger.LogInformation(
            "User {UserId} joined list {ListId}. ConnectionId: {ConnectionId}",
            userId,
            listId,
            Context.ConnectionId
        );

        // Notify others in the group
        await Clients.OthersInGroup(groupName).SendAsync(
            "UserJoined",
            new
            {
                EventType = "UserJoined",
                ListId = listId,
                User = new
                {
                    Id = userId,
                    DisplayName = Context.User?.FindFirst(ClaimTypes.Name)?.Value ?? "Unknown",
                    AvatarUrl = (string?)null
                },
                Timestamp = DateTime.UtcNow
            }
        );
    }

    /// <summary>
    /// Leave a list room to stop receiving updates
    /// </summary>
    public async Task LeaveList(Guid listId)
    {
        var userId = GetCurrentUserId();
        var groupName = GetGroupName(listId);

        await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);

        _logger.LogInformation(
            "User {UserId} left list {ListId}. ConnectionId: {ConnectionId}",
            userId,
            listId,
            Context.ConnectionId
        );

        // Notify others in the group
        await Clients.OthersInGroup(groupName).SendAsync(
            "UserLeft",
            new
            {
                EventType = "UserLeft",
                ListId = listId,
                UserId = userId,
                DisplayName = Context.User?.FindFirst(ClaimTypes.Name)?.Value ?? "Unknown",
                Timestamp = DateTime.UtcNow
            }
        );
    }

    /// <summary>
    /// Update presence (heartbeat)
    /// </summary>
    public async Task UpdatePresence(Guid listId)
    {
        var userId = GetCurrentUserId();
        
        // Verify still has access
        var hasAccess = await _permissionService.HasAccessAsync(userId, listId);
        if (!hasAccess)
        {
            _logger.LogWarning(
                "User {UserId} no longer has access to list {ListId}, removing from group",
                userId,
                listId
            );
            
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, GetGroupName(listId));
            throw new HubException("Access denied - you have been removed from this list");
        }

        // Just acknowledgment - no action needed for now
        _logger.LogDebug(
            "Presence updated for user {UserId} on list {ListId}",
            userId,
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

    private Guid? GetCurrentUserIdOrNull()
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userId != null && Guid.TryParse(userId, out var userGuid))
        {
            return userGuid;
        }
        return null;
    }

    private static string GetGroupName(Guid listId) => $"list_{listId}";
}
```

**✅ Checkpoint**: Hub class created with basic connection management

---

### Step 1.2: Register SignalR in Program.cs

**File**: `src/AeInfinity.Api/Program.cs`

Add SignalR services:

```csharp
// Add SignalR (add after AddControllers)
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
    options.HandshakeTimeout = TimeSpan.FromSeconds(15);
    options.MaximumReceiveMessageSize = 32 * 1024; // 32KB
});
```

Map hub endpoint (add before `app.Run()`):

```csharp
// Map SignalR hub
app.MapHub<ShoppingListHub>("/hubs/shopping-list");
```

**✅ Checkpoint**: SignalR configured and endpoint mapped

---

### Step 1.3: Update CORS Configuration

**File**: `src/AeInfinity.Api/Program.cs`

Ensure CORS allows SignalR:

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins(
                "http://localhost:3000",
                "http://localhost:5173",
                "http://localhost:5174"
            )
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials(); // Required for SignalR
    });
});
```

**✅ Checkpoint**: CORS configured for SignalR

---

### Step 1.4: Test Hub Connection

**Test with REST Client** (`test-signalr.http`):

Create test file: `src/AeInfinity.Api/test-signalr.http`

```http
### Test SignalR endpoint
GET {{baseUrl}}/hubs/shopping-list
```

**Test with Browser Console**:

```javascript
// Run in browser console after authentication
const connection = new signalR.HubConnectionBuilder()
    .withUrl('http://localhost:5233/hubs/shopping-list', {
        accessTokenFactory: () => localStorage.getItem('token')
    })
    .configureLogging(signalR.LogLevel.Information)
    .build();

await connection.start();
console.log('Connected!');

// Try joining a list
await connection.invoke('JoinList', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
console.log('Joined list!');

// Cleanup
await connection.stop();
```

**Expected Result**: 
- Connection successful
- JoinList succeeds (or fails with "Access denied" if not authorized)
- Logs appear in API console

**✅ Checkpoint**: Hub connection working

---

## Phase 2: Backend Event Broadcasting

### Duration: 2-3 days

### Step 2.1: Create IRealtimeNotificationService Interface

**File**: `src/AeInfinity.Application/Common/Interfaces/IRealtimeNotificationService.cs`

```csharp
using AeInfinity.Application.Common.Models.DTOs;

namespace AeInfinity.Application.Common.Interfaces;

/// <summary>
/// Service for broadcasting real-time events to connected clients
/// </summary>
public interface IRealtimeNotificationService
{
    /// <summary>
    /// Notify that an item was added to a list
    /// </summary>
    Task NotifyItemAddedAsync(
        Guid listId,
        ListItemDto item,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that an item was updated
    /// </summary>
    Task NotifyItemUpdatedAsync(
        Guid listId,
        ListItemDto item,
        string[] changedFields,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that an item was deleted
    /// </summary>
    Task NotifyItemDeletedAsync(
        Guid listId,
        Guid itemId,
        UserRefDto deletedBy,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that an item's purchased status changed
    /// </summary>
    Task NotifyItemPurchasedStatusChangedAsync(
        Guid listId,
        Guid itemId,
        bool isPurchased,
        UserRefDto? purchasedBy,
        DateTime? purchasedAt,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that a list was updated
    /// </summary>
    Task NotifyListUpdatedAsync(
        Guid listId,
        ListDto list,
        string[] changedFields,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that a list was archived/unarchived
    /// </summary>
    Task NotifyListArchivedAsync(
        Guid listId,
        bool isArchived,
        UserRefDto archivedBy,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that items were reordered
    /// </summary>
    Task NotifyItemsReorderedAsync(
        Guid listId,
        List<(Guid itemId, int position)> itemPositions,
        UserRefDto reorderedBy,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that a collaborator was added
    /// </summary>
    Task NotifyCollaboratorAddedAsync(
        Guid listId,
        CollaboratorDto collaborator,
        UserRefDto invitedBy,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that a collaborator was removed
    /// </summary>
    Task NotifyCollaboratorRemovedAsync(
        Guid listId,
        Guid userId,
        string displayName,
        UserRefDto removedBy,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Notify that a collaborator's permission changed
    /// </summary>
    Task NotifyCollaboratorPermissionChangedAsync(
        Guid listId,
        Guid userId,
        string displayName,
        string oldPermission,
        string newPermission,
        UserRefDto changedBy,
        CancellationToken cancellationToken = default);
}
```

**✅ Checkpoint**: Interface defined

---

### Step 2.2: Implement RealtimeNotificationService

**File**: `src/AeInfinity.Infrastructure/Services/RealtimeNotificationService.cs`

```csharp
using AeInfinity.Api.Hubs;
using AeInfinity.Application.Common.Interfaces;
using AeInfinity.Application.Common.Models.DTOs;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;

namespace AeInfinity.Infrastructure.Services;

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
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted ItemAdded event for item {ItemId} in list {ListId}",
                item.Id,
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemAdded event for item {ItemId} in list {ListId}",
                item.Id,
                listId);
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
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted ItemUpdated event for item {ItemId} in list {ListId}",
                item.Id,
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemUpdated event for item {ItemId} in list {ListId}",
                item.Id,
                listId);
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
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted ItemDeleted event for item {ItemId} in list {ListId}",
                itemId,
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemDeleted event for item {ItemId} in list {ListId}",
                itemId,
                listId);
        }
    }

    public async Task NotifyItemPurchasedStatusChangedAsync(
        Guid listId,
        Guid itemId,
        bool isPurchased,
        UserRefDto? purchasedBy,
        DateTime? purchasedAt,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "ItemPurchasedStatusChanged",
                    new
                    {
                        EventType = "ItemPurchasedStatusChanged",
                        ListId = listId,
                        ItemId = itemId,
                        IsPurchased = isPurchased,
                        PurchasedBy = purchasedBy,
                        PurchasedAt = purchasedAt,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted ItemPurchasedStatusChanged event for item {ItemId} in list {ListId}",
                itemId,
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemPurchasedStatusChanged event for item {ItemId} in list {ListId}",
                itemId,
                listId);
        }
    }

    public async Task NotifyListUpdatedAsync(
        Guid listId,
        ListDto list,
        string[] changedFields,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var changes = new Dictionary<string, object?>();
            
            if (changedFields.Contains("Name", StringComparer.OrdinalIgnoreCase))
                changes["name"] = list.Name;
            
            if (changedFields.Contains("Description", StringComparer.OrdinalIgnoreCase))
                changes["description"] = list.Description;

            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "ListUpdated",
                    new
                    {
                        EventType = "ListUpdated",
                        ListId = listId,
                        Changes = changes,
                        UpdatedBy = new
                        {
                            Id = list.OwnerId, // This should be the actual updater
                            DisplayName = list.OwnerName
                        },
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted ListUpdated event for list {ListId}",
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ListUpdated event for list {ListId}",
                listId);
        }
    }

    public async Task NotifyListArchivedAsync(
        Guid listId,
        bool isArchived,
        UserRefDto archivedBy,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "ListArchived",
                    new
                    {
                        EventType = "ListArchived",
                        ListId = listId,
                        IsArchived = isArchived,
                        ArchivedBy = archivedBy,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted ListArchived event for list {ListId}",
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ListArchived event for list {ListId}",
                listId);
        }
    }

    public async Task NotifyItemsReorderedAsync(
        Guid listId,
        List<(Guid itemId, int position)> itemPositions,
        UserRefDto reorderedBy,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "ItemsReordered",
                    new
                    {
                        EventType = "ItemsReordered",
                        ListId = listId,
                        ItemPositions = itemPositions.Select(x => new
                        {
                            ItemId = x.itemId,
                            Position = x.position
                        }).ToList(),
                        ReorderedBy = reorderedBy,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted ItemsReordered event for list {ListId}",
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast ItemsReordered event for list {ListId}",
                listId);
        }
    }

    public async Task NotifyCollaboratorAddedAsync(
        Guid listId,
        CollaboratorDto collaborator,
        UserRefDto invitedBy,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "CollaboratorAdded",
                    new
                    {
                        EventType = "CollaboratorAdded",
                        ListId = listId,
                        Collaborator = collaborator,
                        InvitedBy = invitedBy,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted CollaboratorAdded event for list {ListId}",
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast CollaboratorAdded event for list {ListId}",
                listId);
        }
    }

    public async Task NotifyCollaboratorRemovedAsync(
        Guid listId,
        Guid userId,
        string displayName,
        UserRefDto removedBy,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "CollaboratorRemoved",
                    new
                    {
                        EventType = "CollaboratorRemoved",
                        ListId = listId,
                        UserId = userId,
                        DisplayName = displayName,
                        RemovedBy = removedBy,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted CollaboratorRemoved event for list {ListId}",
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast CollaboratorRemoved event for list {ListId}",
                listId);
        }
    }

    public async Task NotifyCollaboratorPermissionChangedAsync(
        Guid listId,
        Guid userId,
        string displayName,
        string oldPermission,
        string newPermission,
        UserRefDto changedBy,
        CancellationToken cancellationToken = default)
    {
        try
        {
            await _hubContext.Clients
                .Group(GetGroupName(listId))
                .SendAsync(
                    "CollaboratorPermissionChanged",
                    new
                    {
                        EventType = "CollaboratorPermissionChanged",
                        ListId = listId,
                        UserId = userId,
                        DisplayName = displayName,
                        OldPermission = oldPermission,
                        NewPermission = newPermission,
                        ChangedBy = changedBy,
                        Timestamp = DateTime.UtcNow
                    },
                    cancellationToken);

            _logger.LogDebug(
                "Broadcasted CollaboratorPermissionChanged event for list {ListId}",
                listId);
        }
        catch (Exception ex)
        {
            _logger.LogError(
                ex,
                "Failed to broadcast CollaboratorPermissionChanged event for list {ListId}",
                listId);
        }
    }

    private static string GetGroupName(Guid listId) => $"list_{listId}";
}
```

**✅ Checkpoint**: Service implemented

---

### Step 2.3: Register Service in DI Container

**File**: `src/AeInfinity.Infrastructure/DependencyInjection.cs`

```csharp
// Add this line in the services registration
services.AddScoped<IRealtimeNotificationService, RealtimeNotificationService>();
```

**✅ Checkpoint**: Service registered

---

### Step 2.4: Integrate with Command Handler (Example: CreateItem)

**File**: `src/AeInfinity.Application/Features/ListItems/Commands/CreateItem/CreateItemCommandHandler.cs`

```csharp
public class CreateItemCommandHandler : IRequestHandler<CreateItemCommand, ListItemDto>
{
    private readonly IApplicationDbContext _context;
    private readonly IListPermissionService _permissionService;
    private readonly IRealtimeNotificationService _realtimeService; // ADD THIS
    private readonly IMapper _mapper;
    private readonly ILogger<CreateItemCommandHandler> _logger;

    public CreateItemCommandHandler(
        IApplicationDbContext context,
        IListPermissionService permissionService,
        IRealtimeNotificationService realtimeService, // ADD THIS
        IMapper mapper,
        ILogger<CreateItemCommandHandler> logger)
    {
        _context = context;
        _permissionService = permissionService;
        _realtimeService = realtimeService; // ADD THIS
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<ListItemDto> Handle(CreateItemCommand request, CancellationToken cancellationToken)
    {
        // ... existing code ...

        var itemDto = _mapper.Map<ListItemDto>(item);

        // ADD THIS: Broadcast real-time event
        await _realtimeService.NotifyItemAddedAsync(
            request.ListId,
            itemDto,
            cancellationToken
        );

        return itemDto;
    }
}
```

**Apply similar changes to**:
- `UpdateItemCommandHandler` → `NotifyItemUpdatedAsync`
- `DeleteItemCommandHandler` → `NotifyItemDeletedAsync`
- `UpdatePurchasedStatusCommandHandler` → `NotifyItemPurchasedStatusChangedAsync`
- `UpdateListCommandHandler` → `NotifyListUpdatedAsync`
- `ArchiveListCommandHandler` → `NotifyListArchivedAsync`
- `ReorderItemsCommandHandler` → `NotifyItemsReorderedAsync`
- `ShareListCommandHandler` → `NotifyCollaboratorAddedAsync`
- `RemoveCollaboratorCommandHandler` → `NotifyCollaboratorRemovedAsync`
- `UpdateCollaboratorPermissionCommandHandler` → `NotifyCollaboratorPermissionChangedAsync`

**✅ Checkpoint**: All command handlers broadcasting events

---

### Step 2.5: Test Backend Event Broadcasting

**Test Script**:

1. Connect two browser tabs to the Hub
2. In tab 1, create an item via REST API
3. Verify tab 2 receives `ItemAdded` event

```javascript
// Tab 1 and Tab 2: Connect to hub
const connection = new signalR.HubConnectionBuilder()
    .withUrl('http://localhost:5233/hubs/shopping-list', {
        accessTokenFactory: () => localStorage.getItem('token')
    })
    .build();

await connection.start();
await connection.invoke('JoinList', 'your-list-id');

// Tab 2: Listen for events
connection.on('ItemAdded', (event) => {
    console.log('Item added:', event);
});

// Tab 1: Create item via REST API (use Postman or fetch)
fetch('http://localhost:5233/api/lists/your-list-id/items', {
    method: 'POST',
    headers: {
        'Authorization': 'Bearer ' + localStorage.getItem('token'),
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        name: 'Test Item',
        quantity: 1,
        categoryId: 'category-id'
    })
});

// Tab 2 should log the event!
```

**✅ Checkpoint**: Events broadcasting correctly

---

## Phase 3: Frontend Foundation

### Duration: 2 days

### Step 3.1: Install SignalR Client

```bash
cd ../ae-infinity-ui
npm install @microsoft/signalr
```

**✅ Checkpoint**: Package installed

---

### Step 3.2: Create SignalR Service

**File**: `src/services/signalRService.ts`

```typescript
import * as signalR from '@microsoft/signalr';
import { authService } from './authService';

class SignalRService {
  private connection: signalR.HubConnection | null = null;
  private reconnectAttempts = 0;
  private readonly maxReconnectAttempts = 5;
  private readonly reconnectDelays = [1000, 2000, 5000, 10000, 30000];

  async connect(): Promise<void> {
    if (this.connection?.state === signalR.HubConnectionState.Connected) {
      console.log('[SignalR] Already connected');
      return;
    }

    const token = authService.getToken();
    if (!token) {
      throw new Error('No authentication token available');
    }

    const baseUrl = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5233';

    this.connection = new signalR.HubConnectionBuilder()
      .withUrl(`${baseUrl}/hubs/shopping-list`, {
        accessTokenFactory: () => token,
        transport:
          signalR.HttpTransportType.WebSockets |
          signalR.HttpTransportType.ServerSentEvents |
          signalR.HttpTransportType.LongPolling,
      })
      .withAutomaticReconnect({
        nextRetryDelayInMilliseconds: (retryContext) => {
          if (retryContext.previousRetryCount >= this.maxReconnectAttempts) {
            return null;
          }
          return this.reconnectDelays[retryContext.previousRetryCount] || 30000;
        },
      })
      .configureLogging(signalR.LogLevel.Information)
      .build();

    this.connection.onreconnecting((error) => {
      console.log('[SignalR] Reconnecting...', error);
      this.reconnectAttempts++;
    });

    this.connection.onreconnected((connectionId) => {
      console.log('[SignalR] Reconnected successfully', connectionId);
      this.reconnectAttempts = 0;
    });

    this.connection.onclose((error) => {
      console.log('[SignalR] Connection closed', error);
    });

    try {
      await this.connection.start();
      console.log('[SignalR] Connected successfully');
      this.reconnectAttempts = 0;
    } catch (error) {
      console.error('[SignalR] Failed to connect:', error);
      throw error;
    }
  }

  async disconnect(): Promise<void> {
    if (this.connection) {
      await this.connection.stop();
      this.connection = null;
      console.log('[SignalR] Disconnected');
    }
  }

  async joinList(listId: string): Promise<void> {
    if (!this.connection || this.connection.state !== signalR.HubConnectionState.Connected) {
      throw new Error('Not connected');
    }

    try {
      await this.connection.invoke('JoinList', listId);
      console.log(`[SignalR] Joined list ${listId}`);
    } catch (error) {
      console.error(`[SignalR] Failed to join list ${listId}:`, error);
      throw error;
    }
  }

  async leaveList(listId: string): Promise<void> {
    if (!this.connection || this.connection.state !== signalR.HubConnectionState.Connected) {
      return;
    }

    try {
      await this.connection.invoke('LeaveList', listId);
      console.log(`[SignalR] Left list ${listId}`);
    } catch (error) {
      console.error(`[SignalR] Failed to leave list ${listId}:`, error);
    }
  }

  async updatePresence(listId: string): Promise<void> {
    if (!this.connection || this.connection.state !== signalR.HubConnectionState.Connected) {
      return;
    }

    try {
      await this.connection.invoke('UpdatePresence', listId);
    } catch (error) {
      console.error(`[SignalR] Failed to update presence for list ${listId}:`, error);
    }
  }

  on<T = any>(eventName: string, callback: (data: T) => void): void {
    if (!this.connection) {
      throw new Error('Connection not initialized');
    }
    this.connection.on(eventName, callback);
  }

  off(eventName: string, callback?: (...args: any[]) => void): void {
    if (this.connection) {
      this.connection.off(eventName, callback);
    }
  }

  getState(): signalR.HubConnectionState {
    return this.connection?.state ?? signalR.HubConnectionState.Disconnected;
  }

  getConnectionId(): string | null {
    return this.connection?.connectionId ?? null;
  }
}

export const signalRService = new SignalRService();
export { signalR };
```

**✅ Checkpoint**: SignalR service created

---

### Step 3.3: Create Realtime Context

**File**: `src/contexts/RealtimeContext.tsx`

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
      console.log('[Realtime] Not authenticated, skipping connection');
      return;
    }

    try {
      setError(null);
      await signalRService.connect();
      setConnectionState(signalRService.getState());
    } catch (err) {
      setError(err as Error);
      console.error('[Realtime] Failed to connect:', err);
    }
  }, [isAuthenticated]);

  const disconnect = useCallback(async () => {
    try {
      await signalRService.disconnect();
      setConnectionState(signalR.HubConnectionState.Disconnected);
    } catch (err) {
      console.error('[Realtime] Failed to disconnect:', err);
    }
  }, []);

  const joinList = useCallback(async (listId: string) => {
    try {
      await signalRService.joinList(listId);
    } catch (err) {
      console.error(`[Realtime] Failed to join list ${listId}:`, err);
      throw err;
    }
  }, []);

  const leaveList = useCallback(async (listId: string) => {
    try {
      await signalRService.leaveList(listId);
    } catch (err) {
      console.error(`[Realtime] Failed to leave list ${listId}:`, err);
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
  }, [isAuthenticated, connect, disconnect]);

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

**✅ Checkpoint**: Context created

---

### Step 3.4: Add Provider to App

**File**: `src/App.tsx`

```typescript
import { RealtimeProvider } from './contexts/RealtimeContext';

function App() {
  return (
    <AuthProvider>
      <RealtimeProvider>  {/* ADD THIS */}
        <BrowserRouter>
          {/* ... routes ... */}
        </BrowserRouter>
      </RealtimeProvider>
    </AuthProvider>
  );
}
```

**✅ Checkpoint**: Provider added

---

## Phase 4: Frontend Event Handling

### Duration: 3-4 days

### Step 4.1: Add Event Type Definitions

**File**: `src/types/signalr-events.ts`

```typescript
import { ShoppingItem, UserRef, Collaborator, Permission } from './index';

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

export interface UserJoinedEvent {
  eventType: 'UserJoined';
  listId: string;
  user: UserRef;
  timestamp: string;
}

export interface UserLeftEvent {
  eventType: 'UserLeft';
  listId: string;
  userId: string;
  displayName: string;
  timestamp: string;
}

export type SignalREvent =
  | ItemAddedEvent
  | ItemUpdatedEvent
  | ItemDeletedEvent
  | ItemPurchasedStatusChangedEvent
  | ListUpdatedEvent
  | UserJoinedEvent
  | UserLeftEvent;
```

**✅ Checkpoint**: Types defined

---

### Step 4.2: Create useListRealtime Hook

**File**: `src/hooks/useListRealtime.ts`

```typescript
import { useEffect, useRef } from 'react';
import { signalRService } from '../services/signalRService';
import { useRealtime } from '../contexts/RealtimeContext';
import type {
  ItemAddedEvent,
  ItemUpdatedEvent,
  ItemDeletedEvent,
  ItemPurchasedStatusChangedEvent,
  ListUpdatedEvent,
  UserJoinedEvent,
  UserLeftEvent,
} from '../types/signalr-events';

interface UseListRealtimeOptions {
  listId: string;
  onItemAdded?: (event: ItemAddedEvent) => void;
  onItemUpdated?: (event: ItemUpdatedEvent) => void;
  onItemDeleted?: (event: ItemDeletedEvent) => void;
  onItemPurchasedStatusChanged?: (event: ItemPurchasedStatusChangedEvent) => void;
  onListUpdated?: (event: ListUpdatedEvent) => void;
  onUserJoined?: (event: UserJoinedEvent) => void;
  onUserLeft?: (event: UserLeftEvent) => void;
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
          console.error('[useListRealtime] Failed to join list:', error);
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

    const handlers = [
      { event: 'ItemAdded', handler: eventHandlers.onItemAdded },
      { event: 'ItemUpdated', handler: eventHandlers.onItemUpdated },
      { event: 'ItemDeleted', handler: eventHandlers.onItemDeleted },
      { event: 'ItemPurchasedStatusChanged', handler: eventHandlers.onItemPurchasedStatusChanged },
      { event: 'ListUpdated', handler: eventHandlers.onListUpdated },
      { event: 'UserJoined', handler: eventHandlers.onUserJoined },
      { event: 'UserLeft', handler: eventHandlers.onUserLeft },
    ];

    handlers.forEach(({ event, handler }) => {
      if (handler) {
        signalRService.on(event, handler);
      }
    });

    return () => {
      handlers.forEach(({ event, handler }) => {
        if (handler) {
          signalRService.off(event, handler);
        }
      });
    };
  }, [isConnected, eventHandlers]);
};
```

**✅ Checkpoint**: Hook created

---

### Step 4.3: Integrate Hook in ListDetail Component

**File**: `src/pages/lists/ListDetail.tsx`

```typescript
import { useListRealtime } from '../../hooks/useListRealtime';
import type { ItemAddedEvent, ItemUpdatedEvent, ItemDeletedEvent, ItemPurchasedStatusChangedEvent } from '../../types/signalr-events';

export const ListDetail: React.FC = () => {
  const { listId } = useParams<{ listId: string }>();
  const [items, setItems] = useState<ShoppingItem[]>([]);
  
  // ... existing code ...

  // Set up real-time updates
  useListRealtime({
    listId: listId!,
    onItemAdded: (event: ItemAddedEvent) => {
      console.log('[ListDetail] Item added:', event);
      setItems((prev) => [...prev, event.item]);
      // TODO: Show toast notification
    },
    onItemUpdated: (event: ItemUpdatedEvent) => {
      console.log('[ListDetail] Item updated:', event);
      setItems((prev) =>
        prev.map((item) => (item.id === event.item.id ? event.item : item))
      );
      // TODO: Show toast notification
    },
    onItemDeleted: (event: ItemDeletedEvent) => {
      console.log('[ListDetail] Item deleted:', event);
      setItems((prev) => prev.filter((item) => item.id !== event.itemId));
      // TODO: Show toast notification
    },
    onItemPurchasedStatusChanged: (event: ItemPurchasedStatusChangedEvent) => {
      console.log('[ListDetail] Purchase status changed:', event);
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
  });

  // ... rest of component ...
};
```

**✅ Checkpoint**: Real-time updates working in UI

---

## Phase 5: Testing and Refinement

### Duration: 2-3 days

### Step 5.1: Manual Testing Checklist

**Test Case 1: Basic Connection**
- [ ] User can connect to SignalR hub
- [ ] Connection status indicator shows "Connected"
- [ ] User can disconnect gracefully

**Test Case 2: Item Addition**
- [ ] User A creates item
- [ ] User B sees item appear immediately
- [ ] Item appears with correct data
- [ ] Toast notification shows on User B's screen

**Test Case 3: Item Update**
- [ ] User A updates item
- [ ] User B sees update immediately
- [ ] Changed fields are correctly updated
- [ ] Notification shows who made the change

**Test Case 4: Item Deletion**
- [ ] User A deletes item
- [ ] User B sees item disappear
- [ ] Smooth animation on removal

**Test Case 5: Purchase Status**
- [ ] User A marks item as purchased
- [ ] User B sees purchase status change
- [ ] Purchased timestamp and user displayed

**Test Case 6: Reconnection**
- [ ] Stop backend server
- [ ] Client attempts reconnection
- [ ] Start backend server
- [ ] Client reconnects successfully
- [ ] User re-joins list automatically

**Test Case 7: Multiple Tabs**
- [ ] Open same list in 2 tabs
- [ ] Changes in tab 1 appear in tab 2
- [ ] Changes in tab 2 appear in tab 1

**Test Case 8: Authorization**
- [ ] User without access cannot join list
- [ ] User removed from list is disconnected
- [ ] User with downgraded permission sees UI update

**✅ Checkpoint**: All manual tests passing

---

### Step 5.2: Automated Integration Tests (Optional)

**Backend Test**: `tests/AeInfinity.IntegrationTests/SignalR/HubConnectionTests.cs`

```csharp
[Fact]
public async Task JoinList_WithValidAccess_BroadcastsUserJoinedEvent()
{
    // Arrange
    var connection = await CreateAuthenticatedConnection();
    var userJoinedReceived = new TaskCompletionSource<UserJoinedEvent>();
    
    connection.On<UserJoinedEvent>("UserJoined", evt => 
    {
        userJoinedReceived.SetResult(evt);
    });
    
    // Act
    await connection.InvokeAsync("JoinList", TestData.ListId);
    
    // Assert
    var result = await userJoinedReceived.Task.WaitAsync(TimeSpan.FromSeconds(5));
    Assert.NotNull(result);
    Assert.Equal(TestData.ListId, result.ListId);
}
```

**✅ Checkpoint**: Integration tests passing

---

## Phase 6: Production Deployment

### Duration: 1 day

### Step 6.1: Environment Configuration

**Backend** (`appsettings.Production.json`):

```json
{
  "Serilog": {
    "MinimumLevel": {
      "Override": {
        "Microsoft.AspNetCore.SignalR": "Information"
      }
    }
  },
  "Cors": {
    "AllowedOrigins": ["https://app.ae-infinity.com"]
  }
}
```

**Frontend** (`.env.production`):

```env
VITE_API_BASE_URL=https://api.ae-infinity.com
```

**✅ Checkpoint**: Configuration ready

---

### Step 6.2: Deploy Backend

```bash
cd src/AeInfinity.Api
dotnet publish -c Release -o ./publish
# Deploy publish folder to server
```

**✅ Checkpoint**: Backend deployed

---

### Step 6.3: Deploy Frontend

```bash
cd ../ae-infinity-ui
npm run build
# Deploy dist folder to CDN/hosting
```

**✅ Checkpoint**: Frontend deployed

---

### Step 6.4: Post-Deployment Verification

**Smoke Tests**:
- [ ] Can connect to SignalR hub in production
- [ ] Real-time updates working in production
- [ ] No console errors
- [ ] Logs show successful connections
- [ ] Performance is acceptable

**✅ Checkpoint**: Production deployment verified

---

## Troubleshooting

### Problem: Connection Fails with 401 Unauthorized

**Cause**: JWT token is invalid or not being sent

**Solution**:
1. Check `authService.getToken()` returns valid token
2. Verify token is not expired
3. Check Authorization header is set correctly
4. Verify CORS allows credentials

### Problem: Hub Methods Throw "Access Denied"

**Cause**: User doesn't have permission to access list

**Solution**:
1. Verify `IListPermissionService.HasAccessAsync()` returns true
2. Check user is actually a collaborator on the list
3. Verify listId is correct

### Problem: Events Not Received on Client

**Cause**: Client not in the group or event name mismatch

**Solution**:
1. Verify `JoinList` was called successfully
2. Check event names match exactly (case-sensitive)
3. Verify `Groups.AddToGroupAsync` was called on server
4. Check group name matches (`list_{listId}`)

### Problem: Reconnection Not Working

**Cause**: Reconnection logic not configured

**Solution**:
1. Verify `.withAutomaticReconnect()` is configured
2. Check reconnection delays are reasonable
3. Ensure `onreconnected` handler re-joins lists

### Problem: Memory Leaks in Frontend

**Cause**: Event handlers not cleaned up

**Solution**:
1. Ensure `signalRService.off()` is called in cleanup
2. Verify `useEffect` cleanup functions are correct
3. Check intervals are cleared

---

## Rollback Plan

### If Issues Arise in Production

**Step 1**: Disable Real-time Updates in Frontend
- Set feature flag to disable SignalR connection
- Users continue with REST API only

**Step 2**: Disable Event Broadcasting in Backend
- Comment out `_realtimeService` calls in handlers
- Keep Hub active but no events sent

**Step 3**: Full Rollback
- Deploy previous version
- Monitor for issues

---

## Success Criteria

### Phase 1 Complete
- ✅ SignalR hub accepting connections
- ✅ JWT authentication working
- ✅ JoinList/LeaveList functional

### Phase 2 Complete
- ✅ All events broadcasting from command handlers
- ✅ Events received in browser console
- ✅ No errors in server logs

### Phase 3 Complete
- ✅ SignalR client connecting
- ✅ Realtime context managing state
- ✅ Connection status visible in UI

### Phase 4 Complete
- ✅ All event types handled
- ✅ UI updates on events
- ✅ Notifications displayed

### Phase 5 Complete
- ✅ All manual tests passing
- ✅ No critical bugs
- ✅ Performance acceptable

### Phase 6 Complete
- ✅ Production deployment successful
- ✅ Real-time updates working in production
- ✅ Monitoring active

---

**Document Status**: ✅ Complete and ready for implementation

**Ready to Begin**: Follow phases sequentially for smooth implementation

