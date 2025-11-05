# Quick Start: User Authentication

**For**: Developers implementing or integrating with the authentication feature  
**Time**: 15 minutes to get up and running

---

## 🚀 Getting Started

### Prerequisites

- Backend API running at `http://localhost:5233`
- Frontend dev server (optional, for integration testing)
- Database initialized with migrations
- .NET 8 SDK and Node.js 20+ installed

---

## 🔑 Test the Existing API

### 1. Login (Already Implemented ✅)

**Endpoint**: `POST http://localhost:5233/api/Auth/login`

```bash
curl -X POST http://localhost:5233/api/Auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "sarah@example.com",
    "password": "Password123!"
  }'
```

**Expected Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "expiresAt": "2025-11-06T10:30:00Z",
  "user": {
    "id": "...",
    "email": "sarah@example.com",
    "displayName": "Sarah Johnson",
    "avatarUrl": null,
    "isEmailVerified": true,
    "lastLoginAt": "2025-11-05T10:30:00Z",
    "createdAt": "2025-01-01T10:00:00Z"
  }
}
```

### 2. Get Current User (Already Implemented ✅)

**Endpoint**: `GET http://localhost:5233/api/Users/me`

```bash
# Replace TOKEN with the JWT from login response
curl -X GET http://localhost:5233/api/Users/me \
  -H "Authorization: Bearer TOKEN"
```

### 3. Logout (Already Implemented ✅)

**Endpoint**: `POST http://localhost:5233/api/Auth/logout`

```bash
curl -X POST http://localhost:5233/api/Auth/logout \
  -H "Authorization: Bearer TOKEN"
```

---

## 🧪 Test User Accounts

The backend has these seeded test accounts:

| Email | Password | Display Name | Role |
|-------|----------|--------------|------|
| sarah@example.com | Password123! | Sarah Johnson | List Creator (Owner) |
| alex@example.com | Password123! | Alex Chen | Active Collaborator |
| mike@example.com | Password123! | Mike Wilson | Active Collaborator |

---

## 🛠️ Development Workflow

### For Backend Developers

#### Implementing Missing Features

1. **Create a new feature handler** (example: Registration):
   ```bash
   cd ae-infinity-api/src/AeInfinity.Application/Features/Auth
   mkdir Register
   cd Register
   # Create RegisterCommand.cs, RegisterHandler.cs, RegisterValidator.cs
   ```

2. **Follow CQRS pattern**:
   ```csharp
   // RegisterCommand.cs
   public record RegisterCommand(string Email, string DisplayName, string Password) 
       : IRequest<LoginResponse>;
   
   // RegisterHandler.cs
   public class RegisterHandler : IRequestHandler<RegisterCommand, LoginResponse>
   {
       // Implementation
   }
   ```

3. **Add controller endpoint**:
   ```csharp
   // AuthController.cs
   [HttpPost("register")]
   public async Task<ActionResult<LoginResponse>> Register(RegisterRequest request)
   {
       var command = new RegisterCommand(request.Email, request.DisplayName, request.Password);
       var response = await _mediator.Send(command);
       return Ok(response);
   }
   ```

4. **Write tests first** (TDD):
   ```bash
   cd tests/AeInfinity.Application.Tests/Auth
   # Create RegisterHandlerTests.cs
   ```

#### Running Backend Tests

```bash
cd ae-infinity-api
dotnet test
```

#### Viewing Swagger Documentation

```bash
# Start API
cd src/AeInfinity.Api
dotnet run

# Open browser
open http://localhost:5233/index.html
```

---

### For Frontend Developers

#### Using AuthService

```typescript
import { authService } from '@/services/authService';

// Login
try {
  const response = await authService.login(email, password);
  console.log('Token:', response.token);
  console.log('User:', response.user);
} catch (error) {
  console.error('Login failed:', error.message);
}

// Get current user
try {
  const user = await authService.getCurrentUser();
  console.log('Current user:', user);
} catch (error) {
  if (error.status === 401) {
    // Token expired, redirect to login
  }
}

// Logout
await authService.logout();
```

#### Using AuthContext (After Integration)

```typescript
import { useAuth } from '@/contexts/AuthContext';

function MyComponent() {
  const { user, isAuthenticated, login, logout } = useAuth();

  const handleLogin = async () => {
    await login(email, password);
    // Automatically updates user state
  };

  if (!isAuthenticated) {
    return <Navigate to="/login" />;
  }

  return <div>Welcome, {user.displayName}!</div>;
}
```

#### Running Frontend Tests

```bash
cd ae-infinity-ui
npm test
```

#### Running Frontend Dev Server

```bash
cd ae-infinity-ui
npm run dev
# Opens at http://localhost:5173
```

---

## 🔍 Debugging Tips

### Backend

**View JWT Token Claims**:
```bash
# Use jwt.io or decode in C#:
var handler = new JwtSecurityTokenHandler();
var token = handler.ReadJwtToken(tokenString);
var claims = token.Claims;
```

**Check Database**:
```sql
-- View users
SELECT * FROM users WHERE email = 'sarah@example.com';

-- Check password hash
SELECT password_hash FROM users WHERE email = 'sarah@example.com';
```

**Enable Detailed Logging**:
```json
// appsettings.Development.json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft.AspNetCore": "Information"
    }
  }
}
```

### Frontend

**View Stored Token**:
```javascript
// In browser console
localStorage.getItem('auth_token')
```

**Test API Calls**:
```javascript
// In browser console
fetch('http://localhost:5233/api/Users/me', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('auth_token')}`
  }
}).then(r => r.json()).then(console.log)
```

**React DevTools**:
- Install React DevTools browser extension
- Inspect AuthContext state in Components tab

---

## 📚 Common Tasks

### Add New Validation Rule

**Backend**:
```csharp
// Update DTO
public class LoginRequest
{
    [Required]
    [EmailAddress]
    [MaxLength(255)] // Add new rule
    public string Email { get; set; }
}
```

**Contract**:
```json
// Update login-request.json
{
  "properties": {
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 255
    }
  }
}
```

### Change Token Expiration

**Backend**:
```csharp
// Program.cs or JwtSettings
options.TokenValidationParameters = new TokenValidationParameters
{
    ClockSkew = TimeSpan.Zero,
    ValidateLifetime = true
};

// In token generation
var tokenExpiry = DateTime.UtcNow.AddHours(48); // Change from 24 to 48
```

### Add New Auth Endpoint

1. Create command/handler in `Application/Features/Auth/`
2. Add endpoint to `AuthController.cs`
3. Write unit tests
4. Write integration tests
5. Update Swagger documentation (automatic)
6. Add method to frontend `authService.ts`
7. Update AuthContext if needed

---

## 🐛 Troubleshooting

### "401 Unauthorized" Errors

**Check**:
1. Token is being sent: `Authorization: Bearer TOKEN`
2. Token hasn't expired (check `expiresAt` from login response)
3. Token is valid (test with jwt.io)
4. Backend JWT settings match (issuer, audience, secret)

**Fix**:
- Re-login to get fresh token
- Check environment variables match
- Verify secret key in both frontend and backend

### "400 Bad Request" on Login

**Check**:
1. Email format is valid
2. Password is not empty
3. Request Content-Type is `application/json`

**Fix**:
- Check DTO validation rules
- View backend logs for validation errors
- Test with curl to isolate frontend issues

### Frontend Not Connecting to Backend

**Check**:
1. Backend is running: `curl http://localhost:5233/api/Users/me`
2. CORS is configured: Check `Program.cs` AllowedOrigins
3. Environment variable: `VITE_API_BASE_URL=http://localhost:5233/api`

**Fix**:
```csharp
// Backend Program.cs
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:5173")
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});
```

---

## 📖 Next Steps

1. **Read** [spec.md](./spec.md) for complete requirements
2. **Review** [plan.md](./plan.md) for implementation strategy
3. **Check** [contracts/](./contracts/) for API schemas
4. **Run** `/speckit.tasks` to get detailed task checklist
5. **Start** implementing missing features (registration, password reset)

---

## 🔗 Useful Links

- **Swagger UI**: http://localhost:5233/index.html
- **Frontend Dev**: http://localhost:5173
- **API Base**: http://localhost:5233/api
- **Constitution**: [/.specify/memory/constitution.md](../../.specify/memory/constitution.md)
- **Old Docs**: [/old_documents/features/authentication/](../../old_documents/features/authentication/)

---

**Questions?** Check the [plan.md](./plan.md) for detailed implementation guidance or refer to the constitution for development standards.

