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
  initial begin
    cyc = 0;
    startpc = 64'h0;

    resetl = 1'b0;
    repeat (2) @(posedge CLK);

    resetl = 1'b1;

    // run long enough to fill pipeline + observe steady state
    repeat (11) @(posedge CLK);

    $finish;
  end

  always @(posedge CLK) begin
    if (!resetl) cyc <= 0;
    else         cyc <= cyc + 1;
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