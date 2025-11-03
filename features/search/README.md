# Search

**Feature Domain**: Search  
**Version**: 1.0  
**Status**: 100% Backend, 100% Frontend Service, 0% UI

---

## Overview

Global search across lists and items.

---

## Features

| Feature | API Endpoint | Backend | Frontend | Status |
|---------|--------------|---------|----------|--------|
| Search All | GET `/search?scope=all` | ✅ | ✅ Service Only | Ready for UI |
| Search Lists | GET `/search?scope=lists` | ✅ | ✅ Service Only | Ready for UI |
| Search Items | GET `/search?scope=items` | ✅ | ✅ Service Only | Ready for UI |
| Search Pagination | Query params | ✅ | ❌ | Backend Only |

---

## API Specification

See [API_SPEC.md](../../API_SPEC.md) lines 618-656

### GET /search
Query Parameters:
- `q: string` - Search query (required)
- `scope?: 'all' | 'lists' | 'items'` - What to search (default: 'all')
- `page?: number` - Page number (default: 1)
- `pageSize?: number` - Items per page (default: 20)

Response:
```json
{
  "lists": [
    // ShoppingListSummary objects
  ],
  "items": [
    {
      // ShoppingItem properties
      "listId": "string",
      "listName": "string"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "pageSize": 20,
    "totalPages": 5,
    "totalCount": 100,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

---

## Search Capabilities

### What Can Be Searched

**Lists**:
- List name
- List description

**Items**:
- Item name
- Item notes
- Category name

### Search Algorithm
- Case-insensitive
- Partial matching
- Word boundaries
- Relevance scoring (backend can implement)

---

## Frontend Implementation

### Services
**Location**: `ae-infinity-ui/src/services/searchService.ts` ✅

All methods implemented:
- `search(params)`
- `searchLists(query)`
- `searchItems(query)`
- `searchAll(query)`

### UI Components Needed ❌

#### 1. Global Search Bar
**Location**: Header component

```typescript
<input 
  type="search"
  placeholder="Search lists and items..."
  onChange={handleSearch}
/>
```

#### 2. Search Results Page
**Location**: `ae-infinity-ui/src/pages/Search.tsx` ❌

- Display search results
- Filter by type (lists/items)
- Pagination
- Click to navigate to list/item

#### 3. Quick Search Dropdown
**Location**: Header component

- Show top 5 results as you type
- "See all results" link
- Recent searches

---

## Backend Implementation

### Controllers
**Location**: `ae-infinity-api/src/AeInfinity.Api/Controllers/SearchController.cs` ✅

### Features (CQRS)
**Location**: `ae-infinity-api/src/AeInfinity.Application/Features/Search/`

- Search query ✅

### Search Implementation
Currently uses LIKE queries. Can be enhanced with:
- Full-text search
- Elasticsearch integration
- Search result ranking
- Fuzzy matching

---

## User Stories

### Quick Search
```
As a user
I want to quickly search for lists or items
So that I can find what I need without browsing
```

**Acceptance Criteria**:
- Search bar in header
- Real-time search as you type
- Display results dropdown
- Show lists and items separately
- Click result to navigate

### Advanced Search
```
As a user
I want to filter search results
So that I can find specific content
```

**Acceptance Criteria**:
- Filter by type (lists/items)
- Sort results by relevance
- Pagination for many results
- Show matching snippet/highlight

---

## Integration Steps

### 1. Add Search Bar to Header
```typescript
const [query, setQuery] = useState('')
const [results, setResults] = useState<SearchResponse | null>(null)

const handleSearch = useDebounce(async (q: string) => {
  if (q.length < 2) return
  const results = await searchService.search({ q, scope: 'all' })
  setResults(results)
}, 300)
```

### 2. Create Search Results Page
- Route: `/search?q=...`
- Display lists and items
- Pagination
- Filter controls

### 3. Add Quick Results Dropdown
- Show top results in dropdown
- Limit to 5 items
- Link to full search page

---

## Performance Considerations

### Debouncing
- Wait 300ms after user stops typing
- Cancel pending requests
- Show loading indicator

### Caching
- Cache recent searches
- Cache search results
- Clear cache on data changes

### Optimization
- Backend: Indexed search columns
- Frontend: Virtual scrolling for many results
- Consider Elasticsearch for large datasets

---

## Future Enhancements

### Advanced Features
- Search filters (date range, category, collaborator)
- Search history
- Saved searches
- Search suggestions/autocomplete
- Fuzzy matching for typos
- Search within a specific list

---

## Next Steps

1. ✅ Backend complete
2. ✅ Frontend service complete
3. 🔄 Add search bar to Header
4. 🔄 Create Search results page
5. 🔄 Implement quick search dropdown
6. 🔄 Add debouncing
7. 🔄 Test search functionality

---

## Related Features

- [Lists](../lists/) - Search lists
- [Items](../items/) - Search items

