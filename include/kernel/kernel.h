// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle
#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>

#define KERNEL_WORKSPACE 0x2000

#define KERNEL_FLAGS (KERNEL_WORKSPACE+0x08)

/* Program Info Header */
#define PIH_BASE      0x4000
#define PIH_MAGIC     (PIH_BASE+0x00)
#define PIH_SIZE      (PIH_BASE+0x02)
#define PIH_ENTRY     (PIH_BASE+0x04)
#define PIH_FLAGS     (PIH_BASE+0x06)
#define PIH_EXITCODE  (PIH_BASE+0x08)
#define PIH_ARGC      (PIH_BASE+0x0A)
#define PIH_ARGV      (PIH_BASE+0x0C)
#define PIH_CODE      (PIH_BASE+0x100)

#define MANUX_MAGIC   0x4D58 /* "MX" */

/* Stack definitions */
#ifndef REGISTER_SP
#define REGISTER_SP   0xFFFF
#endif
#define KERNEL_STACK  REGISTER_SP /* 2048 bytes*/
#define SHELL_SP      REGISTER_SP-0x800 /* 2048 bytes*/
#define SHELL_CODE_AREA 0x3000
#define USER_SP       0xEFFF /* Top of user area*/
#define USER_CODE_AREA 0x4100

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