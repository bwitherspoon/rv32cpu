Toolchain
=========

Build
-----

1. Fetch the RISC-V GNU toolchain
    - `git clone https://github.com/riscv/riscv-gnu-toolchain.git`
2. Configure the toolchain
    - `./configure --prefix=$HOME/.local/riscv --with-xlen=32 --with-arch=I --disable-linux --disable-atomic --disable-float --disable-multilib`
3. Build and install the toolchain
    - `make`
4. Add to path
    - `export PATH=$PATH:$HOME/.local/riscv/bin`

Usage
-----

riscv32-unknown-elf-gcc -nostdlib -nostartfiles -o main.elf main.c

riscv32-unknown-elf-objdump -d main.elf

riscv32-unknown-elf-gcc -nostdlib -nostartfiles -S -o main.s main.c

riscv32-unknown-elf-objcopy -O verilog main.elf main.vh
