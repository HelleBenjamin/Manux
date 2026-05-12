/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2026 Benjamin Helle
*/

#ifndef KSTDIO_H
#define KSTDIO_H

int kputchar(char c) __z88dk_fastcall;
int kputs(char *s) __z88dk_fastcall;
int kputslen(char *s, int len);
int kgetchar(void);
int kgetslen(char *s, int len);
void kputn(int n) __z88dk_fastcall;
void kputh(int n) __z88dk_fastcall;


#endif