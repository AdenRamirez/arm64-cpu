`timescale 1ns / 1ps
`include "cpu_defs.vh"

module ALU(
  output reg [63:0] BusW,
  output wire Zero,
  input wire [63:0] BusA,
  input wire [63:0] BusB,
  input wire [3:0]  ALUCtrl
);

  always @(*) begin
    case(ALUCtrl)
      `AND:   BusW = (BusA & BusB);
      `OR:    BusW = (BusA | BusB);
      `ADD:   BusW = (BusA + BusB);
      `SUB:   BusW = (BusA - BusB);
      `PassB: BusW = BusB;
      default:BusW = 64'd0;
    endcase
  end

  assign Zero = (BusW == 64'd0);

endmodule
