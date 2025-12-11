---
description: Review project documentation for consistency and create/update human-readable project summary
---

You are an AI agent tasked with ensuring project documentation is accurate, consistent, and up to date, then creating a comprehensive project summary for human stakeholders.

## When to Use This Prompt

**Use `/updateSummary` when:**
- After `/discoverEmail` to generate human-readable PROJECT.md and docs/
- When PROJECT.md or docs/ need regeneration from current aiDocs/
- When users have edited PROJECT.md and changes need syncing back to aiDocs/
- To validate documentation consistency across all files
- To refresh human-readable summaries after manual aiDocs/ edits

**Don't use this if:**
- You just need to process new emails (use `/discoverEmail` first, then this)
- You want the complete workflow from scratch (use `/quickStartProject` instead)
- You only need to check context (use `/projectInit` for read-only)

---

Follow these steps carefully:

## 1. Check for User Changes in Root PROJECT.md

**CRITICAL FIRST STEP**: Before reviewing `aiDocs/`, check if the root `PROJECT.md` exists and contains user-made changes that need to be synced back to `aiDocs/`.

If root `PROJECT.md` exists:

### Extract User Changes from Root PROJECT.md

Look for changes that users may have made directly to the root project summary:

**Task Status Changes:**
- Tasks marked as completed (✅ or checked boxes)
- New tasks added by user
- Task priority changes
- Deadline updates
- Owner reassignments

**Discovery Questions:**
- Questions marked as answered
- New questions added
- Answers provided to existing questions

**Risk Updates:**
- Risk status changes (Active → Mitigated, etc.)
- New risks identified
- Mitigation updates

**Contact Updates:**
- New contacts added
- Contact information corrections (phone, email, role)

**Decision Updates:**
- New decisions documented
- Decision status changes

**Notes and Updates:**
- Status updates in "Current Status" section
- New blockers identified
- Blocker resolution notes
- Progress updates in "Completed Work"

### Sync User Changes to aiDocs/

After identifying user changes in root `PROJECT.md`, update the corresponding `aiDocs/` files:

**Update `aiDocs/TASKS.md`:**
- Move tasks marked complete in root PROJECT.md to Completed Tasks section
- Update task statuses, deadlines, owners based on user edits
- Add any new tasks user created in root PROJECT.md
- Preserve task ID sequencing (assign next sequential ID to new tasks)

**Update `aiDocs/DISCOVERY.md`:**
- Mark questions as answered [x] if user provided answers
- Add Answer and Source fields for newly answered questions
- Add any new discovery questions user created

**Update `aiDocs/SUMMARY.md`:**
- Update Risk statuses based on user changes
- Add new risks if user documented them
- Update Decision Log with new decisions
- Update Current Situation with user's status updates
- Add new contacts if user added them
- Update contact information if user corrected it

**Important Notes:**
- Treat root `PROJECT.md` user edits as authoritative
- Don't overwrite user changes - preserve and sync them to `aiDocs/`
- If user changes conflict with `aiDocs/` content, user changes win
- Document sync in your final report

## 2. Review AI Documentation Files

After syncing user changes from root `PROJECT.md`, thoroughly review all documentation in `aiDocs/` to ensure consistency and accuracy:

### Review `aiDocs/SUMMARY.md`
- Verify **Quick Context** section is current (What, Who, Status)
  - Verify character limits: What (100 chars), Who (150 chars), Status (50 chars)
- Verify all key contacts are listed with correct information
  - Check for duplicates (same person, different emails or roles)
  - Verify organizational relationships (divisions, parent companies)
- Check that background information is complete and accurate
- Ensure technical details reflect current state
- Confirm current situation is up to date
- Review **Decision Log** for completeness and accuracy
  - Verify all decisions have: Date, What, Who, Rationale, Source
- Verify risks are accurately documented
  - Check all risks have: Title, Description, Severity, Likelihood, Impact, Mitigation, Owner, Status
- Check that references are valid
- Verify **Stakeholder Relationships** section documents organizational structure

### Review `aiDocs/TASKS.md`
- Verify all tasks have proper IDs (TASK-001, TASK-002, etc.)
  - Check for sequential IDs with no gaps
- Check that task statuses are current (Not Started, In Progress, Blocked, Completed)
- Verify task cross-references (Blocks, Related fields) are accurate
  - All referenced task IDs must exist
- Check that task priorities are appropriate
  - High Priority: Has deadline, blocks work, critical path, security/compliance
  - Planning Tasks: Future work, no immediate deadline, preparatory
  - Documentation Tasks: Post-completion, process improvement
- Ensure task descriptions are clear and actionable
- Confirm dates are accurate and in consistent format
- Verify Source fields point to correct emails/documents
- Verify completed tasks are properly archived
- Ensure every task has Owner or "TBD" (never blank)
- Check that Deadline field is populated when mentioned in sources

### Review `aiDocs/DISCOVERY.md`
- Check that all discovery questions are relevant
- Verify answered questions are marked with [x]
- Ensure all questions have proper metadata (Ask, Check, Status, Priority)
- Verify questions meet quality standards:
  - **Specific**: Not vague, focused on concrete information
  - **Actionable**: Includes where to check or who to ask
  - **Scoped**: One topic per question, not multiple
  - **Answerable**: Has concrete answer, not philosophical
  - **Relevant**: Directly impacts project decisions
- Check that Answer and Source fields are filled in for answered questions
- Verify outstanding questions are still applicable
- Remove obsolete or redundant questions

### Review `aiDocs/AI.md`
- Verify workflow instructions are current
- Check that all file paths and references are correct
- Ensure tool and script locations are accurate
- Review **AI Agent Notes** section for current relevance
- Update AI Agent Notes with new learnings from recent work
- Confirm project structure documentation matches reality

## 3. Cross-Reference Email Content

Review all processed emails in `email/ai/` (if any exist) to:
- Identify any new information not yet reflected in `aiDocs/`
- Verify that documented information matches email sources
- Extract any updates on project status, decisions, or changes
- Identify new contacts, risks, or technical details
- Find any resolved or new tasks/action items
- Verify task IDs in emails match those in TASKS.md
- Check that email-referenced tasks are properly cross-referenced with Source field

## 4. Identify Inconsistencies

Look for and resolve:
- **Conflicting information** between different documentation files
  - When found, use latest information from most recent email/source
  - Document the conflict in Current Situation with note: "Previously X, updated to Y (per source dated [date])"
  - Add discovery question if conflict is significant
- **Outdated information** that contradicts recent emails or changes
- **Missing information** that should be documented based on email content
- **Duplicate information** across multiple files
  - Merge duplicate contacts/organizations
  - Treat related entities correctly (e.g., divisions of same company)
- **Incorrect references** to files, paths, or resources
- **Out-of-date statuses** on tasks or project state
- **Organizational relationships** not properly documented
  - Parent/subsidiary relationships
  - Divisions within companies
  - Vendor/customer relationships

## 5. Update AI Documentation Files

**Note on Templates**: Template files are preserved in `.template/templates/` for reference and reset purposes. Always update the working files in `aiDocs/` (without `.template` extension), not the template files themselves.

Update `aiDocs/` files as needed to ensure:
- **Quick Context** in SUMMARY.md accurately reflects current state
- **Decision Log** in SUMMARY.md is complete with all recent decisions
- All task IDs are sequential and cross-references are accurate
- Discovery questions that have been answered are marked [x] with Answer and Source
- **AI Agent Notes** in AI.md contains current project-specific guidance
- All information is current and accurate
- Cross-references between files are correct
- No contradictions exist between files
- All relevant email information is incorporated
- "Last Updated" dates are current
- Placeholder text is replaced with actual content

## 6. Create/Update Project Summary and Documentation Extracts

### Create/Update PROJECT.md

Create or update `PROJECT.md` at the **project root** (not in `aiDocs/`) with a human-readable summary.

**IMPORTANT**: When creating the file for the first time, add this tagline immediately after the title:

```
*This document was originally created by an AI agent using the Claude Sonnet 4.5 model.*
```

If the file already exists and doesn't have the tagline, add it. If it already has a tagline, preserve it as-is.

### Summary File Structure

The summary should include:

#### Project Overview
- Brief description of the project
- Key objectives and goals
- Current phase or milestone

#### Current Status
- High-level status (e.g., "In Progress", "Planning", "Blocked")
- Recent progress and achievements
- Current focus areas
- Overall health assessment

#### Key Contacts
- Primary stakeholders with names, emails, and roles
- Decision makers
- Technical contacts
- Organized by organization/team

#### Completed Work
- Major completed tasks and milestones
- Recent accomplishments (last 1-2 weeks)
- Deliverables completed
- Organized by date (most recent first)

#### Outstanding Tasks
- High priority tasks requiring immediate attention
- Medium priority planned work
- Lower priority backlog items
- Each task should include:
  - Clear description
  - Priority level
  - Estimated timeline (if known)
  - Dependencies (if any)

#### Blockers
- Current blockers preventing progress
- What is blocked and why
- Who needs to take action
- Potential solutions or next steps

#### Risks
- Identified risks to project success
- Risk severity (High/Medium/Low)
- Mitigation strategies
- Risk owners

#### Outstanding Questions
- Auto-generate from `aiDocs/DISCOVERY.md` high-priority unanswered questions
- Organize by category (Critical, Technical, Environmental, Historical)
- List questions concisely without full metadata
- Add footer note: "*For complete question details including who to ask and where to check, see [aiDocs/DISCOVERY.md](aiDocs/DISCOVERY.md)*"

#### Next Steps
- Immediate next actions
- Who is responsible
- Target dates (if applicable)

#### References
- Links to key documentation
- Important email threads
- External resources

### Create/Update docs/ Human-Readable Files

After updating `PROJECT.md`, generate simplified, human-readable extracts in the `docs/` directory:

**docs/CONTACTS.md:**
- Extract key contacts from `aiDocs/SUMMARY.md`
- Group by organization
- Include: Name, Email, Role, Organization
- Add "Last Updated" date
- Note: "*For complete contact details, see [aiDocs/SUMMARY.md](aiDocs/SUMMARY.md)*"

**docs/TASKS.md:**
- Extract high-priority tasks from `aiDocs/TASKS.md`
- Include: Task ID, Description, Owner, Status
- Separate sections: High Priority, Current Blockers, Recently Completed
- Add "Last Updated" date
- Note: "*For complete task list with all metadata, see [aiDocs/TASKS.md](aiDocs/TASKS.md)*"

**docs/DECISIONS.md:**
- Extract decision log from `aiDocs/SUMMARY.md`
- Table format: Date, Decision, Made By, Rationale
- Add "Last Updated" date
- Note: "*For complete decision log, see [aiDocs/SUMMARY.md](aiDocs/SUMMARY.md)*"

**docs/QUESTIONS.md:**
- Extract high-priority unanswered questions from `aiDocs/DISCOVERY.md`
- Group by category (High Priority, Technical)
- List questions concisely without full metadata
- Add "Last Updated" date
- Note: "*For complete question details including who to ask and where to check, see [aiDocs/DISCOVERY.md](aiDocs/DISCOVERY.md)*"

## 7. Formatting Guidelines

When creating the summary:
- **Be concise**: Focus on high-level information for human readers
- **Be specific**: Include concrete details, dates, names, and numbers
- **Be current**: Only include relevant, up-to-date information
- **Use clear headings**: Make the document easy to scan
- **Highlight critical items**: Use bold or emphasis for urgent/important items
- **Avoid technical jargon**: Write for a non-technical audience where possible
- **Include dates**: Add "Last Updated" at the top of the document
- **Use bullet points**: Make information scannable
- **Provide context**: Don't assume the reader knows the project history

## 8. Summary Content Guidelines

- **Source from `aiDocs/`**: Primary source of truth for project information
- **Validate with `email/ai/`**: Ensure email content is reflected accurately
- **Synthesize, don't copy**: Summarize and consolidate information
- **Prioritize relevance**: Focus on what stakeholders need to know now
- **Be factual**: Only include verified, documented information
- **Update regularly**: Reflect the absolute current state of the project

## 9. Report Your Work

After completing the review and summary update, provide:

**User Changes Sync Summary:**
- Root PROJECT.md exists: [Yes/No]
- User changes detected: [Yes/No - if yes, list types of changes]
- Tasks synced to `aiDocs/TASKS.md`: [number of task updates]
- Discovery questions synced to `aiDocs/DISCOVERY.md`: [number of updates]
- Risks synced to `aiDocs/SUMMARY.md`: [number of updates]
- Contacts synced to `aiDocs/SUMMARY.md`: [number of updates]
- Decisions synced to `aiDocs/SUMMARY.md`: [number of updates]

**Documentation Review Summary:**
- Files reviewed: [list `aiDocs/` files]
- Inconsistencies found and resolved: [number and description]

**Updates Made:**
- `aiDocs/SUMMARY.md`: [specific changes]
- `aiDocs/TASKS.md`: [specific changes]
- `aiDocs/DISCOVERY.md`: [specific changes]
- `aiDocs/AI.md`: [specific changes]
- `PROJECT.md` (root): [specific changes]
- `docs/CONTACTS.md`: [created/updated with X contacts]
- `docs/TASKS.md`: [created/updated with X tasks]
- `docs/DECISIONS.md`: [created/updated with X decisions]
- `docs/QUESTIONS.md`: [created/updated with X questions]

**Documentation Health Check:**
- Contact completeness: [X%] have complete email, role, and organization
- Task ownership: [X%] of tasks have assigned owners (not TBD)
- Cross-reference integrity: [X%] of task cross-references are valid
- Discovery question metadata: [X%] have all required fields
- Quick Context compliance: [Yes/No] meets character limits

**Key Project Status:**
- Current phase: [phase from Quick Context]
- Outstanding high-priority tasks: [number]
- Active blockers: [number]
- High/critical risks: [number]
- Unanswered discovery questions: [number]

**Critical Issues:**
- Urgent items needing immediate attention: [list]
- Blockers preventing progress: [list]
- Information gaps that must be addressed: [list]

**Organizational Relationships:**
- Parent companies/divisions properly documented: [Yes/No]
- Duplicate entities merged: [number merged]
- Stakeholder decision authority documented: [Yes/No]

## Important Notes

- The `PROJECT.md` at project root is for **human stakeholders** (main project summary)
- The `docs/` directory contains **human-readable extracts** for quick reference
- The `aiDocs/` directory is for **AI agent context** (full metadata and details)
- These files serve different purposes and should all be maintained
- Ensure all files are consistent but appropriately formatted for their audiences
- Focus the human summary and docs/ extracts on actionable information and clear status
- If critical blockers or risks exist, highlight them prominently in PROJECT.md
