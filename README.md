riscv
=====

Processor
---------

This project is the design of a single-issue RISC processor in
[SystemVerilog][systemverilog]. The implementation is a classic 5-stage
RISC pipeline including the following stages:

1. Instruction fetch
2. Instruction decode
3. Execute
4. Memory access
5. Writeback

In addition to the pipeline stages and the required pipeline control unit, a
fowarding unit and hazard detection unit to handle data hazards via data
fowarding or pipeline stalling respectively is also implemented.

The processor executes the integer subset of the 32-bit [RISC-V][riscv] ISA
which is summarized in Chapter 8 of the [User Level ISA][riscv] and is denoted
RV32I.

Peripherals
-----------

To demonstrate the functioning of the processor, an interpreter for simple
arithmetic expressions was developed. A desktop computer can be connected to the
development board and in a terminal application expressions can be entered, then
evaluated and the results returned. An example terminal session may look like:

    a = 4
    b = 2
    a + b
    6
    a << b
    16

A UART peripheral capable of transmitting and receiving characters from a
[USB-UART bridge][ft2232h] and interpreter software for evaluating integer
arithmetic expressions will need to be developed. This also implies the need for
a simple DMA engine to copy characters from the UART into program memory and a
simple exception unit to notify the processor of new characters. Expressions
will be evaluated as one or more instructions, written into a region of
executable program memory, executed and the resuts returned properly formated
to the UART controller.

Hardware
--------

The project is targeted for the [Basys3][basys3] board from [Digilent][digilent]
with a Xilinx Artix-7 FPGA. Xilinx Vivado 2014.4 is used for synthesis, but
Modelsim is used for verification. TCL scripts are provided for synthesis and
verification.


[systemverilog]: http://standards.ieee.org/findstds/standard/1300-2011.html
[riscv]: http://riscv.org/
[basys3]: http://www.digilentinc.com/Products/Detail.cfm?NavPath=2,400,1288&Prod=BASYS3
[digilent]: http://www.digilentinc.com
[ft2232h]: http://www.ftdichip.com/Products/ICs/FT2232H.htm
