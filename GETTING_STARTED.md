# Copilot Template

A project template designed to help AI agents (GitHub Copilot) quickly understand and work on your projects by maintaining structured documentation and email context.

---

## ⚠️ SECURITY WARNING

**IMPORTANT**: The `email/` directory may contain sensitive information from your email communications. Before committing to a public repository:

- ✓ Verify `.gitignore` is properly configured to exclude email files
- ✓ Review `PROJECT.md` for any sensitive customer or business information
- ✓ Never commit `.eml` files or converted Markdown emails containing confidential data
- ✓ Consider using a private repository for projects with sensitive context

**The `.gitignore` file is configured to exclude email files by default, but always verify before pushing to remote repositories.**

---

## 🚀 Quick Start (3 Steps)

### Step 1: Run Project Manager
```bash
./go.sh
```
Select "Initialize Project" to configure your project name, customer name, and MCP servers.

### Step 2: Add Email Context
Export project-related emails to `.eml` format and place them in:
```
./email/raw/
```

### Step 3: Initialize Project
In GitHub Copilot chat, run:
```
/quickStartProject
```

**That's it!** The workflow will automatically:
- ✓ Process all emails and extract project information (including attachments)
- ✓ Update AI documentation with contacts, tasks, and technical details
- ✓ Generate a comprehensive project summary
- ✓ Create human-readable documentation in `docs/` folder

📄 **Check `PROJECT.md` at the project root for your complete project status**

📁 **Check `docs/` folder for quick reference (contacts, tasks, decisions, questions)**

---

## Basic Workflow

 - Export any new/updated emails to `email/raw`
 - Send `/discoverEmail` to the AI chat to convert .eml files into .md files in `email/ai`.
 - Send `/updateSummary` to the AI chat to update the AI documentation and the root `PROJECT.md` and `docs/` files based on the full context of all processed emails.

**Result:** `PROJECT.md` at the project root contains a human-readable summary of the project. The `docs/` folder contains quick reference extracts (contacts, tasks, decisions, questions). Documentation in `aiDocs/` is updated based on the full context of the emails as well.

---

## Detailed Setup Guide

### 1. Copy This Repository

```bash
git clone <your-repo-url>
cd copilot_template
```

Or simply copy/fork this repository to start your new project.

### 2. Run Initial Setup

Execute the project manager to configure your project:

```bash
./go.sh
```

Select "Initialize Project" from the menu. This will:
- Prompt you to enter your name (for task tracking)
- Prompt you to enter your project name
- Prompt you to enter your customer/client name
- Display available MCP server configurations from `.template/mcpServers/`
- Let you select which servers to enable using arrow keys and spacebar
- Generate `.vscode/mcp.json` with your selected configurations

### 3. Quick Start (Recommended)

The fastest way to get started is to use the `/quickStartProject` prompt in Copilot chat:

```
/quickStartProject
```

This will automatically:
- Initialize the AI agent with project context
- Check for email files in `email/raw/` and prompt you to add them if missing
- Process any emails found and update documentation
- Generate a comprehensive project summary at `PROJECT.md`
- Create human-readable extracts in `docs/` folder

**After completion, check `PROJECT.md` for your project status overview**

**Also check `docs/` folder for quick reference materials**

**OR** follow the individual steps below for more control:

### 3a. Initialize AI Agent Context (Manual)

In GitHub Copilot chat, enter:

```
/projectInit
```

This prompt will guide the AI agent to:
- Read AI agent instructions from `aiDocs/AI.md`
- Understand the project structure and email processing workflow
- Review project documentation in `aiDocs/`
- Get familiar with available tools and scripts

### 3b. Process Email Context (Manual, Optional)

If you have project-related emails:

1. **Export emails** to `.eml` format from your email client
2. **Place them** in the `email/raw/` directory
3. **Run the discovery prompt** in Copilot chat:

```
/discoverEmail
```

This will:
- Convert `.eml` files to Markdown using `.template/aiScripts/emailToMd/eml_to_md_converter.py`
- Save converted emails to `email/ai/`
- Update all documentation in `aiDocs/` based on email content
- Extract contacts, tasks, technical details, and discovery questions

### 3c. Generate Project Summary (Manual)

After setting up documentation, generate a human-readable summary in Copilot chat:

```
/updateSummary
```

This will:
- Review all `aiDocs/` files for consistency and accuracy
- Cross-reference with email content
- Create/update `PROJECT.md` at the project root with:
  - Current project status
  - Completed and outstanding tasks
  - Blockers and risks
  - Key contacts and next steps
- Generate human-readable extracts in `docs/` folder:
  - `docs/CONTACTS.md` - Key stakeholder contact information
  - `docs/TASKS.md` - High-priority tasks and blockers
  - `docs/DECISIONS.md` - Decision log table
  - `docs/QUESTIONS.md` - Outstanding discovery questions

## Project Structure

```
copilot_template/
├── .github/
│   └── copilot-instructions.md  # Universal AI agent instructions
├── .vscode/
│   ├── settings.json      # GitHub Copilot slash command mappings
│   └── mcp.json           # MCP server configuration (generated by init.sh)
├── docs/                  # Human-readable quick reference files
│   ├── CONTACTS.md       # Key stakeholder contact information
│   ├── TASKS.md          # High-priority tasks and blockers
│   ├── DECISIONS.md      # Decision log table
│   └── QUESTIONS.md      # Outstanding discovery questions
├── aiDocs/                # AI agent documentation (continuously updated)
│   ├── AI.md             # Project-specific AI agent notes
│   ├── SUMMARY.md        # Single source of truth for project state
│   ├── TASKS.md          # Task tracking
│   └── DISCOVERY.md      # Discovery questions
├── .template/            # Template infrastructure (used during setup)
│   ├── scripts/          # Setup and reset scripts
│   │   ├── init.sh       # One-time setup script
│   │   └── clean-reset.sh # Reset to template state
│   ├── aiScripts/        # Email conversion and dependency detection tools
│   │   ├── emailToMd/    # Email to Markdown converter
│   │   └── detectTaskDependencies/  # Task dependency detection
│   ├── templates/        # Template files for aiDocs
│   ├── mcpServers/       # MCP server configurations
│   ├── prompts/          # Bootstrap maintenance workflows
│   ├── FIXES.md         # Bootstrap bug tracking
│   ├── IMPROVEMENTS.md  # Bootstrap enhancements
│   └── SANITY_CHECK_REPORT.md  # Bootstrap analysis
├── email/               # Email processing directories
│   ├── raw/            # Place .eml files here
│   ├── ai/             # Converted Markdown emails
│   └── processed/      # Archived .eml files
├── prompts/             # User workflow prompts (slash commands)
│   ├── ProjectInit.prompt.md
│   ├── discoverEmail.prompt.md
│   ├── updateSummary.prompt.md
│   └── quickStartProject.prompt.md
├── go.sh                # Interactive project manager menu
├── PROJECT.md           # Human-readable project summary
└── GETTING_STARTED.md   # This file (template setup guide)
```

## Key Files Explained

### AI Documentation (`aiDocs/`)

- **Template files**: Template files stored in `.template/templates/`
  - `SUMMARY.template.md`: Template for project summary
  - `TASKS.template.md`: Template for task tracking
  - `DISCOVERY.template.md`: Template for discovery questions
  - `AI.template.md`: Template for AI agent instructions
  - Use `./go.sh` and select "Reset Project" to reset all aiDocs files to templates

- **`AI.md`**: Master instructions for AI agents working on the project
  - Project structure and organization
  - Email processing workflow
  - Documentation maintenance guidelines

- **`DISCOVERY.md`**: Discovery questions and information gaps
  - Customer setup and environment questions
  - Outstanding information needs
  - Clarifications required

- **`SUMMARY.md`**: Detailed project context for AI agents
  - Background and history
  - Key contacts and stakeholders
  - Technical details and current situation
  - Risks and planning options

- **`TASKS.md`**: Task tracking
  - High priority outstanding tasks
  - Planning and documentation tasks
  - Completed tasks with dates

### Prompts (`prompts/`)

Copilot prompts to invoke with `/promptName` in chat:

- **`/quickStartProject`**: Complete workflow - initialize, process emails, and generate summary in one command
- **`/projectInit`**: Initialize AI agent with full project context
- **`/discoverEmail`**: Process raw emails and update documentation
- **`/updateSummary`**: Review docs for consistency and generate summary

### Scripts (`.template/aiScripts/`)

- **`emailToMd/`**: Email to Markdown converter
  - Converts `.eml` files to readable Markdown
  - Automatically organizes files in `email/` directories
  - See `.template/aiScripts/emailToMd/README.md` for details

### Utility Scripts (`scripts/`)

- **`clean-reset.sh`**: Reset project to clean template state
  - Clears all email directories (raw, ai, processed)
  - Resets all `aiDocs/` files to template defaults
  - Removes project-specific data from root `SUMMARY.md`
  - Preserves configuration files and scripts
  - Run with: `./scripts/clean-reset.sh`

## Workflow

### Typical Project Flow

1. **Start new project**: Copy this template
2. **Configure MCP servers**: Run `./go.sh` and select "Initialize Project"
3. **Initialize AI agent**: Use `/projectInit` in Copilot
4. **Add email context**: Export emails to `email/raw/`
5. **Process emails**: Use `/discoverEmail` in Copilot
6. **Generate summary**: Use `/updateSummary` in Copilot
7. **Iterate**: Update `aiDocs/` as project evolves

### Maintaining Documentation

The AI agent is responsible for keeping documentation current:

- **`aiDocs/DISCOVERY.md`**: Updated as new questions arise
- **`aiDocs/SUMMARY.md`**: Maintained with current project state
- **`aiDocs/TASKS.md`**: Updated as tasks are added/completed
- **`PROJECT.md`** (root): Generated periodically for human stakeholders
- **`docs/`** (folder): Human-readable extracts for quick reference

## Email Processing

### Why Process Emails?

Email threads often contain crucial project context:
- Technical discussions and decisions
- Customer requirements and questions
- Project history and timeline
- Key stakeholder communications

### How Email Processing Works

1. Export email threads as `.eml` files from your email client
2. Place them in `email/raw/`
3. Run `/discoverEmail` in Copilot chat
4. The converter script extracts:
   - Subject, sender, recipients, date
   - Email body (converted from HTML to Markdown)
5. Converted emails saved to `email/ai/` as `.md` files
6. Original `.eml` files archived to `email/processed/`
7. AI agent reads Markdown emails and updates all `aiDocs/` files

## MCP Server Configuration

The template includes configurations for several MCP servers in `.template/mcpServers/`:

- **github.json**: GitHub API integration
- **awsCore.json**: AWS Labs core MCP server
- **context7.json**: Context7 MCP server

Run `./go.sh` and select "Initialize Project" to choose which servers to enable in your workspace.

### Adding New MCP Servers

1. Create a new `.json` file in `.template/mcpServers/`
2. Follow the MCP server configuration format
3. Run `./go.sh` and select "Initialize Project" to regenerate `.vscode/mcp.json`

## Customizing for Your Project

### Starting from Template

When using this template for a new project, you have two options:

**Option 1: Clean Reset (Recommended)**
```bash
./scripts/clean-reset.sh
```
This will reset all `aiDocs/` files to template defaults and clear email directories, giving you a fresh start.

**Option 2: Manual Customization**

1. Update `aiDocs/SUMMARY.md` with your project details:
   - Replace `[CUSTOMER NAME]` with actual customer
   - Fill in background information
   - Add key contacts

2. Update `aiDocs/TASKS.md` with initial tasks

3. Add discovery questions to `aiDocs/DISCOVERY.md`

### Ongoing Maintenance

Let the AI agent maintain documentation by:
- Using the `/discoverEmail` prompt when new emails arrive
- Using the `/updateSummary` prompt to generate status reports
- Manually updating `aiDocs/` files as needed
- Keeping the AI informed of project changes

### Resetting to Clean State

If you want to reuse the template for another project or clear out all project-specific data:

```bash
./scripts/clean-reset.sh
```

This will:
- ✓ Clear all email directories
- ✓ Reset `aiDocs/` files to templates
- ✓ Remove root `PROJECT.md` and `docs/` folder
- ✓ Preserve all configuration and scripts

## Tips for Best Results

1. **Email Quality**: Export complete email threads, not individual messages
2. **Regular Updates**: Run `/updateSummary` regularly to track progress
3. **Discovery Questions**: Keep `DISCOVERY.md` updated with unknowns
4. **Task Tracking**: Update `TASKS.md` as work progresses
5. **AI Context**: Re-run `/projectInit` if AI seems to lose context

## Requirements

- **Python 3**: For email converter script
- **Git**: For version control
- **GitHub Copilot**: With prompt support
- **VS Code**: Recommended editor

The email converter automatically installs required Python packages (`html2text`).

