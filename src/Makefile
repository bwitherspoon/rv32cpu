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

.PHONY: clean
.INTERMEDIATE: boot.o

boot.mem:

boot.o: main.S trap.S

%.o: %.c
	$(CC) -m32 -O2 -std=gnu99 -c -o $@ $^

%.o: %.S
	$(AS) -m32 -o $@ $^

%.elf: %.o
	$(LD) -nostdlib -e $(ENTRY) --section-start=.ktext=$(KTEXT) -Ttext=$(TEXT) -Tdata=$(DATA) -Tbss=$(BSS) -o $@ $^

#%.mem: %.elf
#	$(OBJCOPY) -O verilog $< $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.mem: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

clean:
	-$(RM) *.elf *.bin *.mem *.o
