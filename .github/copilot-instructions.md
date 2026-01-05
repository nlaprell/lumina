# GitHub Copilot Instructions

This file contains critical universal instructions for AI agents working in this workspace.

**For detailed workflows and guidelines, see:**
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Full development guidelines
- [core/prompts/completeIssue.prompt.md](../core/prompts/completeIssue.prompt.md) - Issue-to-PR workflow

---

## Quick Reference

### Email Workflow

1. **Raw emails**: Place `.eml` files in `email/raw/`
2. **Convert**: Run `python3 "core/aiScripts/emailToMd/eml_to_md_converter.py"`
3. **Read**: Converted emails in `email/ai/`, originals moved to `email/processed/`

### Notes Workflow

1. **Raw notes**: Place `.txt` or `.md` files in `notes/raw/`
2. **Convert**: Run `python3 "core/aiScripts/notesToMd/notes_to_md_converter.py"`
3. **Read**: Converted notes in `notes/ai/`, originals moved to `notes/processed/`

### Git Branching

**Bug/Defect** (labels: `bug`, `critical`) → `defect/{number}-{description}`  
**Feature** (labels: `enhancement`, `feature`) → `feature/{number}-{description}`

### Labels (See CONTRIBUTING.md for full details)

**Type** (required, one): `bug`, `critical`, `enhancement`, `documentation`, `refactor`  
**Category** (optional, multiple): `quality`, `testing`, `mcp`, `scripts`, `python`, `workflow`, `security`  
**Priority** (optional, one): `priority: high`, `priority: medium`, `priority: low`

### Commits

Format: `type(scope): description`  
Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`  
Always reference issue: `Fixes #123` or `Implements #123`

---

## Writing Style for Documentation

When creating or editing markdown files (README, PROJECT.md, prompts, docs):

### Voice Rules
- Write as a professional consultant, not an AI assistant
- Use contractions naturally: don't, we'll, it's, you're, I'll
- Be confident and direct (no hedging)
- Use first person (I, we) and second person (you)
- Active voice preferred over passive

### Structure Rules
- Lead with key information (answer first, context after)
- Vary sentence length (mix short and long)
- One idea per paragraph (2-4 sentences max)
- Use bullet lists ONLY for parallel items

### Language Rules
- Remove filler phrases entirely:
  - Never: "It is important to note that"
  - Never: "One might consider"
  - Never: "It should be noted"
  - Never: "In order to" (just use "to")
  - Never: "Due to the fact that" (just use "because")
- Be specific over vague:
  - Not: "takes some time" → "takes 2-3 hours"
  - Not: "several benefits" → list them specifically
  - Not: "various options" → "3 options:" then list
- No redundancy:
  - Not: "completely finish" → "finish"
  - Not: "advance planning" → "planning"

### Formatting Rules
- Headings: Clear, action-oriented, scannable
- Bold: Key terms only (not entire sentences)
- Code formatting: Commands, filenames, variables
- Tables: Reference information, comparisons
- Lists: Parallel items, steps, alternatives only

### Anti-Patterns (Never Use These)
❌ "Furthermore, it is noteworthy that..."
❌ "As previously mentioned..."
❌ "It is worth noting that..."
❌ "One should consider the fact that..."
❌ "In the event that..." (use "If")
❌ "At this point in time..." (use "Now")
❌ "For the purpose of..." (use "To")

### Preferred Patterns
✅ Start with the answer: "Use Pandoc. It handles..."
✅ Specific metrics: "Saves 10 minutes per project"
✅ Direct questions: "Need help? Contact..."
✅ Action verbs: "Add", "Fix", "Create", "Update"
✅ Natural rhythm: Short sentence. Longer explanation. Short again.

### Before You Submit
- Read aloud - does it sound like a human consultant?
- Check for contractions - did you use them naturally?
- Remove hedge words - are you confident and direct?
- Verify specifics - did you give actual numbers/details?
- Scan for filler - did you remove "it is important to note"?

---

## Critical Workflows

### Completing GitHub Issues

**When user requests an issue be completed:**

1. **Use the `/completeIssue` prompt** - This automates the full workflow
2. **Or manually follow**: Fetch issue → Create branch → Implement → Sanity check → Commit → PR

**See [core/prompts/completeIssue.prompt.md](../core/prompts/completeIssue.prompt.md) for complete details.**

---

## Standard AI Agent Workflow

When starting work on any project in this workspace:

1. **Initialize context**: Read all files in `aiDocs/` to understand project state
   - `aiDocs/AI.md` - Project-specific guidance and lessons learned
   - `aiDocs/SUMMARY.md` - Project background, contacts, risks, planning options
   - `aiDocs/TASKS.md` - Outstanding and completed tasks
   - `aiDocs/DISCOVERY.md` - Unanswered questions and information gaps

2. **Process new data** (if present):
   - Check `/email/raw/` for new `.eml` files
   - Check `/notes/raw/` for new `.txt` or `.md` files
   - Run email converter if emails found
   - Run notes converter if notes found
   - Read converted Markdown files from `/email/ai/` and `/notes/ai/`
   - Extract relevant information (contacts, tasks, decisions, risks, questions)

3. **Update documentation**: Keep `aiDocs/` files current with new information
   - Update `SUMMARY.md` with new contacts, background, decisions, risks
   - Update `TASKS.md` with new tasks and completion status
   - Update `DISCOVERY.md` with new questions and answers
   - Update `AI.md` with project-specific learnings

4. **Maintain human summary**: Update root `PROJECT.md` and `docs/` for stakeholders when significant changes occur
   - **Bidirectional sync**: If users edit root `PROJECT.md`, sync changes back to `aiDocs/` files first
   - User edits to root summary are authoritative and should be preserved
   - Then regenerate root `PROJECT.md` and `docs/` extracts from updated `aiDocs/` to maintain consistency
   - Generate simplified views in `docs/` (CONTACTS.md, TASKS.md, DECISIONS.md, QUESTIONS.md)

---

## Documentation Standards

### File Responsibilities

AI agents MUST maintain these files:

- **`aiDocs/SUMMARY.md`**: Single source of truth for project state
  - Quick Context (What/Who/Status with character limits)
  - Key Contacts (complete with email, phone, role, organization)
  - Background and historical context
  - Technical details
  - Current situation (last 30 days)
  - Decision Log (Date | Decision | Made By | Rationale | Source)
  - Planning Options
  - Risks (8-field format: Title, Description, Severity, Likelihood, Impact, Mitigation, Owner, Status)
  - References

- **`aiDocs/TASKS.md`**: Task tracking with dependencies
  - Sequential task IDs (TASK-001, TASK-002, no gaps)
  - Required metadata: Owner, Status, Deadline (if applicable), Blocks, Related, Source, Context
  - Categories: High Priority, Planning Tasks, Documentation Tasks
  - Completed tasks archived by date

- **`aiDocs/DISCOVERY.md`**: Information gaps and questions
  - Checkbox format: `- [ ]` unanswered, `- [x]` answered
  - Required metadata: Ask, Check, Status, Priority
  - Answer and Source when answered
  - Categories: High Priority, Technical, Environmental

- **`aiDocs/AI.md`**: Project-specific context for AI agents
  - Project-Specific Guidance (THIS project's unique context)
  - Common Pitfalls (THIS project's known issues)
  - Quick References (THIS project's links and resources)
  - Lessons Learned (THIS project's experiences)

- **`PROJECT.md`** (root): Human-readable project summary
  - Executive summary with visual indicators
  - Condensed information for busy stakeholders
  - Links to detailed documentation in `aiDocs/`

- **`docs/`** (directory): Human-readable quick reference extracts
  - `CONTACTS.md` - Key stakeholder contact information
  - `TASKS.md` - High-priority tasks and current blockers
  - `DECISIONS.md` - Decision log in table format
  - `QUESTIONS.md` - Outstanding discovery questions

### Quick Context Format

In `aiDocs/SUMMARY.md`, the Quick Context section has strict character limits:

```markdown
## Quick Context

**What**: [Brief description - max 100 characters, one sentence only]
**Who**: [Key organizations - max 150 characters, format "Company A supporting Company B"]
**Status**: [Planning | Investigation | Active Development | Testing | Blocked | On Hold - max 50 chars]
```

### Task ID Format

Tasks must have sequential IDs when created:
- Format: `TASK-001`, `TASK-002`, `TASK-003`, etc.
- Task IDs are permanent - once assigned, never reused or renumbered
- Gaps in outstanding task IDs are expected when tasks are completed and moved to archive
- Every task MUST have an Owner (use "TBD" if unknown, never blank)
- All cross-references (Blocks, Related) must use valid task IDs that exist
- Include Source field citing email/document where task originated
- Completed task IDs can remain in Related/Blocks fields for audit trail

### Task Dependency Detection

Use the automated dependency detection script to find task relationships:
- Run: `python3 core/aiScripts/detectTaskDependencies/detectTaskDependencies.py aiDocs/TASKS.md`
- Reviews generated report in `aiDocs/TASK_DEPENDENCY_REPORT.md`
- Updates task Blocks/Related fields based on high-confidence detections
- Resolves circular dependencies before proceeding
- Uses dependency graph visualization for planning

### Discovery Question Format

```markdown
- [ ] **[Specific, actionable question]**  
  - Ask: [Who would know the answer - specific person/role]
  - Check: [Where to look - specific emails, documents, systems]
  - Status: Unknown / Partial / Answered
  - Priority: High / Medium / Low
  - Answer: [If answered, include the answer here]
  - Source: [If answered, cite email/document/person]
```

**Question Quality Standards** - Each question must be:
1. **Specific**: Not vague, focused on concrete information
2. **Actionable**: Includes where to check or who to ask
3. **Scoped**: One topic per question, not multiple
4. **Answerable**: Has concrete answer, not philosophical
5. **Relevant**: Directly impacts project decisions

### Risk Format

All risks must include 8 required fields:

```markdown
- **Title**: [Clear, concise risk name]
  - **Description**: What could go wrong
  - **Severity**: Critical | High | Medium | Low
  - **Likelihood**: Certain | Likely | Possible | Unlikely
  - **Impact**: Specific consequences if risk occurs
  - **Mitigation**: What is being done to reduce/prevent
  - **Owner**: Who is responsible (or TBD, never blank)
  - **Status**: Active | Mitigated | Accepted | Transferred
```

---

## Conflict Resolution Rules

When processing emails that contain conflicting information:

1. **Latest information wins**: Most recent email takes precedence
2. **Note the conflict**: In Current Situation, mention "Previously X, updated to Y (per email dated [date])"
3. **Flag for clarification**: Add discovery question if contradiction is significant
4. **Document both versions**: In Historical Context, note the change in understanding
5. **Escalate critical conflicts**: If affects major decisions, add to "Critical Findings" in summary

---

## Validation Checklist

Before completing work, verify:

- [ ] All email addresses are correctly formatted and complete
- [ ] Phone numbers include country/area codes if provided
- [ ] All task IDs are sequential (gaps allowed for completed tasks)
- [ ] Every task has an Owner or "TBD" (never blank)
- [ ] All discovery questions have required metadata (Ask, Check, Status, Priority)
- [ ] Cross-references (Blocks, Related) use valid task IDs that exist
- [ ] Dates are in consistent format throughout
- [ ] Organization names are consistent throughout
- [ ] No template placeholders remain (`[DATE]`, `[CUSTOMER]`, etc.)
- [ ] Quick Context meets character limits (What: 100, Who: 150, Status: 50)
- [ ] All risks include 8 required fields
- [ ] "Last Updated" dates are current
- [ ] Run dependency detection and review for circular dependencies
- [ ] Verify task dependency graph reflects project structure

---

## Template System

### Template Files

Templates are preserved in `core/templates/` for reference and reset:
- `SUMMARY.template.md`
- `TASKS.template.md`
- `DISCOVERY.template.md`
- `AI.template.md`

### Working Files

Always update working files in `aiDocs/` (without `.template` extension), NOT the template files.

### Reset Process

To reset project to clean state:
```bash
./go.sh
```

This copies templates to working files, clearing all project-specific content.

---

## Email and Notes Processing Best Practices

### Email Processing
- **Always read ALL emails**: Every `.md` file in `email/ai/` must be read completely
- **Extract comprehensively**: Get contacts, tasks, technical details, risks, questions, decisions, timeline
- **Cite sources**: Use format "(Source: "Email Subject" - Date)" when adding facts
- **Deduplication**: Check email domains to identify related organizations; merge duplicate contacts
- **Verify moves**: After conversion, confirm `.eml` files moved to `email/processed/`

### Notes Processing
- **Always read ALL notes**: Every `.md` file in `notes/ai/` must be read completely
- **Extract same information**: Contacts, tasks, decisions, technical details, risks, questions from meeting notes, status updates, architecture docs
- **Cite sources**: Use format "(Source: "Note Title" - Date)" when adding facts
- **Integrate with emails**: Merge information from both sources into unified documentation
- **Verify moves**: After conversion, confirm source files moved to `notes/processed/`

### MarkLogic Ecosystem Organizations

When processing contacts and organizations in MarkLogic-related projects:
- **Progress Software** is the parent company of MarkLogic
- **Progress Federal** is the MarkLogic support and consulting division for government clients
- These should be treated as the same organizational entity in documentation, with Progress Federal being the service delivery arm
- Merge duplicate contacts across Progress/Progress Federal/MarkLogic divisions as appropriate

---

## Documentation Update Triggers

Update `aiDocs/` files when:
- New emails or notes are processed
- Tasks are completed
- Decisions are made
- Risks are identified or resolved
- Discovery questions are answered
- Project status changes

Update root `PROJECT.md` and `docs/` when:
- Major milestones reached
- Critical decisions made
- Significant status changes
- Preparing for stakeholder review

---

## Notes for AI Agents

- Email and notes files must be converted to Markdown before AI analysis
- Prefer reading Markdown files in `/email/ai/` and `/notes/ai/` over raw source files
- Keep organization consistent: raw → processed, converted → ai (applies to both emails and notes)
- Information from both emails and notes should be integrated into unified documentation
- When uncertain, err on side of documenting more rather than less
- Project-specific context belongs in `aiDocs/AI.md`, not this file
