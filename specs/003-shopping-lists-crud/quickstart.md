# Quick Start: Shopping Lists CRUD

**Feature**: 003-shopping-lists-crud  
**For**: Frontend developers integrating list management  
**Backend Status**: ✅ 100% Implemented  
**Your Task**: Replace mock data with real API calls

---

## Overview

The backend API for shopping lists is fully functional. This guide shows you how to:
1. Call the lists API from your React components
2. Handle loading states and errors
3. Implement create, read, update, delete, archive operations
4. Add pagination, filtering, and sorting

**Time to Complete**: 2-3 days for full integration

---

## Prerequisites

- Backend API running at http://localhost:5233
- Frontend running at http://localhost:5173
- User authenticated (JWT token in localStorage)
- Service layer exists in `src/services/listsService.ts`

---

## Quick Reference

### API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/lists` | GET | Get all lists (paginated) |
| `/lists` | POST | Create new list |
| `/lists/{id}` | GET | Get list details |
| `/lists/{id}` | PUT | Update list |
| `/lists/{id}` | DELETE | Delete list |
| `/lists/{id}/archive` | POST | Archive list |
| `/lists/{id}/unarchive` | POST | Unarchive list |

---

## Step-by-Step Integration

### Step 1: View Lists (Dashboard)

Replace mock data in `ListsDashboard.tsx`:

```typescript
import { useEffect, useState } from 'react';
import { listsService } from '../services';

export function ListsDashboard() {
  const [lists, setLists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    loadLists();
  }, []);

  async function loadLists() {
    try {
      setLoading(true);
      setError(null);
      const response = await listsService.getAllLists({
        includeArchived: false,
        page: 1,
        pageSize: 20,
        sortBy: 'updatedAt',
        sortOrder: 'desc'
      });
      setLists(response.lists);
    } catch (err) {
      setError('Failed to load lists');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorMessage message={error} />;
  if (lists.length === 0) {
    return <EmptyState message="No lists yet" onCreateClick={() => navigate('/lists/create')} />;
  }

  return (
    <div className="lists-grid">
      {lists.map(list => (
        <ListCard key={list.id} list={list} onClick={() => navigate(`/lists/${list.id}`)} />
      ))}
    </div>
  );
}
```

### Step 2: Create List

Update `CreateList.tsx`:

```typescript
import { useForm } from 'react-hook-form';
import { listsService } from '../services';

export function CreateList() {
  const navigate = useNavigate();
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm();

  async function onSubmit(data) {
    try {
      const newList = await listsService.createList({
        name: data.name,
        description: data.description || null
      });
      navigate(`/lists/${newList.id}`);
    } catch (err) {
      alert('Failed to create list');
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('name', {
          required: 'List name is required',
          maxLength: { value: 200, message: 'Max 200 characters' }
        })}
        placeholder="List name"
      />
      {errors.name && <span>{errors.name.message}</span>}
      
      <textarea
        {...register('description', {
          maxLength: { value: 1000, message: 'Max 1000 characters' }
        })}
        placeholder="Description (optional)"
      />
      
      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create List'}
      </button>
    </form>
  );
}
```

### Step 3: Update List

Update `ListSettings.tsx`:

```typescript
async function handleUpdateList(data) {
  try {
    await listsService.updateList(listId, {
      name: data.name,
      description: data.description
    });
    alert('List updated successfully');
    // Refresh list data
    loadList();
  } catch (err) {
    alert('Failed to update list');
  }
}
```

### Step 4: Delete List

Add delete with confirmation:

```typescript
async function handleDeleteList() {
  if (!confirm('Permanently delete this list and all items?')) return;
  
  try {
    await listsService.deleteList(listId);
    navigate('/lists');
  } catch (err) {
    alert('Failed to delete list');
  }
}
```

### Step 5: Archive/Unarchive

```typescript
async function handleArchive() {
  try {
    await listsService.archiveList(listId);
    navigate('/lists');
  } catch (err) {
    alert('Failed to archive list');
  }
}

async function handleUnarchive() {
  try {
    await listsService.unarchiveList(listId);
    // Reload list
    loadList();
  } catch (err) {
    alert('Failed to unarchive list');
  }
}
```

---

## Testing Integration

1. **Start backend**: `cd ae-infinity-api && dotnet run`
2. **Start frontend**: `cd ae-infinity-ui && npm run dev`
3. **Login**: Use test account sarah@example.com / Password123!
4. **Create list**: Name "Test List", verify it appears
5. **Edit list**: Change name, verify update
6. **Archive list**: Verify it disappears from dashboard
7. **View archived**: Navigate to /archived, verify list appears
8. **Unarchive**: Verify list returns to dashboard
9. **Delete list**: Confirm deletion dialog, verify list gone

---

**Full documentation**: See [data-model.md](./data-model.md) and [contracts/](./contracts/)
