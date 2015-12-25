/*
 * Copyright (c) 2015, C. Brett Witherspoon
 */

/**
 * Module: ram
 *
 * Synchronous RAM with byte enable
 */
module ram #(
    WIDTH     = 32,
    DEPTH     = 1024,
    INIT_A    = {WIDTH{1'b0}},
    INIT_B    = {WIDTH{1'b0}},
    INIT_FILE = ""
)(
    input  logic                     clk,
    input  logic                     resetn,
    input  logic [WIDTH/8-1:0]       wea,
    input  logic [$clog2(DEPTH)-1:0] addra,
    input  logic [WIDTH-1:0]         dia,
    output logic [WIDTH-1:0]         doa,
    input  logic [WIDTH/8-1:0]       web,
    input  logic [$clog2(DEPTH)-1:0] addrb,
    input  logic [WIDTH-1:0]         dib,
    output logic [WIDTH-1:0]         dob
);
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // Initialization
    if (INIT_FILE == "")
        initial for (int i = 0; i < DEPTH; i++) mem[i] = '0;
    else
        initial $readmemh(INIT_FILE, mem);

    // Port A
    always_ff @(posedge clk)
        for (int i = 0; i < $bits(wea); i++)
            if (wea[i])
                mem[addra][8*i +: 8] <= dia[8*i +: 8];

    always_ff @(posedge clk)
        if (~resetn)
            doa <= INIT_A;
        else if (~|wea)
            doa <= mem[addra];

    // Port B
    always_ff @(posedge clk)
        for (int i = 0; i < $bits(web); i++)
            if (web[i])
                mem[addrb][8*i +: 8] <= dib[8*i +: 8];

    always_ff @(posedge clk)
        if (~resetn)
            dob <= INIT_B;
        else if (~|web)
            dob <= mem[addrb];

endmodule
