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
    wire pc_write_enable;
    wire stall;
    wire id_ex_bubble;
    
    assign pc_plus4 = pc + 64'd4;

    //Holding off on branching for now
    assign nextseqpc = pc_plus4;

    // PC register
    always @(posedge CLK) begin
        if (!resetl)
            pc <= startpc;
        else if (pc_write_enable)
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
    wire if_id_write_enable; 
    pipe_if_id IF_ID(
        .clk(CLK),
        .resetl(resetl),
        .write_enable(if_id_write_enable),
        .if_instr(if_instr),
        .if_nextseqpc(nextseqpc),
        .id_instr(id_instr),
        .id_nextseqpc(id_nextseqpc)
    );
    
    // ----------------------------
    // Instruction Decode Stage
    // Variables marked with id in the begining indicate that they will be sent to the next stage
    // ----------------------------
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
    wire [4:0]  id_rf1;
    wire [4:0]  id_rf2;
    wire id_rf1_used;
    wire id_rf2_used;
    wire [4:0]  id_ra;
    wire [4:0]  id_rb;

    id_register_select id_rs(
        .instruction(id_instr),
        .signop(signop),
        .memwrite(id_memwrite),
    
        .rf1(id_rf1),
        .rf1_used(id_rf1_used),
        .rf2(id_rf2),
        .rf2_used(id_rf2_used),
        .rd(id_rd),
        .ra(id_ra),
        .rb(id_rb)
    );
    
    
    wire[63:0] id_busA;
    wire[63:0] id_busB;
    wire[63:0] id_MemtoRegOut;
    wire[4:0] wb_rd;
    wire wb_regwrite;
    wire[63:0] wb_memtoRegOut;
    
    RegisterFile rf(
        .BusA(id_busA),
        .BusB(id_busB),
        .BusW(wb_memtoRegOut),
        .RA(id_ra),
        .RB(id_rb),
        .RW(wb_rd),
        .RegWr(wb_regwrite),
        .Clk(CLK),
        .resetl(resetl)
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
    wire[4:0] ex_rf1;
    wire[4:0] ex_rf2;
    wire ex_alusrc;
    wire ex_mem2reg;
    wire ex_regwrite;
    wire ex_memread;
    wire ex_memwrite;
    wire ex_branch;
    wire ex_uncond_branch;
    wire[3:0] ex_aluctrl;
    wire ex_rf1_used;
    wire ex_rf2_used;
    
    
    
    pipe_id_ex ID_EX(
        .clk(CLK),
        .resetl(resetl),
        .bubble(id_ex_bubble),
        
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
        .id_rf1(id_rf1),
        .id_rf2(id_rf2),
        .id_rf1_used(id_rf1_used),
        .id_rf2_used(id_rf2_used),
        
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
        .ex_aluctrl(ex_aluctrl),
        .ex_rf1(ex_rf1),
        .ex_rf2(ex_rf2),
        .ex_rf1_used(ex_rf1_used),
        .ex_rf2_used(ex_rf2_used)
    );
    
    assign stall = ex_memread && (ex_rd != 5'd31) && ((id_rf1_used && (ex_rd == id_rf1)) || (id_rf2_used && (ex_rd == id_rf2)));
    
    assign pc_write_enable = ~stall;
    assign if_id_write_enable = ~stall;
    assign id_ex_bubble = stall;
    // ----------------------------
    // Execution Stage
    // Variables marked with ex in the beginning indicate that they will be sent to the next stage
    // ----------------------------
    wire[63:0] alumuxout;
    wire ex_zero;
    wire[63:0] ex_aluout;
    wire[63:0] alu_in_B;
    wire[63:0] forward_A_val;
    wire[63:0] forward_B_val;
    
    assign alu_in_B = ex_alusrc ? ex_immediate : forward_B_val;
    
    ALU alu(
        .BusW(ex_aluout),
        .Zero(ex_zero),
        .BusA(forward_A_val),
        .BusB(alu_in_B),
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
    // Variables marked with mem in the beginning indicate that they will be sent to the next stage
    // ----------------------------
    wire[63:0] mem_memout;
    wire ex_mem_forward;
    wire ex_mem_matchA;
    wire mem_wb_match_A;
    wire ex_mem_match_B;
    wire mem_wb_match_B;
    
    assign ex_mem_forward = (mem_regwrite === 1'b1) && (mem_mem2reg === 1'b0) && (mem_rd != 5'd31);
        
    assign ex_mem_match_A = ex_mem_forward && (mem_rd == ex_rf1);
    assign mem_wb_match_A = (wb_regwrite === 1'b1) && (wb_rd != 5'd31) && (wb_rd == ex_rf1);
    
    assign ex_mem_match_B = ex_mem_forward && (mem_rd == ex_rf2);
    assign mem_wb_match_B = (wb_regwrite === 1'b1) && (wb_rd != 5'd31) && (wb_rd == ex_rf2);
    
    
    assign forward_A_val = ex_mem_match_A ? mem_aluout : mem_wb_match_A ? wb_memtoRegOut : ex_busA;
    assign forward_B_val = ex_mem_match_B ? mem_aluout : mem_wb_match_B ? wb_memtoRegOut : ex_busB;
    
    DataMemory dmem(
        .ReadData(mem_memout),
        .Address(mem_aluout),
        .WriteData(mem_busB),
        .MemoryRead(mem_memread),
        .MemoryWrite(mem_memwrite),
        .Clock(CLK)
     );
    
    // ----------------------------
    // MEM/WB Register
    // ----------------------------
    wire[63:0] mem_memtoRegOut;
    
    assign mem_memtoRegOut = mem_mem2reg ? mem_memout : mem_aluout;
    assign MemtoRegOut = wb_memtoRegOut;
   
    pipe_mem_wb MEM_WB(
        .clk(CLK),
        .resetl(resetl),
        .mem_rd(mem_rd),
        .mem_regwrite(mem_regwrite),
        .mem_memtoRegOut(mem_memtoRegOut),
        
        .wb_rd(wb_rd),
        .wb_regwrite(wb_regwrite),
        .wb_memtoRegOut(wb_memtoRegOut)
    );
    

endmodule