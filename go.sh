#!/bin/bash

# go.sh - Interactive project management menu
# Provides easy access to common project operations

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
    "Reset Project"
    "Quit"
)

# Current selection index
CURRENT_INDEX=0

# Cleanup function to restore cursor
cleanup() {
    tput cnorm 2>/dev/null || true
    clear
}
trap cleanup EXIT

# Hide cursor
tput civis 2>/dev/null || true

# Function to display menu
display_menu() {
    clear
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}    Copilot Template - Project Manager${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
    echo ""
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
            if [ -f "$PROJECT_ROOT/.template/scripts/init.sh" ]; then
                "$PROJECT_ROOT/.template/scripts/init.sh"
                local exit_code=$?
                echo ""
                if [ $exit_code -ne 0 ]; then
                    echo -e "${RED}Error: Initialize script failed with exit code $exit_code${NC}"
                else
                    echo -e "${GREEN}Initialize completed successfully${NC}"
                fi
            else
                echo -e "${RED}Error: init.sh not found at $PROJECT_ROOT/.template/scripts/init.sh${NC}"
            fi
            echo ""
            read -p "Press any key to continue..." -n 1 -s
            ;;
        "Reset Project")
            if [ -f "$PROJECT_ROOT/.template/scripts/clean-reset.sh" ]; then
                "$PROJECT_ROOT/.template/scripts/clean-reset.sh"
                local exit_code=$?
                echo ""
                if [ $exit_code -ne 0 ]; then
                    echo -e "${RED}Error: Reset script failed with exit code $exit_code${NC}"
                else
                    echo -e "${GREEN}Reset completed successfully${NC}"
                fi
            else
                echo -e "${RED}Error: clean-reset.sh not found at $PROJECT_ROOT/.template/scripts/clean-reset.sh${NC}"
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
