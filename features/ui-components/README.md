# UI Components

**Feature Domain**: UI Component Library  
**Version**: 1.0  
**Status**: 10% - Basic components only

---

## Overview

Reusable UI component library for consistent design across the application.

**Note**: This is currently aspirational. The actual UI uses native HTML elements styled with Tailwind CSS.

---

## Implemented Components

| Component | Location | Status |
|-----------|----------|--------|
| LoadingSpinner | `src/components/common/LoadingSpinner.tsx` | ✅ Complete |
| AppLayout | `src/components/layout/AppLayout.tsx` | ✅ Complete |
| AuthLayout | `src/components/layout/AuthLayout.tsx` | ✅ Complete |
| Header | `src/components/layout/Header.tsx` | ✅ Complete |
| Sidebar | `src/components/layout/Sidebar.tsx` | ✅ Complete |

---

## Planned Components (Not Built)

See [COMPONENT_SPEC.md](../../COMPONENT_SPEC.md) for detailed specifications.

### Common Components
- Button ❌
- Input ❌
- Modal ❌
- Card ❌
- Checkbox ❌
- Dropdown ❌
- Avatar ❌
- Badge ❌
- Toast/Notification ❌
- Empty State ❌

### Feature Components
- ShoppingListCard ❌
- ShoppingItemRow ❌
- ItemForm ❌
- CollaboratorList ❌
- ShareListModal ❌
- PresenceIndicator ❌
- ListFilter ❌
- CategoryBadge ❌

---

## Current Approach

**Using**: Native HTML elements + Tailwind CSS

**Why**: Faster development, less maintenance, still looks good

**Example**:
```tsx
{/* Instead of custom Button component */}
<button className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">
  Click Me
</button>
```

---

## Future: Build Component Library

If/when we decide to build the component library:

1. Follow [COMPONENT_SPEC.md](../../COMPONENT_SPEC.md)
2. Build components one at a time
3. Replace native HTML in pages
4. Add Storybook for documentation
5. Write component tests

---

## Priority

**Low** - This is optional. Current approach works fine.

Only build if:
- Need strict design system enforcement
- Want reusable components across multiple apps
- Need advanced features (animations, a11y, etc.)

