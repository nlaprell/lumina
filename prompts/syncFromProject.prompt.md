---
description: Sync user edits from PROJECT.md back to aiDocs/ files
---

You are an AI agent performing a **reverse sync** from the root `PROJECT.md` file back to the source-of-truth files in `aiDocs/`.

## Purpose

When users edit `PROJECT.md` directly, their changes need to be preserved and synced back to `aiDocs/` files before regenerating documentation.

This prompt does **ONLY** the reverse sync - it does not regenerate `PROJECT.md` or `docs/` files. For full bidirectional sync and regeneration, use `/updateSummary`.

## When to Use This Prompt

**Use `/syncFromProject` when:**
- User has edited PROJECT.md directly
- You want to preserve user changes before processing new emails
- You need to update aiDocs/ without regenerating docs
- You want to capture manual status updates

**Don't use this if:**
- You want complete sync (use `/updateSummary` instead)
- PROJECT.md hasn't been edited by user
- You're processing new emails (use `/discoverEmail`)

## Sync Process

### 1. Check if PROJECT.md Exists

If `PROJECT.md` doesn't exist, inform user and exit:

```
PROJECT.md not found. Nothing to sync.

To generate PROJECT.md:
- Run /updateSummary to create from current aiDocs/
- Or run /quickStartProject for complete workflow
```

### 2. Extract User Changes from PROJECT.md

Read `PROJECT.md` and identify user-made changes:

#### A. Task Status Changes
- Tasks marked as completed (✅ or checked boxes)
- New tasks added by user
- Task priority changes
- Deadline updates
- Owner reassignments
- Blocker status changes

#### B. Discovery Questions
- Questions marked as answered
- New questions added by user
- Answers provided to existing questions

#### C. Risk Updates
- Risk status changes (Active → Mitigated, etc.)
- New risks identified
- Mitigation strategy updates
- Risk owner changes

#### D. Contact Updates
- New contacts added
- Contact information corrections (phone, email, role)
- Organization changes

#### E. Decision Updates
- New decisions documented
- Decision rationale added
- Decision status changes

#### F. Status Updates
- Current status changes
- New blockers identified
- Blocker resolution notes
- Progress updates in "Completed Work"
- Recent activity notes

### 3. Update aiDocs/TASKS.md

**For completed tasks:**
- Find task in Outstanding Tasks section
- Move to Completed Tasks section under current date
- Preserve all task metadata
- Update Status to "Completed"

**For new tasks:**
- Assign next sequential task ID (TASK-XXX)
- Add to appropriate priority section
- Include all required metadata:
  - Owner (use "TBD" if not specified)
  - Status (default to "Not Started")
  - Source (mark as "Added via PROJECT.md")
  - Context (from user's description)

**For task updates:**
- Update Status, Owner, or Deadline as changed
- Preserve existing task ID and other metadata
- Note source of change in task history

### 4. Update aiDocs/DISCOVERY.md

**For answered questions:**
- Mark question as [x] (answered)
- Add Answer field with user's response
- Add Source field: "Answered via PROJECT.md - [Date]"
- Update Status to "Answered"

**For new questions:**
- Add to appropriate priority section
- Use checkbox format: `- [ ]`
- Include all required metadata:
  - Ask: [Who would know]
  - Check: [Where to look]
  - Status: Unknown
  - Priority: [Infer from context]

### 5. Update aiDocs/SUMMARY.md

**For risks:**
- Update risk Status if changed
- Add new risks to Risks section with required 8 fields
- Update Mitigation if user added strategies
- Update Owner if reassigned

**For contacts:**
- Add new contacts to Key Contacts section
- Update existing contact information
- Verify email format is correct
- Group by organization

**For decisions:**
- Add new decisions to Decision Log table
- Include: Date, Decision, Made By, Rationale, Source
- Source should reference PROJECT.md and date

**For status updates:**
- Update Current Situation with latest status
- Move old status (>30 days) to Historical Context
- Preserve timeline of changes

### 6. Validation

After syncing, verify:
- [ ] All new task IDs are sequential
- [ ] No task IDs duplicated
- [ ] All cross-references (Blocks, Related) still valid
- [ ] All required metadata present
- [ ] "Last Updated" dates set to current date
- [ ] No placeholders remain

### 7. Generate Sync Report

Provide detailed report of changes:

```markdown
# Reverse Sync Report

**Date**: [Current Date]
**Source**: PROJECT.md → aiDocs/

## Changes Synced

### aiDocs/TASKS.md
- Tasks completed: X (moved to archive)
  - [List TASK-IDs and titles]
- New tasks created: X
  - [List new TASK-IDs and titles]
- Tasks updated: X
  - [List changes: status, owner, deadline]

### aiDocs/DISCOVERY.md
- Questions answered: X
  - [List questions]
- New questions added: X
  - [List questions]

### aiDocs/SUMMARY.md
- Risks updated: X
  - [List risk titles and changes]
- New risks added: X
  - [List new risks]
- Contacts added/updated: X
  - [List contact names]
- Decisions added: X
  - [List decisions]
- Status updated: [Yes/No]

## Validation Results

- Task ID integrity: ✅ PASS / ❌ FAIL
- Cross-references valid: ✅ PASS / ❌ FAIL
- Metadata complete: ✅ PASS / ❌ FAIL

## Next Steps

1. Review changes in aiDocs/ files
2. Run /validateTasks to check task structure
3. Run /updateSummary to regenerate PROJECT.md and docs/ with synced changes
4. Or process new emails with /discoverEmail before regenerating
```

## Important Notes

- **Read-only for PROJECT.md**: This prompt only reads from PROJECT.md, never modifies it
- **Write to aiDocs/**: Updates aiDocs/ files based on user changes
- **Preserves user intent**: Treats PROJECT.md edits as authoritative
- **Does not regenerate**: Run /updateSummary afterward to regenerate docs
- **Validates changes**: Ensures aiDocs/ integrity after sync
- **Source tracking**: Marks changes with "via PROJECT.md" for audit trail

## Workflow Integration

Typical workflow with user edits:
1. User edits PROJECT.md directly
2. Run `/syncFromProject` to preserve changes in aiDocs/
3. Optionally run `/discoverEmail` if new emails exist
4. Run `/updateSummary` to regenerate PROJECT.md and docs/ from updated aiDocs/

This ensures user edits are never lost and remain part of the source of truth.
