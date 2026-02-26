# ARM64 5-Stage Pipelined CPU (Verilog, Vivado)

This repository contains a 64-bit ARM-like CPU implemented as a classic
5-stage pipeline in Verilog.

The design is a refactor of a previously validated
single-cycle CPU and represents the first phase of a fully hazard-aware pipelined
processor.

------------------------------------------------------------------------

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

------------------------------------------------------------------------

## Current Scope

This version focuses strictly on structural pipelining and functional
correctness under hazard-free instruction sequences.

Implemented features:

-   64-bit datapath
-   32-entry register file (2 read ports, 1 write port)
-   Big-endian addressed data memory
-   Clean module separation (stages and pipeline registers)
-   Functionally equivalent to the original single-cycle baseline (when
    hazards are not present)

------------------------------------------------------------------------

## Hazard Handling

Hazard detection and forwarding are intentionally ignored until the standard 5-stage pipeline is validated. 

This version assumes hazard-free instruction sequences for correctness
verification.

Planned enhancements include:

-   Data hazard detection unit
-   Forwarding paths
-   Load-use stall logic
-   Control hazard handling
-   Branch prediction experiments

------------------------------------------------------------------------

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

------------------------------------------------------------------------

## Relationship to Single-Cycle Design

This project builds upon a previously developed single-cycle ARM-like
CPU.

The pipelined version preserves ISA behavior while restructuring the
datapath into stage-isolated logic blocks.

Original single-cycle implementation:
https://github.com/AdenRamirez/Single-Cycle-CPU

------------------------------------------------------------------------

## Simulation

Simulation is performed using Vivado.

To run simulation to completion:

    run all

Test programs validate instruction execution and pipeline stage
interaction under hazard-free conditions. Program tests can be implemented by creating an .asm file in the "Assembly files" directory and then running asmLoader.py and inputting the title. After this the Instruction Memory module will be edited and when you run your simulation your resule will show. current cycle, current pc, if instruction, id instruction, executution rd and regwrite, memory rd and memory regwrite, wb rd and wb regwrite, and memtoRegOut. 

------------------------------------------------------------------------

## Development Roadmap

Planned progression:

1.  Structural 5-stage pipeline (Complete)
2.  Python Assembler (Complete)
3.  Data hazard detection and forwarding (Current Phase)
4.  Control hazard handling
5.  Branch prediction algorithms
