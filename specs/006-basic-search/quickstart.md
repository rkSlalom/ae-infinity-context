# Quickstart: Basic Search Implementation

**Feature**: 006-basic-search  
**For**: Developers implementing the search feature  
**Estimated Time**: 3-5 days

---

## Prerequisites

- [ ] Feature 001: User Authentication completed (JWT auth working)
- [ ] Feature 003: Shopping Lists CRUD completed (lists exist in database)
- [ ] Feature 004: List Items Management completed (items exist in database)
- [ ] Backend repository `ae-infinity-api` cloned and building
- [ ] Frontend repository `ae-infinity-ui` cloned and running
- [ ] Read [spec.md](./spec.md), [plan.md](./plan.md), [data-model.md](./data-model.md)

---

## Implementation Roadmap

```
Phase 1: Backend (TDD)           → 1.5 days
Phase 2: Frontend (TDD)          → 1.5 days
Phase 3: Integration & Testing   → 1 day
Total: 3-5 days
```

---

## Phase 1: Backend Implementation (1.5 days)

### Step 1.1: Create DTOs and Query Parameters (30 mins)

**File**: `src/AeInfinity.Application/DTOs/Search/SearchQueryParams.cs`

```csharp
using System.ComponentModel.DataAnnotations;

namespace AeInfinity.Application.DTOs.Search;

public class SearchQueryParams
{
    [Required(ErrorMessage = "Query is required")]
    [StringLength(200, MinimumLength = 1, ErrorMessage = "Query must be 1-200 characters")]
    public string Query { get; set; } = string.Empty;

    public SearchScope Scope { get; set; } = SearchScope.All;

    [Range(1, int.MaxValue, ErrorMessage = "Page must be at least 1")]
    public int Page { get; set; } = 1;

    [Range(1, 100, ErrorMessage = "Page size must be between 1 and 100")]
    public int PageSize { get; set; } = 20;

    public bool IncludeShared { get; set; } = true;
}

public enum SearchScope
{
    All,
    Lists,
    Items
}
```

**Files to create**:
- `SearchResponse.cs` - Root response object (see data-model.md section 2.1)
- `ListSearchResult.cs` - List result DTO (see data-model.md section 2.2)
- `ItemSearchResult.cs` - Item result DTO (see data-model.md section 2.3)
- `PaginationDto.cs` - Pagination metadata (see data-model.md section 2.1)

✅ **Test**: Compile project, no errors

---

### Step 1.2: Create Search Query and Validator (30 mins)

**File**: `src/AeInfinity.Application/Features/Search/SearchQuery.cs`

```csharp
using AeInfinity.Application.DTOs.Search;
using FluentValidation;
using MediatR;

namespace AeInfinity.Application.Features.Search;

public class SearchQuery : IRequest<SearchResponse>
{
    public string Query { get; set; } = string.Empty;
    public SearchScope Scope { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
    public bool IncludeShared { get; set; }
    public Guid CurrentUserId { get; set; }
}

public class SearchQueryValidator : AbstractValidator<SearchQuery>
{
    public SearchQueryValidator()
    {
        RuleFor(x => x.Query)
            .NotEmpty()
            .Length(1, 200)
            .WithMessage("Query must be 1-200 characters");

        RuleFor(x => x.Page)
            .GreaterThanOrEqualTo(1)
            .WithMessage("Page must be at least 1");

        RuleFor(x => x.PageSize)
            .InclusiveBetween(1, 100)
            .WithMessage("Page size must be between 1 and 100");

        RuleFor(x => x.CurrentUserId)
            .NotEmpty()
            .WithMessage("User ID is required");
    }
}
```

✅ **Test**: Write unit test for validator:

**File**: `tests/AeInfinity.Application.Tests/Search/SearchQueryValidatorTests.cs`

```csharp
public class SearchQueryValidatorTests
{
    private readonly SearchQueryValidator _validator = new();

    [Fact]
    public void Validate_WithValidQuery_Passes()
    {
        var query = new SearchQuery
        {
            Query = "milk",
            Page = 1,
            PageSize = 20,
            CurrentUserId = Guid.NewGuid()
        };

        var result = _validator.Validate(query);

        Assert.True(result.IsValid);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public void Validate_WithEmptyQuery_Fails(string emptyQuery)
    {
        var query = new SearchQuery { Query = emptyQuery };
        
        var result = _validator.Validate(query);

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == nameof(SearchQuery.Query));
    }

    [Fact]
    public void Validate_WithQueryTooLong_Fails()
    {
        var query = new SearchQuery { Query = new string('a', 201) };
        
        var result = _validator.Validate(query);

        Assert.False(result.IsValid);
    }
}
```

---

### Step 1.3: Implement Search Handler (1 hour)

**File**: `src/AeInfinity.Application/Features/Search/SearchHandler.cs`

```csharp
using AeInfinity.Application.DTOs.Search;
using AeInfinity.Core.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace AeInfinity.Application.Features.Search;

public class SearchHandler : IRequestHandler<SearchQuery, SearchResponse>
{
    private readonly IAppDbContext _context;

    public SearchHandler(IAppDbContext context)
    {
        _context = context;
    }

    public async Task<SearchResponse> Handle(SearchQuery request, CancellationToken cancellationToken)
    {
        // Escape special LIKE characters
        var escapedQuery = EscapeLikePattern(request.Query);

        // Get accessible list IDs for permission filtering
        var accessibleListIds = await GetAccessibleListIdsAsync(
            request.CurrentUserId, 
            request.IncludeShared,
            cancellationToken
        );

        // Initialize response
        var response = new SearchResponse
        {
            Query = request.Query,
            Scope = request.Scope
        };

        // Search lists if scope includes them
        if (request.Scope == SearchScope.All || request.Scope == SearchScope.Lists)
        {
            response.Lists = await SearchListsAsync(
                escapedQuery, 
                accessibleListIds, 
                request.CurrentUserId,
                request.Page, 
                request.PageSize,
                cancellationToken
            );
        }

        // Search items if scope includes them
        if (request.Scope == SearchScope.All || request.Scope == SearchScope.Items)
        {
            response.Items = await SearchItemsAsync(
                escapedQuery, 
                accessibleListIds, 
                request.CurrentUserId,
                request.Page, 
                request.PageSize,
                cancellationToken
            );
        }

        // Calculate pagination metadata
        response.Pagination = CalculatePagination(
            request.Page, 
            request.PageSize, 
            response.Lists.Total + response.Items.Total
        );

        return response;
    }

    private async Task<HashSet<Guid>> GetAccessibleListIdsAsync(
        Guid userId, 
        bool includeShared,
        CancellationToken cancellationToken)
    {
        var query = _context.ShoppingLists
            .Where(list => list.OwnerId == userId);

        if (includeShared)
        {
            query = query.Union(
                _context.ShoppingLists
                    .Where(list => list.Collaborators.Any(c => c.UserId == userId))
            );
        }

        var listIds = await query
            .Select(list => list.Id)
            .ToListAsync(cancellationToken);

        return listIds.ToHashSet();
    }

    private async Task<SearchResultSet<ListSearchResult>> SearchListsAsync(
        string escapedQuery,
        HashSet<Guid> accessibleListIds,
        Guid currentUserId,
        int page,
        int pageSize,
        CancellationToken cancellationToken)
    {
        var listsQuery = _context.ShoppingLists
            .Include(list => list.Owner)
            .Include(list => list.Items)
            .Where(list => accessibleListIds.Contains(list.Id))
            .Where(list => EF.Functions.Like(list.Name, $"%{escapedQuery}%"));

        var totalCount = await listsQuery.CountAsync(cancellationToken);

        var lists = await listsQuery
            .OrderBy(list => list.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return new SearchResultSet<ListSearchResult>
        {
            Total = totalCount,
            Results = lists.Select(list => ListSearchResult.FromEntity(list, currentUserId)).ToList()
        };
    }

    private async Task<SearchResultSet<ItemSearchResult>> SearchItemsAsync(
        string escapedQuery,
        HashSet<Guid> accessibleListIds,
        Guid currentUserId,
        int page,
        int pageSize,
        CancellationToken cancellationToken)
    {
        var itemsQuery = _context.ListItems
            .Include(item => item.ShoppingList)
                .ThenInclude(list => list.Owner)
            .Include(item => item.Category)
            .Where(item => accessibleListIds.Contains(item.ShoppingListId))
            .Where(item =>
                EF.Functions.Like(item.Name, $"%{escapedQuery}%") ||
                EF.Functions.Like(item.Notes ?? "", $"%{escapedQuery}%")
            );

        var totalCount = await itemsQuery.CountAsync(cancellationToken);

        var items = await itemsQuery
            .OrderBy(item => item.Name)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return new SearchResultSet<ItemSearchResult>
        {
            Total = totalCount,
            Results = items.Select(item => ItemSearchResult.FromEntity(item, currentUserId)).ToList()
        };
    }

    private PaginationDto CalculatePagination(int page, int pageSize, int totalCount)
    {
        var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

        return new PaginationDto
        {
            Page = page,
            PageSize = pageSize,
            TotalPages = totalPages,
            HasNext = page < totalPages,
            HasPrevious = page > 1
        };
    }

    private static string EscapeLikePattern(string input)
    {
        if (string.IsNullOrEmpty(input))
            return input;

        return input
            .Replace("\\", "\\\\")
            .Replace("%", "\\%")
            .Replace("_", "\\_")
            .Replace("[", "\\[");
    }
}
```

✅ **Test**: Write integration test for SearchHandler (see Step 1.5)

---

### Step 1.4: Create Search Controller (30 mins)

**File**: `src/AeInfinity.Api/Controllers/SearchController.cs`

```csharp
using AeInfinity.Application.DTOs.Search;
using AeInfinity.Application.Features.Search;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AeInfinity.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class SearchController : ControllerBase
{
    private readonly IMediator _mediator;

    public SearchController(IMediator mediator)
    {
        _mediator = mediator;
    }

    /// <summary>
    /// Search for lists and items by name.
    /// </summary>
    /// <param name="queryParams">Search parameters</param>
    /// <returns>Search results with lists and items</returns>
    [HttpGet]
    [ProducesResponseType(typeof(SearchResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<SearchResponse>> Search([FromQuery] SearchQueryParams queryParams)
    {
        // Get current user ID from JWT claims
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        // Map query params to MediatR command
        var query = new SearchQuery
        {
            Query = queryParams.Query.Trim(),
            Scope = queryParams.Scope,
            Page = queryParams.Page,
            PageSize = queryParams.PageSize,
            IncludeShared = queryParams.IncludeShared,
            CurrentUserId = userId
        };

        // Execute search via MediatR
        var result = await _mediator.Send(query);

        return Ok(result);
    }
}
```

✅ **Test**: Write integration test for SearchController (see Step 1.5)

---

### Step 1.5: Write Integration Tests (1 hour)

**File**: `tests/AeInfinity.Api.IntegrationTests/SearchControllerTests.cs`

```csharp
public class SearchControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;

    public SearchControllerTests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = _factory.CreateClient();
    }

    [Fact]
    public async Task Search_WithValidQuery_ReturnsResults()
    {
        // Arrange
        var token = await GetAuthTokenAsync();
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);

        // Act
        var response = await _client.GetAsync(
            "/api/search?query=milk&scope=all&page=1&pageSize=20"
        );

        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<SearchResponse>(content);

        Assert.NotNull(result);
        Assert.Equal("milk", result.Query);
        Assert.True(result.Lists.Total >= 0);
        Assert.True(result.Items.Total >= 0);
    }

    [Fact]
    public async Task Search_WithoutAuthentication_Returns401()
    {
        // Act
        var response = await _client.GetAsync("/api/search?query=milk");

        // Assert
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    public async Task Search_WithEmptyQuery_Returns400(string emptyQuery)
    {
        // Arrange
        var token = await GetAuthTokenAsync();
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);

        // Act
        var response = await _client.GetAsync($"/api/search?query={emptyQuery}");

        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task Search_OnlySearchesAccessibleLists()
    {
        // Arrange: Create user1 with list1, user2 with list2
        // Only user1 should see list1 in search results
        // TODO: Implement test with seeded data
    }
}
```

---

### Step 1.6: Add Database Indexes (Migration) (15 mins)

**File**: `src/AeInfinity.Infrastructure/Data/Migrations/YYYYMMDDHHMMSS_AddSearchIndexes.cs`

```csharp
public partial class AddSearchIndexes : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateIndex(
            name: "IX_ShoppingLists_Name",
            table: "ShoppingLists",
            column: "Name");

        migrationBuilder.CreateIndex(
            name: "IX_ListItems_Name",
            table: "ListItems",
            column: "Name");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "IX_ShoppingLists_Name",
            table: "ShoppingLists");

        migrationBuilder.DropIndex(
            name: "IX_ListItems_Name",
            table: "ListItems");
    }
}
```

**Run migration**:
```bash
cd src/AeInfinity.Infrastructure
dotnet ef migrations add AddSearchIndexes
dotnet ef database update
```

✅ **Test**: Query database to verify indexes exist

---

## Phase 2: Frontend Implementation (1.5 days)

### Step 2.1: Create TypeScript Types (15 mins)

**File**: `src/types/search.ts`

```typescript
export interface SearchQueryParams {
  query: string;
  scope: 'all' | 'lists' | 'items';
  page: number;
  pageSize: number;
  includeShared: boolean;
}

export interface SearchResponse {
  query: string;
  scope: SearchScope;
  lists: SearchResultSet<ListSearchResult>;
  items: SearchResultSet<ItemSearchResult>;
  pagination: Pagination;
}

export interface SearchResultSet<T> {
  total: number;
  results: T[];
}

export interface ListSearchResult {
  id: string;
  name: string;
  description: string | null;
  owner: UserBasic;
  totalItems: number;
  purchasedItems: number;
  isOwner: boolean;
  isArchived: boolean;
  lastUpdatedAt: string;
}

export interface ItemSearchResult {
  id: string;
  name: string;
  quantity: number | null;
  unit: string | null;
  notes: string | null;
  isPurchased: boolean;
  category: CategoryRef | null;
  parentList: ListRef;
}

export interface Pagination {
  page: number;
  pageSize: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

export type SearchScope = 'all' | 'lists' | 'items';
```

---

### Step 2.2: Create Search Service (30 mins)

**File**: `src/services/searchService.ts`

```typescript
import { SearchQueryParams, SearchResponse } from '../types/search';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000';

class SearchService {
  async search(
    params: Partial<SearchQueryParams>,
    signal?: AbortSignal
  ): Promise<SearchResponse> {
    const queryParams = new URLSearchParams({
      query: params.query || '',
      scope: params.scope || 'all',
      page: String(params.page || 1),
      pageSize: String(params.pageSize || 20),
      includeShared: String(params.includeShared ?? true),
    });

    const token = localStorage.getItem('authToken');
    if (!token) {
      throw new Error('Not authenticated');
    }

    const response = await fetch(
      `${API_BASE_URL}/api/search?${queryParams.toString()}`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        signal,
      }
    );

    if (!response.ok) {
      const error = await response.json().catch(() => ({ message: 'Search failed' }));
      throw new Error(error.message || 'Search failed');
    }

    return response.json();
  }
}

export const searchService = new SearchService();
```

---

### Step 2.3: Create useDebounce Hook (15 mins)

**File**: `src/hooks/useDebounce.ts`

```typescript
import { useEffect, useState } from 'react';

export function useDebounce<T>(value: T, delay: number = 300): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}
```

---

### Step 2.4: Create useSearch Hook (30 mins)

**File**: `src/hooks/useSearch.ts`

```typescript
import { useState, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { SearchResponse, SearchScope } from '../types/search';
import { searchService } from '../services/searchService';
import { useDebounce } from './useDebounce';

export function useSearch() {
  const [searchParams, setSearchParams] = useSearchParams();
  
  const query = searchParams.get('query') || '';
  const scope = (searchParams.get('scope') as SearchScope) || 'all';
  const page = parseInt(searchParams.get('page') || '1');
  
  const [results, setResults] = useState<SearchResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const debouncedQuery = useDebounce(query, 300);

  // Perform search when debounced query changes
  useEffect(() => {
    if (!debouncedQuery.trim()) {
      setResults(null);
      return;
    }

    const abortController = new AbortController();

    const performSearch = async () => {
      setIsLoading(true);
      setError(null);

      try {
        const data = await searchService.search(
          { query: debouncedQuery, scope, page, pageSize: 20 },
          abortController.signal
        );
        setResults(data);
      } catch (err: any) {
        if (err.name !== 'AbortError') {
          setError(err.message || 'Search failed');
        }
      } finally {
        setIsLoading(false);
      }
    };

    performSearch();

    return () => {
      abortController.abort();
    };
  }, [debouncedQuery, scope, page]);

  // Update URL when search params change
  const updateSearch = (newQuery: string, newScope?: SearchScope) => {
    const params = new URLSearchParams();
    if (newQuery.trim()) {
      params.set('query', newQuery.trim());
      params.set('scope', newScope || scope);
      params.set('page', '1');  // Reset to page 1 on new search
    }
    setSearchParams(params);
  };

  const setPage = (newPage: number) => {
    searchParams.set('page', newPage.toString());
    setSearchParams(searchParams);
  };

  return {
    query,
    scope,
    page,
    results,
    isLoading,
    error,
    updateSearch,
    setPage,
  };
}
```

---

### Step 2.5: Create SearchBar Component (45 mins)

**File**: `src/components/search/SearchBar.tsx`

```typescript
import React, { useState } from 'react';
import { Search, X } from 'lucide-react';
import { SearchScope } from '../../types/search';

interface SearchBarProps {
  initialQuery?: string;
  initialScope?: SearchScope;
  onSearch: (query: string, scope: SearchScope) => void;
  isLoading?: boolean;
}

export const SearchBar: React.FC<SearchBarProps> = ({
  initialQuery = '',
  initialScope = 'all',
  onSearch,
  isLoading = false,
}) => {
  const [query, setQuery] = useState(initialQuery);
  const [scope, setScope] = useState<SearchScope>(initialScope);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      onSearch(query.trim(), scope);
    }
  };

  const handleClear = () => {
    setQuery('');
    onSearch('', scope);
  };

  return (
    <form onSubmit={handleSubmit} className="flex gap-2 items-center">
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search lists and items..."
          className="w-full pl-10 pr-10 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
          maxLength={200}
          disabled={isLoading}
        />
        {query && (
          <button
            type="button"
            onClick={handleClear}
            className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600"
          >
            <X className="w-5 h-5" />
          </button>
        )}
      </div>

      <select
        value={scope}
        onChange={(e) => setScope(e.target.value as SearchScope)}
        className="px-4 py-2 border border-gray-300 rounded-lg"
        disabled={isLoading}
      >
        <option value="all">All</option>
        <option value="lists">Lists only</option>
        <option value="items">Items only</option>
      </select>
    </form>
  );
};
```

✅ **Test**: Create SearchBar.test.tsx with Vitest + React Testing Library

---

### Step 2.6: Create SearchHighlight Component (20 mins)

**File**: `src/components/search/SearchHighlight.tsx`

```typescript
import React from 'react';

interface SearchHighlightProps {
  text: string;
  query: string;
  className?: string;
}

function escapeRegex(text: string): string {
  return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

export const SearchHighlight: React.FC<SearchHighlightProps> = ({
  text,
  query,
  className = '',
}) => {
  if (!query.trim()) {
    return <span className={className}>{text}</span>;
  }

  const escapedQuery = escapeRegex(query);
  const regex = new RegExp(`(${escapedQuery})`, 'gi');
  const parts = text.split(regex);

  return (
    <span className={className}>
      {parts.map((part, index) =>
        regex.test(part) ? (
          <mark
            key={index}
            className="bg-yellow-200 text-gray-900 font-medium"
            aria-label={`Match: ${part}`}
          >
            {part}
          </mark>
        ) : (
          <span key={index}>{part}</span>
        )
      )}
    </span>
  );
};
```

---

### Step 2.7: Create SearchResults Components (1 hour)

**File**: `src/components/search/SearchResults.tsx`

```typescript
import React from 'react';
import { SearchResponse } from '../../types/search';
import { ListSearchResult } from './ListSearchResult';
import { ItemSearchResult } from './ItemSearchResult';
import { SearchPagination } from './SearchPagination';

interface SearchResultsProps {
  results: SearchResponse;
  query: string;
  onPageChange: (page: number) => void;
}

export const SearchResults: React.FC<SearchResultsProps> = ({
  results,
  query,
  onPageChange,
}) => {
  const totalResults = results.lists.total + results.items.total;

  if (totalResults === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-600">
          No results found for "{query}"
        </p>
        <p className="text-gray-500 text-sm mt-2">
          Try a different search term
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Lists Section */}
      {results.lists.total > 0 && (
        <div>
          <h2 className="text-lg font-semibold mb-3">
            Lists ({results.lists.total})
          </h2>
          <div className="space-y-2">
            {results.lists.results.map((list) => (
              <ListSearchResult key={list.id} list={list} query={query} />
            ))}
          </div>
        </div>
      )}

      {/* Items Section */}
      {results.items.total > 0 && (
        <div>
          <h2 className="text-lg font-semibold mb-3">
            Items ({results.items.total})
          </h2>
          <div className="space-y-2">
            {results.items.results.map((item) => (
              <ItemSearchResult key={item.id} item={item} query={query} />
            ))}
          </div>
        </div>
      )}

      {/* Pagination */}
      <SearchPagination
        pagination={results.pagination}
        onPageChange={onPageChange}
      />
    </div>
  );
};
```

Implement `ListSearchResult.tsx`, `ItemSearchResult.tsx`, and `SearchPagination.tsx` following similar patterns (see data-model.md for full structure).

---

### Step 2.8: Integrate Search into App (30 mins)

**File**: `src/pages/SearchPage.tsx`

```typescript
import React from 'react';
import { SearchBar } from '../components/search/SearchBar';
import { SearchResults } from '../components/search/SearchResults';
import { useSearch } from '../hooks/useSearch';

export const SearchPage: React.FC = () => {
  const {
    query,
    scope,
    results,
    isLoading,
    error,
    updateSearch,
    setPage,
  } = useSearch();

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Search</h1>

      <SearchBar
        initialQuery={query}
        initialScope={scope}
        onSearch={updateSearch}
        isLoading={isLoading}
      />

      {isLoading && (
        <div className="text-center py-12">
          <p className="text-gray-600">Searching...</p>
        </div>
      )}

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mt-4">
          {error}
        </div>
      )}

      {results && !isLoading && (
        <div className="mt-6">
          <SearchResults
            results={results}
            query={query}
            onPageChange={setPage}
          />
        </div>
      )}
    </div>
  );
};
```

**Add route** in `src/App.tsx`:

```typescript
<Route path="/search" element={<SearchPage />} />
```

---

## Phase 3: Integration & Testing (1 day)

### Step 3.1: End-to-End Testing (2 hours)

1. Start backend API
2. Start frontend dev server
3. Test user flow:
   - Login as user
   - Navigate to /search
   - Type "milk" in search box
   - Verify results appear after 300ms
   - Click on list result → navigates to list detail
   - Click on item result → navigates to parent list with item highlighted
   - Test pagination with 50+ results
   - Test scope filters (All/Lists/Items)
   - Test with special characters (*, [, ], %)
   - Test with emojis (🍎)
   - Test permission filtering (shared lists appear)

### Step 3.2: Performance Testing (1 hour)

- Seed database with 10,000 items across 1,000 lists
- Measure search response time: target <500ms
- Verify pagination works with large result sets
- Check debouncing reduces API calls

### Step 3.3: Accessibility Testing (1 hour)

- Screen reader test: highlighted text announced correctly
- Keyboard navigation: Tab through search inputs and results
- Color contrast: Yellow highlighting (#FFEB3B) meets WCAG AA

### Step 3.4: Documentation Updates (30 mins)

Update these files:
- `FEATURES.md`: Set Feature 006 to 100% complete
- `API_REFERENCE.md`: Document GET /api/search endpoint
- `README.md`: Add search demo screenshot

---

## Verification Checklist

- [ ] Backend compiles without errors
- [ ] Frontend builds without errors
- [ ] All unit tests pass (backend + frontend)
- [ ] All integration tests pass
- [ ] Search returns results for valid queries
- [ ] Pagination works correctly
- [ ] Highlighting displays matching text
- [ ] Permission filtering prevents unauthorized access
- [ ] Debouncing reduces API calls by 80%
- [ ] Special characters handled correctly
- [ ] Performance meets targets (<500ms p95)
- [ ] Accessibility meets WCAG AA

---

## Troubleshooting

### Backend Issues

**Problem**: Search returns 500 error  
**Solution**: Check database migrations applied, verify indexes exist

**Problem**: Permission filtering not working  
**Solution**: Verify Collaborator relationships exist, check JOIN query

### Frontend Issues

**Problem**: Highlighting not working  
**Solution**: Verify SearchHighlight component receives correct query prop

**Problem**: Debounce delay too long  
**Solution**: Adjust delay in useDebounce hook (currently 300ms)

**Problem**: Search results not updating  
**Solution**: Check AbortController canceling old requests correctly

---

## Next Steps

After Feature 006 is complete:
1. Deploy to staging environment
2. User acceptance testing
3. Monitor performance metrics
4. Begin Feature 013: Advanced Search & Filters

---

**Questions?** Refer to [spec.md](./spec.md) for requirements or [data-model.md](./data-model.md) for entity definitions.

**Last Updated**: 2025-11-05

