TOP = top.sv
PKG = riscv.sv
SRC = alu.sv     \
      control.sv \
      core.sv    \
      memory.sv  \
      ram.sv     \
      regfile.sv
MEM = boot.mem
LIB = work

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl
SRCDIR = $(PRJDIR)/src
LIBDIR = xsim.dir/$(LIB)

XILINX_VIVADO ?= /opt/Xilinx/Vivado/2015.4

PATH := $(XILINX_VIVADO)/bin:$(PATH)

VPATH = $(RTLDIR):$(SRCDIR):$(LIBDIR)

ALL = $(PKG) $(SRC) $(TOP)

.PHONY: sim wave clean

sim: $(MEM) xsim.dir/$(LIB).$(basename $(TOP))/xsimk
	xsim -runall work.top

gui: $(MEM) $(LIB).$(basename $(TOP)).wdb
	xsim -gui -view top.wcfg work.top &

xsim.dir/$(LIB).$(basename $(TOP))/xsimk: $(addprefix $(LIBDIR)/,$(ALL:.sv=.sdb))
	xelab --timescale "1ns/1ps" -L $(LIB) $(LIB).$(basename $(TOP))

$(LIB).$(basename $(TOP)).wdb: $(addprefix $(LIBDIR)/,$(ALL:.sv=.sdb))
	xelab --timescale "1ns/1ps" --debug typical -L $(LIB) $(LIB).$(basename $(TOP))

$(LIBDIR)/%.sdb: %.sv
	xvlog --sv --work $(LIB) --define MEM_FILE=\"$(SRCDIR)/$(MEM)\" -L $(LIB) $<

clean:
	-$(RM) -rf *.log *.jou *.pb *.vcd *.wdb xsim.dir .Xil

