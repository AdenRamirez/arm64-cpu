`timescale 1ns/1ps

module pipe_mem_wb(
        input clk,
        input resetl,
        input [4:0] mem_rd,
        input mem_regwrite,
        input [63:0] mem_memtoRegOut,
        
        output reg[4:0] wb_rd,
        output reg wb_regwrite,
        output reg[63:0] wb_memtoRegOut
);
    always @(posedge clk) begin
        if (!resetl) begin
            wb_rd <= 5'b0;
            wb_regwrite <= 1'b0;
            wb_memtoRegOut <= 64'b0;
        end else begin
            wb_rd <= mem_rd;
            wb_regwrite <= mem_regwrite;
            if (mem_regwrite)
                wb_memtoRegOut <= mem_memtoRegOut;
            else
                wb_memtoRegOut <= 64'b0;
        end
    end

endmodule