TOP ?= top
FILES += $(TOP).sv

INSTALLDIR = /opt/altera/15.0/modelsim_ase

VLIB = $(INSTALLDIR)/bin/vlib
VLOG = $(INSTALLDIR)/bin/vlog
VSIM = $(INSTALLDIR)/bin/vsim

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl

RUNDO = "run -all"
VCDDO = "vcd file $@; vcd add /$(TOP)/dut/*; run -all"

$(TOP): work/_lib.qdb
	$(VSIM) -batch -quiet -nostdout -logfile $(TOP).log -do $(RUNDO) $(TOP)

vcd: $(TOP).vcd

$(TOP).vcd: work/_lib.qdb
	$(VSIM) -batch -quiet -nostdout -logfile $(TOP).log -do $(VCDDO) $(TOP)

work/_lib.qdb: $(FILES) work/_info
	$(VLOG) -quiet $(FILES)

work/_info:
	$(VLIB) work

clean:
	-$(RM) -rf $(TOP).vcd $(TOP).log work/

.PHONY: $(TOP) vcd clean
