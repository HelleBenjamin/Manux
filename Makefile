all: clean build MANUX

# Assembler and compiler. We'll use zcc for now
AS = zcc
CC = zcc

BUILDDIR = build

# Sources
KSRC = kernel/kmain.asm kernel/proc.asm kernel/system_call.s drivers/io/io.asm
CSRC = sys/syscall.c sys/unistd.c sys/utsname.c sys/shell.c

KOBJ = $(KSRC:%.asm=build/%.o)
COBJ = $(CSRC:%.c=build/%.o)

# Compile flags
CC_FLAGS = -SO2 -startup=3 -clib=classic

# Another set of compile flags
PDEF = -pragma-define:CRT_ORG_CODE=0xB004 \
       -pragma-define:CRT_ORG_BSS=0xC000 \
       -pragma-define:CRT_MODEL=3 \
       -pragma-define:REGISTER_SP=0xA500 \
       -pragma-define:STACK_SIZE=4096 \
       -pragma-define:CRT_INITIALIZE_BSS=0 \
			 -pragma-define:CRT_ENABLE_STDIO=0 \
			 -pragma-include:kernel/kernel.inc

# Some files
CRT0 = crt0.asm
OUTPUT = build/MANUX.bin

# Make build directory
build:
	mkdir -p build/kernel build/drivers/io build/sys

# Assembly files
build/%.o: %.asm
	$(AS) +z80 $(CC_FLAGS) $< -c -o $@ -pragma-include:kernel/kernel.inc

# C files
build/%.o: %.c
	$(CC) +z80 $(CC_FLAGS) -c $< -o $@

MANUX: $(KOBJ) $(COBJ)
	$(CC) +z80 $(CC_FLAGS) $(KOBJ) $(COBJ) $(PDEF) -crt0=$(CRT0) -create-app -m -bn $(OUTPUT)

# Clean the build directory
clean:
	rm -rf build
