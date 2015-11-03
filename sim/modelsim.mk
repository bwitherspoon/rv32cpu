TOP ?= top

SIM_HOME ?= /opt/altera/15.0/modelsim_ase
UVM_HOME ?= /opt/accellera/uvm/1.2

PATH := $(SIM_HOME)/bin:$(UVM_HOME)/bin:$(PATH)

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl

VLIB = vlib work

VLOG = vlog \
       $(VLOG_OPT) \
       +incdir+. \
       -quiet \
       -lint \
       -writetoplevels $(TOP).top \
       $(SRC) \
       $(TOP).sv

VSIM = vsim \
       $(VSIM_OPT) \
       -note 3116 \
       -batch \
       -quiet \
       -do $(DO) \
       -logfile $(TOP).log \
       -f $(TOP).top

all: $(TOP)

lib: work/_lib.qdb

vcd: $(TOP).vcd

$(TOP): DO = "run -all; quit"
$(TOP): work/_lib.qdb
	$(VSIM)

$(TOP).vcd: DO = "vcd file $@; vcd add /$(TOP)/dut/*; run -all; quit"
$(TOP).vcd: work/_lib.qdb
	$(VSIM)

work/_lib.qdb: $(SRC) work/_info
	$(VLOG)

work/_info:
	$(VLIB)

clean:
	-$(RM) -rf $(TOP).vcd $(TOP).top $(TOP).log work/

.PHONY: all lib vcd $(TOP) clean
