/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: blockram
 *
 * Synchronous block RAM in NO_CHANGE mode with byte write enable and output
 * latch reset.
 */
module blockram #(
    DATA_WIDTH  = 32,
    DATA_DEPTH  = 1024,
    INIT_DATA_A = '0,
    INIT_DATA_B = '0,
    INIT_FILE   = ""
)(
    input  logic                          clk,
    input  logic                          rsta,
    input  logic                          ena,
    input  logic [DATA_WIDTH/8-1:0]       wea,
    input  logic [$clog2(DATA_DEPTH)-1:0] addra,
    input  logic [DATA_WIDTH-1:0]         dia,
    output logic [DATA_WIDTH-1:0]         doa,
    input  logic                          rstb,
    input  logic                          enb,
    input  logic [DATA_WIDTH/8-1:0]       web,
    input  logic [$clog2(DATA_DEPTH)-1:0] addrb,
    input  logic [DATA_WIDTH-1:0]         dib,
    output logic [DATA_WIDTH-1:0]         dob
);
    logic [DATA_WIDTH-1:0] _doa = INIT_DATA_A;
    logic [DATA_WIDTH-1:0] _dob = INIT_DATA_B;

    assign doa = _doa;
    assign dob = _dob;

    logic [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];

    // Initialization
    if (INIT_FILE == "")
        initial for (int i = 0; i < DATA_DEPTH; i++) mem[i] = '0;
    else
        initial $readmemh(INIT_FILE, mem);

    // Port A
    always_ff @(posedge clk)
        if (ena)
            for (int i = 0; i < $bits(wea); i++)
                if (wea[i])
                    mem[addra][8*i +: 8] <= dia[8*i +: 8];

    always_ff @(posedge clk)
        if (ena)
            if (rsta)
                _doa <= INIT_DATA_A;
            else if (~|wea)
                _doa <= mem[addra];

    // Port B
    always_ff @(posedge clk)
        if (enb)
            for (int i = 0; i < $bits(web); i++)
                if (web[i])
                    mem[addrb][8*i +: 8] <= dib[8*i +: 8];

    always_ff @(posedge clk)
        if (enb)
            if (rstb)
                _dob <= INIT_DATA_B;
            else if (~|web)
                _dob <= mem[addrb];

endmodule
