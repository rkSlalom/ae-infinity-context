# 🚀 AE Infinity - Azure Deployment Guide

Choose your deployment strategy for the AE Infinity collaborative shopping list application.

---

## 📋 Quick Comparison

| Feature | **Docker + Container Apps** ⭐ | App Service + Static Web App |
|---------|-------------------------------|------------------------------|
| **Portability** | ✅ Run anywhere | ❌ Azure-specific |
| **Scaling** | ✅ Scale to zero, auto-scale | ✅ Auto-scale (min 1 instance) |
| **Cost** | 💰 $5-50/month (pay per use) | 💰 $10-40/month |
| **Setup Time** | ⏱️ 20 minutes | ⏱️ 15 minutes |
| **Complexity** | 🔧 Medium | 🔧 Low |
| **Modern** | ✅ Cutting edge | ✅ Traditional |
| **Best For** | Production, microservices | Simple web apps |

**🎯 Recommended**: Docker + Container Apps (more modern and portable)

---

## 🐳 Option 1: Docker + Azure Container Apps (Recommended)

### ✨ Advantages

- **More portable** - Docker images run anywhere
- **Better scaling** - Scale to zero, save costs
- **Modern architecture** - Container-native platform
- **Production-ready** - Built-in load balancing, SSL, monitoring

### 📦 What Gets Deployed

```
┌─────────────────────────────────┐
│ Azure Container Apps Environment│
│  ┌────────────┐  ┌────────────┐ │
│  │  Frontend  │  │  Backend   │ │
│  │  (Nginx)   │──│  (.NET 8)  │ │
│  └────────────┘  └──────┬─────┘ │
└──────────────────────────┼───────┘
                           │
                     Azure SQL DB
```

### 🚀 Quick Start

```bash
# 1. Prerequisites
brew install azure-cli docker
open -a Docker
az login

# 2. Test locally (optional)
docker-compose up --build

# 3. Deploy to Azure
cd ae-infinity-api/deployment
./azure-container-setup.sh       # Create resources
./build-and-push.sh              # Build images
./deploy-containers.sh           # Deploy

# Done! 🎉
```

### 📖 Full Documentation

See **[DOCKER_QUICK_START.md](./DOCKER_QUICK_START.md)** for step-by-step guide.

See **[ae-infinity-api/deployment/DOCKER_DEPLOYMENT.md](./ae-infinity-api/deployment/DOCKER_DEPLOYMENT.md)** for complete documentation.

---

## 🌐 Option 2: App Service + Static Web App (Simpler)

### ✨ Advantages

- **Simpler setup** - Less moving parts
- **Familiar** - Traditional PaaS approach
- **Easy management** - Azure Portal GUI

### 📦 What Gets Deployed

```
┌─────────────────┐     ┌─────────────────┐
│ Static Web App  │────→│  App Service    │
│   (Frontend)    │     │   (Backend)     │
└─────────────────┘     └────────┬────────┘
                                 │
                           Azure SQL DB
```

### 🚀 Quick Start

```bash
# 1. Prerequisites
brew install azure-cli
az login

# 2. Deploy
cd ae-infinity-api/deployment
./azure-setup.sh          # Create resources
./deploy-backend.sh       # Deploy API
./deploy-frontend.sh      # Deploy UI

# Done! 🎉
```

### 📖 Full Documentation

See **[ae-infinity-api/deployment/QUICK_START.md](./ae-infinity-api/deployment/QUICK_START.md)**.

See **[ae-infinity-api/deployment/README.md](./ae-infinity-api/deployment/README.md)** for complete guide.

---

## 🤔 Which Should I Choose?

### Choose **Docker + Container Apps** if you:

- ✅ Want modern, cloud-native architecture
- ✅ Need portability (can move to other clouds)
- ✅ Want to scale to zero (save costs in dev)
- ✅ Plan to use microservices later
- ✅ Are comfortable with Docker
- ✅ Want the best long-term solution

### Choose **App Service + Static Web App** if you:

- ✅ Want the simplest setup
- ✅ Prefer traditional PaaS
- ✅ Don't need Docker portability
- ✅ Want familiar Azure services
- ✅ Need to deploy quickly

---

## 💰 Cost Comparison

### Development Environment

| Option | Monthly Cost |
|--------|-------------|
| **Docker + Container Apps** | $5-10 (can scale to zero) |
| **App Service + Static Web** | $10-15 (always running) |

### Production Environment

| Option | Monthly Cost |
|--------|-------------|
| **Docker + Container Apps** | $30-50 |
| **App Service + Static Web** | $28-40 |

*Both include Azure SQL Database (~$15/month)*

---

## 🎯 Recommended Path

For most users, we recommend **Docker + Container Apps**:

1. **Better long-term** - More flexible and portable
2. **Cost-effective** - Scale to zero in dev
3. **Modern** - Industry standard approach
4. **Skills** - Docker knowledge is valuable

### Quick Commands

```bash
# Local testing
docker-compose up --build          # Test locally
docker-compose down               # Stop

# Azure deployment
cd ae-infinity-api/deployment
./azure-container-setup.sh        # One-time setup
./build-and-push.sh              # Build images
./deploy-containers.sh           # Deploy
./update-deployment.sh           # Future updates
```

---

## 📁 Deployment Files Created

```
AE-Immersion-Workshop/
├── docker-compose.yml                    # Local testing
├── DOCKER_QUICK_START.md                # Quick guide
├── DEPLOYMENT_GUIDE.md                  # This file
│
├── ae-infinity-api/
│   ├── Dockerfile                       # Backend container
│   ├── .dockerignore
│   └── deployment/
│       ├── DOCKER_DEPLOYMENT.md         # Full Docker guide
│       ├── azure-container-setup.sh     # Create resources
│       ├── build-and-push.sh           # Build images
│       ├── deploy-containers.sh        # Deploy to Azure
│       ├── update-deployment.sh        # Update deployment
│       │
│       ├── README.md                    # App Service guide
│       ├── QUICK_START.md              # App Service quick
│       ├── azure-setup.sh              # App Service resources
│       ├── deploy-backend.sh           # App Service deploy
│       └── deploy-frontend.sh          # Static Web App deploy
│
└── ae-infinity-ui/
    ├── Dockerfile                       # Frontend container
    ├── nginx.conf                       # Nginx config
    └── .dockerignore
```

---

## 🚀 Get Started Now

### For Docker + Container Apps (Recommended):

```bash
# Read quick start first
open DOCKER_QUICK_START.md

# Then deploy
cd ae-infinity-api/deployment
./azure-container-setup.sh
```

### For App Service:

```bash
# Read quick start first
open ae-infinity-api/deployment/QUICK_START.md

# Then deploy
cd ae-infinity-api/deployment
./azure-setup.sh
```

---

## 🆘 Need Help?

### Docker + Container Apps
- Quick Start: `DOCKER_QUICK_START.md`
- Full Guide: `ae-infinity-api/deployment/DOCKER_DEPLOYMENT.md`
- Test locally: `docker-compose up`

### App Service
- Quick Start: `ae-infinity-api/deployment/QUICK_START.md`
- Full Guide: `ae-infinity-api/deployment/README.md`
- Checklist: `ae-infinity-api/deployment/DEPLOYMENT_CHECKLIST.md`

### Common Issues

**Docker not working**: Make sure Docker Desktop is running  
**Azure login fails**: Run `az login` and select correct subscription  
**Port already in use**: Kill existing processes or change ports  
**Database connection fails**: Check firewall rules and connection string  

---

## 🎓 What You'll Learn

By completing this deployment, you'll learn:

✅ Docker containerization  
✅ Azure Container Registry  
✅ Azure Container Apps  
✅ Azure SQL Database  
✅ Infrastructure as Code  
✅ CI/CD concepts  
✅ Cloud deployment strategies  
✅ Monitoring and logging  

---

## 🎉 Ready?

Choose your path and get started:

- **Modern & Portable**: Follow `DOCKER_QUICK_START.md`
- **Simple & Fast**: Follow `ae-infinity-api/deployment/QUICK_START.md`

Both paths will get your app running on Azure in ~20 minutes!

**Happy Deploying! 🚀**

