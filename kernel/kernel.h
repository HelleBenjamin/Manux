// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#ifndef KERNEL_H
#define KERNEL_H

#ifndef KERNEL_WORKSPACE
#define KERNEL_WORKSPACE 0x9000
#endif
#ifndef STACK_START
#define STACK_START 0xD000
#endif

#ifndef EXIT_CODE
#define EXIT_CODE (KERNEL_WORKSPACE + 14) // Exit code address
#endif
#ifndef PROCESS_STACK
#define PROCESS_STACK (STACK_START - 0xFF) // 0xFF bytes
#endif
#ifndef KERNEL_STACK
#define KERNEL_STACK (STACK_START - 0x200) // 0xFF bytes
#endif
#ifndef USER_STACK
#define USER_STACK (STACK_START - 0x300) // n bytes
#endif

extern struct utsname uutsname;

int main(void);

#endif