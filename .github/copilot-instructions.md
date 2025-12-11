# GitHub Copilot Instructions

This file contains universal instructions for AI agents working in this workspace. These rules apply to ALL projects using this template.

---

## Project Structure

### Email Management Workflow

All project communication and context from email should follow this workflow:

1. **Raw emails**: Place `.eml` files in `/email/raw/` for processing
2. **Convert**: Run the email converter to transform emails into AI-readable format
3. **AI-readable emails**: Converted emails stored in `/email/ai/` as Markdown files
4. **Processed emails**: Original `.eml` files archived in `/email/processed/` after conversion

### Email Converter Tool

Located at `.template/aiScripts/emailToMd/eml_to_md_converter.py`, this tool converts `.eml` email files to Markdown format.

**Usage**:
```bash
# Run from project root
python3 ".template/aiScripts/emailToMd/eml_to_md_converter.py"
```

The converter automatically:
- Creates required directories (`email/raw/`, `email/ai/`, `email/processed/`)
- Converts all `.eml` files from `email/raw/` to Markdown
- Saves converted files to `email/ai/`
- Moves processed `.eml` files to `email/processed/`

---

## Standard AI Agent Workflow

When starting work on any project in this workspace:

1. **Initialize context**: Read all files in `aiDocs/` to understand project state
   - `aiDocs/AI.md` - Project-specific guidance and lessons learned
   - `aiDocs/SUMMARY.md` - Project background, contacts, risks, planning options
   - `aiDocs/TASKS.md` - Outstanding and completed tasks
   - `aiDocs/DISCOVERY.md` - Unanswered questions and information gaps

2. **Process new emails** (if present):
   - Check `/email/raw/` for new `.eml` files
   - Run email converter if emails found
   - Read converted Markdown files from `/email/ai/`
   - Extract relevant information (contacts, tasks, decisions, risks, questions)

3. **Update documentation**: Keep `aiDocs/` files current with new information
   - Update `SUMMARY.md` with new contacts, background, decisions, risks
   - Update `TASKS.md` with new tasks and completion status
   - Update `DISCOVERY.md` with new questions and answers
   - Update `AI.md` with project-specific learnings

4. **Maintain human summary**: Update root `SUMMARY.md` for stakeholders when significant changes occur
   - **Bidirectional sync**: If users edit root `SUMMARY.md`, sync changes back to `aiDocs/` files first
   - User edits to root summary are authoritative and should be preserved
   - Then regenerate root `SUMMARY.md` from updated `aiDocs/` to maintain consistency

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

- **`SUMMARY.md`** (root): Human-readable project summary
  - Executive summary with visual indicators
  - Condensed information for busy stakeholders
  - Links to detailed documentation in `aiDocs/`

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
- Run: `python3 .template/aiScripts/detectTaskDependencies/detectTaskDependencies.py aiDocs/TASKS.md`
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

Templates are preserved in `.template/templates/` for reference and reset:
- `SUMMARY.template.md`
- `TASKS.template.md`
- `DISCOVERY.template.md`
- `AI.template.md`

### Working Files

Always update working files in `aiDocs/` (without `.template` extension), NOT the template files.

### Reset Process

To reset project to clean state:
```bash
./.template/scripts/clean-reset.sh
```

This copies templates to working files, clearing all project-specific content.

---

## Email Processing Best Practices

- **Always read ALL emails**: Every `.md` file in `email/ai/` must be read completely
- **Extract comprehensively**: Get contacts, tasks, technical details, risks, questions, decisions, timeline
- **Cite sources**: Use format "(Source: "Email Subject" - Date)" when adding facts
- **Deduplication**: Check email domains to identify related organizations; merge duplicate contacts
- **Verify moves**: After conversion, confirm `.eml` files moved to `email/processed/`

### MarkLogic Ecosystem Organizations

When processing contacts and organizations in MarkLogic-related projects:
- **Progress Software** is the parent company of MarkLogic
- **Progress Federal** is the MarkLogic support and consulting division for government clients
- These should be treated as the same organizational entity in documentation, with Progress Federal being the service delivery arm
- Merge duplicate contacts across Progress/Progress Federal/MarkLogic divisions as appropriate

---

## Documentation Update Triggers

Update `aiDocs/` files when:
- New emails are processed
- Tasks are completed
- Decisions are made
- Risks are identified or resolved
- Discovery questions are answered
- Project status changes

Update root `SUMMARY.md` when:
- Major milestones reached
- Critical decisions made
- Significant status changes
- Preparing for stakeholder review

---

## Notes for AI Agents

- Email files must be converted to Markdown before AI analysis
- Prefer reading Markdown files in `/email/ai/` over raw `.eml` files
- Keep email organization consistent: raw → processed, converted → ai
- When uncertain, err on side of documenting more rather than less
- Project-specific context belongs in `aiDocs/AI.md`, not this file
