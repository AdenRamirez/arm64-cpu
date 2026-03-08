# ARM64 CPU (Verilog, Vivado)

This repository contains a 64-bit ARM-like CPU.

-----------------------------------------------------------------------------

## Project Purpose
The purpose of this project is to create a multi-year spanning project
implementing computer architecture concepts learned in class to reinforce 
and gain experience. This project will span from Junior Spring (2026) to
Masters Spring (2028) incremently building towards a 2-wide issue superscalar


-----------------------------------------------------------------------------

## Architecture Overview

The processor implements a standard 5-stage in-order pipeline:

1.  **IF** -- Instruction Fetch
2.  **ID** -- Instruction Decode / Register Read
3.  **EX** -- Execute / ALU
4.  **MEM** -- Data Memory Access
5.  **WB** -- Register Writeback

Pipeline registers separate each stage (IF/ID, ID/EX, EX/MEM, MEM/WB) to
reduce combinational depth and enable improved clock frequency relative
to the original single-cycle implementation.

Control signals are generated in the **ID stage** and propagated forward
through the pipeline registers.

-----------------------------------------------------------------------------

## Current Scope

Implemented features:
- 64-bit datapath
- 32-entry register file (2 read ports, 1 write port)
- Big-endian addressed data memory
- Clean module separation (stages and pipeline registers)
- Data hazard detection and forwarding (EX-EX and MEM-EX)
- Load-use stall logic
- Control hazard handling (in progress)

-----------------------------------------------------------------------------

## Hazard Handling

Implemented:
- Data hazard detection unit
- Forwarding paths (EX-EX and MEM-EX)
- Load-use stall logic

In progress:
- Control hazard handling
- Branch prediction
- Branch Target Buffer

-----------------------------------------------------------------------------

## Instruction Subset

Supported instructions:

**R-type** 
- AND
- ORR
- ADD
- SUB

**I-type** 
- ADDI
- SUBI

**Move** 
- MOVZ

**Load / Store** 
- LDUR
- STUR

**Branch** 
- CBZ
- B

X31 is implemented as **XZR**.

-----------------------------------------------------------------------------

## Relationship to Single-Cycle Design

This project builds upon a previously developed single-cycle ARM-like
CPU.

The pipelined version preserves ISA behavior while restructuring the
datapath into stage-isolated logic blocks.

Original single-cycle implementation:
https://github.com/AdenRamirez/Single-Cycle-CPU

-----------------------------------------------------------------------------

## Simulation

1. Create an .asm file in the Assembly Files directory
2. Run asmLoader.py and enter the filename when prompted
3. Set line 35 in tb_pipeline.v to desired cycles
4. Open Vivado and run simulation to completion: run all

If there are any issues with the Assembly Loader please create a github issue

-----------------------------------------------------------------------------

## Development Roadmap

Planned progression:

1. Structural 5-stage pipeline (Complete)
2. Python Assembler (Complete)
3. Data hazard detection and forwarding (Complete)
4. Control hazard handling (Current Phase)
5. Branch prediction (static → 1-bit → 2-bit saturating counter)
6. Branch Target Buffer
7. Out-of-order execution via Tomasulo's algorithm
   - Reservation stations
   - Common Data Bus
   - Register renaming
   - Reorder Buffer for precise exceptions
8. 2-wide superscalar implementation

Planned Schedule:

1. Structural 5-stage pipeline Spring 2026
2. Python Assembler Spring 2026
3. Data hazard detection and forwarding Spring 2026
4. Control hazard handling Spring 2026
5. Branch prediction (static → 1-bit → 2-bit saturating counter) Spring 2026
6. Branch Target Buffer Spring 2026
7. Out-of-order execution via Tomasulo's algorithm Summer 2026 - Fall 2026 - Spring 2027
   - Reservation stations
   - Common Data Bus
   - Register renaming
   - Reorder Buffer for precise exceptions
8. 2-wide superscalar implementation Spring 2027 - Spring 2028
