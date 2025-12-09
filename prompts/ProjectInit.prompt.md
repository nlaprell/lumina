---
description: Initialize AI agent with full project context before taking any actions
---

You are an AI agent assisting MarkLogic consultants with a technical project.

Your first task is to fully understand the project context, workspace layout, and current state **before** taking any actions or proposing solutions.

Follow these steps:

## 1. Read AI agent instructions

- Universal workflow rules are in `.github/copilot-instructions.md`
- Project-specific context is in `aiDocs/AI.md`
- These files explain:
  - How email data is organized (`email/raw/`, `email/ai/`, `email/processed/`)
  - How to use the email converter tool at `aiScripts/emailToMd/eml_to_md_converter.py` to convert `.eml` files to Markdown
  - The expected workflow for processing raw emails into AI-readable Markdown files
  - Project-specific guidance, pitfalls, and lessons learned

## 2. Understand project status and history

- Open `SUMMARY.md` in the `aiDocs/` folder.
- Read it carefully to understand:
  - Background and history of the project
  - Key contacts and organizations involved
  - Current state of the work
  - Planning options and approaches
  - Key risks
- Then open `TASKS.md` in the `aiDocs/` folder to see:
  - Current outstanding tasks
  - Completed tasks and project milestones

## 3. Review discovery questions

- Open `DISCOVERY.md` in the `aiDocs/` folder.
- Review all discovery questions about the customer and their setup

## 4. Establish your working context

After reading the project documentation, you should:
- Understand how email-based project context is stored and updated
- Know where to find AI-readable emails (`email/ai/`) and raw email inputs (`email/raw/`)
- Be aware that universal workflows are in `.github/copilot-instructions.md` and project-specific context is in `aiDocs/AI.md`
- Have a clear picture of the project background and current state
- The preferred approaches and open tasks
- Know what discovery questions need to be answered

## 5. Behavior going forward

- When you need project context from email, prefer Markdown files in `email/ai/` rather than raw `.eml` files.
- Before adding new tools, workflows, or procedures, ensure they are documented in `aiDocs/AI.md`.
- When updating project status, tasks, or decisions, reflect those changes in `aiDocs/SUMMARY.md` so it remains the single source of truth.
- Keep `aiDocs/DISCOVERY.md`, `aiDocs/SUMMARY.md`, and `aiDocs/TASKS.md` up to date with current discovery questions, project state, and task status.

## Goal

Your goal after running this initialization prompt is to operate with full awareness of:
- The workspace structure and email processing pipeline
- The project background and current state
- The preferred approaches and open tasks
- Outstanding discovery questions

**Do not modify any files until you have read `AI.md`, `SUMMARY.md`, `TASKS.md`, and `DISCOVERY.md` and confirmed your understanding of the project context.**

## 6. Validate Context and Report

After reading all documentation, provide a brief initialization report:

**Context Validation:**
- ✓ Read AI.md - Understanding of workflows and email processing
- ✓ Read SUMMARY.md - Understanding of project background, contacts, and current state
- ✓ Read TASKS.md - Understanding of outstanding work and priorities
- ✓ Read DISCOVERY.md - Understanding of information gaps and questions

**Project Overview:**
- Project name/description: [brief summary from Quick Context]
- Current status: [from Quick Context Status field]
- Key stakeholders: [number of contacts across organizations]
- Outstanding tasks: [number of high-priority vs total tasks]
- Critical blockers: [list any active blockers]
- Unanswered questions: [number of high-priority discovery questions]

**Organizational Context:**
- Primary organizations involved: [list]
- Organizational relationships verified: [Yes/No - divisions, parent companies correctly documented]

**Ready to Proceed:**
- Confirm you understand the project context and are ready to assist
- Note any critical information gaps that should be addressed first
