#!/bin/bash

# init.sh - Interactive MCP Server Configuration and Project Setup
# This script allows users to configure their project name and select MCP servers

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Color codes for better UI
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

    # Clear any temp files if needed
    if [ -n "${TEMP_FILE:-}" ] && [ -f "$TEMP_FILE" ]; then
        rm -f "$TEMP_FILE"
    fi
}

# Load .env file if it exists
load_env_file() {
    local env_file="$PROJECT_ROOT/.env"

    if [ ! -f "$env_file" ]; then
        echo -e "${YELLOW}NOTE: No .env file found${NC}" >&2
        echo "  Create .env from .env.template to automatically populate credentials" >&2
        echo "  For now, placeholders will be left as-is in mcp.json" >&2
        return 0
    fi

    echo -e "${GREEN}✓${NC} Loading credentials from .env"

    # Export variables from .env file
    set -a  # Automatically export all variables
    # Source with error handling
    if ! source "$env_file" 2>/dev/null; then
        echo -e "${RED}ERROR: Failed to load .env file${NC}" >&2
        echo "  Check .env file syntax" >&2
        return 1
    fi
    set +a

    return 0
}

# Substitute environment variables in JSON
substitute_env_vars() {
    local json="$1"

    # Replace ${VAR_NAME} with actual environment variable values
    # Use Python for reliable JSON processing
    echo "$json" | python3 -c "
import json
import os
import re
import sys

def replace_env_vars(obj):
    if isinstance(obj, dict):
        return {k: replace_env_vars(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [replace_env_vars(item) for item in obj]
    elif isinstance(obj, str):
        # Replace \${VAR_NAME} with environment variable value
        def replacer(match):
            var_name = match.group(1)
            return os.environ.get(var_name, match.group(0))
        return re.sub(r'\\\$\\{([A-Z_][A-Z0-9_]*)\\}', replacer, obj)
    else:
        return obj

try:
    data = json.load(sys.stdin)
    result = replace_env_vars(data)
    print(json.dumps(result, indent=2))
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"
}

# Check for unsubstituted placeholders
check_placeholders() {
    local config="$1"

    if echo "$config" | grep -q '\${[A-Z_][A-Z0-9_]*}'; then
        echo -e "${YELLOW}WARNING: Configuration contains unsubstituted placeholders${NC}" >&2
        echo "  Some MCP servers may not work without credentials" >&2
        echo "  Create .env file from .env.template to provide credentials" >&2
        return 1
    fi
    return 0
}

# Trap errors and cleanup
trap 'handle_error $? $LINENO' ERR
trap 'cleanup' EXIT

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
MCP_SERVERS_DIR="$SCRIPT_DIR/../mcpServers"
VSCODE_DIR="$PROJECT_ROOT/.vscode"
MCP_CONFIG="$VSCODE_DIR/mcp.json"

# Project configuration
PROJECT_NAME=""
CUSTOMER_NAME=""
USER_NAME=""

# Array to store MCP server files and their selected state
declare -a MCP_FILES
declare -a MCP_SELECTED
declare -a MCP_NAMES

# Current selection index
CURRENT_INDEX=0

# Validate required commands
for cmd in python3 tput; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}Error: Required command '$cmd' not found${NC}" >&2
        echo -e "${YELLOW}Please install $cmd and try again${NC}" >&2
        exit 1
    fi
done

# Check and install dependencies
check_dependencies() {
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Dependency Check${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""

    local deps_installed=true

    # Check Python version
    echo -e "${YELLOW}Checking Python...${NC}"
    if command -v python3 &> /dev/null; then
        py_version=$(python3 --version 2>&1 | awk '{print $2}')
        py_major=$(echo "$py_version" | cut -d. -f1)
        py_minor=$(echo "$py_version" | cut -d. -f2)

        if [ "$py_major" -ge 3 ] && [ "$py_minor" -ge 8 ]; then
            echo -e "${GREEN}✓${NC} Python ${py_version} installed"
        else
            echo -e "${YELLOW}⚠${NC} Python ${py_version} installed (recommend 3.8+)"
        fi
    fi
    echo ""

    # Check Python packages
    echo -e "${YELLOW}Checking Python packages...${NC}"
    if python3 -c "import html2text" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} html2text package installed"
    else
        echo -e "${RED}✗${NC} html2text package not found"
        deps_installed=false
    fi
    echo ""

    # Check Node.js/npx
    echo -e "${YELLOW}Checking Node.js/npx...${NC}"
    if command -v node &> /dev/null; then
        node_version=$(node --version 2>&1)
        echo -e "${GREEN}✓${NC} Node.js ${node_version} installed"
    else
        echo -e "${YELLOW}⚠${NC} Node.js not found (required for MCP servers)"
    fi

    if command -v npx &> /dev/null; then
        echo -e "${GREEN}✓${NC} npx available"
    else
        echo -e "${YELLOW}⚠${NC} npx not found (required for MCP servers)"
    fi
    echo ""

    # Offer to install missing Python packages
    if [ "$deps_installed" = false ]; then
        echo -e "${YELLOW}Some Python dependencies are missing.${NC}"
        echo ""
        read -p "Install Python dependencies now? (y/n): " install_choice

        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${BLUE}Installing Python dependencies...${NC}"

            if python3 -m pip install -r "$PROJECT_ROOT/core/aiScripts/requirements.txt" 2>&1 | tee /tmp/pip_install.log; then
                echo ""
                echo -e "${GREEN}✓${NC} Python dependencies installed successfully"

                # Verify installation
                if python3 -c "import html2text" 2>/dev/null; then
                    deps_installed=true
                else
                    echo -e "${YELLOW}⚠${NC} Package installed but import failed"
                    deps_installed=false
                fi
            else
                echo ""
                echo -e "${RED}✗${NC} Failed to install Python dependencies"
                echo -e "${YELLOW}Error log:${NC}"
                cat /tmp/pip_install.log
                echo ""
                echo -e "${YELLOW}You can install manually with:${NC}"
                echo -e "  ${GREEN}python3 -m pip install -r core/aiScripts/requirements.txt${NC}"
                echo ""
                read -p "Press Enter to continue anyway..."
            fi
        else
            echo ""
            echo -e "${YELLOW}Skipping dependency installation.${NC}"
            echo -e "${YELLOW}Install manually with:${NC}"
            echo -e "  ${GREEN}python3 -m pip install -r core/aiScripts/requirements.txt${NC}"
            echo ""
            read -p "Press Enter to continue..."
        fi
    else
        echo -e "${GREEN}✓${NC} All dependencies are installed"
        echo ""
        read -p "Press Enter to continue..."
    fi

    return 0
}

# Check PDF export dependencies (Pandoc + LaTeX)
check_pdf_dependencies() {
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    PDF Export Dependencies (Optional)${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""
    echo "PDF export allows you to package complete documentation"
    echo "for consultant handoffs and stakeholder reports."
    echo ""
    echo "This requires Pandoc and LaTeX (optional but recommended)."
    echo ""

    local pandoc_installed=false
    local latex_installed=false

    # Check for Pandoc
    echo -e "${YELLOW}Checking Pandoc...${NC}"
    if command -v pandoc &> /dev/null; then
        pandoc_version=$(pandoc --version 2>&1 | head -1)
        echo -e "${GREEN}✓${NC} ${pandoc_version}"
        pandoc_installed=true
    else
        echo -e "${RED}✗${NC} Pandoc not found"
    fi

    # Check for XeLaTeX
    echo -e "${YELLOW}Checking XeLaTeX...${NC}"
    if command -v xelatex &> /dev/null; then
        echo -e "${GREEN}✓${NC} XeLaTeX installed"
        latex_installed=true
    else
        echo -e "${RED}✗${NC} XeLaTeX not found"
    fi
    echo ""

    # If both are installed, we're done
    if [ "$pandoc_installed" = true ] && [ "$latex_installed" = true ]; then
        echo -e "${GREEN}✓ PDF export is ready to use!${NC}"
        echo ""
        read -p "Press Enter to continue..."
        return 0
    fi

    # Offer to install missing dependencies
    echo -e "${YELLOW}PDF export dependencies are missing.${NC}"
    echo ""
    echo "Would you like to install them now?"
    echo ""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${BLUE}macOS Installation:${NC}"
        if [ "$pandoc_installed" = false ]; then
            echo "  • Pandoc: brew install pandoc"
        fi
        if [ "$latex_installed" = false ]; then
            echo "  • LaTeX: brew install --cask basictex"
            echo "    Then: sudo tlmgr update --self"
            echo "          sudo tlmgr install collection-fontsrecommended collection-xetex"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${BLUE}Linux Installation:${NC}"
        echo "  sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended"
    fi
    echo ""
    echo -e "${YELLOW}Note: Installation may take 5-10 minutes${NC}"
    echo ""

    read -p "Install PDF export dependencies? (y/n): " install_pdf

    if [[ "$install_pdf" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${BLUE}Installing PDF export dependencies...${NC}"
        echo ""

        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS installation
            if [ "$pandoc_installed" = false ]; then
                echo -e "${YELLOW}Installing Pandoc...${NC}"
                if brew install pandoc 2>&1 | tee /tmp/pandoc_install.log; then
                    echo -e "${GREEN}✓${NC} Pandoc installed"
                    pandoc_installed=true
                else
                    echo -e "${RED}✗${NC} Pandoc installation failed"
                    echo "Check /tmp/pandoc_install.log for details"
                fi
                echo ""
            fi

            if [ "$latex_installed" = false ]; then
                echo -e "${YELLOW}Installing BasicTeX (this may take a few minutes)...${NC}"
                if brew install --cask basictex 2>&1 | tee /tmp/latex_install.log; then
                    echo -e "${GREEN}✓${NC} BasicTeX installed"
                    echo ""
                    echo -e "${YELLOW}Updating LaTeX packages...${NC}"

                    # Add TeX to PATH for this session
                    export PATH="/Library/TeX/texbin:$PATH"

                    # Update tlmgr and install required packages
                    if sudo tlmgr update --self && \
                       sudo tlmgr install collection-fontsrecommended collection-xetex tocloft titlesec enumitem lastpage amsfonts amsmath; then
                        echo -e "${GREEN}✓${NC} LaTeX packages installed"
                        latex_installed=true
                    else
                        echo -e "${YELLOW}⚠${NC} LaTeX package installation had issues"
                        echo "You may need to run manually:"
                        echo "  export PATH=\"/Library/TeX/texbin:\$PATH\""
                        echo "  sudo tlmgr update --self"
                        echo "  sudo tlmgr install collection-fontsrecommended collection-xetex tocloft titlesec enumitem lastpage amsfonts amsmath"
                    fi
                else
                    echo -e "${RED}✗${NC} BasicTeX installation failed"
                    echo "Check /tmp/latex_install.log for details"
                fi
                echo ""
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux installation
            echo -e "${YELLOW}Installing Pandoc and LaTeX...${NC}"
            if sudo apt-get update && \
               sudo apt-get install -y pandoc texlive-xetex texlive-fonts-recommended 2>&1 | tee /tmp/pdf_install.log; then
                echo -e "${GREEN}✓${NC} PDF dependencies installed"
                pandoc_installed=true
                latex_installed=true
            else
                echo -e "${RED}✗${NC} Installation failed"
                echo "Check /tmp/pdf_install.log for details"
            fi
            echo ""
        fi

        # Verify installation
        if [ "$pandoc_installed" = true ] && [ "$latex_installed" = true ]; then
            echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
            echo -e "${GREEN}✓ PDF export is now ready to use!${NC}"
            echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
            echo ""
            echo "Try it: ./go.sh → 'Export to PDF'"
        else
            echo -e "${YELLOW}════════════════════════════════════════════════════${NC}"
            echo -e "${YELLOW}⚠ PDF export dependencies not fully installed${NC}"
            echo -e "${YELLOW}════════════════════════════════════════════════════${NC}"
            echo ""
            echo "You can install manually later or use Lumina without PDF export."
        fi
    else
        echo ""
        echo -e "${YELLOW}Skipping PDF export dependencies.${NC}"
        echo ""
        echo "You can install them later with:"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "  ${GREEN}brew install pandoc${NC}"
            echo -e "  ${GREEN}brew install --cask basictex${NC}"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo -e "  ${GREEN}sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended${NC}"
        fi
        echo ""
        echo "Lumina will work without PDF export (it's optional)."
    fi

    echo ""
    read -p "Press Enter to continue..."
    return 0
}

# Prompt for project name, customer name, and user name
prompt_project_name() {
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Project Setup${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Welcome to Lumina setup!"
    echo ""

    # Load environment variables early
    load_env_file
    echo ""
    echo -e "${YELLOW}What is your name?${NC}"
    echo ""
    read -p "Your name: " USER_NAME

    # Validate user name
    if [ -z "$USER_NAME" ]; then
        echo -e "${RED}Error: User name cannot be empty${NC}"
        sleep 2
        prompt_project_name
        return
    fi

    echo ""
    echo -e "${YELLOW}What is the name of your project?${NC}"
    echo ""
    read -p "Project name: " PROJECT_NAME

    # Validate project name
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}Error: Project name cannot be empty${NC}"
        sleep 2
        prompt_project_name
        return
    fi

    echo ""
    echo -e "${YELLOW}What is the customer/client name?${NC}"
    echo ""
    read -p "Customer name: " CUSTOMER_NAME

    # Validate customer name
    if [ -z "$CUSTOMER_NAME" ]; then
        echo -e "${RED}Error: Customer name cannot be empty${NC}"
        sleep 2
        prompt_project_name
        return
    fi

    # Confirm settings
    echo ""
    echo -e "Your name: ${GREEN}$USER_NAME${NC}"
    echo -e "Project name: ${GREEN}$PROJECT_NAME${NC}"
    echo -e "Customer name: ${GREEN}$CUSTOMER_NAME${NC}"
    echo ""
    read -p "Press Enter to continue to MCP server configuration..."
}

# Load MCP server configurations
load_mcp_configs() {
    local index=0

    if [ ! -d "$MCP_SERVERS_DIR" ]; then
        echo "Error: mcpServers directory not found at $MCP_SERVERS_DIR"
        exit 1
    fi

    for file in "$MCP_SERVERS_DIR"/*.json; do
        if [ -f "$file" ]; then
            MCP_FILES[$index]="$file"
            MCP_SELECTED[$index]=0
            MCP_NAMES[$index]=$(basename "$file" .json)
            ((index++))
        fi
    done

    if [ ${#MCP_FILES[@]} -eq 0 ]; then
        echo "Error: No MCP server configurations found in $MCP_SERVERS_DIR"
        exit 1
    fi
}

# Display the menu
display_menu() {
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    MCP Server Configuration${NC}"
    echo -e "${BLUE}    Project: ${GREEN}$PROJECT_NAME${BLUE}${NC}"
    echo -e "${BLUE}    Customer: ${GREEN}$CUSTOMER_NAME${BLUE}${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Use ↑/↓ arrow keys to navigate, SPACE to toggle, ENTER to confirm"
    echo ""

    for i in "${!MCP_FILES[@]}"; do
        local checkbox="[ ]"
        if [ ${MCP_SELECTED[$i]} -eq 1 ]; then
            checkbox="[✓]"
        fi

        if [ $i -eq $CURRENT_INDEX ]; then
            echo -e "${GREEN}→ $checkbox ${MCP_NAMES[$i]}${NC}"
        else
            echo "  $checkbox ${MCP_NAMES[$i]}"
        fi
    done

    echo ""
    if [ $CURRENT_INDEX -eq ${#MCP_FILES[@]} ]; then
        echo -e "${GREEN}→ [Confirm Selection]${NC}"
    else
        echo "  [Confirm Selection]"
    fi
}

# Validate MCP configuration file
validate_mcp_config() {
    local file="$1"
    local filename=$(basename "$file")

    # Check if valid JSON
    if ! python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
        echo -e "${RED}ERROR: Invalid JSON in $filename${NC}" >&2
        return 1
    fi

    # Check for required "servers" key (or legacy "mcpServers")
    if ! python3 -c "
import json
import sys
with open('$file') as f:
    config = json.load(f)
if 'servers' not in config and 'mcpServers' not in config:
    sys.exit(1)
" 2>/dev/null; then
        echo -e "${YELLOW}WARNING: $filename missing 'servers' or 'mcpServers' key - skipping${NC}" >&2
        return 1
    fi

    # Check that servers object is not empty
    local server_count=$(python3 -c "
import json
with open('$file') as f:
    config = json.load(f)
servers = config.get('servers', config.get('mcpServers', {}))
print(len(servers))
" 2>/dev/null)

    if [ "$server_count" -eq 0 ]; then
        echo -e "${YELLOW}WARNING: $filename has empty servers object - skipping${NC}" >&2
        return 1
    fi

    return 0
}

# Merge MCP configurations
merge_configs() {
    # Create .vscode directory if it doesn't exist
    mkdir -p "$VSCODE_DIR"

    # Start with empty servers object
    local merged_json='{"servers":{}}'

    local configured_servers=()
    local validated_servers=()
    local skipped_servers=()

    for i in "${!MCP_FILES[@]}"; do
        if [ ${MCP_SELECTED[$i]} -eq 1 ]; then
            local file="${MCP_FILES[$i]}"
            local server_name="${MCP_NAMES[$i]}"

            configured_servers+=("$server_name")

            # Validate before merging
            if ! validate_mcp_config "$file"; then
                skipped_servers+=("$server_name")
                continue
            fi

            validated_servers+=("$server_name")

            # Use Python to merge JSON - pass current state via stdin to avoid quoting issues
            merged_json=$(echo "$merged_json" | python3 -c "
import json
import sys

# Read current merged config from stdin
merged = json.load(sys.stdin)

# Read new config file
with open('$file', 'r') as f:
    new_config = json.load(f)

# Merge configurations
if 'servers' in new_config:
    for key, value in new_config['servers'].items():
        merged['servers'][key] = value
elif 'mcpServers' in new_config:
    for key, value in new_config['mcpServers'].items():
        merged['servers'][key] = value

# Output merged config
print(json.dumps(merged, indent=2))
")
        fi
    done

    # Apply environment variable substitution
    merged_json=$(substitute_env_vars "$merged_json")

    # Check for unsubstituted placeholders
    check_placeholders "$merged_json"

    # Write the merged configuration to mcp.json
    echo "$merged_json" > "$MCP_CONFIG"

    # Display results
    clear
    echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}    Configuration Complete!${NC}"
    echo -e "${GREEN}    Project: $PROJECT_NAME${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Validation Summary:${NC}"
    echo "  Selected: ${#configured_servers[@]} servers"
    echo "  Validated: ${#validated_servers[@]} servers"
    if [ ${#skipped_servers[@]} -gt 0 ]; then
        echo -e "  ${YELLOW}Skipped: ${#skipped_servers[@]} servers (validation failed)${NC}"
        for server in "${skipped_servers[@]}"; do
            echo -e "    ${YELLOW}✗${NC} $server"
        done
    fi
    echo ""

    if [ ${#validated_servers[@]} -eq 0 ]; then
        echo -e "${YELLOW}No MCP servers were successfully validated and configured.${NC}"
        echo "The .vscode/mcp.json file has been created with an empty configuration."
    else
        echo "The following MCP servers have been configured in .vscode/mcp.json:"
        echo ""
        for server in "${validated_servers[@]}"; do
            echo -e "  ${GREEN}✓${NC} $server"
        done
    fi

    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Next Steps${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}1. Extract project-relevant email threads (.eml files)${NC}"
    echo -e "   Save them to: ${GREEN}./email/raw${NC}"
    echo ""
    echo -e "${YELLOW}2. Run the quickstart workflow in Copilot chat:${NC}"
    echo -e "   ${GREEN}/quickStartProject${NC}"
    echo ""
    echo "This will automatically:"
    echo "  • Initialize the AI assistant with project context"
    echo "  • Convert emails to Markdown"
    echo "  • Extract information and update aiDocs/"
    echo "  • Generate a comprehensive project summary"
    echo ""
    echo -e "${BLUE}Or run steps individually if preferred:${NC}"
    echo -e "   ${YELLOW}/projectInit${NC} → ${YELLOW}/discoverEmail${NC} → ${YELLOW}/updateSummary${NC}"
    echo ""

    # Create state file
    create_state_file
}

# Create the .lumina.state file
create_state_file() {
    echo -e "${BLUE}Creating project state file...${NC}"

    # Check if Python dependencies are installed
    local deps_installed="False"
    if python3 -c "import html2text" 2>/dev/null; then
        deps_installed="True"
    fi

    cd "$PROJECT_ROOT" && python3 -c "
import sys
sys.path.insert(0, 'core/aiScripts')
from state_manager import create_state_file

create_state_file(
    project_name='${PROJECT_NAME}',
    customer_name='${CUSTOMER_NAME}',
    your_name='${USER_NAME}',
    git_hooks_installed=False,
    dependencies_installed=${deps_installed},
    directories_created=True,
    mcp_configured=True
)
print('✓ State file created')
" || {
        echo -e "${YELLOW}⚠ Warning: Could not create state file${NC}"
        return 1
    }
}

# Main interactive loop
interactive_menu() {
    # First, check dependencies (skip if already installed per state file)
    if [ -f "$PROJECT_ROOT/.lumina.state" ]; then
        deps_status=$(python3 -c "
import json
try:
    with open('.lumina.state') as f:
        state = json.load(f)
    print(state.get('health', {}).get('dependencies_installed', False))
except:
    print('False')
" 2>/dev/null)

        if [ "$deps_status" != "True" ]; then
            check_dependencies
        fi
    else
        check_dependencies
    fi

    # Check PDF export dependencies (optional feature)
    check_pdf_dependencies

    # Then, prompt for project name
    prompt_project_name

    # Then load MCP configs
    load_mcp_configs

    # Add one more item for "Confirm Selection"
    local max_index=${#MCP_FILES[@]}

    while true; do
        display_menu

        # Read a single key
        read -rsn1 key

        # Handle special keys (arrow keys are multi-byte)
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key  # Read the rest of the escape sequence
        fi

        case $key in
            '[A')  # Up arrow
                if [ $CURRENT_INDEX -gt 0 ]; then
                    ((CURRENT_INDEX--))
                fi
                ;;
            '[B')  # Down arrow
                if [ $CURRENT_INDEX -lt $max_index ]; then
                    ((CURRENT_INDEX++))
                fi
                ;;
            ' ')   # Space - toggle selection
                if [ $CURRENT_INDEX -lt $max_index ]; then
                    if [ ${MCP_SELECTED[$CURRENT_INDEX]} -eq 0 ]; then
                        MCP_SELECTED[$CURRENT_INDEX]=1
                    else
                        MCP_SELECTED[$CURRENT_INDEX]=0
                    fi
                fi
                ;;
            '')    # Enter - confirm or toggle
                if [ $CURRENT_INDEX -eq $max_index ]; then
                    # Confirm selection
                    merge_configs
                    break
                else
                    # Toggle selection
                    if [ ${MCP_SELECTED[$CURRENT_INDEX]} -eq 0 ]; then
                        MCP_SELECTED[$CURRENT_INDEX]=1
                    else
                        MCP_SELECTED[$CURRENT_INDEX]=0
                    fi
                fi
                ;;
            'q'|'Q')  # Quit
                clear
                echo "Configuration cancelled."
                exit 0
                ;;
        esac
    done
}

# Run the interactive menu
interactive_menu
