Kernel
======

Kernel is the core of Manux. It handles low level

Reset vectors
-------------

Manux uses the following reset vectors for function calling.
Simple programs should use RSTs 0x08 and 0x10 for I/O, as they are very fast.

- 0x00 - Reset
- 0x08 - Print character to STDOUT
- 0x10 - Get character from STDIN
- 0x20 - System call

Memory map
----------

Memory is organized as follows:

- 0x0000-0x1FFF: Kernel ROM
- 0x2000-0x2FFF: Kernel workspace, BSS, and such
- 0x3000-0x3FFF: Shell/init program location
- 0x4000-0xEFFF: User program space
- 0xF000-0xFFFF: Stack, buffers, etc.

Boot sequence
-------------

- The stack pointer is set to 0xFFFF.
- Kernel CRT initialization. After that, jumps to `KERNEL_ENTRY(kmain.asm)`.
- In `KERNEL_ENTRY`, kernel flags is initialized, then jumps to kernel_main(kernel.c).
- kernel_main initializes the tty driver, filesystem and file descriptors. If filesystem or file descriptor fails, kernel panic is invoked.
- After that, executes `exec_init`(kernel.c) which loads the first program(shell) and jumps to it(at 0x3000). Note that the executable name must be `SHELL.BIN`.
- If `exec_init` fails, kernel panic is invoked.


Kernel.inc file
---------------

This file contains kernel workspace variables and constants.
The default location is`0x2000`.

Below is a list of kernel workspace variables and what they do:

Variables
- `KERNEL_SP`: Kernel stack pointer, used in kernel side functions such as syscalls.
- `SHELL_SP`: Shell stack pointer, used when returning from user program executed from shell.
- `SYSCALL_RET`: Return value variable from syscall. At the end of syscall, the value is stored in HL.
- `KERNEL_FLAGS`: Kernel flags, enables/disables some kernel features. WIP
- `TMP_REG1-3`: Temporary variables used in some kernel assembly functions.
- `SAVED_SP`: Stack pointer before switched to kernel stack. Restored when returning from a syscall.
- `TTY_BUF_TAIL`: TTY driver buffer tail pointer. Used to get a character from the buffer.
- `TTY_BUF_HEAD`: TTY driver buffer head pointer. Used to put a character to the buffer.
- `TTY_BUF_COUNT`: TTY driver buffer character count.
- `TTY_BUF`: TTY driver buffer. 255 bytes in size.

Constants
- `REGISTER_SP`: Default stack pointer value. Defaults to 0xFFFF.
- `KERNEL_STACK`: Top of the kernel stack. Defaults to 2048 bytes.
- `SHELL_STACK`: Top of the shell stack. Defaults to 2048 bytes.
- `USER_STACK`: Top of the user stack. The size is undefined.
- `SYSCALL_COUNT`: Maximum number of system calls.
- `SYSINFO`: Utsname struct.
- `KP_MSG`: Kernel panic message.


Program execution
-----------------

Manux can executed one program at a time. All programs all loaded at fixed address 0x4100.

Before execution, a PIH is created. PIH(Program Information Header) is a 255 byte structure(at 0x4000) that contains program specific information, such as argc and argv. It's essentially Manux's version of DOS's PSP.
Here's a brief explanation of the PIH structure:

| Offset | Type      | Meaning                                           |
|--------|-----------|---------------------------------------------------|
| 0      | magic     | magic value to check if the program is valid      |
| 2      | size      | program size in bytes                             |
| 4      | entry     | where the execution starts                        |
| 6      | flags     | program flags                                     |
| 8      | exit code | program exit code                                 |
| 10     | argc      | argument count                                    |
| 12     | argv      | argument pointer                                  |
| 14-255 | arguments | program arguments in vector format                |
| 256    | code      | executable code                                   |

There are lot of unused variables in the PIH, but they're planned to be used in the future.
The structure may change in the future.

So, how does it execute a program?
First of all, an `execv` syscall must be called. The kernel checks if the file is valid, and if so, it loads the program into memory and setups arguments if provided. If the file fails to load, it returns `-1` to the caller.


