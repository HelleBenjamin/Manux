// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Benjamin Helle
#ifndef KERNEL_H
#define KERNEL_H

#ifndef KERNEL_WORKSPACE
#define KERNEL_WORKSPACE 0x9000
#endif

extern struct utsname uutsname;

void main(void);

#endif