#include "stdio.h"

int getlen(char *s) {
  int len = 0;
  while (s[len] != '\0') {
    ++len;
  }
  return len;
}

char putchar(char c){
  asm(
    "extern _getparams1\n"
    "extern _fputc_cons_native\n"
    "call _getparams1\n"
    "push hl\n"
    "call _fputc_cons_native\n"
    "pop hl"
  );
  //sysc_puts(1, &c);
  return 0;
}
  
char puts(char *s){
  short len = getlen(s);
  sysc_puts(len, s);
  return len;
}

char getchar(void) {
  char *c = '\0';
  sysc_gets(1, c);
  return *c;
}