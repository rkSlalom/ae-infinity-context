# Quick Start - Working Directory Setup

Get a complete workspace in under 2 minutes!

## One-Command Setup

```bash
# Clone context repo (if not already done)
git clone https://github.com/rkSlalom/ae-infinity-context.git
cd ae-infinity-context/scripts

# Create your workspace
./setup-working-directory.sh ~/my-workspace
```

That's it! You now have all three repos cloned and configured.

## What You Get

✅ **ae-infinity-context** - All specs and docs  
✅ **ae-infinity-api** - .NET backend (with dependencies)  
✅ **ae-infinity-ui** - React frontend (with dependencies)  
✅ **Configuration files** - Ready to run  
✅ **Health checks** - Verified setup  

## Start Coding in 3 Steps

### 1. Start the Backend
```bash
cd ~/my-workspace/ae-infinity-api/src/AeInfinity.Api
dotnet run
```
Backend at: http://localhost:5233

### 2. Start the Frontend
```bash
cd ~/my-workspace/ae-infinity-ui
npm run dev
```
Frontend at: http://localhost:5173

### 3. Login
```
Email: sarah@example.com
Password: Password123!
```

## Common Options

```bash
# Skip dependencies (faster, for code reading only)
./setup-working-directory.sh --skip-deps ~/workspace

# Use different branch
./setup-working-directory.sh --branch feature/new-auth ~/workspace

# Verbose output (for debugging)
./setup-working-directory.sh --verbose ~/workspace

# Get help
./setup-working-directory.sh --help
```

## For AI Agents

```bash
# 1. Create isolated workspace
./setup-working-directory.sh ~/agent-workspace-$(date +%Y%m%d-%H%M%S)

# 2. Read specs
cd ~/agent-workspace-*/ae-infinity-context
# Load PROJECT_SPEC.md, API_SPEC.md, etc.

# 3. Implement changes
cd ../ae-infinity-api  # or ../ae-infinity-ui

# 4. Test changes
# ... run tests, start servers, etc.

# 5. Push when ready
git add .
git commit -m "feat: your feature"
git push origin your-branch
```

## Troubleshooting

### Missing Prerequisites?
Install:
- Git: https://git-scm.com/
- Node.js: https://nodejs.org/
- .NET SDK: https://dotnet.microsoft.com/download/dotnet/9.0

### Clone Failed?
Check internet and git config:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Dependencies Failed?
Try manual install:
```bash
# UI
cd ~/workspace/ae-infinity-ui
rm -rf node_modules
npm install

# API
cd ~/workspace/ae-infinity-api
dotnet clean
dotnet restore
```

## Need More Info?

- Full documentation: [README.md](./README.md)
- Architecture pattern: [../docs/WORKING_DIRECTORY_PATTERN.md](../docs/WORKING_DIRECTORY_PATTERN.md)
- Project specs: [../PROJECT_SPEC.md](../PROJECT_SPEC.md)

---

**Happy coding!** 🚀

