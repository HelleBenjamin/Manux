// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle
#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>

#define KERNEL_WORKSPACE 0x2000

/* Program Info Header */
#define PIH_BASE      0x4000
#define PIH_MAGIC     (PIH_BASE+0x00)
#define PIH_SIZE      (PIH_BASE+0x02)
#define PIH_ENTRY     (PIH_BASE+0x04)
#define PIH_FLAGS     (PIH_BASE+0x06)
#define PIH_SP        (PIH_BASE+0x08)
#define PIH_RETURN    (PIH_BASE+0x0A)
#define PIH_EXITCODE  (PIH_BASE+0x0C)
#define PIH_ARGCNT    (PIH_BASE+0x0E)
#define PIH_ARGS      (PIH_BASE+0x10)
#define PIH_CODE      (PIH_BASE+0x20)

#define MANUX_MAGIC   0x4D58 /* "MX" */

/* Stack definitions */
#ifndef REGISTER_SP
#define REGISTER_SP   0xFFFF
#endif
#define KERNEL_STACK  REGISTER_SP /* 1024 bytes*/
#define SHELL_SP      REGISTER_SP-0x400 /* 1024 bytes*/
#define USER_SP       0xEFFF /* Top of user area*/

typedef struct {
  uint16_t magic;
  uint16_t size;
  uint16_t entry;
  uint16_t flags;
  uint16_t sp;
  uint16_t ret;
  uint16_t exitcode;
  uint16_t argc;
  char     args[16];
} PIH_t;


int kernel_main(void);
extern void kernel_panic(void);
int sysc_write(int fd, int count, char *buf);
int sysc_read(int fd, int count, char *buf);
int ksyscall(unsigned char syscall_num, int arg1, int arg2, int arg3);
int exec(char *fname, char *args);
int exec_init(char *fname) __z88dk_fastcall;
int create_PIH(void);

#endif