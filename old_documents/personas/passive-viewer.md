# Persona: The Passive Viewer (Viewer)

**Role**: Viewer  
**Permission Level**: Read-Only

## Profile

**Name**: Emma  
**Age**: 16  
**Occupation**: High School Student  
**Tech Savvy**: High  
**Primary Device**: Mobile (iPhone)

## Background

- Sarah and Mike's teenage daughter
- Lives at home with parents and younger brother
- Gets her own snacks and occasional items
- Learning responsibility through family participation
- Very active on social media and familiar with apps

## Goals

- ✅ See what's on the shopping list
- ✅ Know when parents are shopping
- ✅ Request items to be added (via parents)
- ✅ Know what snacks are coming
- ✅ Learn to plan ahead
- ✅ Feel included in family activities

## Pain Points

- 😫 Can't add items directly (must ask parents)
- 😫 Sometimes parents forget to add her requested items
- 😫 Wants more independence but parents want oversight
- 😫 Misses notifications about shopping trips
- 😫 Can't help when parents are shopping together

## Usage Patterns

- **Frequency**: 2-3 times per week
- **Session Duration**: 30 seconds - 1 minute
- **Peak Usage**: After school, evenings
- **Primary Use Case**: Checking if snacks are on the list
- **Secondary Use Case**: Seeing what's for dinner

### Typical Activities

1. **After School** (3:30 PM)
   - Checks if chips/snacks are on grocery list
   - Sees what parents planned for dinner ingredients
   - Requests items via text message to mom

2. **Evening** (During dinner planning)
   - Looks at list to see what's being bought
   - Knows what meals to expect this week
   - Checks if her preferred items made the cut

3. **Weekend** (Before parents shop)
   - Reviews list one more time
   - Reminds parents about requested items
   - Checks after shopping to see what was actually bought

## Permission Needs

### Viewer Capabilities

✅ **View-Only Access**
- View list names and descriptions
- View all items on lists
- See item details (name, quantity, category, notes, images)
- See who added each item
- See what's been purchased
- See who purchased items

✅ **Real-time Updates**
- See updates as they happen
- View presence indicators (who's viewing/shopping)
- Receive notifications (if enabled)

✅ **Search & Filter**
- Search for specific items
- Filter by category
- Filter by purchased status

### Cannot Do

❌ Cannot add items  
❌ Cannot edit items  
❌ Cannot delete items  
❌ Cannot mark items as purchased  
❌ Cannot reorder items  
❌ Cannot add notes or images  
❌ Cannot change list settings  
❌ Cannot add/remove collaborators  
❌ Cannot change permissions  
❌ Cannot delete or archive lists

### Why Read-Only?

Parents (Sarah & Mike) chose Viewer role for Emma because:
- They want oversight of what gets added to lists
- Budget control (Emma might add expensive items)
- Teaching responsibility gradually
- Emma can still participate and feel included
- May upgrade to Editor as she demonstrates responsibility

## Key Features Used

1. **List Viewing** ⭐⭐⭐⭐
   - Checks what snacks are on the list
   - Sees what ingredients for favorite meals
   - Knows what to expect

2. **Real-time Updates** ⭐⭐⭐
   - Sees when parents add her requested items
   - Knows when parents are shopping
   - Gets excited when favorite items appear

3. **Notifications** ⭐⭐
   - Enabled for when items she cares about are added
   - Gets notified when shopping is complete
   - Limited to avoid notification fatigue

4. **Search** ⭐⭐⭐
   - Searches for specific snack brands
   - Checks if healthy options are there (for school lunch)
   - Quick way to find items in long lists

## Interaction Examples

### Checking for Snacks

```
1. After school, opens app
2. Opens "Weekly Groceries" list
3. Searches for "chips" or "snacks"
4. Sees "Hot Cheetos" on the list
5. Happy! Closes app
   Total time: 15 seconds
```

### Request Flow (Multi-step)

```
1. Emma checks list → Her requested cookies not there
2. Texts mom: "Can we get Oreos?"
3. Mom adds Oreos to list
4. Emma gets notification: "Oreos added to Weekly Groceries"
5. Emma opens app to confirm
6. Sees Oreos on list → Satisfied
```

### During Shopping

```
1. Mom shopping at store (Emma sees presence indicator)
2. Emma browses list to see what's being bought
3. Sees Mom marked "Oreos" as purchased ✅
4. Emma is assured cookies are coming home
```

## User Quotes

> "I like being able to see what we're getting. Makes me feel included even though I can't add stuff myself."

> "Sometimes I wish I could just add things without asking, but I get why my parents want to approve first."

> "It's cool when I get the notification that my requested item was added. Feels like they listened."

> "I mostly use it to check if my snacks made the list. Quick in-and-out."

## Evolution / Transition

Emma represents a **transitional role**:

**Current State**: Viewer (Age 16)
- Parents maintain control
- Emma builds trust and demonstrates responsibility
- Learning to plan ahead and request appropriately

**Future State**: Editor (Age 17-18)
- Parents grant Editor access
- Emma can add items directly
- More independence as she contributes to household
- Prepares her for college/independent living

### Trust Building

Emma can demonstrate responsibility by:
- Requesting reasonable items
- Understanding budget constraints
- Respecting parents' decisions
- Using the app appropriately
- Contributing to household planning

When parents see these behaviors, they may promote Emma to Editor role.

## Alternative Viewer Use Cases

### Viewer: The Roommate's Friend

**Scenario**: College roommate shares list with friends coming to dinner
- Friend can see what's needed for party
- Friend offers to pick up items
- Roommate maintains control of list

### Viewer: The Personal Assistant

**Scenario**: Busy executive shares list with assistant
- Assistant knows what to buy
- Executive maintains final say
- Clear visibility without modification risk

### Viewer: The House Guest

**Scenario**: Short-term guest needs to know household items
- Guest can see what's stocked
- Guest won't accidentally modify/delete
- Temporary access easily revoked

## Related Documentation

- **Permissions**: [permission-matrix.md](./permission-matrix.md) - Permission comparison
- **Journeys**: [../journeys/viewer-to-editor-transition.md](../journeys/viewer-to-editor-transition.md)
- **API**: [../api/lists.md](../api/lists.md) - List access control
- **Architecture**: [../architecture/security.md](../architecture/security.md) - Role-based access

