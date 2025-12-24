#include "s21_cat.h"

void init_flags(CatFlags* flags) {
  flags->b = 0;
  flags->e = 0;
  flags->n = 0;
  flags->s = 0;
  flags->t = 0;
  flags->e_GNU = 0;
  flags->t_GNU = 0;
}

void parse_args(int argc, char* argv[], CatFlags* flags) {
  for (int i = 1; i < argc; i++) {
    if (argv[i][0] == '-') {
      if (strcmp(argv[i], "-b") == 0 ||
          strcmp(argv[i], "--number-nonblank") == 0) {
        flags->b = 1;
      } else if (strcmp(argv[i], "-e") == 0) {
        flags->e = 1;
      } else if (strcmp(argv[i], "-E") == 0) {
        flags->e_GNU = 1;
      } else if (strcmp(argv[i], "-n") == 0 ||
                 strcmp(argv[i], "--number") == 0) {
        flags->n = 1;
      } else if (strcmp(argv[i], "-s") == 0 ||
                 strcmp(argv[i], "--squeeze-blank") == 0) {
        flags->s = 1;
      } else if (strcmp(argv[i], "-t") == 0) {
        flags->t = 1;
      } else if (strcmp(argv[i], "-T") == 0) {
        flags->t_GNU = 1;
      }
    }
  }
}

void print_error_filename(const char* message, const char* filename) {
  fprintf(stderr, "cat: %s: %s\n", filename, message);
}

FILE* open_file(const char* filename) {
  FILE* file = fopen(filename, "r");
  if (!file) {
    print_error_filename("No such file or directory", filename);
    return NULL;
  }
  return file;
}

void flag_t_GNU(char* buffer) {
  char temp[BUFFER_SIZE];
  char* read = buffer;
  char* write = temp;

  while (*read) {
    if (*read == '\t') {
      *write++ = '^';
      *write++ = 'I';
      read++;
    } else {
      *write++ = *read++;
    }
  }
  *write = '\0';
  strncpy(buffer, temp, BUFFER_SIZE - 1);
}

void flag_e_GNU(char* buffer) {
  char temp[BUFFER_SIZE];
  char* read = buffer;
  char* write = temp;

  while (*read && (write - temp) < BUFFER_SIZE - 2) {
    if (*read == '\n') {
      *write++ = '$';
      *write++ = '\n';
      read++;
    } else {
      *write++ = *read++;
    }
  }
  *write = '\0';
  strncpy(buffer, temp, BUFFER_SIZE - 1);
}

void flag_Ev(char* buffer) {
  char temp[BUFFER_SIZE];
  char* read = buffer;
  char* write = temp;

  while (*read) {
    unsigned char c = *read++;

    if (c == '\n') {
      *write++ = '$';
      *write++ = '\n';
    } else if (c < 32 && c != '\t') {
      *write++ = '^';
      *write++ = c + 64;
    } else if (c == 127) {
      *write++ = '^';
      *write++ = '?';
    } else if (c > 127) {
      *write++ = 'M';
      *write++ = '-';
      *write++ = c - 128;
    } else {
      *write++ = c;
    }
  }
  *write = '\0';
  strncpy(buffer, temp, BUFFER_SIZE - 1);
}

void flag_Tv(char* buffer) {
  char temp[BUFFER_SIZE];
  char* read = buffer;
  char* write = temp;

  while (*read) {
    unsigned char c = *read++;

    if (c == '\t') {
      *write++ = '^';
      *write++ = 'I';
    } else if (c == '\n') {
      *write++ = c;
    } else if (c < 32) {
      *write++ = '^';
      *write++ = c + 64;
    } else if (c == 127) {
      *write++ = '^';
      *write++ = '?';
    } else if (c > 127) {
      *write++ = 'M';
      *write++ = '-';
      *write++ = c - 128;
    } else {
      *write++ = c;
    }
  }
  *write = '\0';
  strncpy(buffer, temp, BUFFER_SIZE - 1);
}

void process_file(const char* filename, const CatFlags* flags) {
  FILE* file = open_file(filename);
  if (file) {
    char buffer[BUFFER_SIZE];
    int line_number = 1;
    int isEmpty = 0;
    while (fgets(buffer, BUFFER_SIZE, file)) {
      int current_line_empty =
          (buffer[0] == '\n' || (buffer[0] == '\r' && buffer[1] == '\n'));
      if (flags->s && current_line_empty) {
        if (isEmpty) continue;
        isEmpty = 1;
      } else
        isEmpty = 0;
      if (flags->t_GNU) flag_t_GNU(buffer);
      if (flags->e_GNU) flag_e_GNU(buffer);
      if (flags->e) flag_Ev(buffer);
      if (flags->t) flag_Tv(buffer);
      if ((flags->n && !flags->b) || (flags->b && !current_line_empty)) {
        printf("%6d\t", line_number++);
      }
      printf("%s", buffer);
    }

    fclose(file);
  }
}