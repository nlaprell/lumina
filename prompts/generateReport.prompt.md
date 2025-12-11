---
description: Generate executive status report from current project state
---

You are an AI agent creating an executive status report for project stakeholders.

## Purpose

Generate a concise, high-level status report suitable for:
- Weekly status updates
- Management reviews
- Stakeholder briefings
- Client updates
- Sprint retrospectives

This report focuses on **what executives need to know** - progress, blockers, risks, and decisions needed - not comprehensive technical details.

## When to Use This Prompt

**Use `/generateReport` when:**
- Preparing weekly/monthly status updates
- Management review meeting upcoming
- Client wants progress summary
- Quarterly reporting period
- Major milestone reached

**Don't use this if:**
- Need full project context (read PROJECT.md)
- Want to update documentation (use `/updateSummary`)
- Processing new information (use `/discoverEmail`)

## Report Generation Process

### 1. Gather Current State

Read from `aiDocs/` and `PROJECT.md`:
- Current project phase/status
- Recent progress (last 7-14 days)
- Outstanding high-priority work
- Active blockers
- Critical risks
- Key decisions needed

### 2. Generate Report Structure

Create report with these sections:

```markdown
# Project Status Report

**Project**: [Project Name from Quick Context]
**Report Date**: [Current Date]
**Reporting Period**: [Date Range, e.g., "December 4-11, 2025"]
**Status**: [Green 🟢 / Yellow 🟡 / Red 🔴]

---

## Executive Summary

[2-3 sentences summarizing overall status, key achievement, and primary concern]

**Overall Health**: [Green/Yellow/Red] - [Brief explanation]

---

## Progress This Period

### Completed Work

- [Key accomplishment 1 with impact]
- [Key accomplishment 2 with impact]
- [Key accomplishment 3 with impact]

### Work In Progress

- [Active task 1] - [% complete or ETA]
- [Active task 2] - [% complete or ETA]
- [Active task 3] - [% complete or ETA]

---

## Blockers & Risks

### 🔴 Critical Blockers

**[Blocker Title]**
- **Impact**: [What's blocked]
- **Owner**: [Who's working it]
- **ETA for Resolution**: [When expected to clear]

### ⚠️ Active Risks

**[Risk Title]** - [Severity: High/Medium/Low]
- **Likelihood**: [Certain/Likely/Possible/Unlikely]
- **Impact**: [What could go wrong]
- **Mitigation**: [What we're doing about it]

---

## Decisions Needed

1. **[Decision Title]**
   - **By When**: [Date]
   - **Who Decides**: [Person/Role]
   - **Context**: [Why this decision matters]
   - **Options**: [Brief list if applicable]

---

## Next Period Plan

**Focus Areas** (Next 7-14 days):
1. [Primary focus]
2. [Secondary focus]
3. [Tertiary focus]

**Key Deliverables**:
- [Deliverable 1] - [Target date]
- [Deliverable 2] - [Target date]

---

## Metrics

- **Tasks Completed**: X this period, Y total
- **Tasks Remaining**: X high priority, Y total
- **On-Time Performance**: X% (tasks completed by deadline)
- **Active Blockers**: X
- **Team Utilization**: [If applicable]

---

## Key Contacts

[Only if useful for this report - link to docs/CONTACTS.md for full list]

---

## Notes

[Any additional context, concerns, or observations]

---

*For detailed information, see PROJECT.md and aiDocs/ folder.*
*Questions? Contact [Project Lead Name] at [email]*
```

### 3. Determine Status Color

Use this logic for overall status indicator:

**🟢 Green** (On Track):
- All critical tasks progressing
- No major blockers
- Risks under control
- On schedule and budget
- Team healthy and productive

**🟡 Yellow** (At Risk):
- Some delays but recoverable
- 1-2 blockers present
- Medium/high risks active
- Slightly behind schedule
- Needs management attention

**🔴 Red** (Critical):
- Major blockers preventing progress
- High-severity risks likely to occur
- Significantly behind schedule
- Critical decisions overdue
- Requires immediate intervention

### 4. Focus on Impact

For each item, explain **impact and significance**:
- ❌ "Fixed authentication bug"
- ✅ "Fixed authentication bug enabling secure user access - unblocks testing"

- ❌ "Waiting on database schema"
- ✅ "Waiting on database schema - blocks all data migration work (3 tasks, 2 engineers)"

### 5. Use Appropriate Detail Level

**Executives need:**
- What's the big picture? (status color + exec summary)
- What got done? (completed work with impact)
- What's blocked? (blockers with ETA)
- What decisions do I need to make? (decisions needed)
- What's next? (next period plan)

**Executives don't need:**
- Technical implementation details
- Complete task lists
- Historical context
- Low-severity issues already being handled

### 6. Save Report

Save report to: `reports/status-YYYY-MM-DD.md`

Create `reports/` directory if it doesn't exist.

### 7. Generate Report Summary

After creating report, provide brief summary:

```markdown
# Status Report Generated

**File**: `reports/status-[Date].md`
**Overall Status**: [Green 🟢 / Yellow 🟡 / Red 🔴]

**Key Highlights:**
- Completed: [X items]
- Active Blockers: [X critical items]
- Risks: [X high-severity]
- Decisions Needed: [X urgent]

**Next Steps:**
1. Review report in `reports/` folder
2. Share with stakeholders
3. Schedule any decision-making meetings
4. Address critical blockers

**Report Period**: [Date range]
```

## Report Variations

Depending on audience, adjust emphasis:

### Weekly Status (Internal Team)
- Focus: Recent progress, immediate blockers
- Detail: Medium (include task IDs)
- Tone: Technical, actionable

### Monthly Summary (Management)
- Focus: Trends, major milestones, budget/schedule
- Detail: Low (high-level only)
- Tone: Business-focused, strategic

### Client Update
- Focus: Deliverables, value delivered, upcoming work
- Detail: Medium (outcomes not process)
- Tone: Professional, reassuring

### Milestone Report
- Focus: What was achieved, lessons learned
- Detail: Medium (narrative with metrics)
- Tone: Retrospective, analytical

## Important Notes

- **Concise**: Keep executive summary to 2-3 sentences
- **Honest**: Don't hide problems, but propose solutions
- **Forward-looking**: Focus on what's next, not just what happened
- **Actionable**: Every blocker/risk should have owner and plan
- **Visual**: Use status colors, bullets, clear sections
- **Consistent**: Use same format each reporting period
- **Timely**: Generate near end of reporting period

## Data Sources

Pull information from:
- `aiDocs/TASKS.md` - Task completion, blockers
- `aiDocs/SUMMARY.md` - Risks, decisions, contacts
- `PROJECT.md` - Current status, recent progress
- `docs/` - Quick reference for metrics

## Workflow Integration

Typical reporting workflow:
1. Run `/generateReport` near end of reporting period
2. Review generated report for accuracy
3. Adjust tone/detail for specific audience
4. Share with stakeholders via email/Slack/meeting
5. Archive report in `reports/` folder
6. Update PROJECT.md if major status changes

---

## Example Output Snippet

```markdown
## Executive Summary

The authentication service migration is **on track** with 3 of 5 migration phases completed this week. We've successfully migrated 10,000 user accounts to the new system with zero downtime. The team is currently blocked on database schema approval from infrastructure team, delaying phase 4 by ~3 days. If schema approved by Friday, we remain on schedule for go-live December 20th.

**Overall Health**: 🟡 Yellow - On track with one active blocker requiring management escalation.
```

This report should take 5-10 minutes to read and give stakeholders complete situational awareness.
