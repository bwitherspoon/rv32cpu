Toolchain
=========

1. Fetch the RISC-V GNU toolchain
    - `git clone https://github.com/riscv/riscv-gnu-toolchain.git`
2. Configure the toolchain
    - `./configure --prefix=/usr/local --with-xlen=32 --with-arch=I --disable-linux --disable-atomic --disable-float --disable-multilib`
3. Build the toolchain
    - `make`
