`timescale 1ns / 1ps
`include "cpu_defs.vh"

module DataMemory(
  output reg  [63:0] ReadData,
  input wire [63:0] Address,
  input wire [63:0] WriteData,
  input wire MemoryRead,
  input wire MemoryWrite,
  input wire Clock
);

  reg [7:0] memBank [0:`SIZE-1];

  task initset;
    input [63:0] addr;
    input [63:0] data;
    begin
      memBank[addr + 0] = data[63:56];
      memBank[addr + 1] = data[55:48];
      memBank[addr + 2] = data[47:40];
      memBank[addr + 3] = data[39:32];
      memBank[addr + 4] = data[31:24];
      memBank[addr + 5] = data[23:16];
      memBank[addr + 6] = data[15:8];
      memBank[addr + 7] = data[7:0];
    end
  endtask

  integer i;

  initial begin
    for (i = 0; i < `SIZE; i = i + 1)
      memBank[i] = 8'h00;

    // Preset data used by Program 1
    initset(64'h0,  64'h1);
    initset(64'h8,  64'ha);
    initset(64'h10, 64'h5);
    initset(64'h18, 64'h0ffbea7deadbeeff);
    initset(64'h20, 64'h0);
  end

  always @(*) begin
    if (MemoryRead) begin
      ReadData[63:56] <= memBank[Address + 0];
      ReadData[55:48] <= memBank[Address + 1];
      ReadData[47:40] <= memBank[Address + 2];
      ReadData[39:32] <= memBank[Address + 3];
      ReadData[31:24] <= memBank[Address + 4];
      ReadData[23:16] <= memBank[Address + 5];
      ReadData[15:8]  <= memBank[Address + 6];
      ReadData[7:0]   <= memBank[Address + 7];
    end else
        ReadData = 64'd0;
  end

  always @(posedge Clock) begin
    if (MemoryWrite) begin
      memBank[Address + 0] <= WriteData[63:56];
      memBank[Address + 1] <= WriteData[55:48];
      memBank[Address + 2] <= WriteData[47:40];
      memBank[Address + 3] <= WriteData[39:32];
      memBank[Address + 4] <= WriteData[31:24];
      memBank[Address + 5] <= WriteData[23:16];
      memBank[Address + 6] <= WriteData[15:8];
      memBank[Address + 7] <= WriteData[7:0];
    end
  end

endmodule
