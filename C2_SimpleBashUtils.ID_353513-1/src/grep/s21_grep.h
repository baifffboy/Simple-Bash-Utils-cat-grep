#ifndef S_21GREP_H
#define S_21GREP_H
#define _GNU_SOURCE

#include <ctype.h>
#include <regex.h>
#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 1024
#define MAX_PATTERNS 1024
#define MAX_FILES 1024

typedef struct {
  int e;
  int i;
  int v;
  int c;
  int l;
  int n;
  int h;
  int s;
  int f;
  int o;
  char patterns[MAX_PATTERNS][BUFFER_SIZE];
  int pattern_count;
  char pattern_files[MAX_FILES][BUFFER_SIZE];
  int pattern_file_count;
  char target_files[MAX_FILES][BUFFER_SIZE];
  int target_file_count;
  int place_of_target_files_in_argv[MAX_FILES];
} GrepFlags;

void print_error(const char* message);
void init_flags(GrepFlags* flags);
void parse_args(int argc, char* argv[], GrepFlags* flags);
int match_pattern_regex(const char* line, const char* pattern, int ignore_case);
void load_patterns_from_file(const char* filename, GrepFlags* flags);
void grep_file(const char* filename, GrepFlags* flags, int mult);
void print_error_filename(const char* message, const char* filename);
void flag_c(const char* filename, const GrepFlags* flags, int mult,
            int match_count);
int check_matches(GrepFlags* flags, char** ptr_pattern, const char* buffer);
void flag_o(const char* buffer, const char* ptr_pattern, int mult,
            GrepFlags* flags, const char* filename, int line_num);
void check_pattern_count_for_flag(char* argv[], GrepFlags* flags, int* i);
void check_pattern_count_for_pattern(char* argv[], GrepFlags* flags, int* i);

#endif