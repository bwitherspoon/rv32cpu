Toolchain
=========

1. Fetch the RISC-V GNU toolchain
    - `git clone https://github.com/riscv/riscv-gnu-toolchain.git`
2. Configure the toolchain
    - `./configure --prefix=/usr/local --disable-linux --with-xlen=32 --with-arch=I`
3. Build the toolchain
    - `make`
