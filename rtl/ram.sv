/**
 * Module: ram
 *
 * Synchronous RAM with byte enable
 */
module ram #(
    DATA_WIDTH = 32,
    ADDR_WIDTH = 10
)(
    input  logic                    clk,
    input  logic                    ena,
    input  logic [DATA_WIDTH/8-1:0] wea,
    input  logic [ADDR_WIDTH-1:0]   addra,
    input  logic [DATA_WIDTH-1:0]   dia,
    output logic [DATA_WIDTH-1:0]   doa,
    input  logic                    enb,
    input  logic [DATA_WIDTH/8-1:0] web,
    input  logic [ADDR_WIDTH-1:0]   addrb,
    input  logic [DATA_WIDTH-1:0]   dib,
    output logic [DATA_WIDTH-1:0]   dob
);

    logic [DATA_WIDTH-1:0] mem [0:2**ADDR_WIDTH-1];

    // Port A
    always_ff @(posedge clk)
        if (ena)
            for (int i = 0; i < $bits(wea); i++)
                if (wea[i])
                    mem[addra][8*i +: 8] <= dia[8*i +: 8];

    always_ff @(posedge clk)
        if (ena)
            doa <= mem[addra];

    // Port B
    always_ff @(posedge clk)
        if (enb)
            for (int i = 0; i < $bits(web); i++)
                if (web[i])
                    mem[addrb][8*i +: 8] <= dib[8*i +: 8];

    always_ff @(posedge clk)
        if (enb)
            dob <= mem[addrb];

endmodule
