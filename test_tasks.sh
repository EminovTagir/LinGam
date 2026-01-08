#!/bin/bash

# Test script for LinGam CTF tasks
# This script tests all tasks to ensure they work correctly

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

test_task() {
    local task_name=$1
    local test_description=$2
    local test_command=$3
    
    total_tests=$((total_tests + 1))
    echo ""
    log_info "Testing: $task_name - $test_description"
    
    if eval "$test_command" > /dev/null 2>&1; then
        log_info "✓ PASSED: $task_name - $test_description"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        log_error "✗ FAILED: $task_name - $test_description"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

cleanup_task() {
    local task_dir=$1
    cd "$task_dir"
    
    # Clean up generated files
    rm -rf challenges challenge fail2ban.log large_text_file.txt *.tar *.zip *.gz main 2>/dev/null || true
    cd - > /dev/null
}

echo "======================================"
echo "LinGam CTF Tasks Test Suite"
echo "======================================"
echo ""

# Check prerequisites
log_info "Checking prerequisites..."
command -v python3 >/dev/null 2>&1 || { log_error "python3 is not installed"; exit 1; }
command -v go >/dev/null 2>&1 || { log_error "go is not installed"; exit 1; }
log_info "✓ Prerequisites OK (Python3, Go)"
echo ""

# Test Archives task
log_info "======================================"
log_info "Testing Archives Task"
log_info "======================================"
cd Archives
cleanup_task "$(pwd)"

test_task "Archives" "Python script syntax" "python3 -m py_compile generate.py"
test_task "Archives" "Generate archives" "python3 generate.py"
test_task "Archives" "Check challenges directory created" "[ -d challenges ]"
test_task "Archives" "Check archives generated" "[ \$(ls challenges/ | wc -l) -gt 0 ]"
test_task "Archives" "Check config.sh exists" "[ -f config.sh ]"
test_task "Archives" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test BanMe task
log_info "======================================"
log_info "Testing BanMe Task"
log_info "======================================"
cd BanMe
cleanup_task "$(pwd)"

test_task "BanMe" "Python script syntax" "python3 -m py_compile generate.py"
test_task "BanMe" "Generate fail2ban log" "timeout 60 python3 generate.py"
test_task "BanMe" "Check log file created" "[ -f fail2ban.log ]"
test_task "BanMe" "Check log file has content" "[ -s fail2ban.log ]"
test_task "BanMe" "Check config.sh exists" "[ -f config.sh ]"
test_task "BanMe" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test DeleteFile task
log_info "======================================"
log_info "Testing DeleteFile Task"
log_info "======================================"
cd DeleteFile
cleanup_task "$(pwd)"

test_task "DeleteFile" "Go build" "go build main.go"
test_task "DeleteFile" "Binary created" "[ -f main ]"
test_task "DeleteFile" "Binary is executable" "[ -x main ]"
test_task "DeleteFile" "Check config.sh exists" "[ -f config.sh ]"
test_task "DeleteFile" "Check Dockerfile exists" "[ -f Dockerfile ]"
test_task "DeleteFile" "Check dontdelete file exists" "[ -f dontdelete ]"

cd ..

# Test DoTheMathIn30Seconds task
log_info "======================================"
log_info "Testing DoTheMathIn30Seconds Task"
log_info "======================================"
cd DoTheMathIn30Seconds
cleanup_task "$(pwd)"

test_task "DoTheMathIn30Seconds" "Go build" "go build main.go"
test_task "DoTheMathIn30Seconds" "Binary created" "[ -f main ]"
test_task "DoTheMathIn30Seconds" "Python task script syntax" "python3 -m py_compile task.py"
test_task "DoTheMathIn30Seconds" "Check config.sh exists" "[ -f config.sh ]"
test_task "DoTheMathIn30Seconds" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test KnockKnock task
log_info "======================================"
log_info "Testing KnockKnock Task"
log_info "======================================"
cd KnockKnock
cleanup_task "$(pwd)"

test_task "KnockKnock" "Go build" "go build main.go"
test_task "KnockKnock" "Binary created" "[ -f main ]"
test_task "KnockKnock" "Check go.mod exists" "[ -f go.mod ]"
test_task "KnockKnock" "Check knockd.conf exists" "[ -f knockd.conf ]"
test_task "KnockKnock" "Check config.sh exists" "[ -f config.sh ]"
test_task "KnockKnock" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test LargeFile task
log_info "======================================"
log_info "Testing LargeFile Task"
log_info "======================================"
cd LargeFile
cleanup_task "$(pwd)"

test_task "LargeFile" "Python script syntax" "python3 -m py_compile generator.py"
test_task "LargeFile" "Check requirements.txt exists" "[ -f requirements.txt ]"
test_task "LargeFile" "Check config.sh exists" "[ -f config.sh ]"
test_task "LargeFile" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test MoldovaVirus task
log_info "======================================"
log_info "Testing MoldovaVirus Task"
log_info "======================================"
cd MoldovaVirus
cleanup_task "$(pwd)"

test_task "MoldovaVirus" "Python script syntax" "python3 -m py_compile generate.py"
test_task "MoldovaVirus" "Generate directory structure" "timeout 60 python3 generate.py"
test_task "MoldovaVirus" "Check challenge directory created" "[ -d challenge ]"
test_task "MoldovaVirus" "Check config.sh exists" "[ -f config.sh ]"
test_task "MoldovaVirus" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test PinCode task
log_info "======================================"
log_info "Testing PinCode Task"
log_info "======================================"
cd PinCode
cleanup_task "$(pwd)"

test_task "PinCode" "Go build" "go build main.go"
test_task "PinCode" "Binary created" "[ -f main ]"
test_task "PinCode" "Test correct pin code" "./main 15627 | grep -q 'you flag is super_pin_code_brure'"
test_task "PinCode" "Test incorrect pin code" "./main 12345 | grep -q 'Invalid pin code'"
test_task "PinCode" "Check config.sh exists" "[ -f config.sh ]"
test_task "PinCode" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test ProjectFiles task
log_info "======================================"
log_info "Testing ProjectFiles Task"
log_info "======================================"
cd ProjectFiles
cleanup_task "$(pwd)"

test_task "ProjectFiles" "Python script syntax" "python3 -m py_compile generate.py"
test_task "ProjectFiles" "Generate files" "python3 generate.py"
test_task "ProjectFiles" "Check challenges directory created" "[ -d challenges ]"
test_task "ProjectFiles" "Check 150 files generated" "[ \$(ls challenges/ | wc -l) -eq 150 ]"
test_task "ProjectFiles" "Check config.sh exists" "[ -f config.sh ]"
test_task "ProjectFiles" "Check Dockerfile exists" "[ -f Dockerfile ]"

cd ..

# Test builder.sh script
log_info "======================================"
log_info "Testing builder.sh Script"
log_info "======================================"
test_task "builder.sh" "Script is executable" "[ -x builder.sh ]"
test_task "builder.sh" "Script syntax check" "bash -n builder.sh"

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
    log_info "✓ All tests passed!"
    exit 0
else
    log_error "✗ Some tests failed"
    exit 1
fi
