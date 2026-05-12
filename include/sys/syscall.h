// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025 Benjamin Helle

#ifndef SYSCALL_H
#define SYSCALL_H

#define SYS_EXIT      0
#define SYS_WRITE     1
#define SYS_READ      2
#define SYS_GETS      3
#define SYS_PUTS      4
#define SYS_PUTH      5
#define SYS_GETINFO   6
#define SYS_RAND      7
#define SYS_OPEN      8
#define SYS_CLOSE     9
#define SYS_SEEK      10
#define SYS_EXEC      11
#define SYS_LIST      12
#define SYS_FILESIZE  13

int syscall(unsigned char syscall_num, int arg1, int arg2, int arg3);



#endif