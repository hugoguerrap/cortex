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
- **Name**: Skill identifier (lowercase, hyphens, e.g., `email-checker`)
- **Description**: One-line description
- **User-invocable**: Should it be a `/command`? (default: yes)
- **What it does**: Step-by-step behavior

### 2. Create Directory
```
.claude/skills/<name>/
  SKILL.md
```

### 3. Generate SKILL.md
Use this template:

```yaml
---
name: <name>
description: <description>
user-invocable: <true|false>
---

# <Name>

## When to Use
<Scenarios where this skill activates>

## Steps
<Step-by-step instructions>

## Output
<What the skill produces>

## Error Handling
<What to do when things go wrong>
```

### 4. Create Supporting Scripts (if needed)
If the skill requires shell or Python scripts:
- Create them in `scripts/` (project root, not skill directory)
- Make them executable: `chmod +x scripts/<script>`
- Reference them from the SKILL.md

### 5. Update Memory
Add a note to `memory/conversations.md`:
```
## YYYY-MM-DD - Created skill: <name>
- Description: <what it does>
- Files: .claude/skills/<name>/SKILL.md
```

### 6. Test
Suggest the user test the skill interactively before relying on it in automation.

## Guidelines
- Keep skills focused on a single capability
- SKILL.md should be < 500 lines
- Reference existing scripts when possible
- Follow patterns of existing skills in the project
