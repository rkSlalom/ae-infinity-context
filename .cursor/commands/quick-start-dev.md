---
description: "Quick start guide for development in working directory"
tags: ["quickstart", "development", "getting-started"]
---

# Quick Start Development

Get up and running quickly with a working directory for development.

## 30-Second Setup

```bash
cd ae-infinity-context
./setup-working-directory.sh
# Wait 2-3 minutes...
# ✅ Done!
```

## Start Both Services

### Terminal 1: Backend API
```bash
cd work/ae-infinity-api/src/AeInfinity.Api
dotnet run
```
→ API: http://localhost:5233  
→ Swagger: http://localhost:5233/

### Terminal 2: Frontend UI
```bash
cd work/ae-infinity-ui
npm run dev
```
→ UI: http://localhost:5173

## Test Login

Open http://localhost:5173 and login:
- **Email**: sarah@example.com
- **Password**: Password123!

## Quick Development Workflow

### 1. Load Context
```bash
# Understand what you're building
cat work/ae-infinity-context/PROJECT_SPEC.md
cat work/ae-infinity-context/API_SPEC.md
```

### 2. Make Changes

**Backend:**
```bash
cd work/ae-infinity-api
# Edit files in src/
```

**Frontend:**
```bash
cd work/ae-infinity-ui
# Edit files in src/
```

### 3. Test Changes

**Backend auto-reloads on save** (with `dotnet watch run`)

**Frontend auto-reloads on save** (Vite HMR)

### 4. Verify

```bash
# Build backend
cd work/ae-infinity-api
dotnet build

# Build frontend
cd work/ae-infinity-ui
npm run build
```

### 5. Review & Commit (in working directory)

```bash
cd work/ae-infinity-api
git status
git diff
git add .
git commit -m "feat: your changes"
```

### 6. Cleanup When Done

```bash
cd ae-infinity-context
rm -rf work/
```

## Common Tasks

### View API Documentation
http://localhost:5233/ (Swagger UI)

### Check API Health
```bash
curl http://localhost:5233/api/health
```

### Test Authentication
```bash
curl -X POST http://localhost:5233/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah@example.com","password":"Password123!"}'
```

### View Database (in-memory)
Use Swagger UI to query endpoints and see data

### Debug Backend
- Use Visual Studio, VS Code, or Rider
- Attach to process or use F5 to debug

### Debug Frontend
- Use browser DevTools
- React DevTools extension
- VS Code debugger

## Project Structure Quick Reference

### Backend (ae-infinity-api)
```
src/
├── AeInfinity.Domain/         # Entities, no dependencies
├── AeInfinity.Application/    # Use cases, CQRS handlers
├── AeInfinity.Infrastructure/ # DB, services
└── AeInfinity.Api/           # Controllers, HTTP
```

### Frontend (ae-infinity-ui)
```
src/
├── components/  # Reusable UI components
├── pages/       # Route-level pages
├── services/    # API calls
├── hooks/       # Custom React hooks
├── contexts/    # Global state
└── types/       # TypeScript definitions
```

### Context (ae-infinity-context)
```
├── PROJECT_SPEC.md        # Requirements
├── API_SPEC.md           # API contracts
├── ARCHITECTURE.md       # System design
├── personas/             # User personas
├── journeys/             # User workflows
└── schemas/              # JSON schemas
```

## Keyboard Shortcuts (VS Code)

- **Ctrl/Cmd + `** - Toggle terminal
- **Ctrl/Cmd + B** - Toggle sidebar
- **Ctrl/Cmd + P** - Quick file open
- **Ctrl/Cmd + Shift + F** - Search across files
- **F5** - Start debugging
- **Ctrl/Cmd + Shift + B** - Build

## Hot Tips

### Tip 1: Use Watch Mode
```bash
# Backend: auto-rebuild on changes
cd work/ae-infinity-api/src/AeInfinity.Api
dotnet watch run

# Frontend: already in watch mode
cd work/ae-infinity-ui
npm run dev
```

### Tip 2: Multiple Workspaces
```bash
# Feature branch
./setup-working-directory.sh feature-stats

# Bug fix
./setup-working-directory.sh bugfix-auth
```

### Tip 3: Quick Context Switching
```bash
# Use shell aliases
alias api='cd work/ae-infinity-api'
alias ui='cd work/ae-infinity-ui'
alias docs='cd work/ae-infinity-context'
```

### Tip 4: Save Your Work
```bash
# Create a patch before cleanup
cd work/ae-infinity-api
git diff > ~/my-changes.patch

# Apply later
git apply ~/my-changes.patch
```

### Tip 5: Test Credentials
Keep these handy:
- sarah@example.com / Password123! (Owner)
- alex@example.com / Password123! (Editor)
- mike@example.com / Password123! (Editor)

## Troubleshooting

### API Won't Start
```bash
# Check .NET version
dotnet --version  # Should be 9.0+

# Clear and rebuild
dotnet clean
dotnet restore
dotnet build
```

### UI Won't Start
```bash
# Clear cache
rm -rf node_modules/ package-lock.json
npm install

# Clear Vite cache
rm -rf node_modules/.vite
npm run dev
```

### Port Already in Use
```bash
# Find what's using port 5233
lsof -i :5233

# Kill it
kill -9 <PID>

# Or change port in appsettings.json
```

### CORS Issues
API has CORS enabled for localhost:5173 by default. If using different port:
- Update `appsettings.Development.json`
- Add your UI port to AllowedOrigins

## Next Steps

### Learn More
- Read `WORKING_DIRECTORY_GUIDE.md` for full docs
- Review `REPOSITORY_ANALYSIS.md` for architecture
- Check `API_SPEC.md` for all endpoints

### Extend Your Setup
- Add VS Code launch configurations
- Create shell aliases
- Set up Docker containers
- Configure debugger

### Start Building
- Pick a feature from PROJECT_SPEC.md
- Read relevant specs from context repo
- Implement in working directory
- Test thoroughly
- Review and merge to main repos

## Help

For detailed guidance:
- **Full Setup**: `WORKING_DIRECTORY_GUIDE.md`
- **Context Loading**: Use `/load-context` command
- **Verification**: Use `/verify-specs` command
- **Cleanup**: Use `/workspace-clean` command

---

**You're all set! Happy coding! 🚀**

