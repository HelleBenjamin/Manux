/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2026 Benjamin Helle
* edit.c
* ed inspired text editor
*/

#ifdef __linux
#include <unistd.h>
#include <fcntl.h>
#else
/* Manux libraries */
#include <sys/unistd.h>
#include <sys/fcntl.h>
#endif
#include <stdint.h>
#include <string.h>
#include <stdio.h>

#define MAX_LINE_LEN 96
#define MAX_LINES 150

char lines[MAX_LINES][MAX_LINE_LEN];
int num_lines = 0;

int filefd = -1;

/* Lots of TODOs*/

void append(void) {
  char buf[MAX_LINE_LEN];
  while (1) {
    read(0, buf, MAX_LINE_LEN);

    /* stop when only a dot is read*/
    if (strcmp(buf, ".") == 0) break;
    if (num_lines >= MAX_LINES) {
      printf("Maximum number of lines reached\n");
      break;
    }
  
    strcpy(lines[num_lines++], buf);
  }
}

void print_lines(void) {
  for (int i = 0; i < num_lines; i++) {
    printf("%d\t%s\n", i+1, lines[i]);
  }
}

void load_file(void) {
  /* load file from the filefd*/
  char c;
  char buf[MAX_LINE_LEN];
  int i = 0;
  num_lines = 0;

  /* set initial position to 0*/
  lseek(filefd, 0, SEEK_SET);

  /* read the whole file byte by byte*/
  while (read(filefd, &c, 1) == 1) {
    if (c == '\r') continue; /* linefeed, continue*/

    /* newline, move to next line*/
    if (c == '\n') {
      buf[i] = 0; /* null terminate*/

      if (num_lines < MAX_LINES) {
        strcpy(lines[num_lines++], buf);
      }

      /* reset buffer position*/
      i = 0;
      continue;
    }

    if (i < (MAX_LINE_LEN-1)) { /* if fits in the buffer, put it*/
      buf[i++] = c;
    }
  }

  if (i > 0 && num_lines < MAX_LINES) { /* copy last line*/
    buf[i] = 0;
    strcpy(lines[num_lines++], buf);
  } 
}

int main(int argc, char *argv[]) {

  if (argc > 1) { /* file specified */
    filefd = open(argv[1], O_RDWR | O_CREAT, 0644);
    load_file();
  }

  printf("Edit - text editor\n");

  char cmd[128];
  while(1) {
    printf("> ");
    read(0, cmd, 128); /* read command*/

    if(strcmp(cmd, "q") == 0) {
      break;
    } else if (strcmp(cmd, "w") == 0) {
      /* write command */
      lseek(filefd, 0, SEEK_SET); /* zero position */
      for (int i = 0; i < num_lines; i++) {
        write(filefd, lines[i], strlen(lines[i]));
        write(filefd, "\n", 1);
      }
    } else if (strcmp(cmd, "a") == 0) {
      /* append command */
      append();
    } else if (strcmp(cmd, "p") == 0) {
      /* print lines*/
      print_lines();
    }
  }

  close(filefd);

  return 0;
}