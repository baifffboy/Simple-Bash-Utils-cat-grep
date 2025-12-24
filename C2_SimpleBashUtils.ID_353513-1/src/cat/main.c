#include "s21_cat.h"

int main(int argc, char* argv[]) {
  if (argc < 2) {
    printf("Usage: %s [OPTIONS] [FILE...]\n", argv[0]);
    return 1;
  }

  CatFlags flags;
  init_flags(&flags);
  parse_args(argc, argv, &flags);

  for (int i = 1; i < argc; i++) {
    if (argv[i][0] != '-') {
      process_file(argv[i], &flags);
    }
  }

  return 0;
}