`timescale 1ns / 1ps

module NextPCLogic (
  input wire [63:0] CurrentPC,
  input wire [63:0] SignExtImm64,
  input wire Branch,
  input wire ALUZero,
  input wire Uncondbranch,
  output reg [63:0] NextPC
);

  always @(*) begin
    if (Uncondbranch || (ALUZero && Branch))
      NextPC = CurrentPC + (SignExtImm64 << 2);
    else
      NextPC = CurrentPC + 64'd4;
  end

endmodule
