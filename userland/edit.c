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
    scanf("%95s", buf);
    // read(0, buf, MAX_LINE_LEN);

    if (strcmp(buf, ".") == 0) break;
    strcpy(lines[num_lines++], buf);
  }
}

int main(int argc, char *argv[]) {

  if (argc > 1) { /* file specified */
    filefd = open(argv[1], O_RDWR | O_CREAT, 0644);
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
    }
  }

  close(filefd);

  return 0;
}