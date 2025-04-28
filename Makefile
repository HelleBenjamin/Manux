all: clean build MANUX

# Assembler and compiler. We'll use zcc and z80asm for now
AS = z80asm
CC = zcc

# The build directory
BUILDDIR = build

# Sources
KSRC = kernel/kmain.asm kernel/proc.asm kernel/system_call.s drivers/tty.asm
CSRC = sys/syscall.c sys/unistd.c sys/utsname.c sys/shell.c include/stdio.c

KOBJ = $(KSRC:%.asm=build/%.o)
COBJ = $(CSRC:%.c=build/%.o)

# Compile flags, -SO2 is recommended, use -SO3 for larger programs
# Remove --Cc-unsigned if not working
CC_FLAGS = +z80 -SO2 -Cc-unsigned -startup=3 -clib=classic
AS_FLAGS = -mz80 -DUSE_RST=1 -DCLK_FREQ=1000

# Another set of compile flags
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
CRT0 = crt0.asm
OUTPUT = build/MANUX.bin

# Make build directory
build:
	mkdir -p build/kernel build/drivers/io build/sys build/include

# Assembly files
build/%.o: %.asm
	$(AS) $(AS_FLAGS) $< -o$@

# C files
build/%.o: %.c
	$(CC) $(CC_FLAGS) -c $< -o $@

MANUX: $(KOBJ) $(COBJ)
	$(CC) $(CC_FLAGS) $(KOBJ) $(COBJ) $(PDEF) -crt0=$(CRT0) -create-app -m -bn $(OUTPUT)

# Clean the build directory
clean:
	rm -rf build
