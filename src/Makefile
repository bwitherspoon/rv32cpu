PREFIX  ?= riscv32-unknown-elf-
AS      = $(PREFIX)as
CC	= $(PREFIX)gcc
LD	= $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OD      ?= od

KTEXT   ?= 0x000
ENTRY   ?= 0x040
TEXT    ?= 0x040
DATA    ?= 0xC00
BSS     ?= 0x800

.PHONY: all clean

all: boot.mem

boot.elf: trap.o init.o

%.o: %.c
	$(CC) -static -m32 -O2 -std=gnu99 -c -o $@ $^

%.o: %.S
	$(AS) -m32 -o $@ $^

%.elf: %.o
	$(LD) -T $(@:.elf=.ld) -nostdlib -nostartfiles -o $@ $^

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.mem: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

clean:
	-$(RM) *.elf *.bin *.mem *.o
