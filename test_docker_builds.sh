#!/bin/bash

# Docker build test script for LinGam CTF tasks
# This script tests Docker builds and basic container functionality

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

total_tests=0
passed_tests=0
failed_tests=0

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

test_docker_build() {
    local task_name=$1
    local task_dir=$2
    
    total_tests=$((total_tests + 1))
    echo ""
    log_info "Building Docker image for: $task_name"
    
    cd "$task_dir"
    
    # Run pre_install.sh if it exists
    if [ -f "pre_install.sh" ]; then
        log_info "Running pre_install.sh..."
        if bash pre_install.sh > /dev/null 2>&1; then
            log_info "✓ pre_install.sh completed successfully"
        else
            log_error "✗ pre_install.sh failed"
            cd - > /dev/null
            failed_tests=$((failed_tests + 1))
            return 1
        fi
    fi
    
    # Build Docker image
    if docker build -t "test-${task_name,,}" . > /dev/null 2>&1; then
        log_info "✓ PASSED: Docker build for $task_name"
        passed_tests=$((passed_tests + 1))
        cd - > /dev/null
        return 0
    else
        log_error "✗ FAILED: Docker build for $task_name"
        failed_tests=$((failed_tests + 1))
        cd - > /dev/null
        return 1
    fi
}

echo "======================================"
echo "LinGam Docker Build Test Suite"
echo "======================================"
echo ""

# Check Docker availability
log_info "Checking Docker availability..."
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed or not available"
    exit 1
fi
log_info "✓ Docker is available"
echo ""

# Test each task
test_docker_build "Archives" "Archives"
test_docker_build "BanMe" "BanMe"
test_docker_build "DeleteFile" "DeleteFile"
test_docker_build "DoTheMathIn30Seconds" "DoTheMathIn30Seconds"
test_docker_build "KnockKnock" "KnockKnock"
test_docker_build "LargeFile" "LargeFile"
test_docker_build "MoldovaVirus" "MoldovaVirus"
test_docker_build "PinCode" "PinCode"
test_docker_build "ProjectFiles" "ProjectFiles"

# Test container functionality for PinCode
echo ""
log_info "======================================"
log_info "Testing Container Functionality"
log_info "======================================"

total_tests=$((total_tests + 1))
log_info "Testing PinCode container..."
if echo "./main 15627" | docker run -i --rm test-pincode 2>&1 | grep -q "you flag is super_pin_code_brure"; then
    log_info "✓ PASSED: PinCode container works correctly"
    passed_tests=$((passed_tests + 1))
else
    log_error "✗ FAILED: PinCode container test"
    failed_tests=$((failed_tests + 1))
fi

# Summary
echo ""
echo "======================================"
echo "Test Summary"
echo "======================================"
echo "Total tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"
echo ""

if [ $failed_tests -eq 0 ]; then
    log_info "✓ All Docker builds passed!"
    exit 0
else
    log_error "✗ Some Docker builds failed"
    exit 1
fi
