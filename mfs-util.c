/* SPDX-License-Identifier: GPL-2.0-only
* Copyright (c) 2025-2026 Benjamin Helle
*/

#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

/*
; Here's a (very) basic description of the file system:
; MFS 1.1 (Manux Filesystem)
; Similar to the FAT (File Allocation Table)
; 12 byte filenames
; 512 byte blocks
;
; Root FS (First FS sector):
; 2 byte checksum
; 1 byte format flag
; 1 byte number of files
; 12x Files
;
; File structure:
; 1 byte flag(used/free)
; 12 byte name
; 2 byte size
; 1 byte block size
; 2 byte ptr to first block
;
; Block structure:
; 1 byte flag(used/free)
; 2 byte next sector, 00 = EOF
; 1 reserved byte
; n bytes data
*/

int mfs_delete(char *fname);

/* This is a tool which is used to write files into MFS formated disk images */
/* Use this only on Linux, etc. Not intended for use on Manux. */

FILE* disk;

#define BLOCK_SIZE    512 /* Single sector */
#define MAX_FILES     12
#define MAX_FNAME_LEN 12

/* Checksum is also version dependent, for example v1.1 is 0xBEEF */
#define CHECKSUM      0xBEEF /* v1.1 */

#define FS_BUF        0x0000 /* Single sector sized buffer */
#define FS_ROOT_MADDR 0x0200 /* Start of root directory in emulated RAM */

#define FS_ROOT_SECTOR  0 /* Start of Root directory */
#define FS_BLOCK_SECTOR (FS_ROOT_SECTOR+1) /* Start of File blocks */
#define FS_MAX_SECTORS  2879 /* Max sectors that the FS can use */

/* file flags*/
#define FRO      0x01
#define FWO      0x02
#define FRW      0x03

/* from sys/fcntl.h */
/* file open */
#define O_RDONLY    0x00
#define O_WRONLY    0x01
#define O_RDWR      0x02
#define O_ACCMODE   0x03

/* file create */
#define O_CREAT     0x200

typedef struct __attribute__((packed)) {
  uint8_t   used; /* used flag */
  uint8_t   flags; /* file flags, read/write*/
  uint8_t   id; /* file id*/
  char      name[12];
  uint16_t  size; /* file size on bytes */
  uint8_t   block_size; /* number of blocks allocated */
  uint16_t  block;   /* Start block */
} file; /* 20 bytes*/

/* Root FS structure */
typedef struct {
  uint16_t  checksum;
  uint8_t   formatted;
  uint8_t   filecount;
  file      files[MAX_FILES];
} MFS;


typedef struct {
  file* file;
  uint16_t pos; /* rw position*/
  uint16_t open;
} mfs_fd;


char fs_emulation_buf[0x2000];
char fs_program_buf[0x4000];
char temppbuf[512];
/*pointers to the emulated fs*/
static uint8_t *fs_rootfs = (uint8_t *)(fs_emulation_buf + FS_ROOT_SECTOR*512); /* should point to fs_emulation_buf[0]*/
static uint8_t *tempbuf   = (uint8_t *)temppbuf; /* should point to temppbuf[0]*/

static uint8_t *checksum = (uint8_t *)(fs_emulation_buf+0); /* should point to s_emulation_buf[0]]*/
static uint8_t *formatted = (uint8_t *)(fs_emulation_buf+2); /* should point to s_emulation_buf[2]]*/
static uint8_t *filecount = (uint8_t *)(fs_emulation_buf+3); /* should point to s_emulation_buf[3]]*/
static file *files = (file *)(fs_emulation_buf+4); /* should point to s_emulation_buf[4]->]*/
static mfs_fd current_fd;
static file* current_file;


int disk_read(char *buffer, uint16_t sector, uint8_t num_sectors) {
  /* emulate disk read */
  if (!disk) return 1;

  if (fseek(disk, (long)sector * BLOCK_SIZE, SEEK_SET) != 0) return 1;

  size_t n = fread(buffer, BLOCK_SIZE, num_sectors, disk);
  return (n == num_sectors) ? 0 : 1;
}

int disk_write(char *buffer, uint16_t sector, uint8_t num_sectors) {
  /* emulate disk write */
  if (!disk) return 1;

  if (fseek(disk, (long)sector * BLOCK_SIZE, SEEK_SET) != 0) return 1;

  size_t n = fwrite(buffer, BLOCK_SIZE, num_sectors, disk);
  fflush(disk);
  return (n == num_sectors) ? 0 : 1;
}

int mfs_init(void) {
  /* Load filesystem to memory, etc..*/
  if(disk_read((char *)fs_rootfs, FS_ROOT_SECTOR, 1) == 0) {
    if(*((uint16_t *)checksum) != CHECKSUM) {
      printf(" Root FS checksum incorrect. Filesystem may not be formatted or is wrong version\n");
      printf("Read checksum: 0x%04X, expected: 0x%04X\n", *((uint16_t *)checksum), CHECKSUM);
    } if (*formatted == 0) {
      printf(" Root FS not formatted yet. It needs to be formatted. Format with ./mfs-util -f\n");
    }
    printf(" Root FS loaded\n");
  } else { printf(" Loading Root FS failed\n"); return 1; }
  memset(&current_fd, 0, sizeof(mfs_fd));
  return 0;
}

int mfs_format(void) {
  memset(tempbuf, 0, 512); /* Setup root */

  *(uint16_t *)(tempbuf + 0) = CHECKSUM; /* bytes 0-1: checksum */
  *(uint8_t  *)(tempbuf + 2) = 1; /* byte 2: format flag */
  *(uint8_t  *)(tempbuf + 3) = 0; /* byte 3: filecount */

  *(uint16_t *)checksum = CHECKSUM;
  *formatted = 1;

  disk_write((char *)tempbuf, FS_ROOT_SECTOR, 1);

  memset(tempbuf, 0, 512);
  for (uint16_t i = FS_BLOCK_SECTOR; i < FS_MAX_SECTORS; i++) {
    disk_write((char *)tempbuf, i, 1);
  }

  return 0;
}
void write_changes(void);

/* Run on shutdow/exit */
int mfs_exit(void) {
  /* Save root to disk*/
  write_changes();
  return 0;
}

void write_changes(void) {
  /* Save root, and other loaded files, save them on disk*/
  disk_write((char *)fs_rootfs, FS_ROOT_SECTOR, 1);
}

/* Returns the sector of a free block*/
uint16_t find_free_block(void) {
  char tempbuf2[512];
  memset(tempbuf2, 0, 512);
  for (uint16_t i = FS_BLOCK_SECTOR; i < FS_MAX_SECTORS; i++) {
    disk_read(tempbuf2, i, 1);
    if (tempbuf2[0] == 0) {
      int is_allocated = 0;
      for (uint16_t j = 0; j < MAX_FILES; ++j) {
        uint16_t next_block = files[j].block;
        while (next_block != 0 && next_block < FS_MAX_SECTORS) {
          if (next_block == i) {
            is_allocated = 1;
            break;
          }
          disk_read((char *)tempbuf, next_block, 1);
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

file* find_file(char *fname) {
  for (uint8_t i = 0; i < MAX_FILES; ++i) {
    if (strncmp(fname, files[i].name, MAX_FNAME_LEN) == 0) {
      return &files[i]; /* return pointer to the file*/
    }
  }
  return NULL;
}

uint16_t get_file_block(char *fname) {
  for (uint8_t i = 0; i < MAX_FILES; ++i) {
    if (strncmp(fname, files[i].name, MAX_FNAME_LEN) == 0) {
      return files[i].block;
    }
  }
  return 0;
}

uint8_t get_file_index(char *fname) {
  for (uint8_t i = 0; i < MAX_FILES; ++i) {
    if (strncmp(fname, files[i].name, MAX_FNAME_LEN) == 0) {
      return i;
    }
  }
  return 0xFF;
}

uint16_t load_to_memory(char *fname) {
  /* load a file to fixed address 0x4000*/
  int i = get_file_index(fname);
  if (i == 0xFF) return 1;

  int16_t remaining = files[i].size;
  uint16_t bytes_in_block = 0;
  uint16_t sector = files[i].block; /* First sector, 1 block = 512 bytes = 1 sector*/

  uint16_t offset = 0x0000; /* Space for PIH, kernel creates the PIH */
  uint8_t* dest = (uint8_t*)fs_program_buf;

  while (remaining != 0 && sector != 0 && sector < FS_MAX_SECTORS) {
    bytes_in_block = (remaining > BLOCK_SIZE-4) ? (BLOCK_SIZE-4) : remaining;
    disk_read((char *)tempbuf, sector, 1);

    memcpy((uint8_t*)dest+offset, tempbuf+4, bytes_in_block);

    offset += bytes_in_block;
    remaining -= bytes_in_block;
    sector = *(uint16_t*)(tempbuf + 1); /* next sector */
  }
  return 0;

}

uint16_t save_to_disk(char *fname) {
  int i = get_file_index(fname);
  if (i == 0xFF) return 1;

  /* automatically overwrite the existing file*/
  file temp = files[i];
  mfs_delete(fname); /* delete it first */
  (*filecount)++; /* dirty hack*/

  /* figure out how many blocks we need */
  int16_t remaining = temp.size;
  uint8_t num_blocks = 0;
  int16_t r = remaining;
  while (r > 0) { r -= (BLOCK_SIZE-4); num_blocks++; }

  /* pre allocate all block sectors */
  uint16_t block_sectors[64]; /* adjust if needed*/
  uint8_t localbuf[512];
  for (uint8_t i = 0; i < num_blocks; i++) {
    /* temporarily mark previous finds as used so find_free_block skips them*/
    if (i > 0) {
      disk_read((char*)localbuf, block_sectors[i-1], 1);
      localbuf[0] = 1;
      disk_write((char*)localbuf, block_sectors[i-1], 1);
    }
    block_sectors[i] = find_free_block();
    if (block_sectors[i] == 0) return 1; /* out of space*/
  }

  /* todo: dynamically allocate to ram*/
  uint16_t offset = 0x0000;
  uint8_t *src = (uint8_t*)fs_program_buf;
  temp.block = block_sectors[0];
  temp.block_size = 0;

  /* now write all blocks */
  for (uint8_t i = 0; i < num_blocks; i++) {
    uint16_t bytes_in_block = (remaining > BLOCK_SIZE-4) ? (BLOCK_SIZE-4) : remaining;
    memset(localbuf, 0, 512);
    localbuf[0] = 1; // used
    *(uint16_t*)(localbuf+1) = (i < num_blocks-1) ? block_sectors[i+1] : 0; // next or EOF
    memcpy(localbuf+4, src+offset, bytes_in_block);
    disk_write((char*)localbuf, block_sectors[i], 1);

    offset += bytes_in_block;
    remaining -= bytes_in_block;
    temp.block_size++;
  }

  /* update the file table */
  files[i] = temp;
  files[i].block = block_sectors[0];

  return 0;
}

void list_files(void) {
  printf("File list:\n");
  for (uint8_t i = 0; i < *filecount; ++i) {
    printf("%s %d %d\n", files[i].name, files[i].size, files[i].block);
  }
}

uint16_t get_file_size(char *fname) {
  file* tempfile;
  tempfile = find_file(fname);
  if (tempfile == NULL) return 1;
  return tempfile->size;
}

int mfs_open(char *fname, int flags) {
  /* Opens a file, load it to memory*/
  current_file = find_file(fname);
  if (current_file == NULL && (flags & O_CREAT)) { /* if file doesn't exist, create it */
    /* safety checks */
    volatile uint16_t block = find_free_block(); /* Must use volatile to avoid compiler optimization which fucks these up*/
    if (block == 0 || *filecount >= MAX_FILES) {
      return 2; /* No free blocks or block allocation failed */
    }

    uint8_t index = 0;
    /* find free nameslot*/
    for (index = 0; index < MAX_FILES; ++index) {
      if (files[index].used == 0) break;
    }

    if (index == MAX_FILES) {
      return 3; /* No free nameslots */
    }

    strncpy(files[index].name, &fname[0], MAX_FNAME_LEN-1); /* copy filename*/
    files[index].used = 1; /* mark used */
    files[index].flags = (flags & ~O_CREAT); /* include user flags*/
    files[index].size  = 0;     /* default to 0*/
    files[index].block_size = 0;
    files[index].block = block; /* initial start block */

    memset(tempbuf, 0, 512); /* blank block*/
    *(tempbuf) = 1; /* mark used */
    disk_write((char *)tempbuf, block, 1); /* Reserve first block, write it immediately */

    ++(*filecount); /* update filecount */
    write_changes();

    current_file = &files[index];
  } else if (current_file == NULL) return -1; /* file doesn't exist and O_CREAT not set */

  /* fd points to current file*/
  current_fd.file = current_file;

  /* load it to memory*/
  int code = load_to_memory(current_file->name);

  return code;
}

int mfs_close() {
  if (current_fd.file == NULL) return 1; /* not open */
  current_fd.file = NULL;
  current_fd.open = 0;
  /* write to the disk*/
  int code = save_to_disk(current_file->name);
  current_file = NULL;
  return code;
}

int mfs_read(char *buf, uint16_t count) {
  if (current_file == NULL) {
    return 1; /* current file not available, use open first */
  }
  /* read from memory */
  /* TODO: add position*/
  memcpy(buf, (uint8_t*)fs_program_buf, count); /* simple as it is*/

  return 0;
}

int mfs_write(char *buf, uint16_t count) {
  if (current_file == NULL) {
    return 1; /* current file not available */
  }
  /* write to memory */
  /* TODO: add position*/
  //current_file->size += count; // when position added
  current_file->size = count; /* for now */
  memcpy((uint8_t*)fs_program_buf, buf, count); /* simple as it is again, it's way easier to work in memory than on the disk*/

  return 0;
}

int mfs_sync() {
  /* save all changes to disk */

  disk_write((char *)fs_rootfs, FS_ROOT_SECTOR, 1); /* root block */
  return 0;
}

int dump_fs() {
  printf("Filesystem info:\n");
  printf("Checksum: %04x\n", *(uint16_t *)checksum);
  printf("Formatted: %d\n", *formatted);
  printf("Filecount: %d\n", *filecount);
  printf("Files: ");
  for (uint8_t i = 0; i < *filecount; ++i) {
    printf("%s ", files[i].name);
  }
  printf("\n");
  return 0;
}

int mfs_delete(char *fname) {
  /* delete a file from disk*/
  file* tempfile = find_file(fname);
  if (tempfile == NULL) return 1; /* file doesn't exist */
  
  uint16_t remaining_blocks = tempfile->block_size;
  uint16_t current_block = tempfile->block;
  uint16_t next_block;
  uint8_t zerobuf[512];
  memset(zerobuf, 0, 512);

  while (current_block != 0 && current_block < FS_MAX_SECTORS) {
    disk_read((char *)tempbuf, current_block, 1);
    next_block = *(uint16_t *)(tempbuf + 1);
    disk_write((char *)zerobuf, current_block, 1);  // erase current, not next
    current_block = next_block;
  }

  /* delete the file from the filetable */
  tempfile->flags = 0; /* mark free */
  tempfile->size = 0;
  tempfile->block = 0;
  tempfile->block_size = 0;

  --(*filecount);
  write_changes(); /* save immediately */

  return 0;
}


int main(int argc, char **argv) {
  if (argc < 2) {
    printf("Usage: ./mfs-util <operation> <args>\n");
    printf("Use -h for help\n");
    return 1;
  }

  /* available operations:
    -l: list files
    -d: delete file
    -w: write file to MFS
    -r: read file from MFS
    -f: format disk
    -h: help message
  */

  char *op = argv[1];
  int code;

  if (strcmp(op, "-h") == 0) {
    printf("--MFS Utility--\n");
    printf("Available operations:\n");
    printf("\t-l: list files\n");
    printf("\t-d: delete file\n");
    printf("\t-w: write file to MFS\n");
    printf("\t-r: read file from MFS\n");
    printf("\t-f: format disk\n");
    printf("\t-h: this help message\n");
    printf("Other args available(after operation):\n");
    printf("\t-fd: specify MFS disk image\n");
    printf("\t-f: specify file to operate on, this could be a host file or a file in MFS\n");
    printf("Example usage: ./mfs-util -w -f file1.txt -fd disk.img\n");
    return 0;
  }

  char filename[256] = {0}; /* filename with path */

  for (int i = 2; i < argc; i++) {
    if (strcmp(argv[i], "-f") == 0) { /* either file in MFS or host file */
      strcpy(filename, argv[i+1]); /* filename with extension*/
    }
    else if (strcmp(argv[i], "-fd") == 0) { /* MFS disk */
      disk = fopen(argv[i+1], "r+b");
      if (disk == NULL) {
        perror("fopen");
        return 1;
      }
    }

  }

  /* formatted filename, MFS format */
  char fname[12] = {0};
  char *p = strrchr(filename, '/');
  const char *base = p ? p + 1 : filename;
  strncpy(fname, base, sizeof(fname) - 1);
  fname[sizeof(fname) - 1] = '\0';

  /* disk image is required */
  if (disk == NULL) {
    printf("No disk specified\n");
    return 1;
  }

  /* init MFS */
  if (mfs_init() != 0) {
    printf("MFS init failed\n");
    return 1;
  }

  /* what operation? */
  if (strcmp(op, "-l") == 0) {
    /* list files */
    dump_fs();
    code = 0;
  }
  else if (strcmp(op, "-d") == 0) {
    /* delete file */
    code = mfs_delete(fname);
  }
  else if (strcmp(op, "-w") == 0) {
    /* write file to MFS */
    printf("Writing %s to MFS\n", fname);
    FILE* file = fopen(filename, "rb");
    if (file == NULL) {
      perror("fopen");
      return 1;
    }
    /* read host file into buffer*/
    fseek(file, 0, SEEK_END);
    long fsize = ftell(file);
    fseek(file, 0, SEEK_SET);

    char *buf = malloc(fsize);
    if (!buf) return 1;

    fread(buf, 1, fsize, file);

    int code = mfs_open(fname, O_CREAT);

    /* write into the FS */
    if (code != 0) {
      printf("open failed. code: %d\n", code);
      return 1;
    }

    mfs_write(buf, (uint16_t)fsize);
    mfs_close();

    /* write changes to disk*/
    mfs_sync();

    printf("Wrote %ld bytes to %s\n", fsize, fname);

    free(buf);
    fclose(file);
  }
  else if (strcmp(op, "-r") == 0) {
    /* read file from MFS */
    /* read the file from MFS first*/
    printf("Reading %s from MFS\n", fname);
    file* tempfile = find_file(fname);
    if (tempfile == NULL) {
      printf("File not found\n");
      return 1;
    }
    char* buf = malloc(tempfile->size);
    if (!buf) return 1;

    int code = mfs_open(fname, O_RDONLY);

    if (code != 0) {
      printf("Failed to open file. Code: %d\n", code);
      free(buf);
      return 1;
    }

    code = mfs_read(buf, tempfile->size);
    if (code != 0) {
      printf("Failed to read file. Code: %d\n", code);
      free(buf);
      return 1;
    }

    /* then write it to a host file */
    FILE* file = fopen(fname, "w");
    if (file == NULL) {
      perror("fopen");
      free(buf);
      return 1;
    }
    fwrite(buf, 1, tempfile->size, file);
    fclose(file);
    free(buf);
  }
  else if (strcmp(op, "-f") == 0) {
    /* format disk */
    code = mfs_format();
  }


  fclose(disk);

  return 0;
}
