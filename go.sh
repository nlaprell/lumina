#!/bin/bash

# go.sh - Interactive project management menu
# Provides easy access to common project operations

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Check if terminal supports colors
if [ -t 1 ] && command -v tput &> /dev/null; then
    NUM_COLORS=$(tput colors 2>/dev/null || echo 0)
    if [ "$NUM_COLORS" -ge 8 ]; then
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
else
    GREEN=''
    BLUE=''
    YELLOW=''
    RED=''
    NC=''
fi

# Get project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"

# Menu options
declare -a MENU_OPTIONS=(
    "Initialize Project"
    "Health Check"
    "Reset Project"
    "Backup Project State"
    "Restore from Backup"
    "List Backups"
    "Quit"
)

# Current selection index
CURRENT_INDEX=0

# Error handling function
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

# Cleanup function to restore cursor
cleanup() {
    tput cnorm 2>/dev/null || true
    clear
}

# Trap errors and cleanup
trap 'handle_error $? $LINENO' ERR
trap cleanup EXIT

# Hide cursor
tput civis 2>/dev/null || true

# Health check function
health_check() {
    echo -e "${BLUE}Running health check...${NC}"
    echo ""

    local errors=0
    local warnings=0

    # Check Python version
    if command -v python3 &> /dev/null; then
        py_version=$(python3 --version 2>&1 | awk '{print $2}')
        py_major=$(echo "$py_version" | cut -d. -f1)
        py_minor=$(echo "$py_version" | cut -d. -f2)

        if [ "$py_major" -ge 3 ] && [ "$py_minor" -ge 8 ]; then
            echo -e "${GREEN}✓${NC} Python ${py_version} installed"
        else
            echo -e "${YELLOW}⚠${NC} Python ${py_version} installed (recommend 3.8+)"
            ((warnings++))
        fi
    else
        echo -e "${RED}✗${NC} Python 3 not found"
        ((errors++))
    fi

    # Check required packages
    if python3 -c "import html2text" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} html2text package installed"
    else
        echo -e "${YELLOW}⚠${NC} html2text not installed (run: pip install -r core/aiScripts/requirements.txt)"
        ((warnings++))
    fi

    # Check Git
    if command -v git &> /dev/null; then
        git_version=$(git --version 2>&1 | awk '{print $3}')
        echo -e "${GREEN}✓${NC} Git ${git_version} installed"
    else
        echo -e "${RED}✗${NC} Git not found"
        ((errors++))
    fi

    # Check directory structure
    for dir in "core/templates" "email/raw" "email/ai" "email/processed" "aiDocs" "prompts"; do
        if [ -d "$dir" ]; then
            echo -e "${GREEN}✓${NC} Directory exists: $dir"
        else
            echo -e "${RED}✗${NC} Missing directory: $dir"
            ((errors++))
        fi
    done

    # Check critical files
    for file in ".github/copilot-instructions.md" "aiDocs/SUMMARY.md" "aiDocs/TASKS.md" "aiDocs/DISCOVERY.md" "aiDocs/AI.md"; do
        if [ -f "$file" ]; then
            echo -e "${GREEN}✓${NC} File exists: $file"
        else
            echo -e "${RED}✗${NC} Missing file: $file"
            ((errors++))
        fi
    done

    # Check git hooks
    if [ -L ".git/hooks/pre-commit" ]; then
        echo -e "${GREEN}✓${NC} Pre-commit hook installed"
    else
        echo -e "${YELLOW}⚠${NC} Pre-commit hook not installed (optional - run core/scripts/install-hooks.sh)"
        ((warnings++))
    fi

    # Check if project initialized
    if [ -f ".vscode/mcp.json" ]; then
        echo -e "${GREEN}✓${NC} Project initialized (.vscode/mcp.json exists)"
    else
        echo -e "${YELLOW}⚠${NC} Project not initialized yet (run 'Initialize Project')"
        ((warnings++))
    fi

    # Summary
    echo ""
    echo "───────────────────────────────"
    if [ $errors -eq 0 ] && [ $warnings -eq 0 ]; then
        echo -e "${GREEN}System health: EXCELLENT${NC}"
        echo "All checks passed! System is ready to use."
    elif [ $errors -eq 0 ]; then
        echo -e "${YELLOW}System health: GOOD (${warnings} warning(s))${NC}"
        echo "System is functional but some optional components are missing."
    else
        echo -e "${RED}System health: ISSUES FOUND (${errors} error(s), ${warnings} warning(s))${NC}"
        echo "Please resolve errors before using the system."
    fi
    echo ""
}

# Function to display menu
display_menu() {
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Lumina - Project Manager${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""

    # Display project state
    display_state

    echo "Use arrow keys to navigate, Enter or Space to select:"
    echo ""

    local index=0
    for option in "${MENU_OPTIONS[@]}"; do
        if [ $index -eq $CURRENT_INDEX ]; then
            echo -e "${GREEN}→ $option${NC}"
        else
            echo "  $option"
        fi
        ((index++))
    done
    echo ""
}

# Function to display project state
display_state() {
    # Call Python state_manager to display state
    python3 "$PROJECT_ROOT/core/aiScripts/state_manager.py" 2>/dev/null || {
        echo -e "${YELLOW}📊 Project Status: Unable to check${NC}"
        echo ""
    }
}

# Backup function
backup_project() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$PROJECT_ROOT/backups/backup_${timestamp}"
    
    echo -e "${BLUE}Creating backup...${NC}"
    echo ""
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Backup aiDocs/
    if [ -d "$PROJECT_ROOT/aiDocs" ]; then
        cp -r "$PROJECT_ROOT/aiDocs" "$backup_dir/"
        echo -e "${GREEN}✓${NC} Backed up aiDocs/"
    else
        echo -e "${YELLOW}⚠${NC} aiDocs/ not found (skipped)"
    fi
    
    # Backup PROJECT.md
    if [ -f "$PROJECT_ROOT/PROJECT.md" ]; then
        cp "$PROJECT_ROOT/PROJECT.md" "$backup_dir/"
        echo -e "${GREEN}✓${NC} Backed up PROJECT.md"
    else
        echo -e "${YELLOW}⚠${NC} PROJECT.md not found (skipped)"
    fi
    
    # Backup .lumina.state
    if [ -f "$PROJECT_ROOT/.lumina.state" ]; then
        cp "$PROJECT_ROOT/.lumina.state" "$backup_dir/"
        echo -e "${GREEN}✓${NC} Backed up .lumina.state"
    else
        echo -e "${YELLOW}⚠${NC} .lumina.state not found (skipped)"
    fi
    
    # Backup docs/
    if [ -d "$PROJECT_ROOT/docs" ]; then
        cp -r "$PROJECT_ROOT/docs" "$backup_dir/"
        echo -e "${GREEN}✓${NC} Backed up docs/"
    else
        echo -e "${YELLOW}⚠${NC} docs/ not found (skipped)"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Backup created: backups/backup_${timestamp}${NC}"
}

# List backups function
list_backups() {
    local backups_dir="$PROJECT_ROOT/backups"
    
    if [ ! -d "$backups_dir" ] || [ -z "$(ls -A "$backups_dir" 2>/dev/null)" ]; then
        echo -e "${YELLOW}No backups found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Available backups:${NC}"
    echo ""
    
    local index=1
    for backup in "$backups_dir"/backup_*; do
        if [ -d "$backup" ]; then
            local backup_name=$(basename "$backup")
            local backup_date=${backup_name#backup_}
            # Format: YYYYMMDD_HHMMSS -> YYYY-MM-DD HH:MM:SS
            local formatted_date=$(echo "$backup_date" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
            echo -e "  ${GREEN}$index.${NC} $formatted_date  (${backup_name})"
            ((index++))
        fi
    done
    
    return 0
}

# Restore function
restore_project() {
    local backups_dir="$PROJECT_ROOT/backups"
    
    if ! list_backups; then
        return 1
    fi
    
    echo ""
    read -p "Enter backup number to restore (or 'c' to cancel): " choice
    
    if [[ "$choice" == "c" ]] || [[ "$choice" == "C" ]]; then
        echo -e "${YELLOW}Restore cancelled${NC}"
        return 0
    fi
    
    # Validate choice is a number
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid choice${NC}"
        return 1
    fi
    
    # Get selected backup
    local index=1
    local selected_backup=""
    for backup in "$backups_dir"/backup_*; do
        if [ -d "$backup" ]; then
            if [ "$index" -eq "$choice" ]; then
                selected_backup="$backup"
                break
            fi
            ((index++))
        fi
    done
    
    if [ -z "$selected_backup" ]; then
        echo -e "${RED}Invalid backup number${NC}"
        return 1
    fi
    
    local backup_name=$(basename "$selected_backup")
    echo ""
    echo -e "${YELLOW}WARNING: This will overwrite your current project state!${NC}"
    echo -e "Restoring from: ${backup_name}"
    echo ""
    read -p "Are you sure? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        echo -e "${YELLOW}Restore cancelled${NC}"
        return 0
    fi
    
    echo ""
    echo -e "${BLUE}Restoring from backup...${NC}"
    echo ""
    
    # Restore aiDocs/
    if [ -d "$selected_backup/aiDocs" ]; then
        rm -rf "$PROJECT_ROOT/aiDocs"
        cp -r "$selected_backup/aiDocs" "$PROJECT_ROOT/"
        echo -e "${GREEN}✓${NC} Restored aiDocs/"
    fi
    
    # Restore PROJECT.md
    if [ -f "$selected_backup/PROJECT.md" ]; then
        cp "$selected_backup/PROJECT.md" "$PROJECT_ROOT/"
        echo -e "${GREEN}✓${NC} Restored PROJECT.md"
    fi
    
    # Restore .lumina.state
    if [ -f "$selected_backup/.lumina.state" ]; then
        cp "$selected_backup/.lumina.state" "$PROJECT_ROOT/"
        echo -e "${GREEN}✓${NC} Restored .lumina.state"
    fi
    
    # Restore docs/
    if [ -d "$selected_backup/docs" ]; then
        rm -rf "$PROJECT_ROOT/docs"
        cp -r "$selected_backup/docs" "$PROJECT_ROOT/"
        echo -e "${GREEN}✓${NC} Restored docs/"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Restore completed successfully${NC}"
}

# Function to execute selected option
execute_option() {
    local option="${MENU_OPTIONS[$CURRENT_INDEX]}"

    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Executing: $option${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""

    case "$option" in
        "Initialize Project")
            if [ -f "$PROJECT_ROOT/core/scripts/init.sh" ]; then
                "$PROJECT_ROOT/core/scripts/init.sh"
                local exit_code=$?
                echo ""
                if [ "$exit_code" -ne 0 ]; then
                    echo -e "${RED}Error: Initialize script failed with exit code "$exit_code"${NC}"
                else
                    echo -e "${GREEN}Initialize completed successfully${NC}"
                fi
            else
                echo -e "${RED}Error: init.sh not found at "$PROJECT_ROOT"/core/scripts/init.sh${NC}"
            fi
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "Health Check")
            health_check
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "Backup Project State")
            backup_project
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "Restore from Backup")
            restore_project
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "List Backups")
            list_backups
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "Reset Project")
            if [ -f "$PROJECT_ROOT/core/scripts/clean-reset.sh" ]; then
                "$PROJECT_ROOT/core/scripts/clean-reset.sh"
                local exit_code=$?
                echo ""
                if [ "$exit_code" -ne 0 ]; then
                    echo -e "${RED}Error: Reset script failed with exit code "$exit_code"${NC}"
                else
                    echo -e "${GREEN}Reset completed successfully${NC}"
                fi
            else
                echo -e "${RED}Error: clean-reset.sh not found at "$PROJECT_ROOT"/core/scripts/clean-reset.sh${NC}"
            fi
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "Quit")
            clear
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
    esac
}

# Main loop
while true; do
    display_menu

    # Read input
    read -rsn1 key

    # Handle escape sequences (arrow keys)
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            '[A')  # Up arrow
                ((CURRENT_INDEX--))
                if [ $CURRENT_INDEX -lt 0 ]; then
                    CURRENT_INDEX=$((${#MENU_OPTIONS[@]} - 1))
                fi
                ;;
            '[B')  # Down arrow
                ((CURRENT_INDEX++))
                if [ $CURRENT_INDEX -ge ${#MENU_OPTIONS[@]} ]; then
                    CURRENT_INDEX=0
                fi
                ;;
        esac
    elif [[ $key == "" ]]; then
        # Enter key
        execute_option
    elif [[ $key == " " ]]; then
        # Space key
        execute_option
    elif [[ $key == "q" ]] || [[ $key == "Q" ]]; then
        # Quick quit
        clear
        echo -e "${GREEN}Goodbye!${NC}"
        exit 0
    fi
done
