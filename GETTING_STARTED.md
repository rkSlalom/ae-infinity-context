# Getting Started with AE Infinity

**Quick Start Time**: 5-10 minutes  
**Prerequisites**: .NET 9.0, Node.js 18+, Git  
**Database**: SQLite (no separate installation needed!)

---

## 📋 Prerequisites

Before you begin, ensure you have:

- ✅ **.NET 9.0 SDK** - [Download](https://dotnet.microsoft.com/download/dotnet/9.0)
- ✅ **Node.js 18+** with npm - [Download](https://nodejs.org/)
- ✅ **Git** - [Download](https://git-scm.com/)
- ✅ **Code Editor** - VS Code recommended with C# and React extensions

**Database**: We use **SQLite** - it's embedded in .NET, no separate installation required! 🎉

---

## 🚀 Quick Start (5 Minutes)

### **Step 1: Clone Repositories**

```bash
# Create project directory
mkdir ae-infinity && cd ae-infinity

# Clone context repository (specifications)
git clone [url-to-ae-infinity-context] ae-infinity-context

# Clone backend API
git clone [url-to-ae-infinity-api] ae-infinity-api

# Clone frontend UI
git clone [url-to-ae-infinity-ui] ae-infinity-ui
```

### **Step 2: Start Backend API**

```bash
cd ae-infinity-api

# Restore dependencies
dotnet restore

# Run database migrations (creates SQLite database file)
dotnet ef database update --project AeInfinity.Infrastructure --startup-project AeInfinity.API

# Start the API
dotnet run --project AeInfinity.API

# API will run on: http://localhost:5233
# Swagger UI: http://localhost:5233/index.html
```

**What happens**:
- Creates `app.db` SQLite database file in the project root
- Applies all EF Core migrations
- Seeds test data (3 users, 5 lists, 20 items)
- Starts API server with Swagger documentation

### **Step 3: Start Frontend UI**

```bash
# In a new terminal
cd ae-infinity-ui

# Install dependencies
npm install

# Start development server
npm run dev

# UI will run on: http://localhost:5173
```

### **Step 4: Test the Application**

1. **Open** http://localhost:5173
2. **Click** "Login"
3. **Use test account**:
   - Email: `sarah@example.com`
   - Password: `Password123!`
4. **You should see** the dashboard with shopping lists!

---

## 🎓 Understanding the Project

### **Three Repositories**

| Repository | Purpose | Tech Stack |
|------------|---------|------------|
| **ae-infinity-context** | Specifications & docs | Markdown, Spec Kit |
| **ae-infinity-api** | Backend REST API | .NET 9.0, EF Core, SQLite |
| **ae-infinity-ui** | Frontend SPA | React 19.1, TypeScript, Vite |

### **Your Workflow**

```
1. Read specs    →  ae-infinity-context/specs/
2. Write code    →  ae-infinity-api/ or ae-infinity-ui/
3. Test          →  Run tests in code repositories
4. Verify        →  Check against spec requirements
```

---

## 📚 Reading Specifications

All features are documented in `ae-infinity-context/specs/`:

```bash
cd ae-infinity-context/specs

# View all features
cat README.md

# Explore Feature 001 (User Authentication)
cd 001-user-authentication/
ls -la

# Files you'll find:
# - spec.md         → Business requirements (WHAT to build)
# - plan.md         → Implementation strategy (HOW to build)
# - data-model.md   → Entity definitions and database schema
# - quickstart.md   → Step-by-step developer guide
# - tasks.md        → Checklist of implementation tasks
# - contracts/      → API JSON schemas
```

### **Reading Order for a Feature**

1. **README.md** - Quick overview (2 min read)
2. **spec.md** - User stories and requirements (10 min read)
3. **plan.md** - Technical approach (15 min read)
4. **quickstart.md** - Code examples (hands-on)
5. **data-model.md** - Deep dive into entities (reference)

---

## 🛠️ Development Setup

### **Backend Development (ae-infinity-api)**

```bash
cd ae-infinity-api

# Run tests
dotnet test

# Run with hot reload
dotnet watch run --project AeInfinity.API

# View database (SQLite)
sqlite3 app.db
> .tables
> SELECT * FROM Users;
> .quit

# Create new migration
dotnet ef migrations add MigrationName --project AeInfinity.Infrastructure --startup-project AeInfinity.API

# Apply migrations
dotnet ef database update --project AeInfinity.Infrastructure --startup-project AeInfinity.API

# Reset database (caution: deletes all data)
rm app.db
dotnet ef database update --project AeInfinity.Infrastructure --startup-project AeInfinity.API
```

### **Frontend Development (ae-infinity-ui)**

```bash
cd ae-infinity-ui

# Run tests
npm test

# Run tests with coverage
npm test -- --coverage

# Run tests in watch mode
npm test -- --watch

# Run development server with hot reload
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint

# Format code
npm run format
```

### **Database (SQLite)**

**Location**: `ae-infinity-api/app.db`

**View with SQLite CLI**:
```bash
# Install SQLite (if not already installed)
# macOS: brew install sqlite
# Windows: Download from https://www.sqlite.org/download.html

# Open database
sqlite3 ae-infinity-api/app.db

# SQLite commands
.tables                    # List all tables
.schema Users              # Show table schema
SELECT * FROM Users;       # Query data
.quit                      # Exit
```

**View with GUI Tools**:
- [DB Browser for SQLite](https://sqlitebrowser.org/) (Free, cross-platform)
- [SQLite Viewer](https://marketplace.visualstudio.com/items?itemName=qwtel.sqlite-viewer) (VS Code extension)

**Test Data** (seeded automatically):

| Email | Password | Display Name | Role |
|-------|----------|--------------|------|
| `sarah@example.com` | `Password123!` | Sarah Johnson | List Creator |
| `alex@example.com` | `Password123!` | Alex Chen | Collaborator |
| `mike@example.com` | `Password123!` | Mike Thompson | Viewer |

---

## 🧪 Running Tests

### **Backend Tests**

```bash
cd ae-infinity-api

# Run all tests
dotnet test

# Run with coverage
dotnet test /p:CollectCoverage=true

# Run specific test class
dotnet test --filter "FullyQualifiedName~LoginHandlerTests"

# Run tests in watch mode
dotnet watch test
```

### **Frontend Tests**

```bash
cd ae-infinity-ui

# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test file
npm test -- ProfilePage.test.tsx

# Run in watch mode
npm test -- --watch

# Update snapshots
npm test -- --update
```

### **Manual Testing**

1. **Start both servers** (API + UI)
2. **Test authentication**:
   - Login with test user
   - Check JWT token in localStorage
   - Access protected page (should work)
   - Logout
   - Try to access protected page (should redirect to login)
3. **Test API directly** (Swagger):
   - Open http://localhost:5233/index.html
   - Authorize with JWT token
   - Try endpoints

---

## 📖 Next Steps

### **For New Developers**

1. ✅ **Read Constitution** - [.specify/memory/constitution.md](./specify/memory/constitution.md)
   - Development principles
   - Code standards
   - Quality gates

2. ✅ **Review Feature 001** - [specs/001-user-authentication/](./specs/001-user-authentication/)
   - Example of complete specification
   - See how specs drive implementation

3. ✅ **Pick a Task** - [specs/001-user-authentication/tasks.md](./specs/001-user-authentication/tasks.md)
   - Start with unchecked tasks
   - Follow quickstart.md for guidance

4. ✅ **Join the Team** - Ask questions, request code reviews, contribute!

### **For Experienced Developers**

1. ✅ **Review Architecture** - [ARCHITECTURE.md](./ARCHITECTURE.md)
2. ✅ **Check Roadmap** - See what features are next
3. ✅ **Create Specs** - Use `/speckit.specify` for new features
4. ✅ **Mentor Others** - Help onboard new team members

---

## 🐛 Troubleshooting

### **Backend Issues**

**Problem**: "Unable to create database"
```bash
# Solution: Check write permissions
chmod +w .
rm app.db
dotnet ef database update --project AeInfinity.Infrastructure --startup-project AeInfinity.API
```

**Problem**: "Port 5233 already in use"
```bash
# Solution: Change port in launchSettings.json or kill existing process
# macOS/Linux:
lsof -i :5233
kill -9 <PID>

# Windows:
netstat -ano | findstr :5233
taskkill /PID <PID> /F
```

**Problem**: "Migration already applied"
```bash
# Solution: Reset database
rm app.db
dotnet ef database update --project AeInfinity.Infrastructure --startup-project AeInfinity.API
```

### **Frontend Issues**

**Problem**: "Module not found"
```bash
# Solution: Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

**Problem**: "API connection refused"
```bash
# Solution: Ensure backend is running
# Check: http://localhost:5233/api/health
```

**Problem**: "CORS error"
```bash
# Solution: Backend CORS is configured for localhost:5173
# If you changed frontend port, update CORS in Program.cs
```

### **Database Issues**

**Problem**: "Database is locked"
```bash
# Solution: Close all connections
# Stop backend
# Delete app.db-shm and app.db-wal files
rm app.db-shm app.db-wal
# Restart backend
```

**Problem**: "Cannot see test data"
```bash
# Solution: Check if seeding ran
sqlite3 app.db "SELECT COUNT(*) FROM Users;"
# Should return: 3

# If 0, manually seed:
dotnet run --project AeInfinity.API -- --seed
```

---

## 💡 Pro Tips

### **SQLite**
- 💾 Database is just a file: `app.db`
- 🔄 Easy to reset: `rm app.db` then run migrations
- 📦 No server needed - perfect for development
- 🚀 Fast for < 100k records
- ⚠️ Single writer at a time (fine for development/small production)

### **Development**
- 🔥 Use `dotnet watch` and `npm run dev` for hot reload
- 🧪 Write tests first (TDD approach per constitution)
- 📝 Update specs when requirements change
- 🔍 Use Swagger for API exploration
- 🎨 Use React DevTools for debugging components

### **VS Code Extensions**
- C# (Microsoft)
- ES7+ React/Redux/React-Native snippets
- Tailwind CSS IntelliSense
- SQLite Viewer
- REST Client (test APIs without Postman)

---

## 🎯 Success Criteria

You're ready to develop when you can:

- [x] Start backend API successfully (see Swagger at :5233)
- [x] Start frontend UI successfully (see app at :5173)
- [x] Login with test user `sarah@example.com`
- [x] View shopping lists in the dashboard
- [x] Open SQLite database and see test data
- [x] Run backend tests (all passing)
- [x] Run frontend tests (all passing)
- [x] Read and understand Feature 001 spec

**Time to complete**: ~5-10 minutes

**If stuck**: Check [Troubleshooting](#-troubleshooting) or ask the team!

---

## 📞 Need Help?

- 📖 **Documentation**: Check `ae-infinity-context/specs/`
- 🏛️ **Architecture**: See [ARCHITECTURE.md](./ARCHITECTURE.md)
- 📜 **Standards**: Read [Constitution](./.specify/memory/constitution.md)
- 🤝 **Contributing**: See [CONTRIBUTING.md](./CONTRIBUTING.md)
- 💬 **Questions**: Ask in team chat or create an issue

**Welcome to AE Infinity!** 🚀 Happy coding!

