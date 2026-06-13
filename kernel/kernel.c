// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025-2026 Benjamin Helle
#include <kernel/kstdio.h>
#include <kernel/kernel.h>
#include <fs/mfs.h>
#include <fs/fd.h>
#include <driver/tty.h>
#include <string.h>

uint8_t* kernel_flags = (uint8_t*)KERNEL_FLAGS;

int kernel_main(void) {
  /* initialization order: 1.tty, 2.fs, 3.fd */
  tty_init();
  __asm__("ei\nim 1\n"); /* enable interrupts and set the interrupt mode to 1 */
  kputs("Manux Kernel\n");

  /* init main components*/
  if (mfs_init() == -1) { kputs(" Filesystem init failed\n"); kernel_panic(); }
  kputs(" FS init done\n");

  if (fd_init() == -1) { kputs(" File descriptor init failed\n"); kernel_panic(); }
  kputs(" FD init done\n");

  /* spawn shell */
  kputs(" Running init/shell\n");
  if (exec_init("SHELL.BIN") == -1) { kputs(" Shell/init failed\n"); }

  kernel_panic(); /* should never be reached*/
  return 0;
}

static PIH_t* pih = (PIH_t*)0x4000; /* program info header */

int execv(char *fname, char *argv[]) {
  if (load_executable(fname, USER_CODE_AREA) == -1) return -1; /* file not found, return immediately */

  file *file = find_file(fname);
  pih->size = file->size; /* copy file size, useless for now*/

  if (argv != NULL) {
    int argc = 0; /* argument count*/
    int strpos = 0; /*string position*/
    char *ptrv = pih->argv; /* argv table, points to 0x400C(or PIH_ARGV, defined in kernel.h) initially*/
    uint8_t offsets[16]; /* argument offsets, pointers*/
    memset(ptrv, 0, ARGV_SIZE); /* clear */

    /* a fancy pointer formula: ARGV_SIZE - (argc+1)*2 */

    /* step 1+2, copy each string to argv table and save the offsets*/
    while(argv[argc] != NULL && argc < 16) { /* max 16 arguments */
      int len = strlen(argv[argc])+1; /* +1 for null byte*/
      if (strpos + len > ARGV_SIZE - (16 * 2)) break; /* make sure that it doesn't overflow*/
      offsets[argc] = (uint8_t)strpos; /* offsets under 8-bit boundary*/
      memcpy(ptrv+strpos, argv[argc], len);
      strpos += len; /* update counts */
      argc++;
    }

    /* step 3, set pointers */
    int ptrpos = ARGV_SIZE - (argc+1)*2;
    for (uint8_t i = 0; i < argc; i++) {
      uint16_t addr = PIH_ARGV + offsets[i];
      ptrv[ptrpos+(i*2)] = addr & 0xFF; /* lower half */
      ptrv[ptrpos+(i*2)+1] = (addr >> 8) & 0xFF; /* higher half*/
    }

    /* null terminate*/
    ptrv[ptrpos+(argc*2)] = 0;
    ptrv[ptrpos+(argc*2)+1] = 0;

    pih->argc = argc; /* update to PIH*/
  } else { /* no arguments */
    pih->argc = 0;
    memset(pih->argv, 0, ARGV_SIZE);
  }

  /* jumps in the syscall handler*/

  return 0;
}

int exec_init(char *fname) __z88dk_fastcall {
  /* maybe make shell accept arguments from the kernel?*/
  /* runs the shell*/
  if (load_executable(fname, SHELL_CODE_AREA) == -1) { /* SHELL.BIN not found */
    return -1;
  }

  /* get the size of the shell file */
  file *shellfile = find_file(fname);
  int size = shellfile->size;

  __asm__ ( /* assembly function contains the jump*/
    "extern exec_init_jump\n"
    "jp exec_init_jump\n"
  );

  return 0;
}

int ksyscall(unsigned char syscall_num, int arg1, int arg2, int arg3) __naked {
  /* Kernel syscall wrapper*/

  __asm__ (
    "push ix\n"
    "ld ix, 0x0000\n"
    "add ix, sp\n"
    "ld a, (ix+0x04)\n" /* syscall number*/
    "ld l, (ix+0x05)\n" /* arg1 */
    "ld h, (ix+0x06)\n"
    "ld e, (ix+0x07)\n" /* arg2 */
    "ld d, (ix+0x08)\n"
    "ld c, (ix+0x09)\n" /* arg3 */
    "ld b, (ix+0x0a)\n"
    "rst 0x20\n" /* call syscall*/
    /* status in hl */
    "pop ix\n"
    "ret\n"
  );
  return 0;
}

/* syscall implementations in C*/
int sysc_write(int fd, int count, char *buf) {
  fd_entry *entry = &fd_table[fd];
  if (fd == -1) return -1; /* null */

  if (entry->type == FD_TYPE_STDOUT || entry->type == FD_TYPE_STDERR) { /* STDOUT or STDERR */
    return kputslen(buf, count);
  } 
  else { /* else write to file */
    return mfs_write(fd, buf, count);
  }
  return -1;
}

int sysc_read(int fd, int count, char *buf) {
  fd_entry *entry = &fd_table[fd];
  if (fd == -1) return -1; /* null */

  if (entry->type == FD_TYPE_STDIN) { /* STDIN */
    return kgetslen(buf, count);
  } 
  else { /* else read from file */
    return mfs_read(fd, buf, count);
  }
  return -1;
}