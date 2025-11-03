# LLM Context Guide for AI-Assisted Development

This guide provides instructions for effective AI-assisted development of the AE Infinity application. It's designed for use with LLMs (Large Language Models) and agentic AI workflows.

## 📚 Context Files Overview

### When to Reference Each File

| File | Use When |
|------|----------|
| **PROJECT_SPEC.md** | Understanding overall requirements, features, user roles, or project scope |
| **ARCHITECTURE.md** | Designing system components, understanding data flow, or making architectural decisions |
| **API_SPEC.md** | Implementing or consuming API endpoints, understanding request/response formats |
| **COMPONENT_SPEC.md** | Building UI components, implementing design system, or frontend architecture |
| **DEVELOPMENT_GUIDE.md** | Setting up environment, following coding standards, testing, or deployment |
| **LLM_CONTEXT_GUIDE.md** | Getting started with AI-assisted development (this file) |

## 🎯 Common Development Scenarios

### Scenario 1: Implementing a New Feature

**Required Context Files**: PROJECT_SPEC.md, ARCHITECTURE.md, API_SPEC.md, COMPONENT_SPEC.md

**Prompt Template**:
```
I need to implement [FEATURE_NAME] for the AE Infinity shopping list application.

Context needed:
1. Review PROJECT_SPEC.md for feature requirements
2. Review ARCHITECTURE.md for system design patterns
3. Review API_SPEC.md for relevant endpoints
4. Review COMPONENT_SPEC.md for UI components

Please:
1. Create the backend API endpoint(s)
2. Implement the frontend components
3. Add real-time SignalR events if needed
4. Write tests for both frontend and backend
5. Follow coding standards from DEVELOPMENT_GUIDE.md

Feature details: [DESCRIBE FEATURE]
```

### Scenario 2: Adding a New API Endpoint

**Required Context Files**: API_SPEC.md, ARCHITECTURE.md, DEVELOPMENT_GUIDE.md

**Prompt Template**:
```
I need to add a new API endpoint for [OPERATION].

Context:
- Review API_SPEC.md for API design patterns and conventions
- Review ARCHITECTURE.md for backend structure
- Follow coding standards from DEVELOPMENT_GUIDE.md

Endpoint requirements:
- HTTP Method: [GET/POST/PUT/DELETE]
- Route: /api/v1/[RESOURCE]
- Purpose: [DESCRIBE PURPOSE]
- Request: [DESCRIBE REQUEST BODY]
- Response: [DESCRIBE RESPONSE]

Please implement:
1. DTO classes (Request/Response)
2. Service interface and implementation
3. Controller action
4. Validation
5. Unit tests
6. Integration tests
7. Update API_SPEC.md with the new endpoint
```

### Scenario 3: Building a React Component

**Required Context Files**: COMPONENT_SPEC.md, DEVELOPMENT_GUIDE.md

**Prompt Template**:
```
I need to create a React component for [COMPONENT_NAME].

Context:
- Review COMPONENT_SPEC.md for design system and patterns
- Follow coding standards from DEVELOPMENT_GUIDE.md

Component requirements:
- Purpose: [DESCRIBE PURPOSE]
- Props: [LIST PROPS]
- Features: [LIST FEATURES]

Please:
1. Create TypeScript interface for props
2. Implement the component with accessibility
3. Follow design system (colors, spacing, typography)
4. Add proper ARIA labels
5. Write component tests
6. Include usage example
```

### Scenario 4: Adding Real-time Functionality

**Required Context Files**: ARCHITECTURE.md, API_SPEC.md, COMPONENT_SPEC.md

**Prompt Template**:
```
I need to add real-time updates for [FEATURE].

Context:
- Review ARCHITECTURE.md for SignalR setup
- Review API_SPEC.md for SignalR event patterns
- Review COMPONENT_SPEC.md for useRealtime hook

Requirements:
- Event trigger: [DESCRIBE WHEN EVENT SHOULD FIRE]
- Data to broadcast: [DESCRIBE DATA]
- Affected clients: [WHO SHOULD RECEIVE]

Please implement:
1. Backend SignalR hub method
2. Broadcast logic in service layer
3. Frontend event listener in useRealtime hook
4. Local state update on event received
5. Optimistic update with rollback
6. Update API_SPEC.md with new event
```

### Scenario 5: Fixing a Bug

**Required Context Files**: ARCHITECTURE.md, DEVELOPMENT_GUIDE.md

**Prompt Template**:
```
I need to fix a bug in [COMPONENT/SERVICE].

Bug description: [DESCRIBE BUG]
Expected behavior: [DESCRIBE EXPECTED]
Actual behavior: [DESCRIBE ACTUAL]
Steps to reproduce: [LIST STEPS]

Context:
- Review ARCHITECTURE.md for understanding system behavior
- Follow debugging practices from DEVELOPMENT_GUIDE.md

Please:
1. Identify the root cause
2. Implement the fix
3. Add/update tests to prevent regression
4. Verify the fix doesn't break existing functionality
```

### Scenario 6: Refactoring Code

**Required Context Files**: ARCHITECTURE.md, DEVELOPMENT_GUIDE.md

**Prompt Template**:
```
I need to refactor [COMPONENT/SERVICE] to [GOAL].

Current issues: [DESCRIBE ISSUES]
Refactoring goals: [LIST GOALS]

Context:
- Review ARCHITECTURE.md for design patterns
- Follow coding standards from DEVELOPMENT_GUIDE.md

Please:
1. Analyze current implementation
2. Propose refactoring approach
3. Implement refactoring
4. Ensure all tests still pass
5. Update tests if needed
```

### Scenario 7: Optimizing Performance

**Required Context Files**: ARCHITECTURE.md, COMPONENT_SPEC.md, DEVELOPMENT_GUIDE.md

**Prompt Template**:
```
I need to optimize performance for [FEATURE/COMPONENT].

Performance issue: [DESCRIBE ISSUE]
Current metrics: [PROVIDE METRICS]
Target metrics: [PROVIDE TARGETS]

Context:
- Review ARCHITECTURE.md for optimization strategies
- Review COMPONENT_SPEC.md for performance considerations
- Review DEVELOPMENT_GUIDE.md for optimization techniques

Please:
1. Identify performance bottlenecks
2. Propose optimization strategies
3. Implement optimizations
4. Measure performance improvements
5. Ensure functionality remains intact
```

## 🔄 Agentic Workflow Patterns

### Pattern 1: Feature Implementation Agent

**Autonomous Workflow**:
1. Read PROJECT_SPEC.md to understand feature requirements
2. Read ARCHITECTURE.md to understand system design
3. Read API_SPEC.md to design API endpoints
4. Read COMPONENT_SPEC.md to design UI components
5. Generate backend code (DTOs, services, controllers)
6. Generate frontend code (components, hooks, API clients)
7. Generate tests (unit and integration)
8. Update specification documents
9. Run tests and verify implementation

**Agent Instructions**:
```
You are an autonomous development agent for the AE Infinity project.

Your task: Implement [FEATURE_NAME]

Required steps:
1. ✓ Read context from specification files
2. ✓ Design API endpoints following API_SPEC.md patterns
3. ✓ Design UI components following COMPONENT_SPEC.md patterns
4. ✓ Implement backend (service, controller, DTOs)
5. ✓ Implement frontend (components, hooks)
6. ✓ Implement real-time updates if needed
7. ✓ Write comprehensive tests
8. ✓ Update specification documents
9. ✓ Verify all tests pass
10. ✓ Report completion with summary

Constraints:
- Follow all coding standards from DEVELOPMENT_GUIDE.md
- Maintain consistency with existing patterns
- Ensure accessibility (WCAG 2.1 AA)
- Include error handling
- Add proper documentation
```

### Pattern 2: Code Review Agent

**Autonomous Workflow**:
1. Read DEVELOPMENT_GUIDE.md for coding standards
2. Read ARCHITECTURE.md for design patterns
3. Analyze code for standards compliance
4. Check for security issues
5. Verify tests are present and comprehensive
6. Check accessibility
7. Verify documentation
8. Generate review report

**Agent Instructions**:
```
You are a code review agent for the AE Infinity project.

Your task: Review [PULL_REQUEST/CODE_CHANGES]

Review checklist:
1. ✓ Follows coding standards from DEVELOPMENT_GUIDE.md
2. ✓ Follows architectural patterns from ARCHITECTURE.md
3. ✓ API endpoints match patterns in API_SPEC.md
4. ✓ Components follow COMPONENT_SPEC.md design system
5. ✓ Includes comprehensive tests
6. ✓ Has proper error handling
7. ✓ Includes accessibility features (ARIA, keyboard nav)
8. ✓ Has security considerations (input validation, auth)
9. ✓ Is properly documented
10. ✓ Performance considerations addressed

Output:
- List of issues found (categorized by severity)
- Suggestions for improvements
- Approval/rejection recommendation
```

### Pattern 3: Documentation Agent

**Autonomous Workflow**:
1. Analyze new/changed code
2. Identify what needs documentation
3. Read relevant specification files
4. Generate/update documentation
5. Ensure consistency with existing docs
6. Verify accuracy

**Agent Instructions**:
```
You are a documentation agent for the AE Infinity project.

Your task: Update documentation for [FEATURE/CHANGE]

Steps:
1. ✓ Analyze code changes
2. ✓ Identify documentation impacts:
   - API_SPEC.md (new endpoints?)
   - COMPONENT_SPEC.md (new components?)
   - ARCHITECTURE.md (architectural changes?)
   - DEVELOPMENT_GUIDE.md (new patterns?)
3. ✓ Update relevant documentation
4. ✓ Ensure consistency across all docs
5. ✓ Generate usage examples
6. ✓ Update README.md if needed

Documentation standards:
- Clear and concise
- Include code examples
- Specify all parameters/props
- Show request/response formats
- Include error cases
```

### Pattern 4: Testing Agent

**Autonomous Workflow**:
1. Read code to be tested
2. Read DEVELOPMENT_GUIDE.md for testing standards
3. Identify test scenarios
4. Generate unit tests
5. Generate integration tests
6. Generate component tests
7. Run tests
8. Report coverage

**Agent Instructions**:
```
You are a testing agent for the AE Infinity project.

Your task: Create comprehensive tests for [COMPONENT/SERVICE]

Test categories:
1. ✓ Unit tests
   - All public methods
   - Edge cases
   - Error conditions
2. ✓ Integration tests
   - API endpoints
   - Database interactions
   - External service calls
3. ✓ Component tests (frontend)
   - Rendering
   - User interactions
   - State changes
   - Error states
4. ✓ Accessibility tests
   - Keyboard navigation
   - Screen reader support
   - Focus management

Follow testing patterns from DEVELOPMENT_GUIDE.md
Target: >80% code coverage
```

## 🧠 Context Management Strategies

### Strategy 1: Progressive Context Loading

Load context files progressively based on task complexity:

**Simple Task** (e.g., fixing typo):
- No context files needed

**Medium Task** (e.g., adding UI component):
- COMPONENT_SPEC.md
- DEVELOPMENT_GUIDE.md

**Complex Task** (e.g., implementing feature):
- PROJECT_SPEC.md
- ARCHITECTURE.md
- API_SPEC.md
- COMPONENT_SPEC.md
- DEVELOPMENT_GUIDE.md

### Strategy 2: Context Caching

For repeated operations, cache key information:
- Design system (colors, spacing, typography)
- API patterns (error handling, pagination)
- Coding standards
- Common component props

### Strategy 3: Incremental Context Updates

When specifications change:
1. Update relevant specification file(s)
2. Notify about changes
3. Update related code
4. Update tests
5. Verify consistency

## 📋 Task Checklists

### New Feature Checklist

```markdown
- [ ] Read PROJECT_SPEC.md for requirements
- [ ] Read ARCHITECTURE.md for design patterns
- [ ] Design API endpoints (update API_SPEC.md)
- [ ] Design UI components (update COMPONENT_SPEC.md)
- [ ] Implement backend:
  - [ ] Domain models
  - [ ] DTOs
  - [ ] Service interface
  - [ ] Service implementation
  - [ ] Controller
  - [ ] Validators
- [ ] Implement frontend:
  - [ ] TypeScript types
  - [ ] API client
  - [ ] Custom hooks
  - [ ] Components
  - [ ] Pages
- [ ] Implement real-time (if needed):
  - [ ] SignalR hub methods
  - [ ] Event broadcasting
  - [ ] Client event handlers
- [ ] Write tests:
  - [ ] Backend unit tests
  - [ ] Backend integration tests
  - [ ] Frontend component tests
  - [ ] E2E tests (if needed)
- [ ] Verify:
  - [ ] All tests pass
  - [ ] Accessibility (keyboard nav, ARIA)
  - [ ] Error handling
  - [ ] Loading states
  - [ ] Mobile responsive
- [ ] Documentation:
  - [ ] Update API_SPEC.md
  - [ ] Update COMPONENT_SPEC.md
  - [ ] Add code comments
  - [ ] Update README if needed
```

### Bug Fix Checklist

```markdown
- [ ] Reproduce the bug
- [ ] Identify root cause
- [ ] Read relevant context files
- [ ] Write failing test that reproduces bug
- [ ] Implement fix
- [ ] Verify test now passes
- [ ] Run full test suite
- [ ] Check for similar issues elsewhere
- [ ] Update documentation if needed
- [ ] Deploy and verify in production
```

## 🎨 Prompt Engineering Tips

### Tip 1: Be Specific About Context

❌ Bad:
```
Create a shopping list component
```

✅ Good:
```
Create a ShoppingListCard component following the design in COMPONENT_SPEC.md.
The component should display list name, item count, collaborators, and last updated time.
Follow the design system colors and spacing from COMPONENT_SPEC.md.
Include accessibility features per DEVELOPMENT_GUIDE.md.
```

### Tip 2: Request Incremental Implementation

❌ Bad:
```
Implement the entire shopping list feature
```

✅ Good:
```
Step 1: Implement the ShoppingList data model and repository
Step 2: Implement the ListService with CRUD operations
Step 3: Implement the API controller with endpoints
Step 4: Write tests for each layer
```

### Tip 3: Specify Testing Requirements

❌ Bad:
```
Add tests
```

✅ Good:
```
Add tests following DEVELOPMENT_GUIDE.md:
1. Unit tests for ListService covering all methods
2. Integration tests for API endpoints
3. Test error cases and edge conditions
4. Aim for >80% coverage
```

### Tip 4: Reference Existing Patterns

✅ Good:
```
Create the ItemService following the same pattern as ListService in ARCHITECTURE.md.
Use the repository pattern and dependency injection.
Include similar error handling and validation.
```

### Tip 5: Combine Multiple Context Files

✅ Good:
```
Implement the "Share List" feature:
- Review requirements in PROJECT_SPEC.md (Collaboration section)
- Follow API patterns in API_SPEC.md (POST /lists/{id}/share)
- Use ShareListModal design from COMPONENT_SPEC.md
- Follow coding standards from DEVELOPMENT_GUIDE.md
```

## 🔍 Debugging with LLM Assistance

### Debugging Prompt Template

```
I'm experiencing an issue in [COMPONENT/SERVICE]:

Problem: [DESCRIBE ISSUE]
Expected: [DESCRIBE EXPECTED BEHAVIOR]
Actual: [DESCRIBE ACTUAL BEHAVIOR]

Context:
- Review ARCHITECTURE.md for system behavior
- Code location: [FILE PATH]
- Recent changes: [DESCRIBE CHANGES]

Error messages:
[PASTE ERROR MESSAGES]

Relevant code:
[PASTE RELEVANT CODE]

Please:
1. Analyze the issue
2. Identify root cause
3. Propose solution
4. Implement fix
5. Add test to prevent regression
```

## 📊 Quality Assurance with LLMs

### QA Prompt Template

```
Please perform quality assurance on [FEATURE/COMPONENT]:

Checklist:
1. Functionality
   - [ ] Feature works as specified in PROJECT_SPEC.md
   - [ ] All user flows complete successfully
   - [ ] Error cases handled gracefully

2. Code Quality
   - [ ] Follows DEVELOPMENT_GUIDE.md standards
   - [ ] Proper error handling
   - [ ] Appropriate logging
   - [ ] Clean, maintainable code

3. Testing
   - [ ] Unit tests present and passing
   - [ ] Integration tests present and passing
   - [ ] >80% code coverage
   - [ ] Edge cases covered

4. Security
   - [ ] Input validation
   - [ ] Authentication/authorization
   - [ ] No SQL injection vulnerabilities
   - [ ] No XSS vulnerabilities

5. Performance
   - [ ] No unnecessary re-renders
   - [ ] Appropriate memoization
   - [ ] Efficient database queries
   - [ ] Proper caching

6. Accessibility
   - [ ] Keyboard navigation works
   - [ ] ARIA labels present
   - [ ] Screen reader friendly
   - [ ] Color contrast meets WCAG AA

7. Documentation
   - [ ] Code comments where needed
   - [ ] Specification files updated
   - [ ] Usage examples provided

Report any issues found with severity ratings.
```

## 🚀 Continuous Improvement

### Feedback Loop

After each development session:
1. What worked well?
2. What was unclear in specifications?
3. What context was missing?
4. How can specifications be improved?
5. Update relevant files with learnings

### Specification Evolution

Specifications should evolve with the project:
- Add new patterns discovered
- Document common issues and solutions
- Refine component designs
- Update best practices
- Add examples from actual implementation

---

This guide is a living document. Update it as you discover better patterns for LLM-assisted development.

