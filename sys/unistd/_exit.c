/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <sys/syscall.h>
#include <sys/unistd.h>

void _exit(int code) {
  syscall(SYS_EXIT, code, 0, 0);
}

void _exit_fastcall(int status) __preserves_regs(a,b,c,d,e,h,l) __z88dk_fastcall {
  syscall(SYS_EXIT, status, 0, 0);  
}