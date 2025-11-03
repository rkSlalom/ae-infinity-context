# Quick Start Guide

## 🎯 For Developers

### I want to...

#### ...understand what we're building
→ Read **[PROJECT_SPEC.md](./PROJECT_SPEC.md)**
- Features and requirements
- User roles and permissions
- Development phases

→ Read **[USER_PERSONAS.md](./USER_PERSONAS.md)**
- Detailed user personas and behaviors
- Permission tier explanations
- User journey examples

#### ...understand the technical architecture
→ Read **[ARCHITECTURE.md](./ARCHITECTURE.md)**
- System architecture diagram
- Technology stack
- Data models
- Frontend and backend structure

#### ...implement an API endpoint
→ Read **[API_SPEC.md](./API_SPEC.md)**
- All REST API endpoints
- Request/response formats
- Authentication patterns
- SignalR real-time events

#### ...build a UI component
→ Read **[COMPONENT_SPEC.md](./COMPONENT_SPEC.md)**
- Design system (colors, typography, spacing)
- Component specifications with props
- Custom hooks
- Accessibility guidelines

#### ...set up my dev environment
→ Read **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)**
- Setup instructions
- Project structure
- Coding standards
- Testing guidelines
- Debugging tips

## 🤖 For AI/LLM Assistance

### I want the AI to...

#### ...implement a new feature
→ Use **[LLM_CONTEXT_GUIDE.md](./LLM_CONTEXT_GUIDE.md)** - Scenario 1

**Quick Prompt**:
```
Implement [FEATURE] for AE Infinity shopping list app.
Read: PROJECT_SPEC.md, ARCHITECTURE.md, API_SPEC.md, COMPONENT_SPEC.md
Follow: DEVELOPMENT_GUIDE.md standards
Include: Backend API, Frontend UI, Tests
```

#### ...add an API endpoint
→ Use **[LLM_CONTEXT_GUIDE.md](./LLM_CONTEXT_GUIDE.md)** - Scenario 2

**Quick Prompt**:
```
Add API endpoint: [METHOD] /api/v1/[ROUTE]
Read: API_SPEC.md for patterns, ARCHITECTURE.md for structure
Include: DTOs, Service, Controller, Validation, Tests
Update: API_SPEC.md
```

#### ...create a React component
→ Use **[LLM_CONTEXT_GUIDE.md](./LLM_CONTEXT_GUIDE.md)** - Scenario 3

**Quick Prompt**:
```
Create React component: [NAME]
Read: COMPONENT_SPEC.md for design system
Include: TypeScript types, Accessibility, Tests
Follow: Design system and patterns
```

#### ...fix a bug
→ Use **[LLM_CONTEXT_GUIDE.md](./LLM_CONTEXT_GUIDE.md)** - Scenario 5

**Quick Prompt**:
```
Fix bug in [COMPONENT/SERVICE]
Issue: [DESCRIPTION]
Read: ARCHITECTURE.md for understanding
Include: Fix + Regression test
```

## 📁 File Reference

| File | Purpose | When to Read |
|------|---------|--------------|
| **README.md** | Project overview | First time setup |
| **PROJECT_SPEC.md** | Requirements & features | Before any feature work |
| **USER_PERSONAS.md** | User personas & journeys | Understanding users & permissions |
| **ARCHITECTURE.md** | System design | Architecture decisions |
| **API_SPEC.md** | API documentation | API implementation |
| **COMPONENT_SPEC.md** | UI components | Frontend development |
| **DEVELOPMENT_GUIDE.md** | Dev workflow | Setup, coding, testing |
| **LLM_CONTEXT_GUIDE.md** | AI assistance | Using LLM for development |
| **QUICK_START.md** | Quick reference | Finding the right doc |

## 🚀 Common Workflows

### Starting a New Feature

1. ✅ Read requirements in **PROJECT_SPEC.md**
2. ✅ Understand users in **USER_PERSONAS.md**
3. ✅ Check architecture in **ARCHITECTURE.md**
4. ✅ Design API in **API_SPEC.md**
5. ✅ Design UI in **COMPONENT_SPEC.md**
6. ✅ Follow standards in **DEVELOPMENT_GUIDE.md**
7. ✅ Implement backend + frontend + tests
8. ✅ Update specification docs

### Fixing a Bug

1. ✅ Reproduce the issue
2. ✅ Check **ARCHITECTURE.md** for understanding
3. ✅ Check **DEVELOPMENT_GUIDE.md** for debugging
4. ✅ Write failing test
5. ✅ Fix the issue
6. ✅ Verify test passes

### Code Review

1. ✅ Check against **DEVELOPMENT_GUIDE.md** standards
2. ✅ Verify **ARCHITECTURE.md** patterns followed
3. ✅ Confirm API matches **API_SPEC.md** conventions
4. ✅ Verify UI follows **COMPONENT_SPEC.md** design
5. ✅ Check tests are comprehensive

### Adding Documentation

1. ✅ Identify which spec file to update
2. ✅ Follow existing format and patterns
3. ✅ Include code examples
4. ✅ Update all related references

## 🎓 Learning Path

### Day 1: Understanding the Project
- [ ] Read **README.md** - Overview
- [ ] Read **PROJECT_SPEC.md** - What we're building
- [ ] Read **USER_PERSONAS.md** - Who we're building for
- [ ] Skim **ARCHITECTURE.md** - How it works

### Day 2: Setup & First Task
- [ ] Follow **DEVELOPMENT_GUIDE.md** - Setup
- [ ] Review **API_SPEC.md** - API patterns
- [ ] Review **COMPONENT_SPEC.md** - UI patterns
- [ ] Pick a small task and implement

### Day 3: AI-Assisted Development
- [ ] Read **LLM_CONTEXT_GUIDE.md**
- [ ] Practice with AI assistance
- [ ] Try different prompt patterns

### Week 1: Full Feature Implementation
- [ ] Implement a complete feature
- [ ] Backend + Frontend + Tests
- [ ] Update specifications
- [ ] Submit for review

## 🔗 Quick Links

### External Documentation
- [React Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Vite Documentation](https://vitejs.dev/)
- [.NET Documentation](https://docs.microsoft.com/dotnet/)
- [Entity Framework Core](https://docs.microsoft.com/ef/core/)
- [SignalR Documentation](https://docs.microsoft.com/aspnet/core/signalr/)

### Tools
- [Postman](https://www.postman.com/) - API testing
- [React DevTools](https://react.dev/learn/react-developer-tools)
- [Redux DevTools](https://github.com/reduxjs/redux-devtools)

## 💡 Pro Tips

### For Human Developers
- Always start with the specification docs
- Follow the coding standards strictly
- Write tests before implementation (TDD)
- Update docs when you change functionality
- Ask questions if specs are unclear

### For AI-Assisted Development
- Provide specific context file references
- Use the prompt templates from LLM_CONTEXT_GUIDE.md
- Request incremental implementation
- Always ask for tests to be included
- Have AI update specification docs

### For Code Quality
- Run linter before committing
- Ensure all tests pass
- Check accessibility (keyboard nav, ARIA)
- Test on mobile viewport
- Review your own PR before submitting

## 🆘 Getting Help

### Unclear Requirements?
→ Check **PROJECT_SPEC.md** first
→ If still unclear, raise a question

### Technical Questions?
→ Check **ARCHITECTURE.md**
→ Check **DEVELOPMENT_GUIDE.md**
→ Search existing issues

### API Questions?
→ Check **API_SPEC.md**
→ Look at existing implementations
→ Use Postman collection (if available)

### UI/UX Questions?
→ Check **COMPONENT_SPEC.md**
→ Look at existing components
→ Check design system definitions

## 📝 Quick Command Reference

### Frontend
```bash
cd ae-infinity-ui
npm install              # Install dependencies
npm run dev             # Start dev server
npm run build           # Build for production
npm test                # Run tests
npm run lint            # Lint code
```

### Backend
```bash
cd AeInfinity.Api
dotnet restore          # Restore dependencies
dotnet run              # Start API
dotnet test             # Run tests
dotnet ef database update  # Run migrations
```

## 🎯 Success Checklist

Before submitting any work, verify:

- [ ] Feature works as specified in PROJECT_SPEC.md
- [ ] Code follows DEVELOPMENT_GUIDE.md standards
- [ ] API matches patterns in API_SPEC.md
- [ ] UI follows COMPONENT_SPEC.md design system
- [ ] All tests pass (unit + integration)
- [ ] >80% code coverage
- [ ] Accessibility verified (keyboard, ARIA)
- [ ] Mobile responsive
- [ ] Error handling in place
- [ ] Loading states implemented
- [ ] Documentation updated
- [ ] Self-review completed

---

**Remember**: These specification files are your single source of truth. When in doubt, refer to them!

**Questions?** Open an issue or ask in the team channel.

**Found an error in specs?** Submit a PR to fix it!

