`timescale 1ns / 1ps

module InstructionMemory(
  output reg [31:0] Data,
  input  wire [63:0] Address
);

  always @(*) begin
    case (Address)
        64'h000: Data = 32'hD2800002;
        64'h004: Data = 32'hB4FFFFE2;
      default: Data = 32'h00000000;
    endcase
  end

endmodule