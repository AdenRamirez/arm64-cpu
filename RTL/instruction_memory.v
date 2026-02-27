`timescale 1ns / 1ps

module InstructionMemory(
  output reg [31:0] Data,
  input  wire [63:0] Address
);

  always @(*) begin
    case (Address)
        64'h000: Data = 32'hA20027E1;
        64'h004: Data = 32'hF80083E1;
        64'h008: Data = 32'hF84083E2;
      default: Data = 32'h00000000;
    endcase
  end

endmodule