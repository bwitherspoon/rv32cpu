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
    .ADDR_WIDTH(5), 
    .DATA_WIDTH(32)
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
      .ADDR_WIDTH(9), 
      .DATA_WIDTH(32)
  ) imem (
      .clk(clk), 
      .addr(), 
      .data()
  );

endmodule
