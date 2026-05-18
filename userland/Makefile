
# programs that will be built and included in the image
SOURCES := ecalc.c

# shell, don't touch unless replacing it with another one
SHELL_SRC := shell.c
OBJECTS := $(SOURCES:%.c=$(ROOTDIR)/build/%.o)
BINARIES := $(SOURCES:%.c=$(ROOTDIR)/build/%.bin)

# export from the main makefile
export AS CC AS_FLAGS CCU_FLAGS BUILDDIR ROOTDIR

all: build $(OBJECTS)

$(ROOTDIR)/build/%.o: %.c
	$(CC)	$(CCU_FLAGS) -pragma-define:CRT_ORG_CODE=0x4100 -pragma-define:CRT_ENABLE_COMMANDLINE=2 $< -o $@

# shell is a special case, it needs to be compiled with a different address
build/SHELL.BIN: $(SHELL_SRC)
	$(CC) $(CCU_FLAGS) -pragma-define:CRT_ORG_CODE=0x3000 $(SHELL_SRC) -o $(BUILDDIR)/SHELL.bin
	mv $(BUILDDIR)/SHELL.rom $(BUILDDIR)/SHELL.BIN

all: build $(OBJECTS) build/SHELL.BIN final_image

# build the final image that contains userland tools
final_image: all
	$(ROOTDIR)/mfs-util -s $(BUILDDIR)/SHELL.BIN -fd $(ROOTDIR)/disk.img
	$(foreach bin, $(BINARIES), $(ROOTDIR)/mfs-util -s $(bin) -fd $(ROOTDIR)/disk.img; )
	

build:
	mkdir -p $(ROOTDIR)/build


.PHONY: all