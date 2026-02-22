`timescale 1ns / 1ps

module signExtender(
  output reg [63:0] Imm64,
  input wire [25:0] Imm26,
  input wire [2:0] Ctrl
);

  reg [1:0] shiftAmt;

  always @(*) begin
    case (Ctrl)
      3'b000: begin
        // I-type: imm12 in [21:10], zero-extended
        Imm64 = {52'b0, Imm26[21:10]};
      end

      3'b001: begin
        // D-type: imm9 in [20:12], sign-extended
        Imm64 = {{55{Imm26[20]}}, Imm26[20:12]};
      end

      3'b010: begin
        // B-type: imm26 sign-extended
        Imm64 = {{38{Imm26[25]}}, Imm26} << 2;
      end

      3'b011: begin
        // CBZ-type: imm19 in [23:5], sign-extended
        Imm64 = {{45{Imm26[23]}}, Imm26[23:5]} << 2;
      end

      3'b100: begin
        // MOVZ: shiftAmt in [22:21], imm16 in [20:5], zero-extended then shifted
        shiftAmt = Imm26[22:21];
        Imm64    = {48'b0, Imm26[20:5]};
        Imm64    = Imm64 << (shiftAmt * 16);
      end

      default: begin
        Imm64 = 64'b0;
      end
    endcase
  end

endmodule
