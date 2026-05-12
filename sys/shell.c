// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle

#include <sys/unistd.h>
#include <sys/utsname.h>
#include <string.h>

/*
  Simple shell for Manux. This provides minimal interface for the kernel. This is very barebones.
*/

void terminal(void);


int main(void) {
  terminal();
  return 0;
}


void putchr(char c) {
  write(STDOUT_FILENO, &c, 1);
}

void putstr(char *str) {
  write(STDOUT_FILENO, str, strlen(str));
}

void puthex(int h) {
  syscall(SYS_PUTH, h, 0, 0);
}

void newline(void) {
  putchr('\n');
}

struct utsname uutsname;

void terminal(void) {
  uname(&uutsname);
  putstr("Manux Shell\n\rKernel version: ");
  putstr(uutsname.release);
  putstr("\n\r");
  char command[32]; // Use fixed size array for command input
  while (1) {
    memset(command, 0, 32);
    putstr("$ ");
    read(STDIN_FILENO, &command, 32); // Use fixed length read instead of gets. gets may result in buffer overflow
    newline();
    if (strcmp(command, "uname") == 0) {
      write(STDOUT_FILENO, (char*)&uutsname, 45);
      newline();
    } else if (strcmp(command, "clear") == 0) {
      putchr(0x0C);
    } else if (strcmp("ls", command) == 0) {
      char buffer[144];
      char *bufferptr = buffer;
      int count = syscall(SYS_LIST, (int)buffer, 0, 0);
      for (int i = 0; i < count; i++) {
        putstr(bufferptr);
        newline();
        bufferptr += 12;
      }
    } else if (strncmp("./", command, 2) == 0) { /* run file */
      execl(command + 2, NULL);
    } else if (strcmp("test", command) == 0) {
      char msg[] = "Hello from shell!\n\r";
      int fd = open("TEST.TXT", O_CREAT | O_RDWR, 0);
      write(fd, msg, strlen(msg));
      close(fd);
    } else if(strncmp("cat ", command, 4) == 0) {
      char *fname = command+4;
      int filesize = syscall(SYS_FILESIZE, fname, 0, 0);
      if (filesize < 127) {
        char buffer[127];
        int fd = open(fname, O_RDONLY, 0);
        read(fd, buffer, filesize);
        write(STDOUT_FILENO, buffer, filesize);
        newline();
        close(fd);
      }
    } else {
      putstr("Unknown command\n\r");
    }
  }
}

