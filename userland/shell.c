// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025-2026 Benjamin Helle

#include <sys/unistd.h>
#include <sys/fcntl.h>
#include <sys/utsname.h>
#include <string.h>
#include <stdint.h>

/*
  Simple shell for Manux. This provides minimal interface for the kernel.
*/

/* builtin commands max */
#define NUM_BUILTIN 8

/* prototypes */
int buname(char **argv);
int bls(char **argv);
int bcat(char **argv);
int bclear(char **argv);
int bhelp(char **argv);

/* builtin commands*/
char *builtin_cmds[NUM_BUILTIN] = {
  "uname",
  "ls",
  "cat",
  "clear",
  "help",
  "\0",
  "\0",
  "\0",
};
/* replace "\0" with actual commands, the same with NULL */

/* pointer to the functions, function(argv)*/
int (*builtin_ptr[])(char**) = {
  &buname,
  &bls,
  &bcat,
  &bclear,
  &bhelp,
  NULL,
  NULL,
  NULL
};

int get_builtin_cmd(char *cmd) {
  /* pass parsed command to get_builtin_cmd, return index to the pointer*/
  for (uint8_t i = 0; i < NUM_BUILTIN; i++) {
    if (strcmp(builtin_cmds[i], cmd) == 0) {
      return i; /* return its index */
    }
  }
  return -1; /* no builtin command*/
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

int main(void) {
  uname(&uutsname);
  putstr("Manux Shell\n\rKernel version: ");
  //printf("Manux Shell\n\rKernel version: %s", (char*)uutsname.version); /* doesnt work, fix crt*/
  putstr(uutsname.release);
  putstr("\n\r");
  char command[128]; // Use fixed size array for command input
  while (1) {
    int code = 0;
    memset(command, 0, 128);
    putstr("$ ");
    read(STDIN_FILENO, &command, 128); // Use fixed length read instead of gets. gets may result in buffer overflow

    if (command[0] == '\0') { /* empty command? */
      continue;
    }

    /* parse command*/
    char *args = strchr(command, ' ');
    if (args != NULL) {
      *args = '\0';
      args++;
    }

    /* build argv array from args string */
    char *argvv[17]; /* 16 args max, including cmd + null */
    memset(argvv, 0, sizeof(argvv));
    int argc = 0;
    argvv[argc++] = command;

    if (args != NULL) { /* parse arguments to vector list */
      char *tok = strtok(args, " ");
      while (tok != NULL && argc < 16) {
        argvv[argc++] = tok;
        tok = strtok(NULL, " ");
      }
    }
    argvv[argc] = NULL; /* last element is null*/

    int builtin = get_builtin_cmd(argvv[0]);
    if (builtin != -1) { /* builtin command?*/
      code = builtin_ptr[builtin](argvv);
      continue;
    }

    if (strncmp("./", command, 2) == 0) { /* run file */
      code = execv(command + 2, argvv); /* execute with arguments */
      if (code == -1) putstr("No such file\n\r"); /* no valid program*/
      continue;
    }
    /* no valid command*/
    putstr("Unknown command\n\r");
  }
  return 0; /* should never reach here */
}

/* builtin command functions*/
int buname(char **argv) {
  /* uname, displays eg. kernel version*/
  write(STDOUT_FILENO, (char*)&uutsname, 45);
  newline();
  return 0;
}
int bls(char **argv) {
  /* list files */
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
  return 0;
}
int bcat(char **argv) {
  /* display file contents*/
  char *fname = argv[1];
  int fd = open(fname, O_RDONLY, 0);
  if (fd == -1) {
    putstr("Error opening file\n\r");
    return -1;
  }
  int filesize = syscall(SYS_FILESIZE, fname, 0, 0);
  if (filesize == -1) {
    putstr("Error getting file size\n\r");
    return -1;
  }
  char buffer[255];
  if (filesize < 255) {
    read(fd, buffer, filesize);
    write(STDOUT_FILENO, buffer, filesize);
    newline();
  } else { /* print file in 255 chunks*/
    uint16_t remaining = filesize;

    while (remaining > 0) {
      uint16_t to_read = (remaining < 255) ? remaining : 255;
      read(fd, buffer, to_read);
      write(STDOUT_FILENO, buffer, to_read);
      remaining -= to_read;
    }
  }
  close(fd);
  return 0;
}
int bclear(char **argv) {
  /* ansi clear screen, may not work on non-ansi terminals*/
  putstr("\x1B[2J\x1B[H");
  return 0;
}

int bhelp(char **argv) {
  putstr("Available commands:\n\r");
  for (uint8_t i = 0; i < NUM_BUILTIN; i++) {
    putstr(builtin_cmds[i]);
    putstr("\n\r");
  }
  return 0;
}