# Persona: The Active Collaborator (Editor)

**Role**: Editor  
**Permission Level**: Modify Items

## Profile

**Name**: Mike  
**Age**: 36  
**Occupation**: Software Engineer  
**Tech Savvy**: Medium-High  
**Primary Device**: Mobile (Android)  
**Secondary Device**: Tablet (at home)

## Background

- Shares shopping responsibilities with spouse Sarah
- Often shops on the way home from work
- Adds items throughout the week as they run out
- Tech-comfortable and likes efficiency tools
- Appreciates automation and smart features

## Goals

- ✅ Quickly add items to shared lists
- ✅ Check off items while shopping in real-time
- ✅ See what others have already purchased
- ✅ Add notes about preferences (brands, quantities)
- ✅ Be notified of urgent additions
- ✅ Shop efficiently with minimal friction

## Pain Points

- 😫 Can't delete lists Sarah created (but sometimes wants to)
- 😫 Sometimes over-purchases when others shop simultaneously
- 😫 Needs to communicate about substitutions
- 😫 Wants to suggest items without cluttering the main list
- 😫 Forgets to check list before shopping

## Usage Patterns

- **Frequency**: 5-10 times per week
- **Session Duration**: 1-3 minutes per session
- **Peak Usage**: Commute times, during shopping
- **Shopping Frequency**: 2-3 times per week
- **Active Lists**: 2-3 (shared with Sarah)

### Typical Activities

1. **Throughout the Week** (As needed)
   - Add items as they run out (milk, eggs, etc.)
   - Quick 30-second interactions
   - Often adds items while doing other tasks

2. **Before Shopping** (On commute home, 5:30 PM)
   - Opens app to check list
   - Filters by category (just need produce today)
   - Reviews notes from Sarah

3. **While Shopping** (Store, 6:00 PM)
   - Marks items as purchased in real-time
   - Adds forgotten items on the spot
   - Sees Sarah added something (real-time)
   - Responds via item notes if substitution needed

4. **After Shopping** (Rarely)
   - Reviews what's left on list
   - Removes items he forgot to mark as purchased

## Permission Needs

### Editor Capabilities

✅ **Item Management**
- Add new items to lists
- Edit item details (name, quantity, unit, category, notes)
- Delete items (even ones he didn't add)
- Mark items as purchased/unpurchased
- Reorder items via drag-and-drop
- Add images to items

✅ **List Viewing**
- View all list details
- See all collaborators
- See who added each item
- See who purchased each item
- View item history and timestamps

✅ **Real-time Features**
- See live updates from other collaborators
- View presence indicators (who's shopping now)
- Receive push notifications for updates

✅ **Search & Filter**
- Search across items
- Filter by category
- Filter by purchased status

### Cannot Do

❌ Cannot edit list name or description  
❌ Cannot add or remove collaborators  
❌ Cannot change permissions  
❌ Cannot delete the list  
❌ Cannot archive/unarchive lists  
❌ Cannot transfer ownership  
❌ Cannot change list settings

## Key Features Used

1. **Quick Item Addition** ⭐⭐⭐⭐⭐
   - Opens app, adds item, closes app in 30 seconds
   - Uses voice input while driving
   - Suggests items from history

2. **Real-time Sync While Shopping** ⭐⭐⭐⭐⭐
   - Marks items purchased immediately
   - Sees Sarah's updates in real-time
   - Avoids buying duplicates

3. **Item Search & History** ⭐⭐⭐⭐
   - Searches for items across lists
   - Sees frequently purchased items
   - Quick-add from purchase history

4. **Category Filtering** ⭐⭐⭐⭐
   - Filters to see only produce section
   - Shops more efficiently
   - Follows store layout

5. **Presence Indicators** ⭐⭐⭐⭐
   - Sees Sarah is shopping now
   - Coordinates who buys what
   - Sends quick notes when needed

## Interaction Examples

### Adding an Item (Mobile)

```
1. Notice milk is low → Open app
2. App already shows "Weekly Groceries" (most recent list)
3. Tap "+" button
4. Type "milk" → Autocomplete suggests "Milk, Whole, 1 gallon"
5. Tap suggestion → Item added
6. Close app
   Total time: 20 seconds
```

### Shopping (Mobile)

```
1. Open app while walking into store
2. See list sorted by category (produce, dairy, etc.)
3. Tap checkbox as items go in cart
4. See Sarah added "Coffee" 2 minutes ago
5. Mark items purchased in real-time
6. Add forgotten item "Bananas" on the spot
```

### Coordinating with Sarah (Real-time)

```
Scenario: Both shopping simultaneously
- Mike sees Sarah marked "Milk" as purchased
- Mike skips milk aisle
- Mike adds note to "Bread": "Got wheat instead, bakery was out of white"
- Sarah sees note and responds with thumbs up
```

## User Quotes

> "I love that I can just check things off as I shop. It's so satisfying and Sarah knows exactly what I got."

> "The app saved us from buying duplicate milk three times this month. We can see each other shopping in real-time."

> "I wish I could delete the old party planning list, but I get why Sarah wants to keep it."

> "Voice input while driving is a game-changer. I can add stuff without taking my hands off the wheel."

## Success Metrics

- **Primary**: Can add items quickly and efficiently
- **Secondary**: Avoids duplicate purchases
- **Engagement**: Uses app 7-10 times per week
- **Shopping Efficiency**: Completes shopping 15% faster

## Feature Requests / Wish List

1. **Suggested Items**: Based on purchase history and patterns
2. **Voice Commands**: "Add milk to grocery list"
3. **Store Maps**: Navigate to items in unfamiliar stores
4. **Price Tracking**: See if prices increased since last purchase
5. **Recipe Integration**: Add all ingredients from a recipe

## Related Documentation

- **Permissions**: [permission-matrix.md](./permission-matrix.md) - Full permission details
- **Journeys**: [../journeys/shopping-together.md](../journeys/shopping-together.md)
- **API**: [../api/items.md](../api/items.md) - Item management endpoints
- **Real-time**: [../api/realtime-events.md](../api/realtime-events.md) - SignalR events

