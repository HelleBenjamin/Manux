// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle

#ifndef SYSCALL_H
#define SYSCALL_H

#define SYS_EXIT 0
#define SYS_WRITE 1
#define SYS_READ 2
#define SYS_GETS 3
#define SYS_PUTS 4
#define SYS_EXEC 5
#define SYS_GETINFO 6
#define SYS_RAND 7
#define SYS_SLEEP 8
#define SYS_FORK 9
#define SYS_GETPID 10
#define SYS_GETPCOUNT 11

void sysc_exit(short code) __z88dk_fastcall;
void sysc_write(char* filename, short count, char *buf);
void sysc_read(char* filename, short count, char *buf);
void sysc_gets(short len, char *str);
void sysc_puts(short len, char *str);
void sysc_exec(short *addr) __z88dk_fastcall;
void sysc_getinfo(char *str) __z88dk_fastcall;
void sysc_rand(short *buf) __z88dk_fastcall;
void sysc_sleep(short ms) __z88dk_fastcall;
void sysc_fork(void);
void sysc_getpid(char *buf) __z88dk_fastcall;
void sysc_getpcount(char *buf) __z88dk_fastcall;

#endif