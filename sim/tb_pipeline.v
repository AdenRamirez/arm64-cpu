module tb_pipeline;

  reg CLK;
  reg resetl; 
  reg [63:0] startpc;

  wire [63:0] currentpc;
  wire [63:0] MemtoRegOut;

  pipeline dut (
    .resetl(resetl),
    .startpc(startpc),
    .currentpc(currentpc),
    .MemtoRegOut(MemtoRegOut),
    .CLK(CLK)
  );

  // 10ns or 100 MHz period clock
  initial begin
    CLK = 1'b0;
    forever #5 CLK = ~CLK;
  end

  integer cyc;
  integer stall_count;
  integer instr_count;
  integer nop_count;

  initial begin
    cyc         = 0;
    stall_count = 0;
    instr_count = 0;
    nop_count   = 0;
    startpc     = 64'h0;
    resetl      = 1'b0;
    repeat (2) @(posedge CLK);
    resetl = 1'b1;

    // Run until 5 consecutive NOP cycles in IF since 4 NOPs will drain the pipeline afterwards
    forever begin
      @(posedge CLK);
      if (resetl) begin
        cyc = cyc + 1;
        if (dut.stall) stall_count = stall_count + 1;
        if (dut.id_instr != 32'h0 && !dut.id_ex_bubble)
          instr_count = instr_count + 1;
        if (dut.if_instr == 32'h0 && dut.pc != 64'h0 && !dut.stall)
          nop_count = nop_count + 1;
        else
          nop_count = 0;
        if (nop_count >= 5) begin
          $display("--------------------------------------------------");
          $display("  PERFORMANCE SUMMARY");
          $display("--------------------------------------------------");
          $display("  Total cycles      : %0d", cyc);
          $display("  Instructions      : %0d", instr_count);
          $display("  Stall cycles      : %0d", stall_count);
          $display("  CPI               : %0.3f", (instr_count > 0) ? (1.0 * cyc / instr_count) : 0.0);
          $display("  Stalls / instr    : %0.3f", (instr_count > 0) ? (1.0 * stall_count / instr_count) : 0.0);
          $display("--------------------------------------------------");
          $finish;
        end
      end
    end
  end

  always @(posedge CLK) begin
    if (resetl) begin
      $display(
        "C%0d PC=%h stall=%b pc_we=%b | IF=%h IF/ID=%h | ID/EX(rd=%0d rw=%b mr=%b m2r=%b rs1=%0d rs2=%0d) | EX/MEM(rd=%0d rw=%b) | MEM/WB(rd=%0d rw=%b wb=%h) | RF(RA=%0d RB=%0d A=%h B=%h RW=%0d RegWr=%b W=%h bpA=%b bpB=%b) | memwrite = %0d",
        cyc,
        dut.pc,
        dut.stall,
        dut.pc_write_enable,
        dut.if_instr,
        dut.id_instr,
        dut.ex_rd,
        dut.ex_regwrite,
        dut.ex_memread,
        dut.ex_mem2reg,
        dut.ex_rf1,
        dut.ex_rf2,
        dut.mem_rd,
        dut.mem_regwrite,
        dut.wb_rd,
        dut.wb_regwrite,
        dut.wb_memtoRegOut,
        dut.rf.RA,
        dut.rf.RB,
        dut.rf.BusA,
        dut.rf.BusB,
        dut.rf.RW,
        dut.rf.RegWr,
        dut.rf.BusW,
        dut.rf.bypass_A,
        dut.rf.bypass_B,
        dut.mem_memwrite
      );
    end
  end

endmodule