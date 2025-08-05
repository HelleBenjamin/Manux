// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#include "shell.h"
#include "unistd.h"
#include "utsname.h"
#include "syscall.h"
#include "fs/mfs.h"
#include "fs/devfs.h"
#include "fd/fd.h"
#include "../kernel/kernel.h"
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
  puts("\n\r");
}

void testfunc() {
  puts("Test function called\n\r");
  _exit(3);
}

void terminal() {
  puts(uutsname.sysname);
  puts(uutsname.release);
  newline();
  static char command[32]; // Use fixed size array for command input
  while (1) {
    memset(command, 0, 32);
    puts("> ");
    read(STDIN_FILENO, &command, 32); // Use fixed length read instead of gets. gets may result in buffer overflow
    newline();
    if (strcmp(command, "exit") == 0) {
      _exit(0);
    } else if (strcmp(command, "uname") == 0) {
      syscall(SYS_PUTS, (char *)uutsname, 40, 0);
      newline();
    } else if (strcmp(command, "clear") == 0) {
      putchar(0x0C);
    } else if (strcmp(command, "pid") == 0) { // Debugging
      static char process_id = 0;
      process_id = syscall(SYS_GETPID, 0, 0, 0); // Get process ID
      putn(process_id);
      newline();
    } else if (strcmp(command, "pcount") == 0) {
      static char process_count = 0;
      process_count = syscall(SYS_GETPCOUNT, 0, 0, 0); // Get process count
      putn(process_count);
      newline();
    } else if (strcmp(command, "lsdev") == 0) {
      print_devices();
    } else if (strcmp(command, "ls") == 0) {
      list_files();
    } else if (strcmp(command, "rdump") == 0) { // Debugging
      asm("extern REG_DUMP\ncall REG_DUMP");
    }/* else if (strcmp("test", command) == 0) {
      static char pg[] = {0x3E, 0x4F, 0xCF, 0x3E, 0x4B, 0xCF, 0x3E, 0x00, 0x2E, 0x03, 0xCD, 0x00, 0xA0}; // Example program in hex
      create_file("TESTEXE");
      write_file("TESTEXE", sizeof(pg), pg); // test program
      short *ptr = get_file_blockptr("TESTEXE");
      if (ptr == NULL) {
        puts("Failed to get file block pointer\n\r");
        continue;
      }
      ptr += 4; // Skip header
      for (unsigned char i = 0; i < sizeof(pg); i++) {
        puth(ptr[i]);
      }
      fork(); // Fork the process
      putn(syscall(SYS_EXECS, NULL, "TESTEXE", 0)); // Execute the program
      //syscall(SYS_EXEC, (short *)ptr, 0, 0); // works with (short *)pg, but not with ptr
    }*/ else if (strcmp("ret", command) == 0) {
      _exit(0); // Exit the shell
    } else if (strcmp("ec", command) == 0) {
      puth(*(unsigned short *)EXIT_CODE); // Print exit code
      newline();
    } else if (strcmp("testfunc", command) == 0) {
      fork(); // Fork the process
      syscall(SYS_EXEC, (short *)testfunc, 0, 0); // Execute test function
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

