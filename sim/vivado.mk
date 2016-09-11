#
# Copyright 2015, 2016 C. Brett Witherspoon
#
# See LICENSE for more details.
#

TOP ?= testbench.sv
PKG ?=
INT ?=
RTL ?=
ALL = $(PKG) $(INT) $(RTL) $(TOP)

INIT ?= boot.mem
TIME ?= "1ns/1ps"

LIB  = work
SNAP = $(LIB).$(basename $(TOP))

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl
SRCDIR = $(PRJDIR)/src
LIBDIR = xsim.dir/$(LIB)

VIVADO_DIR ?= /opt/Xilinx/Vivado/2015.4

PATH := $(VIVADO_DIR)/bin:$(PATH)

VPATH = $(RTLDIR):$(SRCDIR):$(LIBDIR)

.PHONY: all test tcl gui xsim xelab xvlog clean

all: xelab

test: xsim

tcl: xelab $(INIT)
	xsim $(SNAP)

gui: $(TOP:.sv=.wcfg) xelab $(INIT)
	xsim -gui -view $< $(SNAP) &

xsim: xelab $(INIT)
	xsim -runall $(SNAP)

xelab: xsim.dir/$(SNAP)/xsimk

xvlog: $(ALL:.sv=.sdb)

$(TOP:.sv=.wcfg):
	touch $@

xsim.dir/$(LIB).$(basename $(TOP))/xsimk: $(addprefix $(LIBDIR)/,$(ALL:.sv=.sdb))
	xelab --timescale "1ns/1ps" --debug typical -L $(LIB) $(SNAP)

$(LIBDIR)/$(INT:.sv=.sdb): | $(PKG:.sv=.sdb)

$(LIBDIR)/$(RTL:.sv=.sdb): | $(PKG:.sv=.sdb) $(INT:.sv=.sdb)

$(LIBDIR)/$(TOP:.sv=.sdb): $(TOP) | $(INIT) $(PKG:.sv=.sdb) $(INT:.sv=.sdb) $(RTL:.sv=.sdb)
	xvlog --sv --work $(LIB) --define TEXT_FILE=\"$(word 1,$|)\" --define DATA_FILE=\"$(word 2,$|)\" -L $(LIB) $<

$(LIBDIR)/%.sdb: %.sv
	xvlog --sv --work $(LIB) -L $(LIB) $<

clean:
	-$(RM) -rf *.log *.jou *.pb *.vcd *.wdb *.str xsim.dir .Xil

