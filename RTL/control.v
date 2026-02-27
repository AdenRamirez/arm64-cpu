`timescale 1ns / 1ps
`include "cpu_defs.vh"

module control(
  output reg alusrc,
  output reg mem2reg,
  output reg regwrite,
  output reg memread,
  output reg memwrite,
  output reg branch,
  output reg uncond_branch,
  output reg [3:0] aluop,
  output reg [2:0] signop,
  input wire [10:0] opcode
);

  always @(*) begin
    casez (opcode)

      `OPCODE_ANDREG: begin
        alusrc        = 1'b0;
        mem2reg       = 1'b0;
        regwrite      = 1'b1;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `AND;
        signop        = 3'b101;
      end

      `OPCODE_ORRREG: begin
        alusrc        = 1'b0;
        mem2reg       = 1'b0;
        regwrite      = 1'b1;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `OR;
        signop        = 3'b101;
      end

      `OPCODE_ADDREG: begin
        alusrc        = 1'b0;
        mem2reg       = 1'b0;
        regwrite      = 1'b1;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `ADD;
        signop        = 3'b101;
      end

      `OPCODE_SUBREG: begin
        alusrc        = 1'b0;
        mem2reg       = 1'b0;
        regwrite      = 1'b1;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `SUB;
        signop        = 3'b101;
      end

      `OPCODE_ADDIMM: begin
        alusrc        = 1'b1;
        mem2reg       = 1'b0;
        regwrite      = 1'b1;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `ADD;
        signop        = 3'b000; // I-type
      end

      `OPCODE_SUBIMM: begin
        alusrc        = 1'b1;
        mem2reg       = 1'b0;
        regwrite      = 1'b1;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `SUB;
        signop        = 3'b000; // I-type
      end

      `OPCODE_B: begin
        alusrc        = 1'b0;
        mem2reg       = 1'b0;
        regwrite      = 1'b0;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b1;
        aluop         = `ADD;   // don't care
        signop        = 3'b010; // B-type
      end

      `OPCODE_CBZ: begin
        alusrc        = 1'b0;
        mem2reg       = 1'b0;
        regwrite      = 1'b0;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b1;
        uncond_branch = 1'b0;
        aluop         = `PassB;
        signop        = 3'b011; // CBZ-type
      end

      `OPCODE_LDUR: begin
        alusrc        = 1'b1;
        mem2reg       = 1'b1;
        regwrite      = 1'b1;
        memread       = 1'b1;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `ADD;
        signop        = 3'b001; // D-type
      end

      `OPCODE_STUR: begin
        alusrc        = 1'b1;
        mem2reg       = 1'b0;
        regwrite      = 1'b0;
        memread       = 1'b0;
        memwrite      = 1'b1;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `ADD;
        signop        = 3'b001; // D-type
      end

      `OPCODE_MOVZ: begin
        alusrc        = 1'b1;
        mem2reg       = 1'b0;
        regwrite      = 1'b1;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `PassB;  
        signop        = 3'b100; // MOVZ-type
      end

      default: begin
        alusrc        = 1'b0;
        mem2reg       = 1'b0;
        regwrite      = 1'b0;
        memread       = 1'b0;
        memwrite      = 1'b0;
        branch        = 1'b0;
        uncond_branch = 1'b0;
        aluop         = `ADD;
        signop        = 3'b111;
      end

    endcase
  end

endmodule
