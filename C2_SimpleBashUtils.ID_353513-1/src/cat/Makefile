CC = gcc
CFLAGS = -std=c11 -Wall -Wextra -Werror
TARGET = s21_cat
TARGET_TEST_FILES = ../../tests/test_files/*.txt
SRC = main.c s21_cat.c

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET) $(TARGET_TEST_FILES) 

test_cat: all
	chmod +x ../../tests/test_s21_cat.sh
	../../tests/test_s21_cat.sh

rebuild: clean all

.PHONY: all test_cat clean