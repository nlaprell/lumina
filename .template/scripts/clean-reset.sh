#!/bin/bash

#############################################################################
# clean-reset.sh
#
# This script resets the copilot_template project to a clean, default state.
# 
# What it does:
# 1. Clears all email directories (raw, ai, processed)
# 2. Resets aiDocs files to template defaults
# 3. Clears project-specific data from root SUMMARY.md
# 4. Preserves configuration and scripts
#
# Usage: ./.template/scripts/clean-reset.sh
#############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Copilot Template Clean Reset${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}WARNING: This will reset the project to a clean template state.${NC}"
echo ""
echo "This script will:"
echo "  - Clear all email directories (raw, ai, processed)"
echo "  - Reset aiDocs files to template defaults"
echo "  - Clear project-specific data from root SUMMARY.md"
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

# Step 1: Clear email directories
echo -e "${BLUE}[1/4] Clearing email directories...${NC}"

if [ -d "$PROJECT_ROOT/email/raw" ]; then
    rm -f "$PROJECT_ROOT/email/raw"/*.eml
    echo "  ✓ Cleared email/raw/"
fi

if [ -d "$PROJECT_ROOT/email/ai" ]; then
    rm -f "$PROJECT_ROOT/email/ai"/*.md
    echo "  ✓ Cleared email/ai/"
fi

if [ -d "$PROJECT_ROOT/email/processed" ]; then
    rm -f "$PROJECT_ROOT/email/processed"/*.eml
    echo "  ✓ Cleared email/processed/"
fi

echo ""

# Step 2: Reset aiDocs files from templates
echo -e "${BLUE}[2/4] Resetting aiDocs files to templates...${NC}"

if [ -f "$PROJECT_ROOT/.template/templates/SUMMARY.template.md" ]; then
    cp "$PROJECT_ROOT/.template/templates/SUMMARY.template.md" "$PROJECT_ROOT/aiDocs/SUMMARY.md"
    echo "  ✓ Reset aiDocs/SUMMARY.md"
else
    echo -e "  ${RED}✗ Template not found: .template/templates/SUMMARY.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/.template/templates/TASKS.template.md" ]; then
    cp "$PROJECT_ROOT/.template/templates/TASKS.template.md" "$PROJECT_ROOT/aiDocs/TASKS.md"
    echo "  ✓ Reset aiDocs/TASKS.md"
else
    echo -e "  ${RED}✗ Template not found: .template/templates/TASKS.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/.template/templates/DISCOVERY.template.md" ]; then
    cp "$PROJECT_ROOT/.template/templates/DISCOVERY.template.md" "$PROJECT_ROOT/aiDocs/DISCOVERY.md"
    echo "  ✓ Reset aiDocs/DISCOVERY.md"
else
    echo -e "  ${RED}✗ Template not found: .template/templates/DISCOVERY.template.md${NC}"
fi

if [ -f "$PROJECT_ROOT/.template/templates/AI.template.md" ]; then
    cp "$PROJECT_ROOT/.template/templates/AI.template.md" "$PROJECT_ROOT/aiDocs/AI.md"
    echo "  ✓ Reset aiDocs/AI.md"
else
    echo -e "  ${RED}✗ Template not found: .template/templates/AI.template.md${NC}"
fi

echo ""

# Step 3: Clear root SUMMARY.md if it exists
echo -e "${BLUE}[3/5] Clearing root SUMMARY.md...${NC}"

if [ -f "$PROJECT_ROOT/SUMMARY.md" ]; then
    rm -f "$PROJECT_ROOT/SUMMARY.md"
    echo "  ✓ Removed SUMMARY.md (will be regenerated on first /quickStartProject run)"
else
    echo "  ℹ SUMMARY.md does not exist (nothing to clear)"
fi

echo ""

# Step 4: Reset mcp.json to default state
echo -e "${BLUE}[4/5] Resetting MCP configuration...${NC}"

if [ -f "$PROJECT_ROOT/.vscode/mcp.json" ]; then
    echo '{"mcpServers": {}}' > "$PROJECT_ROOT/.vscode/mcp.json"
    echo "  ✓ Reset .vscode/mcp.json to default state"
else
    echo "  ℹ .vscode/mcp.json does not exist (nothing to reset)"
fi

echo ""

# Step 5: Verify reset
echo -e "${BLUE}[5/5] Verifying reset...${NC}"

# Check that templates exist
TEMPLATES_OK=true
if [ ! -f "$PROJECT_ROOT/.template/templates/SUMMARY.template.md" ]; then
    echo -e "  ${RED}✗ Missing template: SUMMARY.template.md${NC}"
    TEMPLATES_OK=false
fi
if [ ! -f "$PROJECT_ROOT/.template/templates/TASKS.template.md" ]; then
    echo -e "  ${RED}✗ Missing template: TASKS.template.md${NC}"
    TEMPLATES_OK=false
fi
if [ ! -f "$PROJECT_ROOT/.template/templates/DISCOVERY.template.md" ]; then
    echo -e "  ${RED}✗ Missing template: DISCOVERY.template.md${NC}"
    TEMPLATES_OK=false
fi
if [ ! -f "$PROJECT_ROOT/.template/templates/AI.template.md" ]; then
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
    echo -e "  ${RED}✗ email/raw/ is not empty (found $RAW_FILES file(s))${NC}"
    EMAIL_OK=false
fi
AI_FILES=$(find "$PROJECT_ROOT/email/ai" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$AI_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ email/ai/ is not empty (found $AI_FILES file(s))${NC}"
    EMAIL_OK=false
fi
PROCESSED_FILES=$(find "$PROJECT_ROOT/email/processed" -type f ! -name '.gitkeep' 2>/dev/null | wc -l | tr -d ' ')
if [ "$PROCESSED_FILES" -gt 0 ]; then
    echo -e "  ${RED}✗ email/processed/ is not empty (found $PROCESSED_FILES file(s))${NC}"
    EMAIL_OK=false
fi

# Check mcp.json is reset
MCP_OK=true
if [ -f "$PROJECT_ROOT/.vscode/mcp.json" ]; then
    MCP_CONTENT=$(cat "$PROJECT_ROOT/.vscode/mcp.json" | tr -d '[:space:]')
    if [ "$MCP_CONTENT" != '{"mcpServers":{}}' ]; then
        echo -e "  ${RED}✗ .vscode/mcp.json is not in default state${NC}"
        MCP_OK=false
    fi
fi

if [ "$TEMPLATES_OK" = true ] && [ "$AIDOCS_OK" = true ] && [ "$EMAIL_OK" = true ] && [ "$MCP_OK" = true ]; then
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
echo "  1. Run ./init.sh to configure your project"
echo "  2. Add email files to email/raw/ (if needed)"
echo "  3. Run /quickStartProject in GitHub Copilot"
echo ""
