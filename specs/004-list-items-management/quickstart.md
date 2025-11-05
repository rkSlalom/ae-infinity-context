# Quick Start: List Items Management

**For**: Developers implementing items CRUD, purchase tracking, and reordering  
**Time**: 20 minutes to understand the implementation approach

---

## 🚀 Getting Started

### Prerequisites

- Backend API running at `http://localhost:5233`
- Frontend dev server running at `http://localhost:5173`
- User authenticated (JWT token from Feature 001)
- At least one shopping list created (Feature 003)
- Database initialized with migrations
- .NET 9 SDK and Node.js 20+ installed

---

## 🧪 Test the Existing API

### 1. Add Item to List

**Endpoint**: `POST http://localhost:5233/api/v1/lists/{listId}/items`

```bash
# Replace {listId} with actual list ID and TOKEN with JWT
curl -X POST http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "name": "Milk",
    "quantity": 2,
    "unit": "gallons",
    "categoryId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "notes": "Organic preferred"
  }'
```

**Expected Response** (201 Created):
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "listId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "name": "Milk",
  "quantity": 2,
  "unit": "gallons",
  "notes": "Organic preferred",
  "imageUrl": null,
  "category": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "name": "Dairy",
    "icon": "🥛",
    "color": "#E3F2FD"
  },
  "isPurchased": false,
  "position": 0,
  "createdBy": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "displayName": "Sarah Johnson",
    "avatarUrl": null
  },
  "createdAt": "2025-11-05T10:00:00Z",
  "updatedAt": "2025-11-05T10:00:00Z",
  "purchasedAt": null,
  "purchasedBy": null
}
```

### 2. Get All Items in List

**Endpoint**: `GET http://localhost:5233/api/v1/lists/{listId}/items`

```bash
curl -X GET "http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items" \
  -H "Authorization: Bearer TOKEN"
```

**With Filters/Sorting**:
```bash
# Get only unpurchased items, sorted by name
curl -X GET "http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items?purchased=false&sortBy=name" \
  -H "Authorization: Bearer TOKEN"

# Get only Dairy category items
curl -X GET "http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items?categoryId=3fa85f64-5717-4562-b3fc-2c963f66afa6" \
  -H "Authorization: Bearer TOKEN"
```

**Expected Response** (200 OK):
```json
{
  "items": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "listId": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
      "name": "Milk",
      "quantity": 2,
      "unit": "gallons",
      "category": {...},
      "isPurchased": false,
      "position": 0,
      ...
    }
  ],
  "metadata": {
    "totalCount": 8,
    "purchasedCount": 3,
    "unpurchasedCount": 5,
    "allPurchased": false
  },
  "permission": "Editor"
}
```

### 3. Update Item Details

**Endpoint**: `PUT http://localhost:5233/api/v1/lists/{listId}/items/{itemId}`

```bash
curl -X PUT http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items/a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "name": "Milk - Organic",
    "quantity": 3,
    "unit": "gallons",
    "notes": "Organic only, brand: Horizon"
  }'
```

### 4. Toggle Purchased Status

**Endpoint**: `PATCH http://localhost:5233/api/v1/lists/{listId}/items/{itemId}/purchased`

```bash
# Mark as purchased
curl -X PATCH http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items/a1b2c3d4-e5f6-7890-abcd-ef1234567890/purchased \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "isPurchased": true
  }'
```

**Expected Response** (200 OK):
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "isPurchased": true,
  "purchasedAt": "2025-11-05T14:30:00Z",
  "purchasedBy": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "displayName": "Sarah Johnson",
    "avatarUrl": null
  }
}
```

### 5. Reorder Items (Drag-and-Drop)

**Endpoint**: `PATCH http://localhost:5233/api/v1/lists/{listId}/items/reorder`

```bash
curl -X PATCH http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items/reorder \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "itemPositions": [
      {
        "itemId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        "position": 0
      },
      {
        "itemId": "b2c3d4e5-f6g7-8901-bcde-fg2345678901",
        "position": 1
      },
      {
        "itemId": "c3d4e5f6-g7h8-9012-cdef-gh3456789012",
        "position": 2
      }
    ]
  }'
```

**Expected Response** (200 OK):
```json
{
  "message": "Items reordered successfully",
  "updatedCount": 3
}
```

### 6. Get Autocomplete Suggestions

**Endpoint**: `GET http://localhost:5233/api/v1/lists/items/autocomplete?query={text}`

```bash
curl -X GET "http://localhost:5233/api/v1/lists/items/autocomplete?query=Mil" \
  -H "Authorization: Bearer TOKEN"
```

**Expected Response** (200 OK):
```json
{
  "suggestions": [
    {
      "name": "Milk",
      "quantity": 2,
      "unit": "gallons",
      "categoryId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "categoryName": "Dairy",
      "frequency": 12
    },
    {
      "name": "Milk - Almond",
      "quantity": 1,
      "unit": "carton",
      "categoryId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "categoryName": "Dairy",
      "frequency": 5
    }
  ]
}
```

### 7. Delete Item

**Endpoint**: `DELETE http://localhost:5233/api/v1/lists/{listId}/items/{itemId}`

```bash
curl -X DELETE http://localhost:5233/api/v1/lists/7c9e6679-7425-40de-944b-e07fc1f90ae7/items/a1b2c3d4-e5f6-7890-abcd-ef1234567890 \
  -H "Authorization: Bearer TOKEN"
```

**Expected Response** (204 No Content)

---

## 🛠️ Implementation Guide

### Backend Implementation

#### Step 1: Create Domain Entity

**File**: `Domain/Entities/ListItem.cs`

```csharp
public class ListItem
{
    public Guid Id { get; set; }
    public Guid ListId { get; set; }
    public Guid? CategoryId { get; set; }
    public Guid CreatedById { get; set; }
    public Guid? PurchasedById { get; set; }
    
    public string Name { get; set; } = string.Empty;
    public decimal Quantity { get; set; } = 1;
    public string? Unit { get; set; }
    public string? Notes { get; set; }
    public string? ImageUrl { get; set; }
    
    public bool IsPurchased { get; set; } = false;
    public int Position { get; set; } = 0;
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public DateTime? PurchasedAt { get; set; }
    
    // Navigation properties
    public ShoppingList List { get; set; } = null!;
    public Category? Category { get; set; }
    public User CreatedBy { get; set; } = null!;
    public User? PurchasedBy { get; set; }
}
```

#### Step 2: Create Command (CQRS Pattern)

**File**: `Application/ListItems/Commands/CreateItemCommand.cs`

```csharp
using MediatR;

public class CreateItemCommand : IRequest<ItemResponse>
{
    public Guid ListId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Quantity { get; set; } = 1;
    public string? Unit { get; set; }
    public Guid? CategoryId { get; set; }
    public string? Notes { get; set; }
    public string? ImageUrl { get; set; }
}

public class CreateItemCommandHandler : IRequestHandler<CreateItemCommand, ItemResponse>
{
    private readonly IApplicationDbContext _context;
    private readonly IMapper _mapper;
    private readonly ICurrentUserService _currentUser;

    public CreateItemCommandHandler(
        IApplicationDbContext context,
        IMapper mapper,
        ICurrentUserService currentUser)
    {
        _context = context;
        _mapper = mapper;
        _currentUser = currentUser;
    }

    public async Task<ItemResponse> Handle(CreateItemCommand request, CancellationToken cancellationToken)
    {
        // Check permissions
        var list = await _context.ShoppingLists
            .Include(l => l.Collaborators)
            .FirstOrDefaultAsync(l => l.Id == request.ListId, cancellationToken);
        
        if (list == null)
            throw new NotFoundException("List not found");
        
        var permission = list.GetUserPermission(_currentUser.UserId);
        if (permission == Permission.Viewer)
            throw new ForbiddenException("Viewers cannot add items");
        
        // Get next position
        var maxPosition = await _context.ListItems
            .Where(i => i.ListId == request.ListId)
            .MaxAsync(i => (int?)i.Position, cancellationToken) ?? -1;
        
        // Create item
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
            Position = maxPosition + 1,
            CreatedById = _currentUser.UserId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        
        _context.ListItems.Add(item);
        await _context.SaveChangesAsync(cancellationToken);
        
        // Load navigation properties for response
        var createdItem = await _context.ListItems
            .Include(i => i.Category)
            .Include(i => i.CreatedBy)
            .FirstAsync(i => i.Id == item.Id, cancellationToken);
        
        return _mapper.Map<ItemResponse>(createdItem);
    }
}
```

#### Step 3: Create Validator (FluentValidation)

**File**: `Application/ListItems/Commands/CreateItemValidator.cs`

```csharp
using FluentValidation;

public class CreateItemCommandValidator : AbstractValidator<CreateItemCommand>
{
    public CreateItemCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Item name is required")
            .Length(1, 100).WithMessage("Item name must be between 1 and 100 characters");
        
        RuleFor(x => x.Quantity)
            .GreaterThan(0).WithMessage("Quantity must be greater than 0");
        
        RuleFor(x => x.Unit)
            .MaximumLength(50).WithMessage("Unit must be 50 characters or less")
            .When(x => !string.IsNullOrEmpty(x.Unit));
        
        RuleFor(x => x.Notes)
            .MaximumLength(500).WithMessage("Notes must be 500 characters or less")
            .When(x => !string.IsNullOrEmpty(x.Notes));
    }
}
```

#### Step 4: Create Controller Endpoint

**File**: `API/Controllers/ListItemsController.cs`

```csharp
[ApiController]
[Route("api/v1/lists/{listId}/items")]
[Authorize]
public class ListItemsController : ControllerBase
{
    private readonly IMediator _mediator;

    public ListItemsController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost]
    [ProducesResponseType(typeof(ItemResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ItemResponse>> CreateItem(
        [FromRoute] Guid listId,
        [FromBody] CreateItemRequest request)
    {
        var command = new CreateItemCommand
        {
            ListId = listId,
            Name = request.Name,
            Quantity = request.Quantity,
            Unit = request.Unit,
            CategoryId = request.CategoryId,
            Notes = request.Notes,
            ImageUrl = request.ImageUrl
        };
        
        var result = await _mediator.Send(command);
        return CreatedAtAction(nameof(GetItem), new { listId, itemId = result.Id }, result);
    }
    
    [HttpGet]
    [ProducesResponseType(typeof(ItemsListResponse), StatusCodes.Status200OK)]
    public async Task<ActionResult<ItemsListResponse>> GetItems(
        [FromRoute] Guid listId,
        [FromQuery] Guid? categoryId,
        [FromQuery] bool? purchased,
        [FromQuery] string sortBy = "position",
        [FromQuery] string sortOrder = "asc")
    {
        var query = new GetItemsQuery
        {
            ListId = listId,
            CategoryId = categoryId,
            IsPurchased = purchased,
            SortBy = sortBy,
            SortOrder = sortOrder
        };
        
        var result = await _mediator.Send(query);
        return Ok(result);
    }
    
    // ... other endpoints (PUT, PATCH, DELETE)
}
```

---

### Frontend Implementation

#### Step 1: Create TypeScript Types

**File**: `src/types/index.ts`

```typescript
export interface ListItem {
  id: string;
  listId: string;
  name: string;
  quantity: number;
  unit: string | null;
  notes: string | null;
  category: Category | null;
  isPurchased: boolean;
  position: number;
  createdBy: UserBasic;
  createdAt: string;
  updatedAt: string;
  purchasedAt: string | null;
  purchasedBy: UserBasic | null;
}

export interface CreateItemRequest {
  name: string;
  quantity?: number;
  unit?: string;
  categoryId?: string;
  notes?: string;
}
```

#### Step 2: Create API Service

**File**: `src/services/itemsService.ts`

```typescript
import { apiClient } from './apiClient';

export const itemsService = {
  getItems: async (listId: string, filters?: {
    categoryId?: string;
    purchased?: boolean;
    sortBy?: string;
  }): Promise<ItemsListResponse> => {
    const params = new URLSearchParams();
    if (filters?.categoryId) params.append('categoryId', filters.categoryId);
    if (filters?.purchased !== undefined) params.append('purchased', String(filters.purchased));
    if (filters?.sortBy) params.append('sortBy', filters.sortBy);
    
    const response = await apiClient.get(`/lists/${listId}/items?${params}`);
    return response.data;
  },

  createItem: async (listId: string, data: CreateItemRequest): Promise<ItemResponse> => {
    const response = await apiClient.post(`/lists/${listId}/items`, data);
    return response.data;
  },

  updateItem: async (listId: string, itemId: string, data: UpdateItemRequest): Promise<ItemResponse> => {
    const response = await apiClient.put(`/lists/${listId}/items/${itemId}`, data);
    return response.data;
  },

  togglePurchased: async (listId: string, itemId: string, isPurchased: boolean): Promise<ItemResponse> => {
    const response = await apiClient.patch(`/lists/${listId}/items/${itemId}/purchased`, {
      isPurchased
    });
    return response.data;
  },

  deleteItem: async (listId: string, itemId: string): Promise<void> => {
    await apiClient.delete(`/lists/${listId}/items/${itemId}`);
  },

  reorderItems: async (listId: string, positions: ItemPosition[]): Promise<void> => {
    await apiClient.patch(`/lists/${listId}/items/reorder`, {
      itemPositions: positions
    });
  },

  getAutocomplete: async (query: string): Promise<AutocompleteSuggestion[]> => {
    const response = await apiClient.get(`/lists/items/autocomplete?query=${query}`);
    return response.data.suggestions;
  }
};
```

#### Step 3: Create React Hook

**File**: `src/hooks/useItems.ts`

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { itemsService } from '../services/itemsService';
import { toast } from 'react-hot-toast';

export const useItems = (listId: string) => {
  const queryClient = useQueryClient();

  const { data, isLoading, error } = useQuery({
    queryKey: ['items', listId],
    queryFn: () => itemsService.getItems(listId),
  });

  const createMutation = useMutation({
    mutationFn: (newItem: CreateItemRequest) => itemsService.createItem(listId, newItem),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['items', listId] });
      toast.success('Item added successfully');
    },
    onError: () => {
      toast.error('Failed to add item');
    }
  });

  const togglePurchasedMutation = useMutation({
    mutationFn: ({ itemId, isPurchased }: { itemId: string; isPurchased: boolean }) =>
      itemsService.togglePurchased(listId, itemId, isPurchased),
    onMutate: async ({ itemId, isPurchased }) => {
      // Optimistic update
      await queryClient.cancelQueries({ queryKey: ['items', listId] });
      const previousData = queryClient.getQueryData(['items', listId]);
      
      queryClient.setQueryData(['items', listId], (old: any) => ({
        ...old,
        items: old.items.map((item: ListItem) =>
          item.id === itemId ? { ...item, isPurchased } : item
        )
      }));
      
      return { previousData };
    },
    onError: (err, variables, context) => {
      // Rollback on error
      queryClient.setQueryData(['items', listId], context?.previousData);
      toast.error('Failed to update item');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['items', listId] });
    }
  });

  return {
    items: data?.items || [],
    metadata: data?.metadata,
    permission: data?.permission,
    isLoading,
    error,
    createItem: createMutation.mutate,
    togglePurchased: togglePurchasedMutation.mutate,
  };
};
```

#### Step 4: Create React Component

**File**: `src/components/items/ItemCard.tsx`

```typescript
import React from 'react';
import { ListItem } from '../../types';

interface ItemCardProps {
  item: ListItem;
  canEdit: boolean;
  onTogglePurchased: (itemId: string, isPurchased: boolean) => void;
  onEdit: (item: ListItem) => void;
  onDelete: (itemId: string) => void;
}

export const ItemCard: React.FC<ItemCardProps> = ({
  item,
  canEdit,
  onTogglePurchased,
  onEdit,
  onDelete
}) => {
  return (
    <div className={`p-4 border rounded-lg ${item.isPurchased ? 'bg-gray-50' : 'bg-white'}`}>
      <div className="flex items-center gap-3">
        <input
          type="checkbox"
          checked={item.isPurchased}
          onChange={() => onTogglePurchased(item.id, !item.isPurchased)}
          className="w-5 h-5 rounded"
        />
        
        <div className="flex-1">
          <h3 className={`font-medium ${item.isPurchased ? 'line-through text-gray-500' : ''}`}>
            {item.name}
          </h3>
          <p className="text-sm text-gray-600">
            {item.quantity} {item.unit || 'item'}
          </p>
          {item.notes && (
            <p className="text-sm text-gray-500 mt-1">{item.notes}</p>
          )}
        </div>
        
        {item.category && (
          <span className="text-2xl" title={item.category.name}>
            {item.category.icon}
          </span>
        )}
        
        {canEdit && (
          <div className="flex gap-2">
            <button onClick={() => onEdit(item)} className="text-blue-600 hover:text-blue-800">
              Edit
            </button>
            <button onClick={() => onDelete(item.id)} className="text-red-600 hover:text-red-800">
              Delete
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
```

---

## 🧪 Testing

### Backend Unit Test Example

**File**: `tests/Application.Tests/ListItems/Commands/CreateItemCommandTests.cs`

```csharp
public class CreateItemCommandTests
{
    [Fact]
    public async Task CreateItem_WithValidData_CreatesItemSuccessfully()
    {
        // Arrange
        var context = ApplicationDbContextFactory.Create();
        var mapper = MapperFactory.Create();
        var currentUser = new MockCurrentUserService("user-id");
        var handler = new CreateItemCommandHandler(context, mapper, currentUser);
        
        var command = new CreateItemCommand
        {
            ListId = TestData.ListId,
            Name = "Milk",
            Quantity = 2,
            Unit = "gallons"
        };
        
        // Act
        var result = await handler.Handle(command, CancellationToken.None);
        
        // Assert
        Assert.NotNull(result);
        Assert.Equal("Milk", result.Name);
        Assert.Equal(2, result.Quantity);
        Assert.Equal("gallons", result.Unit);
        
        var itemInDb = await context.ListItems.FindAsync(result.Id);
        Assert.NotNull(itemInDb);
    }
    
    [Fact]
    public async Task CreateItem_AsViewer_ThrowsForbiddenException()
    {
        // Arrange
        var context = ApplicationDbContextFactory.Create();
        // ... set up viewer permission
        
        // Act & Assert
        await Assert.ThrowsAsync<ForbiddenException>(() => 
            handler.Handle(command, CancellationToken.None));
    }
}
```

### Frontend Component Test Example

**File**: `src/components/items/__tests__/ItemCard.test.tsx`

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { ItemCard } from '../ItemCard';

describe('ItemCard', () => {
  const mockItem = {
    id: '1',
    name: 'Milk',
    quantity: 2,
    unit: 'gallons',
    isPurchased: false,
    // ... other fields
  };

  it('renders item details', () => {
    render(
      <ItemCard
        item={mockItem}
        canEdit={true}
        onTogglePurchased={jest.fn()}
        onEdit={jest.fn()}
        onDelete={jest.fn()}
      />
    );

    expect(screen.getByText('Milk')).toBeInTheDocument();
    expect(screen.getByText('2 gallons')).toBeInTheDocument();
  });

  it('calls onTogglePurchased when checkbox clicked', () => {
    const onTogglePurchased = jest.fn();
    render(
      <ItemCard
        item={mockItem}
        canEdit={true}
        onTogglePurchased={onTogglePurchased}
        onEdit={jest.fn()}
        onDelete={jest.fn()}
      />
    );

    const checkbox = screen.getByRole('checkbox');
    fireEvent.click(checkbox);

    expect(onTogglePurchased).toHaveBeenCalledWith('1', true);
  });
});
```

---

## 🚨 Common Issues

### Issue: "List not found" error when creating item

**Cause**: ListId in request doesn't match an existing list  
**Solution**: Verify list exists and user has access:
```bash
curl http://localhost:5233/api/v1/lists/{listId} -H "Authorization: Bearer TOKEN"
```

### Issue: "Viewers cannot add items" error

**Cause**: User has Viewer permission, not Editor or Owner  
**Solution**: Check permission in list response, request permission upgrade from owner

### Issue: Drag-drop not working on mobile

**Cause**: Touch events not properly configured  
**Solution**: Ensure @dnd-kit touch sensors are enabled:
```typescript
import { TouchSensor, useSensor, useSensors } from '@dnd-kit/core';

const sensors = useSensors(
  useSensor(TouchSensor, {
    activationConstraint: {
      delay: 250,
      tolerance: 5,
    },
  })
);
```

---

## 📚 Next Steps

1. ✅ Test all API endpoints with curl
2. ✅ Implement backend commands/queries following CQRS pattern
3. ✅ Write unit tests for each command/query (TDD approach)
4. ✅ Implement frontend components and hooks
5. ✅ Write component tests for React components
6. ✅ Integrate backend and frontend
7. ✅ Test permissions (viewer vs. editor vs. owner)
8. ⏭️ Proceed to `/speckit.tasks` to generate implementation checklist

---

**Quickstart Status**: ✅ Complete  
**Estimated Implementation Time**: 12-16 hours (backend + frontend + tests)

