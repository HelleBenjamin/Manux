// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "stdio.h"
#include "../sys/unistd.h"
#include "../sys/syscall.h"
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
  //sysc_write(STDOUT_FILENO, len, s); // Can also be used but it's slower
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

// Print unsigned number
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

// Print unsigned number as hex
void puth(unsigned short n) __z88dk_fastcall {
  char started = 0;
  for (short i = 12; i >= 0; i -= 4) {
    char digit = (n >> i) & 0xF;
    if (digit > 0 || started || i == 0) {
      char char_digit = (digit < 10) ? ('0' + digit) : ('A' + digit - 10);
      putchar(char_digit);
      started = 1;
    }
  }
}
