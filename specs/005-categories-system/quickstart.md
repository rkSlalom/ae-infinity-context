# Quick Start: Categories System

**Feature**: 005-categories-system  
**Date**: 2025-11-05  
**Phase**: Phase 1 - Developer Implementation Guide

## Overview

This quick start guide provides step-by-step instructions for integrating the Categories System into the AE Infinity application. Both backend and frontend are already implemented—this guide focuses on **integration, testing, and verification**.

**Prerequisites**:
- Backend: .NET 9 SDK, ae-infinity-api repository cloned
- Frontend: Node.js 18+, ae-infinity-ui repository cloned
- Database: SQLite (dev) or PostgreSQL/SQL Server (prod)
- IDE: VS Code, Visual Studio, or Rider

---

## Phase 1: Backend Integration (1-2 days)

### Step 1: Verify Default Category Seeding

**Goal**: Ensure 10 default categories are seeded on application startup.

**Location**: `ae-infinity-api/src/AeInfinity.Infrastructure/Persistence/ApplicationDbContextSeed.cs`

**Verify Seed Logic**:
```csharp
public static async Task SeedDefaultCategoriesAsync(ApplicationDbContext context)
{
    // Check if default categories already exist
    if (await context.Categories.AnyAsync(c => c.IsDefault))
    {
        return; // Already seeded
    }

    var defaultCategories = new[]
    {
        new Category { Name = "Produce", Icon = "🥬", Color = "#4CAF50", IsDefault = true },
        new Category { Name = "Dairy", Icon = "🥛", Color = "#2196F3", IsDefault = true },
        new Category { Name = "Meat", Icon = "🥩", Color = "#F44336", IsDefault = true },
        new Category { Name = "Seafood", Icon = "🐟", Color = "#00BCD4", IsDefault = true },
        new Category { Name = "Bakery", Icon = "🍞", Color = "#FF9800", IsDefault = true },
        new Category { Name = "Frozen", Icon = "❄️", Color = "#03A9F4", IsDefault = true },
        new Category { Name = "Beverages", Icon = "🥤", Color = "#9C27B0", IsDefault = true },
        new Category { Name = "Snacks", Icon = "🍿", Color = "#FF5722", IsDefault = true },
        new Category { Name = "Household", Icon = "🧼", Color = "#607D8B", IsDefault = true },
        new Category { Name = "Personal Care", Icon = "🧴", Color = "#E91E63", IsDefault = true }
    };

    context.Categories.AddRange(defaultCategories);
    await context.SaveChangesAsync();
}
```

**Update Program.cs** (if not already present):
```csharp
// In Program.cs, after app.Build() and before app.Run()
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    
    // Run migrations
    await context.Database.MigrateAsync();
    
    // Seed default categories
    await ApplicationDbContextSeed.SeedDefaultCategoriesAsync(context);
}
```

**Test**:
1. Delete your local database (or use a fresh database)
2. Run the API: `dotnet run --project src/AeInfinity.Api`
3. Check logs for seeding confirmation
4. Query database: `SELECT * FROM Categories WHERE IsDefault = 1`
5. Verify 10 categories exist with correct icons and colors

**Expected Output** (database query):
```
Id                                   | Name          | Icon | Color    | IsDefault
-------------------------------------|---------------|------|----------|----------
<guid>                               | Produce       | 🥬   | #4CAF50  | 1
<guid>                               | Dairy         | 🥛   | #2196F3  | 1
<guid>                               | Meat          | 🥩   | #F44336  | 1
... (7 more rows)
```

---

### Step 2: Test GET /categories Endpoint

**Goal**: Verify category retrieval works for authenticated and unauthenticated users.

**Endpoint**: `GET /api/categories?includeCustom={true|false}`

**Test 1: Unauthenticated Request (Defaults Only)**
```bash
curl -X GET "https://localhost:5001/api/categories" \
  -H "accept: application/json"
```

**Expected Response** (200 OK):
```json
{
  "categories": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "name": "Produce",
      "icon": "🥬",
      "color": "#4CAF50",
      "isDefault": true,
      "createdBy": null
    },
    ... (9 more default categories)
  ]
}
```

**Test 2: Authenticated Request (Defaults + Custom)**
```bash
# First, login to get JWT token
curl -X POST "https://localhost:5001/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah@example.com","password":"Password123!"}'

# Extract token from response, then:
curl -X GET "https://localhost:5001/api/categories?includeCustom=true" \
  -H "accept: application/json" \
  -H "Authorization: Bearer <your-jwt-token>"
```

**Expected Response** (200 OK):
```json
{
  "categories": [
    ... (10 default categories),
    {
      "id": "5fa85f64-5717-4562-b3fc-2c963f66afa8",
      "name": "Pet Supplies",
      "icon": "🐾",
      "color": "#8B4513",
      "isDefault": false,
      "createdBy": {
        "id": "7fa85f64-5717-4562-b3fc-2c963f66afa9",
        "displayName": "Sarah Thompson",
        "email": "sarah@example.com"
      }
    }
  ]
}
```

**Test 3: Authenticated Request (Defaults Only)**
```bash
curl -X GET "https://localhost:5001/api/categories?includeCustom=false" \
  -H "accept: application/json" \
  -H "Authorization: Bearer <your-jwt-token>"
```

**Expected**: Only 10 default categories returned (no custom categories).

---

### Step 3: Test POST /categories Endpoint

**Goal**: Verify custom category creation with validation.

**Endpoint**: `POST /api/categories`

**Test 1: Valid Category Creation**
```bash
curl -X POST "https://localhost:5001/api/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -d '{
    "name": "Pet Supplies",
    "icon": "🐾",
    "color": "#8B4513"
  }'
```

**Expected Response** (201 Created):
```json
{
  "id": "5fa85f64-5717-4562-b3fc-2c963f66afa8",
  "name": "Pet Supplies",
  "icon": "🐾",
  "color": "#8B4513",
  "isDefault": false,
  "createdBy": {
    "id": "7fa85f64-5717-4562-b3fc-2c963f66afa9",
    "displayName": "Sarah Thompson",
    "email": "sarah@example.com"
  }
}
```

**Test 2: Duplicate Name (Case-Insensitive)**
```bash
curl -X POST "https://localhost:5001/api/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -d '{
    "name": "pet supplies",
    "icon": "🐶",
    "color": "#8B4513"
  }'
```

**Expected Response** (400 Bad Request):
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Name": ["A category with this name already exists"]
  }
}
```

**Test 3: Invalid Color Format**
```bash
curl -X POST "https://localhost:5001/api/categories" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your-jwt-token>" \
  -d '{
    "name": "Garden",
    "icon": "🌱",
    "color": "green"
  }'
```

**Expected Response** (400 Bad Request):
```json
{
  "errors": {
    "Color": ["Color must be a valid hex code (e.g., #4CAF50 or #FFF)"]
  }
}
```

**Test 4: Unauthenticated Request**
```bash
curl -X POST "https://localhost:5001/api/categories" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Garden",
    "icon": "🌱",
    "color": "#228B22"
  }'
```

**Expected Response** (401 Unauthorized):
```json
{
  "type": "https://tools.ietf.org/html/rfc7235#section-3.1",
  "title": "Unauthorized",
  "status": 401
}
```

---

### Step 4: Write Backend Integration Tests

**Goal**: Automate endpoint testing with xUnit.

**Location**: `ae-infinity-api/tests/AeInfinity.IntegrationTests/Categories/CategoriesControllerTests.cs`

**Example Test**:
```csharp
public class CategoriesControllerTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public CategoriesControllerTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task GetCategories_Unauthenticated_ReturnsDefaultsOnly()
    {
        // Act
        var response = await _client.GetAsync("/api/categories");

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.OK);
        
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<GetCategoriesResponseDto>(content);
        
        result.Categories.Should().HaveCount(10);
        result.Categories.Should().OnlyContain(c => c.IsDefault);
    }

    [Fact]
    public async Task PostCategory_ValidData_Returns201()
    {
        // Arrange
        var token = await GetAuthTokenAsync("sarah@example.com", "Password123!");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var request = new CreateCategoryDto
        {
            Name = "Test Category",
            Icon = "🧪",
            Color = "#FF5733"
        };

        // Act
        var response = await _client.PostAsJsonAsync("/api/categories", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<CategoryDto>(content);
        
        result.Name.Should().Be("Test Category");
        result.Icon.Should().Be("🧪");
        result.Color.Should().Be("#FF5733");
        result.IsDefault.Should().BeFalse();
    }

    [Fact]
    public async Task PostCategory_DuplicateName_Returns400()
    {
        // Arrange
        var token = await GetAuthTokenAsync("sarah@example.com", "Password123!");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var request = new CreateCategoryDto
        {
            Name = "Test Category",
            Icon = "🧪",
            Color = "#FF5733"
        };

        // Create first category
        await _client.PostAsJsonAsync("/api/categories", request);

        // Act - try to create duplicate
        var response = await _client.PostAsJsonAsync("/api/categories", request);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}
```

**Run Tests**:
```bash
cd ae-infinity-api/tests/AeInfinity.IntegrationTests
dotnet test --filter "FullyQualifiedName~CategoriesControllerTests"
```

---

## Phase 2: Frontend Integration (2-3 days)

### Step 5: Connect categoriesService to Real API

**Goal**: Replace mock data with real API calls.

**Location**: `ae-infinity-ui/src/services/categoriesService.ts`

**Verify API Client**:
```typescript
import { api } from './api';
import type { Category, CreateCategoryRequest, GetCategoriesResponse } from '../types/category';

export const categoriesService = {
  /**
   * Get all categories (default + custom for authenticated users)
   */
  async getAllCategories(params?: { includeCustom?: boolean }): Promise<GetCategoriesResponse> {
    const queryString = params?.includeCustom === false ? '?includeCustom=false' : '';
    const response = await api.get<GetCategoriesResponse>(`/categories${queryString}`);
    return response.data;
  },

  /**
   * Create a custom category
   */
  async createCategory(data: CreateCategoryRequest): Promise<Category> {
    const response = await api.post<Category>('/categories', data);
    return response.data;
  },

  /**
   * Get only default categories (no authentication required)
   */
  async getDefaultCategories(): Promise<GetCategoriesResponse> {
    return this.getAllCategories({ includeCustom: false });
  },

  /**
   * Get all categories including custom (authentication required)
   */
  async getAllCategoriesWithCustom(): Promise<GetCategoriesResponse> {
    return this.getAllCategories({ includeCustom: true });
  }
};
```

**Update API Base URL** (if needed):
```typescript
// src/services/api.ts
import axios from 'axios';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'https://localhost:5001/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Add JWT token interceptor
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

---

### Step 6: Create Category Context (Optional but Recommended)

**Goal**: Centralize category state for entire application.

**Location**: `ae-infinity-ui/src/contexts/CategoryContext.tsx`

**Implementation**:
```typescript
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { categoriesService } from '../services/categoriesService';
import type { Category } from '../types/category';

interface CategoryContextType {
  categories: Category[];
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
  createCategory: (data: CreateCategoryRequest) => Promise<Category>;
}

const CategoryContext = createContext<CategoryContextType | null>(null);

export const CategoryProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCategories = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await categoriesService.getAllCategoriesWithCustom();
      setCategories(response.categories);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch categories');
      console.error('Failed to fetch categories', err);
    } finally {
      setLoading(false);
    }
  };

  const createCategory = async (data: CreateCategoryRequest): Promise<Category> => {
    const newCategory = await categoriesService.createCategory(data);
    setCategories((prev) => [...prev, newCategory]);
    return newCategory;
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  return (
    <CategoryContext.Provider value={{ categories, loading, error, refetch: fetchCategories, createCategory }}>
      {children}
    </CategoryContext.Provider>
  );
};

export const useCategories = (): CategoryContextType => {
  const context = useContext(CategoryContext);
  if (!context) {
    throw new Error('useCategories must be used within CategoryProvider');
  }
  return context;
};
```

**Wrap App with Provider** (`src/main.tsx` or `src/App.tsx`):
```typescript
import { CategoryProvider } from './contexts/CategoryContext';

<CategoryProvider>
  <App />
</CategoryProvider>
```

---

### Step 7: Integrate Category Picker in Item Forms

**Goal**: Use categories in CreateItem and EditItem forms.

**Location**: `ae-infinity-ui/src/components/ItemForm.tsx` (or similar)

**Example Implementation**:
```typescript
import React, { useState } from 'react';
import { useCategories } from '../contexts/CategoryContext';
import type { ListItem, CreateItemRequest } from '../types/item';

export const ItemForm: React.FC = () => {
  const { categories, loading } = useCategories();
  const [formData, setFormData] = useState<CreateItemRequest>({
    name: '',
    categoryId: undefined,
    quantity: 1,
    unit: ''
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // Submit form to API
    await itemsService.createItem(listId, formData);
  };

  return (
    <form onSubmit={handleSubmit}>
      <div>
        <label htmlFor="item-name">Item Name</label>
        <input
          id="item-name"
          type="text"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
          required
        />
      </div>

      <div>
        <label htmlFor="item-category">Category</label>
        <select
          id="item-category"
          value={formData.categoryId || ''}
          onChange={(e) => setFormData({ ...formData, categoryId: e.target.value || undefined })}
        >
          <option value="">Uncategorized</option>
          {loading ? (
            <option disabled>Loading categories...</option>
          ) : (
            categories.map((category) => (
              <option key={category.id} value={category.id}>
                {category.icon} {category.name}
              </option>
            ))
          )}
        </select>
      </div>

      <button type="submit">Add Item</button>
    </form>
  );
};
```

---

### Step 8: Display Category Badges on Items

**Goal**: Show category with icon and color on each item.

**Location**: `ae-infinity-ui/src/components/ItemCard.tsx` or `ItemRow.tsx`

**Example Implementation**:
```typescript
import React from 'react';
import type { ListItem } from '../types/item';

interface ItemCardProps {
  item: ListItem;
}

export const ItemCard: React.FC<ItemCardProps> = ({ item }) => {
  return (
    <div className="item-card">
      <h3>{item.name}</h3>
      
      {item.category && (
        <span
          className="category-badge"
          style={{
            backgroundColor: item.category.color + '20', // 20 = opacity
            color: item.category.color,
            padding: '4px 8px',
            borderRadius: '4px',
            fontSize: '0.875rem',
            fontWeight: 500
          }}
        >
          <span role="img" aria-label={item.category.name}>
            {item.category.icon}
          </span>
          {' '}
          {item.category.name}
        </span>
      )}

      <p>Quantity: {item.quantity} {item.unit}</p>
    </div>
  );
};
```

---

### Step 9: Add Category Filtering to List View

**Goal**: Filter items by selected category.

**Location**: `ae-infinity-ui/src/pages/ListDetail.tsx` or similar

**Example Implementation**:
```typescript
import React, { useState } from 'react';
import { useCategories } from '../contexts/CategoryContext';
import type { ListItem } from '../types/item';

export const ListDetail: React.FC = () => {
  const { categories } = useCategories();
  const [items, setItems] = useState<ListItem[]>([]);
  const [selectedCategoryId, setSelectedCategoryId] = useState<string | null>(null);

  // Client-side filtering
  const filteredItems = selectedCategoryId
    ? items.filter(item => item.category?.id === selectedCategoryId)
    : items;

  return (
    <div>
      <h1>Shopping List</h1>

      {/* Category Filter */}
      <div className="category-filter">
        <button
          onClick={() => setSelectedCategoryId(null)}
          className={selectedCategoryId === null ? 'active' : ''}
        >
          All Categories ({items.length})
        </button>
        {categories.map((category) => {
          const count = items.filter(item => item.category?.id === category.id).length;
          return (
            <button
              key={category.id}
              onClick={() => setSelectedCategoryId(category.id)}
              className={selectedCategoryId === category.id ? 'active' : ''}
            >
              {category.icon} {category.name} ({count})
            </button>
          );
        })}
      </div>

      {/* Item List */}
      <div className="items-list">
        {filteredItems.length === 0 ? (
          <p>No items in this category</p>
        ) : (
          filteredItems.map((item) => (
            <ItemCard key={item.id} item={item} />
          ))
        )}
      </div>
    </div>
  );
};
```

---

### Step 10: Add Custom Category Creation UI

**Goal**: Allow users to create custom categories from the app.

**Location**: `ae-infinity-ui/src/components/CreateCategoryModal.tsx`

**Example Implementation**:
```typescript
import React, { useState } from 'react';
import { useCategories } from '../contexts/CategoryContext';
import type { CreateCategoryRequest } from '../types/category';

interface CreateCategoryModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export const CreateCategoryModal: React.FC<CreateCategoryModalProps> = ({ isOpen, onClose }) => {
  const { createCategory } = useCategories();
  const [formData, setFormData] = useState<CreateCategoryRequest>({
    name: '',
    icon: '📦',
    color: '#607D8B'
  });
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);

    try {
      await createCategory(formData);
      onClose();
      setFormData({ name: '', icon: '📦', color: '#607D8B' });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create category');
    }
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <h2>Create Custom Category</h2>

        <form onSubmit={handleSubmit}>
          <div>
            <label htmlFor="category-name">Name</label>
            <input
              id="category-name"
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g., Pet Supplies"
              maxLength={50}
              required
            />
          </div>

          <div>
            <label htmlFor="category-icon">Icon (Emoji)</label>
            <input
              id="category-icon"
              type="text"
              value={formData.icon}
              onChange={(e) => setFormData({ ...formData, icon: e.target.value })}
              placeholder="🐾"
              maxLength={10}
              required
            />
          </div>

          <div>
            <label htmlFor="category-color">Color</label>
            <input
              id="category-color"
              type="color"
              value={formData.color}
              onChange={(e) => setFormData({ ...formData, color: e.target.value })}
              required
            />
          </div>

          {error && <p className="error">{error}</p>}

          <div className="modal-actions">
            <button type="button" onClick={onClose}>
              Cancel
            </button>
            <button type="submit">
              Create Category
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};
```

---

## Phase 3: End-to-End Testing (1-2 days)

### Step 11: Write Frontend Component Tests

**Goal**: Test category components with Vitest and React Testing Library.

**Location**: `ae-infinity-ui/tests/components/CategoryPicker.test.tsx`

**Example Test**:
```typescript
import { describe, it, expect, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { CategoryPicker } from '../../src/components/CategoryPicker';
import { CategoryProvider } from '../../src/contexts/CategoryContext';
import { categoriesService } from '../../src/services/categoriesService';

vi.mock('../../src/services/categoriesService');

describe('CategoryPicker', () => {
  it('loads and displays categories', async () => {
    // Arrange
    const mockCategories = [
      { id: '1', name: 'Produce', icon: '🥬', color: '#4CAF50', isDefault: true, createdBy: null },
      { id: '2', name: 'Dairy', icon: '🥛', color: '#2196F3', isDefault: true, createdBy: null }
    ];
    
    vi.mocked(categoriesService.getAllCategoriesWithCustom).mockResolvedValue({
      categories: mockCategories
    });

    // Act
    render(
      <CategoryProvider>
        <CategoryPicker value={null} onChange={() => {}} />
      </CategoryProvider>
    );

    // Assert
    await waitFor(() => {
      expect(screen.getByText(/🥬 Produce/)).toBeInTheDocument();
      expect(screen.getByText(/🥛 Dairy/)).toBeInTheDocument();
    });
  });

  it('calls onChange when category is selected', async () => {
    // Arrange
    const onChange = vi.fn();
    const mockCategories = [
      { id: '1', name: 'Produce', icon: '🥬', color: '#4CAF50', isDefault: true, createdBy: null }
    ];
    
    vi.mocked(categoriesService.getAllCategoriesWithCustom).mockResolvedValue({
      categories: mockCategories
    });

    // Act
    render(
      <CategoryProvider>
        <CategoryPicker value={null} onChange={onChange} />
      </CategoryProvider>
    );

    await waitFor(() => screen.getByText(/🥬 Produce/));
    
    await userEvent.click(screen.getByText(/🥬 Produce/));

    // Assert
    expect(onChange).toHaveBeenCalledWith('1');
  });
});
```

**Run Tests**:
```bash
cd ae-infinity-ui
npm test -- CategoryPicker
```

---

### Step 12: Manual End-to-End Testing

**Test Scenario 1: View Default Categories**
1. Open app without logging in
2. Navigate to item creation form
3. Verify category dropdown shows 10 default categories
4. Verify no "Create Category" button (unauthenticated)

**Test Scenario 2: Create Custom Category**
1. Log in as a user
2. Open "Create Category" modal
3. Enter: Name="Pet Supplies", Icon="🐾", Color="#8B4513"
4. Submit form
5. Verify new category appears in dropdown immediately
6. Verify category persists after page refresh

**Test Scenario 3: Category Uniqueness**
1. Try to create "Pet Supplies" again (same user)
2. Verify error: "A category with this name already exists"
3. Try "pet supplies" (lowercase) - same error
4. Try "PET SUPPLIES" (uppercase) - same error

**Test Scenario 4: Assign Category to Item**
1. Create a new item: "Dog Food"
2. Select category: "Pet Supplies"
3. Save item
4. Verify item displays with category badge (icon + name + color)

**Test Scenario 5: Filter Items by Category**
1. Create items in multiple categories
2. Click "Pet Supplies" filter button
3. Verify only pet-related items are displayed
4. Click "All Categories" - verify all items return

---

## Phase 4: Documentation & Deployment (1 day)

### Step 13: Update API Documentation

**Goal**: Ensure Swagger/OpenAPI docs are accurate.

**Location**: `ae-infinity-api/src/AeInfinity.Api/Controllers/CategoriesController.cs`

**Add XML Comments**:
```csharp
/// <summary>
/// Get all categories (default + custom for authenticated users)
/// </summary>
/// <param name="includeCustom">Include custom categories (default: true)</param>
/// <returns>List of categories</returns>
[HttpGet]
[AllowAnonymous]
[ProducesResponseType(typeof(GetCategoriesResponseDto), StatusCodes.Status200OK)]
public async Task<ActionResult<GetCategoriesResponseDto>> GetCategories(
    [FromQuery] bool includeCustom = true)
{
    var query = new GetCategoriesQuery { IncludeCustom = includeCustom };
    var result = await _mediator.Send(query);
    return Ok(result);
}

/// <summary>
/// Create a custom category
/// </summary>
/// <param name="request">Category details (name, icon, color)</param>
/// <returns>Created category</returns>
[HttpPost]
[Authorize]
[ProducesResponseType(typeof(CategoryDto), StatusCodes.Status201Created)]
[ProducesResponseType(StatusCodes.Status400BadRequest)]
[ProducesResponseType(StatusCodes.Status401Unauthorized)]
public async Task<ActionResult<CategoryDto>> CreateCategory(
    [FromBody] CreateCategoryDto request)
{
    var command = new CreateCategoryCommand(request);
    var result = await _mediator.Send(command);
    return CreatedAtAction(nameof(GetCategories), new { id = result.Id }, result);
}
```

**Test Swagger UI**:
1. Navigate to `https://localhost:5001/swagger`
2. Verify `GET /api/categories` and `POST /api/categories` endpoints
3. Test endpoints directly from Swagger UI

---

### Step 14: Deploy to Staging

**Backend Deployment**:
```bash
# Build and publish
cd ae-infinity-api
dotnet publish -c Release -o ./publish

# Deploy to staging (e.g., Azure, AWS, Docker)
docker build -t ae-infinity-api:latest .
docker run -p 5001:5001 ae-infinity-api:latest
```

**Frontend Deployment**:
```bash
# Build for production
cd ae-infinity-ui
npm run build

# Deploy to hosting (e.g., Vercel, Netlify, S3)
# Example: Vercel
vercel --prod
```

**Staging Smoke Tests**:
1. Verify default categories load on first app launch
2. Create a custom category
3. Assign category to an item
4. Filter items by category
5. Verify all operations complete in <1 second

---

## Troubleshooting

### Issue: Default Categories Not Seeding

**Symptoms**: GET /categories returns empty array.

**Solution**:
1. Check `Program.cs` - ensure `SeedDefaultCategoriesAsync` is called
2. Check database - verify `Categories` table exists
3. Check logs - look for seeding errors
4. Manually run seed command: `dotnet ef database update`

---

### Issue: Duplicate Category Names Allowed

**Symptoms**: Two categories with same name created.

**Solution**:
1. Verify unique index exists: `IX_Categories_User_Name`
2. Check validation in `CreateCategoryValidator.cs`
3. Ensure case-insensitive comparison: `EF.Functions.Like(c.Name.ToLower(), ...)`

---

### Issue: Emoji Not Displaying

**Symptoms**: Emoji shows as boxes or question marks.

**Solution**:
1. Verify database encoding: UTF-8 or Unicode
2. Check API response headers: `Content-Type: application/json; charset=utf-8`
3. Test emoji in browser console: `'🥬'.length` (should be 2, not 1)

---

### Issue: Category Filter Not Working

**Symptoms**: All items still visible after selecting category filter.

**Solution**:
1. Check filter logic: `items.filter(item => item.category?.id === categoryId)`
2. Verify `item.category` is populated (not null)
3. Check state updates: `setSelectedCategoryId(categoryId)`

---

## Next Steps

1. **Performance Testing**: Measure API response times under load
2. **Accessibility Audit**: Test with screen readers, keyboard navigation
3. **Analytics Integration**: Track category usage, most popular categories
4. **Future Enhancements**: Category reordering, category deletion with reassignment

---

**Quick Start Status**: ✅ Complete  
**Estimated Time**: 5-8 days (integration + testing + deployment)  
**Next Command**: `/speckit.tasks` to generate detailed task breakdown


