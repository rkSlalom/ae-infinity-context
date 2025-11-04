# 🐳 Docker Deployment - Quick Start

Deploy AE Infinity to Azure using Docker containers in **~20 minutes**.

## ⚡ Prerequisites (5 minutes)

```bash
# 1. Install tools
brew install azure-cli
brew install --cask docker

# 2. Start Docker Desktop
open -a Docker

# 3. Login to Azure
az login
az account set --subscription "Your-Subscription-Name"
```

---

## 🧪 Test Locally First (Optional but Recommended)

```bash
# Start everything with Docker Compose
docker-compose up --build

# Access:
# Frontend: http://localhost:3000
# Backend: http://localhost:8080/swagger
# Database: localhost:1433

# Stop:
docker-compose down
```

---

## 🚀 Deploy to Azure (4 Steps)

### 1️⃣ Create Azure Resources (~10 min)

```bash
cd ae-infinity-api/deployment
./azure-container-setup.sh
```

**⚠️ SAVE THE OUTPUT** - Contains database password and credentials!

### 2️⃣ Update Database Configuration (~2 min)

Add SQL Server package:
```bash
cd ../src/AeInfinity.Infrastructure
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
```

Edit `DependencyInjection.cs`:
```csharp
// Change from:
options.UseSqlite("DataSource=:memory:")

// To:
options.UseSqlServer(
    configuration.GetConnectionString("DefaultConnection"),
    b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName))
```

### 3️⃣ Build and Push Images (~5-10 min)

```bash
cd ../../deployment
./build-and-push.sh
```

### 4️⃣ Deploy Containers (~5 min)

```bash
./deploy-containers.sh
```

---

## ✅ Test Your Deployment

```bash
# Get your URLs
source azure-config.env
echo "Frontend: $WEB_URL"
echo "Backend: $API_URL"

# Test API
curl https://$API_FQDN/health

# Open in browser
open $WEB_URL
```

---

## 🎉 Done!

Your app is now running on Azure Container Apps!

- **Frontend**: https://web-ae-infinity.{region}.azurecontainerapps.io
- **Backend**: https://api-ae-infinity.{region}.azurecontainerapps.io

---

## 🔄 Update Deployment

After making code changes:

```bash
cd ae-infinity-api/deployment
./update-deployment.sh
```

This rebuilds and redeploys both containers.

---

## 📊 Monitor Your App

```bash
# View real-time logs
az containerapp logs show -n api-ae-infinity -g rg-ae-infinity-containers --follow

# Check status
az containerapp show -n api-ae-infinity -g rg-ae-infinity-containers
```

---

## 💰 Cost Management

**Development** (~$5-10/month):
- Scale to zero when not in use
- Use smallest instance sizes

**Production** (~$30-50/month):
- Always-on with multiple replicas
- Larger instances

### Scale to Zero (Save $$$)

```bash
# Stop containers
az containerapp update -n api-ae-infinity -g rg-ae-infinity-containers --min-replicas 0
az containerapp update -n web-ae-infinity -g rg-ae-infinity-containers --min-replicas 0

# Pause database
az sql db pause --name ae-infinity-db --server <sql-server> -g rg-ae-infinity-containers
```

---

## 🗑️ Cleanup

Delete everything:

```bash
az group delete --name rg-ae-infinity-containers --yes
```

⚠️ This deletes ALL resources and data!

---

## 🆘 Troubleshooting

### Docker not running
```bash
# Start Docker Desktop
open -a Docker
```

### Build fails
```bash
# Check Docker is running
docker info

# Clear build cache
docker system prune -a
```

### Deployment fails
```bash
# Check logs
az containerapp logs show -n api-ae-infinity -g rg-ae-infinity-containers --tail 100

# Check registry
az acr repository list --name <acr-name>
```

### Can't access app
```bash
# Check ingress configuration
az containerapp ingress show -n api-ae-infinity -g rg-ae-infinity-containers

# Verify URL
az containerapp show -n api-ae-infinity -g rg-ae-infinity-containers --query "properties.configuration.ingress.fqdn"
```

---

## 📚 Full Documentation

See `ae-infinity-api/deployment/DOCKER_DEPLOYMENT.md` for:
- Detailed explanations
- Advanced configuration
- Monitoring & scaling
- CI/CD setup
- Security best practices

---

## 🎯 What You Just Did

✅ Containerized both backend and frontend  
✅ Pushed images to Azure Container Registry  
✅ Deployed to Azure Container Apps  
✅ Set up auto-scaling and load balancing  
✅ Configured HTTPS and monitoring  
✅ Created a production-ready deployment  

**Your app is now:**
- ✅ Portable (runs anywhere Docker runs)
- ✅ Scalable (auto-scales based on load)
- ✅ Cost-effective (pay per use, scale to zero)
- ✅ Secure (HTTPS, managed identities)
- ✅ Observable (logs, metrics, monitoring)

---

**Next Steps:**
1. Test all features in production
2. Set up custom domain (optional)
3. Configure CI/CD with GitHub Actions
4. Add Application Insights for monitoring
5. Set up staging environment

🎉 **Congratulations on deploying to Azure Container Apps!**

