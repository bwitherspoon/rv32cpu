PREFIX  ?= riscv32-unknown-elf-
AS      = $(PREFIX)as
CC	= $(PREFIX)gcc
LD	= $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OD      ?= od

ENTRY   ?= 0x40
KTEXT   ?= 0x00
TEXT    ?= 0x40

.PHONY: clean

boot.mem:

boot.elf: trap.o

%.o: %.c
	$(CC) -m32 -O2 -std=gnu99 -c -o $@ $<

%.o: %.S
	$(AS) -m32 -o $@ $<

%.elf: %.o
	$(LD) -nostdlibs -r -e $(ENTRY) --section-start=.ktext=$(KTEXT) -Ttext $(TEXT) -o $@ $^

#%.mem: %.elf
#	$(OBJCOPY) -O verilog $< $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.mem: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

clean:
	-$(RM) *.elf *.bin *.mem *.o
