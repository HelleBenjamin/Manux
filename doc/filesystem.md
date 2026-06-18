Filesystem
==========

Manux uses MFS(Manux Filesystem) as its filesystem.
It's designed to be simple and minimalistic, so it supports only files, no directories. Even though it's minimalistic, it provides POSIX-like API.

There is a tool called `mfs-util` which can be used to manage the filesystem from linux.

This document is not complete yet, but gives the core idea.

Filesystem versions
-------------------

- 1.0 - Initial RAM only version, released in v0.2.0, no checksum
- 1.1 - First version with disk support, released in v0.3.0 prereleases, checksum `BEEF`
- 1.2 - Improved version with bitmap, more file support, and improved root superblock, checksum `ABCD`

FS Characteristics
------------------

- Block size: 512 bytes
- Max files: 12
- Max filename length: 12 bytes
- Root directory size: 1 block
- Root directory location: sector 0
- Block header size: 4 bytes
- Data per block: 508 bytes
- Filesystem checksum: 0xBEEF

Root FS structure
-----------------

The root sector occupies the first sector of the disk. It contains the following information:

- Filesystem checksum, offset 0x00, size 2 bytes
- Format flag, offset 0x02, size 1 byte
- Number of files, offset 0x03, size 1 byte
- File entries, offset 0x04, size MAX_FILES * 20 bytes, eg. 12 * 20 = 240 bytes

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
  uint8_t   block_size; /* number of blocks allocated */
  uint16_t  block;      /* first start block */
} file;
```

Each file entry is 20 bytes long.

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