# User Journeys

This directory contains step-by-step user journeys showing how different personas accomplish key tasks in AE Infinity.

## 📁 Journey Files

- **[creating-first-list.md](./creating-first-list.md)** - First-time user experience
  - Account creation
  - Creating their first shopping list
  - Adding initial items

- **[sharing-list.md](./sharing-list.md)** - Collaboration setup
  - How Owners share lists
  - Setting appropriate permissions
  - Inviting collaborators

- **[shopping-together.md](./shopping-together.md)** - Real-time collaboration
  - Multiple people shopping simultaneously
  - Real-time updates and coordination
  - Avoiding duplicate purchases

- **[managing-permissions.md](./managing-permissions.md)** - Access control
  - Changing collaborator permissions
  - Removing collaborators
  - Transferring ownership

## 🎯 Journey Structure

Each journey document includes:
- **Persona**: Which user type is taking this journey
- **Goal**: What they want to accomplish
- **Preconditions**: What must be true to start
- **Steps**: Detailed walkthrough with screenshots references
- **Success Criteria**: How to know it worked
- **Error Handling**: Common problems and solutions
- **Related Features**: Links to relevant documentation

## 🔗 Cross-References

### By Persona

**List Creator (Owner)** journeys:
- [creating-first-list.md](./creating-first-list.md)
- [sharing-list.md](./sharing-list.md)
- [managing-permissions.md](./managing-permissions.md)

**Active Collaborator (Editor)** journeys:
- [shopping-together.md](./shopping-together.md)

**Passive Viewer** journeys:
- (Primarily observes, less active journeys)

### By Feature Area

**List Management**:
- [creating-first-list.md](./creating-first-list.md)

**Collaboration**:
- [sharing-list.md](./sharing-list.md)
- [shopping-together.md](./shopping-together.md)
- [managing-permissions.md](./managing-permissions.md)

**Real-time Features**:
- [shopping-together.md](./shopping-together.md)

## 🔗 Related Documentation

- **Personas**: [../personas/](../personas/) - Who these users are
- **API**: [../api/](../api/) - Technical implementation
- **Components**: [../components/](../components/) - UI components used
- **Architecture**: [../architecture/realtime-strategy.md](../architecture/realtime-strategy.md) - Real-time tech

## 💡 Using Journeys

**For Product Managers**:
- Understand user workflows
- Identify pain points
- Plan feature improvements

**For Designers**:
- Design appropriate UI flows
- Ensure consistent UX
- Plan error states

**For Developers**:
- Understand end-to-end feature usage
- Identify API endpoints needed
- Plan real-time event handling

**For QA**:
- Create test scenarios
- Validate user flows
- Test edge cases

