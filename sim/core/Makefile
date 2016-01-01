TOP = top.sv
PKG = riscv.sv
SRC = alu.sv     \
      control.sv \
      core.sv    \
      memory.sv  \
      ram.sv     \
      regfile.sv
ALL = $(PKG) $(SRC) $(TOP)

LIB = work
MEM ?= boot.mem
SNAP = $(LIB).$(basename $(TOP))

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl
SRCDIR = $(PRJDIR)/src
LIBDIR = xsim.dir/$(LIB)

XILINX_VIVADO ?= /opt/Xilinx/Vivado/2015.4

PATH := $(XILINX_VIVADO)/bin:$(PATH)

VPATH = $(RTLDIR):$(SRCDIR):$(LIBDIR)

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

$(LIBDIR)/memory.sdb: memory.sv | $(MEM)
	xvlog --sv --work $(LIB) --define INIT_FILE=\"$|\" -L $(LIB) $<

$(LIBDIR)/$(SRC:.sv=.sdb): | $(PKG:.sv=.sdb)

$(LIBDIR)/$(TOP:.sv=.sdb): | $(PKG:.sv=.sdb) $(SRC:.sv=.sdb)

$(LIBDIR)/%.sdb: %.sv
	xvlog --sv --work $(LIB) -L $(LIB) $<

clean:
	-$(RM) -rf *.log *.jou *.pb *.vcd *.wdb *.str xsim.dir .Xil

