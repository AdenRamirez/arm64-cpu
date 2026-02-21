`timescale 1ns/1ps

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
    repeat (14) @(posedge CLK);

    $finish;
  end

  always @(posedge CLK) begin
    if (!resetl) cyc <= 0;
    else         cyc <= cyc + 1;
  end

  always @(posedge CLK) begin
    if (resetl) begin
      $display("C%0d IF:pc=%h if_instr=%h | IF/ID:%h | ID/EX:rd=%0d rw=%b | EX/MEM:rd=%0d rw=%b | MEM/WB:rd=%0d rw=%b wbdata=%h",
        cyc,
        dut.pc,
        dut.if_instr,
        dut.id_instr,
        dut.ex_rd, dut.ex_regwrite,
        dut.mem_rd, dut.mem_regwrite,
        dut.wb_rd, dut.wb_regwrite,
        dut.wb_memtoRegOut
      );
    end
  end

endmodule