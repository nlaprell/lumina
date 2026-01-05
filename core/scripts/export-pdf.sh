#!/bin/bash

# export-pdf.sh - Export project documentation to professional PDF
# Uses Pandoc + LaTeX for high-quality typesetting

set -euo pipefail

# Color output
if [ -t 1 ] && command -v tput &> /dev/null; then
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

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Output directory
EXPORT_DIR="$PROJECT_ROOT/exports"
TEMPLATE_FILE="$PROJECT_ROOT/core/templates/lumina.latex"

# Temporary directory for processing
TEMP_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_DIR'" EXIT

# Function to check dependencies
check_dependencies() {
    local missing=0

    echo -e "${BLUE}Checking dependencies...${NC}"

    # Check for pandoc
    if ! command -v pandoc &> /dev/null; then
        echo -e "${RED}✗ Pandoc not found${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ Pandoc installed${NC}"
    fi

    # Check for xelatex (part of LaTeX distribution)
    if ! command -v xelatex &> /dev/null; then
        echo -e "${RED}✗ XeLaTeX not found${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ XeLaTeX installed${NC}"
    fi

    if [ $missing -eq 1 ]; then
        echo ""
        echo -e "${YELLOW}========================================${NC}"
        echo -e "${YELLOW}Missing Dependencies${NC}"
        echo -e "${YELLOW}========================================${NC}"
        echo ""
        echo "To generate PDFs, you need Pandoc and LaTeX."
        echo ""

        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${BLUE}macOS Installation:${NC}"
            echo "  brew install pandoc"
            echo "  brew install --cask basictex"
            echo ""
            echo "After installing BasicTeX, run:"
            echo "  export PATH=\"/Library/TeX/texbin:\$PATH\""
            echo "  sudo tlmgr update --self"
            echo "  sudo tlmgr install collection-fontsrecommended collection-xetex"
            echo "  sudo tlmgr install tocloft titlesec enumitem lastpage amsfonts amsmath"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo -e "${BLUE}Linux Installation:${NC}"
            echo "  sudo apt-get update"
            echo "  sudo apt-get install pandoc texlive-xetex texlive-fonts-recommended"
            echo ""
            echo "Or for Red Hat/Fedora:"
            echo "  sudo dnf install pandoc texlive-xetex texlive-collection-fontsrecommended"
        fi

        echo ""
        echo -e "${YELLOW}========================================${NC}"
        return 1
    fi

    return 0
}

# Function to extract project metadata
get_project_metadata() {
    local project_name="Project Documentation"
    local customer=""

    # Try to extract from PROJECT.md if it exists
    if [ -f "$PROJECT_ROOT/PROJECT.md" ]; then
        # Get first heading as project name
        project_name=$(grep -m 1 "^# " "$PROJECT_ROOT/PROJECT.md" | sed 's/^# //' || echo "Project Documentation")

        # Try to extract customer from Quick Context or similar
        customer=$(grep -i "customer\|client" "$PROJECT_ROOT/PROJECT.md" | head -1 | sed 's/.*://;s/\*\*//g;s/^[[:space:]]*//' || echo "")
    fi

    # Try aiDocs/SUMMARY.md for better metadata
    if [ -f "$PROJECT_ROOT/aiDocs/SUMMARY.md" ]; then
        # Extract from Quick Context section
        local who_line=$(grep "^\*\*Who\*\*:" "$PROJECT_ROOT/aiDocs/SUMMARY.md" | head -1 || echo "")
        if [ -n "$who_line" ]; then
            customer=$(echo "$who_line" | sed 's/.*://;s/\[//;s/\]//;s/^[[:space:]]*//;s/[[:space:]]*$//')
        fi
    fi

    echo "$project_name|$customer"
}

# Function to collect markdown files
collect_files() {
    echo -e "${BLUE}Collecting documentation files...${NC}" >&2

    local combined_file="$TEMP_DIR/combined.md"

    # Extract metadata
    local metadata=$(get_project_metadata)
    local project_name=$(echo "$metadata" | cut -d'|' -f1)
    local customer=$(echo "$metadata" | cut -d'|' -f2)
    local date=$(date "+%B %d, %Y")

    # Create combined markdown file with sections
    {
        # Don't include title in body (it's in the template cover page)

        # Section 1: Executive Summary
        if [ -f "$PROJECT_ROOT/PROJECT.md" ]; then
            echo "# Executive Summary"
            echo ""
            # Skip the title line and AI tagline, start from content
            tail -n +4 "$PROJECT_ROOT/PROJECT.md" | sed '/^*This document was originally created/d'
            echo ""
            echo "\\newpage"
            echo ""
        fi

        # Section 2: Quick Reference
        echo "# Quick Reference"
        echo ""

        if [ -f "$PROJECT_ROOT/docs/CONTACTS.md" ]; then
            echo "## Contacts"
            echo ""
            tail -n +3 "$PROJECT_ROOT/docs/CONTACTS.md"
            echo ""
            echo "\\newpage"
            echo ""
        fi

        if [ -f "$PROJECT_ROOT/docs/TASKS.md" ]; then
            echo "## Tasks"
            echo ""
            tail -n +3 "$PROJECT_ROOT/docs/TASKS.md"
            echo ""
            echo "\\newpage"
            echo ""
        fi

        if [ -f "$PROJECT_ROOT/docs/DECISIONS.md" ]; then
            echo "## Decisions"
            echo ""
            tail -n +3 "$PROJECT_ROOT/docs/DECISIONS.md"
            echo ""
            echo "\\newpage"
            echo ""
        fi

        if [ -f "$PROJECT_ROOT/docs/QUESTIONS.md" ]; then
            echo "## Outstanding Questions"
            echo ""
            tail -n +3 "$PROJECT_ROOT/docs/QUESTIONS.md"
            echo ""
            echo "\\newpage"
            echo ""
        fi

        # Section 3: Complete Project Context
        echo "# Complete Project Context"
        echo ""

        if [ -f "$PROJECT_ROOT/aiDocs/SUMMARY.md" ]; then
            echo "## Project Summary"
            echo ""
            tail -n +3 "$PROJECT_ROOT/aiDocs/SUMMARY.md"
            echo ""
            echo "\\newpage"
            echo ""
        fi

        if [ -f "$PROJECT_ROOT/aiDocs/TASKS.md" ]; then
            echo "## Detailed Tasks"
            echo ""
            tail -n +3 "$PROJECT_ROOT/aiDocs/TASKS.md"
            echo ""
            echo "\\newpage"
            echo ""
        fi

        if [ -f "$PROJECT_ROOT/aiDocs/DISCOVERY.md" ]; then
            echo "## Discovery Questions"
            echo ""
            tail -n +3 "$PROJECT_ROOT/aiDocs/DISCOVERY.md"
            echo ""
            echo "\\newpage"
            echo ""
        fi

        if [ -f "$PROJECT_ROOT/aiDocs/AI.md" ]; then
            echo "## AI Agent Context"
            echo ""
            tail -n +3 "$PROJECT_ROOT/aiDocs/AI.md"
            echo ""
        fi

    } > "$combined_file"

    echo -e "${GREEN}✓ Files collected${NC}" >&2
    echo "$combined_file|$project_name|$customer|$date"
}

# Function to generate PDF
generate_pdf() {
    local input_file="$1"
    local project_name="$2"
    local customer="$3"
    local date="$4"

    # Create export directory if it doesn't exist
    mkdir -p "$EXPORT_DIR"

    # Generate output filename
    local sanitized_name=$(echo "$project_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    local date_stamp=$(date "+%Y-%m-%d")
    local output_file="$EXPORT_DIR/${sanitized_name}-${date_stamp}.pdf"

    echo -e "${BLUE}Generating PDF...${NC}"
    echo -e "${YELLOW}This may take 30-60 seconds...${NC}"

    # Run pandoc with our custom template
    if pandoc "$input_file" \
        --from=markdown \
        --to=pdf \
        --pdf-engine=xelatex \
        --template="$TEMPLATE_FILE" \
        --variable=project-name:"$project_name" \
        --variable=customer:"$customer" \
        --variable=date:"$date" \
        --variable=title:"$project_name" \
        --variable=subtitle:"Complete Project Documentation" \
        --variable=tables:true \
        --toc \
        --toc-depth=3 \
        --syntax-highlighting=tango \
        --output="$output_file" \
        2>&1; then

        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}✓ PDF Generated Successfully${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo -e "${BLUE}Output:${NC} $output_file"
        echo -e "${BLUE}Size:${NC} $(du -h "$output_file" | cut -f1)"
        echo ""

        # Open PDF if on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "${YELLOW}Opening PDF...${NC}"
            open "$output_file"
        else
            echo -e "${YELLOW}Tip: Open with your PDF viewer${NC}"
        fi

        return 0
    else
        echo ""
        echo -e "${RED}========================================${NC}"
        echo -e "${RED}✗ PDF Generation Failed${NC}"
        echo -e "${RED}========================================${NC}"
        echo ""
        echo "Check the error messages above for details."
        echo ""
        return 1
    fi
}

# Main execution
main() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Lumina PDF Export${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    # Check dependencies first
    if ! check_dependencies; then
        exit 1
    fi

    echo ""

    # Collect files and metadata
    local file_info=$(collect_files)
    local combined_file=$(echo "$file_info" | cut -d'|' -f1)
    local project_name=$(echo "$file_info" | cut -d'|' -f2)
    local customer=$(echo "$file_info" | cut -d'|' -f3)
    local date=$(echo "$file_info" | cut -d'|' -f4)

    echo ""

    # Generate PDF
    if generate_pdf "$combined_file" "$project_name" "$customer" "$date"; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
