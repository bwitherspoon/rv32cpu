/*
 * core.sv
 */
 
/**
 * Module: core
 * 
 * The processor core.
 */
module core (
    input logic clk,
    input logic resetn
);

  regfile #(
    .ADDR_WIDTH(riscv::REGS_ADDR_WIDTH), 
    .DATA_WIDTH(riscv::REGS_DATA_WIDTH)
  ) regfile (
    .clk(clk), 
    .raddr1(), 
    .rdata1(), 
    .raddr2(), 
    .rdata2(), 
    .wen(), 
    .waddr(), 
    .wdata()
  );
  
  imem #(
      .ADDR_WIDTH(riscv::IMEM_ADDR_WIDTH), 
      .DATA_WIDTH(riscv::IMEM_ADDR_WIDTH)
  ) imem (
      .clk(clk), 
      .addr(), 
      .data()
  );

endmodule
