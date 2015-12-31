PREFIX  ?= riscv32-unknown-elf-
AS      = $(PREFIX)as
CC	= $(PREFIX)gcc
LD	= $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OD      ?= od

.PHONY: clean

%.o: %.c
	$(CC) -m32 -O2 -std=gnu99 -c -o $@ $<

%.elf: %.o
	$(LD) -e 0x100 -Ttext 0x00000000 -o $@ $<

%.elf: %.S
	$(AS) -m32 -R -o $@ $<

%.bin: %.elf
	$(OBJCOPY) -O binary -j .text $< $@

%.vh: %.elf
	$(OBJCOPY) -O verilog -j .text $< $@

%.mem: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

clean:
	-$(RM) *.elf *.bin *.vh *.mem *.o
