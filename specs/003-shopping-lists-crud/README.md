# Feature 003: Shopping Lists CRUD

**Status**: Planning Phase  
**Priority**: P1 (MVP - Core Business Value)  
**Dependencies**: 001-user-authentication  
**Branch**: feature/spec-kit-experiment (working on current branch)

---

## 📋 Quick Overview

This feature enables users to create, view, edit, delete, and archive their shopping lists. It forms the core business value of the application, allowing users to organize their shopping needs into named lists with descriptions.

**Key Capabilities**:
- Create new shopping lists with name and optional description
- View all lists (owned + shared) with filtering and sorting
- Edit list details (name, description)
- Delete lists permanently (owner only)
- Archive/unarchive lists for organization
- Search lists by name
- Pagination for large list collections
- Permission-based access control

---

## 🎯 User Value

**Problem**: Users need to organize their shopping needs into separate lists (e.g., "Weekly Groceries", "Birthday Party", "Home Supplies")

**Solution**: Create and manage multiple shopping lists with full CRUD operations and smart organization features (archive, search, sort)

**Success Metric**: Users can create and manage 10+ lists without confusion, archive completed lists, and quickly find lists via search

---

## 📊 Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Specification** | ✅ To Generate | Will be created in this planning phase |
| **Backend API** | ✅ 100% Implemented | All endpoints exist in ae-infinity-api |
| **Frontend UI** | 🟡 70% Implemented | UI exists with mock data, needs API integration |
| **Integration** | ❌ 0% | Needs frontend-backend connection |

---

## 🔗 Dependencies

### **Required**
- **Feature 001**: User Authentication - For JWT token, user identity, ownership

### **Enables**
- **Feature 004**: List Items Management - Items belong to lists
- **Feature 008**: Invitations & Permissions - Sharing lists requires lists

---

## 📁 Documentation

- **[spec.md](./spec.md)** - Business requirements (to be generated)
- **[plan.md](./plan.md)** - Implementation strategy (this planning phase)
- **[data-model.md](./data-model.md)** - Entity definitions (to be generated)
- **[quickstart.md](./quickstart.md)** - Developer guide (to be generated)
- **[tasks.md](./tasks.md)** - Implementation checklist (to be generated)
- **[contracts/](./contracts/)** - API JSON schemas (to be generated)

---

## 🚀 Expected Endpoints

| Endpoint | Method | Description | Status |
|----------|--------|-------------|--------|
| `/lists` | GET | Get all lists (with filters) | ✅ Exists |
| `/lists` | POST | Create new list | ✅ Exists |
| `/lists/{listId}` | GET | Get list details | ✅ Exists |
| `/lists/{listId}` | PUT | Update list | ✅ Exists |
| `/lists/{listId}` | DELETE | Delete list | ✅ Exists |
| `/lists/{listId}/archive` | POST | Archive list | ✅ Exists |
| `/lists/{listId}/unarchive` | POST | Unarchive list | ✅ Exists |

---

## 🎨 UI Components

| Component | Location | Status |
|-----------|----------|--------|
| Lists Dashboard | `ae-infinity-ui/src/pages/lists/ListsDashboard.tsx` | 🟡 Mock Data |
| List Detail | `ae-infinity-ui/src/pages/lists/ListDetail.tsx` | 🟡 Mock Data |
| Create List | `ae-infinity-ui/src/pages/lists/CreateList.tsx` | 🟡 Mock Data |
| List Settings | `ae-infinity-ui/src/pages/lists/ListSettings.tsx` | 🟡 Mock Data |
| Archived Lists | `ae-infinity-ui/src/pages/ArchivedLists.tsx` | ✅ Complete |

---

## ⏱️ Estimated Effort

| Phase | Effort | Description |
|-------|--------|-------------|
| **Specification** | 2-3 hours | Generate spec, contracts, data model |
| **Backend Verification** | 1-2 hours | Verify existing API matches spec |
| **Frontend Integration** | 8-12 hours | Connect UI to real API, replace mocks |
| **Testing** | 4-6 hours | Integration tests, E2E tests |
| **Total** | **2-3 days** | MVP list management complete |

---

## 🔍 Consolidating From

This feature consolidates the following old documents:

- `old_documents/API_SPEC.md` - List endpoints (lines 145-350)
- `old_documents/schemas/list.json` - List DTO schema
- `old_documents/schemas/list-basic.json` - List summary schema
- `old_documents/schemas/list-detail.json` - Detailed list schema
- `old_documents/FEATURES.md` - List requirements (lines 36-51)
- `old_documents/features/lists/README.md` - Feature description

---

## 🎯 Next Steps

1. ✅ Generate `spec.md` - Business requirements and user stories
2. ✅ Generate `plan.md` - Implementation strategy
3. ✅ Generate `data-model.md` - Entity and DTO definitions
4. ✅ Generate `contracts/` - JSON schemas for API
5. ✅ Generate `quickstart.md` - Developer integration guide
6. Generate `tasks.md` - Task breakdown
7. Verify backend API matches specification
8. Integrate frontend to backend API

---

**Ready to proceed with specification generation!**

