---
description: Archive old tasks, detect dependencies, optimize task organization
---

You are an AI agent performing task maintenance and optimization on `aiDocs/TASKS.md`.

## Purpose

As projects mature, the task list grows and needs periodic cleanup to remain manageable and useful. This prompt:
- Archives old completed tasks
- Detects and suggests task dependencies
- Identifies orphaned or stale tasks
- Optimizes task organization
- Improves task metadata quality

## When to Use This Prompt

**Use `/cleanupTasks` when:**
- Task list has grown large (>20 tasks)
- Many tasks completed >30 days ago
- Task dependencies unclear
- Planning major project phase
- Quarterly maintenance

**Don't use this if:**
- Just starting project (few tasks)
- Need validation only (use `/validateTasks`)
- Processing new emails (use `/discoverEmail`)

## Cleanup Process

### 1. Archive Old Completed Tasks

Review Completed Tasks section in `aiDocs/TASKS.md`:

**Archive tasks that are:**
- Completed >30 days ago
- No longer relevant to current work
- Not referenced by any outstanding tasks

**Archive format:**
- Group by month: "### December 2025", "### November 2025"
- Within month, order by completion date
- Preserve all task metadata (ID, title, completion info)
- Keep TASK-ID for reference (never reuse archived IDs)

**Keep in main Completed section:**
- Tasks completed in last 30 days
- Tasks frequently referenced
- Tasks with important lessons learned

### 2. Run Dependency Detection

Execute the automated dependency detector:

```bash
python3 .template/aiScripts/detectTaskDependencies/detectTaskDependencies.py aiDocs/TASKS.md
```

Review `aiDocs/TASK_DEPENDENCY_REPORT.md` and:
- Apply **high confidence** suggestions automatically
- Flag **medium confidence** suggestions for review
- Note **low confidence** suggestions in report
- Resolve any circular dependencies immediately

Update task Blocks and Related fields based on analysis.

### 3. Identify Orphaned Tasks

Find tasks that:
- Have no Blocks or Related references
- Aren't blocked by anything
- Don't appear in other tasks' dependencies
- Might be forgotten or unclear scope

**For each orphaned task:**
- Review if it's still needed
- Determine if it should relate to other work
- Consider if it's miscategorized
- Flag for owner review if uncertain

### 4. Group Related Tasks

Identify task clusters working toward same goal:
- Use Related field to connect tasks in same area
- Suggest creating epic/theme categories if helpful
- Ensure dependencies reflect actual work sequence
- Note opportunities for parallel work

### 5. Optimize Priority Categories

Review task distribution across priority sections:

**High Priority:**
- Should have <10 tasks
- Must have deadline OR block critical work
- Should be actively worked or about to start

**Planning Tasks:**
- Future work, not immediate
- Dependent on decisions not yet made
- Preparatory activities

**Documentation Tasks:**
- Post-completion work
- Process improvements
- Can be done anytime

**Recommend moves:**
- Tasks in wrong section
- Stale high-priority items → planning
- Urgent planning items → high priority

### 6. Improve Task Metadata Quality

For each task, verify and improve:

**Owner:**
- Change "TBD" to actual person if known
- Flag tasks with TBD owner >14 days
- Suggest owners based on related tasks

**Status:**
- Update stale "In Progress" (>30 days with no activity)
- Mark blocked tasks appropriately
- Clear "Blocked" status if blocker resolved

**Context:**
- Ensure description is clear and actionable
- Add missing details from related work
- Reference relevant emails/documents

**Source:**
- Verify source citation is accurate
- Update if additional context found
- Add related email references

**Deadlines:**
- Add deadline if mentioned in emails
- Flag overdue tasks
- Suggest realistic deadlines for critical work

### 7. Detect Circular Dependencies

Check for dependency cycles:
- A blocks B, B blocks A (2-cycle)
- A blocks B blocks C blocks A (3-cycle)
- Longer chains

**For each cycle found:**
- Explain the circular dependency
- Analyze which relationship is incorrect
- Suggest resolution
- Flag for urgent review

### 8. Generate Cleanup Report

Provide comprehensive maintenance report:

```markdown
# Task Cleanup Report

**Date**: [Current Date]
**File**: `aiDocs/TASKS.md`

## Summary

- Total outstanding tasks: X (was Y)
- Tasks archived: X
- Dependencies added: X
- Dependencies updated: X
- Tasks moved between priorities: X
- Orphaned tasks identified: X
- Circular dependencies resolved: X

---

## Changes Made

### Archived Tasks
- Tasks moved to archive: X
  - [List TASK-IDs and titles]
- Archive organized by month
- All TASK-IDs preserved for reference

### Dependencies Updated
- High confidence suggestions applied: X
  - [List key relationships added]
- Circular dependencies resolved: X
  - [List and explain resolutions]

### Task Organization
- Tasks moved to High Priority: X
  - [List with rationale]
- Tasks moved to Planning: X
  - [List with rationale]
- Tasks moved to Documentation: X
  - [List with rationale]

### Metadata Improvements
- Owners assigned: X (was TBD)
  - [List TASK-IDs]
- Status updated: X
  - [List what changed]
- Context enhanced: X
  - [List improvements]
- Deadlines added: X
  - [List with dates]

---

## Orphaned Tasks Identified

**[TASK-XXX]: [Title]**
- **Current State**: No dependencies or relationships
- **Concern**: [Why flagged]
- **Recommendation**: [Suggested action]

---

## Task Clusters Identified

**Cluster 1: [Theme/Goal]**
- TASK-XXX: [Title]
- TASK-XXX: [Title]
- TASK-XXX: [Title]
- **Suggestion**: [How to coordinate these tasks]

---

## Action Items

### Immediate Attention Required
1. [Critical issue to address]
2. [Another critical issue]

### Owner Review Needed
- [TASK-XXX]: Owner TBD >30 days, needs assignment
- [TASK-XXX]: Blocked >14 days, blocker status unclear

### Optimization Opportunities
1. [Suggestion for better organization]
2. [Another suggestion]

---

## Task Health Metrics

**Before Cleanup:**
- Outstanding tasks: Y
- Tasks with TBD owner: Z
- Orphaned tasks: N
- Avg dependencies per task: X.X

**After Cleanup:**
- Outstanding tasks: X
- Tasks with TBD owner: Y (improved by Z%)
- Orphaned tasks: N (flagged for review)
- Avg dependencies per task: X.X

---

## Recommendations

1. [Key recommendation for task management]
2. [Process improvement suggestion]
3. [Planning recommendation]

**Next Steps:**
1. Review orphaned tasks with team
2. Assign owners to TBD tasks
3. Address flagged action items
4. Run /validateTasks to verify integrity
5. Update PROJECT.md with cleaned structure
```

## Important Notes

- **Preserves history**: Archived tasks remain in file with full metadata
- **Never reuses IDs**: TASK-IDs are permanent, even when archived
- **Validates changes**: Ensures no broken references after cleanup
- **Updates timestamps**: Sets "Last Updated" to current date
- **Creates backup**: Recommend backing up before major changes
- **Non-destructive**: All changes are reorganization, not deletion

## Safety Checks

Before finalizing changes:
- [ ] All task IDs still valid (no duplicates, proper sequence)
- [ ] All cross-references (Blocks, Related) point to existing tasks
- [ ] No circular dependencies remain
- [ ] Archive sections properly dated
- [ ] All required metadata present
- [ ] "Last Updated" date current

## Workflow Integration

Typical cleanup workflow:
1. Run `/cleanupTasks` to optimize task structure
2. Run `/validateTasks` to verify integrity
3. Review orphaned tasks with team
4. Assign owners to TBD tasks
5. Run `/updateSummary` to regenerate PROJECT.md with clean structure
6. Commit changes to git
