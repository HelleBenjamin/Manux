/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2026 Benjamin Helle
*/

/*
  Custom optimized (kernel) stdio for Manux. Use this instead of the z88dk's stdio library.
  Functions communicate directly with the TTY driver.
*/

#include <kernel/kstdio.h>
#include <driver/tty.h>

int kputchar(char c) __z88dk_fastcall {
  return tty_putchar(c);
}

int kgetchar(void) {
  __asm__(
    "rst 0x10\n"
    "ld l, a\n"
    "ld h, 0\n"
    "ret\n"
  );
  return 0;
}
  
int kputs(char *s) __z88dk_fastcall {
  while (*s) {
    kputchar(*s);
    ++s;
  }
  return 0;
}

int kputslen(char *s, int len) {
  for (unsigned short i = 0; i < len; ++i) {
    kputchar(s[i]);
  }
  return 0;
}

int kgetslen(char *s, int len) {
  unsigned int i;
  for (i = 0; i < len; ++i) {
    s[i] = kgetchar();
    if (s[i] == '\r' || s[i] == '\n') { /* newline */
      break;
    }
    if (s[i] == '\b' || s[i] == 0x7f) { /* backspace */
      if (i > 0) {
        s[i] = 0;
        i-=2;
        kputchar('\b');
      } else --i;

    }
  }
  s[i] = 0; /* null terminator*/
  return 0;
}

// Print unsigned number
/*void kputn(unsigned short n) __z88dk_fastcall {
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
      kputchar(char_digit);
      started = 1;
    }
  }
}*/

// Print unsigned number as hex
void kputh(int n) __z88dk_fastcall {
  char started = 0;
  for (short i = 12; i >= 0; i -= 4) {
    char digit = (n >> i) & 0xF;
    if (digit > 0 || started || i == 0) {
      char char_digit = (digit < 10) ? ('0' + digit) : ('A' + digit - 10);
      kputchar(char_digit);
      started = 1;
    }
  }
}

