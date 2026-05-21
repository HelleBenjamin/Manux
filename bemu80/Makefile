CC := gcc
# Release flags
CFLAGS := -O2 -Wall -lpthread
# Debug flags
#CFLAGS := -O0 -g -Wall -fsanitize=address -lpthread

all: 
	$(CC) $(CFLAGS) -o bemu80 bemu80.c

install:
	sudo cp bemu80 /usr/local/bin

.PHONY: all
