# AE Infinity - Collaborative Shopping List Application

A real-time collaborative shopping list application that enables multiple users to create, share, and manage shopping lists together.

## 📋 Project Documentation

This project follows a spec-driven development approach optimized for LLM-assisted development and agentic workflows. All specifications are comprehensive and designed to provide complete context for development.

### Core Specification Documents

- **[PROJECT_SPEC.md](./PROJECT_SPEC.md)** - Complete project requirements, features, user roles, and development phases
- **[USER_PERSONAS.md](./USER_PERSONAS.md)** - User personas, permission tiers, and user journey examples
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture, data models, technology stack, and design patterns
- **[API_SPEC.md](./API_SPEC.md)** - Detailed REST API specification with all endpoints, requests, and responses
- **[COMPONENT_SPEC.md](./COMPONENT_SPEC.md)** - Frontend component specifications, design system, and UI patterns
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - Development workflow, coding standards, testing, and deployment

## 🏗️ Architecture Overview

### Technology Stack

**Frontend**:
- React 19 with TypeScript
- Vite (build tool)
- SignalR Client (real-time communication)
- React Context / React Query (state management)

**Backend**:
- .NET 8 Web API
- Entity Framework Core
- SignalR (real-time hub)
- SQL Server / PostgreSQL
- Redis (caching)

## 🚀 Getting Started

### Prerequisites

- Node.js 20+ and npm
- .NET 8 SDK
- SQL Server or PostgreSQL
- Redis (optional, for caching)

### Quick Start

#### Frontend Setup

```bash
cd ae-infinity-ui
npm install
npm run dev
```

The app will be available at `http://localhost:3000`

#### Backend Setup

```bash
cd AeInfinity.Api
dotnet restore
dotnet ef database update
dotnet run
```

The API will be available at `http://localhost:5000`

For detailed setup instructions, see [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md).

## 📦 Project Structure

```
ae-infinity/
├── ae-infinity-ui/          # React frontend application
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   ├── pages/           # Page-level components
│   │   ├── hooks/           # Custom React hooks
│   │   ├── services/        # API clients and business logic
│   │   ├── context/         # React Context providers
│   │   ├── types/           # TypeScript type definitions
│   │   └── utils/           # Helper functions
│   └── public/              # Static assets
│
├── AeInfinity.Api/          # .NET Web API
├── AeInfinity.Core/         # Domain models and interfaces
├── AeInfinity.Application/  # Business logic and services
├── AeInfinity.Infrastructure/ # Data access and external services
│
├── PROJECT_SPEC.md          # Project requirements and features
├── ARCHITECTURE.md          # Architecture documentation
├── API_SPEC.md             # API specification
├── COMPONENT_SPEC.md       # Component specifications
└── DEVELOPMENT_GUIDE.md    # Development guide
```

## ✨ Core Features

- **User Authentication** - Secure registration and login with JWT tokens
- **List Management** - Create, edit, and organize shopping lists
- **Real-time Collaboration** - See updates from collaborators instantly
- **Item Management** - Add, edit, and mark items as purchased
- **Sharing & Permissions** - Share lists with custom permission levels
- **Categories** - Organize items by customizable categories
- **Offline Support** - Work offline with automatic sync when online
- **Responsive Design** - Mobile-first, works on all devices

## 🧪 Testing

### Frontend Tests

```bash
cd ae-infinity-ui
npm test                  # Run tests
npm test -- --coverage    # Run tests with coverage
```

### Backend Tests

```bash
cd AeInfinity.Tests
dotnet test
dotnet test /p:CollectCoverage=true
```

## 📖 Development Workflow

1. **Review Specifications** - Start with the relevant spec document (PROJECT_SPEC.md, API_SPEC.md, or COMPONENT_SPEC.md)
2. **Create Feature Branch** - Branch from `develop` for new features
3. **Write Tests First** - Follow TDD approach
4. **Implement Feature** - Follow coding standards in DEVELOPMENT_GUIDE.md
5. **Run Tests** - Ensure all tests pass
6. **Create Pull Request** - Submit for review
7. **Deploy** - Merge to `develop`, then to `main` for production

See [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) for detailed workflow and coding standards.

## 🔒 Security

- JWT-based authentication
- Role-based access control
- HTTPS enforcement
- Input validation and sanitization
- SQL injection prevention
- XSS protection
- Rate limiting

## 📊 API Documentation

The complete API specification is available in [API_SPEC.md](./API_SPEC.md), including:

- Authentication endpoints
- Shopping list CRUD operations
- Item management
- Collaboration and sharing
- Real-time SignalR events
- Error handling and responses

## 🎨 Component Library

All UI components are documented in [COMPONENT_SPEC.md](./COMPONENT_SPEC.md), including:

- Design system (colors, typography, spacing)
- Common components (Button, Input, Modal, etc.)
- Feature components (ShoppingListCard, ItemRow, etc.)
- Layout components
- Custom hooks
- Accessibility guidelines

## 🤝 Contributing

1. Read the [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
2. Follow the coding standards
3. Write tests for new features
4. Submit pull requests against `develop` branch
5. Ensure CI/CD checks pass

## 📝 License

This project is part of the AE Workshop and is for educational purposes.

## 🌟 Key Design Principles

- **Spec-Driven Development** - All features defined in specifications before implementation
- **LLM-Friendly Context** - Documentation structured for easy LLM consumption
- **Agentic Workflows** - Designed for autonomous AI-assisted development
- **Mobile-First** - Responsive design prioritizing mobile experience
- **Accessibility** - WCAG 2.1 AA compliance
- **Real-time First** - Collaborative features with instant updates
- **Offline Capable** - Progressive Web App with offline support

---

For questions or issues, please refer to the specification documents or open an issue in the repository.

