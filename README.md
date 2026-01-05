# Lumina

**Turn notes and email threads into structured project documentation automatically.**

AI-powered bootstrap system for MarkLogic consultants. Export emails and notes → generate comprehensive project docs in minutes.

---

## 🚀 Quick Start (3 Steps)

### 1. Export Your Data
- **Emails**: Export `.eml` files → place in `email/raw/`
- **Notes**: Export `.txt` or `.md` files → place in `notes/raw/`

### 2. Initialize Project
```bash
./go.sh
```
Choose **"Initialize Project"** and enter:
- Your name
- Project name  
- Customer name
- Select MCP servers (optional)

### 3. Generate Documentation
In GitHub Copilot chat:
```
/quickStartProject
```

**Done!** Check `PROJECT.md` for your complete project summary.

---

## 🧪 Try It With Sample Data

Want to see it work before adding your own data?

```
/initSampleProject
```

This will:
- ✅ Load 4 sample emails + 3 sample notes
- ✅ Process everything automatically  
- ✅ Generate complete documentation
- ✅ Show you what Lumina produces
- ✅ Reset to clean state when done

**Perfect for:** Testing the workflow, demos, understanding output format.

---

## 📝 Command Reference

| **I Want To...** | **Use This** |
|------------------|--------------|
| Set up new project | `./go.sh` → Initialize Project |
| Generate docs from emails/notes | `/quickStartProject` |
| Try with sample data | `/initSampleProject` |
| Add more emails | `/discoverEmail` then `/updateSummary` |
| Add more notes | `/discoverNotes` then `/updateSummary` |
| Create status report | `/generateReport` |
| Export docs to PDF | `./go.sh` → Export to PDF |
| Process emails from menu | `./go.sh` → Process Emails |
| Process notes from menu | `./go.sh` → Process Notes |
| Reload AI context | `/projectInit` |

<details>
<summary><strong>📋 All Commands (click to expand)</strong></summary>

| Command | Purpose |
|---------|---------|
| `/quickStartProject` | Complete workflow: init → process → generate docs |
| `/initSampleProject` | Test with bundled sample data (4 emails + 3 notes) |
| `/discoverEmail` | Process emails and update aiDocs/ |
| `/discoverNotes` | Process notes and update aiDocs/ |
| `/updateSummary` | Regenerate PROJECT.md and docs/ from aiDocs/ |
| `/generateReport` | Create executive status report |
| `/projectInit` | Re-initialize AI with project knowledge |
| `/validateTasks` | Check task IDs, dependencies, metadata |
| `/cleanupTasks` | Archive old tasks, optimize organization |
| `/syncFromProject` | Sync user edits from PROJECT.md to aiDocs/ |
| `/completeIssue <number>` | Automated Issue→Branch→PR workflow (template maintenance) |

</details>

---

## 📊 What You Get

After running `/quickStartProject` or `/initSampleProject`:

```
✅ PROJECT.md         Executive summary for stakeholders
✅ docs/              Quick reference (contacts, tasks, decisions, questions)
✅ aiDocs/            Complete project context for AI agents
✅ Task tracking      With dependencies automatically detected
✅ Risk analysis      Identified from emails and notes
✅ Contact list       Extracted with roles and organizations
✅ Decision log       Captured from communications
✅ PDF export         Professional package for handoffs (optional)
```

---

## 🎯 Common Workflows

**Weekly Status Update:**
```bash
# 1. Add new emails to email/raw/ and/or notes to notes/raw/
# 2. In Copilot chat:
/discoverEmail       # (if emails added)
/discoverNotes       # (if notes added)
/generateReport      # Creates reports/status-YYYY-MM-DD.md
```

**New Team Member Handoff:**
```bash
# Ensure docs are current, then share PROJECT.md and docs/ folder
# New team member runs:
/projectInit
```

**Export for Consultant Handoff:**
```bash
# Package complete project documentation as professional PDF
./go.sh
# Choose "Export to PDF"
# Opens: exports/project-name-YYYY-MM-DD.pdf
# Includes: PROJECT.md + docs/ + aiDocs/ (all documentation)
```

---

## 📦 Requirements

- **Python 3.x** + packages: `pip install -r core/aiScripts/requirements.txt`
- **GitHub Copilot** with slash command support in VS Code
- **Git** for version control

### PDF Export (Optional)

To export documentation as PDF:
- **Pandoc**: Document converter
- **LaTeX**: Professional typesetting engine

**macOS:**
```bash
brew install pandoc
brew install --cask basictex
# After installing BasicTeX:
sudo tlmgr update --self
sudo tlmgr install collection-fontsrecommended collection-xetex
```

**Linux:**
```bash
sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended
```

The PDF export feature will check for these dependencies and provide install instructions if missing.

---

<details>
<summary><strong>🔐 Security & Environment Setup (click to expand)</strong></summary>

## MCP Credentials

MCP servers require credentials (API tokens, access keys). Store in `.env`:

1. **Copy template:** `cp .env.template .env`
2. **Edit `.env`** with your credentials
3. **Run `./go.sh`** - credentials auto-populate `.vscode/mcp.json`

✅ `.env` is gitignored (safe)  
❌ Never commit `.env` or share credentials

## Security Warning

The `email/` and `notes/` directories contain sensitive information.

- ✓ `.gitignore` excludes email/notes files by default
- ✓ Review `PROJECT.md` before committing
- ✓ Never commit `.eml` or `.md` files with confidential data
- ✓ Use private repository for sensitive projects

</details>

---

<details>
<summary><strong>📖 How It Works (click to expand)</strong></summary>

### 1. Data Conversion
- Export emails to `.eml`, notes to `.txt`/`.md`
- Place in `email/raw/` and `notes/raw/`
- AI converts to structured Markdown
- Extracts: contacts, decisions, tasks, risks, technical details

### 2. AI Documentation
- Analyzes all content for project context
- Creates structured documentation in `aiDocs/`:
  - `SUMMARY.md` - Contacts, background, risks, decisions
  - `TASKS.md` - Task tracking with dependencies
  - `DISCOVERY.md` - Questions and information gaps
  - `AI.md` - Project-specific AI agent notes

### 3. Human-Readable Output
- Generates `PROJECT.md` at root (executive summary)
- Creates `docs/` folder with quick reference:
  - `CONTACTS.md`, `TASKS.md`, `DECISIONS.md`, `QUESTIONS.md`

### 4. Continuous Updates
- Add new content → Process → Regenerate
- Documentation stays current throughout project
- Dependencies automatically detected

</details>

---

<details>
<summary><strong>🏗️ Project Structure (click to expand)</strong></summary>

```
lumina/
├── 📄 PROJECT.md              ← Generated project summary
├── 📁 aiDocs/                 ← AI documentation (source of truth)
├── 📁 docs/                   ← Human-readable quick reference
├── 📁 email/raw/              ← Place .eml files here
├── 📁 notes/raw/              ← Place .txt/.md files here
├── 📁 prompts/                ← AI workflow prompts (/quickStartProject, etc.)
├── 🔧 go.sh                   ← Interactive menu (main entry point)
└── 📁 core/                   ← Template infrastructure
```

**Key Files:**
- `PROJECT.md` - Executive summary (generated)
- `aiDocs/` - Complete AI context (maintained)
- `docs/` - Quick reference (generated)

</details>

---

<details>
<summary><strong>📚 Detailed Prompt Reference (click to expand)</strong></summary>

## Primary Workflows

### `/quickStartProject` - Complete Project Initialization
**Use for:** First-time setup, complete workflow from start to finish

**What it does:**
- Initializes AI agent context
- Processes all emails and notes in raw/ directories
- Updates `aiDocs/` with extracted information
- Generates `PROJECT.md` and `docs/` folder

**When to run:** Setting up new project, want end-to-end processing

---

### `/initSampleProject` - Test With Sample Data
**Use for:** Testing workflow, demos, understanding output

**What it does:**
- Copies 4 sample emails + 3 sample notes to raw/ directories
- Runs complete initialization workflow
- Generates all documentation from sample data
- Resets environment when done

**When to run:** Before using with real data, giving demos, verifying setup

---

### `/projectInit` - Context Initialization
**Use for:** Refreshing AI agent understanding (read-only)

**When to run:** Starting new Copilot session, AI lost context

---

### `/discoverEmail` - Email Processing
**Use for:** Processing new email files

**When to run:** New emails added to `email/raw/`
**Follow with:** `/updateSummary`

---

### `/discoverNotes` - Notes Processing
**Use for:** Processing new notes files

**When to run:** New notes added to `notes/raw/`
**Follow with:** `/updateSummary`

---

### `/updateSummary` - Documentation Generation
**Use for:** Generating PROJECT.md and docs/ from aiDocs/

**When to run:** After processing emails/notes, after manual aiDocs/ edits

---

## Maintenance

### `/validateTasks` - Task Integrity Check
**Use for:** Quick validation without full documentation review

**When to run:** After editing TASKS.md, before planning sessions

---

### `/cleanupTasks` - Task Maintenance
**Use for:** Organizing and optimizing task list

**When to run:** Task list large (>20 tasks), quarterly maintenance

---

### `/syncFromProject` - Reverse Sync
**Use for:** Syncing user edits from PROJECT.md to aiDocs/

**When to run:** User edited PROJECT.md directly
**Follow with:** `/updateSummary`

---

### `/generateReport` - Executive Status Report
**Use for:** Creating status reports for stakeholders

**When to run:** Weekly updates, monthly reporting, management reviews

</details>

---

## 🔧 Maintenance

For developers maintaining Lumina itself, see [CONTRIBUTING.md](CONTRIBUTING.md).


