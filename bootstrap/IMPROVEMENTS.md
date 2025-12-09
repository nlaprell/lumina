# Bootstrap Project Improvements

*Last Updated: December 9, 2025*

Enhancement ideas and improvements for the copilot_template bootstrap project.

---

## Summary

- Total Improvements: 6
- High Impact: 2
- Medium Impact: 3
- Low Impact: 1

---

## High Impact Improvements

These improvements would significantly enhance the bootstrap system.

### TASK-024: Add Terminal Color Support Detection

**Priority**: Low  
**Category**: Code Quality  
**Component**: init.sh  
**Effort**: Low (1 hour)  
**Impact**: Low  

**Problem**:
init.sh uses hard-coded ANSI color codes without checking if terminal supports colors. May show escape codes on terminals without color support.

**Current Behavior**:
Color codes defined as magic strings; always displayed regardless of terminal capability.

**Expected Behavior**:
Check terminal capabilities before using colors; fall back to no colors if unsupported.

**Proposed Solution**:
Add color capability detection at start of script:
```bash
# Check if terminal supports colors
if [ -t 1 ] && command -v tput &> /dev/null && [ $(tput colors) -ge 8 ]; then
    GREEN=$(tput setaf 2)
    BLUE=$(tput setaf 4)
    YELLOW=$(tput setaf 3)
    RED=$(tput setaf 1)
    NC=$(tput sgr0)
else
    GREEN=''
    BLUE=''
    YELLOW=''
    RED=''
    NC=''
fi
```

**Location**:
- File: `init.sh`
- Lines: 8-12

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] Terminal color support detected
- [ ] tput used for portable color codes
- [ ] Graceful fallback to no colors
- [ ] Test on terminal without color support
- [ ] Test on terminal with color support

**References**:
- Sanity Check Issue: ISSUE-024

---

### TASK-025: Add .editorconfig for Consistent Formatting

**Priority**: Low  
**Category**: Best Practice  
**Component**: Root directory  
**Effort**: Low (1 hour)  
**Impact**: Medium  

**Problem**:
Project lacks .editorconfig file to enforce consistent indentation and line endings across contributors. Potential formatting inconsistencies in contributed files.

**Current Behavior**:
No automated formatting enforcement.

**Expected Behavior**:
.editorconfig provides consistent formatting rules for all file types.

**Proposed Solution**:
Create .editorconfig in project root:
```ini
# EditorConfig for copilot_template
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
indent_style = space
indent_size = 2
trim_trailing_whitespace = false

[*.{py,sh}]
indent_style = space
indent_size = 4

[*.{json,yml,yaml}]
indent_style = space
indent_size = 2

[*.sh]
end_of_line = lf

[Makefile]
indent_style = tab
```

**Location**:
- New file: `.editorconfig` at project root

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] .editorconfig created
- [ ] Rules for all file types used in project
- [ ] Markdown, Python, Bash, JSON configured
- [ ] Line ending consistency enforced (LF)
- [ ] Trailing whitespace handling appropriate per file type
- [ ] Test with different editors (VS Code, vim, etc.)

**References**:
- Sanity Check Issue: ISSUE-025
- EditorConfig.org specification

---

## Medium Impact Improvements

These improvements would provide noticeable benefits.

### TASK-026: Add Pre-Commit Hook for Placeholder Detection

**Priority**: Medium  
**Category**: Quality Assurance  
**Component**: New file: .git/hooks/pre-commit  
**Effort**: Low (2 hours)  
**Impact**: Medium  

**Problem**:
No automated detection if aiDocs files still contain template placeholders like [DATE], [CUSTOMER], [PROJECT] before allowing commit. Users may accidentally commit placeholder text.

**Current Behavior**:
No pre-commit validation of placeholder removal.

**Expected Behavior**:
Git pre-commit hook detects placeholders and blocks commit with helpful message.

**Proposed Solution**:
Create pre-commit hook script:
```bash
#!/bin/bash
# Pre-commit hook to detect template placeholders

PLACEHOLDER_PATTERN='\[(DATE|CUSTOMER|PROJECT|NAME|EMAIL|TASK|PERSON)\]'

# Check aiDocs files
if git diff --cached --name-only | grep -q '^aiDocs/'; then
    if git diff --cached | grep -E "$PLACEHOLDER_PATTERN" > /dev/null; then
        echo "ERROR: Template placeholders detected in aiDocs/"
        echo "Please replace all [PLACEHOLDER] text before committing"
        git diff --cached | grep -E "$PLACEHOLDER_PATTERN"
        exit 1
    fi
fi

exit 0
```

Also create script to install hook: `scripts/install-hooks.sh`

**Location**:
- New file: `.git/hooks/pre-commit`
- New file: `scripts/install-hooks.sh`

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-020 (Quick Context validation could be added to this hook)

**Acceptance Criteria**:
- [ ] Pre-commit hook script created
- [ ] Detects common placeholder patterns
- [ ] Blocks commit if placeholders found
- [ ] Shows which placeholders were found
- [ ] Clear error message with resolution steps
- [ ] install-hooks.sh script for easy setup
- [ ] README updated with hook installation instructions

**References**:
- Sanity Check Issue: ISSUE-026

---

### TASK-027: Create Quick Reference Card

**Priority**: Medium  
**Category**: Documentation  
**Component**: New file: QUICKREF.md  
**Effort**: Low (1-2 hours)  
**Impact**: Medium  

**Problem**:
No one-page quick reference showing common commands, slash commands, and workflow steps. Users must read full README to find basic information.

**Current Behavior**:
Information scattered across README, prompts, and documentation.

**Expected Behavior**:
Single-page quick reference with essential commands and decision tree.

**Proposed Solution**:
Create QUICKREF.md with sections:
```markdown
# Copilot Template Quick Reference

## Essential Commands

### Setup (One Time)
- `./init.sh` - Configure project and MCP servers
- `./scripts/clean-reset.sh` - Reset to clean state

### Email Processing
- Place emails in: `email/raw/`
- Run: `/discoverEmail` in Copilot

### Workflows (Slash Commands)
- `/quickStartProject` - Complete init workflow
- `/projectInit` - Initialize AI context
- `/discoverEmail` - Process emails
- `/updateSummary` - Generate summary
- `/sanityCheck` - Run bootstrap validation
- `/generateTasks` - Create task lists

## Decision Tree

**First time using template?**
→ Run `./init.sh`
→ Add emails to `email/raw/`
→ Run `/quickStartProject`

**Adding more emails later?**
→ Add to `email/raw/`
→ Run `/discoverEmail`
→ Run `/updateSummary`

**Need project status summary?**
→ Run `/updateSummary`
→ Check `SUMMARY.md`

**Want to analyze bootstrap health?**
→ Run `/sanityCheck`
→ Review `bootstrap/SANITY_CHECK_REPORT.md`

## File Locations

- **Project docs**: `aiDocs/`
- **Email context**: `email/ai/`
- **Task list**: `aiDocs/TASKS.md`
- **Project summary**: `SUMMARY.md` (root)
- **Bootstrap tasks**: `bootstrap/FIXES.md`, `bootstrap/IMPROVEMENTS.md`
```

**Location**:
- New file: `QUICKREF.md` at project root

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-006 (README improvements)

**Acceptance Criteria**:
- [ ] QUICKREF.md created
- [ ] All slash commands listed
- [ ] Decision tree for common scenarios
- [ ] File locations quick reference
- [ ] Fits on one printed page (or close)
- [ ] Link from README to QUICKREF
- [ ] Clear, scannable format

**References**:
- Sanity Check Issue: ISSUE-027

---

### TASK-028: Add Bootstrap Analysis Directory

**Priority**: Medium  
**Category**: Project Structure  
**Component**: bootstrap/  
**Effort**: Low (< 1 hour)  
**Impact**: Low  

**Problem**:
Bootstrap prompts reference `bootstrap/analysis/` directory but it doesn't exist. Generated reports need a consistent location.

**Current Behavior**:
Reports saved to bootstrap/ root, creating clutter.

**Expected Behavior**:
Dedicated analysis/ subdirectory for all generated reports.

**Proposed Solution**:
1. Create `bootstrap/analysis/` directory
2. Add .gitkeep to preserve in git
3. Update sanityCheck prompt to save to `bootstrap/analysis/SANITY_CHECK_REPORT.md`
4. Move existing SANITY_CHECK_REPORT.md if present
5. Add README explaining directory purpose

**Location**:
- New directory: `bootstrap/analysis/`
- Update: `bootstrap/prompts/sanityCheck.prompt.md`

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] bootstrap/analysis/ directory created
- [ ] .gitkeep added
- [ ] README.md in analysis/ explains purpose
- [ ] sanityCheck prompt updated to use new location
- [ ] Existing reports moved if present

**References**:
- Sanity Check Report: Project Structure findings

---

### TASK-029: Add MCP Config to .gitignore

**Priority**: Medium  
**Category**: Best Practice  
**Component**: .gitignore  
**Effort**: Low (< 1 hour)  
**Impact**: Low  

**Problem**:
`.vscode/mcp.json` not in .gitignore but could contain sensitive paths or configuration specific to individual developer machines.

**Current Behavior**:
mcp.json may be committed with user-specific or sensitive paths.

**Expected Behavior**:
mcp.json ignored by default; each developer runs init.sh to create their own.

**Proposed Solution**:
Add to .gitignore:
```
# MCP configuration (user-specific)
.vscode/mcp.json
```

Add note to README about running init.sh on clone.

**Location**:
- File: `.gitignore`

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] .vscode/mcp.json added to .gitignore
- [ ] README notes mcp.json is user-specific
- [ ] init.sh instructions emphasize re-running after clone
- [ ] Example mcp.json.template provided (optional)

**References**:
- Sanity Check Report: Project Structure findings

---

## Low Impact Improvements

These are polish and optimization improvements.

### TASK-030: Add Troubleshooting Section to README

**Priority**: Low  
**Category**: Documentation  
**Component**: README.md  
**Effort**: Medium (2-3 hours)  
**Impact**: High  

**Problem**:
No troubleshooting guide for common issues. Users get stuck on common problems without guidance.

**Current Behavior**:
Users must search through issues or ask for help.

**Expected Behavior**:
README has troubleshooting section addressing common problems.

**Proposed Solution**:
Add section to README before conclusion:
```markdown
## Troubleshooting

### Python 3 Not Found
**Error**: `python3: command not found`
**Solution**: Install Python 3.8+ from https://python.org

### Email Converter Fails
**Error**: Email conversion errors
**Solutions**:
- Check email file encoding (UTF-8 recommended)
- Ensure .eml files are valid email format
- Run with `python3 -v` for detailed errors
- Check file permissions in email/ directories

### Prompts Not Available in Copilot
**Error**: Slash commands don't work
**Solutions**:
- Verify files exist in prompts/
- Check .vscode/settings.json references prompts
- Reload VS Code window
- Ensure GitHub Copilot extension enabled

### Task IDs Have Gaps
**Info**: This is normal!
**Explanation**: When tasks complete, they move to archive. Gaps in outstanding task IDs are expected.

### MCP Server Selection Hangs
**Error**: init.sh freezes at server selection
**Solutions**:
- Press arrow keys (not Enter) to navigate
- Press Space to toggle selection
- Navigate to "Confirm Selection" and press Enter
- Use Ctrl+C to cancel and restart
```

**Location**:
- File: `README.md`
- Add section before final conclusion

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-006 (README improvements)

**Acceptance Criteria**:
- [ ] Troubleshooting section added
- [ ] Common issues documented
- [ ] Clear solutions provided
- [ ] Links to relevant documentation
- [ ] Covers Python, email, MCP, and prompt issues

**References**:
- Sanity Check Report: User Experience Analysis

---

## Completed Improvements

### December 9, 2025

[Improvements will be moved here as they are completed]

---

## Notes

- This file tracks improvements to the bootstrap template itself
- For improvements to bootstrapped projects, see root `FUTURE.md`
- For critical bugs, see `bootstrap/FIXES.md`
- High impact improvements should be prioritized even if effort is higher
- Many of these can be done in parallel (no blocking dependencies)
