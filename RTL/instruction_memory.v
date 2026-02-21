`timescale 1ns / 1ps

module InstructionMemory(
  output reg [31:0] Data,
  input  wire [63:0] Address
);

  always @(*) begin
    case (Address)
        /*Assembly Code for test
        MOVZ X9,  0x1234, LSL 48;  11010010111000100100011010001001
        MOVZ X11, 0x5678, LSL 32;  11010010110010101100111100001011
        MOVZ X12, 0x9ABC, LSL 16;  11010010101100110101011110001100
        MOVZ X13, 0xDEF0, LSL 0;   11010010100110111101111000001101
    
        MOVZ X9,  0x1234, LSL 48;  11010010111000100100011010001001
        MOVZ X11, 0x5678, LSL 32;  11010010110010101100111100001011
        MOVZ X12, 0x9ABC, LSL 16;  11010010101100110101011110001100
        MOVZ X13, 0xDEF0, LSL 0;   11010010100110111101111000001101
        */
        
        64'h000: Data = 32'hD2E24689; 
        64'h004: Data = 32'hD2CACF0B;
        64'h008: Data = 32'hD2B3578C;
        64'h00C: Data = 32'hD29BDE0D;
    
        64'h010: Data = 32'hD2E24689;
        64'h014: Data = 32'hD2CACF0B;
        64'h018: Data = 32'hD2B3578C;
        64'h01C: Data = 32'hD29BDE0D;
      default: Data = 32'h00000000;
    endcase
  end

endmodule
