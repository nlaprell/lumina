# Quality Assurance Workflow Architecture

**Last Updated**: December 22, 2025

This document describes the complete QA and issue tracking workflow for the Lumina bootstrap project.

---

## Overview

The Lumina QA system consists of **three integrated prompt workflows** that funnel findings to **GitHub Issues** as the single source of truth:

```
Developer Makes Changes
    ↓
Run: /sanityCheck (seconds)
├─ Checks: Recent changes only (staged/unstaged or last commit)
├─ Validates: Syntax, critical references, security
├─ Creates: .template/SANITY_CHECK_REPORT.md
└─ Result: ✅ PASS or ❌ FAIL
    ↓
If CRITICAL Issues Found → /reportToGitHub → Create GitHub Issues
    ↓
Otherwise: Proceed with commit

Separately (Weekly/Monthly):
Run: /healthCheck (minutes)
├─ Checks: Entire codebase comprehensively
├─ Audits: Code quality, documentation, UX, features
├─ Creates: .template/HEALTH_CHECK_REPORT.md
└─ Result: Detailed findings by severity
    ↓
Run: /reportToGitHub → Convert findings to GitHub Issues
    ↓
Use GitHub project board to track and prioritize work
```

---

## Prompt Workflows

### 1. `/sanityCheck` - Pre-Commit Quick Check ⚡

**Purpose**: Fast validation before every commit  
**Scope**: Recent changes only (staged/unstaged or last commit)  
**Duration**: Seconds  
**Triggers**: Before committing code  

**Checks**:
- Bash syntax validation (`bash -n script.sh`)
- Python syntax validation (`python3 -m py_compile script.py`)
- Broken file path references
- Security issues (unquoted variables, hardcoded secrets)
- Critical functionality gaps

**Output**: `.template/SANITY_CHECK_REPORT.md`

**Next Step**: If critical issues found → Run `/reportToGitHub` to create GitHub issues

**Key Feature**: Analyzes ONLY modified files for speed:
```bash
git diff --name-only              # unstaged changes
git diff --cached --name-only     # staged changes
git log -1 --name-only            # last commit (if clean)
```

---

### 2. `/healthCheck` - Comprehensive Codebase Audit 🔍

**Purpose**: Deep audit of entire template system  
**Scope**: Entire codebase and documentation  
**Duration**: Minutes  
**Triggers**: Weekly or monthly, before major releases  

**Checks**:
- **Project Structure**: Directory organization, file placement
- **Code Quality**: All scripts, syntax, best practices, edge cases
- **Prompt Workflows**: Consistency, accuracy, integration
- **Templates & Documentation**: Completeness, accuracy, examples
- **User Experience**: Complete workflow simulation
- **Integration & Dependencies**: Cross-references, dependencies
- **Completeness**: Missing features, TODOs, gaps

**Output**: `.template/HEALTH_CHECK_REPORT.md` (detailed findings by severity)

**Next Step**: Run `/reportToGitHub` to convert findings to GitHub issues

**Report Sections**:
- Executive Summary with status indicators (Excellent/Good/Needs Work/Critical)
- Issues organized by severity (🔴 Critical, 🟠 High, 🟡 Medium, 🟢 Low, 💡 Recommended)
- Detailed analysis by component
- Recommendations summary

---

### 3. `/reportToGitHub` - Issue Creation & Tracking 🐙

**Purpose**: Convert findings from health/sanity checks to GitHub issues  
**Source**: `.template/SANITY_CHECK_REPORT.md` or `.template/HEALTH_CHECK_REPORT.md`  
**Destination**: [GitHub Issues](https://github.com/nlaprell/lumina/issues)  

**Workflow**:
1. Read health check or sanity check report
2. Categorize issues by GitHub labels
3. Group related issues
4. Create GitHub issues with:
   - Proper labels (bug, enhancement, quality, documentation, etc.)
   - Assigned milestone (v1.0.0 MVP or v1.1.0 Post-MVP)
   - Acceptance criteria
   - Related/blocking issue links
5. Generate summary report

**Label Mapping**:
| Severity | Labels | Milestone | Priority |
|----------|--------|-----------|----------|
| 🔴 Critical | `bug`, `critical` | v1.0.0 | Process immediately |
| 🟠 High | `bug` or `enhancement` | v1.0.0 | 1-2 weeks |
| 🟡 Medium | `enhancement` | v1.1.0 | Planned |
| 🟢 Low | `enhancement` | v1.1.0 | Backlog |
| 💡 Recommended | `enhancement` | v1.1.0 | Future |

**Additional Labels**: `quality`, `testing`, `documentation`, `scripts`, `python`, `mcp`

---

## GitHub Issue Milestones

All issues created via `/reportToGitHub` are assigned to one of two milestones:

### v1.0.0 - MVP (Target: December 31, 2025)
- **Goal**: Bootstrap system fully functional for MarkLogic consultants
- **Includes**: Critical bugs, high-priority enhancements, core features
- **Issues**: Typically 9-12 items
- **Status**: Actively being worked

### v1.1.0 - Post-MVP (Target: Q1 2026)
- **Goal**: Quality improvements, additional features, documentation enhancements
- **Includes**: Medium/low priority enhancements, nice-to-have features
- **Issues**: Typically 5-8 items
- **Status**: Planned for future sprint

---

## Removed Markdown Tracking

⚠️ **IMPORTANT**: Legacy markdown trackers have been removed. All work is tracked in GitHub Issues.

- `.template/FIXES.md` - Removed (GitHub issues are source of truth)
- `.template/IMPROVEMENTS.md` - Removed (GitHub issues are source of truth)
- `/generateTasks` prompt - Deprecated; use `/reportToGitHub` instead

### Why?

1. **Single Source of Truth**: GitHub is the authoritative issue tracker
2. **No Duplication**: Eliminates sync burden of markdown files
3. **Better Tracking**: Labels, milestones, assignees, project boards
4. **Collaboration**: Comments, reviews, discussions on each issue
5. **Automation**: MCP tools automate issue creation from reports

---

## Complete Developer Workflow

### Before Every Commit

```bash
# 1. Make code changes
vim .template/scripts/init.sh

# 2. Run sanity check (quick validation)
# (This is the /sanityCheck prompt workflow)
#
# It will:
# - Check git status
# - Validate syntax of changed files
# - Check file references
# - Create .template/SANITY_CHECK_REPORT.md

# 3. If issues found in report:
# - Fix the issues
# - Re-run sanity check
# - Repeat until clean

# 4. If no issues:
git add .
git commit -m "feat: description"

# 5. If critical issues block commit:
# - Run /reportToGitHub to create GitHub issue
# - Fix issue in new commit
# - Link PR to issue: "Fixes #123"
```

### Weekly/Monthly Deep Audit

```bash
# 1. Run comprehensive health check
# (This is the /healthCheck prompt workflow)
#
# It will:
# - Audit entire codebase
# - Check documentation
# - Analyze UX and workflows
# - Create .template/HEALTH_CHECK_REPORT.md

# 2. Review findings
cat .template/HEALTH_CHECK_REPORT.md

# 3. Convert to GitHub issues
# (This is the /reportToGitHub prompt workflow)
#
# It will:
# - Read HEALTH_CHECK_REPORT.md
# - Categorize by severity and label
# - Create GitHub issues with milestones
# - Generate summary report

# 4. Track progress on GitHub
open https://github.com/nlaprell/lumina/issues
```

---

## Issue Severity & Priority Guide

### 🔴 Critical Issues

**Characteristics**:
- Break core functionality
- Prevent commits or releases
- Cause data loss or security risks
- Block other work
- Should never ship to users

**Examples**:
- Syntax errors in scripts
- Broken prompt references
- Security vulnerabilities
- Failed test suite

**Action**: Fix immediately before any commit  
**Milestone**: v1.0.0 (MVP)  
**Labels**: `bug`, `critical`

### 🟠 High Priority Issues

**Characteristics**:
- Major bugs or missing features
- Cause significant user friction
- Prevent important workflows
- Important for MVP completion

**Examples**:
- Missing error handling
- Unclear documentation
- Performance problems
- Important missing features

**Action**: Fix within 1-2 weeks  
**Milestone**: v1.0.0 (MVP)  
**Labels**: `bug` or `enhancement` + category labels

### 🟡 Medium Priority Issues

**Characteristics**:
- Improvements and enhancements
- Nice-to-have features
- Code quality improvements
- Documentation gaps

**Examples**:
- Add logging system
- Improve error messages
- Add tests
- Better documentation

**Action**: Schedule for next sprint  
**Milestone**: v1.1.0 (Post-MVP)  
**Labels**: `enhancement`, `quality`, category labels

### 🟢 Low Priority Issues

**Characteristics**:
- Minor improvements
- Polish and optimization
- Future enhancements
- Backlog items

**Examples**:
- Minor code reorganization
- Performance optimization
- Nice-to-have features
- Future exploration

**Action**: Backlog for future consideration  
**Milestone**: v1.1.0 (Post-MVP) or unassigned  
**Labels**: `enhancement`, category labels

### 💡 Recommended Enhancements

**Characteristics**:
- Ideas for improvement
- Not yet validated
- Research or exploration needed
- Low confidence

**Examples**:
- "Could we add X feature?"
- "What if we refactored Y component?"
- "Consider adopting Z best practice"

**Action**: Discuss with team before committing  
**Milestone**: Unassigned (for discussion)  
**Labels**: `enhancement`, optionally `needs discussion`

---

## Report Structure

### SANITY_CHECK_REPORT.md Structure

```markdown
# Pre-Commit Sanity Check Report
- Date
- Scope (Modified files | Last commit)
- Files Analyzed
- Status (✅ PASS | ❌ FAIL)
- Critical Issues Found

## Critical Issues
[List each with file, line, problem, fix]

## Validation Summary
[Syntax, references, security checks]

## Recommendation
[Safe to commit | Fix before committing]
```

### HEALTH_CHECK_REPORT.md Structure

```markdown
# Bootstrap Project Health Check Report
- Executive Summary with status
- Statistics (Critical, High, Medium, Low, Recommended)
- Issues by Severity (organized with detailed analysis)
- Detailed Analysis by Component
- Recommendations Summary
```

---

## GitHub Integration via MCP

The `/reportToGitHub` prompt uses MCP tools to automate GitHub issue creation:

```
.template/HEALTH_CHECK_REPORT.md
    ↓
Read and categorize findings
    ↓
mcp_github_create_issue (for each issue)
    ↓
GitHub Issue created with:
  - Title and description
  - Labels (bug, enhancement, quality, etc.)
  - Milestone (v1.0.0 or v1.1.0)
  - Acceptance criteria
    ↓
GitHub Project Board
    ↓
Track and close as work progresses
```

---

## Key Principles

1. **GitHub is Source of Truth**: All work tracked in GitHub issues
2. **Markdown Files Removed**: Legacy FIXES/IMPROVEMENTS markdown trackers are gone
3. **No Duplication**: Single system eliminates sync burden
4. **Automation**: MCP tools automate issue creation from reports
5. **Clear Severity**: Issues categorized by actual impact
6. **Fast Feedback**: Sanity check for every commit, health check weekly/monthly
7. **Milestone-Based**: Issues assigned to v1.0.0 (MVP) or v1.1.0 (Post-MVP)

---

## Quick Reference

| Need | Use This | Time | Scope |
|------|----------|------|-------|
| Pre-commit check | `/sanityCheck` | Seconds | Recent changes |
| Comprehensive audit | `/healthCheck` | Minutes | Entire codebase |
| Create GitHub issues | `/reportToGitHub` | Minutes | From reports |
| Track work | GitHub Issues | Ongoing | Single source of truth |

---

## Archive: Deprecated Prompts/Files

- ❌ `/generateTasks` - Use `/reportToGitHub` instead
- ❌ Legacy markdown trackers removed (`.template/FIXES.md`, `.template/IMPROVEMENTS.md`)

All work is tracked in GitHub issues.

---

## Next Steps

1. **Before committing**: Run `/sanityCheck` prompt
2. **If issues found**: Fix and re-run sanity check
3. **If critical blocker**: Run `/reportToGitHub` to create GitHub issue
4. **Weekly**: Run `/healthCheck` for comprehensive audit
5. **After health check**: Run `/reportToGitHub` to create GitHub issues
6. **Track progress**: Use GitHub project board and issues

---

**Questions?** Check the individual prompt files:
- [`.template/prompts/sanityCheck.prompt.md`](.template/prompts/sanityCheck.prompt.md)
- [`.template/prompts/healthCheck.prompt.md`](.template/prompts/healthCheck.prompt.md)
- [`.template/prompts/reportToGitHub.prompt.md`](.template/prompts/reportToGitHub.prompt.md)
