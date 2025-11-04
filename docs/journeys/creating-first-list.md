# User Journey: Creating Your First List

**Persona**: [List Creator (Owner)](../personas/list-creator.md) - Sarah  
**Goal**: Create a shopping list from scratch and add initial items  
**Time**: 3-5 minutes  
**Device**: Mobile (iPhone)

## Preconditions

- ✅ User has downloaded the app
- ✅ User has completed registration
- ✅ User is logged in
- ❌ User has NOT created any lists yet (first-time experience)

## User Context

Sarah just finished registering for AE Infinity. She's motivated because her family keeps buying duplicate groceries. She wants to create a shared weekly shopping list.

**Mindset**: Slightly anxious (new app), hopeful (this will solve her problem)

## Journey Steps

### Step 1: Welcome Screen (First Launch)

**Screen**: Welcome / Empty State

**What Sarah Sees**:
```
┌─────────────────────────────┐
│  🛒 AE Infinity             │
│                             │
│  📋 No lists yet            │
│                             │
│  Create your first shopping │
│  list to get started!       │
│                             │
│  [+ Create Your First List] │
│                             │
│  [How It Works] [Skip Tour] │
└─────────────────────────────┘
```

**Sarah's Actions**:
- Sees empty state with clear call-to-action
- Considers clicking "How It Works" but wants to dive in
- Taps "Create Your First List"

**Time**: 10 seconds

---

### Step 2: Create List Form

**Screen**: New List Creation

**What Sarah Sees**:
```
┌─────────────────────────────┐
│ ← Create Shopping List      │
│                             │
│ List Name *                 │
│ ┌─────────────────────────┐ │
│ │ Weekly Groceries        │ │
│ └─────────────────────────┘ │
│                             │
│ Description (optional)      │
│ ┌─────────────────────────┐ │
│ │ Our regular weekly      │ │
│ │ shopping list           │ │
│ └─────────────────────────┘ │
│                             │
│         [Create List]       │
└─────────────────────────────┘
```

**Sarah's Actions**:
1. Types "Weekly Groceries" in name field
2. Types description: "Our regular weekly shopping list"
3. Taps "Create List"

**Validation**:
- Name is required (1-100 characters)
- Description is optional (max 500 characters)

**API Call**:
```typescript
POST /api/v1/lists
{
  "name": "Weekly Groceries",
  "description": "Our regular weekly shopping list"
}
```

**Response**:
```typescript
{
  "id": "list-uuid-here",
  "name": "Weekly Groceries",
  "description": "Our regular weekly shopping list",
  "ownerId": "sarah-user-id",
  "myPermission": "Owner",
  "itemCount": 0,
  "purchasedCount": 0,
  "collaboratorCount": 1, // Just Sarah
  "createdAt": "2025-11-03T10:00:00Z",
  "updatedAt": "2025-11-03T10:00:00Z"
}
```

**Time**: 30 seconds

**Reference**: [../api/lists.md#create-list](../api/lists.md#create-list)

---

### Step 3: Empty List View

**Screen**: List Detail (No Items Yet)

**What Sarah Sees**:
```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ Our regular weekly shopping │
│                             │
│  📝 No items yet            │
│                             │
│  Start adding items to      │
│  your shopping list         │
│                             │
│     [+ Add First Item]      │
│                             │
│  💡 Tip: You can share this │
│  list with family members!  │
└─────────────────────────────┘
```

**Sarah's Actions**:
- Reads the empty state message
- Notices the tip about sharing (mental note for later)
- Taps "+ Add First Item"

**Time**: 15 seconds

---

### Step 4: Add First Item

**Screen**: Add Item Form

**What Sarah Sees**:
```
┌─────────────────────────────┐
│ ← Add Item                  │
│                             │
│ Item Name *                 │
│ ┌─────────────────────────┐ │
│ │ Milk                    │ │
│ └─────────────────────────┘ │
│                             │
│ Quantity      Unit          │
│ ┌──────┐     ┌────────────┐ │
│ │  2   │     │ gallons   ↓│ │
│ └──────┘     └────────────┘ │
│                             │
│ Category                    │
│ ┌─────────────────────────┐ │
│ │ 🥛 Dairy               ↓│ │
│ └─────────────────────────┘ │
│                             │
│ Notes (optional)            │
│ ┌─────────────────────────┐ │
│ │ Whole milk preferred    │ │
│ └─────────────────────────┘ │
│                             │
│         [Add Item]          │
└─────────────────────────────┘
```

**Sarah's Actions**:
1. Types "Milk" in name field
2. Sets quantity to "2"
3. Selects "gallons" from unit dropdown
4. Selects "Dairy" category (emoji makes it easy to find)
5. Adds note: "Whole milk preferred"
6. Taps "Add Item"

**API Call**:
```typescript
POST /api/v1/lists/{listId}/items
{
  "name": "Milk",
  "quantity": 2,
  "unit": "gallons",
  "categoryId": "dairy-category-id",
  "notes": "Whole milk preferred"
}
```

**Response**: Full `ShoppingItem` object with position 1

**Time**: 45 seconds

**Reference**: [../api/items.md#create-item](../api/items.md#create-item)

---

### Step 5: First Item Added

**Screen**: List with One Item

**What Sarah Sees**:
```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ Our regular weekly shopping │
│                             │
│ ☐ Milk                      │
│   2 gallons                 │
│   🥛 Dairy                  │
│   💬 Whole milk preferred   │
│   Added by you · Just now   │
│                             │
│  [+ Add Item]               │
│                             │
│ ✨ Great start! Keep adding │
│    items to your list       │
└─────────────────────────────┘
```

**Sarah's Thoughts**:
- ✅ "That was easy!"
- ✅ "I like how it shows all the details"
- ✅ "The category emoji is helpful"
- → "Let me add more items"

**Sarah's Actions**:
- Feels encouraged by success message
- Taps "+ Add Item" again

**Time**: 10 seconds

---

### Step 6: Adding Multiple Items (Batch)

**Workflow**: Sarah adds 8 more items quickly

**Items Added**:
1. Eggs (12 count, Dairy)
2. Bread (1 loaf, Bakery)
3. Bananas (6 pieces, Produce)
4. Chicken Breast (2 lbs, Meat)
5. Rice (1 bag, Pantry)
6. Tomatoes (4 pieces, Produce)
7. Cheese (1 block, Dairy)
8. Pasta (2 boxes, Pantry)

**Pattern**: Sarah gets faster with each item
- First item (Milk): 45 seconds
- Items 2-3: 30 seconds each
- Items 4-9: 20 seconds each (muscle memory forming)

**Total Time for 8 items**: ~3 minutes

---

### Step 7: Reviewing Complete List

**Screen**: List with 9 Items

**What Sarah Sees**:
```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ 9 items · 0 purchased       │
│                             │
│ 🥛 Dairy                    │
│ ☐ Milk (2 gallons)          │
│ ☐ Eggs (12 count)           │
│ ☐ Cheese (1 block)          │
│                             │
│ 🍞 Bakery                   │
│ ☐ Bread (1 loaf)            │
│                             │
│ 🍎 Produce                  │
│ ☐ Bananas (6 pieces)        │
│ ☐ Tomatoes (4 pieces)       │
│                             │
│ 🥩 Meat                     │
│ ☐ Chicken Breast (2 lbs)    │
│                             │
│ 📦 Pantry                   │
│ ☐ Rice (1 bag)              │
│ ☐ Pasta (2 boxes)           │
│                             │
│  [+ Add Item]               │
└─────────────────────────────┘
```

**Sarah's Reactions**:
- ✅ "Love that it's organized by category!"
- ✅ "This will make shopping so much easier"
- ✅ "Now I need to share this with Mike"
- → Notices "⋮" menu button
- → Taps menu to explore options

**Time**: 20 seconds

---

### Step 8: Discovering Share Feature

**Screen**: List Menu

**What Sarah Sees**:
```
┌─────────────────────────────┐
│ Weekly Groceries            │
├─────────────────────────────┤
│ 👥 Share List               │
│ ✏️  Edit List Details        │
│ 🗂️  Archive List             │
│ 🗑️  Delete List              │
│ ⚙️  List Settings            │
└─────────────────────────────┘
```

**Sarah's Actions**:
- Sees "Share List" option (exactly what she needs!)
- Taps "Share List"
- **Journey continues** → [sharing-list.md](./sharing-list.md)

**Time**: 5 seconds

## Success Criteria

✅ **Primary Goals Achieved**:
- Created first shopping list
- Added multiple items with details
- Items automatically organized by category
- Discovered how to share list

✅ **User Satisfaction**:
- Process felt intuitive
- Took less than 5 minutes
- No errors or confusion
- Clear path to next action (sharing)

## Error Handling

### Error: List Name Too Short

**Trigger**: User tries to create list with empty name

**Validation Message**:
```
┌─────────────────────────────┐
│ ⚠️ List name is required    │
└─────────────────────────────┘
```

**Resolution**: User adds name, retries

---

### Error: Network Failure During Creation

**Trigger**: No internet connection or API timeout

**Error Message**:
```
┌─────────────────────────────┐
│ ❌ Couldn't create list     │
│                             │
│ Check your connection and   │
│ try again                   │
│                             │
│  [Retry]  [Save for Later]  │
└─────────────────────────────┘
```

**Resolution**: 
- Retry when connected
- Or save to offline queue

**Reference**: [../architecture/offline-sync.md](../architecture/offline-sync.md)

---

### Error: Invalid Category Selected

**Trigger**: Category ID doesn't exist

**Handling**: Falls back to "Other" category, logs error

## Metrics & Analytics

**Key Events to Track**:
- `list_created` - First list creation
- `first_item_added` - User engagement
- `time_to_first_item` - Onboarding efficiency
- `items_added_in_first_session` - Initial engagement depth
- `share_feature_discovered` - Feature discovery

**Success Metrics**:
- **Time to First List**: < 2 minutes (median)
- **Items in First List**: 5-10 (median)
- **Completion Rate**: > 85% (users who start list creation finish it)
- **Time to Share**: < 10 minutes after list creation

## Related Documentation

**Next Steps**:
- [sharing-list.md](./sharing-list.md) - Share the list with family

**Technical Implementation**:
- [../api/lists.md](../api/lists.md) - List API endpoints
- [../api/items.md](../api/items.md) - Item API endpoints
- [../components/list-components.md](../components/list-components.md) - UI components

**Personas**:
- [../personas/list-creator.md](../personas/list-creator.md) - Sarah's full persona

