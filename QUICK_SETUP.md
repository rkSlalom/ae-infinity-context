# Quick Setup Reference

**One-command setup for agentic development**

## 🚀 TL;DR

```bash
cd ae-infinity-context
./scripts/setup-working-directory.sh
```

Wait 2-3 minutes. Done! ✅

---

## 📦 What You Get

```
work/
├── ae-infinity-api/      ✅ Built & ready
├── ae-infinity-ui/       ✅ Dependencies installed
└── ae-infinity-context/  ✅ Docs ready
```

---

## ▶️ Start Development

```bash
# Terminal 1 - API
cd work/ae-infinity-api/src/AeInfinity.Api && dotnet run

# Terminal 2 - UI  
cd work/ae-infinity-ui && npm run dev
```

**API**: http://localhost:5233  
**UI**: http://localhost:5173  
**Swagger**: http://localhost:5233/

---

## 🔐 Login

| Email | Password |
|-------|----------|
| sarah@example.com | Password123! |
| alex@example.com | Password123! |
| mike@example.com | Password123! |

---

## 🧹 Cleanup

```bash
rm -rf work/
```

---

## 📚 Full Documentation

See [WORKING_DIRECTORY_GUIDE.md](./WORKING_DIRECTORY_GUIDE.md) for:
- Prerequisites
- Troubleshooting
- Advanced usage
- Agentic patterns
- Security considerations

---

## ⚙️ Custom Directory

```bash
./scripts/setup-working-directory.sh my-workspace
./scripts/setup-working-directory.sh /tmp/dev-$(date +%Y%m%d)
```

---

## ❓ Help

```bash
./scripts/setup-working-directory.sh --help
```

---

**That's it! Start coding! 🎉**

