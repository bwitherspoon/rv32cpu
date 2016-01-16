#
# Copyright 2015, 2016 C. Brett Witherspoon
#
# See LICENSE for more details.
#

TOP = testbench.sv
INF = axi.sv
PKG = axi4.sv    \
      core.sv
RTL = alu.sv     \
      bram.sv    \
      control.sv \
      cpu.sv    \
      fetch.sv   \
      memory.sv  \
      mem2reg.sv \
      ram.sv     \
      reg2mem.sv \
      regfile.sv
LIB = work
ALL = $(PKG) $(INF) $(RTL) $(TOP)

INIT ?= boot.mem
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

xsim: xelab $(INIT)
	xsim -runall $(SNAP)

tcl: xelab $(INIT)
	xsim $(SNAP)

gui: $(TOP:.sv=.wcfg) xelab $(MEM)
	xsim -gui -view $< $(SNAP) &

xelab: xsim.dir/$(SNAP)/xsimk

xvlog: $(ALL:.sv=.sdb)

$(TOP:.sv=.wcfg):
	touch $@

$(INIT):
	for i in $$(seq 0 1023); do printf '%08X\n' $$i >> $@; done

xsim.dir/$(LIB).$(basename $(TOP))/xsimk: $(addprefix $(LIBDIR)/,$(ALL:.sv=.sdb))
	xelab --timescale "1ns/1ps" --debug typical -L $(LIB) $(SNAP)

$(LIBDIR)/$(INF:.sv=.sdb): | $(PKG:.sv=.sdb)

$(LIBDIR)/$(RTL:.sv=.sdb): | $(PKG:.sv=.sdb) $(INF:.sv=.sdb)

$(LIBDIR)/$(TOP:.sv=.sdb): $(TOP) | $(INIT) $(PKG:.sv=.sdb) $(INF:.sv=.sdb) $(RTL:.sv=.sdb)
	xvlog --sv --work $(LIB) --define INIT_FILE=\"$(word 1,$|)\" -L $(LIB) $<

$(LIBDIR)/%.sdb: %.sv
	xvlog --sv --work $(LIB) -L $(LIB) $<

clean:
	-$(RM) -rf *.log *.jou *.pb *.vcd *.wdb *.str xsim.dir .Xil $(INIT)

