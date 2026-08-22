// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle
#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>

#ifndef KERNEL_WORKSPACE
#define KERNEL_WORKSPACE 0x2000
#endif

#define KERNEL_FLAGS (KERNEL_WORKSPACE+0x08)

/* Program Info Header */
#ifndef USER_AREA
#define USER_AREA 0x5000
#endif
#ifndef PIH_BASE
#define PIH_BASE      0x4F00
#endif
#define PIH_MAGIC     (PIH_BASE+0x00)
#define PIH_SIZE      (PIH_BASE+0x02)
#define PIH_ENTRY     (PIH_BASE+0x04)
#define PIH_FLAGS     (PIH_BASE+0x06)
#define PIH_EXITCODE  (PIH_BASE+0x08)
#define PIH_ARGC      (PIH_BASE+0x0A)
#define PIH_ARGV      (PIH_BASE+0x0C)
#define PIH_CODE      USER_AREA

#define MANUX_MAGIC   0x4D58 /* "MX" */

/* Stack definitions */
#ifndef STACK_BASE
#define STACK_BASE    0x3000
#endif

#define KERNEL_STACK  STACK_BASE+0x7FF /* 2048 bytes*/


/* shell*/
#ifndef SHELL_AREA
#define SHELL_AREA 0x3800
#endif
#define SHELL_CODE_AREA SHELL_AREA
#define SHELL_SP      SHELL_AREA+0x1000+0x3FF /* 1024 bytes*/

/* userland*/
#ifndef USER_STACK
#define USER_STACK    0xFFFF
#endif
#define USER_SP       USER_STACK /* Top of user area*/

#define USER_CODE_AREA USER_AREA

#define ARGV_SIZE 242

extern uint8_t* kernel_flags;

typedef struct {
  uint16_t magic;
  uint16_t size;
  uint16_t entry;
  uint16_t flags;
  uint16_t exitcode;
  uint16_t argc;
  char     argv[ARGV_SIZE];
} PIH_t;


int kernel_main(void);
extern void kernel_panic(void);
int sysc_write(int fd, int count, char *buf);
int sysc_read(int fd, int count, char *buf);
int ksyscall(unsigned char syscall_num, int arg1, int arg2, int arg3);
int execv(char *fname, char *argv[]);
int exec_init(char *fname) __z88dk_fastcall;
int create_PIH(void);

#endif