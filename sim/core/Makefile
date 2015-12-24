TOP = top.sv
PKG = riscv.sv
SRC = alu.sv     \
      control.sv \
      core.sv    \
      memory.sv  \
      ram.sv     \
      regfile.sv
LIB = work

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl
SRCDIR = $(PRJDIR)/src
LIBDIR = xsim.dir/$(LIB)

XILINX_VIVADO ?= /opt/Xilinx/Vivado/2015.4

PATH := $(XILINX_VIVADO)/bin:$(PATH)

VPATH = $(RTLDIR):$(LIBDIR)

ALL = $(PKG) $(SRC) $(TOP)

.PHONY: sim wave clean

sim: xsim.dir/$(LIB).$(basename $(TOP))/xsimk
	xsim -runall work.top

gui: $(LIB).$(basename $(TOP)).wdb
	xsim -gui -view top.wcfg work.top &

xsim.dir/$(LIB).$(basename $(TOP))/xsimk: $(addprefix $(LIBDIR)/,$(ALL:.sv=.sdb))
	xelab --timescale "1ns/1ps" -L $(LIB) $(LIB).$(basename $(TOP))

$(LIB).$(basename $(TOP)).wdb: $(addprefix $(LIBDIR)/,$(ALL:.sv=.sdb))
	xelab --timescale "1ns/1ps" --debug typical -L $(LIB) $(LIB).$(basename $(TOP))

#$(addprefix $(LIBDIR)/,$(TOP:.sv=.sdb)): $(addprefix $(LIBDIR)/,$(SRC:.sv=.sdb))

#$(addprefix $(LIBDIR)/,$(SRC:.sv=.sdb)): $(addprefix $(LIBDIR)/,$(PKG:.sv=.sdb))

$(LIBDIR)/%.sdb: %.sv
	xvlog --sv -work $(LIB) -L $(LIB) $<

clean:
	-$(RM) -rf *.log *.jou *.pb *.vcd *.wdb xsim.dir .Xil

