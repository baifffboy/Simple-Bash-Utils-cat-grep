CC = gcc
CFLAGS = -std=c11 -Wall -Wextra -Werror
TARGET = s21_grep
TARGET_TEST_FILES = ../../tests/test_files/*.txt
SRC = main.c s21_grep.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET) $(TARGET_TEST_FILES) 

test_grep: all
	chmod +x ../../tests/test_s21_grep.sh
	../../tests/test_s21_grep.sh

rebuild: clean all

.PHONY: all test_grep clean