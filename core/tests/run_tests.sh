#!/bin/bash
#
# Smoke Test Suite
# Runs all smoke tests for the Lumina project
#
# Usage: ./run_tests.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Lumina Smoke Test Suite${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Track test results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Helper function to run a test suite
run_suite() {
    local suite_name="$1"
    local suite_command="$2"
    
    TOTAL_SUITES=$((TOTAL_SUITES + 1))
    
    echo -e "${YELLOW}Running: $suite_name${NC}"
    echo "---------------------------------------------------"
    
    if eval "$suite_command"; then
        echo -e "${GREEN}✓ $suite_name PASSED${NC}"
        echo ""
        PASSED_SUITES=$((PASSED_SUITES + 1))
        return 0
    else
        echo -e "${RED}✗ $suite_name FAILED${NC}"
        echo ""
        FAILED_SUITES=$((FAILED_SUITES + 1))
        return 1
    fi
}

# Run test suites
run_suite "Shell Script Tests" "bash '$SCRIPT_DIR/test_scripts.sh'"
run_suite "Email Converter Tests" "python3 '$SCRIPT_DIR/test_email_converter.py'"
run_suite "Task Detector Tests" "python3 '$SCRIPT_DIR/test_task_detector.py'"

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo "  Total Test Suites: $TOTAL_SUITES"
echo -e "  Passed: ${GREEN}$PASSED_SUITES${NC}"
echo -e "  Failed: ${RED}$FAILED_SUITES${NC}"
echo ""

if [ $FAILED_SUITES -eq 0 ]; then
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  All smoke tests passed! ✓${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
    exit 0
else
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    echo -e "${RED}  Some tests failed!${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════${NC}"
    exit 1
fi
