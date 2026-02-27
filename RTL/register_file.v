`timescale 1ns / 1ps

module RegisterFile(
  output wire [63:0] BusA,
  output wire [63:0] BusB,
  input wire [63:0] BusW,
  input wire [4:0] RA,
  input wire [4:0] RB,
  input wire [4:0] RW,
  input wire RegWr,
  input wire Clk,
  input wire resetl
);
 
  reg[63:0] registers[0:31];
  wire[63:0] internal_A;
  wire[63:0] internal_B;
  wire bypass_A;
  wire bypass_B;
  //To simulate a half cycle write and read we just pass the write data through if we're reading from the writing register
  assign internal_A = (RA == 5'd31) ? 64'd0 : registers[RA];
  assign internal_B = (RB == 5'd31) ? 64'd0 : registers[RB];
  assign bypass_A = (RegWr === 1'b1)&& (RW != 5'd31) && (RW == RA);
  assign bypass_B = (RegWr === 1'b1) && (RW != 5'd31) && (RW == RB);
  
  assign BusA = bypass_A ? BusW : internal_A;
  assign BusB = bypass_B ? BusW : internal_B;
  
  integer i;
  always @(posedge Clk) begin
    if (!resetl) begin
        for (i = 0; i < 32; i = i + 1) 
            registers[i] <= 64'b0;
    end
    else if (RegWr && (RW != 5'd31))
      registers[RW] <= BusW;
  end

endmodule
