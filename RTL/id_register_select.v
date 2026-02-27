`timescale 1ns / 1ps

module id_register_select(
    input wire[31:0] instruction,
    input  wire [2:0] signop,
    input  wire memwrite,

    output reg [4:0] rf1,
    output reg rf1_used,
    output reg [4:0] rf2,
    output reg rf2_used,
    output reg [4:0] rd,
    output wire [4:0] ra,
    output wire [4:0] rb
);
    wire [4:0] rm;
    wire [4:0] rn;
    wire [4:0] rt;
    
    assign rt = instruction[4:0];
    assign rn = instruction[9:5];
    assign rm = instruction[20:16];
    
    
    assign ra = rf1_used ? rf1 : 5'd31;
    assign rb = rf2_used ? rf2 : 5'd31;
    
    always @(*) begin
    case (signop)
      3'b000: begin
        // I-type
            rf1 = rn;
            rf1_used = 1;
            rd = rt;
            rf2 = 5'd31;
            rf2_used = 0;
      end

      3'b001: begin
        // D-type
            rf1 = rn;
            rf1_used = 1;
            rf2 = memwrite ? rt : 5'd31;
            rf2_used = memwrite;
            rd = rt;
      end

      3'b011: begin
        // CBZ
            rf1 = rt;
            rf1_used = 1;
            rf2 = 5'd31;
            rf2_used = 0;
            rd = 5'd31;
      end
      
      3'b101: begin
        // R-type
            rf1 = rn;
            rf2 = rm;
            rf1_used = 1;
            rf2_used = 1;
            rd = rt;
      end
      default: begin
            rf1 = 5'd31;
            rf2 = 5'd31;
            rf1_used = 0;
            rf2_used = 0;
            rd = 5'd31;
      end
    endcase
  end

endmodule
