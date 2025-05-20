// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "stdio.h"
#include <string.h>

/*
  Custom optimized stdio for Manux. Use this instead of the z88dk's stdio library.
  Functions communicate directly with the TTY driver via crt wrapper. For string operations, it uses syscalls.
*/

char putchar(char c) __z88dk_fastcall{
  asm(
    "extern _fputc_cons_native\n"
    "ld a, l\n"
    "call _fputc_cons_native\n"
  );
  return 0;
}
  
char puts(char *s) __z88dk_fastcall {
  short len = strlen(s);
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

void putn(unsigned short n) __z88dk_fastcall {
  static unsigned short powers[] = {10000, 1000, 100, 10, 1};
  short started = 0;

  for (char i = 0; i < 5; ++i) {
    char digit = 0;

    while (n >= powers[i]) {
      n -= powers[i];
      ++digit;
    }

    if (digit > 0 || started || i == 4) {
      char char_digit = '0' + digit;
      putchar(char_digit);
      started = 1;
    }
  }
}
