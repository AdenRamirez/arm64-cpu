`timescale 1ns/1ps

module pipeline(
    input resetl,
    input [63:0] startpc,
    output [63:0] currentpc,
    output [63:0] MemtoRegOut,
    input CLK
);

    reg[63:0] pc;
    wire[63:0] pc_plus4;
    wire[63:0] nextseqpc;
    wire[31:0] if_instr;

    assign pc_plus4 = pc + 64'd4;

    //Holding off on branching for now
    assign nextseqpc = pc_plus4;

    // PC register
    always @(posedge CLK) begin
        if (!resetl)
            pc <= startpc;
        else
            pc <= nextseqpc;
    end
    assign currentpc = pc;

    // ----------------------------
    // Instruction Fetch Stage
    // ----------------------------
    InstructionMemory imem(
        .Data(if_instr),
        .Address(pc)
    );
    
    wire[31:0] id_instr;
    wire[63:0] id_nextseqpc;
    
    // ----------------------------
    // IF/ID Register
    // ----------------------------    
    pipe_if_id IF_ID(
        .clk(CLK),
        .resetl(resetl),
        .if_instr(if_instr),
        .if_nextseqpc(nextseqpc),
        .id_instr(id_instr),
        .id_nextseqpc(id_nextseqpc)
    );
    
    // ----------------------------
    // Instruction Decode Stage
    // Variables marked with id in the begining indicate that they will be sent to the next stage
    // ----------------------------
    
    wire reg2loc;
    wire id_alusrc;
    wire id_mem2reg;
    wire id_regwrite;
    wire id_memread;
    wire id_memwrite;
    wire id_branch;
    wire id_uncond_branch;
    wire[3:0] id_aluctrl;
    wire[2:0] signop;
    wire[10:0] opcode;
    
    assign opcode = id_instr[31:21];
    
    control u_control(
        .reg2loc(reg2loc),
        .alusrc(id_alusrc),
        .mem2reg(id_mem2reg),
        .regwrite(id_regwrite),
        .memread(id_memread),
        .memwrite(id_memwrite),
        .branch(id_branch),
        .uncond_branch(id_uncond_branch),
        .aluop(id_aluctrl),
        .signop(signop),
        .opcode(opcode)
     );
  
    wire [4:0]  id_rd;
    wire [4:0]  rm;
    wire [4:0]  rn;
    
    assign id_rd = id_instr[4:0];
    assign rm = id_instr[9:5];
    assign rn = reg2loc ? id_instr[4:0] : id_instr[20:16];
    
    
    wire[63:0] id_busA;
    wire[63:0] id_busB;
    wire[63:0] id_MemtoRegOut;
    
    RegisterFile rf(
        .BusA(id_busA),
        .BusB(id_busB),
        .BusW(id_MemtoRegOut), //Placeholder
        .RA(rm),
        .RB(rn),
        .RW(id_rd),//Placeholder
        .RegWr(id_regwrite), //Placeholder
        .Clk(CLK)
     );
    
    wire[63:0] id_immediate;
    
    signExtender se(
    .Imm64(id_immediate),
    .Imm26(id_instr[25:0]),
    .Ctrl(signop)
     );
    
    // ----------------------------
    // ID/EX Register
    // ----------------------------
    
    wire[63:0] ex_busA; 
    wire[63:0] ex_busB;
    wire[63:0] ex_nextseqpc;
    wire[63:0] ex_immediate;
    wire[4:0] ex_rd;
    wire ex_alusrc;
    wire ex_mem2reg;
    wire ex_regwrite;
    wire ex_memread;
    wire ex_memwrite;
    wire ex_branch;
    wire ex_uncond_branch;
    wire[3:0] ex_aluctrl;
    
    
    pipe_id_ex ID_EX(
        .clk(CLK),
        .resetl(resetl),
        .id_busA(id_busA),
        .id_busB(id_busB),
        .id_nextseqpc(id_nextseqpc),
        .id_immediate(id_immediate),
        .id_rd(id_rd),
        .id_alusrc(id_alusrc),
        .id_mem2reg(id_mem2reg),
        .id_regwrite(id_regwrite),
        .id_memread(id_memread),
        .id_memwrite(id_memwrite),
        .id_branch(id_branch),
        .id_uncond_branch(id_uncond_branch),
        .id_aluctrl(id_aluctrl),
        
        .ex_busA(ex_busA),
        .ex_busB(ex_busB),
        .ex_nextseqpc(ex_nextseqpc),
        .ex_immediate(ex_immediate),
        .ex_rd(ex_rd),
        .ex_alusrc(ex_alusrc),
        .ex_mem2reg(ex_mem2reg),
        .ex_regwrite(ex_regwrite),
        .ex_memread(ex_memread),
        .ex_memwrite(ex_memwrite),
        .ex_branch(ex_branch),
        .ex_uncond_branch(ex_uncond_branch),
        .ex_aluctrl(ex_aluctrl)
    );
    
    // ----------------------------
    // Execution Stage
    // Variables marked with ex in the beginning indicate that they will be sent to the next stage
    // ----------------------------
    wire[63:0] alumuxout;
    wire ex_zero;
    wire[63:0] ex_aluout;
    
    assign alumuxout = (ex_alusrc) ? ex_immediate : ex_busB;
    
    ALU alu(
        .BusW(ex_aluout),
        .Zero(ex_zero),
        .BusA(ex_busA),
        .BusB(alumuxout),
        .ALUCtrl(ex_aluctrl)
      );
      
    // ----------------------------
    // EX/MEM Register
    // ----------------------------
    
    wire mem_zero;
    wire [63:0] mem_aluout;
    wire [63:0] mem_nextseqpc;
    wire [63:0] mem_busB;
    wire [4:0] mem_rd;
    wire mem_mem2reg;
    wire mem_regwrite;
    wire mem_memwrite;
    wire mem_memread;
    wire mem_branch;
    wire mem_uncond_branch;
        
    pipe_ex_mem EX_MEM(
        .clk(CLK),
        .resetl(resetl),
        .ex_zero(ex_zero),
        .ex_aluout(ex_aluout),
        .ex_nextseqpc(ex_nextseqpc),
        .ex_busB(ex_busB),
        .ex_rd(ex_rd),
        .ex_mem2reg(ex_mem2reg),
        .ex_regwrite(ex_regwrite),
        .ex_memread(ex_memread),
        .ex_memwrite(ex_memwrite),
        .ex_branch(ex_branch),
        .ex_uncond_branch(ex_uncond_branch),
        
        .mem_zero(mem_zero),
        .mem_aluout(mem_aluout),
        .mem_nextseqpc(mem_nextseqpc),
        .mem_busB(mem_busB),
        .mem_rd(mem_rd),
        .mem_mem2reg(mem_mem2reg),
        .mem_regwrite(mem_regwrite),
        .mem_memwrite(mem_memwrite),
        .mem_memread(mem_memread),
        .mem_branch(mem_branch),
        .mem_uncond_branch(mem_uncond_branch)
    );
    
    // ----------------------------
    // Memory Stage
    // Variables marked with ex in the beginning indicate that they will be sent to the next stage
    // ----------------------------
    
    
    assign MemtoRegOut = 64'b0;

endmodule