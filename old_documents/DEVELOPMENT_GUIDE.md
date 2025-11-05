# Development Guide

## Getting Started

### Prerequisites

**Frontend Development**:
- Node.js 20+ and npm
- Git
- Code editor (VS Code recommended)

**Backend Development**:
- .NET 8 SDK
- SQL Server or PostgreSQL
- Redis (for caching)
- Docker (optional, for local services)

### Environment Setup

#### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd ae-infinity-ui
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env.local` file:
```env
VITE_API_URL=http://localhost:5000/api/v1
VITE_SIGNALR_HUB_URL=http://localhost:5000/hubs/shopping
VITE_ENABLE_MOCKS=false
```

4. Start development server:
```bash
npm run dev
```

The app will be available at `http://localhost:3000`

#### Backend Setup

1. Navigate to backend directory:
```bash
cd AeInfinity.Api
```

2. Create `appsettings.Development.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=AeInfinity;Trusted_Connection=True;",
    "Redis": "localhost:6379"
  },
  "Jwt": {
    "Secret": "your-super-secret-key-min-32-chars",
    "Issuer": "ae-infinity",
    "Audience": "ae-infinity-users",
    "ExpirationMinutes": 60
  }
}
```

3. Run database migrations:
```bash
dotnet ef database update
```

4. Start the API:
```bash
dotnet run
```

The API will be available at `http://localhost:5000`

---

## Project Structure

### Frontend Structure
```
ae-infinity-ui/
├── src/
│   ├── components/     # Reusable components
│   ├── pages/         # Page components
│   ├── hooks/         # Custom React hooks
│   ├── services/      # API clients, SignalR
│   ├── context/       # React Context providers
│   ├── types/         # TypeScript definitions
│   ├── utils/         # Helper functions
│   ├── styles/        # Global styles
│   └── __tests__/     # Test files
├── public/            # Static assets
└── vite.config.ts     # Vite configuration
```

### Backend Structure
```
AeInfinity/
├── AeInfinity.Api/         # Web API project
├── AeInfinity.Core/        # Domain models, interfaces
├── AeInfinity.Application/ # Business logic, services
└── AeInfinity.Infrastructure/ # Data access, external services
```

---

## Development Workflow

### Branching Strategy

- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Production hotfixes

### Feature Development Process

1. **Create feature branch**:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/add-item-images
```

2. **Review specifications**:
   - Check `PROJECT_SPEC.md` for requirements
   - Review `API_SPEC.md` for endpoints
   - Check `COMPONENT_SPEC.md` for UI components

3. **Write tests first** (TDD approach):
   - Unit tests for business logic
   - Integration tests for API endpoints
   - Component tests for React components

4. **Implement feature**:
   - Follow coding standards
   - Write self-documenting code
   - Add comments for complex logic

5. **Run tests**:
```bash
# Frontend
npm test

# Backend
dotnet test
```

6. **Commit changes**:
```bash
git add .
git commit -m "feat: add image upload support for shopping items"
```

7. **Create pull request**:
   - Push branch to remote
   - Open PR against `develop`
   - Request review
   - Address feedback

8. **Merge after approval**

---

## Coding Standards

### TypeScript/React Standards

1. **File Naming**:
   - Components: PascalCase (`ShoppingListCard.tsx`)
   - Hooks: camelCase with `use` prefix (`useAuth.ts`)
   - Utils: camelCase (`formatters.ts`)
   - Types: PascalCase (`models.ts`)

2. **Component Structure**:
```tsx
// Imports
import React from 'react';
import { Button } from './Button';

// Types/Interfaces
interface MyComponentProps {
  title: string;
  onClick: () => void;
}

// Component
export const MyComponent: React.FC<MyComponentProps> = ({ title, onClick }) => {
  // Hooks
  const [state, setState] = useState();
  
  // Effects
  useEffect(() => {
    // ...
  }, []);
  
  // Event handlers
  const handleClick = () => {
    onClick();
  };
  
  // Render helpers (if needed)
  const renderContent = () => {
    // ...
  };
  
  // JSX
  return (
    <div>
      <h1>{title}</h1>
      <Button onClick={handleClick}>Click me</Button>
    </div>
  );
};
```

3. **TypeScript Best Practices**:
   - Avoid `any`, use proper types
   - Use interfaces for object shapes
   - Use type unions for string literals
   - Export types from dedicated files

4. **React Best Practices**:
   - Use functional components with hooks
   - Memoize expensive computations with `useMemo`
   - Memoize callbacks with `useCallback`
   - Use `React.memo` for pure components
   - Extract custom hooks for reusable logic

### C# Standards

1. **File Naming**:
   - PascalCase for all files
   - Match class name: `ListService.cs`

2. **Class Structure**:
```csharp
using System;
using AeInfinity.Core.Interfaces;

namespace AeInfinity.Application.Services
{
    /// <summary>
    /// Service for managing shopping lists
    /// </summary>
    public class ListService : IListService
    {
        // Private fields
        private readonly IListRepository _listRepository;
        private readonly ILogger<ListService> _logger;
        
        // Constructor
        public ListService(
            IListRepository listRepository,
            ILogger<ListService> logger)
        {
            _listRepository = listRepository;
            _logger = logger;
        }
        
        // Public methods
        public async Task<List> CreateListAsync(CreateListRequest request)
        {
            // Implementation
        }
        
        // Private helper methods
        private void ValidateRequest(CreateListRequest request)
        {
            // Validation logic
        }
    }
}
```

3. **C# Best Practices**:
   - Use dependency injection
   - Async/await for I/O operations
   - Proper exception handling
   - XML documentation comments
   - Follow SOLID principles

---

## Testing Guidelines

### Frontend Testing

**Unit Tests** (Vitest):
```typescript
import { describe, it, expect } from 'vitest';
import { formatQuantity } from './formatters';

describe('formatQuantity', () => {
  it('should format quantity with unit', () => {
    expect(formatQuantity(2, 'kg')).toBe('2 kg');
  });
  
  it('should handle missing unit', () => {
    expect(formatQuantity(5, null)).toBe('5');
  });
});
```

**Component Tests** (React Testing Library):
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('should render children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
  
  it('should call onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('should be disabled when loading', () => {
    render(<Button loading>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

**Integration Tests**:
```typescript
import { renderHook, waitFor } from '@testing-library/react';
import { useLists } from './useLists';
import { mockApi } from '../__mocks__/api';

describe('useLists', () => {
  it('should fetch lists on mount', async () => {
    mockApi.getLists.mockResolvedValue({ lists: [/* ... */] });
    
    const { result } = renderHook(() => useLists());
    
    await waitFor(() => {
      expect(result.current.isLoading).toBe(false);
    });
    
    expect(result.current.lists).toHaveLength(2);
  });
});
```

### Backend Testing

**Unit Tests** (xUnit):
```csharp
public class ListServiceTests
{
    private readonly Mock<IListRepository> _mockRepository;
    private readonly ListService _service;
    
    public ListServiceTests()
    {
        _mockRepository = new Mock<IListRepository>();
        _service = new ListService(_mockRepository.Object);
    }
    
    [Fact]
    public async Task CreateListAsync_ValidRequest_ReturnsCreatedList()
    {
        // Arrange
        var request = new CreateListRequest { Name = "Test List" };
        var expectedList = new List { Id = Guid.NewGuid(), Name = "Test List" };
        _mockRepository
            .Setup(r => r.CreateAsync(It.IsAny<List>()))
            .ReturnsAsync(expectedList);
        
        // Act
        var result = await _service.CreateListAsync(request);
        
        // Assert
        Assert.NotNull(result);
        Assert.Equal("Test List", result.Name);
    }
    
    [Fact]
    public async Task CreateListAsync_EmptyName_ThrowsValidationException()
    {
        // Arrange
        var request = new CreateListRequest { Name = "" };
        
        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(
            () => _service.CreateListAsync(request)
        );
    }
}
```

**Integration Tests**:
```csharp
public class ListsControllerIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;
    
    public ListsControllerIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }
    
    [Fact]
    public async Task GetLists_Authenticated_ReturnsLists()
    {
        // Arrange
        var token = await GetAuthTokenAsync();
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
        
        // Act
        var response = await _client.GetAsync("/api/v1/lists");
        
        // Assert
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        var result = JsonSerializer.Deserialize<ListsResponse>(content);
        Assert.NotNull(result.Lists);
    }
}
```

---

## Debugging

### Frontend Debugging

**VS Code Launch Configuration** (`.vscode/launch.json`):
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome against localhost",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}/ae-infinity-ui/src"
    }
  ]
}
```

**Browser DevTools**:
- React DevTools extension
- Redux DevTools (if using Redux)
- Network tab for API calls
- Console for errors

**Debugging Tips**:
- Use `debugger;` statements
- Console.log with descriptive messages
- React DevTools for component inspection
- Network tab for failed requests

### Backend Debugging

**VS Code Launch Configuration**:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": ".NET Core Launch (web)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      "program": "${workspaceFolder}/AeInfinity.Api/bin/Debug/net8.0/AeInfinity.Api.dll",
      "args": [],
      "cwd": "${workspaceFolder}/AeInfinity.Api",
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  ]
}
```

**Debugging Tips**:
- Set breakpoints in VS Code or Visual Studio
- Use conditional breakpoints
- Watch window for variable inspection
- Immediate window for expression evaluation
- Logging with Serilog

---

## Common Tasks

### Adding a New API Endpoint

1. Define DTOs in `Application/DTOs`
2. Add interface method in `Core/Interfaces`
3. Implement in service in `Application/Services`
4. Add controller action in `Api/Controllers`
5. Update API_SPEC.md
6. Write tests
7. Create frontend API client method

### Adding a New React Component

1. Check COMPONENT_SPEC.md for design
2. Create component file in appropriate directory
3. Define TypeScript interfaces
4. Implement component with accessibility
5. Write component tests
6. Export from index file
7. Document usage

### Adding Real-time Feature

**Backend**:
1. Add hub method in `ShoppingListHub.cs`
2. Implement business logic
3. Broadcast to clients

**Frontend**:
1. Add event listener in `useRealtime` hook
2. Update local state on event
3. Test real-time synchronization

### Database Migration

**Create migration**:
```bash
dotnet ef migrations add AddItemImages --project AeInfinity.Infrastructure
```

**Apply migration**:
```bash
dotnet ef database update --project AeInfinity.Api
```

**Rollback migration**:
```bash
dotnet ef database update PreviousMigrationName --project AeInfinity.Api
```

---

## Performance Optimization

### Frontend Performance

1. **Code Splitting**:
```typescript
const ListDetailPage = lazy(() => import('./pages/ListDetail'));
```

2. **Memoization**:
```typescript
const expensiveValue = useMemo(() => {
  return computeExpensiveValue(data);
}, [data]);
```

3. **Debouncing**:
```typescript
const debouncedSearch = useDebouncedCallback(
  (query: string) => {
    searchLists(query);
  },
  300
);
```

4. **Virtual Scrolling**:
```typescript
import { FixedSizeList } from 'react-window';
```

### Backend Performance

1. **Caching**:
```csharp
var lists = await _cache.GetOrSetAsync(
    $"user:{userId}:lists",
    async () => await _repository.GetListsAsync(userId),
    TimeSpan.FromMinutes(5)
);
```

2. **Database Indexing**:
```csharp
modelBuilder.Entity<ShoppingItem>()
    .HasIndex(i => new { i.ListId, i.Position });
```

3. **Async Operations**:
```csharp
var lists = await _repository.GetListsAsync(userId);
var items = await _repository.GetItemsAsync(listId);
```

4. **Batch Operations**:
```csharp
await _repository.BulkUpdateAsync(items);
```

---

## Security Best Practices

### Frontend Security

1. **XSS Prevention**:
   - React escapes by default
   - Avoid `dangerouslySetInnerHTML`
   - Sanitize user input

2. **Authentication**:
   - Store JWT in httpOnly cookie
   - Include in Authorization header
   - Refresh before expiration

3. **HTTPS Only**:
   - Force HTTPS in production
   - Secure cookies

### Backend Security

1. **Input Validation**:
```csharp
public class CreateListValidator : AbstractValidator<CreateListRequest>
{
    public CreateListValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(100);
    }
}
```

2. **SQL Injection Prevention**:
   - Use parameterized queries
   - Entity Framework handles this

3. **Authorization**:
```csharp
[Authorize]
[HttpGet("{listId}")]
public async Task<IActionResult> GetList(Guid listId)
{
    await _authService.EnsureUserHasAccessAsync(listId, User.GetUserId());
    // ...
}
```

---

## Deployment

### Frontend Deployment

1. **Build for production**:
```bash
npm run build
```

2. **Deploy to hosting** (Netlify, Vercel, etc.):
```bash
netlify deploy --prod --dir=build
```

### Backend Deployment

1. **Publish**:
```bash
dotnet publish -c Release -o ./publish
```

2. **Docker**:
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0
COPY ./publish /app
WORKDIR /app
ENTRYPOINT ["dotnet", "AeInfinity.Api.dll"]
```

3. **Deploy to cloud** (Azure, AWS, etc.)

---

## Troubleshooting

### Common Issues

**Frontend won't start**:
- Delete `node_modules` and `package-lock.json`
- Run `npm install` again
- Check Node version

**API connection fails**:
- Check API is running
- Verify CORS configuration
- Check environment variables

**SignalR not connecting**:
- Check hub URL
- Verify authentication token
- Check firewall/proxy settings

**Database migration fails**:
- Check connection string
- Ensure database server is running
- Check migration syntax

---

## Resources

### Documentation
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Vite Guide](https://vitejs.dev/guide/)
- [.NET Documentation](https://docs.microsoft.com/dotnet/)
- [Entity Framework Core](https://docs.microsoft.com/ef/core/)
- [SignalR Documentation](https://docs.microsoft.com/aspnet/core/signalr/)

### Tools
- [Postman](https://www.postman.com/) - API testing
- [Redux DevTools](https://github.com/reduxjs/redux-devtools) - State debugging
- [React DevTools](https://react.dev/learn/react-developer-tools) - Component debugging

### Community
- GitHub Issues
- Team Slack channel
- Weekly standup meetings

