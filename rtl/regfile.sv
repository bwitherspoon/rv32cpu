/**
 * Module: regfile
 * 
 * A register file.
 */
module regfile #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 32
)(
    input  logic                  clk,

    input  logic [ADDR_WIDTH-1:0] rs1_addr,
    output logic [DATA_WIDTH-1:0] rs1_data,

    input  logic [ADDR_WIDTH-1:0] rs2_addr,
    output logic [DATA_WIDTH-1:0] rs2_data,

    input  logic                  rd_wen,
    input  logic [ADDR_WIDTH-1:0] rd_addr,
    input  logic [DATA_WIDTH-1:0] rd_data
);

    logic [DATA_WIDTH-1:0] regs [0:2**ADDR_WIDTH-2];

`ifndef SYNTHESIS
    initial for (int i = 0; i < 2**ADDR_WIDTH-1; i = i + 1) regs[i] = 0;
`endif
    
    logic rs1_zero = rs1_addr == {ADDR_WIDTH{1'b0}};
    logic rs2_zero = rs2_addr == {ADDR_WIDTH{1'b0}};
    logic rd_zero  = rd_addr  == {ADDR_WIDTH{1'b0}};

    always @(negedge clk)
        if (rd_wen && ~rd_zero)
            regs[rd_addr - 1] <= rd_data;

    assign rs1_data = rs1_zero ? {DATA_WIDTH{1'b0}} : regs[rs1_addr - 1];
    assign rs2_data = rs2_zero ? {DATA_WIDTH{1'b0}} : regs[rs2_addr - 1];

endmodule
