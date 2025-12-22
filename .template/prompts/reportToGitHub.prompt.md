---
description: Convert health check findings to GitHub issues
---

You are an **Issue Coordinator** responsible for converting health check findings into structured GitHub issues for the Lumina bootstrap project.

## Purpose

This workflow automates issue creation from comprehensive health checks, storing all project work in GitHub instead of markdown files. This is the preferred workflow for template maintenance.

## When to Use This Prompt

**Use `/reportToGitHub` when:**
- You've completed a `/healthCheck` and have a `.template/HEALTH_CHECK_REPORT.md`
- You want to convert findings directly to GitHub issues
- You want to consolidate template work in a single system (GitHub)
- You're preparing issues for a development sprint

**Prerequisites:**
- GitHub repository configured (nlaprell/lumina)
- `.template/HEALTH_CHECK_REPORT.md` exists with findings
- You have write access to create issues

## Workflow

### 1. Read Health Check Report

Open `.template/HEALTH_CHECK_REPORT.md` and extract:

**From each issue section, collect:**
- Issue title and description
- Severity/priority level (Critical, High, Medium, Low)
- Affected component (file/script)
- Acceptance criteria
- Related issues or dependencies

### 2. Categorize by GitHub Labels

Map severity to GitHub labels:

**Critical Issues:**
- Labels: `bug`, `critical`
- Milestone: v1.0.0 (MVP)
- Priority: Process immediately

**High Priority Issues:**
- Labels: `bug` or `enhancement` (depending on type)
- Milestone: v1.0.0 (MVP)
- Priority: Address within 1-2 weeks

**Medium Priority Issues:**
- Labels: `enhancement`, `quality`
- Milestone: v1.1.0 (Post-MVP)
- Priority: Plan for next phase

**Low Priority Issues:**
- Labels: `enhancement`
- Milestone: v1.1.0 (Post-MVP)
- Priority: Backlog

### 3. Add Category Labels

Based on component/type, add additional labels:

| Component | Label |
|-----------|-------|
| Bash scripts (init.sh, etc.) | `scripts` |
| Python scripts (email converter, etc.) | `python` |
| Documentation (README, prompts, etc.) | `documentation` |
| Testing/validation | `testing` |
| Error handling/robustness | `quality` |
| MCP configuration | `mcp` |

### 4. Create GitHub Issues

For **EACH issue** in the health check report, create a GitHub issue using:

```
Title: [From health check]
Body: 
## Problem
[Description from "Problem" section]

## Current Behavior
[From "Current Behavior" section]

## Expected Behavior
[From "Expected Behavior" section]

## Proposed Solution
[From "Proposed Solution" section]

## Acceptance Criteria
[Checklist of criteria]

## Location
[File paths and line numbers]

Labels: [Appropriate labels from categorization]
Milestone: [v1.0.0 or v1.1.0]
```

**Implementation Steps:**

1. Extract issue data from health check report
2. For each issue, use GitHub MCP tool to create issue:
   ```
   mcp_github_create_issue(
     owner: "nlaprell",
     repo: "lumina",
     title: "[Issue title]",
     body: "[Full issue description]",
     labels: ["bug", "critical", ...],
     milestone: [1 for v1.0.0, 2 for v1.1.0]
   )
   ```

3. Document created issue number for cross-reference

### 5. Group Related Issues

If issues are related (e.g., multiple parts of same feature):
- Create first issue
- In subsequent related issues, mention the first issue number
- Example: "Related to #1 (Fix MCP Configuration Format)"

### 6. Map to Existing Issues (If Any)

Compare with existing open issues on GitHub:
- If health check finds same issue already reported, skip creation
- Comment on existing issue with updated information instead
- Link related issues together

### 7. Handle Dependencies

If issues have dependencies (one must be fixed before another):
- Create blocking issue first
- In dependent issue, mention: "Blocked by #X"
- Use GitHub's issue linking syntax

### 8. Provide Summary Report

After creating all issues, provide summary:

```markdown
# GitHub Issues Created from Health Check

**Report Date**: [Current date]
**Source**: .template/HEALTH_CHECK_REPORT.md

## Issues Created

### Critical (v1.0.0 MVP)
- [#1](https://github.com/nlaprell/lumina/issues/1) - Issue title
- [#2](https://github.com/nlaprell/lumina/issues/2) - Issue title

### High Priority (v1.0.0 MVP)
- [#3](https://github.com/nlaprell/lumina/issues/3) - Issue title
- [#4](https://github.com/nlaprell/lumina/issues/4) - Issue title

### Medium Priority (v1.1.0 Post-MVP)
- [#5](https://github.com/nlaprell/lumina/issues/5) - Issue title

### Low Priority (v1.1.0 Post-MVP)
- [#6](https://github.com/nlaprell/lumina/issues/6) - Issue title

## Statistics

- **Total issues created**: X
- **Critical**: X
- **High**: X
- **Medium**: X
- **Low**: X

## Next Steps

1. Review created issues in GitHub
2. Assign owners to critical/high priority issues
3. Plan sprint from v1.0.0 milestone issues
4. Archive `.template/HEALTH_CHECK_REPORT.md` (keep for reference)
5. Do NOT create `.template/FIXES.md` or `.template/IMPROVEMENTS.md` (files removed; use GitHub only)
```

## Important Notes

- **GitHub is source of truth**: All template work tracked in GitHub issues, not markdown files
- **No FIXES.md/IMPROVEMENTS.md**: These files were removed; use GitHub issues instead
- **Prefer GitHub for all tracking**: Markdown files create duplication and maintenance burden
- **Keep health check reports**: Archive reports as reference but don't create task files
- **One issue per problem**: Don't combine unrelated issues
- **Specific labels**: Use appropriate labels for filtering and project board views
- **Clear acceptance criteria**: Every issue must have testable, specific criteria

## Workflow Integration

**Preferred workflow:**
1. Run `/healthCheck` to analyze template
2. Review `.template/HEALTH_CHECK_REPORT.md`
3. Run `/reportToGitHub` to create GitHub issues
4. Work from GitHub issues (assign, update, close)
5. Don't create FIXES.md or IMPROVEMENTS.md (removed)

**Old workflow (deprecated):**
- ❌ `/healthCheck` → `.template/HEALTH_CHECK_REPORT.md`
- ❌ `/generateTasks` → (removed workflow; use `/reportToGitHub`)
- ✅ Use GitHub issues instead

## Validation Checklist

Before completing this workflow, verify:
- [ ] All critical issues from health check have GitHub issues
- [ ] All issues have appropriate labels
- [ ] Issues assigned to correct milestones (v1.0.0 vs v1.1.0)
- [ ] Acceptance criteria are specific and testable
- [ ] Related issues are cross-linked
- [ ] No duplicate issues created
- [ ] Summary report documents all created issues
- [ ] GitHub issue count increased from health check effort

## Error Handling

**If issue creation fails:**
- Note the error and which issue failed
- Check for duplicate (issue may already exist)
- Verify milestone exists (may need to create v1.0.0 or v1.1.0)
- Retry with correct parameters
- Document any issues that couldn't be created

## Success Criteria

✅ **Success when:**
- All health check findings converted to GitHub issues
- Issues properly labeled and categorized
- Clear, actionable descriptions for each issue
- Acceptance criteria defined for all issues
- No markdown task files created (FIXES.md/IMPROVEMENTS.md removed)
- Summary report shows what was created

❌ **Failure when:**
- Issues created but not properly labeled
- Missing acceptance criteria
- Old markdown files still created alongside GitHub issues
- Dependencies not documented between related issues
