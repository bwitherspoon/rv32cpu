Summary
-------

This project is the design of a single-issue RISC processor in
[SystemVerilog][systemverilog]. The design is a 5-stage pipeline with hazard
detection and data forwarding. The processor executes the base integer
instruction set of the user level 32-bit [RISC-V][riscv] ISA (RV32I).

Hardware Platforms
------------------

The design is targeted for the Xilinx 7 Series FPGAs and SoCs. The [Arty][arty]
board from Digilent is used for development and testing.

Software Tools
--------------

[Xilinx Vivado 2015.4][vivado] is used for hardware synthesis and simulation of
the processor.
The [RISC-V GNU toolchain][riscv-gnu-toolchain] is used for software development
for the processor.

[systemverilog]: http://standards.ieee.org/findstds/standard/1800-2012.html
[riscv]: http://riscv.org/
[arty]: http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,1487&Prod=ARTY
[vivado]: http://www.xilinx.com/support/download.html
[riscv-gnu-toolchain]: https://github.com/riscv/riscv-gnu-toolchain
