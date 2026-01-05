---
description: End-to-end test using sample email data
---

You are an AI agent running a full end-to-end validation of the bootstrap workflow using bundled sample data.

Follow these steps exactly:

## Step 1: Prepare Sample Data

### Emails
- From project root, copy all `.eml` files in `./core/testData/email/` **except** `.gitkeep` into `./email/raw/` (create the folder if missing).
- Confirm the four sample files exist in `email/raw/` after copy.

### Notes
- From project root, copy all `.txt` and `.md` files in `./core/testData/notes/` **except** `.gitkeep` into `./notes/raw/` (create the folder if missing).
- Confirm the three sample notes files exist in `notes/raw/` after copy.

## Step 2: Initialize Project Context
- Run `./core/scripts/init.sh` and provide:
  - Name: `John Doe`
  - Project: `My Project`
  - Client: `Customer X`
- Let the script finish; do not skip any defaults.

## Step 3: Run Quick Start Workflow
- Execute the `/quickStartProject` prompt to process the copied emails and notes, then generate aiDocs, PROJECT.md, and docs/ extracts.
- If `/quickStartProject` is not available, run `/discoverEmail`, then `/discoverNotes`, followed by `/updateSummary` to ensure documentation is generated.

## Step 4: Verify Generated Outputs

### Email Processing
- Check that email/raw files were converted to `email/ai/` and moved to `email/processed/`.
- Confirm 4 emails were processed successfully.

### Notes Processing
- Check that notes/raw files were converted to `notes/ai/` and moved to `notes/processed/`.
- Confirm 3 notes were processed successfully.

### Documentation
- Verify aiDocs files are updated (SUMMARY.md, TASKS.md, DISCOVERY.md, AI.md) with current dates and no placeholders; ensure task IDs are sequential and Quick Context meets character limits.
- Confirm PROJECT.md exists at root with the required tagline if newly created.
- Ensure docs/ extracts (CONTACTS.md, TASKS.md, DECISIONS.md, QUESTIONS.md) are regenerated and consistent with aiDocs.
- Spot-check that Quick Context respects character limits and task IDs are sequential.
- Verify information from both emails and notes is integrated into documentation.

## Step 5: Report Findings
- Summarize results to the user: highlight any issues, mismatches, or missing data; call out if outputs remain template defaults (e.g., aiDocs or docs placeholders) and whether PROJECT.md was generated.

## Step 6: Reset Environment
- Run the reset script `./core/scripts/clean-reset.sh` to return the repository to a clean baseline after reporting.

---

## Common Scenarios

### Scenario 1: Full Successful End-to-End Test
**Situation**: Testing complete workflow with bundled sample data
**Steps**:
1. Copy 4 sample .eml files from core/testData/email/ to email/raw/
2. Copy 3 sample notes files from core/testData/notes/ to notes/raw/
3. Run init.sh with test data (Name: John Doe, Project: My Project, Client: Customer X)
4. Run /quickStartProject
5. Verify all outputs
6. Reset with clean-reset.sh

**Expected Result**:
- Email processing: 4 emails converted and moved
- Notes processing: 3 notes converted and moved
- aiDocs/: All 4 files populated with actual data from both emails and notes (no placeholders)
- PROJECT.md: Created at root with AI tagline
- docs/: All 4 extract files generated
- Task IDs sequential (TASK-001, TASK-002, etc.)
- Quick Context within character limits
- Information from both sources integrated
- Clean reset successful

**Report Shows**: ✅ All checks passed, workflow functioning correctly

---

### Scenario 2: Empty Data Directories Test
**Situation**: Testing workflow without email or notes data
**Steps**:
1. Ensure email/raw/ and notes/raw/ are both empty
2. Run init.sh with test data
3. Run /quickStartProject
4. Verify template state preserved
5. Reset

**Expected Result**:
- Email processing: Skipped with "No emails found" message
- Notes processing: Skipped with "No notes found" message
- aiDocs/: Remain in template state with placeholders
- PROJECT.md: Not created (no content to generate)
- docs/: Remain in template state
- Warning shown: Add emails/notes to continue

**Report Shows**: ⚠️ Partial success - workflow handles empty state gracefully

---

### Scenario 3: Error Recovery Test
**Situation**: Testing with malformed email file and valid notes
**Steps**:
1. Copy 3 valid + 1 invalid .eml file to email/raw/
2. Copy 3 valid notes files to notes/raw/
3. Run init.sh
4. Run /quickStartProject
5. Observe error handling
6. Reset

**Expected Result**:
- Email processing: 3 valid emails processed, 1 failed with error message
- Notes processing: 3 notes processed successfully
- aiDocs/: Updated with data from 3 valid emails + 3 notes
- PROJECT.md: Generated (data from both sources)
- Error logged but workflow continued
- Clean reset successful

**Report Shows**: ⚠️ Partial success - error handling works, 3/4 emails + 3/3 notes processed
