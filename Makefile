.PHONY: kernel sys disasm disasm2
SRCS = src/kernel.c src/monitor.c src/os.c
all:
	zcc +z80 -SO2 -clib=classic $(SRCS) -pragma-define:CRT_ORG_CODE=0xB004 -pragma-define:REGISTER_SP=0xB004 -create-app -m
	./../pl a.bin manuos80.bas


KERNEL_SRCS = kernel/kernel.asm
IO_SRCS = drivers/io/io.asm
SYS_SRCS = sys/syscall.c sys/unistd.c sys/utsname.c
kernel:
	z80asm -mz80 -Obuild -b $(KERNEL_SRCS) $(IO_SRCS) -m -g
	./pl build/kernel/kernel_CODE.bin manuos80.bas

disasm:
	z88dk-dis -o 0xB004 -x build/kernel/kernel.map build/kernel/kernel_KERNEL.bin

disasm2:
	z88dk-dis -o 0xB004 -x build/MANUX.map build/MANUX.rom

BUILDDIR = build/
CC_FLAGS= -SO2 -startup=3 -clib=classic
PDEF= -pragma-define:CRT_ORG_CODE=0xB004 -pragma-define:CRT_ORG_BSS=0xC000 -pragma-define:CRT_MODEL=3 -pragma-define:REGISTER_SP=0xA500 -pragma-define:STACK_SIZE=4096 -pragma-define:CRT_INITIALIZE_BSS=0
# Use compressed BSS section. This saves so much space compared to the uncompressed BSS section. The only downside is that startup takes longer due to decompression.
sys:
	rm -rf build
	mkdir build
#zcc +z80 -SO2 -startup=3 -clib=classic sys/syscall.c -create-app -a -o $(BUILDDIR)SCALL.asm
#zcc +z80 -SO2 -startup=3 -clib=classic sys/unistd.c -create-app -a -o $(BUILDDIR)UNISTD.asm
	zcc +z80 $(CC_FLAGS) sys/shell.c $(SYS_SRCS) $(KERNEL_SRCS) $(IO_SRCS) $(PDEF) -crt0=crt0.asm -create-app -m -bn $(BUILDDIR)MANUX.bin

	./pl $(BUILDDIR)MANUX.rom MANUX.bas

clean:
	rm -rf build
	mkdir build