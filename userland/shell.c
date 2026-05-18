// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025-2026 Benjamin Helle

#include <sys/unistd.h>
#include <sys/fcntl.h>
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

/* todo: make a proper shell with busybox like commands*/

void terminal(void) {
  uname(&uutsname);
  putstr("Manux Shell\n\rKernel version: ");
  //printf("Manux Shell\n\rKernel version: %s", (char*)uutsname.version); /* doesnt work, fix crt*/
  putstr(uutsname.release);
  putstr("\n\r");
  char command[128]; // Use fixed size array for command input
  while (1) {
    memset(command, 0, 128);
    putstr("$ ");
    read(STDIN_FILENO, &command, 128); // Use fixed length read instead of gets. gets may result in buffer overflow
    newline();
    if (strcmp(command, "uname") == 0) {
      write(STDOUT_FILENO, (char*)&uutsname, 45);
      newline();
    } else if (strcmp(command, "clear") == 0) {
      putchr(0x0C);
    } else if (strcmp("ls", command) == 0) {
      char buffer[144]; 
      char *bufferptr = buffer;
      int count = syscall(SYS_LIST, (int*)buffer, 0, 0);
      putstr("File count: ");
      puthex(count);
      newline();
      for (int i = 0; i < count; i++) {
        putstr(bufferptr);
        newline();
        bufferptr += 12; /* 12 is the filesize*/
      }
    } else if (strncmp("./", command, 2) == 0) { /* run file */
      /* parse arguments*/
      char *args = strchr(command, ' ');
      if (args != NULL) {
        *args = '\0';
        args++;
      }

      /* build argv array from args string */
      char *argvv[16 + 1]; /* 16 args max + null */
      int argc = 0;
      argvv[argc++] = command + 2; /* filename is also an arg*/

      if (args != NULL) { /* parse arguments to vector list */
        char *tok = strtok(args, " ");
        while (tok != NULL && argc < 16) {
          argvv[argc++] = tok;
          tok = strtok(NULL, " ");
        }
      }
      argvv[argc] = NULL; /* last element is null*/
      execv(command + 2, argvv); /* execute with arguments */

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

