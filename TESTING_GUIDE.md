# Testing Guide

**Project**: AE Infinity  
**Approach**: Test-Driven Development (TDD)  
**Minimum Coverage**: 80%  
**Testing Philosophy**: Write tests first, implementation second

---

## 🎯 Testing Philosophy

### **Core Principles**

1. **TDD is Mandatory** - All code must be test-driven (per [Constitution](./.specify/memory/constitution.md))
2. **80% Minimum Coverage** - Backend and frontend must maintain 80%+ test coverage
3. **Test Behavior, Not Implementation** - Tests should verify what the code does, not how
4. **Fast Feedback** - Tests should run quickly (< 1 second for unit tests)
5. **Independent Tests** - Each test should be self-contained and not depend on others
6. **Readable Tests** - Tests serve as documentation; write them clearly

### **Test-Driven Development (TDD) Cycle**

```
1. RED   → Write a failing test
2. GREEN → Write minimum code to make it pass
3. REFACTOR → Clean up code while keeping tests green
```

**Example**:
```csharp
// 1. RED - Write failing test
[Fact]
public async Task Handle_ValidCommand_UpdatesDisplayName()
{
    // Arrange
    var command = new UpdateProfileCommand { DisplayName = "New Name" };
    
    // Act
    var result = await _handler.Handle(command);
    
    // Assert (will fail - handler doesn't exist yet)
    result.IsSuccess.Should().BeTrue();
    result.Value.DisplayName.Should().Be("New Name");
}

// 2. GREEN - Implement minimum code
public async Task<Result<UserDto>> Handle(UpdateProfileCommand request)
{
    var user = await _context.Users.FindAsync(request.UserId);
    user.DisplayName = request.DisplayName;
    await _context.SaveChangesAsync();
    return Result<UserDto>.Success(UserDto.FromEntity(user));
}

// 3. REFACTOR - Improve without breaking tests
// Add validation, error handling, etc.
```

---

## 🧪 Testing Levels

### **Testing Pyramid**

```
         /\
        /  \  E2E Tests (10%)
       /____\
      /      \  Integration Tests (30%)
     /________\
    /          \  Unit Tests (60%)
   /____________\
```

**Unit Tests (60%)**:
- Test individual functions/methods in isolation
- Mock external dependencies
- Fast execution (< 1 second)
- Highest number of tests

**Integration Tests (30%)**:
- Test multiple components together
- Use real database (in-memory or SQLite test DB)
- Verify API endpoints end-to-end
- Medium execution speed (< 5 seconds per test)

**E2E Tests (10%)**:
- Test complete user flows
- Use real browser (Playwright)
- Verify UI + API integration
- Slower execution (< 30 seconds per test)

---

## 🔧 Backend Testing (.NET 9.0)

### **Tech Stack**

- **Test Framework**: xUnit
- **Assertion Library**: FluentAssertions
- **Mocking**: Moq
- **In-Memory DB**: SQLite in-memory mode
- **Integration Testing**: WebApplicationFactory (ASP.NET Core)
- **Coverage**: Coverlet

### **Test Project Structure**

```
AeInfinity.Tests/
├── Unit/
│   ├── Application/
│   │   ├── Users/
│   │   │   ├── UpdateProfileCommandHandlerTests.cs
│   │   │   └── GetUserStatsQueryHandlerTests.cs
│   │   └── Auth/
│   │       ├── LoginCommandHandlerTests.cs
│   │       └── RegisterCommandHandlerTests.cs
│   ├── Domain/
│   │   └── Entities/
│   │       └── UserTests.cs
│   └── Infrastructure/
│       └── Caching/
│           └── MemoryCacheServiceTests.cs
├── Integration/
│   ├── Controllers/
│   │   ├── AuthControllerTests.cs
│   │   └── UsersControllerTests.cs
│   └── Helpers/
│       ├── TestWebApplicationFactory.cs
│       └── TestDataSeeder.cs
└── AeInfinity.Tests.csproj
```

---

### **Unit Tests (Backend)**

#### **Command Handler Test Example**

```csharp
using AeInfinity.Application.Users.Commands.UpdateProfile;
using AeInfinity.Domain.Entities;
using FluentAssertions;
using Moq;
using Xunit;

namespace AeInfinity.Tests.Unit.Application.Users
{
    public class UpdateProfileCommandHandlerTests
    {
        private readonly Mock<IApplicationDbContext> _mockContext;
        private readonly UpdateProfileCommandHandler _handler;

        public UpdateProfileCommandHandlerTests()
        {
            _mockContext = new Mock<IApplicationDbContext>();
            _handler = new UpdateProfileCommandHandler(_mockContext.Object);
        }

        [Fact]
        public async Task Handle_ValidCommand_UpdatesDisplayName()
        {
            // Arrange
            var user = new User
            {
                Id = Guid.NewGuid(),
                Email = "test@example.com",
                DisplayName = "Old Name"
            };
            
            _mockContext.Setup(c => c.Users.FindAsync(user.Id))
                .ReturnsAsync(user);

            var command = new UpdateProfileCommand
            {
                UserId = user.Id,
                DisplayName = "New Name",
                AvatarUrl = null
            };

            // Act
            var result = await _handler.Handle(command, CancellationToken.None);

            // Assert
            result.IsSuccess.Should().BeTrue();
            result.Value.DisplayName.Should().Be("New Name");
            user.DisplayName.Should().Be("New Name");
            
            _mockContext.Verify(c => c.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        }

        [Fact]
        public async Task Handle_InvalidDisplayName_ReturnsValidationError()
        {
            // Arrange
            var command = new UpdateProfileCommand
            {
                UserId = Guid.NewGuid(),
                DisplayName = "X", // Too short (min 2 chars)
                AvatarUrl = null
            };

            // Act
            var result = await _handler.Handle(command, CancellationToken.None);

            // Assert
            result.IsFailure.Should().BeTrue();
            result.Error.Should().Contain("Display name must be between 2 and 100 characters");
        }

        [Fact]
        public async Task Handle_UserNotFound_ReturnsNotFoundError()
        {
            // Arrange
            var nonExistentUserId = Guid.NewGuid();
            _mockContext.Setup(c => c.Users.FindAsync(nonExistentUserId))
                .ReturnsAsync((User)null);

            var command = new UpdateProfileCommand
            {
                UserId = nonExistentUserId,
                DisplayName = "Valid Name"
            };

            // Act
            var result = await _handler.Handle(command, CancellationToken.None);

            // Assert
            result.IsFailure.Should().BeTrue();
            result.Error.Should().Be("User not found");
        }
    }
}
```

---

### **Integration Tests (Backend)**

#### **API Endpoint Test Example**

```csharp
using System.Net;
using System.Net.Http.Json;
using AeInfinity.Application.Users.DTOs;
using FluentAssertions;
using Xunit;

namespace AeInfinity.Tests.Integration.Controllers
{
    public class UsersControllerTests : IClassFixture<TestWebApplicationFactory>
    {
        private readonly HttpClient _client;

        public UsersControllerTests(TestWebApplicationFactory factory)
        {
            _client = factory.CreateClient();
        }

        [Fact]
        public async Task GetCurrentUser_WhenAuthenticated_ReturnsUserDto()
        {
            // Arrange
            var token = await AuthenticateAsTestUser();
            _client.DefaultRequestHeaders.Authorization = 
                new AuthenticationHeaderValue("Bearer", token);

            // Act
            var response = await _client.GetAsync("/api/users/me");

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.OK);
            
            var user = await response.Content.ReadFromJsonAsync<UserDto>();
            user.Should().NotBeNull();
            user.Email.Should().Be("sarah@example.com");
            user.DisplayName.Should().Be("Sarah Johnson");
        }

        [Fact]
        public async Task GetCurrentUser_WhenNotAuthenticated_ReturnsUnauthorized()
        {
            // Act (no Authorization header)
            var response = await _client.GetAsync("/api/users/me");

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
        }

        [Fact]
        public async Task UpdateProfile_ValidData_UpdatesUserAndReturns200()
        {
            // Arrange
            var token = await AuthenticateAsTestUser();
            _client.DefaultRequestHeaders.Authorization = 
                new AuthenticationHeaderValue("Bearer", token);

            var updateRequest = new UpdateProfileDto
            {
                DisplayName = "Updated Name",
                AvatarUrl = "https://example.com/avatar.jpg"
            };

            // Act
            var response = await _client.PatchAsJsonAsync("/api/users/me", updateRequest);

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.OK);
            
            var updatedUser = await response.Content.ReadFromJsonAsync<UserDto>();
            updatedUser.DisplayName.Should().Be("Updated Name");
            updatedUser.AvatarUrl.Should().Be("https://example.com/avatar.jpg");
        }

        [Fact]
        public async Task UpdateProfile_InvalidDisplayName_Returns400WithValidationErrors()
        {
            // Arrange
            var token = await AuthenticateAsTestUser();
            _client.DefaultRequestHeaders.Authorization = 
                new AuthenticationHeaderValue("Bearer", token);

            var updateRequest = new UpdateProfileDto
            {
                DisplayName = "X", // Too short
                AvatarUrl = null
            };

            // Act
            var response = await _client.PatchAsJsonAsync("/api/users/me", updateRequest);

            // Assert
            response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
            
            var errorResponse = await response.Content.ReadAsStringAsync();
            errorResponse.Should().Contain("Display name must be between 2 and 100 characters");
        }

        private async Task<string> AuthenticateAsTestUser()
        {
            var loginRequest = new LoginRequest
            {
                Email = "sarah@example.com",
                Password = "Password123!"
            };

            var response = await _client.PostAsJsonAsync("/api/auth/login", loginRequest);
            var authResponse = await response.Content.ReadFromJsonAsync<LoginResponse>();
            
            return authResponse.Token;
        }
    }
}
```

---

### **Test Helpers**

#### **TestWebApplicationFactory**

```csharp
using AeInfinity.Infrastructure.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace AeInfinity.Tests.Integration.Helpers
{
    public class TestWebApplicationFactory : WebApplicationFactory<Program>
    {
        protected override void ConfigureWebHost(IWebHostBuilder builder)
        {
            builder.ConfigureServices(services =>
            {
                // Remove existing DbContext
                var descriptor = services.SingleOrDefault(
                    d => d.ServiceType == typeof(DbContextOptions<ApplicationDbContext>));
                if (descriptor != null) services.Remove(descriptor);

                // Add in-memory SQLite database for testing
                services.AddDbContext<ApplicationDbContext>(options =>
                {
                    options.UseSqlite("DataSource=:memory:");
                });

                // Build service provider and seed test data
                var sp = services.BuildServiceProvider();
                using var scope = sp.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                
                db.Database.OpenConnection(); // Keep in-memory DB alive
                db.Database.EnsureCreated();
                TestDataSeeder.SeedTestData(db);
            });
        }
    }
}
```

---

### **Running Backend Tests**

```bash
cd ae-infinity-api

# Run all tests
dotnet test

# Run with coverage
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover

# Run specific test class
dotnet test --filter "FullyQualifiedName~UpdateProfileCommandHandlerTests"

# Run tests in watch mode
dotnet watch test

# Generate coverage report (HTML)
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
reportgenerator -reports:coverage.cobertura.xml -targetdir:coverage-report
open coverage-report/index.html
```

---

## 🎨 Frontend Testing (React 19.1 + TypeScript)

### **Tech Stack**

- **Test Framework**: Vitest
- **Component Testing**: React Testing Library
- **Mocking**: MSW (Mock Service Worker) for API calls
- **Accessibility**: axe (via jest-axe)
- **Coverage**: V8 (built into Vitest)

### **Test Project Structure**

```
ae-infinity-ui/src/
├── components/
│   ├── common/
│   │   ├── LoadingSpinner.tsx
│   │   └── LoadingSpinner.test.tsx
│   └── layout/
│       ├── Header.tsx
│       └── Header.test.tsx
├── pages/
│   ├── profile/
│   │   ├── Profile.tsx
│   │   └── Profile.test.tsx
│   └── auth/
│       ├── Login.tsx
│       └── Login.test.tsx
├── hooks/
│   ├── useAuth.ts
│   └── useAuth.test.ts
├── utils/
│   ├── formatters.ts
│   └── formatters.test.ts
└── __mocks__/
    ├── handlers.ts (MSW handlers)
    └── server.ts (MSW server)
```

---

### **Component Tests**

#### **Simple Component Test**

```typescript
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { LoadingSpinner } from './LoadingSpinner';

describe('LoadingSpinner', () => {
  it('renders loading spinner', () => {
    render(<LoadingSpinner />);
    
    const spinner = screen.getByRole('status');
    expect(spinner).toBeInTheDocument();
    expect(spinner).toHaveAttribute('aria-label', 'Loading');
  });

  it('displays custom message when provided', () => {
    render(<LoadingSpinner message="Loading profile..." />);
    
    expect(screen.getByText('Loading profile...')).toBeInTheDocument();
  });
});
```

---

#### **Form Component Test**

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { ProfileSettings } from './ProfileSettings';

describe('ProfileSettings', () => {
  it('updates profile when form is submitted with valid data', async () => {
    const user = userEvent.setup();
    const mockOnUpdate = vi.fn();

    render(<ProfileSettings currentUser={mockUser} onUpdate={mockOnUpdate} />);

    // Update display name
    const displayNameInput = screen.getByLabelText(/display name/i);
    await user.clear(displayNameInput);
    await user.type(displayNameInput, 'New Name');

    // Submit form
    const submitButton = screen.getByRole('button', { name: /save/i });
    await user.click(submitButton);

    // Assert
    await waitFor(() => {
      expect(mockOnUpdate).toHaveBeenCalledWith({
        displayName: 'New Name',
        avatarUrl: null
      });
    });
  });

  it('shows validation error when display name is too short', async () => {
    const user = userEvent.setup();

    render(<ProfileSettings currentUser={mockUser} />);

    const displayNameInput = screen.getByLabelText(/display name/i);
    await user.clear(displayNameInput);
    await user.type(displayNameInput, 'X'); // Too short

    const submitButton = screen.getByRole('button', { name: /save/i });
    await user.click(submitButton);

    expect(await screen.findByText(/display name must be at least 2 characters/i))
      .toBeInTheDocument();
  });

  it('disables submit button while submitting', async () => {
    const user = userEvent.setup();
    const mockOnUpdate = vi.fn(() => new Promise(resolve => setTimeout(resolve, 1000)));

    render(<ProfileSettings currentUser={mockUser} onUpdate={mockOnUpdate} />);

    const submitButton = screen.getByRole('button', { name: /save/i });
    await user.click(submitButton);

    expect(submitButton).toBeDisabled();
    expect(screen.getByText(/saving/i)).toBeInTheDocument();
  });
});
```

---

#### **API Integration Test with MSW**

```typescript
// __mocks__/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('http://localhost:5233/api/users/me', () => {
    return HttpResponse.json({
      id: '123',
      email: 'test@example.com',
      displayName: 'Test User',
      avatarUrl: null,
      isEmailVerified: true,
      createdAt: '2025-11-01T00:00:00Z'
    });
  }),

  http.patch('http://localhost:5233/api/users/me', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({
      id: '123',
      email: 'test@example.com',
      displayName: body.displayName,
      avatarUrl: body.avatarUrl,
      isEmailVerified: true,
      createdAt: '2025-11-01T00:00:00Z'
    });
  })
];

// __mocks__/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

```typescript
// Profile.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, beforeAll, afterEach, afterAll } from 'vitest';
import { server } from '../../__mocks__/server';
import { Profile } from './Profile';

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('Profile Page', () => {
  it('loads and displays user profile', async () => {
    render(<Profile />);

    expect(screen.getByText(/loading/i)).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText('Test User')).toBeInTheDocument();
      expect(screen.getByText('test@example.com')).toBeInTheDocument();
    });
  });

  it('updates profile successfully', async () => {
    const user = userEvent.setup();

    render(<Profile />);

    // Wait for profile to load
    await screen.findByText('Test User');

    // Click edit button
    const editButton = screen.getByRole('button', { name: /edit profile/i });
    await user.click(editButton);

    // Update display name
    const displayNameInput = screen.getByLabelText(/display name/i);
    await user.clear(displayNameInput);
    await user.type(displayNameInput, 'Updated Name');

    // Save
    const saveButton = screen.getByRole('button', { name: /save/i });
    await user.click(saveButton);

    // Assert success
    await waitFor(() => {
      expect(screen.getByText('Profile updated successfully')).toBeInTheDocument();
      expect(screen.getByText('Updated Name')).toBeInTheDocument();
    });
  });
});
```

---

### **Hook Tests**

```typescript
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useAuth } from './useAuth';

describe('useAuth', () => {
  it('initializes with no user', () => {
    const { result } = renderHook(() => useAuth());
    
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });

  it('sets user on login', () => {
    const { result } = renderHook(() => useAuth());
    
    act(() => {
      result.current.login({
        id: '123',
        email: 'test@example.com',
        displayName: 'Test User'
      });
    });
    
    expect(result.current.user).toBeTruthy();
    expect(result.current.isAuthenticated).toBe(true);
  });

  it('clears user on logout', () => {
    const { result } = renderHook(() => useAuth());
    
    act(() => {
      result.current.login({ id: '123', email: 'test@example.com', displayName: 'Test' });
    });
    
    act(() => {
      result.current.logout();
    });
    
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });
});
```

---

### **Utility Function Tests**

```typescript
import { describe, it, expect } from 'vitest';
import { formatDate, formatRelativeTime, pluralize } from './formatters';

describe('formatters', () => {
  describe('formatDate', () => {
    it('formats ISO date to readable format', () => {
      const result = formatDate('2025-11-05T12:00:00Z');
      expect(result).toBe('November 5, 2025');
    });

    it('handles invalid date gracefully', () => {
      const result = formatDate('invalid');
      expect(result).toBe('Invalid Date');
    });
  });

  describe('formatRelativeTime', () => {
    it('returns "just now" for very recent dates', () => {
      const now = new Date().toISOString();
      const result = formatRelativeTime(now);
      expect(result).toBe('just now');
    });

    it('returns "X minutes ago" for recent dates', () => {
      const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000).toISOString();
      const result = formatRelativeTime(fiveMinutesAgo);
      expect(result).toBe('5 minutes ago');
    });
  });

  describe('pluralize', () => {
    it('returns singular for count of 1', () => {
      const result = pluralize(1, 'item', 'items');
      expect(result).toBe('1 item');
    });

    it('returns plural for count greater than 1', () => {
      const result = pluralize(5, 'item', 'items');
      expect(result).toBe('5 items');
    });

    it('returns plural for count of 0', () => {
      const result = pluralize(0, 'item', 'items');
      expect(result).toBe('0 items');
    });
  });
});
```

---

### **Running Frontend Tests**

```bash
cd ae-infinity-ui

# Run all tests
npm test

# Run in watch mode
npm test -- --watch

# Run with coverage
npm test -- --coverage

# Run specific test file
npm test -- Profile.test.tsx

# Run tests matching pattern
npm test -- --grep "authentication"

# Update snapshots
npm test -- --update

# Run tests in UI mode (interactive)
npm test -- --ui
```

---

## ✅ Test Coverage Requirements

### **Minimum Coverage: 80%**

| Layer | Target | Current (001) | Current (002) |
|-------|--------|---------------|---------------|
| Backend - Commands/Queries | 90%+ | TBD | TBD |
| Backend - Controllers | 80%+ | TBD | TBD |
| Backend - Validators | 100% | TBD | TBD |
| Backend - Domain Logic | 90%+ | TBD | TBD |
| Frontend - Components | 80%+ | TBD | TBD |
| Frontend - Hooks | 90%+ | TBD | TBD |
| Frontend - Utils | 100% | TBD | TBD |

### **Coverage Verification**

```bash
# Backend
cd ae-infinity-api
dotnet test /p:CollectCoverage=true /p:Threshold=80

# Frontend
cd ae-infinity-ui
npm test -- --coverage --coverage.threshold.lines=80
```

**CI/CD will fail if coverage drops below 80%**.

---

## 🚀 Best Practices

### **DO**

✅ Write tests BEFORE implementation (TDD)
✅ Test behavior, not implementation details
✅ Use descriptive test names: `MethodName_Scenario_ExpectedResult`
✅ Follow Arrange-Act-Assert pattern
✅ Mock external dependencies (database, API calls, file system)
✅ Test edge cases and error scenarios
✅ Keep tests independent (no shared state)
✅ Write fast tests (unit tests < 1s, integration tests < 5s)
✅ Use realistic test data
✅ Test accessibility (a11y) with jest-axe

### **DON'T**

❌ Skip tests to "move faster" (you'll move slower later)
❌ Test implementation details (private methods, internal state)
❌ Write tests that depend on execution order
❌ Use production database for tests
❌ Leave commented-out test code
❌ Ignore flaky tests (fix them immediately)
❌ Test third-party libraries (they have their own tests)
❌ Over-mock (use real objects when possible)

---

## 📊 Test Metrics

Track these metrics in CI/CD:

- **Test Count**: Total number of tests
- **Coverage**: % of code covered by tests (80% minimum)
- **Execution Time**: How long tests take to run
- **Flaky Tests**: Tests that fail intermittently (should be 0)
- **Test-to-Code Ratio**: Lines of test code / lines of production code (~1:1 ideal)

---

## 🔧 CI/CD Integration

### **GitHub Actions Workflow**

```yaml
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '9.0.x'
      - run: dotnet restore
      - run: dotnet test /p:CollectCoverage=true /p:Threshold=80
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test -- --coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## 📚 Additional Resources

- **Testing Library**: [https://testing-library.com/](https://testing-library.com/)
- **Vitest**: [https://vitest.dev/](https://vitest.dev/)
- **xUnit**: [https://xunit.net/](https://xunit.net/)
- **FluentAssertions**: [https://fluentassertions.com/](https://fluentassertions.com/)
- **MSW**: [https://mswjs.io/](https://mswjs.io/)
- **Kent C. Dodds - Testing Trophy**: [https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications](https://kentcdodds.com/blog/the-testing-trophy-and-testing-classifications)

---

**Remember**: Tests are not overhead. They are **insurance** that your code works correctly and **documentation** of expected behavior.

**Last Updated**: November 5, 2025

