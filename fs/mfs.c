/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <kernel/kernel.h>
#include <fs/mfs.h>
#include <fs/fd.h>
#include <string.h>
#include <kernel/kstdio.h>
#include <stdint.h>

/*
; Here's a (very) basic description of the file system:
; MFS 1.1 (Manux Filesystem)
; Similar to the FAT (File Allocation Table)
; 12 byte filenames
; 512 byte blocks
;
; Root FS (First FS sector):
; 2 bytes checksum
; 1 byte format flag
; 1 byte number of files
; 12x Files
;
; File structure:
; 1 byte flag(used/free)
; 1 byte file id
; 12 byte name
; 2 byte size (bytes)
; 1 byte block size (blocks )
; 2 byte pointer to first block
;
; Block structure:
; 1 byte flag(used/free)
; 2 byte next sector, 00 = EOF
; 1 reserved byte
; n bytes data
*/

static MFS *fs = (MFS *)FS_ROOT_MADDR;

static uint8_t *fs_rootfs = (uint8_t *)FS_ROOT_MADDR;
static uint8_t *tempbuf = (uint8_t *)FS_BUF; /* 512 bytes max, this should be used instead of using local buffers*/

int mfs_init(void) {
  /* Load filesystem root block to memory, etc..*/
  if(disk_read((char *)fs, FS_ROOT_SECTOR, 1) == 0) {
    if(fs->checksum != CHECKSUM) {
      kputs(" Root FS checksum incorrect. Some files may be corrupted\n");
    } if (fs->formatted == 0) {
      kputs(" Root FS not formatted yet. Format? (y/n): ");
      char input = kgetchar();
      if (input != 'y') { return -1; }
      mfs_format();
    }
    kputs(" Root FS loaded\n");
  } else { kputs(" Loading Root FS failed\n"); kernel_panic(); }
  return 0;
}

int mfs_format(void) {
  memset(fs, 0, 512); /* Setup root */
  fs->checksum = CHECKSUM;
  fs->formatted = 1;
  fs->filecount = 0;

  disk_write((char *)fs, FS_ROOT_SECTOR, 1);

  memset(tempbuf, 0, 512);
  for (uint16_t i = FS_BLOCK_SECTOR; i < FS_MAX_SECTORS; i++) {
    disk_write(tempbuf, i, 1);
  }

  return 0;
}

/* Run on shutdow/exit */
int mfs_exit(void) {
  /* Save root to disk*/
  write_changes();
  return 0;
}

void print_file_info(file *f) __z88dk_fastcall {
  kputs("File: ");
  kputs(f->name);
  kputchar('\n');
  kputs("Size: ");
  kputh(f->size);
  kputchar('\n');
  kputs("Block size: ");
  kputh(f->block_size);
  kputchar('\n');
  kputs("First Block: ");
  kputh(f->block);
  kputchar('\n');
}

void write_changes(void) {
  /* Save root to disk*/
  disk_write((char *)fs, FS_ROOT_SECTOR, 1);
}

/* Returns the sector of a free block*/
uint16_t find_free_block(void) {
  char tempbuf2[512];
  memset(tempbuf2, 0, 512);
  for (uint16_t i = FS_BLOCK_SECTOR; i < FS_MAX_SECTORS; i++) {
    disk_read(tempbuf2, i, 1);
    if (tempbuf2[0] == 0) {
      int is_allocated = 0;
      for (uint16_t j = 0; j < fs->filecount; ++j) {
        uint16_t next_block = fs->files[j].block;
        while (next_block != 0 && next_block < FS_MAX_SECTORS) {
          if (next_block == i) {
            is_allocated = 1;
            break;
          }
          disk_read(tempbuf, next_block, 1);
          next_block = *(uint16_t*)(tempbuf + 1);
        }
        if (is_allocated) break;
      }
      if (!is_allocated) {
        return i;
      }
    }
  }
  return 0;
}

file* find_file(char *fname) __z88dk_fastcall {
  for (uint8_t i = 0; i < fs->filecount; ++i) {
    if (strncmp(fname, fs->files[i].name, MAX_FNAME_LEN) == 0) {
      return &fs->files[i]; /* return pointer to the file*/
    }
  }
  return NULL;
}

uint16_t get_file_block(char *fname) __z88dk_fastcall {
  for (uint8_t i = 0; i < fs->filecount; ++i) {
    if (strncmp(fname, fs->files[i].name, MAX_FNAME_LEN) == 0) {
      return fs->files[i].block;
    }
  }
  return 0;
}

uint8_t get_file_index(char *fname) __z88dk_fastcall {
  for (uint8_t i = 0; i < fs->filecount; ++i) {
    if (strncmp(fname, fs->files[i].name, MAX_FNAME_LEN) == 0) {
      return i;
    }
  }
  return 0xFF;
}

int load_executable(char *fname, uint16_t addr) {
  /* load a file to fixed address 0x4020, mainly used for executables*/
  int i = get_file_index(fname);
  if (i == 0xFF) return -1;

  int16_t remaining = fs->files[i].size;
  uint16_t bytes_in_block = 0;
  uint16_t sector = fs->files[i].block; /* First sector, 1 block = 512 bytes = 1 sector*/

  uint16_t offset = 0x0000; /* Space for PIH, kernel creates the PIH */
  uint8_t* dest = (uint8_t*)addr;

  while (remaining != 0 && sector != 0 && sector < FS_MAX_SECTORS) {
    bytes_in_block = (remaining > BLOCK_SIZE-4) ? (BLOCK_SIZE-4) : remaining;
    disk_read(tempbuf, sector, 1);

    memcpy((uint8_t*)dest+offset, tempbuf+4, bytes_in_block);

    offset += bytes_in_block;
    remaining -= bytes_in_block;
    sector = *(uint16_t*)(tempbuf + 1); /* next sector */
  }

  return 0;
}

uint16_t get_file_size(char *fname) __z88dk_fastcall {
  file* tempfile;
  tempfile = find_file(fname);
  if (tempfile == NULL) return -1;
  return tempfile->size;
}

int mfs_open(char *fname, int flags) {
  /* Opens a file, load it to memory*/
  file* current_file = find_file(fname);
  if (current_file == NULL && (flags & O_CREAT)) { /* if file doesn't exist, create it */
    /* safety checks */
    volatile uint16_t block = find_free_block(); /* remove volatile?*/
    if (block == 0 || fs->filecount >= MAX_FILES) {
      return -1; /* No free blocks or block allocation failed */
    }

    uint8_t index = 0;
    /* find free nameslot*/
    for (index = 0; index < MAX_FILES; ++index) {
      if (fs->files[index].used == 0) break;
    }

    if (index == MAX_FILES) {
      return -1; /* No free nameslots */
    }

    strncpy(fs->files[index].name, &fname[0], MAX_FNAME_LEN-1); /* copy filename*/
    fs->files[index].used = 1; /* mark used*/
    fs->files[index].flags = (flags & ~O_CREAT); /* include user flags*/
    fs->files[index].size  = 0;     /* default to 0*/
    fs->files[index].block_size = 0;
    fs->files[index].block = block; /* initial start block */

    memset(tempbuf, 0, 512); /* blank block*/
    tempbuf[0] = 1; /* mark used */
    disk_write(tempbuf, block, 1); /* Reserve first block, write it immediately */

    ++fs->filecount; /* update filecount */
    current_file = &fs->files[index];
    write_changes(); /* save changes to disk*/
  } else if (current_file == NULL) {
    return -1; /* file doesn't exist */
  }

  /* create file descriptor for it*/
  fd_entry entry;
  entry.type = FD_TYPE_FILE;
  entry.file = current_file;
  entry.flags = 0;

  int acc = flags & O_ACCMODE;
  /* flag setup*/
  if (acc == O_RDONLY) {
    entry.flags |= FD_FLAGS_READ;
    entry.pos = 0; /* position is always 0, change with seek*/
  } else if (acc == O_WRONLY) {
    entry.flags |= FD_FLAGS_WRITE;
    /* append and truncate is only allowed in write mode*/
    if (flags & O_APPEND) entry.pos = current_file->size;
    else if (flags & O_TRUNC) entry.pos = 0;
    else entry.pos = 0;
  } else if (acc == O_RDWR) {
    entry.flags |= FD_FLAGS_READ | FD_FLAGS_WRITE;
    /* append and truncate is only allowed in write mode, in read mode it may cause problems?*/
    if (flags & O_APPEND) entry.pos = current_file->size;
    else if (flags & O_TRUNC) entry.pos = 0;
    else entry.pos = 0;
  }
  entry.cur_block = current_file->block;
  entry.block_offset = 0;
  entry.prev_block = 0;

  return fd_create(&entry); /* return FD, */
}

int mfs_close(int fd) __z88dk_fastcall {
  fd_entry *entry = fd_get(fd);
  if (entry == NULL) {
    return -1; /* FD not found*/
  }

  if (entry->type == FD_TYPE_FILE) {
    /* save changes to disk*/
    write_changes();
  }

  entry->file = NULL; /* mark unused, prevent looping bugs*/

  return fd_close(fd);
}

int mfs_read(int fd, char *buf, uint16_t count) {
  /* read from memory */
  fd_entry *entry = fd_get(fd);
  if (entry == NULL) {
    return -1;
  }

  if (!(entry->flags & FD_FLAGS_READ) || entry->type != FD_TYPE_FILE) {
    return -1; /* non readable or not a file*/
  }

  if (entry->pos >= entry->file->size) {
    return 0 /* EOF*/;
  }

  uint16_t remaining = count; /* remaining bytes to read*/
  uint16_t written = 0; /* bytes written*/

  while (remaining > 0 && entry->cur_block != 0 && entry->cur_block < FS_MAX_SECTORS && entry->pos < entry->file->size) {
    disk_read(tempbuf, entry->cur_block, 1); /* read current block*/
    uint16_t available = (BLOCK_SIZE-4) - entry->block_offset; /* available bytes*/
    uint16_t to_read = (remaining < available) ? remaining : available;

    uint16_t bytes_left = entry->file->size - entry->pos;
    if (bytes_left < to_read) { /* check if there are enough bytes left to read */
      to_read = bytes_left;
    }

    memcpy(buf+written, tempbuf+4+entry->block_offset, to_read); /* copy bytes to buffer*/

    /* update positions */
    written += to_read;
    remaining -= to_read;
    entry->pos += to_read;
    entry->block_offset += to_read;

    if (entry->block_offset >= (BLOCK_SIZE-4)) { /* next block?*/
      entry->block_offset = 0;
      entry->cur_block = *(uint16_t*)(tempbuf + 1); /* next block*/
    }
  }

  return written; /* return bytes read*/
}

int mfs_write(int fd, char *buf, uint16_t count) {
  /* write to memory */
  fd_entry *entry = fd_get(fd);
  if (entry == NULL) {
    return -1;
  }

  if (!(entry->flags & FD_FLAGS_WRITE) || entry->type != FD_TYPE_FILE) {
    return -1; /* non writeable or not a file*/
  }

  uint16_t remaining = count; /* remaining bytes to read*/
  uint16_t written = 0; /* bytes written*/ 

  while (remaining > 0) {
    if (entry->cur_block == 0 || entry->cur_block >= FS_MAX_SECTORS) {
      uint16_t block = find_free_block();
      if (block == 0) return -1; /* out of space*/

      /* init the new block */
      memset(tempbuf, 0, 512); /* blank block */
      tempbuf[0] = 1; /* used */
      *(uint16_t*)(tempbuf + 1) = 0; /* EOF for now*/
      disk_write((char*)tempbuf, block, 1);

      /* if we have previous block, write it to point to the current block*/
      if (entry->prev_block != 0) {
        uint8_t temp[512];
        disk_read((char*)temp, entry->prev_block, 1);
        *(uint16_t*)(temp + 1) = block; /* point to current block */
        disk_write((char*)temp, entry->prev_block, 1);
      } else {
        entry->file->block = block; /* first block*/
      }
      entry->cur_block = block;
      entry->block_offset = 0;
    }

    disk_read((char*)tempbuf, entry->cur_block, 1); /* read current block*/
    uint16_t space_left = (BLOCK_SIZE-4) - entry->block_offset; /* available bytes*/
    uint16_t to_write = (remaining < space_left) ? remaining : space_left;

    memcpy(tempbuf+4+entry->block_offset, buf+written, to_write); /* copy bytes to block buffer*/
    disk_write((char*)tempbuf, entry->cur_block, 1); /* write the block*/

    /* update variables*/
    written += to_write;
    remaining -= to_write;
    entry->pos += to_write;
    entry->block_offset += to_write;

    if (entry->pos > entry->file->size) { /* update file size, if bigger*/
      entry->file->size = entry->pos;
    }

    if (entry->block_offset >= (BLOCK_SIZE-4)) { /* next block?*/
      uint16_t next = *(uint16_t*)(tempbuf + 1);
      entry->prev_block = entry->cur_block; /* update the previous block to the current block*/
      entry->cur_block = next; /* next block*/
      entry->block_offset = 0;
    }
  }

  return written; /* return bytes written*/
}

int mfs_sync(void) {
  /* save all changes to disk */
  //save_to_disk(current_file->name);
  disk_write((char *)fs_rootfs, FS_ROOT_SECTOR, 1); /* root block */
  return 0;
}

int mfs_seek(int fd, uint16_t pos, int whence) {
  fd_entry *entry = fd_get(fd);
  if (entry == NULL || entry->type != FD_TYPE_FILE) {
    return -1;
  }

  uint16_t block = entry->file->block;
  uint16_t offset; /* read offset*/
  if (whence == SEEK_SET) { /* absolute*/
    offset = pos;
  } else if (whence == SEEK_CUR) { /* from current position*/
    offset = entry->pos + pos;
  } else if (whence == SEEK_END) { /* from the end of the file*/
    offset = entry->file->size + pos;
  }

  while (offset >= (BLOCK_SIZE-4) && block != 0 && block < FS_MAX_SECTORS) {
    disk_read(tempbuf, block, 1);
    block = *(uint16_t*)(tempbuf + 1);
    offset -= (BLOCK_SIZE-4);
  }

  /* update variables*/
  entry->pos = pos;
  entry->cur_block = block;
  entry->block_offset = offset;
  return 0;
}

int dump_fs(void) {
  kputs("Filesystem debug info:\n");
  kputs("Checksum: "); kputh(fs->checksum); kputs("\n");
  kputs("Formatted: "); kputh(fs->formatted); kputs("\n");
  kputs("Filecount: "); kputh(fs->filecount); kputs("\n");
  kputs("Filetable: ");
  for (uint8_t i = 0; i < fs->filecount; ++i) {
    kputs(fs->files[i].name);
    kputchar(' ');
  }
  kputs("\n");
  return 0;
}

int mfs_delete(char *fname) __z88dk_fastcall {
  /* delete a file from disk*/
  file* tempfile = find_file(fname);
  if (tempfile == NULL) return -1; /* file doesn't exist */
  
  uint16_t remaining_blocks = tempfile->block_size;
  uint16_t current_block = tempfile->block;
  uint16_t next_block;
  uint8_t zerobuf[512];
  memset(zerobuf, 0, 512);

  while (current_block != 0 && current_block < FS_MAX_SECTORS) {
    disk_read(tempbuf, current_block, 1);
    next_block = *(uint16_t *)(tempbuf + 1);
    disk_write(zerobuf, current_block, 1);  // erase current, not next
    current_block = next_block;
  }

  /* delete the file from the filetable, zero it */
  memset(tempfile, 0, sizeof(file));
  /*tempfile->used = 0;
  tempfile->flags = 0;
  tempfile->size = 0;
  tempfile->block = 0;
  tempfile->block_size = 0;*/

  --fs->filecount;

  /* update the root block immediately*/
  write_changes();

  return 0;
}

int mfs_list(char *buf) __z88dk_fastcall {
  /* copy the filenames to the buffer, returns count */
  for (uint8_t i = 0; i <fs->filecount; ++i) {
    memcpy(buf, fs->files[i].name, MAX_FNAME_LEN);
    buf += MAX_FNAME_LEN;
  }

  return fs->filecount;
}

int mfs_filesize(char *fname) __z88dk_fastcall {
  file* tempfile = find_file(fname);
  if (tempfile == NULL) return -1; /* file doesn't exist */
  return tempfile->size;
}

int disk_read(char *buffer, uint16_t sector, uint8_t num_sectors) __naked {
  /* Wrapper for the assembly function*/
  __asm__ (
    "push ix\n"
    "ld ix, 0x0000\n"
    "add ix, sp\n"
    "ld a, (ix+8)\n" /* read count*/
    "ld e, (ix+6)\n" /* sector */
    "ld d, (ix+7)\n"
    "ld l, (ix+4)\n" /* buffer */
    "ld h, (ix+5)\n"
    "extern READ_DISK\n"
    "call READ_DISK\n"
    "ld l, a\n" /* status in a*/
    "ld h, 0\n"
    "pop ix\n"
    "ret\n"
  );

  return 0;
}

int disk_write(char *buffer, uint16_t sector, uint8_t num_sectors) __naked {
  /* Wrapper for the assembly function*/
  __asm__ (
    "push ix\n"
    "ld ix, 0x0000\n"
    "add ix, sp\n"
    "ld a, (ix+8)\n" /* read count*/
    "ld e, (ix+6)\n" /* sector */
    "ld d, (ix+7)\n"
    "ld l, (ix+4)\n" /* buffer */
    "ld h, (ix+5)\n"
    "extern WRITE_DISK\n"
    "call WRITE_DISK\n"
    "ld l, a\n" /* status in a*/
    "ld h, 0\n"
    "pop ix\n"
    "ret\n"
  );

  return 0;
}
