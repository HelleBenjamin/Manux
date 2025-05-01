// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "stdio.h"

/*
  Custom optimized stdio for Manux. Use this instead of the z88dk's stdio library.
  Functions communicate directly with the TTY driver via crt wrapper. For string operations, it uses syscalls.
*/

short getlen(char *s) {
  short len = 0;
  while (s[len] != '\0') {
    ++len;
  }
  return len;
}

char putchar(char c) {
  asm(
    "extern _getparams1\n"
    "extern _fputc_cons_native\n"
    "call _getparams1\n"
    "push hl\n"
    "call _fputc_cons_native\n"
    "pop hl"
  );
  return 0;
}
  
char puts(char *s){
  short len = getlen(s);
  sysc_puts(len, s);
  return 0;
}

char getchar(void) {
  asm(
    "extern _fgetc_cons\n"
    "call _fgetc_cons\n"
    "ld l, a\n"
    "ld h, 0\n"
  );
}