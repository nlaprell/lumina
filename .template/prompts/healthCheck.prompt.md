---
description: Comprehensive health check of the Lumina bootstrap project
---

You are a **Quality Assurance Architect** conducting a comprehensive health check of the Lumina bootstrap project.

## Context

This is NOT a project created FROM the template - this IS the template itself. Your job is to validate that this bootstrap system works correctly for MarkLogic consultants who will use it to initialize their projects with email-based documentation.

This is a **comprehensive health check** that analyzes all aspects of the template. For a quick pre-commit validation focusing only on critical issues, use `/sanityCheck` instead.

## Your Mission

Perform a deep, comprehensive analysis of the entire bootstrap system to identify:
- Critical bugs that break functionality
- Missing features or incomplete implementations
- Inconsistencies between documentation and code
- Logical errors in workflows
- User experience issues
- Code quality problems
- Opportunities for improvement

## Scope of Analysis

### 1. Project Structure & Organization

**Examine:**
- Directory structure and file organization
- Naming conventions and consistency
- File placement (are things in the right locations?)
- Missing expected files or unexpected files

**Check:**
- Does the structure match what README.md describes?
- Are there orphaned files or directories?
- Is the separation between bootstrap (this project) and project workflows (used BY projects) clear?

### 2. Code Quality & Correctness

**Review ALL scripts:**

**`init.sh`:**
- Bash syntax and best practices
- Error handling (set -e, trap, validation)
- Edge cases (empty input, special characters, path spaces)
- Platform compatibility (macOS vs Linux)
- User input validation
- File creation and permissions
- MCP server selection logic
- Configuration file generation

**`.template/aiScripts/emailToMd/eml_to_md_converter.py`:**
- Python best practices and PEP 8
- Error handling for malformed emails
- File I/O safety (permissions, encoding)
- Directory creation and file moves
- Email parsing edge cases
- Character encoding issues

**`.template/aiScripts/detectTaskDependencies/detectTaskDependencies.py`:**
- Task parsing accuracy
- Dependency detection algorithms (3-tier confidence)
- Circular dependency detection correctness
- Graph generation logic
- Error handling for malformed TASKS.md
- Report generation accuracy

**`.template/scripts/clean-reset.sh`:**
- Safe file operations
- Proper backup or confirmation
- Template copying logic
- Error handling

**Check for:**
- Hardcoded paths that should be dynamic
- Missing error messages or unclear errors
- Unsafe operations (rm, mv without confirmation)
- Missing input validation
- Race conditions or concurrency issues
- Missing documentation or comments in complex sections

### 3. Prompt Workflow Integrity

**Analyze ALL prompts in `prompts/`:**

**For each prompt (`ProjectInit`, `discoverEmail`, `updateSummary`, `quickStartProject`):**
- Are instructions clear and unambiguous?
- Do they match actual script behavior?
- Are all file paths correct and up-to-date?
- Are placeholders and examples consistent?
- Do they reference files/scripts that exist?
- Are validation checklists complete?
- Is error handling guidance provided?

**Cross-prompt consistency:**
- Do prompts use the same terminology?
- Are task ID formats consistent (TASK-001 everywhere)?
- Are placeholder examples the same (`[DATE]`, `[CUSTOMER]`, `[PROJECT]`)?
- Do they reference the same paths in the same way?
- Are validation criteria aligned across prompts?

**Integration with copilot-instructions.md:**
- Do prompts align with universal instructions?
- Are there contradictions between prompts and instructions?
- Is the workflow described consistently?

### 4. Template & Documentation Validation

**Review `aiDocs/templates/`:**
- Are all 4 templates present and complete?
- Do placeholders match what prompts expect?
- Are section headings consistent?
- Is formatting correct (Markdown syntax)?
- Do templates include all required sections?

**Validate `README.md`:**
- Does Quick Start workflow actually work as described?
- Are all commands correct?
- Are file paths accurate?
- Is security warning clear and complete?
- Are prerequisites listed?
- Is workflow diagram accurate?

**Check `.github/copilot-instructions.md`:**
- Are all sections complete?
- Are code examples correct?
- Are file paths and references accurate?
- Is MarkLogic ecosystem guidance clear?
- Are validation checklists complete?
- Do examples match current structure?

**Review MCP Server Configurations (`mcpServers/*.json`):**
- Is JSON syntax correct?
- Are placeholder instructions clear?
- Are server configurations complete?
- Do they follow MCP spec correctly?

### 5. User Experience & Journey Analysis

**Complete User Journey Simulation:**

Walk through the experience of a MarkLogic consultant using this template:

1. **Clone the repository**
   - What does the user see first?
   - Is README.md immediately helpful?
   - Are next steps obvious?

2. **Run `./.template/scripts/init.sh`**
   - Are prompts clear?
   - Does error handling guide user correctly?
   - Is MCP server selection intuitive?
   - Does the script complete successfully?

3. **Add `.eml` files to `email/raw/`**
   - Is this step clear in documentation?
   - What if directory doesn't exist?

4. **Run `/quickStartProject`**
   - Does it execute without errors?
   - Are intermediate steps visible?
   - Does it create expected files?
   - Is output helpful?

5. **Review generated `SUMMARY.md`**
   - Is it properly formatted?
   - Does it contain expected sections?
   - Is tagline present?

**Identify pain points:**
- Where could user get stuck?
- What error messages are unhelpful?
- What assumptions does system make?
- What's not documented but should be?

### 6. Integration & Dependencies

**Cross-reference validation:**
- Do all file path references work?
- Are script invocations correct?
- Do prompts call the right scripts?
- Are workflow sequences logical?

**Dependency analysis:**
- What depends on what?
- Are there circular dependencies?
- What breaks if one component fails?
- Are there single points of failure?

### 7. Completeness Check

**Missing features or implementations:**
- Are there TODO comments in code?
- Are there incomplete sections in docs?
- Are there features mentioned but not implemented?
- Are there validation checks that should exist but don't?

## Output Format

Create a comprehensive report saved to `.template/HEALTH_CHECK_REPORT.md` with this structure:

```markdown
# Bootstrap Project Health Check Report

*Generated: [Current Date]*

## Executive Summary

**Overall Status**: [Excellent / Good / Needs Work / Critical Issues]

**Statistics:**
- Total Issues Found: X
- 🔴 Critical: X (breaks functionality, data loss, security)
- 🟠 High: X (major problems, user confusion, missing features)
- 🟡 Medium: X (improvements, minor bugs, clarity issues)
- 🟢 Low: X (polish, optimization)
- 💡 Recommended: X (enhancements, best practices)

**Key Findings:**
- [3-5 most important discoveries]

---

## Issues by Severity

### 🔴 Critical Issues

**[ISSUE-001]: [Clear, concise title]**
- **Category**: [Code Quality | Documentation | User Experience | Integration]
- **Component**: [Specific file/script/prompt]
- **Description**: [What's wrong and why it's critical]
- **Impact**: [How this breaks functionality]
- **Location**: [File path and line number if applicable]
- **Recommendation**: [How to fix it]

[Repeat for each critical issue]

### 🟠 High Priority Issues

[Same format as Critical]

### 🟡 Medium Priority Issues

[Same format, can be more concise]

### 🟢 Low Priority Issues

[Brief format]

### 💡 Recommended Enhancements

[Brief format with effort/impact estimates]

---

## Detailed Analysis by Component

### 1. Project Structure

**Findings:**
[Detailed analysis of directory structure]

**Issues:**
- [List specific problems]

**Strengths:**
- [What's working well]

### 2. Code Quality

#### init.sh
**Overall Quality**: [Score/Assessment]
**Issues Found**: X
**Critical Problems**: [List]
**Recommendations**: [List]

#### Email Converter (eml_to_md_converter.py)
[Same structure]

#### Task Dependency Detector (detectTaskDependencies.py)
[Same structure]

#### Clean Reset Script (clean-reset.sh)
[Same structure]

### 3. Prompt Workflows

#### Overall Consistency
[Analysis of cross-prompt consistency]

#### ProjectInit.prompt.md
**Quality**: [Assessment]
**Issues**: [List]
**Recommendations**: [List]

#### discoverEmail.prompt.md
[Same structure]

#### updateSummary.prompt.md
[Same structure]

#### quickStartProject.prompt.md
[Same structure]

### 4. Templates & Documentation

#### Templates (aiDocs/templates/)
[Analysis]

#### README.md
[Analysis]

#### .github/copilot-instructions.md
[Analysis]

#### MCP Server Configurations
[Analysis]

### 5. User Experience Analysis

**User Journey Validation:**
[Walk through complete workflow]

**Pain Points Identified:**
- [List specific UX issues]

**Confusion Points:**
- [Where users might get stuck]

**Suggestions:**
- [How to improve UX]

### 6. Integration & Cross-References

**Broken References**: [List]
**Outdated Paths**: [List]
**Missing Dependencies**: [List]
**Circular Dependencies**: [List]

### 7. Completeness Assessment

**Incomplete Features**: [List]
**TODOs in Code**: [List]
**Documentation Gaps**: [List]
**Missing Validation**: [List]

---

## GitHub Issue Mapping

**Items Already Implemented:**
- [List issues closed during health check]

**Items Still Relevant:**
- [List open issues still applicable]

**New Opportunities Discovered:**
- [Issues to create in GitHub]

---

## Recommendations Summary

### Immediate Action Required (Critical)
1. [Most critical fix needed]
2. [Second most critical]
3. [etc.]

### Short-term Improvements (High Priority)
1. [Priority improvements]

### Long-term Enhancements (Medium/Low)
1. [Nice-to-have improvements]

---

## Conclusion

[Overall assessment of bootstrap project health]
[Key strengths to preserve]
[Primary areas needing attention]
[Confidence level in current state]

```

## Important Guidelines

1. **Be thorough but realistic**: Don't create issues for hypothetical edge cases that will never happen
2. **Prioritize correctly**: Critical = breaks functionality, not "could be better"
3. **Provide actionable recommendations**: Specific fixes, not vague suggestions
4. **Check actual behavior**: Don't assume - trace through code execution paths
5. **Consider the audience**: These are MarkLogic consultants, not novice users
6. **Note what works well**: Don't just focus on problems
7. **Think holistically**: How do components work together?
8. **Be specific with locations**: File paths and line numbers where applicable

## After Completion

Save your complete report to `.template/HEALTH_CHECK_REPORT.md` and provide a brief summary:

**Summary:**
- Total issues found: X
- Critical issues requiring immediate attention: X
- High priority improvements: X
- Overall health assessment: [1-2 sentences]
- Top 3 recommendations: [Brief list]

---

## ⭐ Important: Next Step - Use GitHub for Issue Tracking

**DO NOT** create `.template/FIXES.md` or `.template/IMPROVEMENTS.md` markdown files (they have been removed; use GitHub issues only).

**Instead, use GitHub for all issue tracking:**

After health check completes, run `/reportToGitHub` to convert findings to GitHub issues:

```
/reportToGitHub
```

This workflow:
1. Reads `.template/HEALTH_CHECK_REPORT.md`
2. Creates GitHub issues with proper labels and milestones
3. Stores all template work in GitHub (single source of truth)
4. Avoids duplication and maintenance burden of markdown task files

**Preferred Workflow:**
1. Run `/healthCheck` → generates HEALTH_CHECK_REPORT.md
2. Run `/reportToGitHub` → creates GitHub issues
3. Work from GitHub issues (legacy FIXES/IMPROVEMENTS files removed)
````
