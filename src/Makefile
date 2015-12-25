PREFIX  ?= riscv32-unknown-elf-
AS      = $(PREFIX)as
OBJCOPY = $(PREFIX)objcopy
OD      ?= od

.PHONY: clean

%.elf: %.S
	$(AS) -m32 -R -o $@ $<

%.bin: %.elf
	$(OBJCOPY) -O binary -j .text $< $@

%.vh: %.elf
	$(OBJCOPY) -O verilog -j .text $< $@

%.mem: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

clean:
	-$(RM) *.elf *.bin *.vh *.mem
