PREFIX  ?= riscv32-unknown-elf-
AS      = $(PREFIX)as
CC	= $(PREFIX)gcc
LD	= $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OD      ?= od

.PHONY: clean

boot.elf: init.o trap.o
	$(LD) -nostdlibs -r -e 0x40 --section-start=.ktext=0x0 -Ttext 0x40 -o $@ $^

%.o: %.c
	$(CC) -m32 -O2 -std=gnu99 -c -o $@ $<

%.o: %.S
	$(AS) -m32 -o $@ $<

%.elf: %.o
	$(LD) -nostdlibs -r -e 0x40 --section-start=.ktext=0x0 -Ttext 0x40 -o $@ $^

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.vh: %.elf
	$(OBJCOPY) -O verilog $< $@

%.mem: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

clean:
	-$(RM) *.elf *.bin *.vh *.mem *.o
