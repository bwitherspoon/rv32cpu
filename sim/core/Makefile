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

SNAP = $(LIB).$(basename $(TOP))

ALL = $(PKG) $(SRC) $(TOP)

.PHONY: xsim tcl gui xelab xvlog clean

xsim: xelab $(MEM)
	xsim -runall $(SNAP)

tcl: xelab $(MEM)
	xsim $(SNAP)

gui: $(TOP:.sv=.wcfg) xelab $(MEM)
	xsim -gui -view $< $(SNAP) &

xelab: xsim.dir/$(SNAP)/xsimk

xvlog: $(ALL:.sv=.sdb)

xsim.dir/$(LIB).$(basename $(TOP))/xsimk: $(addprefix $(LIBDIR)/,$(ALL:.sv=.sdb))
	xelab --timescale "1ns/1ps" --debug typical -L $(LIB) $(SNAP)

$(LIBDIR)/ram.sdb: $(MEM) ram.sv
	xvlog --sv --work $(LIB) --define MEM_FILE=\"$<\" -L $(LIB) $(word 2,$^)

$(LIBDIR)/%.sdb: %.sv
	xvlog --sv --work $(LIB) -L $(LIB) $<

clean:
	-$(RM) -rf *.log *.jou *.pb *.vcd *.wdb *.str xsim.dir .Xil

