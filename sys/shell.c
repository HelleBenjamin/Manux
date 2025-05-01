// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "shell.h"
#include "unistd.h"
#include "utsname.h"
#include "syscall.h"
#include <string.h>
#include "../include/stdio.h"

/*
  Simple shell for Manux. This provides minimal interface for the kernel.
*/

void newline(void) {
  write(STDOUT_FILENO, "\n\r", 2);
}

static struct utsname uutsname;

void print_uint(unsigned short n) {
  static unsigned short powers[] = {10000, 1000, 100, 10, 1};
  short started = 0;

  for (short i = 0; i < 5; i++) {
    char digit = 0;

    while (n >= powers[i]) {
      n -= powers[i];
      digit++;
    }

    if (digit > 0 || started || i == 4) {
      char char_digit = '0' + digit;
      putchar(char_digit);
      started = 1;
    }
  }
}

char hextobyte(char *hex) {
  char byte = 0;
  if (hex[0] >= '0' && hex[0] <= '9') {
    byte += (hex[0] - '0') << 4;
  } else if (hex[0] >= 'A' && hex[0] <= 'F') {
    byte += (hex[0] - 'A' + 10) << 4;
  }
  if (hex[1] >= '0' && hex[1] <= '9') {
    byte += (hex[1] - '0');
  } else if (hex[1] >= 'A' && hex[1] <= 'F') {
    byte += (hex[1] - 'A' + 10);
  }
  return byte;
}

void z80ld() {
  // Very small Z80 program loader, loads hex code to 0xF000 and executes it
  static char *program = (char *)0xF000;
  char pg[0xFF] = {0}; // increase size if needed
  read(STDIN_FILENO, &pg, 0xFF);
  for (short i = 0; i < 0xFF; i++) {
    program[i] = hextobyte(&pg[i * 2]);
  }
  newline();
  fork();
  sysc_exec((short *)0xF000);
}

void terminal() {
  static char command[32] = {0};
  while (1) {
    memset(command, 0, 32);
    puts("> ");
    read(STDIN_FILENO, &command, 32);
    newline();
    if (strcmp(command, "exit") == 0) {
      _exit(0);
    } else if (strcmp(command, "uname") == 0) {
      puts(uutsname.sysname);
      puts(uutsname.nodename);
      puts(uutsname.release);
      puts(uutsname.version);
      puts(uutsname.machine);
      newline();
    } else if (strcmp(command, "z80ld") == 0) {
      z80ld();
    } else if (strcmp(command, "clear") == 0) {
      putchar(0x0C);
    } else if (strcmp(command, "pid") == 0) {
      static char process_id = 0;
      sysc_getpid(&process_id);
      print_uint(process_id);
      newline();
    } else if (strcmp(command, "pcount") == 0) {
      static char process_count = 0;
      sysc_getpcount(&process_count);
      print_uint(process_count);
      newline();
    } else {
      puts("Unknown command\n\r");
    }
  }
}

void main() {
  uname(&uutsname);
  puts(uutsname.sysname);
  puts(uutsname.release);
  newline();
  fork();
  sysc_exec((short *)terminal);
  _exit(0);
}
