`timescale 1ns / 1ps

module InstructionMemory(
  output reg [31:0] Data,
  input  wire [63:0] Address
);

  always @(*) begin
    case (Address)

      // Program 1
      64'h000: Data = 32'hF84003E9;
      64'h004: Data = 32'hF84083EA;
      64'h008: Data = 32'hF84103EB;
      64'h00c: Data = 32'hF84183EC;
      64'h010: Data = 32'hF84203ED;
      64'h014: Data = 32'hAA0B014A;
      64'h018: Data = 32'h8A0A018C;
      64'h01c: Data = 32'hB400008C;
      64'h020: Data = 32'h8B0901AD;
      64'h024: Data = 32'hCB09018C;
      64'h028: Data = 32'h17FFFFFD;
      64'h02c: Data = 32'hF80203ED;
      64'h030: Data = 32'hF84203ED;

      // Program 2
      64'h034: Data = 32'hD2E24689;
      64'h038: Data = 32'hD2CACF0B;
      64'h03C: Data = 32'hD2B3578C;
      64'h040: Data = 32'hD29BDE0D;
      64'h044: Data = 32'h8B0B0129;
      64'h048: Data = 32'h8B0C0129;
      64'h04C: Data = 32'h8B0D0129;
      64'h050: Data = 32'hF80283E9;
      64'h054: Data = 32'hF84283EA;

      default: Data = 32'h00000000;
    endcase
  end

endmodule
