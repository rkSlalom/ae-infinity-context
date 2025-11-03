# UI Component Specifications

This directory contains UI component specifications and design system documentation.

## 📁 Component Documentation Files

**Note**: This is the planned structure. Currently, see [../COMPONENT_SPEC.md](../COMPONENT_SPEC.md) for complete component specifications.

- **[design-system.md](./design-system.md)** - Design tokens and foundations
  - Color palette
  - Typography scale
  - Spacing system
  - Elevation/shadows
  - Border radius
  - Animation timing

- **[common-components.md](./common-components.md)** - Reusable components
  - Button
  - Input / TextArea
  - Checkbox / Radio
  - Modal / Dialog
  - Dropdown / Select
  - Card
  - Avatar
  - Badge
  - Spinner / Loader
  - Toast / Notification

- **[list-components.md](./list-components.md)** - Shopping list components
  - ShoppingListCard
  - ListGrid
  - CreateListDialog
  - EditListDialog
  - ShareDialog
  - CollaboratorList
  - ListFilters

- **[item-components.md](./item-components.md)** - Shopping item components
  - ItemRow
  - ItemList
  - AddItemForm
  - EditItemDialog
  - CategoryBadge
  - ItemFilters
  - PurchaseCheckbox

- **[layout-components.md](./layout-components.md)** - Layout and navigation
  - AppHeader
  - Sidebar
  - MobileBottomNav
  - PageLayout
  - EmptyState
  - ErrorBoundary

## 🎨 Design System

### Core Principles
- **Mobile-First** - Design for mobile, enhance for desktop
- **Accessibility** - WCAG 2.1 AA compliance
- **Consistency** - Reusable patterns across the app
- **Performance** - Lightweight and fast
- **Responsiveness** - Works on all screen sizes

### Design Tokens

**Colors**:
- Primary: Blue (#2196F3)
- Secondary: Purple (#9C27B0)
- Success: Green (#4CAF50)
- Warning: Orange (#FF9800)
- Error: Red (#F44336)

**Typography**:
- Font Family: Inter, Segoe UI, Roboto, sans-serif
- Scale: xs (12px) → 4xl (36px)

**Spacing**:
- Scale: 0.25rem (4px) → 4rem (64px)
- Based on 8px grid

**Reference**: [../COMPONENT_SPEC.md](../COMPONENT_SPEC.md) lines 1-100

## 📦 Component Structure

Each component document includes:

1. **Purpose** - What the component does
2. **Props** - All props with types and defaults
3. **States** - Visual states (default, hover, focus, disabled, loading, error)
4. **Examples** - Code examples and screenshots
5. **Accessibility** - ARIA attributes and keyboard support
6. **Related** - Cross-references to other components

## 🔗 Cross-References

### By User Journey

**Creating First List** → common-components.md (Button, Input), list-components.md (CreateListDialog)

**Shopping Together** → item-components.md (ItemRow, PurchaseCheckbox), layout-components.md (presence indicators)

**Sharing List** → list-components.md (ShareDialog, CollaboratorList)

### By Architecture

**State Management** → [../architecture/state-management.md](../architecture/state-management.md)

**Real-time Updates** → [../architecture/realtime-strategy.md](../architecture/realtime-strategy.md)

**API Data** → [../api/](../api/)

## ♿ Accessibility Standards

All components must meet **WCAG 2.1 AA** compliance:

- ✅ Semantic HTML
- ✅ ARIA labels and roles
- ✅ Keyboard navigation
- ✅ Focus management
- ✅ Screen reader support
- ✅ Color contrast ratios (4.5:1 normal text, 3:1 large text)
- ✅ Touch targets (44x44px minimum)

**Reference**: [../PROJECT_SPEC.md](../PROJECT_SPEC.md) line 187

## 📱 Responsive Breakpoints

```typescript
const breakpoints = {
  mobile: '< 768px',
  tablet: '768px - 1024px',
  desktop: '> 1024px'
};
```

**Approach**: Mobile-first with progressive enhancement

## 🎯 Component Development Workflow

1. **Design Review** - Check this spec and design system
2. **Props Definition** - Define TypeScript interface
3. **Implementation** - Build component with accessibility
4. **States** - Implement all visual states
5. **Testing** - Unit tests + accessibility tests
6. **Documentation** - Update this spec if needed
7. **Storybook** - Add to component library (if using)

## 🔧 Tech Stack

**Component Framework**: React 19 with TypeScript

**Styling Options** (to be decided):
- CSS Modules (isolation)
- Tailwind CSS (utility-first)
- Styled Components (CSS-in-JS)

**State Management**:
- Local: useState for UI state
- Global: Context API for app-wide state
- Server: React Query for API data

**Reference**: [../architecture/frontend-architecture.md](../architecture/frontend-architecture.md)

## 🎨 Design Patterns

### Composition over Inheritance
```typescript
<Card>
  <Card.Header>
    <Card.Title>Weekly Groceries</Card.Title>
  </Card.Header>
  <Card.Body>
    {/* content */}
  </Card.Body>
</Card>
```

### Render Props
```typescript
<DataProvider>
  {({ data, loading, error }) => (
    // custom rendering
  )}
</DataProvider>
```

### Custom Hooks
```typescript
const { user, isAuthenticated } = useAuth();
const { lists, isLoading } = useLists();
const { connection, isConnected } = useRealtime(listId);
```

## 🔗 Related Documentation

- **Personas**: [../personas/](../personas/) - User needs inform design
- **Journeys**: [../journeys/](../journeys/) - Components in user flows
- **API**: [../api/](../api/) - Data structures for components
- **Architecture**: [../architecture/](../architecture/) - Technical implementation

---

**Current Status**: Components specified in [../COMPONENT_SPEC.md](../COMPONENT_SPEC.md). Will be split by component type in future updates.

