# Frontend Component Specification

**Current Implementation Status**: This document describes the IDEAL component library. The actual UI implementation uses **native HTML elements with Tailwind CSS** instead of custom components. See `UI_IMPLEMENTATION_STATUS.md` for actual implementation details.

**Components Currently Implemented**:
- LoadingSpinner ✅
- Layout components (AppLayout, AuthLayout, Header, Sidebar) ✅

**Components Using Native HTML**:
- All form elements (buttons, inputs)
- All page content
- All modals and cards

---

## Design System (Aspirational)

### Color Palette
```typescript
const colors = {
  primary: {
    50: '#E3F2FD',
    100: '#BBDEFB',
    500: '#2196F3',
    700: '#1976D2',
    900: '#0D47A1'
  },
  secondary: {
    50: '#F3E5F5',
    100: '#E1BEE7',
    500: '#9C27B0',
    700: '#7B1FA2',
    900: '#4A148C'
  },
  success: '#4CAF50',
  warning: '#FF9800',
  error: '#F44336',
  info: '#2196F3',
  grey: {
    50: '#FAFAFA',
    100: '#F5F5F5',
    200: '#EEEEEE',
    300: '#E0E0E0',
    500: '#9E9E9E',
    700: '#616161',
    900: '#212121'
  }
};
```

### Typography
- **Font Family**: 'Inter', 'Segoe UI', 'Roboto', sans-serif
- **Font Sizes**:
  - xs: 12px
  - sm: 14px
  - base: 16px
  - lg: 18px
  - xl: 20px
  - 2xl: 24px
  - 3xl: 30px
  - 4xl: 36px

### Spacing Scale
- 1: 4px
- 2: 8px
- 3: 12px
- 4: 16px
- 5: 20px
- 6: 24px
- 8: 32px
- 10: 40px
- 12: 48px
- 16: 64px

### Border Radius
- sm: 4px
- md: 8px
- lg: 12px
- xl: 16px
- full: 9999px

---

## Core Components

### Button Component

**File**: `src/components/common/Button.tsx`

**Props**:
```typescript
interface ButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'outlined' | 'text' | 'danger';
  size?: 'small' | 'medium' | 'large';
  fullWidth?: boolean;
  disabled?: boolean;
  loading?: boolean;
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
  onClick?: (e: React.MouseEvent<HTMLButtonElement>) => void;
  type?: 'button' | 'submit' | 'reset';
  className?: string;
}
```

**Usage**:
```tsx
<Button variant="primary" size="medium" onClick={handleClick}>
  Save List
</Button>

<Button variant="outlined" icon={<PlusIcon />} loading={isLoading}>
  Add Item
</Button>
```

**Accessibility**:
- Full keyboard navigation
- ARIA labels for icon-only buttons
- Loading state announcements
- Disabled state properly conveyed

---

### Input Component

**File**: `src/components/common/Input.tsx`

**Props**:
```typescript
interface InputProps {
  label?: string;
  placeholder?: string;
  value: string;
  onChange: (value: string) => void;
  type?: 'text' | 'email' | 'password' | 'number' | 'search';
  error?: string;
  helperText?: string;
  disabled?: boolean;
  required?: boolean;
  icon?: React.ReactNode;
  iconPosition?: 'left' | 'right';
  fullWidth?: boolean;
  autoComplete?: string;
  autoFocus?: boolean;
  maxLength?: number;
  className?: string;
}
```

**Usage**:
```tsx
<Input
  label="List Name"
  placeholder="Enter list name..."
  value={listName}
  onChange={setListName}
  error={errors.name}
  required
  maxLength={100}
/>
```

**Features**:
- Error state styling
- Helper text below input
- Character counter for maxLength
- Clear button for non-empty inputs
- Password visibility toggle

---

### Modal Component

**File**: `src/components/common/Modal.tsx`

**Props**:
```typescript
interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  size?: 'small' | 'medium' | 'large' | 'fullscreen';
  showCloseButton?: boolean;
  closeOnBackdropClick?: boolean;
  closeOnEscape?: boolean;
  footer?: React.ReactNode;
  className?: string;
}
```

**Usage**:
```tsx
<Modal
  isOpen={showModal}
  onClose={handleClose}
  title="Add New Item"
  size="medium"
  footer={
    <>
      <Button variant="text" onClick={handleClose}>Cancel</Button>
      <Button variant="primary" onClick={handleSubmit}>Add Item</Button>
    </>
  }
>
  <ItemForm />
</Modal>
```

**Features**:
- Portal rendering
- Focus trap
- Backdrop overlay
- Smooth animations
- Scroll lock on body
- Accessible (ARIA attributes)

---

### Card Component

**File**: `src/components/common/Card.tsx`

**Props**:
```typescript
interface CardProps {
  children: React.ReactNode;
  variant?: 'elevated' | 'outlined' | 'flat';
  padding?: 'none' | 'small' | 'medium' | 'large';
  hoverable?: boolean;
  onClick?: () => void;
  className?: string;
}
```

**Usage**:
```tsx
<Card variant="elevated" hoverable onClick={handleCardClick}>
  <CardContent>
    <h3>Weekly Groceries</h3>
    <p>12 items remaining</p>
  </CardContent>
</Card>
```

---

### Checkbox Component

**File**: `src/components/common/Checkbox.tsx`

**Props**:
```typescript
interface CheckboxProps {
  checked: boolean;
  onChange: (checked: boolean) => void;
  label?: string;
  disabled?: boolean;
  indeterminate?: boolean;
  size?: 'small' | 'medium' | 'large';
  className?: string;
}
```

**Usage**:
```tsx
<Checkbox
  checked={item.isPurchased}
  onChange={(checked) => handleTogglePurchased(item.id, checked)}
  label={item.name}
/>
```

---

## Feature Components

### ShoppingListCard

**File**: `src/components/lists/ShoppingListCard.tsx`

**Props**:
```typescript
interface ShoppingListCardProps {
  list: ShoppingList;
  onClick?: () => void;
  onShare?: () => void;
  onArchive?: () => void;
  onDelete?: () => void;
}

interface ShoppingList {
  id: string;
  name: string;
  description?: string;
  itemCount: number;
  purchasedCount: number;
  collaboratorCount: number;
  myPermission: 'Owner' | 'Editor' | 'Viewer';
  updatedAt: string;
  ownerName: string;
}
```

**Features**:
- Display list name and description
- Show item progress (5/12 items)
- Show collaborator count
- Action menu (share, archive, delete)
- Last updated timestamp
- Permission badge
- Hover effects

**Usage**:
```tsx
<ShoppingListCard
  list={list}
  onClick={() => navigate(`/lists/${list.id}`)}
  onShare={() => handleShare(list.id)}
  onArchive={() => handleArchive(list.id)}
  onDelete={() => handleDelete(list.id)}
/>
```

---

### ShoppingItemRow

**File**: `src/components/items/ShoppingItemRow.tsx`

**Props**:
```typescript
interface ShoppingItemRowProps {
  item: ShoppingItem;
  onTogglePurchased: (itemId: string, isPurchased: boolean) => void;
  onEdit: (itemId: string) => void;
  onDelete: (itemId: string) => void;
  canEdit: boolean;
  dragHandleProps?: any; // For drag-and-drop
}

interface ShoppingItem {
  id: string;
  name: string;
  quantity: number;
  unit?: string;
  category: Category;
  notes?: string;
  imageUrl?: string;
  isPurchased: boolean;
  createdBy: {
    displayName: string;
  };
  purchasedBy?: {
    displayName: string;
  };
  purchasedAt?: string;
}
```

**Features**:
- Checkbox to mark as purchased
- Item name, quantity, and unit
- Category badge with icon
- Notes (collapsible if long)
- Item image thumbnail
- Edit/delete actions
- Strikethrough when purchased
- Drag handle for reordering
- Who added/purchased indicator

**Usage**:
```tsx
<ShoppingItemRow
  item={item}
  onTogglePurchased={handleTogglePurchased}
  onEdit={handleEditItem}
  onDelete={handleDeleteItem}
  canEdit={hasEditPermission}
/>
```

---

### ItemForm

**File**: `src/components/items/ItemForm.tsx`

**Props**:
```typescript
interface ItemFormProps {
  initialValues?: Partial<ItemFormValues>;
  onSubmit: (values: ItemFormValues) => Promise<void>;
  onCancel: () => void;
  categories: Category[];
}

interface ItemFormValues {
  name: string;
  quantity: number;
  unit: string;
  categoryId: string;
  notes: string;
  imageUrl?: string;
}
```

**Features**:
- Form validation
- Category dropdown with icons
- Quantity and unit inputs
- Optional notes textarea
- Image upload (optional)
- Loading state during submission
- Error handling

**Usage**:
```tsx
<ItemForm
  initialValues={editingItem}
  onSubmit={handleSubmitItem}
  onCancel={handleCancel}
  categories={categories}
/>
```

---

### CollaboratorList

**File**: `src/components/lists/CollaboratorList.tsx`

**Props**:
```typescript
interface CollaboratorListProps {
  listId: string;
  collaborators: Collaborator[];
  myPermission: PermissionLevel;
  onChangePermission: (userId: string, permission: PermissionLevel) => void;
  onRemove: (userId: string) => void;
}

interface Collaborator {
  userId: string;
  displayName: string;
  avatarUrl?: string;
  permission: PermissionLevel;
  invitedAt: string;
  acceptedAt?: string;
}

type PermissionLevel = 'Owner' | 'Editor' | 'Viewer';
```

**Features**:
- List of collaborators with avatars
- Permission badges
- Dropdown to change permissions (if allowed)
- Remove collaborator button (if allowed)
- Pending invitation indicators
- Owner cannot be removed or changed

**Usage**:
```tsx
<CollaboratorList
  listId={list.id}
  collaborators={list.collaborators}
  myPermission={myPermission}
  onChangePermission={handleChangePermission}
  onRemove={handleRemoveCollaborator}
/>
```

---

### ShareListModal

**File**: `src/components/lists/ShareListModal.tsx`

**Props**:
```typescript
interface ShareListModalProps {
  isOpen: boolean;
  onClose: () => void;
  listId: string;
  listName: string;
}
```

**Features**:
- Email input to invite users
- Permission dropdown
- Copy shareable link button
- List of pending invitations
- Cancel invitation option

**Usage**:
```tsx
<ShareListModal
  isOpen={showShareModal}
  onClose={() => setShowShareModal(false)}
  listId={list.id}
  listName={list.name}
/>
```

---

### PresenceIndicator

**File**: `src/components/realtime/PresenceIndicator.tsx`

**Props**:
```typescript
interface PresenceIndicatorProps {
  activeUsers: ActiveUser[];
  maxDisplay?: number;
}

interface ActiveUser {
  userId: string;
  displayName: string;
  avatarUrl?: string;
}
```

**Features**:
- Shows avatar stack of active users
- Tooltip with user names on hover
- Overflow counter (+3 more)
- Real-time updates

**Usage**:
```tsx
<PresenceIndicator activeUsers={activeUsers} maxDisplay={5} />
```

---

### ListFilter

**File**: `src/components/lists/ListFilter.tsx`

**Props**:
```typescript
interface ListFilterProps {
  filters: FilterState;
  onFilterChange: (filters: FilterState) => void;
}

interface FilterState {
  showArchived: boolean;
  sortBy: 'name' | 'updatedAt' | 'createdAt';
  sortOrder: 'asc' | 'desc';
  searchQuery: string;
}
```

**Features**:
- Search input
- Sort dropdown
- Toggle for archived lists
- Clear all filters button

**Usage**:
```tsx
<ListFilter filters={filters} onFilterChange={setFilters} />
```

---

### CategoryBadge

**File**: `src/components/common/CategoryBadge.tsx`

**Props**:
```typescript
interface CategoryBadgeProps {
  category: Category;
  size?: 'small' | 'medium' | 'large';
  showIcon?: boolean;
  onClick?: () => void;
}

interface Category {
  id: string;
  name: string;
  icon: string;
  color: string;
}
```

**Features**:
- Color-coded background
- Emoji icon
- Responsive sizing
- Optional click handler (for filtering)

**Usage**:
```tsx
<CategoryBadge
  category={item.category}
  size="small"
  showIcon
  onClick={() => filterByCategory(item.category.id)}
/>
```

---

### EmptyState

**File**: `src/components/common/EmptyState.tsx`

**Props**:
```typescript
interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
}
```

**Features**:
- Large icon/illustration
- Title and description
- Optional call-to-action button
- Centered layout

**Usage**:
```tsx
<EmptyState
  icon={<ShoppingCartIcon />}
  title="No items in this list"
  description="Add your first item to get started"
  action={{
    label: "Add Item",
    onClick: handleAddItem
  }}
/>
```

---

### LoadingSpinner

**File**: `src/components/common/LoadingSpinner.tsx`

**Props**:
```typescript
interface LoadingSpinnerProps {
  size?: 'small' | 'medium' | 'large';
  color?: string;
  fullscreen?: boolean;
  message?: string;
}
```

**Features**:
- Animated spinner
- Multiple sizes
- Optional loading message
- Fullscreen overlay option
- Accessible (ARIA live region)

**Usage**:
```tsx
<LoadingSpinner size="medium" message="Loading lists..." />
```

---

### Toast/Notification

**File**: `src/components/common/Toast.tsx`

**Props**:
```typescript
interface ToastProps {
  message: string;
  type?: 'success' | 'error' | 'warning' | 'info';
  duration?: number;
  onClose?: () => void;
  action?: {
    label: string;
    onClick: () => void;
  };
}
```

**Features**:
- Auto-dismiss after duration
- Color-coded by type
- Optional action button
- Swipe to dismiss
- Stack multiple toasts
- Accessible announcements

**Usage**:
```tsx
// Via context/hook
const { showToast } = useToast();

showToast({
  message: "Item added successfully",
  type: "success",
  action: {
    label: "Undo",
    onClick: handleUndo
  }
});
```

---

## Layout Components

### AppLayout

**File**: `src/components/layout/AppLayout.tsx`

**Features**:
- Top navigation bar
- Sidebar (collapsible on mobile)
- Main content area
- Responsive breakpoints

**Structure**:
```tsx
<AppLayout>
  <Header />
  <Sidebar />
  <MainContent>
    {children}
  </MainContent>
</AppLayout>
```

---

### Header

**File**: `src/components/layout/Header.tsx`

**Features**:
- Logo/app name
- Search bar
- User menu dropdown
- Notifications bell
- Mobile menu toggle

---

### Sidebar

**File**: `src/components/layout/Sidebar.tsx`

**Features**:
- Navigation links
  - All Lists
  - Shared with Me
  - Archived
  - Settings
- Create new list button
- Collapse/expand functionality
- Active route highlighting

---

## Page Components

### HomePage

**File**: `src/pages/Home.tsx`

**Layout**:
- Welcome header
- Quick actions (New List, Join List)
- Recent lists grid
- List filter/search
- Empty state if no lists

---

### ListDetailPage

**File**: `src/pages/ListDetail.tsx`

**Layout**:
- List header (name, description, collaborators)
- Presence indicators
- Add item input (quick add)
- Item filters (category, status)
- Items list (grouped by category)
- Empty state if no items

---

### LoginPage

**File**: `src/pages/Login.tsx`

**Features**:
- Email/password form
- "Remember me" checkbox
- "Forgot password" link
- Social login options (optional)
- Link to registration page

---

### RegisterPage

**File**: `src/pages/Register.tsx`

**Features**:
- Email, display name, password fields
- Password strength indicator
- Terms of service checkbox
- Link to login page

---

### ProfilePage

**File**: `src/pages/Profile.tsx`

**Features**:
- Edit display name
- Upload avatar
- Change password
- Email preferences
- Danger zone (delete account)

---

## Custom Hooks

### useAuth

**File**: `src/hooks/useAuth.ts`

```typescript
interface UseAuthReturn {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => void;
  updateProfile: (data: ProfileData) => Promise<void>;
}
```

---

### useLists

**File**: `src/hooks/useLists.ts`

```typescript
interface UseListsReturn {
  lists: ShoppingList[];
  isLoading: boolean;
  error: Error | null;
  createList: (data: CreateListData) => Promise<ShoppingList>;
  updateList: (id: string, data: UpdateListData) => Promise<void>;
  deleteList: (id: string) => Promise<void>;
  shareList: (id: string, email: string, permission: PermissionLevel) => Promise<void>;
  refetch: () => void;
}
```

---

### useItems

**File**: `src/hooks/useItems.ts`

```typescript
interface UseItemsReturn {
  items: ShoppingItem[];
  isLoading: boolean;
  error: Error | null;
  addItem: (data: CreateItemData) => Promise<ShoppingItem>;
  updateItem: (id: string, data: UpdateItemData) => Promise<void>;
  togglePurchased: (id: string, isPurchased: boolean) => Promise<void>;
  deleteItem: (id: string) => Promise<void>;
  reorderItems: (itemPositions: ItemPosition[]) => Promise<void>;
}
```

---

### useRealtime

**File**: `src/hooks/useRealtime.ts`

```typescript
interface UseRealtimeReturn {
  isConnected: boolean;
  joinList: (listId: string) => void;
  leaveList: (listId: string) => void;
  activeUsers: ActiveUser[];
}
```

**Events handled**:
- ItemAdded → Update local state
- ItemUpdated → Update local state
- ItemDeleted → Remove from local state
- ItemPurchased → Update item status
- PresenceChanged → Update active users

---

### useOptimistic

**File**: `src/hooks/useOptimistic.ts`

```typescript
interface UseOptimisticReturn {
  data: T[];
  addOptimistic: (item: T) => void;
  updateOptimistic: (id: string, updates: Partial<T>) => void;
  removeOptimistic: (id: string) => void;
  rollback: (id: string) => void;
}
```

**Purpose**: Immediately update UI before server confirmation, rollback on error.

---

## Responsive Design

### Breakpoints
```typescript
const breakpoints = {
  xs: '0px',      // Mobile portrait
  sm: '640px',    // Mobile landscape
  md: '768px',    // Tablet portrait
  lg: '1024px',   // Tablet landscape / Desktop
  xl: '1280px',   // Desktop
  '2xl': '1536px' // Large desktop
};
```

### Mobile-First Approach
- Design for mobile first
- Progressively enhance for larger screens
- Touch-friendly hit targets (minimum 44x44px)
- Swipe gestures for mobile interactions

---

## Accessibility Guidelines

1. **Keyboard Navigation**
   - All interactive elements focusable
   - Logical tab order
   - Visible focus indicators
   - Keyboard shortcuts for common actions

2. **Screen Reader Support**
   - Semantic HTML
   - ARIA labels and descriptions
   - Live regions for dynamic updates
   - Meaningful alt text for images

3. **Color and Contrast**
   - WCAG AA contrast ratios (4.5:1 minimum)
   - Don't rely solely on color
   - Color blind-friendly palette

4. **Forms**
   - Associated labels
   - Error messages
   - Required field indicators
   - Helper text

5. **Motion**
   - Respect prefers-reduced-motion
   - Provide alternatives to animations
   - No auto-playing content

---

## Performance Considerations

1. **Code Splitting**: Route-based lazy loading
2. **Memoization**: React.memo for expensive components
3. **Virtual Scrolling**: For long item lists
4. **Image Optimization**: Lazy loading, WebP format
5. **Debouncing**: Search and filter inputs
6. **Optimistic Updates**: Instant UI feedback

