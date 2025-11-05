# Cursor Slash Commands

Custom slash commands for AE Infinity development workflow.

## Available Commands

### Working Directory Management

#### `/workspace-setup`
Setup a new isolated working directory with all three repositories.

**Use when:**
- Starting a new feature
- Beginning a bug fix
- Creating experimental workspace
- Need clean environment

**What it does:**
- Clones all three repos (API, UI, Context)
- Installs dependencies
- Builds projects
- Verifies setup

**Quick usage:**
```bash
./setup-working-directory.sh [directory-name]
```

---

#### `/workspace-clean`
Clean up working directories and temporary workspaces.

**Use when:**
- Finished with a workspace
- Need to free disk space
- Starting fresh
- Workspace became corrupted

**What it does:**
- Safely removes working directories
- Provides selective cleanup options
- Includes safety checks

**Quick usage:**
```bash
rm -rf work/
```

---

### Development Workflow

#### `/quick-start-dev`
Quick start guide for development in working directory.

**Use when:**
- First time setting up
- Need quick reference
- Showing someone the workflow
- Forgot the steps

**What it does:**
- 30-second setup guide
- Starting both services
- Common tasks reference
- Troubleshooting tips

**Quick usage:**
Setup → Start API → Start UI → Login → Develop

---

#### `/load-context`
Load project specifications into context for AI-assisted development.

**Use when:**
- Starting implementation
- Need to understand requirements
- Reviewing architecture
- Before making changes

**What it does:**
- Guides context loading strategy
- Shows what specs to read
- Provides examples
- Role-specific guidance

**Context loading order:**
1. PROJECT_SPEC.md (overview)
2. API_SPEC.md (contracts)
3. ARCHITECTURE.md (patterns)
4. Persona files (user context)
5. Feature docs (specifics)

---

#### `/verify-specs`
Verify implementation matches specifications.

**Use when:**
- Before committing code
- During code review
- After major changes
- Quality assurance

**What it does:**
- Checklist for verification
- Automated verification scripts
- Common issues & fixes
- Testing guidance

**Verification areas:**
- API contracts
- Architecture patterns
- User requirements
- Code quality
- Data schemas
- Authentication
- Error handling

---

### OpenSpec Integration

#### `/openspec-proposal`
Create an OpenSpec proposal for changes.

**Use when:**
- Planning major changes
- Need architecture review
- Breaking changes planned
- New feature design

---

#### `/openspec-apply`
Apply an OpenSpec proposal.

**Use when:**
- Proposal approved
- Ready to implement
- Need to execute changes

---

#### `/openspec-doctor`
Diagnose OpenSpec setup issues.

**Use when:**
- Setup problems
- Cross-repo issues
- Configuration errors

---

#### `/openspec-archive`
Archive completed OpenSpec proposals.

**Use when:**
- Proposal implemented
- Cleaning up history
- Documentation purposes

---

## Command Usage Patterns

### Pattern 1: New Feature Development

```
1. /workspace-setup
   → Create isolated workspace

2. /load-context
   → Read PROJECT_SPEC.md
   → Read API_SPEC.md
   → Read relevant feature docs

3. Implement feature
   → Make changes in workspace

4. /verify-specs
   → Check against specifications
   → Run tests
   → Fix issues

5. Review & merge
   → Human review
   → Merge to main repos

6. /workspace-clean
   → Remove workspace
```

### Pattern 2: Bug Fix

```
1. /workspace-setup bugfix-xyz
   → Create bugfix workspace

2. /load-context
   → Read relevant specs
   → Understand expected behavior

3. Fix bug in workspace

4. /verify-specs
   → Verify fix works
   → No regressions

5. /workspace-clean
   → Cleanup after merge
```

### Pattern 3: Experimental Development

```
1. /workspace-setup experiment-$(date +%Y%m%d)
   → Create dated experiment workspace

2. Try risky changes

3. /verify-specs
   → Does it work?
   
4. Decision:
   If good → merge
   If bad → /workspace-clean (discard)
```

### Pattern 4: Learning the Codebase

```
1. /workspace-setup learning
   → Create exploration workspace

2. /load-context
   → Read all specs
   → Understand architecture

3. /quick-start-dev
   → Start services
   → Explore UI and API

4. Make experimental changes
   → Learn by doing
   
5. /workspace-clean
   → Remove when done learning
```

## Command Cheat Sheet

| Want to... | Use command... |
|-----------|---------------|
| Create workspace | `/workspace-setup` |
| Start dev quickly | `/quick-start-dev` |
| Understand project | `/load-context` |
| Check implementation | `/verify-specs` |
| Clean up workspace | `/workspace-clean` |
| Propose changes | `/openspec-proposal` |
| Apply proposal | `/openspec-apply` |
| Fix OpenSpec issues | `/openspec-doctor` |

## Tips for Using Slash Commands

### Tip 1: Chain Commands
Use commands in sequence for complete workflows:
```
/workspace-setup → /load-context → [develop] → /verify-specs → /workspace-clean
```

### Tip 2: Custom Workspace Names
Always use descriptive names:
```
./setup-working-directory.sh feature-user-stats
./setup-working-directory.sh bugfix-auth-token
./setup-working-directory.sh experiment-new-arch
```

### Tip 3: Quick Reference During Development
Keep `/quick-start-dev` open for common tasks and troubleshooting.

### Tip 4: Verify Early and Often
Don't wait until the end to run `/verify-specs`. Check as you go.

### Tip 5: Context Before Code
Always run `/load-context` before starting implementation to ensure you understand requirements.

## Integration with Cursor AI

These commands are optimized for use with Cursor AI:

1. **Use in Chat**
   ```
   @workspace-setup
   "I want to implement user statistics feature"
   ```

2. **Reference in Code**
   ```typescript
   // See: /load-context for API contracts
   // Verified with: /verify-specs
   ```

3. **During Development**
   - Ask AI to check specs: "Does this match /load-context?"
   - Verify patterns: "Run /verify-specs checklist"
   - Quick help: "Show me /quick-start-dev"

## File Locations

All slash commands are in:
```
ae-infinity-context/.cursor/commands/
├── README.md                  # This file
├── workspace-setup.md         # Setup command
├── workspace-clean.md         # Cleanup command
├── quick-start-dev.md         # Quick start
├── load-context.md            # Context loading
├── verify-specs.md            # Verification
├── openspec-proposal.md       # OpenSpec proposal
├── openspec-apply.md          # OpenSpec apply
├── openspec-doctor.md         # OpenSpec doctor
└── openspec-archive.md        # OpenSpec archive
```

## Creating Custom Commands

To add your own slash commands:

1. Create a new `.md` file in `.cursor/commands/`
2. Add YAML frontmatter:
   ```yaml
   ---
   description: "Your command description"
   tags: ["tag1", "tag2"]
   ---
   ```
3. Write the command content in Markdown
4. Reference it with `/your-command-name`

## Help & Documentation

- **Setup Guide**: `/workspace-setup`
- **Quick Reference**: `/quick-start-dev`
- **Context Loading**: `/load-context`
- **Verification**: `/verify-specs`
- **Full Docs**: `../WORKING_DIRECTORY_GUIDE.md`

## Troubleshooting Commands

If commands don't work:

1. **Check Cursor Settings**
   - Ensure slash commands are enabled
   - Check command directory path

2. **Verify File Format**
   - YAML frontmatter is correct
   - Markdown is properly formatted

3. **Restart Cursor**
   - Commands are loaded at startup
   - Restart if you add new commands

4. **Check File Permissions**
   ```bash
   ls -la .cursor/commands/
   # All should be readable
   ```

## Contributing

To improve these commands:

1. Test thoroughly
2. Update documentation
3. Add examples
4. Keep patterns consistent
5. Update this README

---

## Quick Links

- **Working Directory Guide**: [WORKING_DIRECTORY_GUIDE.md](../../WORKING_DIRECTORY_GUIDE.md)
- **Quick Setup**: [QUICK_SETUP.md](../../QUICK_SETUP.md)
- **Visual Overview**: [VISUAL_OVERVIEW.md](../../VISUAL_OVERVIEW.md)
- **Repository Analysis**: [REPOSITORY_ANALYSIS.md](../../REPOSITORY_ANALYSIS.md)

---

**Happy coding with slash commands! ⚡**

