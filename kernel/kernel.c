// SPDX-License-Identifier: GPL-2.0-only
// Copyright (c) 2025-2026 Benjamin Helle
#include <kernel/kstdio.h>
#include <kernel/kernel.h>
#include <fs/mfs.h>
#include <fs/fd.h>
#include <driver/tty.h>
#include <string.h>

int kernel_main(void) {
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

int exec(char *fname, char *args) {
  if (load_to_memory(fname) == -1) return -1; /* file not found */

  /* setup the PIH*/
  file *file = find_file(fname);
  pih->size = file->size;
  //fd_entry *entry = &fd_table[fd];
  //pih->entry = entry->file->entry;
  //pih->size = entry->file->size;
  if (strlen(args) < 16) memcpy(pih->args, args, strlen(args)); /* copy args*/
  else if (strlen(args) > 16) memcpy(pih->args, args, 16); /* copy args within 16 bytes*/
  else if (args == NULL) memset(pih->args, 0, 16); /* clear args*/
  /* jumps in the syscall handler*/

  return 0;
}

int exec_init(char *fname) __z88dk_fastcall {
  /* runs the shell*/
  if (load_to_memory(fname) == -1) { /* SHELL.BIN not found */
    return -1;
  }

  /* get the size of the shell file */
  //fd_entry *entry = &fd_table[fd];
  //int size = entry->file->size;
  file *shellfile = find_file(fname);
  int size = shellfile->size;

  /* mfs_open reads by default to 0x4020, so copy the file to 0x3000 where the shell area lives */
  memcpy((uint8_t*)0x3000, (uint8_t*)0x4020, size);

  //mfs_close(fd);

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
    kputslen(buf, count);
  } 
  else { /* else write to file */
    mfs_write(fd, buf, count);
  }
  return count;
}

int sysc_read(int fd, int count, char *buf) {
  fd_entry *entry = &fd_table[fd];
  if (fd == -1) return -1; /* null */

  if (entry->type == FD_TYPE_STDIN) { /* STDIN */
    kgetslen(buf, count);
  } 
  else { /* else read from file */
    mfs_read(fd, buf, count);
  }
  return count;
}