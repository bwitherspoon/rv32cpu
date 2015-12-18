# Overridable if any of these tools are not in PATH
HEXDUMP ?= hexdump

CROSS_COMPILE ?= riscv32-unknown-elf-
AS            := $(CROSS_COMPILE)as
OBJCOPY       := $(CROSS_COMPILE)objcopy

%.elf: %.S
	$(AS) -m32 -o $@ $<

%.bin: %.elf
	$(OBJCOPY) -O binary -j .text $< $@

%.txt: %.bin
	$(HEXDUMP) -v -e '4/1 "%.2X" "\n"' $< > $@

%.hex: %.elf
	$(OBJCOPY) -O verilog -j .text $< $@

