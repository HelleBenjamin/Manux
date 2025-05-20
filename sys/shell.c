// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "shell.h"
#include "unistd.h"
#include "utsname.h"
#include "syscall.h"
#include <string.h>
#include "../include/stdio.h"

#if INCLUDE_USER_PROGRAMS
// Add user program includes here
#include "../user/sal.h"
#endif

/*
  Simple shell for Manux. This provides minimal interface for the kernel.
*/

void newline(void) {
  write(STDOUT_FILENO, "\n\r", 2);
}

static struct utsname uutsname;

char hextobyte(char *hex) __z88dk_fastcall {
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

void notepad(void) {
  // Very Simple text editor
  // You can remove this, if you want
  puts("Simple text editor\n\r");
  puts("1. Open file 2. New file");
  char choice = 0;
  read(STDIN_FILENO, &choice, 1);
  static char filename[8] = {0};
  static char buffer[256] = {0};
  newline();
  if (choice == '1') {
    // Open file
    puts("Enter filename: ");
    read(STDIN_FILENO, &filename, 8);
    sysc_read(filename, 256, buffer);
    newline();
    puts(buffer);
    newline();
  } else {
    read(STDIN_FILENO, &buffer, 256);
    puts("Enter filename: ");
    read(STDIN_FILENO, &filename, 8);
    newline();
    sysc_write(filename, 256, buffer);
  }
}

void z80ld() {
  // Very small Z80 program loader, loads hex code to 0xF000 and executes it
  char *program = (char *)0xF000;
  static char pg[0xFF]; // increase size if needed
  read(STDIN_FILENO, &pg, 0xFF);
  for (char i = 0; i < 0xFF; ++i) {
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
      putn(process_id);
      newline();
    } else if (strcmp(command, "pcount") == 0) {
      static char process_count = 0;
      sysc_getpcount(&process_count);
      putn(process_count);
      newline();
    }/* else if (strcmp(command, "testwrite") == 0) { // Test only
      static char *message = "Hello World!";
      sysc_write("TESTFIL\0", strlen(message), message);
    } else if (strcmp(command, "testread") == 0) {
      static char buffer[32] = {0};
      sysc_read("TESTFILE\0", 32, buffer);
      puts(buffer);
    }*/ else if (strcmp(command, "notepad") == 0) {
      notepad();
    }
    #if INCLUDE_USER_PROGRAMS
    // Add user program commands here
    else if (strcmp(command, "sal") == 0) {
      sal_main();
    }
    #endif
    else {
      puts("Unknown command\n\r");
    }
  }
}

void main() {
  uname(&uutsname); // Get system information
  puts(uutsname.sysname);
  puts(uutsname.release);
  newline();
  fork();
  sysc_exec((short *)terminal);
  _exit(0);
}
