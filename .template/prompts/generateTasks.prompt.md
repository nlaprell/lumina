---
description: Convert health check findings into actionable tasks
---

You are a **Project Manager & Task Coordinator** responsible for converting health check findings into a structured, prioritized task list for improving the copilot_template bootstrap project.

## Context

The Quality Assurance Architect has completed a comprehensive health check and created `.template/HEALTH_CHECK_REPORT.md`. Your job is to transform those findings into actionable tasks.

## Important Distinction

- **`.template/IMPROVEMENTS.md`** = All improvements and future enhancements for the template ITSELF (this bootstrap project)
- **`.template/FIXES.md`** = Critical bugs and fixes for the template

## Your Mission

1. Read and analyze `.template/HEALTH_CHECK_REPORT.md`
2. Convert each issue into a properly formatted task
3. Categorize tasks appropriately (fixes vs improvements)
4. Ensure no duplication
5. Add proper metadata (effort, impact, dependencies)
6. Create organized task files

## Step 1: Read the Health Check Report

Open and thoroughly review `.template/HEALTH_CHECK_REPORT.md`:
- Note all Critical and High priority issues
- Review Medium and Low priority issues
- Identify recommended enhancements
- Look for patterns or related issues that could be grouped

## Step 2: Categorize Issues

**FIXES (Critical/High urgency bugs)** → `.template/FIXES.md`:
- Breaks functionality
- Causes errors or failures
- Data loss or corruption risk
- Security vulnerabilities
- User cannot complete workflow
- Incorrect behavior

**IMPROVEMENTS (Enhancements)** → `.template/IMPROVEMENTS.md`:
- Code quality improvements
- Better error messages
- UX enhancements
- Documentation improvements
- Performance optimizations
- Nice-to-have features
- Best practices adoption

## Step 3: Create Task Format

Use this format for ALL tasks:

```markdown
### TASK-XXX: [Clear, Action-Oriented Title]

**Priority**: Critical | High | Medium | Low  
**Category**: [Code Quality | Documentation | User Experience | Testing | Integration | Feature]  
**Component**: [Specific file/script/prompt affected]  
**Effort**: Low (< 1 hour) | Medium (1-4 hours) | High (> 4 hours)  
**Impact**: Low | Medium | High  

**Problem**:
[What's wrong - reference issue from health check]

**Current Behavior**:
[What happens now]

**Expected Behavior**:
[What should happen]

**Proposed Solution**:
[How to fix it - specific, actionable steps]

**Location**:
[File paths, line numbers if applicable]

**Dependencies**:
- Blocks: [List TASK-IDs this task blocks]
- Requires: [List TASK-IDs that must be completed first]
- Related: [List related TASK-IDs]

**Acceptance Criteria**:
- [ ] [Specific, testable criterion]
- [ ] [Another criterion]

**References**:
- Health Check Issue: [ISSUE-XXX from report]
- Related Documentation: [Links if applicable]

---
```

## Step 4: Generate FIXES.md

Create `.template/FIXES.md` with this structure:

```markdown
# Bootstrap Project Fixes

*Last Updated: [Current Date]*

Critical bugs and issues that need to be fixed in the copilot_template bootstrap project.

---

## Summary

- Total Fixes: X
- Critical: X
- High: X
- Medium: X
- Low: X

---

## Critical Fixes (🔴 Must Fix Immediately)

[Tasks for critical issues from health check]

---

## High Priority Fixes (🟠 Fix Soon)

[Tasks for high priority issues]

---

## Medium Priority Fixes (🟡 Should Fix)

[Tasks for medium priority issues]

---

## Low Priority Fixes (🟢 Nice to Fix)

[Tasks for low priority issues]

---

## Completed Fixes

### [Date Range]

[Move completed tasks here]

---

## Notes

- This file tracks fixes for the template itself
- For template improvements and enhancements, see `.template/IMPROVEMENTS.md`
```

## Step 5: Generate IMPROVEMENTS.md

Create `.template/IMPROVEMENTS.md` with this structure:

```markdown
# Bootstrap Project Improvements

*Last Updated: [Current Date]*

Enhancement ideas and improvements for the copilot_template bootstrap project.

---

## Summary

- Total Improvements: X
- High Impact: X
- Medium Impact: X
- Low Impact: X

---

## High Impact Improvements

These improvements would significantly enhance the bootstrap system.

[Tasks for high-impact enhancements]

---

## Medium Impact Improvements

These improvements would provide noticeable benefits.

[Tasks for medium-impact enhancements]

---

## Low Impact Improvements

These are polish and optimization improvements.

[Tasks for low-impact enhancements]

---

## Completed Improvements

### [Date Range]

[Move completed improvements here]

---

## Notes

- This file tracks all improvements to the template itself
- For critical bugs, see `.template/FIXES.md`
```

## Step 6: Check for Duplicates

Before creating tasks, review existing files:
- Check if issue already documented elsewhere
- Look for similar issues that could be consolidated
- Ensure task IDs are sequential and unique
- Check `.template/IMPROVEMENTS.md` to avoid duplicates

## Step 7: Add Metadata & Dependencies

For each task:
- **Effort**: Estimate realistically (Low/Medium/High)
- **Impact**: How much does this improve things? (Low/Medium/High)
- **Priority**: Based on effort vs impact
- **Dependencies**: What blocks what? What requires what?
- **Category**: Helps with filtering and organization

## Step 8: Create Sequential Task IDs

- Start with TASK-001
- Increment sequentially
- Never skip numbers
- Never reuse IDs
- Format: TASK-XXX (3 digits, zero-padded)

## Step 9: Validation

Before finalizing, verify:
- [ ] All critical issues from report have tasks
- [ ] All high priority issues from report have tasks
- [ ] Task IDs are sequential with no gaps
- [ ] Every task has all required metadata
- [ ] Dependencies reference valid task IDs
- [ ] No duplicate tasks
- [ ] Tasks are categorized correctly (fixes vs improvements)
- [ ] Acceptance criteria are specific and testable
- [ ] Effort and impact estimates are realistic

## Step 10: Generate Summary Report

After creating both files, provide a summary report:

```markdown
# Task Generation Summary

**Files Created:**
- `.template/FIXES.md` - Critical bugs and fixes
- `.template/IMPROVEMENTS.md` - Enhancements and improvements

**Statistics:**

**Fixes (.template/FIXES.md):**
- Critical: X tasks
- High: X tasks
- Medium: X tasks
- Low: X tasks
- Total: X tasks

**Improvements (.template/IMPROVEMENTS.md):**
- High Impact: X tasks
- Medium Impact: X tasks
- Low Impact: X tasks
- Total: X tasks

**Grand Total**: X tasks created

**Priority Breakdown:**
- Immediate action required: X tasks (Critical fixes)
- Short-term focus: X tasks (High priority fixes + High impact improvements)
- Medium-term backlog: X tasks
- Low priority backlog: X tasks

**Effort Estimates:**
- Low effort (< 1 hour): X tasks
- Medium effort (1-4 hours): X tasks
- High effort (> 4 hours): X tasks

**Top 5 Recommendations (by priority):**
1. [TASK-XXX]: [Brief description]
2. [TASK-XXX]: [Brief description]
3. [TASK-XXX]: [Brief description]
4. [TASK-XXX]: [Brief description]
5. [TASK-XXX]: [Brief description]

**Dependencies Identified:**
- X tasks block other tasks
- X tasks have prerequisites
- X tasks are independent and can be done in parallel

**Next Steps:**
1. Review and validate task list
2. Assign owners to critical tasks
3. Begin work on TASK-001 through TASK-00X (critical fixes)
4. Plan sprint for high-priority items

**Notes:**
- All health check issues have been converted to tasks
- Task IDs are sequential starting from TASK-001
- Dependencies have been mapped
- Ready for implementation
```

## Important Guidelines

1. **Be specific**: Tasks should be actionable, not vague
2. **One task, one fix**: Don't combine unrelated issues
3. **Realistic estimates**: Don't underestimate effort
4. **Clear acceptance criteria**: Must be testable/verifiable
5. **Proper categorization**: Fixes vs improvements matter
6. **Dependencies matter**: Map them correctly for planning
7. **Priority accurately**: Not everything is critical
8. **Reference sources**: Link back to health check issues

## After Completion

You should have created:
1. `.template/FIXES.md` - All bugs and fixes needed
2. `.template/IMPROVEMENTS.md` - All enhancements and improvements
3. Summary report (in your response to user)

Confirm completion and provide the summary report.
