NAME  = fifo_test
FILES = $(NAME).sv $(RTLDIR)/fifo.sv $(RTLDIR)/axis.sv

INSTALLDIR = /opt/altera/15.0/modelsim_ase

VLIB = $(INSTALLDIR)/bin/vlib
VLOG = $(INSTALLDIR)/bin/vlog
VSIM = $(INSTALLDIR)/bin/vsim

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl

RUNDO = "run -all"
VCDDO = "vcd file $@; vcd add /$(NAME)/dut/*; run -all"

$(NAME): work/_lib.qdb
	$(VSIM) -batch -quiet -nostdout -logfile $(NAME).log -do $(RUNDO) $(NAME)

vcd: $(NAME).vcd

$(NAME).vcd: work/_lib.qdb
	$(VSIM) -batch -quiet -nostdout -logfile $(NAME).log -do $(VCDDO) $(NAME)

work/_lib.qdb: $(FILES) work/_info
	$(VLOG) -quiet $(FILES)

work/_info:
	$(VLIB) work

clean:
	-$(RM) -rf $(NAME).vcd $(NAME).log work/

.PHONY: $(NAME) vcd clean
