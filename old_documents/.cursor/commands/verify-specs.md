---
description: "Verify implementation matches specifications"
tags: ["verification", "validation", "specs", "quality"]
---

# Verify Against Specifications

Check if your implementation matches the project specifications and follows established patterns.

## What This Command Does

Provides a systematic approach to verify that code changes:
- Follow API contracts defined in specs
- Match architecture patterns
- Implement user requirements correctly
- Follow coding standards

## Verification Checklist

### 1. API Contract Verification

**For Backend Changes:**

Check against `API_SPEC.md`:
- [ ] Endpoint path matches spec
- [ ] HTTP method is correct (GET, POST, PUT, DELETE)
- [ ] Request body matches spec
- [ ] Response format matches spec
- [ ] Status codes match spec
- [ ] Error responses follow pattern
- [ ] Authentication requirements met

**Example Verification:**
```bash
# Your implementation
POST /api/lists
Request: { "name": "Groceries", "description": "Weekly shopping" }
Response: { "id": "guid", "name": "Groceries", ... }

# Check spec
cat ae-infinity-context/API_SPEC.md | grep -A 20 "POST /api/lists"

# Verify JSON schema
cat ae-infinity-context/schemas/list.json
```

### 2. Architecture Pattern Verification

**For Backend (Clean Architecture):**

- [ ] Entities in Domain layer (no dependencies)
- [ ] Use cases in Application layer
- [ ] Data access in Infrastructure layer
- [ ] Controllers in API layer
- [ ] Dependencies flow inward only
- [ ] CQRS: Commands vs Queries separated
- [ ] MediatR used for handler pattern
- [ ] Validation with FluentValidation
- [ ] Mapping with AutoMapper
- [ ] Repository pattern followed

**Verify with:**
```bash
# Check layer dependencies
cd work/ae-infinity-api
dotnet list src/AeInfinity.Domain/AeInfinity.Domain.csproj reference
# Should show: No references (Domain has no dependencies)

dotnet list src/AeInfinity.Application/AeInfinity.Application.csproj reference
# Should show: Domain only

# Check for CQRS pattern
find src/AeInfinity.Application/Features -name "*Command.cs" -o -name "*Query.cs"
```

**For Frontend (React Patterns):**

- [ ] Components follow single responsibility
- [ ] Custom hooks for reusable logic
- [ ] Services for API calls
- [ ] Context for global state
- [ ] TypeScript types match schemas
- [ ] Error boundaries implemented
- [ ] Loading states handled
- [ ] Optimistic updates where appropriate

**Verify with:**
```bash
cd work/ae-infinity-ui

# Check component structure
find src/components -name "*.tsx"

# Check hooks follow naming
find src/hooks -name "use*.ts"

# Check TypeScript compilation
npm run build
```

### 3. User Requirements Verification

**Check against Personas:**
```bash
cat ae-infinity-context/personas/list-creator.md
```

- [ ] Feature serves identified user need
- [ ] Permission levels respected
- [ ] User goals achievable
- [ ] Pain points addressed

**Check against Journeys:**
```bash
cat ae-infinity-context/journeys/[relevant-journey].md
```

- [ ] Workflow steps implemented
- [ ] User can complete journey
- [ ] Edge cases handled
- [ ] Error states friendly

### 4. Code Quality Verification

**Backend:**
```bash
cd work/ae-infinity-api

# Build without warnings
dotnet build --no-incremental

# Check for code issues
# (If you have analyzers configured)
dotnet build /p:TreatWarningsAsErrors=true

# Run tests
dotnet test
```

**Frontend:**
```bash
cd work/ae-infinity-ui

# TypeScript compilation
npm run build

# Linting
npm run lint

# Type checking
npx tsc --noEmit
```

### 5. Data Schema Verification

**For API Responses:**

Compare your DTOs against JSON schemas:

```bash
# View schema
cat ae-infinity-context/schemas/list.json

# Verify your DTO matches
cat work/ae-infinity-api/src/AeInfinity.Application/Common/Models/DTOs/ListDto.cs
```

**Check:**
- [ ] All required fields present
- [ ] Data types match
- [ ] Field names match (camelCase)
- [ ] Nullable fields correctly marked
- [ ] Enums match allowed values

### 6. Authentication & Authorization

**Verify:**
- [ ] Protected endpoints require JWT
- [ ] Token validation implemented
- [ ] Permission levels checked
- [ ] Unauthorized returns 401
- [ ] Forbidden returns 403
- [ ] Token expiration handled

**Test:**
```bash
# Test without token (should fail)
curl http://localhost:5233/api/lists

# Test with token (should succeed)
curl -H "Authorization: Bearer $TOKEN" http://localhost:5233/api/lists
```

### 7. Error Handling

**Verify:**
- [ ] Validation errors return 400
- [ ] Not found returns 404
- [ ] Server errors return 500
- [ ] Error messages are helpful
- [ ] Error format matches spec

**Check error response format:**
```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    {
      "property": "Name",
      "message": "Name is required"
    }
  ]
}
```

## Automated Verification

### Create a Verification Script

```bash
#!/bin/bash
# verify-implementation.sh

echo "🔍 Verifying implementation against specs..."

# 1. Build backend
cd work/ae-infinity-api
echo "Building API..."
dotnet build --no-incremental || exit 1

# 2. Build frontend
cd ../ae-infinity-ui
echo "Building UI..."
npm run build || exit 1

# 3. Run linters
echo "Linting UI..."
npm run lint || exit 1

# 4. Type check
echo "Type checking..."
npx tsc --noEmit || exit 1

echo "✅ All verifications passed!"
```

### API Contract Testing

Create integration tests that verify against specs:

```csharp
// Example test
[Fact]
public async Task CreateList_ShouldMatchApiSpec()
{
    // Arrange
    var request = new CreateListCommand 
    { 
        Name = "Test List",
        Description = "Test Description"
    };
    
    // Act
    var result = await _mediator.Send(request);
    
    // Assert - Verify matches API_SPEC.md
    result.Should().NotBeNull();
    result.Id.Should().NotBeEmpty();
    result.Name.Should().Be(request.Name);
    result.Description.Should().Be(request.Description);
    result.CreatedAt.Should().BeCloseTo(DateTime.UtcNow, TimeSpan.FromSeconds(5));
    // ... verify all fields from spec
}
```

## Manual Testing Checklist

### Backend API Testing

```bash
# Start API
cd work/ae-infinity-api/src/AeInfinity.Api
dotnet run

# In another terminal, test endpoints
# 1. Login
curl -X POST http://localhost:5233/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah@example.com","password":"Password123!"}'

# 2. Use returned token
export TOKEN="<token-from-login>"

# 3. Test protected endpoint
curl http://localhost:5233/api/lists \
  -H "Authorization: Bearer $TOKEN"

# 4. Verify response matches schema
```

### Frontend UI Testing

```bash
# Start UI
cd work/ae-infinity-ui
npm run dev

# Manual tests:
# 1. Open http://localhost:5173
# 2. Test login flow
# 3. Test creating a list
# 4. Test viewing list details
# 5. Test editing items
# 6. Test search
# 7. Test user profile
# 8. Verify all persona workflows work
```

## Comparison Tools

### Diff Against Reference Implementation

If you have a reference implementation:

```bash
# Compare your changes
cd work/ae-infinity-api
git diff origin/main src/AeInfinity.Api/Controllers/ListsController.cs

# Or compare full feature
git diff origin/main src/AeInfinity.Application/Features/Lists/
```

### Schema Validation

For JSON schema validation:

```bash
# Install ajv-cli if not already
npm install -g ajv-cli

# Validate a response against schema
ajv validate -s ae-infinity-context/schemas/list.json -d response.json
```

## Common Issues & Fixes

### Issue: Endpoint doesn't match spec

**Problem:**
```csharp
[HttpPost("create")]  // Wrong!
public async Task<ActionResult<ListDto>> CreateList(...)
```

**Fix:**
```csharp
[HttpPost]  // Correct per spec
public async Task<ActionResult<ListDto>> CreateList(...)
```

### Issue: Response format wrong

**Problem:**
```json
{
  "ListId": "123",  // PascalCase (wrong)
  "ListName": "Groceries"
}
```

**Fix:**
```json
{
  "id": "123",  // camelCase (correct)
  "name": "Groceries"
}
```

### Issue: Missing error handling

**Problem:**
```csharp
var user = await _context.Users.FindAsync(id);
return Ok(user);  // What if null?
```

**Fix:**
```csharp
var user = await _context.Users.FindAsync(id);
if (user == null)
    return NotFound($"User with ID {id} not found");
return Ok(user);
```

## Documentation

For reference:
- **API Spec**: `ae-infinity-context/API_SPEC.md`
- **Architecture**: `ae-infinity-context/ARCHITECTURE.md`
- **Schemas**: `ae-infinity-context/schemas/`
- **Dev Guide**: `ae-infinity-context/DEVELOPMENT_GUIDE.md`

## Summary

Verification ensures:
✅ Code matches specifications  
✅ Architecture patterns followed  
✅ User needs met  
✅ Quality standards maintained  
✅ No regressions introduced  

Regular verification prevents technical debt and maintains project consistency.

