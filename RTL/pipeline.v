`timescale 1ns/1ps

module pipeline(
    input resetl,
    input [63:0] startpc,
    output [63:0] currentpc,
    output [63:0] MemtoRegOut,
    input CLK
);

    reg [63:0] pc;
    wire [63:0] pc_plus4;
    wire [63:0] nextseqpc;
    wire [31:0] if_instr;

    assign pc_plus4 = pc + 64'd4;

    //Holding off on branching for now
    assign nextseqpc = pc_plus4;

    // PC register
    always @(posedge CLK) begin
        if (!resetl)
            pc <= startpc;
        else
            pc <= nextseqpc;
    end
    assign currentpc = pc;

    // Instruction memory fetch
    InstructionMemory imem(
        .Data(if_instr),
        .Address(pc)
    );

    wire [31:0] id_instr;
    wire [63:0] id_nextpc;

    pipe_if_id IF_ID(
        .clk(CLK),
        .resetl(resetl),
        .if_instr(if_instr),
        .if_nextseqpc(nextseqpc),
        .id_instr(id_instr),
        .id_nextseqpc(id_nextpc)
    );

    assign MemtoRegOut = 64'b0;

endmodule