#ifndef S_21CAT_H
#define S_21CAT_H

#include <ctype.h>
#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 1024

typedef struct {
  int b;
  int e;
  int n;
  int s;
  int t;
  int e_GNU;
  int t_GNU;
} CatFlags;

void init_flags(CatFlags* flags);
void parse_args(int argc, char* argv[], CatFlags* flags);
void process_file(const char* filename, const CatFlags* flags);
FILE* open_file(const char* filename);
void flag_t_GNU(char* buffer);
void flag_e_GNU(char* buffer);
void flag_Ev(char* buffer);
void flag_Tv(char* buffer);
void print_error_filename(const char* message, const char* filename);

#endif