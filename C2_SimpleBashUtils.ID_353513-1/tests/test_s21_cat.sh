#!/bin/bash

# test_s21_cat.sh

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Пути к файлам
S21_CAT="./s21_cat"
TEST_FILE="test_cat.txt"
TAB_FILE="tabs_cat.txt"
SPECIAL_FILE="special_cat.txt"

# Create test files
create_files() {
    # Основной тестовый файл
    echo "line 1" > $TEST_FILE
    echo "line 2" >> $TEST_FILE
    echo "" >> $TEST_FILE
    echo "line 4" >> $TEST_FILE
    
    # Файл с табами
    echo -e "line with\ttabs" > $TAB_FILE
    echo -e "another\tline\twith\ttabs" >> $TAB_FILE
    
    # Файл со специальными символами
    echo -e "normal line" > $SPECIAL_FILE
    echo -e "line with\ttab" >> $SPECIAL_FILE
    echo -e "line with\nnewline" >> $SPECIAL_FILE
    echo -e "" >> $SPECIAL_FILE
    echo -e "" >> $SPECIAL_FILE
    echo -e "another line" >> $SPECIAL_FILE
    echo -e "line with \x01 control" >> $SPECIAL_FILE
    echo -e "line with \x7F del" >> $SPECIAL_FILE
}

# Simple test function
run_test() {
    local test_name="$1"
    local cat_cmd="$2"
    local s21_cat_cmd="$3"
    
    echo -e "${GREEN}RUN${NC} $test_name"
    
    eval $cat_cmd > cat_out.txt 2>&1
    eval $s21_cat_cmd > s21_cat_out.txt 2>&1
    
    if diff cat_out.txt s21_cat_out.txt > /dev/null; then
        echo -e "${GREEN}OK${NC} $test_name"
        return 0
    else
        echo -e "${RED}FAILED${NC} $test_name"
        echo "Differences:"
        diff cat_out.txt s21_cat_out.txt
        return 1
    fi
}

# Main tests
main() {
    echo "=== Testing s21_cat ==="
    
    create_files
    
    # Basic tests
    run_test "Basic output" "cat $TEST_FILE" "$S21_CAT $TEST_FILE"
    run_test "Number lines" "cat -n $TEST_FILE" "$S21_CAT -n $TEST_FILE"
    run_test "Number non-empty" "cat -b $TEST_FILE" "$S21_CAT -b $TEST_FILE"
    run_test "Squeeze blank" "cat -s $TEST_FILE" "$S21_CAT -s $TEST_FILE"
    run_test "Show ends" "cat -E $TEST_FILE" "$S21_CAT -E $TEST_FILE"
    run_test "Show tabs" "cat -T $TAB_FILE" "$S21_CAT -T $TAB_FILE"
    run_test "Show all" "cat -e $TEST_FILE" "$S21_CAT -e $TEST_FILE"
    run_test "Show tabs all" "cat -t $TAB_FILE" "$S21_CAT -t $TAB_FILE"
    
    # Multiple files
    run_test "Multiple files" "cat $TEST_FILE $TAB_FILE" "$S21_CAT $TEST_FILE $TAB_FILE"
    
    # Flag combinations - основные комбинации
    run_test "Flags -n -s" "cat -n -s $TEST_FILE" "$S21_CAT -n -s $TEST_FILE"
    run_test "Flags -b -E" "cat -b -E $TEST_FILE" "$S21_CAT -b -E $TEST_FILE"
    run_test "Flags -n -E" "cat -n -E $TEST_FILE" "$S21_CAT -n -E $TEST_FILE"
    run_test "Flags -b -T" "cat -b -T $TAB_FILE" "$S21_CAT -b -T $TAB_FILE"
    
    # Комбинации с squeeze-blank
    run_test "Flags -s -E" "cat -s -E $TEST_FILE" "$S21_CAT -s -E $TEST_FILE"
    run_test "Flags -s -T" "cat -s -T $TAB_FILE" "$S21_CAT -s -T $TAB_FILE"
    run_test "Flags -s -e" "cat -s -e $SPECIAL_FILE" "$S21_CAT -s -e $SPECIAL_FILE"
    run_test "Flags -s -t" "cat -s -t $SPECIAL_FILE" "$S21_CAT -s -t $SPECIAL_FILE"
    
    # Комбинации нумерации
    run_test "Flags -n -b" "cat -n -b $TEST_FILE" "$S21_CAT -n -b $TEST_FILE"
    run_test "Flags -n -e" "cat -n -e $SPECIAL_FILE" "$S21_CAT -n -e $SPECIAL_FILE"
    run_test "Flags -b -t" "cat -b -t $SPECIAL_FILE" "$S21_CAT -b -t $SPECIAL_FILE"
    
    # Комбинации отображения символов
    run_test "Flags -E -T" "cat -E -T $SPECIAL_FILE" "$S21_CAT -E -T $SPECIAL_FILE"
    run_test "Flags -e -t" "cat -e -t $SPECIAL_FILE" "$S21_CAT -e -t $SPECIAL_FILE"
    
    # Тройные комбинации
    run_test "Flags -n -s -E" "cat -n -s -E $TEST_FILE" "$S21_CAT -n -s -E $TEST_FILE"
    run_test "Flags -b -s -T" "cat -b -s -T $TAB_FILE" "$S21_CAT -b -s -T $TAB_FILE"
    run_test "Flags -n -e -t" "cat -n -e -t $SPECIAL_FILE" "$S21_CAT -n -e -t $SPECIAL_FILE"
    
    # GNU long options
    run_test "GNU --number" "cat --number $TEST_FILE" "$S21_CAT --number $TEST_FILE"
    run_test "GNU --number-nonblank" "cat --number-nonblank $TEST_FILE" "$S21_CAT --number-nonblank $TEST_FILE"
    run_test "GNU --squeeze-blank" "cat --squeeze-blank $TEST_FILE" "$S21_CAT --squeeze-blank $TEST_FILE"
    
    # Edge cases
    run_test "Empty file" "cat /dev/null" "$S21_CAT /dev/null"
    run_test "Nonexistent file" "cat nofile.txt 2>&1" "$S21_CAT nofile.txt 2>&1"
    
    # Special cases
    run_test "Only empty lines" "cat -s $SPECIAL_FILE" "$S21_CAT -s $SPECIAL_FILE"
    run_test "All flags special" "cat -b -e -t -s $SPECIAL_FILE" "$S21_CAT -b -e -t -s $SPECIAL_FILE"
    
    # Cleanup
    rm -f $TEST_FILE $TAB_FILE $SPECIAL_FILE cat_out.txt s21_cat_out.txt
    
    echo "=== cat tests completed ==="
}

main