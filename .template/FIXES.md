# Bootstrap Project Fixes

*Last Updated: December 9, 2025*

Critical bugs and issues that need to be fixed in the copilot_template bootstrap project.

---

## Summary

- Total Fixes: 21
- Critical: 3
- High: 8
- Medium: 8
- Low: 2

---

## Critical Fixes (🔴 Must Fix Immediately)

### TASK-001: Fix Command Injection Vulnerability in init.sh

**Priority**: Critical  
**Category**: Code Quality - Security  
**Component**: init.sh  
**Effort**: Medium (2-3 hours)  
**Impact**: High  

**Problem**:
The Python command that merges MCP configs uses unescaped file paths passed directly to Python via shell, creating a potential command injection vector.

**Current Behavior**:
File paths from mcpServers/ are inserted directly into Python command string executed via shell. A malicious filename could execute arbitrary code.

**Expected Behavior**:
JSON merging should be done safely without shell command injection risk.

**Proposed Solution**:
1. Replace inline Python with proper subprocess.run() call using argument list instead of shell=True
2. OR: Use jq for JSON merging (more portable, safer)
3. OR: Validate/sanitize file paths before passing to any command
4. Add unit test with specially crafted filename to verify fix

**Location**:
- File: `init.sh`
- Lines: 165-185 (merge_configs function)

**Dependencies**:
- Blocks: TASK-009 (MCP validation can use same safe merging approach)
- Requires: None
- Related: TASK-004 (input sanitization)

**Acceptance Criteria**:
- [ ] File paths are validated or properly escaped before use
- [ ] JSON merging does not use shell=True or uses argument list properly
- [ ] Test with filename containing shell metacharacters (`;`, `$()`, etc.) does not execute code
- [ ] All existing MCP config files still merge correctly
- [ ] Error handling provides clear message if merge fails

**References**:
- Sanity Check Issue: ISSUE-001
- Security Best Practice: OWASP Command Injection Prevention

---

### TASK-002: Add Bootstrap Prompts to VS Code Settings

**Priority**: Critical  
**Category**: Integration  
**Component**: .vscode/settings.json  
**Effort**: Low (< 1 hour)  
**Impact**: High  

**Problem**:
settings.json doesn't reference the new bootstrap prompts (sanityCheck, generateTasks), so they won't be available via slash commands in Copilot chat.

**Current Behavior**:
Users cannot invoke /sanityCheck or /generateTasks - prompts exist but are not registered.

**Expected Behavior**:
/sanityCheck and /generateTasks slash commands work in Copilot chat.

**Proposed Solution**:
Add two entries to .vscode/settings.json:
```json
{
    "file": ".template/prompts/sanityCheck.prompt.md"
},
{
    "file": ".template/prompts/generateTasks.prompt.md"
}
```

**Location**:
- File: `.vscode/settings.json`
- Lines: 3-13

**Dependencies**:
- Blocks: None (but enables template workflow)
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] sanityCheck.prompt.md added to settings.json
- [ ] generateTasks.prompt.md added to settings.json
- [ ] /sanityCheck command works in Copilot chat
- [ ] /generateTasks command works in Copilot chat
- [ ] Existing prompts still work correctly

**References**:
- Sanity Check Issue: ISSUE-002
- Related Files: .template/prompts/sanityCheck.prompt.md, .template/prompts/generateTasks.prompt.md

---

### TASK-003: Add Error Handling for Email Move Failures

**Priority**: Critical  
**Category**: Code Quality - Data Integrity  
**Component**: .template/aiScripts/emailToMd/eml_to_md_converter.py  
**Effort**: Medium (1-2 hours)  
**Impact**: High  

**Problem**:
If email file cannot be moved to processed/ directory (due to permissions, disk full, etc.), the script continues and reports success. User loses track of which emails were actually processed.

**Current Behavior**:
- rename() is called but return value not checked
- Exceptions in move caught generically and script continues
- Success count includes emails that weren't actually moved
- Re-running converter may process same emails twice

**Expected Behavior**:
- Track which files were successfully moved vs failed
- Report failures clearly with reason
- Success count reflects only fully processed emails
- Failed emails remain in raw/ for retry

**Proposed Solution**:
1. Wrap rename() in try/except specifically for OSError/PermissionError
2. Track failed_moves list separately from converted_count
3. Only increment converted_count if both conversion AND move succeed
4. Report failed moves at end: "Failed to archive: file1.eml (Permission denied), file2.eml (Disk full)"
5. Exit with non-zero status if any moves failed

**Location**:
- File: `.template/aiScripts/emailToMd/eml_to_md_converter.py`
- Lines: 207-211

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-005 (error handling for malformed emails)

**Acceptance Criteria**:
- [ ] rename() wrapped in specific exception handler
- [ ] Failed moves tracked in separate list
- [ ] Success count only includes fully processed emails
- [ ] Clear error message for each failed move with reason
- [ ] Script exits with status 1 if any moves failed
- [ ] Failed emails remain in raw/ directory
- [ ] Re-running script processes failed emails correctly

**References**:
- Sanity Check Issue: ISSUE-003
- Python docs: pathlib.Path.rename()

---

## High Priority Fixes (🟠 Fix Soon)

### TASK-004: Add Input Sanitization to init.sh

**Priority**: High  
**Category**: Code Quality - Security  
**Component**: init.sh  
**Effort**: Medium (2-3 hours)  
**Impact**: Medium  

**Problem**:
User inputs (USER_NAME, PROJECT_NAME, CUSTOMER_NAME) are not sanitized for special characters, spaces, or shell metacharacters before being used in commands or file operations.

**Current Behavior**:
User can enter any characters including special shell characters that could break subsequent operations.

**Expected Behavior**:
Input is validated against safe character set with clear error messages for invalid input.

**Proposed Solution**:
1. Define safe character set: [a-zA-Z0-9_- ] (alphanumeric, underscore, hyphen, space)
2. Add validation function: validate_input()
3. Check each input after read, reject and re-prompt if invalid
4. Add length limits (e.g., max 100 chars)
5. Provide helpful error: "Name can only contain letters, numbers, spaces, hyphens, and underscores"

**Location**:
- File: `init.sh`
- Lines: 41-75 (prompt_project_name function)

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-001 (command injection)

**Acceptance Criteria**:
- [ ] validate_input() function created
- [ ] All three inputs (user, project, customer) validated
- [ ] Special characters rejected with clear error message
- [ ] Length limits enforced
- [ ] Valid inputs still work correctly
- [ ] Test with various special characters: `$()`, `;`, `|`, `&`, `\``, `"`, `'`

**References**:
- Sanity Check Issue: ISSUE-004

---

### TASK-005: Improve Email Converter Error Handling

**Priority**: High  
**Category**: Code Quality  
**Component**: .template/aiScripts/emailToMd/eml_to_md_converter.py  
**Effort**: Medium (2-3 hours)  
**Impact**: Medium  

**Problem**:
Malformed emails or unsupported encodings fail silently with generic exception handler; no specific guidance for user on what went wrong or which email failed.

**Current Behavior**:
Generic `except Exception as e` catches all errors with minimal context.

**Expected Behavior**:
Specific exception types caught with actionable error messages naming the problematic file and suggesting solutions.

**Proposed Solution**:
1. Replace generic exception handler with specific handlers:
   - UnicodeDecodeError: "Email has unsupported encoding"
   - email.errors.MessageError: "Email file is malformed"
   - KeyError: "Email missing required headers"
2. Include filename in all error messages
3. Add --verbose flag to show full stack trace
4. Continue processing remaining emails after error
5. Summary at end lists all failed files with reasons

**Location**:
- File: `.template/aiScripts/emailToMd/eml_to_md_converter.py`
- Lines: 162-165

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-003 (move failure handling), TASK-011 (attachment handling)

**Acceptance Criteria**:
- [ ] Specific exception handlers for common errors
- [ ] Error messages include filename
- [ ] --verbose flag implemented
- [ ] Processing continues after individual email failure
- [ ] Summary report lists all failed emails with reasons
- [ ] Exit status reflects failures (non-zero if any failed)

**References**:
- Sanity Check Issue: ISSUE-005
- Python email library docs

---

### TASK-006: Fix README Quick Start Step Ordering

**Priority**: High  
**Category**: Documentation  
**Component**: README.md  
**Effort**: Low (< 1 hour)  
**Impact**: High  

**Problem**:
README says to run /quickStartProject but doesn't explain that this requires emails to be in email/raw/ first. Step ordering is confusing for new users.

**Current Behavior**:
Users run quickStartProject before adding emails, get empty/confusing results.

**Expected Behavior**:
Clear guidance on when to add emails vs when to run quickStartProject.

**Proposed Solution**:
Rewrite Quick Start section with conditional steps:
```
### Step 2: Add Email Context (Optional)
**If you have project-related emails:**
1. Export email threads to .eml format
2. Place them in `email/raw/`

**If you don't have emails yet:**
- Skip to Step 3 - you can add emails later

### Step 3: Initialize Project
Run: /quickStartProject
- If you added emails, they'll be processed automatically
- If not, project will initialize with empty context
```

**Location**:
- File: `README.md`
- Lines: 15-40

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-027 (quick reference card)

**Acceptance Criteria**:
- [ ] Step 2 clearly marked as optional
- [ ] Conditional instructions for with/without emails
- [ ] Guidance on adding emails later
- [ ] No misleading statements about required vs optional steps
- [ ] Flow makes sense to first-time user

**References**:
- Sanity Check Issue: ISSUE-006

---

### TASK-007: Add --apply Flag to Task Dependency Detector

**Priority**: High  
**Category**: User Experience - Feature  
**Component**: .template/aiScripts/detectTaskDependencies/detectTaskDependencies.py  
**Effort**: High (4-6 hours)  
**Impact**: High  

**Problem**:
Script generates report and suggestions but doesn't actually update TASKS.md with detected dependencies, leaving manual work for user.

**Current Behavior**:
User must manually copy dependency suggestions from report to TASKS.md.

**Expected Behavior**:
Optional --apply flag automatically updates TASKS.md with high-confidence detected dependencies.

**Proposed Solution**:
1. Add argparse with --apply and --dry-run flags
2. Parse TASKS.md to get current task state
3. For each high-confidence (>0.8) detection:
   - Check if dependency already exists
   - If not, add to appropriate Blocks/Related field
4. Update TASKS.md preserving all formatting
5. --dry-run shows what would change without writing
6. Backup original TASKS.md before applying changes

**Location**:
- File: `.template/aiScripts/detectTaskDependencies/detectTaskDependencies.py`
- Missing functionality

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-010 (circular dependency detection)

**Acceptance Criteria**:
- [ ] --apply flag implemented
- [ ] --dry-run flag shows changes without applying
- [ ] Only high-confidence (>0.8) dependencies applied
- [ ] Existing dependencies not duplicated
- [ ] TASKS.md formatting preserved
- [ ] Backup created before modification
- [ ] Clear summary of changes made
- [ ] Warning if circular dependencies would be created

**References**:
- Sanity Check Issue: ISSUE-007

---

### TASK-008: Add Python 3 Version Check

**Priority**: High  
**Category**: Code Quality  
**Component**: init.sh, aiScripts/emailToMd/eml_to_md_converter.py  
**Effort**: Low (1 hour)  
**Impact**: Medium  

**Problem**:
Scripts assume python3 exists but don't check; init.sh uses Python without checking availability, leading to cryptic errors.

**Current Behavior**:
If Python 3 not installed, script fails with confusing error message.

**Expected Behavior**:
Early check for Python 3 with clear error message and installation instructions.

**Proposed Solution**:
1. In init.sh, add check before merge_configs:
```bash
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed"
    echo "Install Python 3.8+ from https://python.org"
    exit 1
fi
```
2. In eml_to_md_converter.py, add version check in main():
```python
import sys
if sys.version_info < (3, 8):
    print("Error: Python 3.8+ required")
    sys.exit(1)
```

**Location**:
- File: `init.sh` line 165
- File: `.template/aiScripts/emailToMd/eml_to_md_converter.py` main()

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] init.sh checks for python3 before use
- [ ] Email converter checks Python version
- [ ] Clear error message if Python missing
- [ ] Error message includes installation instructions
- [ ] Minimum version 3.8 enforced
- [ ] README updated to specify Python 3.8+ requirement

**References**:
- Sanity Check Issue: ISSUE-008

---

### TASK-009: Add MCP Server Config Validation

**Priority**: High  
**Category**: Code Quality  
**Component**: init.sh  
**Effort**: Medium (2 hours)  
**Impact**: Medium  

**Problem**:
init.sh merges JSON configs without validating they're valid JSON or valid MCP server configs first. Malformed JSON breaks init.sh with cryptic Python error.

**Current Behavior**:
Invalid JSON causes Python error during merge without identifying which file is invalid.

**Expected Behavior**:
JSON validated before merge; clear error message naming the invalid file.

**Proposed Solution**:
1. Add validate_json() function that uses python3 -c to check each file
2. Before merging, iterate through all MCP files and validate
3. If invalid, print: "Error: Invalid JSON in mcpServers/filename.json"
4. Optional: validate against MCP schema (check for required fields)
5. Exit early if any invalid files found

**Location**:
- File: `init.sh`
- Lines: 165-185 (merge_configs function)

**Dependencies**:
- Blocks: None
- Requires: TASK-001 (safe merging implementation)
- Related: TASK-021 (schema standardization)

**Acceptance Criteria**:
- [ ] validate_json() function created
- [ ] All MCP files validated before merge
- [ ] Clear error naming invalid file
- [ ] Valid files still merge correctly
- [ ] Test with intentionally malformed JSON file

**References**:
- Sanity Check Issue: ISSUE-009

---

### TASK-010: Fix Circular Dependency Detection False Positives

**Priority**: High  
**Category**: Code Quality  
**Component**: .template/aiScripts/detectTaskDependencies/detectTaskDependencies.py  
**Effort**: Medium (3-4 hours)  
**Impact**: Medium  

**Problem**:
The DFS-based cycle detection adds cycles to list even when no actual circular dependency exists in some edge cases.

**Current Behavior**:
False positive warnings about circular dependencies confuse users.

**Expected Behavior**:
Only actual circular dependencies reported; equivalent cycles deduplicated.

**Proposed Solution**:
1. Add cycle normalization to deduplicate equivalent cycles
2. Verify each detected cycle actually forms a circle (start == end)
3. Add unit tests with known circular and non-circular cases
4. Sort cycle nodes before comparison to detect duplicates
5. Only report unique cycles

**Location**:
- File: `.template/aiScripts/detectTaskDependencies/detectTaskDependencies.py`
- Lines: 248-270

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-007 (--apply flag should check for cycles)

**Acceptance Criteria**:
- [ ] Cycles normalized before comparison
- [ ] Equivalent cycles deduplicated
- [ ] Only valid circular dependencies reported
- [ ] Unit tests for circular and non-circular cases
- [ ] No false positives in test suite

**References**:
- Sanity Check Issue: ISSUE-010

---

### TASK-011: Add Attachment Listing to Email Converter

**Priority**: High  
**Category**: User Experience - Feature  
**Component**: .template/aiScripts/emailToMd/eml_to_md_converter.py  
**Effort**: Medium (2-3 hours)  
**Impact**: Medium  

**Problem**:
Script silently ignores email attachments; no indication in output that attachments existed or were skipped. Important context from attachments (screenshots, documents) is lost without user knowing.

**Current Behavior**:
Attachments completely ignored, no mention in converted Markdown.

**Expected Behavior**:
Converted Markdown lists all attachments that were present but not converted.

**Proposed Solution**:
1. In email parsing loop, detect attachment parts
2. Collect attachment filenames in list
3. Add section to Markdown output:
```markdown
**Attachments** (not converted):
- screenshot.png
- requirements.pdf
- diagram.jpg
```
4. Only add section if attachments exist
5. Include attachment size and content type

**Location**:
- File: `.template/aiScripts/emailToMd/eml_to_md_converter.py`
- Missing functionality in extract_email_content()

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-005 (error handling)

**Acceptance Criteria**:
- [ ] Attachments detected during parsing
- [ ] Attachment names collected
- [ ] Attachment list added to converted Markdown
- [ ] Section only appears if attachments exist
- [ ] Filename, size, and type shown for each attachment
- [ ] Test with email containing multiple attachment types

**References**:
- Sanity Check Issue: ISSUE-011

---

## Medium Priority Fixes (🟡 Should Fix)

### TASK-012: Update .template/FUTURE.md Item #2 Status

**Priority**: Medium  
**Category**: Documentation  
**Component**: .template/FUTURE.md  
**Effort**: Low (< 1 hour)  
**Impact**: Low  

**Problem**:
.template/FUTURE.md lists "Smart Task Dependency Detection" as improvement #2, but it's already implemented in detectTaskDependencies.py. Confusing to have completed feature listed as future work.

**Current Behavior**:
Item #2 in .template/FUTURE.md describes feature that already exists.

**Expected Behavior**:
.template/FUTURE.md reflects actual status - completed items marked or moved.

**Proposed Solution**:
Either:
1. Add "Implemented Improvements" section and move #2 there with completion date
2. OR: Mark item as ✅ COMPLETE with note about detectTaskDependencies.py
3. Update description to reflect current state and note remaining work (like --apply flag from TASK-007)

**Location**:
- File: `.template/FUTURE.md`
- Lines: 47-87

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-007 (--apply flag is remaining work for this feature)

**Acceptance Criteria**:
- [ ] Item #2 marked as completed or moved to implemented section
- [ ] Reference to detectTaskDependencies.py added
- [ ] Remaining work (--apply flag) noted if applicable
- [ ] .template/FUTURE.md structure updated if new section added

**References**:
- Sanity Check Issue: ISSUE-012

---

### TASK-013: Standardize Path Separator Documentation

**Priority**: Medium  
**Category**: Documentation  
**Component**: README.md, prompts/  
**Effort**: Low (1 hour)  
**Impact**: Low  

**Problem**:
Some places use `./` prefix, others don't; inconsistent between "email/raw" and "./email/raw" throughout documentation.

**Current Behavior**:
Mixed path styles cause minor confusion about whether paths are relative or absolute.

**Expected Behavior**:
Consistent path format throughout all documentation.

**Proposed Solution**:
1. Choose standard: `email/raw/` (without ./ prefix) for clarity
2. Search and replace in all files:
   - README.md
   - All prompt files
   - copilot-instructions.md
3. Update any examples to match

**Location**:
- Throughout README.md and prompts/

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] All path references use consistent format
- [ ] No `./` prefix on directory paths
- [ ] Trailing `/` used consistently for directories
- [ ] README, prompts, and instructions all match

**References**:
- Sanity Check Issue: ISSUE-013

---

### TASK-014: Add Template Existence Check to clean-reset.sh

**Priority**: Medium  
**Category**: Code Quality  
**Component**: .template/scripts/clean-reset.sh  
**Effort**: Low (1 hour)  
**Impact**: Medium  

**Problem**:
Script attempts to copy templates but only reports error after attempting copy; doesn't fail early. Partial reset leaves project in inconsistent state if templates missing.

**Current Behavior**:
Script tries to copy each template individually, continues even if some fail.

**Expected Behavior**:
Pre-flight check verifies all templates exist before starting reset; fails early with clear message if any missing.

**Proposed Solution**:
1. Add check_templates() function at start
2. Verify all 4 templates exist:
   - SUMMARY.template.md
   - TASKS.template.md
   - DISCOVERY.template.md
   - AI.template.md
3. If any missing, list them and exit before deleting anything
4. Only proceed with reset if all templates present

**Location**:
- File: `.template/scripts/clean-reset.sh`
- Lines: 79-108 (add check before this section)

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] check_templates() function created
- [ ] All 4 templates verified before reset starts
- [ ] Clear error listing missing templates
- [ ] No files deleted if templates missing
- [ ] Existing reset logic unchanged if all templates present

**References**:
- Sanity Check Issue: ISSUE-014

---

### TASK-015: Improve clean-reset.sh Warning Message

**Priority**: Medium  
**Category**: User Experience  
**Component**: .template/scripts/clean-reset.sh  
**Effort**: Low (< 1 hour)  
**Impact**: Low  

**Problem**:
Script asks "Are you sure?" but doesn't specifically warn about PERMANENT email deletion. Users may not realize they're permanently deleting email context.

**Current Behavior**:
Generic confirmation message doesn't emphasize data loss.

**Expected Behavior**:
Explicit warning about permanent email deletion.

**Proposed Solution**:
Update confirmation message:
```bash
echo -e "${RED}⚠️  WARNING: This will PERMANENTLY DELETE all processed emails!${NC}"
echo ""
echo "This script will:"
echo "  - DELETE all emails from raw/, ai/, and processed/ directories"
echo "  - Reset all aiDocs files to template defaults"
echo "  - Clear project-specific data from root SUMMARY.md"
echo "  - Reset .vscode/mcp.json to default state"
echo ""
echo "Make sure you have backups of any important email context!"
echo ""
read -p "Type 'yes' to continue or anything else to cancel: " CONFIRM
```

**Location**:
- File: `.template/scripts/clean-reset.sh`
- Lines: 34-43

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] Warning message emphasizes email deletion
- [ ] All actions clearly listed
- [ ] Backup reminder included
- [ ] User must type "yes" (not just "y")
- [ ] Red color for warning

**References**:
- Sanity Check Issue: ISSUE-015

---

### TASK-016: Fix Task Template Checkbox Format

**Priority**: Medium  
**Category**: Documentation  
**Component**: aiDocs/templates/TASKS.template.md  
**Effort**: Low (< 1 hour)  
**Impact**: Low  

**Problem**:
Some tasks use `- [ ]` format, last task in template doesn't have checkbox. Inconsistency in task formatting when using template.

**Current Behavior**:
Inconsistent checkbox usage in template.

**Expected Behavior**:
All task entries have checkboxes.

**Proposed Solution**:
Add `- [ ]` to line 29 and ensure all task entries in template have checkboxes.

**Location**:
- File: `aiDocs/templates/TASKS.template.md`
- Line: 29

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] All task entries have checkboxes
- [ ] Format consistent throughout template
- [ ] Template still renders correctly as Markdown

**References**:
- Sanity Check Issue: ISSUE-016

---

### TASK-017: Add Example Question to Discovery Template

**Priority**: Medium  
**Category**: Documentation  
**Component**: aiDocs/templates/DISCOVERY.template.md  
**Effort**: Low (< 1 hour)  
**Impact**: Medium  

**Problem**:
Template doesn't show example of properly formatted discovery question with all required metadata. Users don't have clear example of expected format.

**Current Behavior**:
Template is empty or has minimal placeholder.

**Expected Behavior**:
Template includes one complete example showing all required fields.

**Proposed Solution**:
Add example question to template:
```markdown
## Example Questions

- [ ] **What is the network architecture between the MarkLogic cluster and client applications?**  
  - Ask: Network administrator or IT contact
  - Check: Network diagrams, architecture documentation, IT department
  - Status: Unknown
  - Priority: High
  - Answer: [Will be filled in when answered]
  - Source: [Email/document that provides the answer]
```

**Location**:
- File: `aiDocs/templates/DISCOVERY.template.md`

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] Complete example question added
- [ ] All required fields shown (Ask, Check, Status, Priority, Answer, Source)
- [ ] Example follows quality standards (specific, actionable, scoped)
- [ ] Comment explains this is an example

**References**:
- Sanity Check Issue: ISSUE-017

---

### TASK-018: Reorganize README Security Warning

**Priority**: Medium  
**Category**: Documentation  
**Component**: README.md  
**Effort**: Low (< 1 hour)  
**Impact**: Medium  

**Problem**:
Security warning is at top but last bullet "(gitignore configured by default)" undermines urgency - users may skip reading important verification steps.

**Current Behavior**:
Reassuring comment at end may cause users to not read verification steps carefully.

**Expected Behavior**:
Security warning emphasizes action items, reassurance doesn't undermine importance.

**Proposed Solution**:
Reorder bullets:
```markdown
## ⚠️ SECURITY WARNING

**IMPORTANT**: The `email/` directory may contain sensitive information from your email communications.

- ✓ The `.gitignore` file is configured by default to exclude email files
- ⚠️ **ALWAYS verify** `.gitignore` is properly configured before committing
- ⚠️ **ALWAYS review** `SUMMARY.md` for sensitive customer or business information
- ⚠️ **NEVER commit** `.eml` files or Markdown emails containing confidential data
- 💡 **Consider** using a private repository for projects with sensitive context
```

**Location**:
- File: `README.md`
- Lines: 7-16

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] Reassuring comment moved to first bullet
- [ ] Verification steps emphasized with warning emoji
- [ ] Key actions (verify, review, never, consider) highlighted
- [ ] Message conveys both "it's configured" and "you must verify"

**References**:
- Sanity Check Issue: ISSUE-018

---

### TASK-019: Document Dependency Detection Confidence Levels

**Priority**: Medium  
**Category**: Documentation  
**Component**: .template/aiScripts/detectTaskDependencies/README.md  
**Effort**: Low (1 hour)  
**Impact**: Medium  

**Problem**:
Code implements 3-tier confidence system (0.95, 0.60, 0.40) but README doesn't explain what confidence levels mean. Users don't understand which suggestions to trust.

**Current Behavior**:
README likely incomplete or missing confidence explanation.

**Expected Behavior**:
README clearly explains confidence levels and accuracy expectations.

**Proposed Solution**:
Add section to README:
```markdown
## Confidence Levels

The detector assigns confidence scores to each detected dependency:

### High Confidence (≥ 0.80)
- **Accuracy**: ~95%
- **Criteria**: Explicit TASK-XXX reference with dependency keyword
- **Example**: "Requires TASK-001 to be complete before starting"
- **Recommendation**: Generally safe to apply automatically

### Medium Confidence (0.50 - 0.79)
- **Accuracy**: ~60%
- **Criteria**: Keyword pattern match without explicit task reference
- **Example**: "Depends on database setup being complete"
- **Recommendation**: Review before applying

### Low Confidence (< 0.50)
- **Accuracy**: ~40%
- **Criteria**: Contextual clues (prerequisite/follow-up keywords)
- **Example**: Task mentions "setup" or "initialize"
- **Recommendation**: Manual review required
```

**Location**:
- File: `.template/aiScripts/detectTaskDependencies/README.md`

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-007 (--apply should use high confidence threshold)

**Acceptance Criteria**:
- [ ] Confidence levels documented
- [ ] Accuracy estimates provided
- [ ] Examples for each level
- [ ] Recommendations for usage
- [ ] README is complete and helpful

**References**:
- Sanity Check Issue: ISSUE-019

---

### TASK-020: Create Quick Context Validation Script

**Priority**: Medium  
**Category**: Quality Assurance  
**Component**: New file: scripts/validate-quick-context.sh  
**Effort**: Medium (2 hours)  
**Impact**: Medium  

**Problem**:
Prompts document character limits (100/150/50) for Quick Context but rely on AI compliance; no validation script to check. Limits can be accidentally exceeded without detection.

**Current Behavior**:
No automated checking of Quick Context character counts.

**Expected Behavior**:
Script validates Quick Context section meets character limits.

**Proposed Solution**:
Create bash script:
1. Parse Quick Context from aiDocs/SUMMARY.md
2. Extract What/Who/Status lines
3. Count characters (excluding "**What**: " prefix)
4. Check against limits: What≤100, Who≤150, Status≤50
5. Exit 0 if valid, exit 1 if invalid
6. Print violations with actual vs max counts

**Location**:
- New file: `scripts/validate-quick-context.sh`

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-026 (pre-commit hook could use this)

**Acceptance Criteria**:
- [ ] Script created and executable
- [ ] Parses Quick Context correctly
- [ ] Character counts accurate
- [ ] Clear error messages for violations
- [ ] Exit status indicates pass/fail
- [ ] Can be called from pre-commit hook
- [ ] Handles missing Quick Context section gracefully

**References**:
- Sanity Check Issue: ISSUE-020

---

### TASK-021: Standardize MCP Server JSON Schema

**Priority**: Medium  
**Category**: Documentation  
**Component**: mcpServers/  
**Effort**: Medium (2 hours)  
**Impact**: Low  

**Problem**:
Some files use "mcpServers" key, others use "servers" key (github.json vs awsCore.json). Inconsistency requires init.sh to handle both formats.

**Current Behavior**:
Mixed schema requires complex merging logic.

**Expected Behavior**:
All MCP config files use standardized "mcpServers" key.

**Proposed Solution**:
1. Convert all MCP JSON files to use "mcpServers" key
2. Document schema in README:
```json
{
  "mcpServers": {
    "server-name": {
      "type": "http" | "stdio",
      "url": "..." (for http)
      // or
      "command": "...",
      "args": [...]
    }
  }
}
```
3. Simplify init.sh merge logic (no longer need to handle both formats)

**Location**:
- Files: All files in `mcpServers/`
- Specifically: `mcpServers/github.json` (uses "servers")

**Dependencies**:
- Blocks: None
- Requires: TASK-009 (validation will check new schema)
- Related: TASK-001 (merge logic will be simplified)

**Acceptance Criteria**:
- [ ] All MCP JSON files use "mcpServers" key
- [ ] Schema documented in README
- [ ] init.sh merge logic simplified
- [ ] All existing configs still work
- [ ] Test merging multiple configs

**References**:
- Sanity Check Issue: ISSUE-021

---

## Low Priority Fixes (🟢 Nice to Fix)

### TASK-022: Improve Email Converter Success Message

**Priority**: Low  
**Category**: User Experience  
**Component**: .template/aiScripts/emailToMd/eml_to_md_converter.py  
**Effort**: Low (< 1 hour)  
**Impact**: Low  

**Problem**:
Final message says "X/Y files successfully processed" but doesn't clarify what "processed" means (converted? moved?).

**Current Behavior**:
Ambiguous success message.

**Expected Behavior**:
Clear message about what happened to files.

**Proposed Solution**:
Change line 218 message to:
```python
print(f"\nConversion completed! {converted_count}/{len(eml_files)} files successfully converted and archived")
```

**Location**:
- File: `.template/aiScripts/emailToMd/eml_to_md_converter.py`
- Line: 218

**Dependencies**:
- Blocks: None
- Requires: None
- Related: TASK-003 (will need to update this after error handling added)

**Acceptance Criteria**:
- [ ] Message clearly states "converted and archived"
- [ ] Still accurate after TASK-003 changes

**References**:
- Sanity Check Issue: ISSUE-022

---

### TASK-023: Document Task ID Zero-Padding Format

**Priority**: Low  
**Category**: Documentation  
**Component**: .github/copilot-instructions.md  
**Effort**: Low (< 1 hour)  
**Impact**: Low  

**Problem**:
Documentation says "TASK-001, TASK-002" but doesn't specify how many digits (001 vs 0001).

**Current Behavior**:
Zero-padding format implied but not explicit.

**Expected Behavior**:
Explicit documentation of 3-digit zero-padded format.

**Proposed Solution**:
Update line 127 to add explicit note:
```markdown
### Task ID Format

Tasks must have sequential IDs when created:
- Format: `TASK-001`, `TASK-002`, `TASK-003`, etc.
- **3-digit zero-padded** format (TASK-001 through TASK-999)
- Task IDs are permanent - once assigned, never reused or renumbered
```

**Location**:
- File: `.github/copilot-instructions.md`
- Line: 127

**Dependencies**:
- Blocks: None
- Requires: None
- Related: None

**Acceptance Criteria**:
- [ ] Explicit statement of 3-digit format
- [ ] Range documented (001-999)
- [ ] Examples show correct format

**References**:
- Sanity Check Issue: ISSUE-023

---

## Completed Fixes

### December 9, 2025

[Tasks will be moved here as they are completed]

---

## Notes

- This file tracks fixes for the template itself
- For improvements to projects created from template, see root `.template/FUTURE.md`
- For enhancement ideas, see `.template/IMPROVEMENTS.md`
- Critical issues (TASK-001 through TASK-003) should be addressed immediately
- High priority issues should be completed within 1-2 weeks
- Task IDs are permanent and sequential (no gaps)
