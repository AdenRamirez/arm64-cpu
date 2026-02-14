`ifndef CPU_DEFS_VH
`define CPU_DEFS_VH

`define SIZE 1024

// Instruction opcode patterns
`define OPCODE_ANDREG 11'b?0001010???
`define OPCODE_ORRREG 11'b?0101010???
`define OPCODE_ADDREG 11'b?0?01011???
`define OPCODE_SUBREG 11'b?1?01011???

`define OPCODE_ADDIMM 11'b?0?10001???
`define OPCODE_SUBIMM 11'b?1?10001???

`define OPCODE_MOVZ   11'b110100101??

`define OPCODE_B      11'b?00101?????
`define OPCODE_CBZ    11'b?011010????

`define OPCODE_LDUR   11'b??111000010
`define OPCODE_STUR   11'b??111000000

// ALU control encodings
`define AND    4'b0000
`define OR     4'b0001
`define ADD    4'b0010
`define SUB    4'b0110
`define PassB  4'b0111

`endif
