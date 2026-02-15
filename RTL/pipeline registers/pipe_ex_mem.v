`timescale 1ns/1ps

module pipe_ex_mem (
        input clk,
        input resetl,
        input ex_zero,
        input [63:0] ex_aluout,
        input [63:0] ex_nextseqpc,
        input [63:0] ex_busB,
        input [4:0] ex_rd,
        input ex_mem2reg,
        input ex_regwrite,
        input ex_memwrite,
        input ex_memread,
        input ex_branch,
        input ex_uncond_branch,
        
        output reg mem_zero,
        output reg[63:0] mem_aluout,
        output reg[63:0] mem_nextseqpc,
        output reg[63:0] mem_busB,
        output reg[4:0] mem_rd,
        output reg mem_mem2reg,
        output reg mem_regwrite,
        output reg mem_memwrite,
        output reg mem_memread,
        output reg mem_branch,
        output reg mem_uncond_branch
    );
    
    always@(posedge clk) begin 
        if(!resetl) begin
            mem_zero <= 1'b0;
            mem_aluout <= 64'b0;
            mem_nextseqpc <= 64'b0;
            mem_busB <= 64'b0;
            mem_rd <= 5'b0;
            mem_mem2reg <= 1'b0;
            mem_regwrite <= 1'b0;
            mem_memwrite <= 1'b0;
            mem_memread <= 1'b0;
            mem_branch <= 1'b0;
            mem_uncond_branch <= 1'b0;
        end
        else begin
            mem_zero <= ex_zero;
            mem_aluout <= ex_aluout;
            mem_nextseqpc <= ex_nextseqpc;
            mem_busB <= ex_busB;
            mem_rd <= ex_rd;
            mem_mem2reg <= ex_mem2reg;
            mem_regwrite <= ex_regwrite;
            mem_memwrite <= ex_memwrite;
            mem_memread <= ex_memread;
            mem_branch <= ex_branch;
            mem_uncond_branch <= ex_uncond_branch;
        end
    end
endmodule