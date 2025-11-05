# AE Infinity Constitution

## Core Principles

### I. Specification-First Development
Every feature starts with comprehensive specifications before implementation. All product, design, and technical decisions are documented and serve as the single source of truth. Specifications must be complete, precise, and cross-referenced. Implementation follows specs, not the reverse.

**Requirements:**
- Write complete specifications in this context repository before coding
- Update specs when requirements change
- Document deviations when implementation must differ from specs
- Track feature status from specification through implementation to integration

### II. OpenSpec Change Management
All significant changes follow the OpenSpec workflow: proposal, approval, implementation, archive. Changes require structured documentation with clear requirements, scenarios, and implementation tasks. No breaking changes or new capabilities without approved proposals.

**Requirements:**
- Create proposal for: new features, breaking changes, architecture changes, security/performance work
- Skip proposal only for: bug fixes, typos, non-breaking dependency updates, configuration changes
- Use delta operations: ADDED, MODIFIED, REMOVED, RENAMED Requirements
- Every requirement MUST have at least one scenario in `#### Scenario:` format
- Validate with `openspec validate --strict` before requesting approval
- Do NOT start implementation until proposal is approved

### III. Real-time Collaboration Architecture
The system is built for real-time collaborative shopping with multiple users editing simultaneously. Architecture must support live updates, optimistic UI, conflict resolution, and presence indicators. WebSocket/SignalR communication is non-negotiable for collaborative features.

**Requirements:**
- All list and item updates broadcast via SignalR to connected clients
- Implement optimistic UI updates with rollback capability
- Handle conflict resolution (last-write-wins with user notification)
- Display presence indicators for active collaborators
- Maintain offline capability with sync when reconnected

### IV. Security & Privacy by Design
JWT-based authentication with secure password hashing. Role-based access control at the list level (Owner, Editor, Viewer). All API endpoints require authentication except login/register. HTTPS in production, CORS properly configured, input validation mandatory.

**Requirements:**
- JWT tokens (HMAC-SHA256) expire after 24 hours
- BCrypt password hashing with automatic salts
- Authorization checks at middleware, business logic, and database query levels
- Validate all inputs with FluentValidation
- Parameterized queries (Entity Framework Core prevents SQL injection)
- Case-insensitive email lookup, generic error messages for failed auth

### V. Test-Driven Development (NON-NEGOTIABLE)
Write tests before implementation. Unit tests for business logic, integration tests for API endpoints, component tests for React components. All tests must pass before merging. Test coverage is tracked and enforced.

**Requirements:**
- Unit tests (Vitest/xUnit) for all services and utilities
- Integration tests for API endpoints (WebApplicationFactory)
- Component tests (React Testing Library) for UI components
- Test real-time features with SignalR test clients
- Minimum 80% code coverage target
- Tests run in CI/CD pipeline, blocking merges on failure

## Development Workflow

### Branching Strategy
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: New features (branch from develop)
- `bugfix/*`: Bug fixes
- `hotfix/*`: Production hotfixes

### Feature Development Process
1. **Check specifications** in this context repository (PROJECT_SPEC.md, API_SPEC.md, COMPONENT_SPEC.md, etc.)
2. **Create/update specs** if requirements change
3. **Create OpenSpec proposal** for significant changes (follow openspec/AGENTS.md)
4. **Write tests first** following TDD approach
5. **Implement feature** in code repositories (ae-infinity-api, ae-infinity-ui)
6. **Run tests** and ensure all pass
7. **Update documentation** status in FEATURES.md and ARCHITECTURE.md
8. **Create pull request** against develop, request review
9. **Merge after approval** and passing tests

### Code Review Requirements
- All code changes require approval from at least one reviewer
- Reviewer must verify: compliance with specs, test coverage, security considerations
- Breaking changes require approval from tech lead
- Documentation must be updated before merge

## Technical Standards

### Frontend Standards (React + TypeScript + Vite)
- TypeScript strict mode enabled, no `any` types
- Functional components with hooks (no class components)
- Use `useMemo` and `useCallback` for performance
- Custom hooks for reusable logic
- Code splitting by route with lazy loading
- Tailwind CSS for styling (utility-first approach)
- Accessibility: WCAG 2.1 AA compliance required

### Backend Standards (.NET 9.0)
- Clean Architecture: API → Application → Core → Infrastructure layers
- Dependency Injection throughout
- Async/await for all I/O operations
- XML documentation comments on public APIs
- Entity Framework Core for data access (no raw SQL)
- FluentValidation for request validation
- SOLID principles enforced

### API Design Principles
- RESTful conventions (proper HTTP verbs and status codes)
- Resource-based URLs: `/api/lists/{listId}/items/{itemId}`
- Consistent error responses with structured format
- Pagination for all list endpoints (default page size: 20)
- Filtering and sorting via query parameters
- Versioning: `/api/v1/` prefix

### Naming Conventions
- **Frontend Files**:
  - Components: PascalCase (`ShoppingListCard.tsx`)
  - Hooks: camelCase with `use` prefix (`useAuth.ts`)
  - Utils: camelCase (`formatters.ts`)
- **Backend Files**:
  - All files: PascalCase matching class name (`ListService.cs`)
- **Capabilities**: verb-noun format (`user-auth`, `list-management`)
- **Change IDs**: kebab-case, verb-led (`add-two-factor-auth`, `update-item-schema`)

## Quality Gates

### Pre-Merge Checklist
- [ ] All tests pass locally and in CI
- [ ] Code follows naming and style conventions
- [ ] TypeScript/C# compiler has no errors
- [ ] No security vulnerabilities (linter checks)
- [ ] Documentation updated (if public API changed)
- [ ] Specs updated (if behavior changed)
- [ ] Code review approved
- [ ] Branch up-to-date with target branch

### Performance Requirements
- Page load time < 2 seconds
- Real-time update latency < 100ms
- API response time < 200ms (p95)
- Support 10,000+ concurrent users
- Database queries optimized with proper indexes

### Security Requirements
- All production traffic over HTTPS
- No sensitive data in logs or error messages
- Rate limiting: 100 requests/minute per user
- CORS restricted to known origins in production
- Content Security Policy headers configured

## Deployment & Operations

### Environment Configuration
- **Development**: Local with mock data support
- **Staging**: Pre-production for integration testing
- **Production**: Live environment with monitoring

### CI/CD Pipeline
1. Code push triggers automated build
2. Run all tests (unit, integration, component)
3. Lint and security scan
4. Build Docker images
5. Deploy to staging
6. Run automated smoke tests
7. Manual approval gate
8. Deploy to production
9. Monitor metrics and alerts

### Monitoring Requirements
- Structured logging with Serilog (Backend) and console (Frontend)
- Log levels: Trace, Debug, Info, Warning, Error, Critical
- Track: request/response times, error rates, active users, cache hit rates
- Distributed tracing with correlation IDs
- Centralized logging (ELK stack or Application Insights)

## Governance

### Constitution Authority
This constitution supersedes all other practices and guidelines. When conflicts arise, this document is authoritative. All PRs and code reviews must verify compliance. Changes to this constitution require documentation, approval from tech lead, and communication to all team members.

### Amendment Process
1. Propose amendment with rationale and impact analysis
2. Discuss with team in architecture review meeting
3. Document decision and migration plan if needed
4. Update this constitution with version and date
5. Communicate changes to entire team
6. Update related documentation and tooling

### Complexity Justification
Additional complexity requires:
- Performance data showing current solution insufficient
- Concrete scale requirements (>1000 users, >100MB data)
- Multiple proven use cases requiring abstraction
- Approval from tech lead

Default to simplicity: <100 lines of new code, single-file implementations, boring/proven patterns.

### Integration Guidance
For runtime development guidance and current feature status, see:
- **FEATURES.md** - Master feature tracker with implementation status
- **ARCHITECTURE.md** - Implementation details and patterns
- **DEVELOPMENT_GUIDE.md** - Setup and development workflow
- **openspec/AGENTS.md** - Change management workflow

**Version**: 1.0.0 | **Ratified**: 2025-11-05 | **Last Amended**: 2025-11-05
