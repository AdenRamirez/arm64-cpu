`timescale 1ns/1ps

module pipe_id_ex(
    input clk,
    input resetl,
    
    input [63:0] id_busA,
    input [63:0] id_busB,
    input [63:0] id_nextseqpc,
    input [63:0] id_immediate,
    input [4:0] id_rd,
    input id_alusrc,
    input id_mem2reg,
    input id_regwrite,
    input id_memread,
    input id_memwrite,
    input id_branch,
    input id_uncond_branch,
    input [3:0] id_aluctrl,
    
    output reg[63:0] ex_busA,
    output reg[63:0] ex_busB,
    output reg[63:0] ex_nextseqpc,
    output reg[63:0] ex_immediate,
    output reg[4:0] ex_rd,
    output reg ex_alusrc,
    output reg ex_mem2reg,
    output reg ex_regwrite,
    output reg ex_memread,
    output reg ex_memwrite,
    output reg ex_branch,
    output reg ex_uncond_branch,
    output reg[3:0] ex_aluctrl
    );
    always @(posedge clk) begin
        if (!resetl) begin
        ex_busA <= 64'b0;
        ex_busB <= 64'b0;
        ex_nextseqpc <= 64'b0;
        ex_immediate <= 64'b0;
        ex_rd <= 5'b0;
        ex_alusrc <= 1'b0;
        ex_mem2reg <= 1'b0;
        ex_regwrite <= 1'b0;
        ex_memread <= 1'b0;
        ex_memwrite <= 1'b0;
        ex_branch <= 1'b0;
        ex_uncond_branch <= 1'b0;
        ex_aluctrl <= 4'b0;
        end
        
        else begin
        ex_busA <= id_busA;
        ex_busB <= id_busB;
        ex_nextseqpc <= id_nextseqpc;
        ex_immediate <= id_immediate;
        ex_rd <= id_rd;
        ex_alusrc <= id_alusrc;
        ex_mem2reg <= id_mem2reg;
        ex_regwrite <= id_regwrite;
        ex_memread <= id_memread;
        ex_memwrite <= id_memwrite;
        ex_branch <= id_branch;
        ex_uncond_branch <= id_uncond_branch;
        ex_aluctrl <= id_aluctrl;
        end
    end
endmodule