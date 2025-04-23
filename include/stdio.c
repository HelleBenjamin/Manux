#include "stdio.h"

int getlen(char *s) {
  int len = 0;
  while (s[len] != '\0') {
    ++len;
  }
  return len;
}

int putchar(char c) {
  sysc_puts(1, &c);
  return c;
}
  
int puts(char *s) {
  short len = getlen(s);
  sysc_puts(len, s);
  return len;
}

char getchar(void) {
  char *c = '\0';
  sysc_gets(1, c);
  return *c;
}