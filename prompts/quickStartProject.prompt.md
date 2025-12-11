---
description: Quick start workflow - Initialize project, process emails, and generate summary in one flow
---

You are an AI agent performing a complete project initialization workflow.

Follow these steps in sequence:

## Step 1: Initialize AI Agent Context

First, run the `/projectInit` prompt to:
- Read AI agent instructions from `aiDocs/AI.md`
- Understand the project structure and email processing workflow
- Review project documentation in `aiDocs/`
- Get familiar with available tools and scripts

## Step 2: Check for Email Files

Check if there are any `.eml` files in the `email/raw/` directory:

- If `.eml` files exist, proceed to Step 3
- If NO `.eml` files exist, inform the user:

```
No email files found in `email/raw/`

To add project context from emails:
1. Export email threads to .eml format from your email client
2. Place them in the `email/raw/` directory
3. Re-run /quickStartProject or run /discoverEmail

For now, I'll skip email processing and continue with available context.
```

## Step 3: Process Email Files (if present)

If `.eml` files were found in `email/raw/`, run the `/discoverEmail` workflow:

Execute the email converter script from the **project root** directory:

```bash
python3 ".template/aiScripts/emailToMd/eml_to_md_converter.py"
```

The script will:
1. Convert all `.eml` files from `email/raw/` to Markdown
2. Save converted files to `email/ai/`
3. Move processed `.eml` files to `email/processed/`

**Verify the move**: After running the script, check that:
- `.eml` files have been moved from `email/raw/` to `email/processed/`
- Corresponding `.md` files exist in `email/ai/`
- If files were not moved, report the error and check file permissions

Then:
- Read all converted Markdown files in `email/ai/`
- Extract relevant information (contacts, tasks, technical details, etc.)
- Update all files in `aiDocs/` based on email content:
  - `aiDocs/SUMMARY.md` - Quick Context, contacts, background, technical details, Decision Log
  - `aiDocs/TASKS.md` - tasks with IDs (`TASK-001`), statuses, cross-references, priorities
  - `aiDocs/DISCOVERY.md` - discovery questions with metadata (Ask/Check/Status/Priority)
  - `aiDocs/AI.md` - workflows, procedures, AI Agent Notes with project-specific guidance
- Update "Last Updated" dates to current date in all modified `aiDocs/` files

## Step 4: Generate Project Summary and Documentation

Run the `/updateSummary` workflow:

- Review all `aiDocs/` files for consistency and accuracy
- Verify Quick Context, Decision Log, Task IDs, and Discovery metadata
- Cross-reference with email content in `email/ai/`
- Create or update `PROJECT.md` at the project root with:
  - **AI model tagline** (if creating for first time): *This document was originally created by an AI agent using the Claude Sonnet 4.5 model.*
  - Project overview and current status
  - Key contacts
  - Completed work and outstanding tasks (with TASK IDs)
  - Blockers and risks
  - Outstanding questions and next steps
  - Decision log highlights
- Generate human-readable extracts in `docs/` directory:
  - `docs/CONTACTS.md` - Key stakeholder contact information
  - `docs/TASKS.md` - High-priority tasks and blockers
  - `docs/DECISIONS.md` - Decision log table
  - `docs/QUESTIONS.md` - Unanswered questions

**Optional: Run Task Dependency Detection**

If tasks were created or updated during email processing:
- Run: `python3 .template/aiScripts/detectTaskDependencies/detectTaskDependencies.py aiDocs/TASKS.md`
- Review generated `TASK_DEPENDENCY_REPORT.md` for suggested relationships
- Update task Blocks/Related fields based on high-confidence detections
- Resolve any circular dependencies identified

## Step 5: Validate and Provide Summary Report

Before providing your final report, verify:
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
- [ ] "Last Updated" dates are current in all `aiDocs/` files

After completing all steps, provide a comprehensive report:

### Initialization Complete

**Project Setup Summary:**
- ✓ AI agent initialized with project context
- ✓ Email processing: [X emails processed / No emails found]
- ✓ Documentation updated: [list files updated]
- ✓ Project summary generated: PROJECT.md
- ✓ Human-readable docs created: docs/ folder

**Key Findings:**
- **Contacts**: [number added] new contacts added, [number removed] removed
  - New: [list names and organizations]
  - Removed: [list names if any]
- **Tasks**: [number created] new tasks created, [number completed] tasks marked complete
  - New outstanding tasks: [list TASK-IDs with brief description]
  - Newly completed tasks: [list completed task descriptions]
- **Risks**: [number added] new risks identified, [number removed] risks resolved
  - New risks: [list risk descriptions with severity]
  - Resolved risks: [list if any]
- **Blockers**: [number added] new blockers identified, [number removed] blockers cleared
  - New blockers: [list blocker descriptions]
  - Cleared blockers: [list if any]

**Documentation Health Check:**
- Contact completeness: [X%] have complete email, role, and organization
- Task ownership: [X%] of tasks have assigned owners (not TBD)
- Cross-reference integrity: [X%] of task cross-references are valid
- Discovery question metadata: [X%] have all required fields
- Quick Context compliance: [Yes/No] meets character limits

**Next Steps:**
1. **📄 Review PROJECT.md at project root for complete project overview**
2. **📁 Check docs/ folder for quick reference (contacts, tasks, decisions, questions)**
3. Check `aiDocs/TASKS.md` for complete task details
4. Review `aiDocs/DISCOVERY.md` for unanswered questions

**To add more email context later:**
- Export emails to `email/raw/`
- Run `/discoverEmail` to process them
- Run `/updateSummary` to regenerate the summary

**Optional: Run Task Dependency Detection**

If tasks were created during email processing:
- Run: `python3 .template/aiScripts/detectTaskDependencies/detectTaskDependencies.py aiDocs/TASKS.md`
- Review generated `aiDocs/TASK_DEPENDENCY_REPORT.md` for suggested relationships
- Update task Blocks/Related fields based on high-confidence detections
- Resolve any circular dependencies identified

---

## Important Notes

- Always run the email converter from the project root directory
- Skip email processing gracefully if no `.eml` files are present
- Ensure all documentation is consistent across files
- Highlight any critical issues or urgent items discovered
- If email processing fails, continue with remaining steps and report the error
- **Direct user to PROJECT.md at project root for complete project status**
- **Direct user to docs/ folder for quick reference materials**
- Template files are preserved in `.template/templates/` directory
- To reset project to clean state, use `./go.sh` and select "Reset Project"
