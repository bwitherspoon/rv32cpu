RV32CPU
====

![Diagram](http://bwitherspoon.github.io/rv32cpu/core.svg)

Summary
-------

This project is a single-issue RISC processor in [SystemVerilog 1800-2012][systemverilog].
The processor executes the base integer instruction set of the user level 32-bit [RISC-V][riscv] ISA (RV32I).

Platforms
------------------

The design is targeted for Xilinx 7 Series FPGAs and SoCs.
The [Arty][arty] board from Digilent is used for development and testing.

![VivadoSystem](http://bwitherspoon.github.io/rv32cpu/system.svg)

Dependencies
--------------

[Xilinx Vivado 2016.2][vivado] is used for hardware synthesis and simulation.
The [RISC-V GNU toolchain][riscv-gnu-toolchain] is used for software compiling and linking.

[systemverilog]: http://standards.ieee.org/findstds/standard/1800-2012.html
[riscv]: http://riscv.org/
[arty]: http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,1487&Prod=ARTY
[vivado]: http://www.xilinx.com/support/download.html
[riscv-gnu-toolchain]: https://github.com/riscv/riscv-gnu-toolchain
