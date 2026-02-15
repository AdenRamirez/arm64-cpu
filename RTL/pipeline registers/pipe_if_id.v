`timescale 1ns/1ps

module pipe_if_id (
    input clk,
    input resetl,
    input [31:0] if_instr,
    input [63:0] if_nextseqpc,
    output reg[31:0] id_instr,
    output reg[63:0] id_nextseqpc
);
    always @(posedge clk) begin
        if (!resetl) begin
            id_instr <= 32'b0;
            id_nextseqpc <= 64'b0;
        end else begin
            id_instr <= if_instr;
            id_nextseqpc <= if_nextseqpc;
        end
    end
endmodule
