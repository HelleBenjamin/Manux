all: build MANUX userland bemu80

# Assembler and compiler. We'll use zcc and z80asm for now
AS := z88dk-z80asm
CC := zcc

# project root directory
ROOTDIR := $(shell pwd)

# The build directory, absolute path
BUILDDIR := $(ROOTDIR)/build

# Kernel assembly sources
KSRC := kernel/kmain.asm kernel/system_call.asm driver/disk.asm

# Kernel C sources
CSRC := kernel/kernel.c kernel/kstdio.c driver/tty.c fs/mfs.c fs/fd.c

# Manux POSIX sources
# compile all within the sys/ directory
POSIX_SRC := $(wildcard sys/*.c) $(wildcard sys/unistd/*.c)

# bemu80 emulator executable
BEMU80 := $(ROOTDIR)/bemu80/bemu80

# Objects
KOBJ = $(KSRC:%.asm=build/%.o)
COBJ = $(CSRC:%.c=build/%.o)

# POSIX library
POBJ = $(POSIX_SRC:%.c=build/%.o)

# Extract flags from .config file

# Assembler flags
AS_CONFIG_FLAGS := $(shell \
  grep '^CONFIG_AS_' .config | sed 's/^CONFIG_AS_/-D/' | sed 's/y$$/1/' | sed 's/n$$/0/' \
)

# Compiler flags
CC_CONFIG_FLAGS := $(shell \
  grep '^CONFIG_CC_' .config | sed 's/^CONFIG_CC_/-pragma-define:/' | sed 's/y$$/1/' | sed 's/n$$/0/' \
)

# Common flags for both assembler and compiler
COMMON_CONFIG_FLAGS_AS += $(shell \
	grep '^CONFIG_COMMON_' .config | sed 's/^CONFIG_COMMON_/-D/' | sed 's/y$$/1/' | sed 's/n$$/0/' \
)
COMMON_CONFIG_FLAGS_CC += $(shell \
	grep '^CONFIG_COMMON_' .config | sed 's/^CONFIG_COMMON_/-pragma-define:/' | sed 's/y$$/1/' | sed 's/n$$/0/' \
)

# Add common flags to both assembler and compiler
AS_CONFIG_FLAGS += $(COMMON_CONFIG_FLAGS_AS)
CC_CONFIG_FLAGS += $(COMMON_CONFIG_FLAGS_CC)


# compiler/assembler flags
CC_FLAGS := +z80 -SO3 -vn -clib=sdcc_iy --max-allocs-per-node100000 -Wall -I$(ROOTDIR)/include
AS_FLAGS := -mz80 $(AS_CONFIG_FLAGS)

# Some files
OUTPUT := $(ROOTDIR)/build/MANUX.bin

# Make build directory
build:
	mkdir -p build/kernel build/driver build/sys build/fs build/include build/userland build/sys/unistd

# Assembly files
build/%.o: %.asm
	$(AS) $(AS_FLAGS) $< -o$@

# C files
build/%.o: %.c
	$(CC) $(CC_FLAGS) -c $< -o $@


# Build the final binary and bootloader
MANUX: $(KOBJ) $(COBJ)
  # Add final flags here, -Cz"--rombase=0x0000 --romsize=0x2000"
	$(CC) $(CC_FLAGS) $(KOBJ) $(COBJ) $(CC_CONFIG_FLAGS) -pragma-define:CRT_INTERRUPT_MODE=1 -pragma-define:CLIB_EXIT_STACK_SIZE=0 -pragma-define:CRT_INITIALIZE_BSS=0 -pragma-include:kernel/kernel.inc -crt0=$(CRT0) -create-app -m -bn $(OUTPUT)

# kernel only target
kernel: build MANUX

posix_lib: build $(POBJ)
	$(AS) -xlibposix.lib $(POBJ)
	mv libposix.lib $(BUILDDIR)/

mfs-util: mfs-util.c
	gcc -O2 mfs-util.c -o mfs-util

disk: # 1.44mb image, floppy as reference
	dd if=/dev/zero of=disk.img bs=512 count=2880

# userland utilities eg. shell
CCU_FLAGS := +z80 -SO3 -vn -clib=sdcc_iy -compiler=sdcc --max-allocs-per-node100000 -Wall -I$(ROOTDIR)/include -L$(BUILDDIR) -llibposix -startup=-1 -pragma-include:pragma.inc -m -create-app
userland: mfs-util posix_lib disk
	$(MAKE) -C userland AS=$(AS) CC=$(CC) AS_FLAGS="$(AS_FLAGS)" CCU_FLAGS="$(CCU_FLAGS)" ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR)

bemu80:
	$(MAKE) -C bemu80 ROOTDIR=$(ROOTDIR) BUILDDIR=$(BUILDDIR)

# Clean the build directory
clean:
	rm -rf build
	rm -f mfs-util
	rm -f disk.img

disasm:
	z88dk-dis -mz80 -o 0x0000 -x $(BUILDDIR)/MANUX.map $(BUILDDIR)/MANUX.rom > MANUX.asm

testprogram:
	./mfs-util -w -f test.asm -fd disk.img

emulate:
	$(BEMU80) --rom $(BUILDDIR)/MANUX.rom --fd disk.img

.PHONY: userland bemu80