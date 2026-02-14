`timescale 1ns / 1ps
`include "cpu_defs.vh"

module singlecycle(
  input  wire resetl,        // resetl==0 loads startpc; resetl==1 runs
  input  wire [63:0] startpc,
  output reg  [63:0] currentpc,
  output wire [63:0] MemtoRegOut,    // output of MemtoReg mux
  input  wire CLK
);

  wire [63:0] nextpc;
  wire [31:0] instruction;

  wire [4:0]  rd;
  wire [4:0]  rm;
  wire [4:0]  rn;
  wire [10:0] opcode;

  wire reg2loc;
  wire alusrc;
  wire mem2reg;
  wire regwrite;
  wire memread;
  wire memwrite;
  wire branch;
  wire uncond_branch;
  wire [3:0]  aluctrl;
  wire [2:0]  signop;

  wire [63:0] regoutA;
  wire [63:0] regoutB;

  wire [63:0] aluout;
  wire zero;

  wire [63:0] extimm;
  wire [63:0] memout;
  wire [63:0] alumuxout;

  // ----------------------------
  // PC update - Reset active means make the currentpc the start pc
  // ----------------------------
  always @(posedge CLK) begin
    if (!resetl)
      currentpc <= startpc;
    else
      currentpc <= nextpc;
  end

  // ----------------------------
  // Instruction fields - Least signifcant 10 bits will be rm and rd. rn depends on the reg2loc which is instruction based and the opcode is the most significant 11 bits
  // ----------------------------
  assign rd     = instruction[4:0];
  assign rm     = instruction[9:5];
  assign rn     = reg2loc ? instruction[4:0] : instruction[20:16];
  assign opcode = instruction[31:21];

  // ----------------------------
  // Instruction memory
  // ----------------------------
  InstructionMemory imem(
    .Data(instruction),
    .Address(currentpc)
  );

  // ----------------------------
  // Control
  // ----------------------------
  control u_control(
    .reg2loc(reg2loc),
    .alusrc(alusrc),
    .mem2reg(mem2reg),
    .regwrite(regwrite),
    .memread(memread),
    .memwrite(memwrite),
    .branch(branch),
    .uncond_branch(uncond_branch),
    .aluop(aluctrl),
    .signop(signop),
    .opcode(opcode)
  );

  // ----------------------------
  // Sign extender
  // ----------------------------
  signExtender u_se(
    .Imm64(extimm),
    .Imm26(instruction[25:0]),
    .Ctrl(signop)
  );

  // ----------------------------
  // Next PC logic
  // ----------------------------
  NextPCLogic u_npc(
    .CurrentPC(currentpc),
    .SignExtImm64(extimm),
    .Branch(branch),
    .ALUZero(zero),
    .Uncondbranch(uncond_branch),
    .NextPC(nextpc)
  );

  // ----------------------------
  // Register file (X31 as XZR)
  // ----------------------------
  RegisterFile u_rf(
    .BusA(regoutA),
    .BusB(regoutB),
    .BusW(MemtoRegOut),
    .RA(rm),
    .RB(rn),
    .RW(rd),
    .RegWr(regwrite),
    .Clk(CLK)
  );

  // ----------------------------
  // ALU input mux + ALU
  // ----------------------------
  assign alumuxout = (alusrc) ? extimm : regoutB;

  ALU u_alu(
    .BusW(aluout),
    .Zero(zero),
    .BusA(regoutA),
    .BusB(alumuxout),
    .ALUCtrl(aluctrl)
  );

  // ----------------------------
  // Data memory
  // ----------------------------
  DataMemory u_dmem(
    .ReadData(memout),
    .Address(aluout),
    .WriteData(regoutB),
    .MemoryRead(memread),
    .MemoryWrite(memwrite),
    .Clock(CLK)
  );

  // ----------------------------
  // MemtoReg mux
  // ----------------------------
  assign MemtoRegOut = (mem2reg) ? memout : aluout;

endmodule
