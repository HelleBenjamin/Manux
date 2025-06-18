all: clean build MANUX

# Assembler and compiler. We'll use zcc and z80asm for now
AS := z80asm
CC := zcc

# The build directory
BUILDDIR := build

# Kernel sources. These all are required for a minimal kernel build
KSRC := kernel/kmain.asm kernel/proc.asm kernel/system_call.asm drivers/tty.asm

# System C sources
CSRC := kernel/kernel.c sys/syscall.c sys/unistd.c sys/utsname.c sys/shell.c include/stdio.c sys/fs/mfs.c sys/fs/devfs.c sys/fd/fd.c

# User programs
USRC := user/sal.c

KOBJ = $(KSRC:%.asm=build/%.o)
COBJ = $(CSRC:%.c=build/%.o)
UOBJ = $(USRC:%.c=build/%.o)

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


# Include user programs
ifeq ($(filter -pragma-define:INCLUDE_USER_PROGRAMS=1, $(CC_CONFIG_FLAGS)), -pragma-define:INCLUDE_USER_PROGRAMS=1) 
	INCLUDE_USR_PROGRAMS := 1
	INC_USR_PG_ARG := -DINCLUDE_USER_PROGRAMS=1
else
	INCLUDE_USR_PROGRAMS := 0
	INC_USR_PG_ARG :=
endif

# Compile flags, -SO2 is recommended, use -SO3 for larger programs
# Remove --Cc-unsigned if not working
# Add -startup=3 if not working 
CC_FLAGS := +z80 -SO2 -Cc-unsigned -clib=classic -compiler=sccz80 $(INC_USR_PG_ARG) -Wall
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
	mkdir -p build/kernel build/drivers build/sys build/sys/fs build/sys/fd build/include build/user

# Assembly files
build/%.o: %.asm
	$(AS) $(AS_FLAGS) $< -o$@

# C files
build/%.o: %.c
	$(CC) $(CC_FLAGS) -c $< -o $@

# User programs
ifeq ($(INCLUDE_USR_PROGRAMS),1)
  UOBJ_COND := $(UOBJ)
else
  UOBJ_COND :=
endif


# Build the final binary and bootloader
MANUX: $(KOBJ) $(COBJ) $(UOBJ_COND)
	$(AS) $(AS_FLAGS) kernel_load.asm -b
	./bs 0x9000 kernel_load.bin BOOT.bas
	$(CC) $(CC_FLAGS) $(KOBJ) $(COBJ) $(UOBJ_COND) $(CC_CONFIG_FLAGS) -pragma-define:CLIB_EXIT_STACK_SIZE=0 -pragma-define:CRT_INITIALIZE_BSS=0 -pragma-include:kernel/kernel.inc -crt0=$(CRT0) -create-app -m -bn $(OUTPUT)

# Clean the build directory
clean:
	rm -rf build
