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
    "Process Emails"
    "Process Notes"
    "Reset Project"
    "Backup Project State"
    "Restore from Backup"
    "List Backups"
    "Lumina Prompts"
    "Export to PDF"
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

# Process emails function
process_emails() {
    echo -e "${BLUE}Processing emails...${NC}"
    echo ""

    # Check if email converter exists
    if [ ! -f "$PROJECT_ROOT/core/aiScripts/emailToMd/eml_to_md_converter.py" ]; then
        echo -e "${RED}Error: Email converter not found${NC}"
        return 1
    fi

    # Check if email/raw/ has files
    local email_count=$(find "$PROJECT_ROOT/email/raw" -type f -name "*.eml" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$email_count" -eq 0 ]; then
        echo -e "${YELLOW}No .eml files found in email/raw/${NC}"
        echo ""
        echo "To process emails:"
        echo "  1. Export emails from your email client as .eml files"
        echo "  2. Place them in email/raw/"
        echo "  3. Run this option again"
        return 0
    fi

    echo -e "Found ${GREEN}$email_count${NC} email file(s)"
    echo ""

    # Run the converter
    python3 "$PROJECT_ROOT/core/aiScripts/emailToMd/eml_to_md_converter.py"
    local exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Email processing completed${NC}"
        echo ""
        echo "Next steps:"
        echo "  - Converted emails are in email/ai/"
        echo "  - Original emails moved to email/processed/"
        echo "  - Use GitHub Copilot: /discoverEmail to extract information"
    else
        echo -e "${RED}✗ Email processing failed${NC}"
    fi
}

# Show available prompts function
show_prompts() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}                    Available Lumina Prompts${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Core Workflow Prompts:${NC}"
    echo "  /projectInit           Initialize AI with project context"
    echo "  /quickStartProject     Complete workflow: init → process → generate docs"
    echo "  /discoverEmail         Process emails and update documentation"
    echo "  /discoverNotes         Process notes and update documentation"
    echo "  /updateSummary         Regenerate PROJECT.md and docs/ from aiDocs/"
    echo ""
    echo -e "${GREEN}Maintenance & Quality:${NC}"
    echo "  /validateTasks         Check task structure and dependencies"
    echo "  /cleanupTasks          Archive old tasks, optimize organization"
    echo "  /syncFromProject       Sync user edits from PROJECT.md to aiDocs/"
    echo ""
    echo -e "${GREEN}Reporting & Analysis:${NC}"
    echo "  /generateReport        Create executive status report"
    echo ""
    echo -e "${GREEN}Testing & Development:${NC}"
    echo "  /initSampleProject     Test workflow with sample data (4 emails + 3 notes)"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC} In GitHub Copilot chat, type the prompt name (e.g., /quickStartProject)"
    echo ""
    read -p "Press Enter to continue..."
}

# Process notes function
process_notes() {
    echo -e "${BLUE}Processing notes...${NC}"
    echo ""

    # Check if notes converter exists
    if [ ! -f "$PROJECT_ROOT/core/aiScripts/notesToMd/notes_to_md_converter.py" ]; then
        echo -e "${RED}Error: Notes converter not found${NC}"
        return 1
    fi

    # Check if notes/raw/ has files
    local notes_count=$(find "$PROJECT_ROOT/notes/raw" -type f \( -name "*.txt" -o -name "*.md" \) ! -name ".gitkeep" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$notes_count" -eq 0 ]; then
        echo -e "${YELLOW}No .txt or .md files found in notes/raw/${NC}"
        echo ""
        echo "To process notes:"
        echo "  1. Export notes from OneNote, Apple Notes, etc."
        echo "  2. Save as .txt or .md files"
        echo "  3. Place them in notes/raw/"
        echo "  4. Run this option again"
        return 0
    fi

    echo -e "Found ${GREEN}$notes_count${NC} note file(s)"
    echo ""

    # Run the converter
    python3 "$PROJECT_ROOT/core/aiScripts/notesToMd/notes_to_md_converter.py"
    local exit_code=$?

    if [ "$exit_code" -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Notes processing completed${NC}"
        echo ""
        echo "Next steps:"
        echo "  - Converted notes are in notes/ai/"
        echo "  - Original notes moved to notes/processed/"
        echo "  - Use GitHub Copilot: /discoverNotes to extract information"
    else
        echo -e "${RED}✗ Notes processing failed${NC}"
    fi
}

# Export to PDF function
export_pdf() {
    echo -e "${BLUE}Exporting documentation to PDF...${NC}"
    echo ""

    # Check if export script exists
    if [ ! -f "$PROJECT_ROOT/core/scripts/export-pdf.sh" ]; then
        echo -e "${RED}Error: PDF export script not found${NC}"
        return 1
    fi

    # Run the export script
    "$PROJECT_ROOT/core/scripts/export-pdf.sh"
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
        "Process Emails")
            process_emails
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "Process Notes")
            process_notes
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
        "Lumina Prompts")
            show_prompts
            ;;
        "Export to PDF")
            export_pdf
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
