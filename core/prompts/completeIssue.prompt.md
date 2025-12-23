---
description: Complete a GitHub issue following standardized workflow from issue to PR
---

**CRITICAL**: When a user requests that a GitHub issue be completed, implemented, or worked on, you MUST follow this standardized workflow. Do NOT ask for confirmation or skip steps.

## Workflow Steps

### 1. Fetch Issue Details

- Use GitHub MCP tools to get the full issue details
- Read the issue body, acceptance criteria, implementation steps
- Understand the scope and requirements completely
- Note any dependencies or related issues
- Document the issue number, labels, and milestone

### 2. Ask Critical Questions (If Needed)

Before starting implementation, identify and ask about potential problems:

**Ask the user IF:**
- [ ] **Blockers exist**: Is this issue blocked by other open issues? Should those be completed first?
- [ ] **Unclear requirements**: Are any acceptance criteria ambiguous or missing important details?
- [ ] **Scope concerns**: Does the scope seem too large or too small? Should it be broken into smaller issues?
- [ ] **Testing strategy**: How should this be tested? Should you run existing tests? Create new tests?
- [ ] **Documentation updates**: Will this require updates to README, CONTRIBUTING, or other documentation?
- [ ] **Breaking changes**: Could these changes affect other functionality or break existing workflows?
- [ ] **Platform compatibility**: Does this need to work on both macOS and Linux?

**Only ask questions if you identify actual concerns.** If the issue is clear and straightforward, proceed to Step 3 without asking.

### 3. Create Branch Based on Issue Type

**Determine branch prefix from issue labels:**
- **Bug/Defect**: Issues with `bug`, `critical`, `defect`, or `fix` labels → `defect/{number}-{description}`
- **Feature/Enhancement**: Issues with `enhancement`, `feature`, or other labels → `feature/{number}-{description}`

**Branch naming format**: `{prefix}/{issue_number}-{brief-description}`
- Examples:
  - Bug: `defect/1-fix-mcp-config-format`
  - Feature: `feature/5-centralized-logging`
- Use kebab-case for description (lowercase with hyphens)
- Keep branch name under 50 characters total
- Create branch from current default branch (usually `main`)
- Link branch to issue in commit messages

### 4. Implement the Changes

- Run syntax validation for all modified scripts
- For bash scripts: `bash -n script.sh`
- For Python scripts: `python3 -m py_compile script.py`
- Verify file paths are correct
- Check that no placeholders remain
- Ensure changes match acceptance criteria
- If tests exist, run them: `core/tests/test_suite.sh`

### 5. Commit Changes

- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`
- Reference issue in commit: `Fixes #123` or `Implements #123`
- Example: `feat(logging): add centralized logging system\n\nImplements #5`
- Make commits atomic (one logical change per commit)
- Write clear, descriptive commit messages

### 6. Verify Acceptance Criteria

Before creating the PR, verify that all acceptance criteria from the issue are met:

**Review each acceptance criterion:**
- [ ] Read the acceptance criteria from the original issue
- [ ] Verify your changes address each criterion
- [ ] Check for completeness (nothing partially implemented)
- [ ] Test manually if applicable
- [ ] Run any automated tests

**Verify no side effects:**
- [ ] Changes don't break existing functionality
- [ ] No new warnings or deprecations introduced
- [ ] Documentation is updated if needed
- [ ] Breaking changes are clearly documented (if any)

**If criteria not fully met:**
1. Implement missing pieces
2. Add new commits
3. Run sanity checks again
4. Return to this verification step

**If all criteria met:**
Proceed to Step 7 (Run Sanity Check)

### 7. Run Sanity Check Before PR

**MANDATORY**: Before creating the PR, run a sanity check on all changes:

```
/sanityCheck
```

This validates:
- ✅ Bash syntax for all modified .sh files
- ✅ Python syntax for all modified .py files
- ✅ File path references are correct
- ✅ No broken links in modified prompts
- ✅ No security issues (unquoted variables, credentials)

**If sanity check FAILS:**
1. Review the SANITY_CHECK_REPORT.md
2. Fix all critical issues identified
3. Commit fixes
4. Re-run `/sanityCheck`
5. Only proceed when sanity check PASSES

**If sanity check PASSES:**
Proceed to Step 8 (Create Pull Request)

### 8. Create Pull Request

- Title format: `[Issue #{number}] Brief description`
- Example: `[Issue #5] Add centralized logging system`
- Include in PR description:
  - Link to issue: `Closes #123`
  - Summary of changes
  - Acceptance criteria checklist (from issue) - mark all as completed
  - Testing performed
  - Any breaking changes or notes
- Assign yourself as the PR author
- Add relevant labels (match issue labels)
- Request review if applicable

**STOP HERE** - Do NOT merge the PR automatically. The workflow ends after creating the PR. The user will review and merge manually.

**Note**: The sanity check (Step 7) ensures code quality before PR submission. This catches critical issues early and maintains a clean PR history.

## Example Flows

### Example 1: Bug Fix

**User says**: "Complete issue #1"

Issue #1 has labels: `bug`, `critical`, `mcp`

```bash
# 1. Fetch issue (using MCP GitHub tools)
# Issue #1: "Fix MCP Configuration Format"
# Labels: bug, critical, mcp

# 2. Ask clarifying questions (if needed)
# - No blockers: Issue is standalone
# - Requirements clear: Configuration format is well-documented
# - Scope appropriate: Just 2 files to fix
# - Testing strategy: Bash syntax check sufficient

# 3. Create defect branch (bug label detected)
git checkout -b defect/1-fix-mcp-config-format

# 4. Implement changes (multiple commits)
git add core/scripts/init.sh
git commit -m "fix(mcp): correct configuration format in init.sh

Fixes #1
- Change 'mcpServers' to 'servers' on line 154
- Update merge logic to output correct format"

git add core/scripts/clean-reset.sh
git commit -m "fix(mcp): correct configuration format in clean-reset.sh

Fixes #1
- Change 'mcpServers' to 'servers' on line 162"

# 5. Already committed above

# 6. Verify acceptance criteria
# - [ ] Line 154 in init.sh: changed to 'servers'
# - [ ] Line 162 in clean-reset.sh: changed to 'servers'
# - [ ] Bash syntax checks pass

# 7. Run sanity check
/sanityCheck
# ✅ PASS - All syntax valid, no broken references

# 8. Create PR
# Title: [Issue #1] Fix MCP Configuration Format
# Body: Closes #1, fixes critical MCP server loading bug
```

### Example 2: Feature Enhancement

**User says**: "Implement issue #5"

Issue #5 has labels: `enhancement`, `quality`

```bash
# 1. Fetch issue (using MCP GitHub tools)
# Issue #5: "Add Centralized Logging System"
# Labels: enhancement, quality

# 2. Ask clarifying questions (if needed)
# - No blockers: Logging is standalone feature
# - Requirements clear: Detailed specification in issue
# - Scope appropriate: Single cohesive feature
# - Testing strategy: Run test suite, test with email converter
# - Documentation: Will need to update usage examples

# 3. Create feature branch (enhancement label detected)
git checkout -b feature/5-centralized-logging

# 4. Implement changes (multiple commits)
git add core/aiScripts/logger.py
git commit -m "feat(logging): add Python logging helper module

Implements #5
- Creates centralized logger with file and console handlers
- Supports log rotation (10MB max, 5 backups)
- Configurable log levels"

git add core/aiScripts/emailToMd/eml_to_md_converter.py
git commit -m "feat(logging): integrate logging into email converter

Implements #5
- Replace print statements with logger calls
- Add DEBUG level for detailed email processing
- Include stack traces in error logs"

# 5. Already committed above

# 6. Verify acceptance criteria
# - [ ] Logger module created with rotation support
# - [ ] Email converter uses new logger
# - [ ] DEBUG level shows detailed processing
# - [ ] All tests pass
# - [ ] Error logs include stack traces

# 7. Run sanity check
/sanityCheck
# ✅ PASS - Python syntax valid, imports correct

# 8. Create PR
# Title: [Issue #5] Add Centralized Logging System
# Body: Closes #5, adds comprehensive logging infrastructure
```

## Mandatory Rules

- ✅ **ALWAYS** ask clarifying questions if you identify concerns (Step 2)
- ✅ **ALWAYS** create a feature branch (never commit directly to main)
- ✅ **ALWAYS** link commits to the issue (`Fixes #123`, `Implements #123`)
- ✅ **ALWAYS** run sanity checks before committing
- ✅ **ALWAYS** verify acceptance criteria are met before creating PR (Step 6)
- ✅ **ALWAYS** run `/sanityCheck` before creating PR (Step 7)
- ✅ **ALWAYS** create a PR and STOP (let user review and merge)
- ✅ **ALWAYS** include acceptance criteria checklist in PR
- ❌ **NEVER** skip the sanity check step
- ❌ **NEVER** skip acceptance criteria verification
- ❌ **NEVER** make one giant commit (break into logical commits)
- ❌ **NEVER** commit broken code (syntax errors, etc.)
- ❌ **NEVER** proceed with partial understanding of requirements
- ❌ **NEVER** automatically merge PRs (user reviews and merges manually)

## When Things Go Wrong

**If sanity checks fail:**
1. Fix the issues identified
2. Re-run sanity checks
3. Commit fixes separately
4. Continue with PR creation

**If implementation is unclear:**
1. Ask clarifying questions BEFORE creating the branch
2. Do NOT proceed with partial understanding
