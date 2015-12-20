CROSS_COMPILE ?= riscv32-unknown-elf-
AS            := $(CROSS_COMPILE)as
OBJCOPY       := $(CROSS_COMPILE)objcopy

OD ?= od

%.elf: %.S
	$(AS) -m32 -o $@ $<

%.bin: %.elf
	$(OBJCOPY) -O binary -j .text $< $@

%.hex: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

%.vh: %.elf
	$(OBJCOPY) -O verilog -j .text $< $@

