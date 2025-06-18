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

/*char hextobyte(char *hex) __z88dk_fastcall {
  static char byte;
  byte = 0;
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
}*/

/*void z80ld() {
  // Very small Z80 program loader, loads hex code to a file and executes it
  // Create files
  sysc_create("Z80PROG"); // File to hold program
  create_file("Z80ASM "); // Executable program

  char *program = get_file_blockptr("Z80PROG"); // Get block pointers
  char *program_exec = get_file_blockptr("Z80ASM ");

  read(STDIN_FILENO, program, 0xFF); // Read hex code to file
  for (unsigned char i = 0; i < 0xFF; ++i) {
    program_exec[i] = hextobyte(&program[i * 2]); // Convert hex to bytes
  }
  newline(); // Newline for fun
  fork(); // Fork the process, new process will execute the program
  sysc_execs("Z80ASM ", "0123456789"); // Execute the program

}*/

void terminal() {
  static char command[32];
  while (1) {
    memset(command, 0, 32);
    puts("> ");
    read(STDIN_FILENO, &command, 32); // Use fixed length read instead of gets. gets may result in buffer overflow
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
    }/* else if (strcmp(command, "z80ld") == 0) {
      z80ld();
    }*/ else if (strcmp(command, "clear") == 0) {
      putchar(0x0C);
    } else if (strcmp(command, "pid") == 0) { // Debugging
      static char process_id = 0;
      sysc_getpid(&process_id);
      putn(process_id);
      newline();
    } else if (strcmp(command, "pcount") == 0) {
      static char process_count = 0;
      sysc_getpcount(&process_count);
      putn(process_count);
      newline();
    } else if (strcmp(command, "lsdev") == 0) {
      print_devices();
    } else if (strcmp(command, "ls") == 0) {
      list_files();
    } else if (strcmp(command, "rdump") == 0) { // Debugging
      asm("extern REG_DUMP\ncall REG_DUMP");
    } /*else if (strcmp(command, "test") == 0) { // Debugging, writes a test file and reads it
      sysc_create("TESTFIL");
      char testfd;
      sysc_open("TESTFIL", &testfd);
      char *testmsg = "Hello World!\n\r";
      sysc_write(testfd, strlen(testmsg), testmsg);
      char testbuf[32] = {0};
      sysc_read(testfd, strlen(testmsg), testbuf);
      sysc_write(STDOUT_FILENO, strlen(testbuf), testbuf);
    }*/ else if (strncmp(command, "cat ", 4) == 0) {
      char *filename = command + 4;
      char *filebuf = get_file_blockptr(filename);
      if (filebuf != NULL) {
        read_file(filename, get_file_size(filename), filebuf);
        sysc_write(STDOUT_FILENO, get_file_size(filename), filebuf);
      } else {
        puts("File not found\n\r");
      }
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
