---
name: create-skill
description: Meta-skill — create a new skill for your AI assistant from scratch.
user-invocable: true
---

# Create Skill

## When to Use
When the user wants to add a new capability by creating a new skill.

## Process

### 1. Gather Info
Ask the user (or infer from context):
- **Name**: Skill identifier (lowercase, hyphens)
- **Description**: One-line description
- **User-invocable**: Should it be a `/command`? (default: yes)
- **What it does**: Step-by-step behavior

### 2. Create Skill Directory
Create `.claude/skills/<name>/SKILL.md` in the **current project** (skills are project-specific).

### 3. Generate SKILL.md
Use the standard skill template format.

### 4. Create Supporting Scripts (if needed)
Save to `~/.claude/cortex/scripts/` (shared across projects) and make executable.

### 5. Log Creation
Add a note to `~/.claude/cortex/memory/conversations.md`:
```
## YYYY-MM-DD - Created skill: <name>
- Description: <what it does>
```

### 6. Test
Suggest the user test the skill interactively.

## Guidelines
- Keep skills focused on a single capability
- SKILL.md should be < 500 lines
- Shared scripts go in `~/.claude/cortex/scripts/`
- Project-specific skills go in the project's `.claude/skills/`
