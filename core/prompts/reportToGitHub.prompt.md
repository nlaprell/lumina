---
description: Convert health check findings to GitHub issues
---

You are an **Issue Coordinator** responsible for converting health check findings into structured GitHub issues for the Lumina bootstrap project.

## Purpose

This workflow automates issue creation from comprehensive health checks, storing all project work in GitHub instead of markdown files. This is the preferred workflow for template maintenance.

## When to Use This Prompt

**Use `/reportToGitHub` when:**
- You've completed a `/healthCheck` and have a `core/HEALTH_CHECK_REPORT.md`
- You want to convert findings directly to GitHub issues
- You want to consolidate template work in a single system (GitHub)
- You're preparing issues for a development sprint

**Prerequisites:**
- GitHub repository configured (nlaprell/lumina)
- `core/HEALTH_CHECK_REPORT.md` exists with findings
- You have write access to create issues

## Workflow

### 1. Read Health Check Report

Open `core/HEALTH_CHECK_REPORT.md` and extract:

**From each issue section, collect:**
- Issue title and description
- Severity/priority level (Critical, High, Medium, Low)
- Affected component (file/script)
- Acceptance criteria
- Related issues or dependencies

### 2. Ensure "AI Recommended" Label Exists

**FIRST**: Check if the `AI Recommended` label exists in the repository:

```bash
gh label list --search "AI Recommended"
```

**If label doesn't exist, create it:**

```bash
gh label create "AI Recommended" --description "Issue identified by AI health check analysis" --color "7057ff"
```

**Label Purpose**: 
- Identifies issues discovered through automated health checks
- Distinguishes AI-suggested improvements from user-reported issues
- Helps track value provided by automated quality analysis
- Purple color (7057ff) makes them easily recognizable

**Documentation**: This label is now documented in:
- `.github/copilot-instructions.md` (Labels and Milestones section)
- `CONTRIBUTING.md` (Category Labels section)

### 3. Categorize by GitHub Labels

Map severity to GitHub labels:

**Critical Issues:**
- Labels: `bug`, `critical`, `AI Recommended`
- Milestone: v1.0.0 (MVP)
- Priority: Process immediately

**High Priority Issues:**
- Labels: `bug` or `enhancement` (depending on type), `AI Recommended`
- Milestone: v1.0.0 (MVP)
- Priority: Address within 1-2 weeks

**Medium Priority Issues:**
- Labels: `enhancement`, `quality`, `AI Recommended`
- Milestone: v1.1.0 (Post-MVP)
- Priority: Plan for next phase

**Low Priority Issues:**
- Labels: `enhancement`, `AI Recommended`
- Milestone: v1.1.0 (Post-MVP)
- Priority: Backlog

**Recommended Enhancements:**
- Labels: `enhancement`, `AI Recommended`
- Milestone: v1.2.0 (Future) or none
- Priority: Optional improvements

### 4. Check for Duplicates

**CRITICAL**: Before creating any issues, check if they already exist in GitHub:

For each finding in the health check report:
1. Search existing open issues for similar title or problem
2. If exact or very similar issue already exists:
   - Skip creation (don't create duplicate)
   - Comment on existing issue with new findings if different from what's documented
   - Reference the health check report date in comment
3. Only create if truly new issue

**Use GitHub search:**
```bash
# Search for existing issues related to finding
mcp_github_list_issues(owner=nlaprell, repo=lumina, state=open)
# Check titles match before creating
```

**Example - Skip if exists:**
- Finding: "Add requirements.txt for Python dependencies"
- Search existing issues: "requirements"
- Found: Issue #17 "Add requirements.txt for Python dependencies"
- Action: Skip (don't create duplicate)

### 5. Add Category Labels

Based on component/type, add additional labels:

| Component | Label |
|-----------|-------|
| Bash scripts (init.sh, etc.) | `scripts` |
| Python scripts (email converter, etc.) | `python` |
| Documentation (README, prompts, etc.) | `documentation` |
| Testing/validation | `testing` |
| Error handling/robustness | `quality` |
| MCP configuration | `mcp` |

### 6. Create GitHub Issues

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
2. **Check for duplicates first** - Search existing GitHub issues for similar problems
3. For each new issue (not a duplicate), use GitHub MCP tool to create issue:
   ```
   mcp_github_create_issue(
     owner: "nlaprell",
     repo: "lumina",
     title: "[Issue title]",
     body: "[Full issue description]",
     labels: ["bug", "critical", "AI Recommended", ...],
     milestone: [1 for v1.0.0, 2 for v1.1.0]
   )
   ```

4. Document created issue number for cross-reference

### 7. Clean Up Report Files

**After successfully creating all issues**, delete the report files that were processed:

```bash
# Remove health check report after conversion to issues
rm -f core/HEALTH_CHECK_REPORT.md

# Remove any other temporary report files
rm -f core/SANITY_CHECK_REPORT.md  # (if created)
```

**Rationale**: 
- Reports were temporary working documents to generate issues
- GitHub issues are now the authoritative record
- Avoid duplication and maintenance burden of markdown task files
- Keep repository clean

### 8. Group Related Issues

If issues are related (e.g., multiple parts of same feature):
- Create first issue
- In subsequent related issues, mention the first issue number
- Example: "Related to #1 (Fix MCP Configuration Format)"

### 9. Map to Existing Issues (If Any)

Compare with existing open issues on GitHub:
- If health check finds same issue already reported, skip creation
- Comment on existing issue with updated information instead
- Link related issues together

### 10. Handle Dependencies

If issues have dependencies (one must be fixed before another):
- Create blocking issue first
- In dependent issue, mention: "Blocked by #X"
- Use GitHub's issue linking syntax

### 11. Provide Summary Report

After creating all issues, provide summary:

```markdown
# GitHub Issues Created from Health Check

**Report Date**: [Current date]
**Source**: core/HEALTH_CHECK_REPORT.md

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
4. ✅ Health check report automatically deleted after processing (GitHub is authoritative)
```

## Important Notes

- **GitHub is source of truth**: All template work tracked in GitHub issues, not markdown files
- **Prefer GitHub for all tracking**: Markdown files create duplication and maintenance burden
- **Keep health check reports**: Archive reports as reference but don't create task files
- **One issue per problem**: Don't combine unrelated issues
- **Specific labels**: Use appropriate labels for filtering and project board views
- **Clear acceptance criteria**: Every issue must have testable, specific criteria

## Workflow Integration

**Preferred workflow:**
1. Run `/healthCheck` to analyze template
2. Review `core/HEALTH_CHECK_REPORT.md`
3. Run `/reportToGitHub` to create GitHub issues
4. Work from GitHub issues (assign, update, close)


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
- Summary report shows what was created

❌ **Failure when:**
- Issues created but not properly labeled
- Missing acceptance criteria
- Old markdown files still created alongside GitHub issues
- Dependencies not documented between related issues
