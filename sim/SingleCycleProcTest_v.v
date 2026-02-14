`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod (`HalfClockPeriod * 2)

module SingleCycleProcTest_v;

  task passTest;
    input [63:0] actualOut, expectedOut;
    input [`STRLEN*8:0] testType;
    inout [7:0] passed;
    begin
      if(actualOut == expectedOut) begin
        $display ("%s passed", testType);
        passed = passed + 1;
      end else begin
        $display ("%s failed: 0x%h should be 0x%h", testType, actualOut, expectedOut);
      end
    end
  endtask

  task allPassed;
    input [7:0] passed;
    input [7:0] numTests;
    begin
      if(passed == numTests) $display ("All tests passed");
      else $display("Some tests failed: %d of %d passed", passed, numTests);
    end
  endtask

  reg         CLK;
  reg         Reset_L;
  reg [63:0]  startPC;
  reg [7:0]   passed;
  reg [15:0]  watchdog;

  wire [63:0] MemtoRegOut;
  wire [63:0] currentPC;

  singlecycle uut (
    .CLK(CLK),
    .resetl(Reset_L),
    .startpc(startPC),
    .currentpc(currentPC),
    .MemtoRegOut(MemtoRegOut)
  );

  initial begin
    CLK = 0;
    forever #`HalfClockPeriod CLK = ~CLK;
  end

  initial begin
    $dumpfile("singlecycle.vcd");
    $dumpvars;

    Reset_L  = 1;
    startPC  = 0;
    passed   = 0;
    watchdog = 0;

    // reset pulse: drive low to load startpc, then high to run
    @(posedge CLK);
    Reset_L = 0; startPC = 0;
    @(posedge CLK);
    Reset_L = 1;

    // Run Program 1 until PC reaches 0x30
    while (currentPC < 64'h30) begin
      @(posedge CLK);
      $display("CurrentPC:%h", currentPC);
      watchdog = watchdog + 1;
      if (watchdog == 16'hFF) begin
        $display("Watchdog Timer Expired.");
        $finish;
      end
    end
    passTest(MemtoRegOut, 64'hF, "Results of Program 1", passed);

    // Run Program 2 until PC reaches 0x54
    while (currentPC < 64'h54) begin
      @(posedge CLK);
      $display("CurrentPC:%h", currentPC);
      watchdog = watchdog + 1;
      if (watchdog == 16'hFF) begin
        $display("Watchdog Timer Expired.");
        $finish;
      end
    end
    passTest(MemtoRegOut, 64'h123456789abcdef0, "Results of Program 2", passed);

    allPassed(passed, 2);
    $finish;
  end

endmodule
