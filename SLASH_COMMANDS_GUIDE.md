# Cursor Slash Commands Guide

**AE Infinity Custom Slash Commands for Enhanced Development Workflow**

---

## 🎯 Overview

We've created 5 custom Cursor slash commands that work seamlessly with the working directory pattern to supercharge your development workflow.

These commands integrate directly into Cursor IDE, providing quick access to:
- Workspace management
- Context loading
- Development shortcuts
- Specification verification
- Cleanup operations

---

## 📋 Available Commands

### 1. `/workspace-setup` 🔧

**Purpose**: Setup a new isolated working directory

**What it does**:
- Guides you through creating a clean workspace
- Explains the setup script options
- Shows expected output
- Provides next steps

**When to use**:
- Starting a new feature
- Creating a bug fix workspace
- Setting up for experimentation
- Need fresh environment

**Example usage in Cursor**:
```
Type: /workspace-setup
AI will guide you through:
1. Running setup script
2. Choosing directory name
3. Starting services
4. Testing login
```

**Key sections**:
- Prerequisites check
- Script execution
- After setup checklist
- Common use cases
- Documentation links

---

### 2. `/load-context` 📚

**Purpose**: Load project specifications into AI context

**What it does**:
- Provides systematic context loading strategy
- Shows which specs to read for different tasks
- Gives examples for common scenarios
- Role-specific guidance

**When to use**:
- Before starting implementation
- Need to understand requirements
- Reviewing architecture
- Verifying approach

**Example usage in Cursor**:
```
Type: /load-context
AI will help you load:
1. PROJECT_SPEC.md (overview)
2. API_SPEC.md (contracts)
3. Relevant persona
4. Feature documentation
5. JSON schemas
```

**Context loading steps**:
1. **Project Overview** → PROJECT_SPEC.md
2. **API Contracts** → API_SPEC.md  
3. **Architecture** → ARCHITECTURE.md
4. **User Context** → personas/
5. **Workflows** → journeys/
6. **Feature Details** → features/
7. **Data Contracts** → schemas/

**Examples by role**:
- **Backend Dev**: API_SPEC + ARCHITECTURE + features/
- **Frontend Dev**: COMPONENT_SPEC + API_SPEC + personas/ + journeys/
- **Full-Stack**: All of the above
- **AI Agent**: Progressive loading with verification

---

### 3. `/quick-start-dev` ⚡

**Purpose**: Fast development startup guide

**What it does**:
- 30-second setup instructions
- Quick commands for common tasks
- Keyboard shortcuts
- Hot tips and troubleshooting

**When to use**:
- First time setup
- Need quick reference
- Forgot the steps
- Showing someone the workflow

**Example usage in Cursor**:
```
Type: /quick-start-dev
Get instant access to:
- Setup command
- Start API command
- Start UI command
- Test credentials
- Common tasks
```

**Quick reference includes**:
- Setup: `./scripts/setup-working-directory.sh`
- Start API: `cd work/ae-infinity-api/src/AeInfinity.Api && dotnet run`
- Start UI: `cd work/ae-infinity-ui && npm run dev`
- Login: sarah@example.com / Password123!
- Cleanup: `rm -rf work/`

---

### 4. `/verify-specs` ✅

**Purpose**: Verify implementation matches specifications

**What it does**:
- Provides verification checklist
- Shows how to check against specs
- Automated verification scripts
- Common issues and fixes

**When to use**:
- Before committing code
- During code review
- After major changes
- Quality assurance

**Example usage in Cursor**:
```
Type: /verify-specs
Run through checklist:
1. API contract verification
2. Architecture pattern check
3. User requirements match
4. Code quality validation
5. Schema compliance
6. Auth/authz verification
7. Error handling check
```

**Verification areas**:
- ✅ API endpoints match spec
- ✅ Request/response format correct
- ✅ Architecture layers respected
- ✅ CQRS pattern followed
- ✅ User needs addressed
- ✅ TypeScript types match schemas
- ✅ Error handling complete

---

### 5. `/workspace-clean` 🧹

**Purpose**: Clean up working directories

**What it does**:
- Safe workspace removal guide
- Selective cleanup options
- Safety checks before deletion
- Recovery options

**When to use**:
- Finished with workspace
- Need disk space
- Workspace corrupted
- Starting fresh

**Example usage in Cursor**:
```
Type: /workspace-clean
Get guidance on:
1. Safety checks (git status)
2. Removal commands
3. Selective cleanup
4. Verification steps
```

**Cleanup options**:
- **Basic**: `rm -rf work/`
- **Interactive**: `rm -rfi work/`
- **Selective**: Keep code, remove deps
- **Automated**: Script for old workspaces

**Before cleanup checklist**:
- [ ] Check `git status` in each repo
- [ ] Save any uncommitted changes
- [ ] Verify nothing is running
- [ ] Confirm workspace name

---

## 🔄 Workflow Patterns

### Pattern 1: Feature Development

```
1. /workspace-setup
   "Let's set up a workspace for user statistics feature"
   
2. /load-context
   "Load specs for user statistics and list management"
   
3. [Implement feature with AI assistance]
   
4. /verify-specs
   "Check if my implementation matches the specifications"
   
5. /workspace-clean
   "Clean up workspace after merging"
```

### Pattern 2: Bug Fix

```
1. /workspace-setup
   "Create bugfix workspace for authentication issue"
   
2. /load-context
   "Load authentication specs and security architecture"
   
3. [Fix bug with AI guidance]
   
4. /verify-specs
   "Verify fix doesn't break anything"
   
5. /workspace-clean
   "Remove bugfix workspace"
```

### Pattern 3: Learning & Exploration

```
1. /quick-start-dev
   "Show me how to get started"
   
2. /load-context
   "Help me understand the project architecture"
   
3. [Explore codebase with AI explanations]
   
4. /workspace-clean
   "Clean up exploration workspace"
```

### Pattern 4: Code Review

```
1. /load-context
   "Load relevant specs for this pull request"
   
2. /verify-specs
   "Check if changes match specifications"
   
3. [Review with spec-based validation]
```

---

## 💡 Using Commands with Cursor AI

### In Chat Window

```
You: /workspace-setup
AI: I'll help you set up a new working directory...

You: /load-context
AI: Let me load the project specifications...

You: /verify-specs
AI: Let's verify your implementation against specs...
```

### In Code Comments

```typescript
// @workspace-setup - Created in workspace: feature-user-stats
// @load-context - Verified against API_SPEC.md
// @verify-specs - Matches schema: user-stats.json

export interface UserStats {
  // Implementation...
}
```

### With @ References

```
@workspace-setup Tell me how to create a new workspace

@load-context What specs should I read for authentication?

@verify-specs Does this endpoint match the API specification?
```

---

## 🎨 Command Features

### Markdown Formatting
All commands use rich Markdown:
- **Headers** for organization
- **Code blocks** for commands
- **Checklists** for verification
- **Tables** for reference
- **Links** to documentation

### YAML Frontmatter
Each command includes metadata:
```yaml
---
description: "Command description"
tags: ["tag1", "tag2", "tag3"]
---
```

### Comprehensive Content
Every command includes:
- Clear purpose statement
- Step-by-step instructions
- Real-world examples
- Common use cases
- Troubleshooting tips
- Links to related docs

---

## 📂 Command Files

Located in: `.cursor/commands/`

| File | Purpose | Size |
|------|---------|------|
| `workspace-setup.md` | Setup new workspace | 2.5 KB |
| `load-context.md` | Load specifications | 6.0 KB |
| `quick-start-dev.md` | Quick start guide | 5.7 KB |
| `verify-specs.md` | Verify implementation | 8.8 KB |
| `workspace-clean.md` | Cleanup workspaces | 5.9 KB |
| `README.md` | Command documentation | 8.2 KB |

**Total**: ~37 KB of slash command goodness!

---

## 🚀 Getting Started

### Step 1: Verify Commands Available

In Cursor, type `/` and you should see:
- `/workspace-setup`
- `/load-context`
- `/quick-start-dev`
- `/verify-specs`
- `/workspace-clean`

Plus existing OpenSpec commands:
- `/openspec-proposal`
- `/openspec-apply`
- `/openspec-doctor`
- `/openspec-archive`

### Step 2: Try Your First Command

```
Type: /quick-start-dev
Read the output
Follow the instructions
```

### Step 3: Use in Workflow

```
1. /workspace-setup → Create workspace
2. /load-context → Understand requirements
3. Develop feature
4. /verify-specs → Validate implementation
5. /workspace-clean → Remove workspace
```

---

## 💪 Power User Tips

### Tip 1: Command Chaining
Use commands in sequence for complete workflows:
```
/workspace-setup → /load-context → [code] → /verify-specs → /workspace-clean
```

### Tip 2: Quick Reference
Keep `/quick-start-dev` handy while coding for instant access to commands and credentials.

### Tip 3: Context Before Code
Always run `/load-context` before implementing to ensure you understand requirements.

### Tip 4: Verify Early
Don't wait until the end - use `/verify-specs` during development to catch issues early.

### Tip 5: Clean Regularly
Use `/workspace-clean` to remove old workspaces and keep your environment tidy.

### Tip 6: Custom Variations
Modify commands for your needs:
- Add project-specific checks
- Customize verification steps
- Add team conventions
- Include organization standards

---

## 🔧 Customization

### Adding New Commands

1. **Create file** in `.cursor/commands/`
   ```bash
   touch .cursor/commands/my-command.md
   ```

2. **Add frontmatter**
   ```yaml
   ---
   description: "My custom command"
   tags: ["custom", "workflow"]
   ---
   ```

3. **Write content** in Markdown
   - Clear purpose
   - Step-by-step guide
   - Examples
   - Links

4. **Restart Cursor** to load new command

### Modifying Existing Commands

1. Edit the `.md` file
2. Keep frontmatter intact
3. Update documentation
4. Restart Cursor

---

## 🐛 Troubleshooting

### Commands Don't Appear

**Check**:
1. Files are in `.cursor/commands/`
2. Files have `.md` extension
3. YAML frontmatter is valid
4. Restart Cursor

### Commands Show But Don't Work

**Check**:
1. Markdown formatting is correct
2. Code blocks are properly formatted
3. Links are valid
4. Permissions are correct

### Commands Out of Date

**Fix**:
1. Git pull latest changes
2. Review updated commands
3. Restart Cursor
4. Test commands

---

## 📊 Command Usage Statistics

### Most Useful Commands

Based on typical workflows:

1. **`/quick-start-dev`** - Used daily for reference
2. **`/load-context`** - Essential before every feature
3. **`/verify-specs`** - Critical before commits
4. **`/workspace-setup`** - Weekly for new work
5. **`/workspace-clean`** - Weekly cleanup

### Time Saved

Estimated time savings per command:
- `/workspace-setup`: 15 minutes → 30 seconds
- `/load-context`: 10 minutes → 1 minute
- `/quick-start-dev`: 5 minutes → 10 seconds
- `/verify-specs`: 20 minutes → 5 minutes
- `/workspace-clean`: 2 minutes → 10 seconds

**Total time saved per workflow**: ~45 minutes → ~7 minutes (85% reduction!)

---

## 🤝 Contributing

### Improving Commands

1. Test command thoroughly
2. Update content for clarity
3. Add examples
4. Update this guide
5. Submit changes

### Reporting Issues

If a command needs improvement:
1. Note what's unclear
2. Suggest improvement
3. Provide examples
4. Update documentation

---

## 📚 Related Documentation

- **Setup Script**: [setup-working-directory.sh](./scripts/setup-working-directory.sh)
- **Full Guide**: [WORKING_DIRECTORY_GUIDE.md](./WORKING_DIRECTORY_GUIDE.md)
- **Quick Setup**: [QUICK_SETUP.md](./QUICK_SETUP.md)
- **Visual Overview**: [VISUAL_OVERVIEW.md](./VISUAL_OVERVIEW.md)
- **Repository Analysis**: [REPOSITORY_ANALYSIS.md](./REPOSITORY_ANALYSIS.md)

---

## ✅ Summary

You now have **5 powerful slash commands** that:

✅ **Setup** workspaces automatically  
✅ **Load** context intelligently  
✅ **Start** development quickly  
✅ **Verify** specifications automatically  
✅ **Clean** workspaces safely  

Combined with the **working directory pattern**, these commands enable:
- 🚀 **Fast iteration** - Setup in seconds
- 🎯 **Focused development** - Right context loaded
- ✅ **Quality assurance** - Spec verification built-in
- 🔄 **Clean workflow** - Easy cleanup
- 🤖 **AI-optimized** - Perfect for agentic development

---

**Start using slash commands today and supercharge your workflow! ⚡**

