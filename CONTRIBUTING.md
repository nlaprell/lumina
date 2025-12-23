# Contributing to Lumina

Thank you for contributing! This document provides guidelines for contributing to this project.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Git Branching Strategy](#git-branching-strategy)
- [Commit Conventions](#commit-conventions)
- [Labels and Milestones](#labels-and-milestones)
- [Pull Request Process](#pull-request-process)
- [Code Quality Standards](#code-quality-standards)

---

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/lumina.git`
3. Install git hooks for local validation: `./core/scripts/install-hooks.sh`
4. Create a branch for your work (see [Git Branching Strategy](#git-branching-strategy))

---

## Development Workflow

When working on a GitHub issue:

1. **Fetch the issue** - Read the issue details, acceptance criteria, and implementation steps
2. **Create a branch** - Follow the branching strategy below
3. **Implement changes** - Make incremental commits
4. **Run sanity checks** - Validate syntax and run tests
5. **Submit a PR** - Include acceptance criteria checklist

For AI agents, use the `/completeIssue` prompt which automates this workflow.

---

## Git Branching Strategy

### Branch Naming Convention

Branches are prefixed based on the type of work:

**Bug/Defect Branches:**
```
defect/{issue_number}-{brief-description}
```
- Used for: `bug`, `critical`, `defect`, or `fix` labeled issues
- Example: `defect/1-fix-mcp-config-format`

**Feature/Enhancement Branches:**
```
feature/{issue_number}-{brief-description}
```
- Used for: `enhancement`, `feature`, `documentation`, `refactor` labeled issues
- Example: `feature/5-centralized-logging`

**Branch Naming Rules:**
- Use kebab-case for description (lowercase with hyphens)
- Keep total branch name under 50 characters
- Always include the issue number
- Create branches from `main`

---

## Commit Conventions

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
type(scope): description

Body (optional)

Footer (optional)
```

### Commit Types

- **`feat`** - New feature
- **`fix`** - Bug fix
- **`docs`** - Documentation changes
- **`test`** - Adding or updating tests
- **`refactor`** - Code restructuring without behavior change
- **`chore`** - Maintenance tasks

### Commit Examples

```bash
feat(logging): add Python logging helper module

Implements #5
- Creates centralized logger with file and console handlers
- Supports log rotation (10MB max, 5 backups)
- Configurable log levels
```

```bash
fix(mcp): correct configuration format in init.sh

Fixes #1
- Change 'mcpServers' to 'servers' on line 154
- Update merge logic to output correct format
```

### Commit Rules

- ✅ Reference the issue in every commit (`Fixes #123` or `Implements #123`)
- ✅ Make atomic commits (one logical change per commit)
- ✅ Write clear, descriptive commit messages
- ❌ Never make one giant commit for multiple changes

---

## Labels and Milestones

### Type Labels (Required - Choose ONE)

Every issue/PR must have exactly one type label:

| Label | Description | Branch Prefix | Commit Type |
|-------|-------------|---------------|-------------|
| `bug` | Something is broken | `defect/` | `fix:` |
| `critical` | Urgent bug that blocks functionality | `defect/` | `fix:` |
| `enhancement` | New feature or improvement | `feature/` | `feat:` |
| `documentation` | Documentation changes only | `feature/` | `docs:` |
| `refactor` | Code restructuring | `feature/` | `refactor:` |

### Category Labels (Optional - Choose MULTIPLE)

Add category labels for additional context:

| Label | Used For |
|-------|----------|
| `quality` | Code quality improvements |
| `testing` | Test-related changes |
| `mcp` | Model Context Protocol related |
| `scripts` | Bash/shell script changes |
| `python` | Python code changes |
| `workflow` | GitHub Actions, CI/CD |
| `dependencies` | Dependency updates |
| `security` | Security-related issues |
| `AI Recommended` | Issue identified by AI health check analysis |

**Note**: The `AI Recommended` label is automatically added when issues are created via `/reportToGitHub` after running `/healthCheck`. This label distinguishes AI-discovered improvements from user-reported issues.

### Priority Labels (Optional - Choose ONE)

| Label | Timeline |
|-------|----------|
| `priority: high` | Next sprint/week |
| `priority: medium` | Next month |
| `priority: low` | Backlog |

### Status Labels

| Label | Meaning |
|-------|---------|
| `wip` | Work in progress (not ready for review) |
| `ready for review` | PR is complete |
| `blocked` | Cannot proceed due to dependency |
| `needs discussion` | Requires team discussion |

### Label Combinations

**For Bugs:**
```
Required: bug or critical
Optional: mcp, scripts, python, security
Priority: high, medium, or low
```

**For Features:**
```
Required: enhancement
Optional: quality, testing, mcp, scripts, python, workflow
Priority: high, medium, or low
```

**For Documentation:**
```
Required: documentation
Optional: (rarely needed)
Priority: (rarely needed)
```

### Labeling Examples

| Issue Type | Labels | Branch Name |
|------------|--------|-------------|
| MCP servers not loading | `bug`, `critical`, `mcp` | `defect/1-fix-mcp-config-format` |
| Add error handling | `enhancement`, `quality`, `scripts` | `feature/3-improve-error-handling` |
| Add smoke tests | `enhancement`, `testing`, `quality` | `feature/4-add-smoke-tests` |
| Exposed token | `bug`, `critical`, `security` | `defect/7-remove-exposed-token` |

### Milestones

Milestones group related issues for release planning.

**Naming Conventions:**
- **Semantic versioning**: `v1.0.0`, `v1.1.0`, `v1.0.1`
- **Phase-based**: `Phase 1: Core Functionality`, `Phase 2: Quality`
- **Time-based**: `Sprint 3`, `Q1 2025`

**When to Use Milestones:**
- ✅ Issue is part of a planned release
- ✅ Issue belongs to a specific project phase
- ✅ Issue is in current sprint/iteration
- ❌ Issue is exploratory or research
- ❌ Issue is a small fix with no release target
- ❌ Issue is in backlog with no timeline

**Examples:**
```
v1.0.0 - Bootstrap MVP
  Issues: #1, #2, #3, #4
  Due: 2025-01-15

Phase 2: Quality Improvements
  Issues: #3, #4, #5, #6, #7
  Due: 2025-02-01
```

---

## Pull Request Process

### PR Title Format

```
[Issue #{number}] Brief description
```

Examples:
- `[Issue #1] Fix MCP Configuration Format`
- `[Issue #5] Add Centralized Logging System`

### PR Description Template

```markdown
## Issue

Closes #123

## Summary

[Brief description of changes]

## Changes Made

- [Change 1]
- [Change 2]
- [Change 3]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Testing Performed

- [Test 1]
- [Test 2]

## Breaking Changes

[None or describe breaking changes]

## Notes

[Any additional context]
```

### PR Checklist

Before submitting a PR:

- [ ] Branch name follows convention (`defect/` or `feature/`)
- [ ] Commits follow conventional format
- [ ] All commits reference the issue
- [ ] Sanity checks passed (syntax validation)
- [ ] Tests run successfully (if applicable)
- [ ] Documentation updated (if needed)
- [ ] Acceptance criteria met
- [ ] PR description includes issue link and checklist
- [ ] Labels match the issue labels

---

## Code Quality Standards

### Sanity Checks

**Bash scripts:**
```bash
bash -n script.sh
```

**Python scripts:**
```bash
python3 -m py_compile script.py
```

**Note**: If a test suite exists, run it before submitting your PR.

### Pre-Commit Validation

If pre-commit hooks are installed:
- Bash syntax validation runs automatically
- Python syntax validation runs automatically
- Commit message format is validated

### Automated Checks

GitHub Actions will validate:
- PR has required labels
- Branch name follows convention
- Commits reference an issue
- Code passes syntax checks

---

## Questions?

If you have questions about contributing:
- Open an issue for clarification
- Review existing issues and PRs for examples
- Check the project README for overview
- See `.github/copilot-instructions.md` for AI agent guidelines

Thank you for contributing! 🎉
