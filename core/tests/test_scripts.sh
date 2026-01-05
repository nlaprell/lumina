#!/bin/bash
"""
Smoke tests for shell scripts
Tests that critical shell scripts have valid syntax and structure
"""

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Testing shell scripts..."
echo ""

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    echo -n "  $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "Init Script Tests:"
echo "------------------"

# Test init.sh exists
run_test "init.sh exists" "test -f '$PROJECT_ROOT/core/scripts/init.sh'"

# Test init.sh is executable
run_test "init.sh is executable" "test -x '$PROJECT_ROOT/core/scripts/init.sh'"

# Test init.sh has valid bash syntax
run_test "init.sh has valid syntax" "bash -n '$PROJECT_ROOT/core/scripts/init.sh'"

# Test init.sh has shebang
run_test "init.sh has shebang" "head -1 '$PROJECT_ROOT/core/scripts/init.sh' | grep -q '^#!/bin/bash'"

echo ""
echo "Clean Reset Script Tests:"
echo "-------------------------"

# Test clean-reset.sh exists
run_test "clean-reset.sh exists" "test -f '$PROJECT_ROOT/core/scripts/clean-reset.sh'"

# Test clean-reset.sh is executable
run_test "clean-reset.sh is executable" "test -x '$PROJECT_ROOT/core/scripts/clean-reset.sh'"

# Test clean-reset.sh has valid bash syntax
run_test "clean-reset.sh has valid syntax" "bash -n '$PROJECT_ROOT/core/scripts/clean-reset.sh'"

echo ""
echo "Go Script Tests:"
echo "----------------"

# Test go.sh exists
run_test "go.sh exists" "test -f '$PROJECT_ROOT/go.sh'"

# Test go.sh is executable
run_test "go.sh is executable" "test -x '$PROJECT_ROOT/go.sh'"

# Test go.sh has valid bash syntax
run_test "go.sh has valid syntax" "bash -n '$PROJECT_ROOT/go.sh'"

echo ""
echo "Template Files Tests:"
echo "---------------------"

# Test templates directory exists
run_test "templates/ directory exists" "test -d '$PROJECT_ROOT/core/templates'"

# Test required templates exist
run_test "SUMMARY.template.md exists" "test -f '$PROJECT_ROOT/core/templates/SUMMARY.template.md'"
run_test "TASKS.template.md exists" "test -f '$PROJECT_ROOT/core/templates/TASKS.template.md'"
run_test "DISCOVERY.template.md exists" "test -f '$PROJECT_ROOT/core/templates/DISCOVERY.template.md'"
run_test "AI.template.md exists" "test -f '$PROJECT_ROOT/core/templates/AI.template.md'"

echo ""
echo "Python Script Tests:"
echo "--------------------"

# Test email converter exists
run_test "eml_to_md_converter.py exists" "test -f '$PROJECT_ROOT/core/aiScripts/emailToMd/eml_to_md_converter.py'"

# Test email converter has valid Python syntax
run_test "eml_to_md_converter.py valid syntax" "python3 -m py_compile '$PROJECT_ROOT/core/aiScripts/emailToMd/eml_to_md_converter.py'"

# Test task detector exists
run_test "detectTaskDependencies.py exists" "test -f '$PROJECT_ROOT/core/aiScripts/detectTaskDependencies/detectTaskDependencies.py'"

# Test task detector has valid Python syntax
run_test "detectTaskDependencies.py valid syntax" "python3 -m py_compile '$PROJECT_ROOT/core/aiScripts/detectTaskDependencies/detectTaskDependencies.py'"

# Test state manager exists
run_test "state_manager.py exists" "test -f '$PROJECT_ROOT/core/aiScripts/state_manager.py'"

# Test state manager has valid Python syntax
run_test "state_manager.py valid syntax" "python3 -m py_compile '$PROJECT_ROOT/core/aiScripts/state_manager.py'"

echo ""
echo "================================"
echo "Test Summary:"
echo "  Total:  $TESTS_RUN"
echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"
echo "================================"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All shell script tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
