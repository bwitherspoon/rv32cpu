TOP ?= top

XILINX_VIVADO ?= /opt/Xilinx/Vivado/2015.4/

PATH := $(XILINX_VIVADO)/bin:$(PATH)

PRJDIR = ../..
SIMDIR = $(PRJDIR)/sim
RTLDIR = $(PRJDIR)/rtl
SRCDIR = $(PRJDIR)/src

xsim: xelab
	xsim -runall work.top

xelab: xvlog
	xelab -relax -debug wave work.top

xvlog: $(PKG) $(SRC) $(TOP).sv
	xvlog --sv $^

gui: xelab
	xsim -gui -view top.wcfg work.top &

clean:
	-$(RM) -rf *.log *.jou *.pb *.vcd *.wdb xsim.dir .Xil

