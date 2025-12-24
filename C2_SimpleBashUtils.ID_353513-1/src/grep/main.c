#include "s21_grep.h"

int main(int argc, char* argv[]) {
  if (argc < 2) {
    printf("Usage: %s [OPTIONS] PATTERN [FILE...]\n", argv[0]);
    return 1;
  }

  GrepFlags flags;
  init_flags(&flags);
  parse_args(argc, argv, &flags);

  if (flags.pattern_count == 0 && !flags.f) {
    if (!flags.s) {
      print_error("Pattern not specified");
    }
    return 1;
  }

  for (int i = 0; i < flags.target_file_count; i++) {
    grep_file(argv[flags.place_of_target_files_in_argv[i]], &flags,
              flags.target_file_count > 1);
  }

  return 0;
}