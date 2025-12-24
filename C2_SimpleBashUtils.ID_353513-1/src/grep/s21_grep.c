#include "s21_grep.h"

void init_flags(GrepFlags* flags) {
  flags->e = 0;
  flags->i = 0;
  flags->v = 0;
  flags->c = 0;
  flags->l = 0;
  flags->n = 0;
  flags->h = 0;
  flags->s = 0;
  flags->f = 0;
  flags->o = 0;
  flags->pattern_count = 0;
  flags->pattern_file_count = 0;
  flags->target_file_count = 0;
  for (int i = 0; i < MAX_PATTERNS; i++) {
    flags->patterns[i][0] = '\0';
  }
  for (int i = 0; i < MAX_FILES; i++) {
    flags->pattern_files[i][0] = '\0';
  }
  for (int i = 0; i < MAX_FILES; i++) {
    flags->target_files[i][0] = '\0';
  }
  for (int i = 0; i < MAX_FILES; i++) {
    flags->place_of_target_files_in_argv[i] = 0;
  }
}

void check_pattern_count_for_flag(char* argv[], GrepFlags* flags, int* i) {
  if (flags->pattern_count < MAX_PATTERNS) {
    (*i)++;
    strncpy(flags->patterns[flags->pattern_count], argv[*i], BUFFER_SIZE - 1);
    flags->patterns[flags->pattern_count][BUFFER_SIZE - 1] = '\0';
    flags->pattern_count++;
  }
}

void check_pattern_count_for_pattern(char* argv[], GrepFlags* flags, int* i) {
  if (flags->pattern_count < MAX_PATTERNS) {
    strncpy(flags->patterns[flags->pattern_count], argv[*i], BUFFER_SIZE - 1);
    flags->pattern_count++;
  }
}

void parse_args(int argc, char* argv[], GrepFlags* flags) {
  int er = 0;
  for (int i = 1; i < argc; i++) {
    if (argv[i][0] == '-') {
      if (strcmp(argv[i], "-e") == 0 && i + 1 < argc) {
        flags->e = 1;
        check_pattern_count_for_flag(argv, flags, &i);
      } else if (strcmp(argv[i], "-i") == 0) {
        flags->i = 1;
      } else if (strcmp(argv[i], "-v") == 0) {
        flags->v = 1;
      } else if (strcmp(argv[i], "-c") == 0) {
        flags->c = 1;
      } else if (strcmp(argv[i], "-l") == 0) {
        flags->l = 1;
      } else if (strcmp(argv[i], "-n") == 0) {
        flags->n = 1;
      } else if (strcmp(argv[i], "-h") == 0) {
        flags->h = 1;
      } else if (strcmp(argv[i], "-s") == 0) {
        flags->s = 1;
      } else if (strcmp(argv[i], "-f") == 0 && i + 1 < argc) {
        flags->f = 1;
        if (flags->pattern_file_count < MAX_FILES) {
          strncpy(flags->pattern_files[flags->pattern_file_count], argv[++i],
                  BUFFER_SIZE - 1);
          load_patterns_from_file(
              flags->pattern_files[flags->pattern_file_count], flags);
          flags->pattern_file_count++;
        }
      } else if (strcmp(argv[i], "-o") == 0) {
        flags->o = 1;
      }
    } else if (strcmp(argv[i - 1], "./s21_grep") == 0 ||
               (argv[i - 1][0] == '-' && strcmp(argv[i - 1], "-f") != 0 &&
                strcmp(argv[i - 1], "-e") != 0)) {
      check_pattern_count_for_pattern(argv, flags, &i);
    } else {
      if (flags->target_file_count < MAX_FILES) {
        strncpy(flags->target_files[flags->target_file_count], argv[i],
                BUFFER_SIZE - 1);
        flags->target_file_count++;
        if (er < MAX_FILES) {
          flags->place_of_target_files_in_argv[er] = i;
          er++;
        }
      }
    }
  }
}

int match_pattern_regex(const char* line, const char* pattern,
                        int ignore_case) {
  regex_t regex;
  int flags = REG_EXTENDED;
  int result;
  if (ignore_case) {
    flags |= REG_ICASE;
  }
  if (regcomp(&regex, pattern, flags) != 0) {
    return 0;
  }
  result = regexec(&regex, line, 0, NULL, 0);
  regfree(&regex);
  return (result == 0);
}

void load_patterns_from_file(const char* filename, GrepFlags* flags) {
  FILE* file = fopen(filename, "r");
  if (!file) {
    if (!flags->s) {
      print_error_filename("No such file or directory", filename);
    }
    return;
  }
  char buffer[BUFFER_SIZE];
  while (fgets(buffer, BUFFER_SIZE, file) &&
         flags->pattern_count < MAX_PATTERNS) {
    char* newline = strchr(buffer, '\n');
    if (newline) *newline = '\0';
    if (buffer[0] == '\0') continue;
    strncpy(flags->patterns[flags->pattern_count], buffer, BUFFER_SIZE - 1);
    flags->patterns[flags->pattern_count][strlen(buffer)] = '\0';
    flags->pattern_count++;
  }
  if (flags->pattern_count == MAX_PATTERNS) {
    print_error("There are too many patterns!");
  }
  fclose(file);
}

void print_error(const char* message) {
  fprintf(stderr, "grep: %s\n", message);
}

void print_error_filename(const char* message, const char* filename) {
  fprintf(stderr, "grep: %s: %s\n", filename, message);
}

void flag_c(const char* filename, const GrepFlags* flags, int mult,
            int match_count) {
  if (flags->c) {
    if (flags->l && match_count > 0) {
    } else {
      if (mult && !flags->h) {
        printf("%s:", filename);
      }
      printf("%d\n", match_count);
    }
  }
}

int check_matches(GrepFlags* flags, char** ptr_pattern, const char* buffer) {
  int return_flag = 0;
  for (int i = 0; i < flags->pattern_count; i++) {
    if (match_pattern_regex(buffer, flags->patterns[i], flags->i)) {
      *ptr_pattern = flags->patterns[i];
      return_flag = 1;
      break;
    }
  }
  return return_flag;
}

void flag_o(const char* buffer, const char* ptr_pattern, int mult,
            GrepFlags* flags, const char* filename, int line_num) {
  const char* search_pos = buffer;
  char* match;
  while ((match = flags->i ? strcasestr(search_pos, ptr_pattern)
                           : strstr(search_pos, ptr_pattern)) != NULL) {
    if (mult && !flags->h) {
      printf("%s:", filename);
    }
    if (flags->n) {
      printf("%d:", line_num);
    }
    printf("%.*s\n", (int)strlen(ptr_pattern), match);
    search_pos = match + strlen(ptr_pattern);
  }
}

void grep_file(const char* filename, GrepFlags* flags, int mult) {
  FILE* file = fopen(filename, "r");
  if (!file) {
    if (!flags->s) {
      print_error_filename("No such file or directory", filename);
    }
    return;
  }
  char buffer[BUFFER_SIZE];
  int line_num = 1;
  int match_count = 0;
  while (fgets(buffer, BUFFER_SIZE, file)) {
    char* newline = strchr(buffer, '\n');
    if (newline) *newline = '\0';
    char* ptr_pattern = NULL;
    int matches = check_matches(flags, &ptr_pattern, buffer);
    if (flags->v) {
      matches = !matches;
    }
    if (matches) {
      match_count++;
      if (flags->l) {
        printf("%s\n", filename);
        break;
      } else if (flags->c) {
      } else if (flags->o && !flags->v && ptr_pattern) {
        flag_o(buffer, ptr_pattern, mult, flags, filename, line_num);
      } else {
        if (mult && !flags->h) {
          printf("%s:", filename);
        }
        if (flags->n) {
          printf("%d:", line_num);
        }
        printf("%s\n", buffer);
      }
    }
    line_num++;
  }
  flag_c(filename, flags, mult, match_count);
  fclose(file);
}