#!/bin/bash

#############################################################################
# clean-reset.sh
#
# This script resets the Lumina project to a clean, default state.
#
# What it does:
# 1. Clears all email and notes directories (raw, ai, processed, attachments)
# 2. Resets aiDocs files to template defaults
# 3. Removes root PROJECT.md and docs/ folder
# 4. Preserves configuration and scripts
#
# Usage: ./core/scripts/clean-reset.sh
#############################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling functions
handle_error() {
    local exit_code=$1
    local line_number=$2

    echo -e "${RED}========================================${NC}" >&2
    echo -e "${RED}ERROR on line $line_number${NC}" >&2
    echo -e "${RED}Exit code: $exit_code${NC}" >&2
    echo -e "${RED}========================================${NC}" >&2

    # Show recent commands for debugging
    if [ "${BASH_VERSION:-}" ]; then
        echo -e "${YELLOW}Last command: ${BASH_COMMAND}${NC}" >&2
    fi

    cleanup
    exit "$exit_code"
}

cleanup() {
    # Restore cursor visibility
    tput cnorm 2>/dev/null || true
}

# Trap errors and cleanup
trap 'handle_error $? $LINENO' ERR
trap 'cleanup' EXIT

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Lumina Clean Reset${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}WARNING: This will reset the project to a clean template state.${NC}"
echo ""
echo "This script will:"
echo "  - Clear all email and notes directories (raw, ai, processed, attachments)"
echo "  - Reset aiDocs files to template defaults"
echo "  - Remove root PROJECT.md and docs/ folder"
echo "  - Reset .vscode/mcp.json to default state"
echo "  - Preserve all other configuration files and scripts"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Reset cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Starting clean reset...${NC}"
echo ""

# Step 1: Clear email and notes directories
echo -e "${BLUE}[1/5] Clearing email and notes directories...${NC}"

# Clear email directories
if [ -d "$PROJECT_ROOT/email/raw" ]; then
    rm -f "$PROJECT_ROOT/email/raw/"*.eml
    echo "  ✓ Cleared email/raw/"
fi

if [ -d "$PROJECT_ROOT/email/ai" ]; then
    rm -f "$PROJECT_ROOT/email/ai/"*.md
    echo "  ✓ Cleared email/ai/"
fi

if [ -d "$PROJECT_ROOT/email/processed" ]; then
    rm -f "$PROJECT_ROOT/email/processed/"*.eml
    echo "  ✓ Cleared email/processed/"
fi

if [ -d "$PROJECT_ROOT/email/attachments" ]; then
    rm -rf "$PROJECT_ROOT/email/attachments/"*
    echo "  ✓ Cleared email/attachments/"
fi

# Clear notes directories
if [ -d "$PROJECT_ROOT/notes/raw" ]; then
    rm -f "$PROJECT_ROOT/notes/raw/"*.txt "$PROJECT_ROOT/notes/raw/"*.md
    echo "  ✓ Cleared notes/raw/"
fi

if [ -d "$PROJECT_ROOT/notes/ai" ]; then
    rm -f "$PROJECT_ROOT/notes/ai/"*.md
    echo "  ✓ Cleared notes/ai/"
fi

if [ -d "$PROJECT_ROOT/notes/processed" ]; then
    rm -f "$PROJECT_ROOT/notes/processed/"*.txt "$PROJECT_ROOT/notes/processed/"*.md
    echo "  ✓ Cleared notes/processed/"
fi

if [ -d "$PROJECT_ROOT/notes/attachments" ]; then
    rm -rf "$PROJECT_ROOT/notes/attachments/"*
    echo "  ✓ Cleared notes/attachments/"
fi

echo ""

# Step 2: Reset aiDocs files from templates
echo -e "${BLUE}[2/5] Resetting aiDocs files to templates...${NC}"

if [ -f "$PROJECT_ROOT/core/templates/SUMMARY.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/SUMMARY.template.md" "$PROJECT_ROOT/aiDocs/SUMMARY.md"
    echo "  ✓ Reset aiDocs/SUMMARY.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/SUMMARY.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/core/templates/TASKS.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/TASKS.template.md" "$PROJECT_ROOT/aiDocs/TASKS.md"
    echo "  ✓ Reset aiDocs/TASKS.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/TASKS.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/core/templates/DISCOVERY.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/DISCOVERY.template.md" "$PROJECT_ROOT/aiDocs/DISCOVERY.md"
    echo "  ✓ Reset aiDocs/DISCOVERY.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/DISCOVERY.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/core/templates/AI.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/AI.template.md" "$PROJECT_ROOT/aiDocs/AI.md"
    echo "  ✓ Reset aiDocs/AI.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/AI.template.md${NC}"
fi

echo ""

# Step 3: Remove root PROJECT.md and reset docs/ folder from templates
echo -e "${BLUE}[3/5] Removing root PROJECT.md and resetting docs/ folder...${NC}"

if [ -f "$PROJECT_ROOT/PROJECT.md" ]; then
    rm -f "$PROJECT_ROOT/PROJECT.md"
    echo "  ✓ Removed PROJECT.md (will be regenerated on first /quickStartProject run)"
else
    echo "  ℹ PROJECT.md does not exist (nothing to remove)"
fi

# Remove existing docs/ folder
if [ -d "$PROJECT_ROOT/docs" ]; then
    rm -rf "$PROJECT_ROOT/docs"
    echo "  ✓ Removed existing docs/ folder"
fi

# Recreate docs/ folder from templates
mkdir -p "$PROJECT_ROOT/docs"
echo "  ✓ Created docs/ folder"

# Copy docs templates
if [ -f "$PROJECT_ROOT/core/templates/CONTACTS.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/CONTACTS.template.md" "$PROJECT_ROOT/docs/CONTACTS.md"
    echo "  ✓ Reset docs/CONTACTS.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/CONTACTS.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/core/templates/TASKS_docs.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/TASKS_docs.template.md" "$PROJECT_ROOT/docs/TASKS.md"
    echo "  ✓ Reset docs/TASKS.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/TASKS_docs.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/core/templates/DECISIONS.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/DECISIONS.template.md" "$PROJECT_ROOT/docs/DECISIONS.md"
    echo "  ✓ Reset docs/DECISIONS.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/DECISIONS.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/core/templates/QUESTIONS.template.md" ]; then
    cp "$PROJECT_ROOT/core/templates/QUESTIONS.template.md" "$PROJECT_ROOT/docs/QUESTIONS.md"
    echo "  ✓ Reset docs/QUESTIONS.md"
else
    echo -e "  ${RED}✗ Template not found: core/templates/QUESTIONS.template.md${NC}"
fi

echo ""

# Step 4: Reset mcp.json to default state
echo -e "${BLUE}[4/5] Resetting MCP configuration...${NC}"

if [ -f "$PROJECT_ROOT/.vscode/mcp.json" ]; then
    echo '{"servers": {}}' > "$PROJECT_ROOT/.vscode/mcp.json"
    echo "  ✓ Reset .vscode/mcp.json to default state"
else
    echo "  ℹ .vscode/mcp.json does not exist (nothing to reset)"
fi

echo ""

# Step 5: Verify reset
echo -e "${BLUE}[5/5] Verifying reset...${NC}"

# Check that templates exist
TEMPLATES_OK=true
if [ ! -f "$PROJECT_ROOT/core/templates/SUMMARY.template.md" ]; then
    echo -e "  ${RED}✗ Missing template: SUMMARY.template.md${NC}"
    TEMPLATES_OK=false
fi
if [ ! -f "$PROJECT_ROOT/core/templates/TASKS.template.md" ]; then
    echo -e "  ${RED}✗ Missing template: TASKS.template.md${NC}"
    TEMPLATES_OK=false
fi
if [ ! -f "$PROJECT_ROOT/core/templates/DISCOVERY.template.md" ]; then
    echo -e "  ${RED}✗ Missing template: DISCOVERY.template.md${NC}"
    TEMPLATES_OK=false
fi
if [ ! -f "$PROJECT_ROOT/core/templates/AI.template.md" ]; then
    echo -e "  ${RED}✗ Missing template: AI.template.md${NC}"
    TEMPLATES_OK=false
fi

# Check that aiDocs files were reset
AIDOCS_OK=true
if [ ! -f "$PROJECT_ROOT/aiDocs/SUMMARY.md" ]; then
    echo -e "  ${RED}✗ Missing aiDocs/SUMMARY.md${NC}"
    AIDOCS_OK=false
fi
if [ ! -f "$PROJECT_ROOT/aiDocs/TASKS.md" ]; then
    echo -e "  ${RED}✗ Missing aiDocs/TASKS.md${NC}"
    AIDOCS_OK=false
fi
if [ ! -f "$PROJECT_ROOT/aiDocs/DISCOVERY.md" ]; then
    echo -e "  ${RED}✗ Missing aiDocs/DISCOVERY.md${NC}"
    AIDOCS_OK=false
fi
if [ ! -f "$PROJECT_ROOT/aiDocs/AI.md" ]; then
    echo -e "  ${RED}✗ Missing aiDocs/AI.md${NC}"
    AIDOCS_OK=false
fi

# Check email directories are empty (excluding .gitkeep)
EMAIL_OK=true
RAW_FILES=$(find "$PROJECT_ROOT/email/raw" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$RAW_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ email/raw/ is not empty (found "$RAW_FILES" file(s))${NC}"
    EMAIL_OK=false
fi
AI_FILES=$(find "$PROJECT_ROOT/email/ai" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$AI_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ email/ai/ is not empty (found "$AI_FILES" file(s))${NC}"
    EMAIL_OK=false
fi
PROCESSED_FILES=$(find "$PROJECT_ROOT/email/processed" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$PROCESSED_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ email/processed/ is not empty (found "$PROCESSED_FILES" file(s))${NC}"
    EMAIL_OK=false
fi

# Check notes directories are empty (excluding .gitkeep)
NOTES_OK=true
NOTES_RAW_FILES=$(find "$PROJECT_ROOT/notes/raw" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$NOTES_RAW_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ notes/raw/ is not empty (found "$NOTES_RAW_FILES" file(s))${NC}"
    NOTES_OK=false
fi
NOTES_AI_FILES=$(find "$PROJECT_ROOT/notes/ai" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$NOTES_AI_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ notes/ai/ is not empty (found "$NOTES_AI_FILES" file(s))${NC}"
    NOTES_OK=false
fi
NOTES_PROCESSED_FILES=$(find "$PROJECT_ROOT/notes/processed" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$NOTES_PROCESSED_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ notes/processed/ is not empty (found "$NOTES_PROCESSED_FILES" file(s))${NC}"
    NOTES_OK=false
fi

# Check mcp.json is reset
MCP_OK=true
if [ -f "$PROJECT_ROOT/.vscode/mcp.json" ]; then
    MCP_CONTENT=$(cat "$PROJECT_ROOT/.vscode/mcp.json" | tr -d '[:space:]')
    if [ "$MCP_CONTENT" != '{"servers":{}}' ]; then
        echo -e "  ${RED}✗ .vscode/mcp.json is not in default state${NC}"
        MCP_OK=false
    fi
fi

if [ "$TEMPLATES_OK" = "true" ] && [ "$AIDOCS_OK" = "true" ] && [ "$EMAIL_OK" = "true" ] && [ "$NOTES_OK" = "true" ] && [ "$MCP_OK" = "true" ]; then
    echo -e "  ${GREEN}✓ All checks passed${NC}"
else
    echo -e "  ${YELLOW}⚠ Some issues found (see above)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Reset Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "The project has been reset to a clean template state."
echo ""
echo "Next steps:"
echo "  1. Run ./core/scripts/init.sh to configure your project"
echo "  2. Add email files to email/raw/ and/or notes files to notes/raw/ (if needed)"
echo "  3. Run /quickStartProject in GitHub Copilot"
echo ""
