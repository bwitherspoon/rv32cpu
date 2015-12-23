CROSS_COMPILE ?= riscv32-unknown-elf-
AS            := $(CROSS_COMPILE)as
OBJCOPY       := $(CROSS_COMPILE)objcopy

OD ?= od

%.o: %.S
	$(AS) -m32 -R -o $@ $<

%.bin: %.o
	$(OBJCOPY) -O binary -j .text $< $@

%.txt: %.bin
	$(OD) -An -tx4 -w4 -v $< > $@

%.vh: %.elf
	$(OBJCOPY) -O verilog -j .text $< $@

