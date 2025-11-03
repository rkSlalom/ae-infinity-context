# User Personas

## Overview

AE Infinity serves multiple user types with different needs, goals, and access levels. Understanding these personas helps guide feature prioritization, UX design, and permission models.

---

## Primary Personas

### 1. The List Creator (Owner)

**Profile**: Sarah, 34, Working Parent  
**Tech Savvy**: Medium  
**Primary Device**: Mobile (iPhone)

**Background**:
- Manages household shopping for family of 4
- Shops weekly at multiple stores
- Coordinates with spouse and older children
- Values organization and efficiency

**Goals**:
- Create and organize multiple shopping lists (groceries, household items, special occasions)
- Share lists with family members
- Control who can edit vs. just view lists
- Track what's been purchased in real-time while shopping
- Avoid duplicate purchases when multiple family members shop

**Pain Points**:
- Family members don't see updates when shopping separately
- Confusion about who's buying what
- Kids adding items without asking first
- Need to revoke access when circumstances change

**Usage Patterns**:
- Creates 3-5 lists (Weekly Groceries, Costco Run, Party Shopping, etc.)
- Checks list multiple times per day
- Actively manages who has access to which lists
- Archives old lists for reference

**Permission Needs**:
- **Full Control**: Create, edit, delete lists
- **Manage Collaborators**: Add/remove people, change permissions
- **Archive/Restore**: Manage list lifecycle
- **Transfer Ownership**: Pass control to spouse if needed

**Key Features Used**:
- List creation and organization
- Sharing with custom permissions
- Real-time updates and presence
- Categories for store organization
- Item notes and images

---

### 2. The Active Collaborator (Editor)

**Profile**: Mike, 36, Sarah's Spouse  
**Tech Savvy**: Medium-High  
**Primary Device**: Mobile (Android) + Tablet

**Background**:
- Shares shopping responsibilities with Sarah
- Often shops on the way home from work
- Adds items throughout the week as they run out
- Tech-comfortable and likes efficiency tools

**Goals**:
- Quickly add items to shared lists
- Check off items while shopping
- See what others have already purchased
- Add notes about preferences (brands, quantities)
- Be notified of urgent additions

**Pain Points**:
- Can't delete lists Sarah created (but wants to)
- Sometimes over-purchases when others shop simultaneously
- Needs to communicate about substitutions

**Usage Patterns**:
- Adds 5-10 items per week
- Shops 2-3 times per week
- Checks list before leaving work
- Uses voice input while driving

**Permission Needs**:
- **Add/Edit Items**: Full item management
- **Mark as Purchased**: Update item status
- **Add Notes**: Communicate with other collaborators
- **View All List Details**: See who added what and when
- **Cannot**: Delete the list, remove owner, change others' permissions

**Key Features Used**:
- Quick item addition
- Real-time sync while shopping
- Item search and history
- Category filtering
- Presence indicators (who's shopping now)

---

## Secondary Personas

### 3. The Teen Helper (Editor - Limited)

**Profile**: Emma, 16, Daughter  
**Tech Savvy**: High  
**Primary Device**: Mobile (iPhone)

**Background**:
- Responsible teen learning household management
- Sometimes does small shopping trips
- Often requests items to be added to list
- Very active on social media and apps

**Goals**:
- Request items be added to list
- Help with shopping when asked
- Check off items completed
- Learn to be responsible with household tasks

**Pain Points**:
- Parents worry about accidental deletions
- Can be impulsive with adding non-essential items
- Needs guidance on quantities and brands

**Usage Patterns**:
- Adds items occasionally (3-5 per week)
- Shops once a month with parent supervision
- Checks list when asked to pick up items
- Most active on weekends

**Permission Needs**:
- **Add Items**: Can suggest additions
- **Edit Own Items**: Modify items they added
- **Mark as Purchased**: During shopping
- **View List**: See all items and categories
- **Cannot**: Delete items others added, change list settings, remove collaborators

**Key Features Used**:
- Quick add via mobile
- Item suggestions from history
- Simple categorization
- Notifications for list updates

---

### 4. The Extended Family (Viewer)

**Profile**: Grandma Betty, 68, Sarah's Mother  
**Tech Savvy**: Low-Medium  
**Primary Device**: Tablet (iPad)

**Background**:
- Lives nearby and helps family occasionally
- Visits weekly and likes to bring needed items
- Not comfortable making changes without asking
- Appreciates seeing what family needs

**Goals**:
- See what family needs before visiting
- Know what's already been purchased
- Offer to pick up items during her shopping
- Stay connected with family activities

**Pain Points**:
- Doesn't want to accidentally change things
- Overwhelmed by too many features
- Needs simple, read-only access
- Wants notifications but not too many

**Usage Patterns**:
- Checks list 2-3 times per week before visiting
- Rarely adds items (asks Sarah instead)
- Prefers phone calls for questions
- Values simplicity

**Permission Needs**:
- **View Only**: See all list items and details
- **Print/Export**: Create shopping reference
- **Cannot**: Add, edit, or delete anything
- **Optional**: Comment/suggest items (future feature)

**Key Features Used**:
- Simple list viewing
- Large text/accessibility features
- Print-friendly view
- Minimal notifications

---

### 5. The Roommate/Temporary Collaborator (Editor - Time-Limited)

**Profile**: Alex, 28, College Roommate  
**Tech Savvy**: High  
**Primary Device**: Mobile (Various)

**Background**:
- Shares apartment with 2 others
- Splits grocery costs
- Temporary living situation (1-year lease)
- Tech-native generation

**Goals**:
- Contribute to shared household lists
- Track shared expenses
- Coordinate shopping rotations
- Easy to remove access when lease ends

**Pain Points**:
- Needs equal editing rights
- Wants to avoid permanent access
- Concerned about privacy after moving out
- Needs clear expense tracking

**Usage Patterns**:
- Active for duration of lease
- Adds items weekly
- Shops on rotation (every 3rd week)
- Checks list frequently

**Permission Needs**:
- **Full Editor Rights**: During collaboration period
- **Automatic Expiration**: Set end date for access (future feature)
- **Equal Participation**: Same as other roommates
- **Clean Exit**: Complete removal of access when leaving

**Key Features Used**:
- Item addition and editing
- Price tracking (future feature)
- Shopping history
- Fair rotation coordination

---

## Permission Tiers Summary

### 🔷 Owner (List Creator)
**Full Control**: Everything below, plus:
- Delete entire list
- Transfer ownership
- Manage all collaborators
- Change list settings
- Archive/unarchive
- Cannot be removed from list

### 🔶 Editor (Active Collaborator)
**Content Management**:
- Add items
- Edit items
- Delete items
- Mark items as purchased
- Add notes and images
- Reorder items
- View purchase history
- See all collaborators
- Cannot: Manage permissions, delete list

### 🔵 Editor - Limited (Supervised Access)
**Restricted Editing**:
- Add items
- Edit own items only
- Mark items as purchased
- View list and history
- Cannot: Delete others' items, manage collaborators, change settings

### 🟢 Viewer (Read-Only)
**View Only**:
- See all list items
- View categories
- See purchase status
- View history
- Cannot: Make any changes

### 🟡 Pending (Invited, Not Yet Accepted)
**No Access Until Accepted**:
- Receives invitation
- Can preview list name/description
- Must accept to gain assigned permission level
- Invitation can be revoked

---

## User Journey Examples

### Journey 1: Family Weekly Shopping

1. **Sarah (Owner)** creates "Weekly Groceries" list
2. **Sarah** adds Mike as Editor
3. **Sarah** adds Emma as Editor-Limited
4. **Mike** adds items during the week
5. **Emma** requests snacks (adds items)
6. **Sarah** reviews and approves Emma's additions
7. **Saturday**: Sarah goes shopping, marks items purchased
8. **Real-time**: Mike sees updates while at soccer practice
9. **Emma** checks list to see what was bought

### Journey 2: Holiday Party Planning

1. **Sarah (Owner)** creates "Thanksgiving Dinner" list
2. **Sarah** adds Mike as Editor
3. **Sarah** adds Grandma Betty as Viewer
4. **Sarah** adds sister as Editor (temporary)
5. **Multiple people** add items throughout the week
6. **Betty** checks list before visiting, brings items
7. **Day of**: Multiple people shopping at different stores
8. **Real-time sync** prevents duplicate purchases
9. **After party**: Sarah archives list for next year

### Journey 3: Roommate Coordination

1. **Alex** creates "Apartment Supplies" list
2. **Alex** adds Roommate 1 as Editor
3. **Alex** adds Roommate 2 as Editor
4. **All three** add items equally
5. **Rotation**: Each person shops every 3rd trip
6. **Active shopper** marks items purchased
7. **Others** see real-time updates
8. **Lease ends**: Alex removes all collaborators, deletes list

### Journey 4: Permission Evolution

**Week 1**: Sarah creates list, adds Mike as Editor
**Month 2**: Emma turns 16, gets Editor-Limited access
**Month 6**: Sarah adds Grandma Betty as Viewer
**Year 1**: Emma proves responsible, upgraded to full Editor
**Year 2**: Emma goes to college, access revoked
**Year 3**: New baby, Sarah adds nanny as Editor-Limited

---

## Persona-Driven Feature Priorities

### High Priority (All Personas)
- Clean, intuitive list creation
- Easy sharing with permission selection
- Real-time updates and sync
- Mobile-first design
- Clear indication of who changed what

### Medium Priority (Creators & Active Collaborators)
- Category management
- Item history and suggestions
- Bulk actions (add multiple items)
- List templates
- Notification preferences

### Future Considerations
- Time-limited access (Alex's use case)
- Permission upgrade requests (Emma wants full editor)
- Comment/suggestion system (Betty wants to suggest without editing)
- Expense tracking (roommate scenarios)
- Recipe integration (Sarah's meal planning)

---

## Accessibility Considerations by Persona

### Sarah (Creator)
- Needs quick actions for busy lifestyle
- One-handed mobile use
- Voice input while driving

### Mike (Active Collaborator)
- Dark mode for evening shopping
- Large tap targets in stores
- Offline support in poor signal areas

### Emma (Teen)
- Fast, modern interface
- Social-like interactions
- Rich media (images, emojis)

### Betty (Viewer)
- Large text options
- High contrast mode
- Simple navigation
- Minimal learning curve
- Print-friendly views

### Alex (Temporary)
- Clear data privacy
- Easy onboarding
- Clean offboarding
- Export personal data

---

## Design Implications

### For Owners
- Prominent "Share" and "Manage Access" buttons
- Visual permission indicators
- Bulk permission changes
- Ownership transfer workflow

### For Editors
- Fast item addition (single tap)
- Clear indication of editing permissions
- Undo functionality
- Conflict resolution UI

### For Viewers
- Obvious "Read-Only" indicators
- Hide edit/delete buttons
- Focus on clarity and readability
- Easy upgrade request (future)

### For All Users
- Clear visual hierarchy of permissions
- Role badges next to user names
- Permission explanations in tooltips
- Graceful permission change notifications

---

## Security & Privacy by Persona

### Owner Concerns
- Who has access to my lists?
- Can I revoke access instantly?
- Will I know if someone shares further?
- Can I see what others have done?

### Collaborator Concerns
- What can others see about my activity?
- Are my additions permanent?
- Can I leave a list?
- What happens to my data when removed?

### Viewer Concerns
- Am I accidentally changing things?
- Who knows I'm viewing?
- Can I trust this is read-only?

### Design Solutions
- Clear audit logs
- Activity indicators
- Easy permission viewing
- Instant revocation
- Data export on removal
- Privacy settings

---

This persona document should guide all UX decisions, feature prioritization, and permission model implementation throughout the AE Infinity project.

