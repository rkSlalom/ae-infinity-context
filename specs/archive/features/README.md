# Features Directory

**Organization**: Feature-Driven Documentation  
**Last Updated**: November 3, 2025

---

## Overview

This directory contains detailed documentation for each feature domain in the AE Infinity application. Each feature area has its own subdirectory with comprehensive specs, implementation details, and integration steps.

---

## Feature Domains

### 🔐 [Authentication](./authentication/)
User authentication, authorization, and profile management.

**Status**: 80% Backend, 80% Frontend, 0% Integrated  
**Key Features**: Login, Registration, Profile Management, JWT Tokens  
**Priority**: High - Needed for all other features

---

### 📋 [Lists](./lists/)
Shopping list CRUD operations and management.

**Status**: 100% Backend, 70% Frontend, 0% Integrated  
**Key Features**: Create, Read, Update, Delete, Archive, Filter, Sort  
**Priority**: High - Core functionality

---

### 🛒 [Items](./items/)
Shopping item management within lists.

**Status**: 90% Backend, 70% Frontend, 0% Integrated  
**Key Features**: Add, Edit, Delete, Mark Purchased, Reorder, Categories, Notes  
**Priority**: High - Core functionality

---

### 👥 [Collaboration](./collaboration/)
List sharing, permissions, and collaborator management.

**Status**: 90% Backend, 70% Frontend, 0% Integrated  
**Key Features**: Share Lists, Manage Collaborators, Permissions, Invitations  
**Priority**: High - Key differentiator

---

### 🏷️ [Categories](./categories/)
Item categorization with default and custom categories.

**Status**: 100% Backend, 100% Frontend Service, 0% Integrated  
**Key Features**: Default Categories, Custom Categories  
**Priority**: Medium - Enhances organization

---

### 🔍 [Search](./search/)
Global search across lists and items.

**Status**: 100% Backend, 100% Frontend Service, 0% UI  
**Key Features**: Search Lists, Search Items, Search All  
**Priority**: Medium - Improves discoverability

---

### 🔄 [Real-time](./realtime/)
Live updates using SignalR.

**Status**: 0% Backend, Types Only Frontend, 0% Integrated  
**Key Features**: Live Item Updates, Presence Indicators, Real-time Sync  
**Priority**: Medium - Enhances collaboration UX

---

### 🎨 [UI Components](./ui-components/)
Reusable UI component library (aspirational).

**Status**: 10% - Only LoadingSpinner and Layouts  
**Current**: Using native HTML + Tailwind CSS  
**Priority**: Low - Optional enhancement

---

### 🔧 [Infrastructure](./infrastructure/)
Cross-cutting concerns (CORS, logging, monitoring, etc.).

**Status**: Partial - Basic setup only  
**Priority**: Medium - Needed for production

---

## How to Use This Directory

### For Developers

1. **Starting a new feature?**
   - Read the feature's README
   - Check API specification links
   - Review data models
   - Follow integration steps

2. **Need to integrate frontend/backend?**
   - Look at "Integration Steps" section
   - Check status indicators
   - Follow code examples

3. **Want to see what's done?**
   - Status indicators show progress
   - ✅ = Complete
   - 🟡 = Partial/Mock Data
   - ❌ = Not Started

### For Product/Design

1. **Planning new features?**
   - Check related features
   - Review user stories
   - See what's already built

2. **Need to update requirements?**
   - Update feature README
   - Update main spec docs
   - Link related features

---

## Feature Dependency Map

```
Authentication (foundational)
    ├── Lists
    │   ├── Items
    │   │   ├── Categories
    │   │   └── Search
    │   └── Collaboration
    │       └── Real-time
    └── Profile Management
```

### Dependencies

- **Authentication** - Required for everything
- **Lists** - Required for Items and Collaboration
- **Items** - Depends on Lists and Categories
- **Collaboration** - Depends on Lists
- **Real-time** - Depends on Lists, Items, Collaboration
- **Search** - Depends on Lists and Items
- **Categories** - Independent (can be used with Items)

---

## Quick Reference

### Backend Complete (100%)
- [Categories](./categories/)

### Backend Mostly Done (80-90%)
- [Authentication](./authentication/) - Missing registration, password reset
- [Lists](./lists/) - Complete
- [Items](./items/) - Missing image upload
- [Collaboration](./collaboration/) - Missing invite acceptance

### Backend Not Started (0%)
- [Real-time](./realtime/)

### Frontend Services Ready
- All feature domains have services implemented ✅
- Just need to replace mock data with real API calls

### Frontend UI Complete
- Most pages are built with mock data 🟡
- Need integration with backend APIs

---

## Next Steps by Priority

### Priority 1: Backend Integration (This Week)
1. Start backend API
2. Update AuthContext to use real API
3. Replace mock data in all pages
4. Test end-to-end flows

### Priority 2: Complete Missing Endpoints (Next Week)
1. Registration endpoint
2. Accept invite endpoint
3. Password reset flow
4. Image upload (optional)

### Priority 3: Real-time Features (Week 3-4)
1. SignalR hub implementation
2. Frontend SignalR integration
3. Live updates
4. Presence indicators

---

## Related Documentation

**Note**: This directory has been archived. Active feature specifications now follow SDD methodology in `../../active/`.

- [FEATURES.md](../../../docs/project/FEATURES.md) - Master feature tracker
- [API_SPEC.md](../../../docs/api/API_SPEC.md) - Complete API specification
- [ARCHITECTURE.md](../../../docs/project/ARCHITECTURE.md) - System architecture
- [README.md](../../../README.md) - Context repo guide
- [Active Specs](../../active/) - Current SDD-compliant specifications

---

## Contributing

When updating feature documentation:

1. **Update the feature's README** with new details
2. **Update FEATURES.md** tracker with status changes
3. **Update ARCHITECTURE.md** if structure changes
4. **Commit with clear message**: `docs: Update [feature] status`

---

**Remember**: Each feature directory is self-contained with everything you need to know about that feature domain!

