#!/bin/bash
# Run integration tests for AppyDex Admin
# Usage: ./run_integration_tests.sh [test_file]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
API_URL="${API_BASE_URL:-https://api.appydex.co}"
DEVICE="${TEST_DEVICE:-chrome}"

echo -e "${YELLOW}AppyDex Admin Integration Tests${NC}"
echo "API URL: $API_URL"
echo "Device: $DEVICE"
echo ""

# Check if specific test file provided
if [ -n "$1" ]; then
    TEST_FILE="integration_test/$1"
    if [ ! -f "$TEST_FILE" ]; then
        echo -e "${RED}Error: Test file not found: $TEST_FILE${NC}"
        exit 1
    fi
    echo -e "${GREEN}Running test: $TEST_FILE${NC}"
    flutter test "$TEST_FILE" \
        --dart-define=API_BASE_URL="$API_URL" \
        -d "$DEVICE"
else
    echo -e "${GREEN}Running all integration tests${NC}"
    flutter test integration_test/ \
        --dart-define=API_BASE_URL="$API_URL" \
        -d "$DEVICE"
fi

echo ""
echo -e "${GREEN}✓ Tests completed${NC}"
