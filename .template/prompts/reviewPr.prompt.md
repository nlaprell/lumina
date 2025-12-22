---
description: Review a pull request for quality, correctness, and readiness to merge
---

**PURPOSE**: Conduct thorough code review of GitHub PR, identify issues, leave feedback, and manage merge workflow.

## When to Use This Prompt

**Use `/reviewPr` when:**
- A PR has been created and needs review before merging
- You want to conduct automated code quality review
- You need to verify acceptance criteria are met
- You're checking for potential bugs or issues
- You want to determine merge readiness

**Typical Workflow:**
1. Developer completes issue and creates PR (via `/completeIssue`)
2. Run `/reviewPr` to review the PR
3. Agent identifies issues and leaves comments
4. If issues found: agent fixes them and re-reviews
5. If ready: agent merges to main and closes issue

---

## Workflow Steps

### 1. Get PR Details from GitHub

Retrieve the open PR that needs review:

**Determine which PR to review:**
- If user specifies PR number: Use that PR
- If user doesn't specify: Find the most recent open PR
- Get full PR details including:
  - PR title and number
  - Description and acceptance criteria
  - Branch name and target branch (should be `main`)
  - Author/creator
  - Changed files
  - Related issue number (from `Closes #X` in description)

**Use GitHub MCP tools:**
```
mcp_github_get_pull_request(owner: "nlaprell", repo: "lumina", pull_number: X)
mcp_github_get_pull_request_files(owner: "nlaprell", repo: "lumina", pull_number: X)
```

### 2. Review the Proposed Changes

For each file changed in the PR:

**Read the file from the PR branch:**
- Get the actual code changes by reading files from the feature branch
- Understand what was changed and why
- Compare against the acceptance criteria in the PR description

**Check for:**
- **Syntax errors**: Run validation (bash -n, python3 -m py_compile)
- **Logic errors**: Trace through the code to find potential bugs
- **Best practices**: Check naming, structure, comments, error handling
- **Incomplete work**: Are all acceptance criteria actually addressed?
- **Side effects**: Could these changes break other functionality?
- **Documentation**: Are changes documented properly?
- **Testing**: Are changes testable? Would tests cover them?
- **Security**: Any potential security issues?
- **Performance**: Any performance concerns?

**Validation checklist:**
- [ ] All syntax checks pass
- [ ] Code follows project conventions
- [ ] All acceptance criteria are met
- [ ] No obvious bugs detected
- [ ] Error handling is appropriate
- [ ] Changes don't break existing functionality
- [ ] Documentation updated if needed
- [ ] No hardcoded credentials or secrets
- [ ] Code is readable and maintainable

### 3. Run Acceptance Criteria Verification

Review each acceptance criterion from the PR description:

**For each criterion:**
- [ ] Is it clearly addressed in the code?
- [ ] Is the fix complete or partial?
- [ ] Can it be verified/tested?
- [ ] Does it solve the original problem?

**Determine readiness:**
- **All met ✅**: Ready for merge (proceed to Step 4)
- **Some met ⚠️**: Not ready - needs work (proceed to Step 5)
- **None met ❌**: Incomplete - needs major work (proceed to Step 5)

### 4. Leave Review Comment on PR

Post a detailed review comment on the PR with findings:

**Comment format:**
```markdown
## Code Review - [Date]

### ✅ Strengths
- [Positive observation 1]
- [Positive observation 2]

### 🔍 Review Findings

#### Syntax & Validation
- [Finding 1 - severity]
- [Finding 2 - severity]

#### Logic & Correctness
- [Finding 1 - severity]
- [Finding 2 - severity]

#### Best Practices
- [Finding 1 - severity]

### 📋 Acceptance Criteria Status
- [x] Criterion 1 - **Met**
- [x] Criterion 2 - **Met**
- [ ] Criterion 3 - **Not Met** - [specific reason]

### Summary

**Overall Status**: [Ready to Merge ✅ | Needs Work ⚠️ | Major Revisions Needed ❌]

**Severity of Issues**:
- 🔴 Critical: [count] issues blocking merge
- 🟠 High: [count] issues needing attention
- 🟡 Medium: [count] improvements suggested
- 🟢 Low: [count] minor items

**Recommendation**: [Merge as-is | Fix issues before merge | Needs major rework]

---

**Issues Blocking Merge** (if any):
1. [Issue 1 - how to fix]
2. [Issue 2 - how to fix]

**Optional Improvements**:
1. [Improvement 1]
2. [Improvement 2]
```

**Use GitHub MCP tool:**
```
mcp_github_create_pull_request_review(
  owner: "nlaprell",
  repo: "lumina",
  pull_number: X,
  body: "[Review comment text]",
  event: "COMMENT"  # or "REQUEST_CHANGES" if issues block merge
)
```

### 5. Determine Merge Readiness

**Decision matrix:**

| Condition | Decision |
|-----------|----------|
| All syntax passes + all acceptance criteria met + no blocking issues | ✅ Ready to merge |
| Some acceptance criteria not met + fixable issues found | ⚠️ Not ready - needs fixes |
| Critical bugs or major issues found | ❌ Reject - major rework needed |

### 6. Handle Issues Found (If Not Ready)

**If issues found, fix them:**

1. **Check out the PR branch:**
   ```bash
   git fetch origin pull/X/head:pr-branch-name
   git checkout pr-branch-name
   ```

2. **Implement fixes:**
   - Fix each issue identified in the review
   - Follow same process as original implementation
   - Run syntax validation after each change

3. **Commit fixes:**
   - Use conventional commit format: `fix(scope): description`
   - Reference the issue: `Fixes #X`
   - Example: `fix(mcp): add missing error handling for invalid JSON`

4. **Push fixes:**
   ```bash
   git push origin pr-branch-name
   ```

5. **Start review again:**
   - Return to Step 2 to review changes again
   - Post updated review comment
   - Repeat until ready to merge

### 7. Merge to Main

Once PR is approved and ready:

**Merge the PR:**
```
mcp_github_merge_pull_request(
  owner: "nlaprell",
  repo: "lumina",
  pull_number: X,
  merge_method: "squash",  # or "merge" or "rebase"
  commit_title: "[Conventional commit title]",
  commit_message: "[Full commit message with issue reference]"
)
```

**Recommended merge settings:**
- **Method**: `squash` - keeps main history clean
- **Commit title**: Match conventional commits format
- **Commit message**: Include full context and issue reference

### 8. Update Issue Status

After merge:

**Close the related GitHub issue:**
```
mcp_github_update_issue(
  owner: "nlaprell",
  repo: "lumina",
  issue_number: X,
  state: "closed"
)
```

**Add comment to issue:**
- Note that PR #Y has been merged
- Reference the commit SHA
- Confirm the fix is now in main branch

### 9. Cleanup

After successful merge:

**Switch back to main:**
```bash
git checkout main
git pull origin main
```

**Delete the feature branch locally (optional):**
```bash
git branch -d branch-name
```

### 10. Provide Merge Summary

After complete workflow:

```markdown
# PR Review & Merge Summary

**PR**: [#19 - Issue Title]
**Reviewed**: [Date]
**Status**: ✅ Merged to main

## Review Results

**Syntax Validation**: ✅ All files passed
**Acceptance Criteria**: ✅ All met
**Code Quality**: ✅ Good
**Issues Found**: [count]
- 🔴 Critical: [fixed count]
- 🟠 High: [fixed count]
- 🟡 Medium: [fixed count]

## Changes Made During Review

[If issues were fixed during review, summarize]
- Fix 1
- Fix 2

## Merge Details

- **Merged PR**: #19
- **Target Branch**: main
- **Merge Method**: squash
- **Commit**: [commit SHA first 7 chars]
- **Closed Issue**: #1

## Next Steps

[Suggest next action - e.g., "Ready to review next PR in v1.0.0 milestone"]
```

---

## Important Guidelines

### Code Review Standards

- **Be thorough**: Check all aspects (syntax, logic, best practices)
- **Be fair**: Acknowledge good work, not just problems
- **Be specific**: Point to exact locations and specific issues
- **Be constructive**: Explain how to fix each issue
- **Be respectful**: Tone should be professional and helpful

### Merge Criteria

Only merge when:
- ✅ All syntax checks pass
- ✅ All acceptance criteria met
- ✅ No critical/blocking issues remain
- ✅ Code follows project standards
- ✅ Changes are complete and tested

Don't merge if:
- ❌ Syntax errors present
- ❌ Acceptance criteria not met
- ❌ Critical bugs found
- ❌ Incomplete implementation
- ❌ Breaking changes not documented

### Common Issues to Check

**Bash Scripts:**
- Quoting of variables and file paths
- Error handling (set -e, error checks)
- Proper escaping of special characters
- Cross-platform compatibility (macOS vs Linux)
- File permissions and ownership

**Python Scripts:**
- Import statements and dependencies
- Exception handling
- File I/O safety
- Type hints and documentation
- PEP 8 compliance

**Documentation:**
- Accurate command examples
- Correct file paths
- Updated references
- Spelling and grammar
- Clear explanations

**Configuration:**
- Valid JSON/YAML/etc syntax
- No hardcoded secrets
- Proper structure and nesting
- Environment variable references

---

## Error Handling

**If review comment fails to post:**
- Note the error
- Determine if it's a GitHub API issue or content issue
- Retry with simplified comment if needed
- Document the issue

**If merge fails:**
- Check for merge conflicts
- Verify branch hasn't been deleted
- Ensure you have write permissions
- Check PR is in "Ready to merge" state
- Retry or report error

**If issue close fails:**
- Verify issue number is correct
- Ensure issue is open (not already closed)
- Try updating issue with comment instead

---

## Success Criteria

✅ **Success when:**
- PR review is thorough and specific
- All issues are identified and documented
- Review comment is posted to PR
- Merge readiness is clearly determined
- If issues found: all are fixed and re-reviewed
- If ready: PR is merged to main with proper commit message
- Related issue is closed
- Summary clearly documents what was done

❌ **Failure when:**
- Review misses obvious bugs
- Critical issues not identified
- Issues fixed but not re-reviewed
- PR merged with known problems
- Merge fails and not retried/escalated
- Related issue not closed

---

## Workflow Integration

**Complete Issue Resolution Workflow:**

1. **Developer**: Uses `/completeIssue` to implement issue
   - Creates branch
   - Makes changes
   - Commits with proper format
   - Creates PR with acceptance criteria

2. **Reviewer** (AI Agent): Uses `/reviewPr` to review and merge
   - Reviews changes thoroughly
   - Posts detailed feedback
   - Fixes any issues found
   - Re-reviews until ready
   - Merges to main
   - Closes related issue

3. **Verification**: Changes are now in main branch
   - Available to all users
   - Continuous integration runs
   - Issue is resolved and closed

---

## Quick Reference

### GitHub MCP Commands

**Get PR details:**
```
mcp_github_get_pull_request(owner, repo, pull_number)
mcp_github_get_pull_request_files(owner, repo, pull_number)
```

**Post review:**
```
mcp_github_create_pull_request_review(owner, repo, pull_number, body, event)
```

**Merge PR:**
```
mcp_github_merge_pull_request(owner, repo, pull_number, merge_method, commit_title, commit_message)
```

**Close issue:**
```
mcp_github_update_issue(owner, repo, issue_number, state: "closed")
```

### Validation Commands

**Bash syntax:**
```bash
bash -n script.sh
```

**Python syntax:**
```bash
python3 -m py_compile script.py
```

### Git Commands

**Fetch PR branch:**
```bash
git fetch origin pull/X/head:branch-name
git checkout branch-name
```

**Push changes:**
```bash
git push origin branch-name
```

**Switch to main:**
```bash
git checkout main
git pull origin main
```

---

## Example Workflow

```
User: "Review PR #19"

Agent:
1. Fetches PR #19 details (MCP tool)
2. Gets changed files (MCP tool)
3. Reviews each file:
   - .template/scripts/init.sh - syntax OK, logic checked
   - .template/scripts/clean-reset.sh - syntax OK, logic checked
4. Checks acceptance criteria - all 6 met ✅
5. Runs validation:
   - bash -n init.sh ✅
   - bash -n clean-reset.sh ✅
6. Posts review comment: "All checks passed, ready to merge"
7. Merges PR to main (MCP tool)
8. Closes issue #1 (MCP tool)
9. Reports: "PR #19 merged successfully, issue #1 closed"
```

---

## Notes for AI Agents

- Always be thorough - reviewing code is critical responsibility
- Acknowledge good work - reinforce best practices
- Provide specific, actionable feedback
- If unsure about issue: ask clarifying questions or mark as optional improvement
- Run all validation checks before approving
- Post comprehensive review comments even if no issues found (builds confidence)
- Keep PR description and commit message in sync during merge
- Verify merge actually succeeded before reporting complete
