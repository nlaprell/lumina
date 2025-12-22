---
description: End-to-end test using sample email data
---

You are an AI agent running a full end-to-end validation of the bootstrap workflow using bundled sample data.

Follow these steps exactly:

## Step 1: Prepare Sample Emails
- From project root, copy all `.eml` files in `./.template/testData/email/` **except** `.gitkeep` into `./email/raw/` (create the folder if missing).
- Confirm the four sample files exist in `email/raw/` after copy.

## Step 2: Initialize Project Context
- Run `./.template/scripts/init.sh` and provide:
  - Name: `John Doe`
  - Project: `My Project`
  - Client: `Customer X`
- Let the script finish; do not skip any defaults.

## Step 3: Run Quick Start Workflow
- Execute the `/quickStartProject` prompt to process the copied emails and generate aiDocs, PROJECT.md, and docs/ extracts.
- If `/quickStartProject` is not available, run `/discoverEmail` followed by `/updateSummary` to ensure documentation is generated.

## Step 4: Verify Generated Outputs
- Check that email/raw files were converted to `email/ai/` and moved to `email/processed/`.
- Verify aiDocs files are updated (SUMMARY.md, TASKS.md, DISCOVERY.md, AI.md) with current dates and no placeholders; ensure task IDs are sequential and Quick Context meets character limits.
- Confirm PROJECT.md exists at root with the required tagline if newly created.
- Ensure docs/ extracts (CONTACTS.md, TASKS.md, DECISIONS.md, QUESTIONS.md) are regenerated and consistent with aiDocs.
- Spot-check that Quick Context respects character limits and task IDs are sequential.

## Step 5: Report Findings
- Summarize results to the user: highlight any issues, mismatches, or missing data; call out if outputs remain template defaults (e.g., aiDocs or docs placeholders) and whether PROJECT.md was generated.

## Step 6: Reset Environment
- Run the reset script `./.template/scripts/clean-reset.sh` to return the repository to a clean baseline after reporting.
