# Configuration Documentation

This directory contains configuration documentation and environment setup guides.

## 📁 Configuration Files

**Note**: This is the planned structure. Configuration details will be extracted from existing docs.

- **[environment-variables.md](./environment-variables.md)** - Environment variable reference
  - Frontend environment variables
  - Backend environment variables
  - Required vs optional
  - Default values
  - Security considerations

- **[deployment-config.md](./deployment-config.md)** - Deployment configurations
  - Development environment
  - Staging environment
  - Production environment
  - Infrastructure as Code (IaC)

- **[feature-flags.md](./feature-flags.md)** - Feature toggle system
  - Feature flag definitions
  - Toggle mechanism
  - Gradual rollout strategy
  - A/B testing configuration

## ⚙️ Environment Variables

### Frontend (.env.local)

```bash
# API Configuration
VITE_API_BASE_URL=http://localhost:5000/api/v1
VITE_SIGNALR_HUB_URL=http://localhost:5000/hubs/shopping-list

# Environment
VITE_ENVIRONMENT=development

# Feature Flags
VITE_ENABLE_LOGGING=true
VITE_ENABLE_DEV_TOOLS=true
```

### Backend (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=AeInfinity;...",
    "Redis": "localhost:6379"
  },
  "JWT": {
    "Secret": "[secure-key-here]",
    "Issuer": "ae-infinity-api",
    "Audience": "ae-infinity-ui",
    "ExpirationMinutes": 60
  },
  "SignalR": {
    "MaxBufferSize": 32768
  }
}
```

**Reference**: [../DEVELOPMENT_GUIDE.md](../DEVELOPMENT_GUIDE.md) lines 18-64

## 🌍 Environments

### Development
- **Purpose**: Local development
- **URL**: http://localhost:3000 (UI), http://localhost:5000 (API)
- **Database**: Local SQL Server / PostgreSQL
- **Cache**: Local Redis
- **Logging**: Debug level
- **Features**: All enabled

### Staging
- **Purpose**: Pre-production testing
- **URL**: https://staging.ae-infinity.com
- **Database**: Staging database (separate)
- **Cache**: Staging Redis cluster
- **Logging**: Info level
- **Features**: Match production

### Production
- **Purpose**: Live environment
- **URL**: https://ae-infinity.com
- **Database**: Production database (replicated)
- **Cache**: Production Redis cluster
- **Logging**: Warning+ level
- **Features**: Gradual rollout

**Reference**: [../ARCHITECTURE.md](../ARCHITECTURE.md) lines 403-408

## 🎚️ Feature Flags

Feature flags allow gradual rollout and A/B testing:

```typescript
interface FeatureFlags {
  enableOfflineMode: boolean;
  enableVoiceInput: boolean;
  enableRecipeIntegration: boolean;
  enablePriceTracking: boolean;
  // ... more features
}
```

**Management**:
- Toggle via admin panel
- Per-environment configuration
- User-based targeting
- Gradual percentage rollout

## 🔒 Security Configuration

### Secrets Management
- **Development**: `.env.local` (gitignored)
- **Staging/Production**: Azure Key Vault / AWS Secrets Manager
- **Never**: Commit secrets to repository

### HTTPS Configuration
- **Development**: HTTP acceptable
- **Staging/Production**: HTTPS enforced
- **Certificate**: Let's Encrypt / Commercial CA

### CORS Configuration
```csharp
// Development: Allow localhost
AllowedOrigins: ["http://localhost:3000"]

// Production: Specific domain
AllowedOrigins: ["https://ae-infinity.com"]
```

## 📊 Database Configuration

### Connection Pooling
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=...;Min Pool Size=5;Max Pool Size=100;"
  }
}
```

### Migrations
- **Development**: Auto-apply on startup
- **Staging**: Manual review + apply
- **Production**: Scheduled maintenance window

## 🚀 Deployment Configuration

### Docker Configuration
```dockerfile
# Frontend
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "preview"]
```

```dockerfile
# Backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
COPY *.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .
EXPOSE 5000
ENTRYPOINT ["dotnet", "AeInfinity.Api.dll"]
```

### Kubernetes Configuration
- Deployment manifests
- Service definitions
- Ingress rules
- ConfigMaps and Secrets
- Horizontal Pod Autoscaling

## 📈 Monitoring Configuration

### Application Insights / CloudWatch
```json
{
  "ApplicationInsights": {
    "InstrumentationKey": "[key-here]",
    "EnableAdaptiveSampling": true,
    "SamplingPercentage": 10.0
  }
}
```

### Logging Levels
- **Development**: Debug
- **Staging**: Information
- **Production**: Warning

## 🔗 Related Documentation

- **Deployment Process**: [../workflows/deployment-process.md](../workflows/deployment-process.md)
- **Development Workflow**: [../workflows/development-workflow.md](../workflows/development-workflow.md)
- **Architecture**: [../architecture/system-overview.md](../architecture/system-overview.md)

---

**Current Status**: Configuration details scattered across existing docs. Will be consolidated here in future updates.

