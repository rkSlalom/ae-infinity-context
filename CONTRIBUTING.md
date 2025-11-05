# Contributing to AE Infinity

**Thank you for contributing!** This project follows **Spec Kit SDD** (Specification-Driven Development) methodology.

---

## 🎯 Core Principles

1. **Specification First** - No code without complete specs
2. **Test-Driven Development** - Write tests before implementation (80% coverage minimum)
3. **Constitution Compliance** - All code must pass quality gates
4. **Real-time Collaboration** - SignalR for live updates
5. **Security by Design** - JWT auth, validation, HTTPS in production

See [Constitution](.specify/memory/constitution.md) for complete principles.

---

## 🚀 Development Workflow

### **1. Specify a Feature**

Before writing any code, create a complete specification:

```bash
# Use the Spec Kit command
/speckit.specify "feature description"

# Example:
/speckit.specify "Allow users to add images to shopping list items"
```

**This generates**:
- `specs/XXX-feature-name/spec.md` - Business requirements
- `specs/XXX-feature-name/checklists/requirements.md` - Quality validation

**What to include**:
- User stories with priorities (P1, P2, P3)
- Acceptance scenarios (Given-When-Then)
- Functional requirements
- Success criteria (measurable)
- Edge cases

---

### **2. Plan the Implementation**

Generate an implementation plan:

```bash
/speckit.plan XXX-feature-name
```

**This generates**:
- `specs/XXX-feature-name/plan.md` - Implementation strategy
- `specs/XXX-feature-name/data-model.md` - Entity definitions
- `specs/XXX-feature-name/quickstart.md` - Developer guide
- `specs/XXX-feature-name/contracts/` - API JSON schemas

**Plan includes**:
- Technical context (.NET 9.0, React 19.1, SQLite)
- Constitution check (quality gates)
- Implementation phases
- Testing strategy
- Performance goals

---

### **3. Break Down into Tasks**

Create an actionable task list:

```bash
/speckit.tasks XXX-feature-name
```

**This generates**:
- `specs/XXX-feature-name/tasks.md` - Implementation checklist

**Tasks include**:
- Sequential IDs (T001, T002, T003...)
- User story labels ([US1], [US2]...)
- Parallelization markers ([P])
- File paths for each task
- Independent test criteria

---

### **4. Implement the Feature**

Now you can write code in the actual repositories:

#### **Backend (`ae-infinity-api`)**

```bash
cd ae-infinity-api

# Create feature branch
git checkout -b XXX-feature-name

# Follow tasks.md and quickstart.md
# Write tests first (TDD)
# Implement code
# Ensure tests pass

dotnet test
```

#### **Frontend (`ae-infinity-ui`)**

```bash
cd ae-infinity-ui

# Create feature branch
git checkout -b XXX-feature-name

# Follow tasks.md and quickstart.md
# Write component tests first
# Implement UI
# Ensure tests pass

npm test
```

---

### **5. Verify Against Spec**

Ensure implementation matches specification:

```bash
# Check implementation completeness
/speckit.analyze XXX-feature-name

# Verify all acceptance scenarios pass
# Check success criteria are met
# Ensure test coverage >= 80%
```

**Verification Checklist**:
- [ ] All acceptance scenarios from spec.md pass
- [ ] All functional requirements implemented
- [ ] Test coverage >= 80%
- [ ] API contracts match JSON schemas in `contracts/`
- [ ] No TypeScript `any` types (frontend)
- [ ] XML documentation on public APIs (backend)
- [ ] Constitution quality gates pass

---

### **6. Submit Pull Request**

```bash
# Commit your changes
git add .
git commit -m "feat(XXX): implement feature description"

# Push to GitHub
git push origin XXX-feature-name

# Create Pull Request
# Title: feat(XXX): Brief description
# Body: Link to spec.md, explain implementation
```

---

## 📋 Code Standards

### **Backend Standards (.NET 9.0)**

✅ **Clean Architecture**
```
API → Application (MediatR) → Domain → Infrastructure
```

✅ **Naming Conventions**
- Files: PascalCase (matching class name): `UserService.cs`
- Classes: PascalCase: `LoginCommand`
- Methods: PascalCase: `GetUserById`
- Variables: camelCase: `userId`
- Private fields: `_camelCase`: `_context`

✅ **Patterns**
- MediatR for CQRS (commands/queries)
- FluentValidation for DTOs
- Entity Framework Core for data access (no raw SQL)
- Async/await for all I/O operations
- Dependency Injection throughout

✅ **Documentation**
```csharp
/// <summary>
/// Updates user profile information
/// </summary>
/// <param name="command">Profile update command</param>
/// <returns>Updated user DTO</returns>
public async Task<UserDto> Handle(UpdateProfileCommand command)
{
    // Implementation
}
```

✅ **Testing**
- Unit tests: xUnit with FluentAssertions
- Integration tests: WebApplicationFactory
- Test naming: `MethodName_Scenario_ExpectedResult`
- Arrange-Act-Assert pattern

---

### **Frontend Standards (React 19.1 + TypeScript)**

✅ **File Structure**
- Components: PascalCase: `ProfilePage.tsx`
- Hooks: camelCase with `use` prefix: `useAuth.ts`
- Utils: camelCase: `formatters.ts`
- Tests: Same name + `.test`: `ProfilePage.test.tsx`

✅ **Component Style**
```typescript
// Functional components with TypeScript
interface Props {
  userId: string;
  onUpdate: (data: UserDto) => void;
}

export function ProfilePage({ userId, onUpdate }: Props) {
  // Hooks at top
  const { user, loading } = useProfile(userId);
  
  // Early returns for loading/error states
  if (loading) return <Spinner />;
  if (!user) return <ErrorMessage />;
  
  // Main render
  return (
    <div className="p-4">
      {/* Component content */}
    </div>
  );
}
```

✅ **TypeScript**
- Strict mode enabled
- No `any` types (use `unknown` if truly unknown)
- Explicit return types on functions
- Interface over type for objects

✅ **Styling**
- Tailwind CSS utility classes
- Mobile-first responsive design
- Semantic HTML elements
- WCAG 2.1 AA accessibility

✅ **Testing**
- Vitest + React Testing Library
- Test user behavior, not implementation
- Mock API calls with MSW
- Accessibility tests with axe

---

## 🧪 Testing Requirements

### **Minimum Coverage: 80%**

| Layer | Tool | Coverage Target |
|-------|------|-----------------|
| Backend - Unit | xUnit | 80%+ |
| Backend - Integration | WebApplicationFactory | All endpoints |
| Frontend - Component | Vitest + RTL | 80%+ |
| Frontend - Hooks | Vitest | 80%+ |

### **Test-Driven Development (TDD)**

**RED → GREEN → REFACTOR**

1. **Write failing test** (RED)
```csharp
[Fact]
public async Task Handle_ValidCommand_UpdatesProfile()
{
    // Arrange
    var command = new UpdateProfileCommand { DisplayName = "New Name" };
    
    // Act
    var result = await _handler.Handle(command);
    
    // Assert
    result.IsSuccess.Should().BeTrue();
    result.Value.DisplayName.Should().Be("New Name");
}
```

2. **Implement minimum code** (GREEN)
```csharp
public async Task<Result<UserDto>> Handle(UpdateProfileCommand request)
{
    var user = await _context.Users.FindAsync(request.UserId);
    user.DisplayName = request.DisplayName;
    await _context.SaveChangesAsync();
    return Result<UserDto>.Success(UserDto.FromEntity(user));
}
```

3. **Refactor** (clean up, optimize, follow patterns)

---

## 📜 Git Commit Guidelines

### **Commit Message Format**

```
<type>(<scope>): <subject>

<body>

<footer>
```

### **Types**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting, no logic change)
- `refactor`: Code change (no feat/fix)
- `test`: Add/update tests
- `chore`: Build/tooling changes

### **Scopes**

Use feature number or component:
- `001`: Feature 001 (User Authentication)
- `002`: Feature 002 (User Profile Management)
- `api`: Backend API changes
- `ui`: Frontend UI changes
- `docs`: Documentation updates

### **Examples**

```bash
# Good commits
git commit -m "feat(001): implement user registration endpoint"
git commit -m "fix(002): validate avatar URL format correctly"
git commit -m "test(001): add integration tests for login endpoint"
git commit -m "docs(spec): update Feature 003 acceptance scenarios"

# Bad commits
git commit -m "updates"
git commit -m "fixed bug"
git commit -m "WIP"
```

---

## 🔍 Code Review Checklist

### **For Reviewers**

When reviewing a PR, verify:

#### **Specification Compliance**
- [ ] Implementation matches `spec.md` requirements
- [ ] All acceptance scenarios pass
- [ ] Success criteria are met
- [ ] Edge cases handled

#### **Code Quality**
- [ ] Follows naming conventions
- [ ] No code smells (long methods, deep nesting, etc.)
- [ ] Proper error handling
- [ ] No hardcoded values (use configuration)
- [ ] Logging added for important events

#### **Testing**
- [ ] Tests written before implementation (TDD)
- [ ] Test coverage >= 80%
- [ ] All tests pass
- [ ] Tests cover edge cases

#### **Documentation**
- [ ] XML comments on public APIs (backend)
- [ ] JSDoc comments on exported functions (frontend)
- [ ] README updated if needed
- [ ] CHANGELOG.md updated

#### **Security**
- [ ] Input validation (FluentValidation backend)
- [ ] Authorization checks (can user perform this action?)
- [ ] No sensitive data in logs
- [ ] SQL injection prevented (use EF Core, no raw SQL)
- [ ] XSS prevented (React escapes by default)

#### **Performance**
- [ ] Database queries optimized (use LINQ efficiently)
- [ ] No N+1 queries (use `.Include()` for related data)
- [ ] Caching used where appropriate
- [ ] API response time < 200ms (p95)

---

## 🚫 What NOT to Do

❌ **Don't write code without specs**
- Always create specification first
- Use `/speckit.specify` to scaffold

❌ **Don't skip tests**
- TDD is mandatory (constitution requirement)
- Aim for 80%+ coverage

❌ **Don't use `any` in TypeScript**
- Use proper types or `unknown`

❌ **Don't write raw SQL**
- Use Entity Framework Core LINQ queries
- EF prevents SQL injection

❌ **Don't hardcode values**
- Use configuration (appsettings.json, .env)
- Use constants for magic numbers

❌ **Don't ignore linter warnings**
- Fix all warnings before committing
- Use `dotnet format` and `npm run lint`

❌ **Don't commit commented code**
- Delete unused code
- Use git history if you need it later

❌ **Don't mix concerns**
- Follow Clean Architecture
- Controllers → thin (just routing)
- Handlers → business logic
- Repositories → data access

---

## 🎓 Learning Resources

### **For Beginners**

1. **Read existing specs**:
   - [Feature 001: User Authentication](./specs/001-user-authentication/spec.md)
   - [Feature 002: User Profile Management](./specs/002-user-profile-management/spec.md)

2. **Review constitution**:
   - [Development Principles](./.specify/memory/constitution.md)

3. **Explore codebase**:
   - Backend: `ae-infinity-api/`
   - Frontend: `ae-infinity-ui/`

4. **Watch examples**:
   - See `quickstart.md` in any feature for code examples

### **For Advanced**

1. **Architecture patterns**:
   - Clean Architecture (Robert C. Martin)
   - CQRS with MediatR
   - Repository Pattern

2. **Testing strategies**:
   - TDD (Kent Beck)
   - Testing Trophy (Kent C. Dodds)
   - Integration testing with WebApplicationFactory

3. **Spec Kit methodology**:
   - Review all templates in `.specify/templates/`
   - Understand the full workflow

---

## 🐛 Reporting Issues

### **Bug Reports**

When reporting a bug, include:

1. **Feature**: Which feature is affected?
2. **Expected**: What should happen (reference spec.md)?
3. **Actual**: What actually happened?
4. **Steps**: How to reproduce?
5. **Environment**: Browser/OS, .NET version, Node version

### **Feature Requests**

For new features:

1. **Create specification first**: Use `/speckit.specify`
2. **Discuss with team**: Is this aligned with roadmap?
3. **Get approval**: Before implementing

---

## 📞 Getting Help

- 📖 **Documentation**: Check `specs/` folder
- 📜 **Constitution**: Read development principles
- 🏛️ **Architecture**: See ARCHITECTURE.md
- 💬 **Team Chat**: Ask questions
- 🐛 **Issues**: Create GitHub issue

---

## 🎯 Definition of Done

A feature is complete when:

- [x] Specification created and reviewed
- [x] Implementation plan generated
- [x] All tasks checked off in tasks.md
- [x] All acceptance scenarios pass
- [x] Test coverage >= 80%
- [x] Code review approved
- [x] CI/CD pipeline passes
- [x] Documentation updated
- [x] CHANGELOG.md updated
- [x] Deployed to staging
- [x] QA sign-off

---

## 🌟 Recognition

We appreciate all contributions! Contributors will be:

- ✅ Listed in CONTRIBUTORS.md (coming soon)
- ✅ Mentioned in CHANGELOG.md
- ✅ Recognized in team meetings
- ✅ Invited to design discussions

---

**Thank you for contributing to AE Infinity!** 🚀

Your adherence to Spec Kit SDD helps us build better software, faster, with AI assistance.

