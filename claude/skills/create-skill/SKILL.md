---
name: create-skill
description: Create a new Claude Code skill with the correct format by checking the latest docs first
argument-hint: <skill-name> <description>
disable-model-invocation: true
---

# Create a Claude Code Skill

You are creating a new Claude Code skill. **Before doing anything else**, you MUST look up the latest documentation to ensure you are using the current correct format.

## Step 1: Check the latest docs (MANDATORY)

Fetch the official Claude Code skills documentation to check for any updates to the skill format:

- Visit https://docs.anthropic.com/en/docs/claude-code/skills
- Look for: correct directory structure, SKILL.md format, supported frontmatter fields, any new features or changes

Do NOT skip this step. Do NOT rely on your training data. The skill format may have changed.

## Step 2: Ask the user

Clarify with the user:
- **Skill name**: What should the slash command be called?
- **Scope**: Global (`~/.claude/skills/`) or project-level (`.claude/skills/`)?
- **What it does**: What instructions should the skill contain?
- **Who can invoke it**: User only, Claude only, or both?

Use the information from $ARGUMENTS if the user already provided a name and description.

## Step 3: Create the skill

Using the format confirmed from the docs in Step 1:
1. Create the directory at the correct path
2. Write the `SKILL.md` file with proper YAML frontmatter and markdown instructions
3. Verify the file was created successfully

## Step 4: Confirm

Tell the user:
- Where the skill was created
- How to invoke it
- What frontmatter options were set and why
