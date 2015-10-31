SRC += $(UVM_HOME)/src/uvm.sv

VLOG_OPT = +incdir+$(UVM_HOME)/src \
           +define+UVM_NO_DEPRECATED \
           +define+UVM_OBJECT_DO_NOT_NEED_CONSTRUCTOR

VSIM_OPT = -sv_lib $(UVM_HOME)/lib/uvm_dpi \

include ../common.mk
