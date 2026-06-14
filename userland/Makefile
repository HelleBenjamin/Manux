
# programs that will be built and included in the image
SOURCES := ecalc.c asmz80.c edit.c

# shell, don't touch unless replacing it with another one
SHELL_SRC := shell.c
OBJECTS := $(SOURCES:%.c=$(ROOTDIR)/build/userland/%.o)
BINARIES := $(SOURCES:%.c=$(ROOTDIR)/build/userland/%.bin)

# stdio driver
STDIO_DRV = \
	@stdio/terminal/term_01_input_char.lst \
	@stdio/terminal/term_01_output_char.lst

# export from the main makefile
export AS CC AS_FLAGS CCU_FLAGS BUILDDIR ROOTDIR

all: build $(OBJECTS)

$(ROOTDIR)/build/userland/%.o: %.c
	$(CC)	$(CCU_FLAGS) -pragma-define:CRT_ORG_CODE=0x4100 -pragma-define:CRT_ENABLE_COMMANDLINE=2 -pragma-define:CRT_INCLUDE_DRIVER_INSTANTIATION=1 $< $(STDIO_DRV) -o $@

# shell is a special case, it needs to be compiled with a different address
build/SHELL.BIN: $(SHELL_SRC)
	$(CC) $(CCU_FLAGS) -pragma-define:CRT_ORG_CODE=0x3000 $(SHELL_SRC) -o $(BUILDDIR)/userland/SHELL.bin
	mv $(BUILDDIR)/userland/SHELL.rom $(BUILDDIR)/SHELL.BIN

all: build $(OBJECTS) build/SHELL.BIN final_image

# build the final image that contains userland tools
final_image: all
# format first
	$(ROOTDIR)/mfs-util -f -fd $(ROOTDIR)/disk.img
# then write
	$(ROOTDIR)/mfs-util -w -f $(BUILDDIR)/SHELL.BIN -fd $(ROOTDIR)/disk.img
	$(foreach bin, $(BINARIES), $(ROOTDIR)/mfs-util -w -f $(bin) -fd $(ROOTDIR)/disk.img; )
	

build:
	mkdir -p $(ROOTDIR)/build $(ROOTDIR)/build/userland


.PHONY: all