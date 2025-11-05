# User Journey: Shopping Together

**Personas**: 
- [List Creator (Owner)](../personas/list-creator.md) - Sarah
- [Active Collaborator (Editor)](../personas/active-collaborator.md) - Mike

**Goal**: Coordinate shopping when both users are in stores simultaneously  
**Scenario**: Both Sarah and Mike shopping at the same time, different stores  
**Time**: 20-30 minutes (shopping duration)  
**Devices**: Both on Mobile

## Preconditions

- ✅ Sarah created "Weekly Groceries" list
- ✅ Mike has Editor access to the list
- ✅ Both users are logged in
- ✅ Both have stable internet connection
- ✅ List has 15 items to purchase

## User Context

**Sarah's Situation**: 
- Shopping at main grocery store (30 items)
- Has the big cart, doing main shopping
- Time: Saturday 10:00 AM

**Mike's Situation**:
- Stopping at convenience store on way home from gym
- Only getting a few quick items
- Time: Saturday 10:05 AM (5 minutes later)

**Goal**: Avoid buying duplicate items, coordinate efficiently

## Journey Steps

### Step 1: Sarah Starts Shopping

**Time**: 10:00 AM  
**Location**: Sarah at grocery store

**Screen**: Shopping List View

```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ 15 items · 0 purchased      │
│                             │
│ 🥛 Dairy                    │
│ ☐ Milk (2 gallons)          │
│ ☐ Eggs (12 count)           │
│ ☐ Yogurt (4 cups)           │
│                             │
│ 🍎 Produce                  │
│ ☐ Bananas (6 pieces)        │
│ ☐ Apples (8 pieces)         │
│ ☐ Lettuce (1 head)          │
│                             │
│ 🥩 Meat                     │
│ ☐ Chicken (2 lbs)           │
│ ☐ Ground Beef (1 lb)        │
└─────────────────────────────┘
```

**Sarah's Actions**:
1. Opens app as she enters store
2. Starts in produce section
3. Checks off "Bananas" ✓
4. Checks off "Apples" ✓

**API Calls** (per item):
```typescript
PATCH /api/v1/lists/{listId}/items/{itemId}/purchased
{
  "isPurchased": true
}
```

**SignalR Events Broadcasted**:
```typescript
// Sent to all connected clients on this list
ItemPurchased {
  itemId: "banana-id",
  userId: "sarah-id",
  listId: "list-id",
  purchasedAt: "2025-11-03T10:02:00Z"
}
```

**Time**: 10:02 AM (2 minutes in)

**Reference**: [../api/items.md#update-purchased](../api/items.md#update-purchased)

---

### Step 2: Mike Enters Store (Presence Detection)

**Time**: 10:05 AM  
**Location**: Mike at convenience store

**Mike Opens App**:
- App automatically connects to SignalR hub
- Joins "Weekly Groceries" room

**SignalR Client → Server**:
```typescript
connection.invoke("JoinList", listId);
connection.invoke("UpdatePresence", listId, true);
```

**Mike's Screen**:
```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ 15 items · 2 purchased      │
│                             │
│ 👤 Sarah is shopping now    │
│                             │
│ 🥛 Dairy                    │
│ ☐ Milk (2 gallons)          │
│ ☐ Eggs (12 count)           │
│ ☐ Yogurt (4 cups)           │
│                             │
│ 🍎 Produce                  │
│ ☑ Bananas ✓ by Sarah        │
│ ☑ Apples ✓ by Sarah         │
│ ☐ Lettuce (1 head)          │
└─────────────────────────────┘
```

**Mike's Observations**:
- ✅ Sees "Sarah is shopping now" indicator
- ✅ Sees 2 items already checked off
- ✅ Knows Sarah got bananas and apples
- → Decision: "I'll skip produce, get dairy and meat"

**Sarah's Screen Updates** (simultaneously):
```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ 👤 Mike is shopping now     │
└─────────────────────────────┘
```

**Sarah's Thoughts**:
- ✅ "Oh great, Mike can grab some items too"
- ✅ "I'll focus on produce and pantry, he can get dairy"

**SignalR Events**:
```typescript
// Broadcast to all clients
PresenceChanged {
  userId: "mike-id",
  listId: "list-id",
  isActive: true
}
```

**Time**: 10:05 AM

**Reference**: [../api/realtime-events.md#presence](../api/realtime-events.md#presence)

---

### Step 3: Mike Checks Off Dairy Items

**Time**: 10:07 AM

**Mike's Actions**:
1. Grabs milk (2 gallons)
2. Checks off "Milk" ✓ in app
3. Grabs eggs
4. Checks off "Eggs" ✓ in app

**Mike's Screen**:
```
┌─────────────────────────────┐
│ 🥛 Dairy                    │
│ ☑ Milk ✓ by you · Just now  │
│ ☑ Eggs ✓ by you · Just now  │
│ ☐ Yogurt (4 cups)           │
└─────────────────────────────┘
```

**Sarah's Screen** (Real-time Update):
```
┌─────────────────────────────┐
│ 🥛 Dairy                    │
│ ☑ Milk ✓ by Mike · Just now │
│ ☑ Eggs ✓ by Mike · Just now │
│ ☐ Yogurt (4 cups)           │
└─────────────────────────────┘
```

**Sarah's Reaction**:
- ✅ Sees Mike's updates in real-time
- ✅ "Perfect! I can skip dairy aisle"
- → Changes route through store

**Time**: 10:07 AM

---

### Step 4: Potential Conflict - Both Approach Yogurt

**Time**: 10:10 AM

**Scenario**: Both Sarah and Mike are looking at yogurt

**Sarah**:
- Finishes produce section
- Heads toward dairy for yogurt
- Sees yogurt still unchecked

**Mike**:
- Already in dairy aisle
- Reaches for yogurt

**Mike's Action** (happens first):
- Grabs yogurt
- Checks off "Yogurt" ✓
- **Network delay**: 200ms

**Sarah's Action** (2 seconds later):
- Reaches for yogurt
- Sees app update: "Yogurt ✓ by Mike"
- **Stops before grabbing it**

**Result**: ✅ **Conflict avoided!**

**Sarah's Screen** (Real-time):
```
┌─────────────────────────────┐
│ 🥛 Dairy                    │
│ ☑ Milk ✓ by Mike            │
│ ☑ Eggs ✓ by Mike            │
│ ☑ Yogurt ✓ by Mike · Just now│
│                             │
│ ✨ Great! All dairy items   │
│    are complete             │
└─────────────────────────────┘
```

**Sarah's Thoughts**:
- ✅ "Phew! Saved me from buying duplicates"
- ✅ "This real-time thing really works"

**Real-time Latency**: < 500ms (within target of 100ms)

**Reference**: [../architecture/realtime-strategy.md#conflict-resolution](../architecture/realtime-strategy.md#conflict-resolution)

---

### Step 5: Adding Forgotten Items On-The-Fly

**Time**: 10:15 AM

**Mike's Situation**:
- Walking past snack aisle
- Remembers they're out of chips
- Wants to add to list and buy immediately

**Mike's Actions**:
1. Taps "+ Add Item" button
2. Types "Chips"
3. Selects "Snacks" category
4. Taps "Add & Mark Purchased"
5. Grabs chips from shelf

**API Call**:
```typescript
POST /api/v1/lists/{listId}/items
{
  "name": "Chips",
  "categoryId": "snacks-category-id",
  "quantity": 1
}

// Immediately followed by:
PATCH /api/v1/lists/{listId}/items/{newItemId}/purchased
{
  "isPurchased": true
}
```

**Sarah's Screen** (Gets notification):
```
┌─────────────────────────────┐
│ 🔔 Mike added "Chips"       │
│    (Already purchased)      │
└─────────────────────────────┘
```

**Sarah's Reaction**:
- ✅ "Good idea, we were out"
- ✅ Doesn't need to do anything

**Time**: 10:15 AM

**Reference**: [../api/items.md#create-item](../api/items.md#create-item)

---

### Step 6: Mike Finishes First

**Time**: 10:18 AM

**Mike's Status**:
- Checked off: Milk, Eggs, Yogurt, Chips (new)
- Total time in store: 13 minutes
- Heading to checkout

**Mike's Actions**:
1. Reviews list one more time
2. Sees Sarah still has items unchecked
3. Leaves app open (stays connected)
4. Checks out

**Mike's Screen**:
```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ 16 items · 6 purchased      │
│                             │
│ 👤 Sarah is shopping now    │
│                             │
│ ✅ Your items:              │
│ ☑ Milk, Eggs, Yogurt, Chips│
│                             │
│ 📋 Still needed: 10 items   │
│ (Sarah shopping)            │
└─────────────────────────────┘
```

**Mike leaves store but stays connected**:
- SignalR connection maintained
- Still receives updates
- No longer actively shopping but monitoring

**Time**: 10:20 AM

---

### Step 7: Sarah Continues Shopping

**Time**: 10:20 AM - 10:35 AM

**Sarah's Situation**:
- Mike finished his items
- Sarah continues with remaining 10 items
- Sees Mike's contributions in real-time
- Feels supported (not shopping alone)

**Sarah Completes**:
- ✓ Lettuce
- ✓ Chicken
- ✓ Ground Beef
- ✓ Rice
- ✓ Pasta
- ✓ Bread
- ✓ Tomatoes
- ✓ Onions
- ✓ Garlic
- ✓ Cheese

**Time**: 10:35 AM (Total: 35 minutes in store)

---

### Step 8: Shopping Complete - Both Review

**Time**: 10:36 AM

**Screen** (Both Sarah and Mike):
```
┌─────────────────────────────┐
│ ← Weekly Groceries      ⋮   │
│ 16 items · 16 purchased ✅  │
│                             │
│ 🎉 Shopping Complete!       │
│                             │
│ ✅ Purchased by you: 12     │
│ ✅ Purchased by Mike: 4     │
│                             │
│ [Archive List]              │
│ [Mark All Unpurchased]      │
│ [Create Similar List]       │
└─────────────────────────────┘
```

**Summary Stats**:
- Total items: 16 (15 planned + 1 added on-the-fly)
- Sarah purchased: 12 items
- Mike purchased: 4 items
- Duplicates avoided: 3 (Milk, Eggs, Yogurt)
- Time saved: ~10 minutes (avoided duplicate shopping)

---

## Success Criteria

✅ **Primary Goals Achieved**:
- No duplicate purchases
- Coordinated efficiently
- Both users stayed informed
- Real-time updates worked seamlessly

✅ **Real-time Performance**:
- Update latency: < 500ms average
- No lost events
- Presence indicators accurate
- No conflicts or race conditions

✅ **User Satisfaction**:
- Sarah: "This saved us so much time!"
- Mike: "I love seeing what she's already got"

## Error Handling & Edge Cases

### Edge Case: Network Interruption

**Scenario**: Mike loses signal temporarily in store

**Handling**:
1. App shows "Reconnecting..." indicator
2. Mike's checks are queued locally
3. When connection restores, queued items sync
4. Sarah sees batch update

**Reference**: [../architecture/offline-sync.md](../architecture/offline-sync.md)

---

### Edge Case: Both Check Same Item Simultaneously

**Scenario**: Both tap checkbox for "Chicken" at exact same moment

**Handling** (Last-Write-Wins):
1. Both send PATCH requests
2. Server timestamps determine winner
3. Second request sees item already purchased
4. Server returns 200 OK (idempotent)
5. Both UIs show item purchased

**Result**: No duplicate, no error

**Reference**: [../architecture/realtime-strategy.md#conflict-resolution](../architecture/realtime-strategy.md#conflict-resolution)

---

### Edge Case: One User Goes Offline Mid-Shopping

**Scenario**: Sarah's phone dies mid-shopping

**Impact on Mike**:
- Mike sees "Sarah was shopping" (past tense)
- Mike doesn't know which items Sarah has in cart
- Mike proceeds cautiously

**Resolution**:
- Sarah's partial state syncs when phone powers on
- Minimal impact since most items already marked

## Metrics & Analytics

**Key Events Tracked**:
- `shopping_session_started` (per user)
- `presence_overlap` (both users shopping simultaneously)
- `duplicate_avoided` (when one user sees other marked item)
- `realtime_update_latency` (performance metric)
- `items_purchased_collaboratively`

**Success Metrics**:
- **Duplicate Avoidance Rate**: 100% (this session)
- **Real-time Latency**: < 500ms (target: < 100ms)
- **Collaboration Efficiency**: 40% time saved vs. sequential shopping
- **User Satisfaction**: Both users report positive experience

## Related Documentation

**Previous Journeys**:
- [creating-first-list.md](./creating-first-list.md) - How list was created
- [sharing-list.md](./sharing-list.md) - How Mike got access

**Technical Implementation**:
- [../api/realtime-events.md](../api/realtime-events.md) - SignalR events
- [../architecture/realtime-strategy.md](../architecture/realtime-strategy.md) - Real-time architecture
- [../architecture/performance.md](../architecture/performance.md) - Performance targets

**Personas**:
- [../personas/list-creator.md](../personas/list-creator.md) - Sarah
- [../personas/active-collaborator.md](../personas/active-collaborator.md) - Mike

