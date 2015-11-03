riscv
=====

This project is the design of a single-issue RISC processor in
[SystemVerilog][systemverilog]. It is implemented as a classic 5-stage
RISC pipeline with hazard detection and data forwarding. The processor executes
the integer subset of the user level 32-bit [RISC-V][riscv] ISA which is denoted
RV32I.

Supported Hardware
------------------

The project is targeted for the [Arty][arty] development board from
Digilent. Xilinx Vivado is used for synthesis and Modelsim is used
for verification.

[systemverilog]: http://standards.ieee.org/findstds/standard/1800-2012.html
[riscv]: http://riscv.org/
[arty]: http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,1487&Prod=ARTY
