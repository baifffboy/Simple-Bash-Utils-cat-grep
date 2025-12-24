#!/bin/bash

# test_s21_grep.sh

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

S21_GREP="./s21_grep"
TEST_FILE="test_grep.txt"
PATTERN_FILE="patterns_grep.txt"

# Create test files
create_files() {
    echo "line 1 hello" > $TEST_FILE
    echo "LINE 2 HELLO" >> $TEST_FILE
    echo "line 3 world" >> $TEST_FILE
    echo "line 4 test" >> $TEST_FILE
    echo "line 5 hello world" >> $TEST_FILE
    
    echo "hello" > $PATTERN_FILE
    echo "test" >> $PATTERN_FILE
}

# Simple test function
run_test() {
    local test_name="$1"
    local grep_cmd="$2"
    local s21_grep_cmd="$3"
    
    echo -e "${GREEN}RUN${NC} $test_name"
    
    eval $grep_cmd > grep_out.txt 2>&1
    eval $s21_grep_cmd > s21_grep_out.txt 2>&1
    
    if diff grep_out.txt s21_grep_out.txt > /dev/null; then
        echo -e "${GREEN}OK${NC} $test_name"
        return 0
    else
        echo -e "${RED}FAILED${NC} $test_name"
        echo "Differences:"
        diff grep_out.txt s21_grep_out.txt
        return 1
    fi
}

# Main tests
main() {
    echo "=== Testing s21_grep ==="
    
    create_files
    
    # Basic tests
    run_test "Basic search" "grep hello $TEST_FILE" "$S21_GREP hello $TEST_FILE"
    run_test "Case insensitive" "grep -i hello $TEST_FILE" "$S21_GREP -i hello $TEST_FILE"
    run_test "Invert match" "grep -v hello $TEST_FILE" "$S21_GREP -v hello $TEST_FILE"
    run_test "Line numbers" "grep -n hello $TEST_FILE" "$S21_GREP -n hello $TEST_FILE"
    run_test "Count matches" "grep -c hello $TEST_FILE" "$S21_GREP -c hello $TEST_FILE"
    run_test "Only matching" "grep -o hello $TEST_FILE" "$S21_GREP -o hello $TEST_FILE"
    run_test "File names" "grep -l hello $TEST_FILE" "$S21_GREP -l hello $TEST_FILE"
    run_test "No file names" "grep -h hello $TEST_FILE" "$S21_GREP -h hello $TEST_FILE"
    run_test "Suppress errors" "grep -s hello nofile.txt" "$S21_GREP -s hello nofile.txt"
    run_test "Pattern from file" "grep -f $PATTERN_FILE $TEST_FILE" "$S21_GREP -f $PATTERN_FILE $TEST_FILE"
    run_test "Multiple patterns" "grep -e hello -e test $TEST_FILE" "$S21_GREP -e hello -e test $TEST_FILE"
    run_test "Different case" "grep -i HELLO test $TEST_FILE" "$S21_GREP -i HELLO test $TEST_FILE"
    
    # Multiple files
    run_test "Multiple files" "grep hello $TEST_FILE $TEST_FILE" "$S21_GREP hello $TEST_FILE $TEST_FILE"
    run_test "Multiple files with -f" "grep -f $TEST_FILE $TEST_FILE" "$S21_GREP -f $TEST_FILE $TEST_FILE"
    run_test "Multiple files with -h" "grep -h $TEST_FILE $TEST_FILE" "$S21_GREP -h $TEST_FILE $TEST_FILE"
    run_test "Multiple files with -n" "grep -n $TEST_FILE $TEST_FILE" "$S21_GREP -n $TEST_FILE $TEST_FILE"
    run_test "Multiple files with -i -n" "grep -i -n $TEST_FILE $TEST_FILE" "$S21_GREP -i -n $TEST_FILE $TEST_FILE"
    
    # Flag combinations
    run_test "Flags -i -n" "grep -i -n hello $TEST_FILE" "$S21_GREP -i -n hello $TEST_FILE"
    run_test "Flags -v -c" "grep -v -c hello $TEST_FILE" "$S21_GREP -v -c hello $TEST_FILE"
    run_test "Flags -i -v -n" "grep -i -v -n hello $TEST_FILE" "$S21_GREP -i -v -n hello $TEST_FILE"
    run_test "Flags -i -o" "grep -i -o hello $TEST_FILE" "$S21_GREP -i -o hello $TEST_FILE"
    run_test "Flags -i -n -o" "grep -i -n -o hello $TEST_FILE" "$S21_GREP -i -n -o hello $TEST_FILE"
    run_test "Flags -c -o" "grep -c -o hello $TEST_FILE" "$S21_GREP -c -o hello $TEST_FILE"
    run_test "Flags -l -c" "grep -l -c hello $TEST_FILE" "$S21_GREP -l -c hello $TEST_FILE"
    run_test "Flags -v -n" "grep -v -n hello $TEST_FILE" "$S21_GREP -v -n hello $TEST_FILE"
    run_test "Flags -i -v" "grep -i -v hello $TEST_FILE" "$S21_GREP -i -v hello $TEST_FILE"
    run_test "Flags -i -n -v -c" "grep -i -n -v -c hello $TEST_FILE" "$S21_GREP -i -n -v -c hello $TEST_FILE"
    run_test "Flags -i -n -v -c -o" "grep -i -n -v -c -o hello $TEST_FILE" "$S21_GREP -i -n -v -c -o hello $TEST_FILE"

    #Special cases
    run_test "nonexistentpattern pattern" "grep "nonexistentpattern" $TEST_FILE" "$S21_GREP "nonexistentpattern" $TEST_FILE"
    run_test "A special case "^Hello"" "grep ^Hello $TEST_FILE" "$S21_GREP ^Hello $TEST_FILE"
    run_test "A special case "world$"" "grep world$ $TEST_FILE" "$S21_GREP world$ $TEST_FILE"
    run_test "A special case "[Hh]ello"" "grep "[Hh]ello" $TEST_FILE" "$S21_GREP "[Hh]ello" $TEST_FILE"

    # File operations
    run_test "Show filename only" "grep -l hello $TEST_FILE" "$S21_GREP -l hello $TEST_FILE"
    run_test "Suppress filename in output" "grep -h hello $TEST_FILE $TEST_FILE" "$S21_GREP -h hello $TEST_FILE $TEST_FILE"
    run_test "Silent mode for scripts" "grep -s hello nofile.txt" "$S21_GREP -s hello nofile.txt"
    
    # Pattern files and multiple patterns
    run_test "Patterns from file" "grep -f $PATTERN_FILE $TEST_FILE" "$S21_GREP -f $PATTERN_FILE $TEST_FILE"
    run_test "Multiple pattern expressions" "grep -e hello -e world $TEST_FILE" "$S21_GREP -e hello -e world $TEST_FILE"
    
    # Real-world search scenarios
    run_test "Search for IP addresses" "grep -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' $TEST_FILE" "$S21_GREP -E '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' $TEST_FILE"
    run_test "Find empty lines" "grep -E '^$' $TEST_FILE" "$S21_GREP -E '^$' $TEST_FILE"
    run_test "Search for lines starting with word" "grep -E '^Hello' $TEST_FILE" "$S21_GREP -E '^Hello' $TEST_FILE"
    run_test "Search for lines ending with word" "grep -E 'world$' $TEST_FILE" "$S21_GREP -E 'world$' $TEST_FILE"
    
    # Multiple files handling
    run_test "Search in multiple files" "grep hello $TEST_FILE $TEST_FILE" "$S21_GREP hello $TEST_FILE $TEST_FILE"
    run_test "Multiple files with line numbers" "grep -n hello $TEST_FILE $TEST_FILE" "$S21_GREP -n hello $TEST_FILE $TEST_FILE"
    
    # Practical flag combinations
    run_test "Case insensitive with line numbers" "grep -i -n HELLO $TEST_FILE" "$S21_GREP -i -n HELLO $TEST_FILE"
    run_test "Count non-matching lines" "grep -v -c hello $TEST_FILE" "$S21_GREP -v -c hello $TEST_FILE"
    run_test "Inverse case insensitive search" "grep -i -v HELLO $TEST_FILE" "$S21_GREP -i -v HELLO $TEST_FILE"
    
    # Email pattern search (common use case)
    run_test "Email pattern search" "grep -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' $TEST_FILE" "$S21_GREP -E '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' $TEST_FILE"
    
    # Number searches
    run_test "Find numbers" "grep -E '[0-9]+' $TEST_FILE" "$S21_GREP -E '[0-9]+' $TEST_FILE"
    run_test "Find prices pattern" "grep -E '\$[0-9]+\.[0-9]{2}' $TEST_FILE" "$S21_GREP -E '\$[0-9]+\.[0-9]{2}' $TEST_FILE"
    
    # Word boundary tests
    run_test "Whole word search" "grep -E '\bhello\b' $TEST_FILE" "$S21_GREP -E '\bhello\b' $TEST_FILE"
    run_test "Word beginning with pattern" "grep -E '\btest' $TEST_FILE" "$S21_GREP -E '\btest' $TEST_FILE"
    
    # Character classes
    run_test "Uppercase letters" "grep -E '[A-Z]' $TEST_FILE" "$S21_GREP -E '[A-Z]' $TEST_FILE"
    run_test "Lowercase letters" "grep -E '[a-z]' $TEST_FILE" "$S21_GREP -E '[a-z]' $TEST_FILE"
    run_test "Alphanumeric characters" "grep -E '[a-zA-Z0-9]' $TEST_FILE" "$S21_GREP -E '[a-zA-Z0-9]' $TEST_FILE"
    
    # Error handling tests
    run_test "Search in non-existent file" "grep hello nonexistent.txt" "$S21_GREP hello nonexistent.txt"
    run_test "Silent mode with non-existent file" "grep -s hello nonexistent.txt" "$S21_GREP -s hello nonexistent.txt"
    
    # Performance-like tests (large patterns)
    run_test "Multiple OR patterns" "grep -E 'hello|world|test|grep' $TEST_FILE" "$S21_GREP -E 'hello|world|test|grep' $TEST_FILE"
    run_test "Character ranges" "grep -E '[A-Za-z]+' $TEST_FILE" "$S21_GREP -E '[A-Za-z]+' $TEST_FILE"

    # Cleanup
    rm -f $TEST_FILE $PATTERN_FILE grep_out.txt s21_grep_out.txt
    
    echo "=== grep tests completed ==="
}

main