System calls
============

Programs can communicate with the kernel using system calls. 
Syscalls are mostly implemented in assembly, but some are written in C.

Calling convention
------------------

Manux uses the following calling convention for system calls:

- HL - Syscall argument 1
- DE - Syscall argument 2
- BC - Syscall argument 3
- A  - Syscall number

- HL - Return value if any

All general purposes registers are preserved by system calls.

System calls
------------

The following system calls are implemented:

sys_exit - 0x00
---------------
  Arguments:
  - HL - exit code
  
  Returns:
  - none

  This syscall is used to exit to the shell/init when a program is done.

sys_write - 0x01
----------------
  Arguments:
  - HL - file descriptor
  - DE - count
  - BC - buffer

  Returns:
  - HL - number of bytes written

  Write to a file descriptor, for example stdout. 

sys_read - 0x02
---------------
  Arguments:
  - HL - file descriptor
  - DE - count
  - BC - buffer

  Returns:
  - HL - number of bytes read

  Read from a file descriptor, for example stdin.

sys_gets - 0x03
---------------
  Arguments:
  - HL - buffer
  - DE - length

  Returns:
  - HL - number of bytes read

  Read a line from stdin into a buffer. This is recommeded for user input.

sys_puts - 0x04
---------------
  Arguments:
  - HL - buffer
  - DE - length

  Returns:
  - none

  Write a buffer to stdout. 

sys_puth - 0x05
---------------
  Arguments:
  - HL - value

  Returns:
  - none

  Print a 16-bit number as hex to stdout.

sys_getinfo - 0x06
------------------
  Arguments:
  - HL - buffer

  Returns:
  - none

  Get system information into a buffer. Same as uname.

sys_rand - 0x07
---------------
  Arguments:
  - none

  Returns:
  - HL - random number

  Get a random number from the refresh register.

sys_open - 0x08
---------------
  Arguments:
  - HL - filename
  - DE - flags

  Returns:
  - HL - file descriptor

  Open a file, returns a file descriptor. Flags are defined in filesystem documentation.

sys_close - 0x09
----------------
  Arguments:
  - HL - file descriptor

  Returns:
  - none

  Close a file descriptor.

sys_seek - 0x0a
---------------
  Arguments:
  - HL - file descriptor
  - DE - offset
  - BC - whence

  Returns:
  - none

  Seek in a file. Whence argument is SEEK_SET(0), SEEK_CUR(1), SEEK_END(2).
  SEEK_SET = absolute, SEEK_CUR = from current position, SEEK_END = from the end of the file

sys_execv - 0x0b
---------------
  Arguments:
  - HL - filename
  - DE - argument pointer

  Returns:
  - HL if error

  Execute a file with arguments. If the file is not found, it will return an error.

sys_list - 0x0c
---------------
  Arguments:
  - HL - buffer

  Returns:
  - HL - number of files

  List the files in the current directory into a buffer.

sys_filesize - 0x0d
-------------------
  Arguments:
  - HL - filename

  Returns:
  - HL - file size

  Get the size of a file.

sys_remove - 0x0e
------------------
  Arguments:
  - HL - filename

  Returns:
  - HL - code

  Delete a file.
