Filesystem
==========

Manux uses MFS(Manux Filesystem) as its filesystem.
It's designed to be simple and minimalistic, so it supports only files, no directories. Even though it's minimalistic, it provides POSIX-like API.

There is a tool called `mfs-util` which can be used to manage the filesystem from linux.

This document is not complete yet.

Filesystem versions
-------------------

- 1.0 - Initial RAM only version, released in v0.2.0, no checksum
- 1.1 - First version with disk support, released in v0.3.0 prereleases, checksum `BEEF`
- 1.2 - Improved version with bitmap, more file support, and improved root superblock, checksum `ABCD`

FS Characteristics
------------------

- Block size: 512 bytes
- Max files: 24
- Max filename length: 12 bytes
- Root superblock size: 1 block
- Root superblock location: sector 0
- Block header size: 4 bytes
- Data per block: 508 bytes
- Root superblock, block bitmap and file entries at own sectors

Root superblock structure
-----------------

The root sector occupies the first sector of the disk. It contains the following information:

- Jump instruction for x86 machines
- Filesystem checksum size 2 bytes
- Number of sectors in disk, size 2 bytes
- Bitmap sector, usually 1, size 2 bytes
- File entry sector, usually 2, size 2 bytes
- Data block start sector, usually 3, size 2 bytes
- Maximum number of files, 2 bytes
- Number of files, size 1 byte

Here the structure is represented in C:
```C
typedef struct {
  uint8_t   jmp[3]; /* jmp short for x86, future use */
  uint16_t  checksum; /* same as version*/
  uint16_t  total_sectors; /* total number of sectors in disk */
  uint16_t  bitmap_sector; /* where the bitmap is */
  uint16_t  fentry_sector; /* where the file entry is*/
  uint16_t  data_start_sector; /* where data blocks start*/
  uint16_t  max_files; /* maximum number of files*/
  uint8_t   filecount;

  /* this is for future use, x86 compatible*/
  //uint8_t boot_code[494];
  //uint16_t boot_sig; /* 0x55AA*/
} MFS_root;
```

File Entry structure
--------------------

Each file entry is represented by the following structure:

```C
typedef struct {
  uint8_t   used;       /* used flag*/
  uint8_t   flags;      /* file flags, read/write*/
  uint8_t   id;         /* file id*/
  char      name[12];   /* file name*/
  uint16_t  size;       /* file size in bytes */
  uint16_t   block_size; /* number of blocks allocated */
  uint16_t  block;      /* first start block */
} file;
```

Each file entry is 21 bytes long.

Block structure
---------------

Each file block occupies 512 bytes. It contains the following information:

- Used/free flag, offset 0x00, size 1 byte
- Next block, offset 0x01, size 2 bytes
- Allignment padding, offset 0x03, size 1 byte
- Data, offset 0x04, size 508 bytes

Linked block allocation
-----------------------

MFS uses linked chains similar to FAT. Each block has a pointer to the next block. The last block points to 0000(EOF).

Example:

```
File test.txt
  block 1, next block 2
  block 2, next block 3
  block 3, next block 0
```

Memory layout
-------------

The filesystem uses fixed memory addresses.

- FS_BUF, 0xF000, DMA buffer for disk I/O
- FS_ROOT_MADDR, 0xF200, Cached root directory in memory

Functions `mfs_sync` or `write_changes` writes the root sector in memory to disk.


File descriptors
-----------------

Manux supports simplified version of file descriptor(s), or FD(s). I'm not going to dive deep how they work.
FDs are tightly integrated with the MFS filesystem.
FDs also make the OS POSIX compliant. 

The current FD implementation in C:
```C
typedef struct {
  uint8_t type; /* file, etc..*/
  uint8_t flags; /* read write*/
  uint16_t pos; /* rw position*/
  uint16_t cur_block; /* current block */
  uint16_t prev_block; /* previous block */
  uint16_t block_offset; /* byte offset */
  file* file;
} fd_entry;
```
Note that `file` is in MFS format.