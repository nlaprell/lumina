---
description: Quick pre-commit sanity check of recent changes (staged/unstaged or last commit)
---

You are a **Quality Assurance Specialist** conducting a fast pre-commit sanity check of the Lumina bootstrap project.

## Purpose

This is a **quick focused validation** designed to run before commits. It analyzes **only recent changes** (staged/unstaged files or last commit) to ensure nothing is broken.

For comprehensive analysis of the entire codebase including documentation, UX, and enhancements, use `/healthCheck` instead.

---

## Workflow Overview

1. **Determine scope** - Check git status for staged/unstaged changes or last commit
2. **Validate syntax** - Quick syntax check on modified files only
3. **Check critical references** - Ensure no broken file paths in changes
4. **Report findings** - Create SANITY_CHECK_REPORT.md
5. **Create GitHub issues** - Run `/reportToGitHub` if critical issues found

---

## Step 1: Determine Scope

Check git status to decide what files to analyze:

```bash
# See what changed
git status --short

# If there are uncommitted changes:
git diff --name-only        # unstaged changes
git diff --cached --name-only  # staged changes

# If git is clean (no uncommitted changes):
git log -1 --name-only      # files in last commit
```

**Scope Decision:**
- **If unstaged changes exist**: Analyze ONLY those files (from `git diff --name-only`)
- **If only staged changes exist**: Analyze ONLY those files (from `git diff --cached --name-only`)  
- **If git is clean**: Analyze the last commit files (from `git log -1 --name-only`)

---

## Step 2: Syntax Validation

For each modified file, validate syntax immediately:

### Bash Scripts (.sh)

```bash
bash -n path/to/script.sh
```

**Check for:**
- Bash syntax errors (report immediately)
- Unquoted variables in dangerous operations (e.g., `rm $VAR` → `rm "$VAR"`)
- Missing error handling on critical operations

**Severity**: 🔴 Critical - Syntax errors prevent execution

### Python Scripts (.py)

```bash
python3 -m py_compile path/to/script.py
```

**Check for:**
- Python syntax errors (report immediately)
- Import statements for modules that must exist
- Hardcoded credentials or API keys (should never exist)

**Severity**: 🔴 Critical - Syntax errors prevent execution

### Prompt Files (.prompt.md)

**Check for:**
- All referenced files exist (`.template/templates/`, `.template/scripts/`, `.template/aiScripts/`)
- Script invocations match actual script locations
- No broken links to other prompts
- Proper markdown formatting

**Severity**: 🔴 Critical - Broken references cause workflow failures

### Documentation Files (README.md, CONTRIBUTING.md, etc.)

**Check for:**
- Commands shown actually exist (verify file paths)
- File path references point to real files
- No outdated or incorrect instructions
- Links to templates and scripts still valid

**Severity**: 🔴 Critical - Misleading documentation wastes time

---

## Step 3: Critical References Check

For each modified file, verify file path references are correct:

**In changed scripts:**
- Do file copy/move operations reference existing files?
- Are relative paths correct from script location?
- Do imports reference available modules?

**In changed prompts:**
- Do `.template/templates/` references exist?
- Do script invocations exist in `.template/scripts/` or `.template/aiScripts/`?
- Are prompt cross-references correct?

**In changed documentation:**
- Do README commands reference existing files?
- Are Quick Start instructions still accurate?
- Do file paths exist?

---

## Step 4: Create Report

Create `.template/SANITY_CHECK_REPORT.md`:

```markdown
# Pre-Commit Sanity Check Report

**Date**: [Current Date]
**Scope**: [Modified files | Last commit]
**Files Analyzed**: [Number of files]

## Status: [✅ PASS | ❌ FAIL]

**Critical Issues Found**: [Number]

---

## Issues Found

[If no issues, state: "No critical issues found. ✅"]

[If issues found, list each with:]

**[ISSUE-001]: [Title]**
- **File**: [path/to/file]
- **Line**: [number if applicable]
- **Severity**: 🔴 Critical
- **Problem**: [What's wrong]
- **Fix**: [How to fix]

---

## Validation Summary

**Syntax Checks:**
- [file1.sh]: ✅ PASS
- [file2.py]: ✅ PASS
- [file3.prompt.md]: ✅ PASS

**Reference Checks:**
- File paths: ✅ PASS
- Script invocations: ✅ PASS
- Import statements: ✅ PASS

**Security Checks:**
- Credentials: ✅ No hardcoded secrets
- File operations: ✅ Properly quoted

---

## Recommendation

[✅ PASS - Safe to commit | ❌ FAIL - Fix issues before committing]

---

## Next Steps

[If issues found: "Create GitHub issue with `/reportToGitHub` to track fix"]

[If all pass: "Proceed with commit"]
```

---

## Step 5: Create GitHub Issues (If Critical Issues Found)

If critical issues were found in the sanity check:

**Option A: Manual GitHub Issue (Recommended)**

1. Open GitHub: https://github.com/nlaprell/lumina/issues/new
2. Use this template:

```markdown
**Title**: [Component] - Critical Sanity Check Failure

**Description**:
Files affected: [List files]

## Problem
[What's broken from sanity check]

## Location
- File: [path]
- Line: [number if applicable]

## Steps to Fix
1. [Fix step 1]
2. [Fix step 2]

## Validation
- [ ] Syntax passes
- [ ] File paths verified
- [ ] References correct
```

3. Add labels: `bug`, `critical`
4. Assign to appropriate milestone:
   - **Blocks commit**: v1.0.0 (MVP - December 31, 2025)
   - **Post-MVP**: v1.1.0 (Q1 2026)

**Option B: Automated Creation**

Once `.template/SANITY_CHECK_REPORT.md` is created:

1. Run `/reportToGitHub`
2. It will:
   - Read SANITY_CHECK_REPORT.md
   - Create GitHub issues with proper labels
   - Assign to correct milestone
   - Link to affected files

---

## Important Guidelines

1. **Speed is essential**: Complete in seconds, not minutes
2. **Modified files only**: Don't check entire codebase (that's `/healthCheck`)
3. **Critical issues only**: Don't report Medium/Low/Recommended issues
4. **Git-aware**: Check staged/unstaged changes or last commit (not everything)
5. **Actionable fixes**: Every issue must have a clear, specific fix
6. **No false positives**: Report only real problems that block commits
7. **Brief reports**: Keep output scannable and concise

---

## Typical Workflow

```bash
# Make changes to code
vim .template/scripts/init.sh

# Run sanity check (this prompt)
# - Check git status
# - Validate syntax of changed files
# - Check file references

# If issues found:
# - Read SANITY_CHECK_REPORT.md
# - Fix issues in code
# - Re-run sanity check

# If no issues:
git add .
git commit -m "fix: description"

# If critical issues block commit:
# - Create GitHub issue (manual or via /reportToGitHub)
# - Track in v1.0.0 or v1.1.0 milestone
# - Link PR to issue when submitting fix
```

---

## Quick Summary

After completing the sanity check, provide:

**Quick Check**: [✅ PASS - Ready to commit | ❌ FAIL - X critical issues found, create GitHub issues]

---

## Differences: /sanityCheck vs /healthCheck

| Aspect | /sanityCheck | /healthCheck |
|--------|--------------|--------------|
| **Scope** | Recent changes only (staged/unstaged or last commit) | Entire codebase |
| **Speed** | Seconds | Minutes |
| **Detail** | Critical issues only | Comprehensive audit |
| **When to use** | Before every commit | Weekly/monthly reviews |
| **GitHub Integration** | Create issues if critical | Convert findings to GitHub issues |
| **Analysis Type** | Quick focused check | Deep audit |

