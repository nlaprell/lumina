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

# Prompt for project name, customer name, and user name
prompt_project_name() {
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Project Setup${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Welcome to Lumina setup!"
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
}

# Main interactive loop
interactive_menu() {
    # First, prompt for project name
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
