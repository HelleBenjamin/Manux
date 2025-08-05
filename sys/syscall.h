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
#define SYS_OPEN 12
#define SYS_CLOSE 13
#define SYS_CREATE 14
#define SYS_EXECS 15

short syscall(unsigned char syscall_num, short arg1, short arg2, short arg3);

void sysc_write(char fd, short count, char *buf);
void sysc_read(char fd, short count, char *buf);

#endif