all: build MANUX

# Assembler and compiler. We'll use zcc and z80asm for now
AS := z88dk-z80asm
CC := zcc

# The build directory
BUILDDIR := build

# Kernel assembly sources
KSRC := kernel/kmain.asm kernel/system_call.asm driver/disk.asm

# Kernel C sources
CSRC := kernel/kernel.c kernel/kstdio.c driver/tty.c fs/mfs.c fs/fd.c

# Manux POSIX sources
POSIX_SRC := sys/syscall.c sys/utsname.c sys/unistd/read.c sys/unistd/write.c sys/unistd/close.c sys/unistd/_exit.c sys/unistd/execl.c sys/unistd/open.c

# User sources
USRC := sys/shell.c

# Objects
KOBJ = $(KSRC:%.asm=build/%.o)
COBJ = $(CSRC:%.c=build/%.o)
UOBJ = $(USRC:%.c=build/%.o)

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


# Compile flags, -O2 is recommended, use -O3 for larger programs
# Remove --Cc-unsigned if not working
# Add -startup=3 if not working 
# with sccz80 around 5100 bytes
CC_FLAGS := +z80 -SO3 -vn -clib=sdcc_iy --max-allocs-per-node100000 -Wall -Iinclude
AS_FLAGS := -mz80 $(AS_CONFIG_FLAGS)

# Another set of compile flags, currently unused
PDEF = 	-pragma-define:CRT_ORG_CODE=0xB004 \
       	-pragma-define:CRT_ORG_BSS=0xC000 \
       	-pragma-define:CRT_MODEL=3 \
       	-pragma-define:REGISTER_SP=0xA500 \
       	-pragma-define:STACK_SIZE=4096 \
       	-pragma-define:CRT_INITIALIZE_BSS=0 \
	   	-pragma-define:CRT_ENABLE_STDIO=0 \
	    -pragma-include:kernel/kernel.inc \
			-pragma-define:SYSCALL_VECTOR=0xB000 \

# Some files
CRT0 := crt0.asm
OUTPUT := build/MANUX.bin

# Make build directory
build:
	mkdir -p build/kernel build/driver build/sys build/fs build/include build/user build/sys/unistd

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

posix_lib: build $(POBJ)
	$(AS) -xlibposix.lib $(POBJ)
	mv libposix.lib $(BUILDDIR)/

mfs-util:
	gcc -O2 mfs-util.c -o mfs-util

disk: # 1.44mb image, floppy as reference
	dd if=/dev/zero of=disk.img bs=512 count=2880

# userland utilities eg. shell
CCU_FLAGS := +z80 -SO3 -vn -clib=sdcc_iy --max-allocs-per-node200000 -Wall -Iinclude -L$(BUILDDIR) -llibposix -pragma-define:CRT_ENABLE_EIDI=0 -pragma-define:CRT_INITIALIZE_BSS=0 -pragma-define:CRT_MODEL=0x1 -pragma-define:CLIB_EXIT_STACK_SIZE=0 -pragma-define:CLIB_STDIO_HEAP_SIZE=0 -pragma-define:CLIB_MALLOC_HEAP_SIZE=0 -pragma-define:CRT_ORG_BSS=-1 -pragma-define:CRT_ENABLE_CLOSE=0 -pragma-define:CRT_ORG_DATA=-1 -pragma-define:REGISTER_SP=-1 -nostdlib -m -pragma-define:ENABLE_STDIO=0 -create-app
user-utils: disk mfs-util posix_lib
	$(CC) $(CCU_FLAGS) -pragma-define:CRT_ORG_CODE=0x3000 sys/shell.c -o $(BUILDDIR)/SHELL.bin
	mv $(BUILDDIR)/SHELL.rom $(BUILDDIR)/SHELL.BIN
	./mfs-util -s $(BUILDDIR)/SHELL.BIN -fd disk.img
	./mfs-util -s TEST.BIN -fd disk.img

disk-copy:
# only copy the binaries
	./mfs-util -s $(BUILDDIR)/SHELL.BIN -fd disk.img
	./mfs-util -s TEST.BN -fd disk.img
	./mfs-util -s $(BUILDDIR)/Z80ASM.BIN -fd disk.img

# Clean the build directory
clean:
	rm -rf build

disasm:
	z88dk-dis -mz80 -o 0x0000 -x $(BUILDDIR)/MANUX.map $(BUILDDIR)/MANUX.rom > MANUX.asm

disasm-shell:
	z88dk-dis -mz80 -o 0x3000 -x SHELL.map SHELL.bin > SHELL.asm

emulate:
	bemu80 --rom $(BUILDDIR)/MANUX.rom --fd disk.img