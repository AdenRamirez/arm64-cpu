import re


INSTRUCTION_MEMORY_FILE_PATH = "RTL/instruction_memory.v"

#Taken directly from the verilog header
INSTRUCTION_INFO = {
    "ADD":  {"args": 4, "type": "R", "opcode": "10001011000"},
    "SUB":  {"args": 4, "type": "R", "opcode": "11001011000"},
    "AND":  {"args": 4, "type": "R", "opcode": "10001010000"}, 
    "ORR":  {"args": 4, "type": "R", "opcode": "10101010000"},
    "ADDI": {"args": 4, "type": "I", "opcode": "101000100"},
    "SUBI": {"args": 4, "type": "I", "opcode": "101000100"},
    "MOVZ": {"args": 5, "type": "M", "opcode": "110100101"},
    "LDUR": {"args": 4, "type": "D", "opcode": "11111000010"},
    "STUR": {"args": 4, "type": "D", "opcode": "11111000000"},
    "B":    {"args": 2, "type": "B", "opcode": "00101"},
    "CBZ":  {"args": 3, "type": "CB", "opcode": "1110100"}
}

def write_instructions_to_file(instruction_hex_list: list[str], file_path: str):
    with open(file_path, 'r') as f:
        lines = f.readlines()

    # Find indices for "case (Address)" and "default:"
    case_idx = next(i for i, line in enumerate(lines) if "case (Address)" in line)
    default_idx = next(i for i, line in enumerate(lines) if "default:" in line)

    # Prepare new instruction lines
    new_lines = []
    for i, instr in enumerate(instruction_hex_list):
        addr = i * 4
        new_lines.append(f"        64'h{addr:03X}: Data = 32'h{instr};\n")

    # Replace existing lines between case and default
    updated_lines = lines[:case_idx+1] + new_lines + lines[default_idx:]

    # Write back to file
    with open(file_path, 'w') as f:
        f.writelines(updated_lines)

def string_clean(line:str) -> list[str]:
    #clear line break
    instructions = line.strip()
    #remove , [ and ]
    instructions = re.sub(r"[,\[\]]", "", instructions)
    #remove anything after instruction
    instructions = re.sub(r"//.*", "", instructions)
    #Ensure capital X's for checks later
    instructions = instructions.replace("x", "X")
    #Internally XZR is X31
    instructions = instructions.replace("XZR", "X31")
    return instructions.split()


def get_args(instruction:str, instruction_line) -> int:
    try:
        return INSTRUCTION_INFO[instruction]["args"]
    except KeyError:
        raise KeyError(f"Error on line {instruction_line} unknown instruction found")


def get_line_type(instruction_list:list) -> str:
    size = len(instruction_list)
    #If the list is empty then its a new line that we ignore
    if not instruction_list:
        return "empty"
    #There are no one word instructions for if the list only has 1 word then its a label
    elif size == 1:
        return "label"
    #Everything else is instruction, there are other functions to confirm
    else: 
        return "instruction"


def label_check(instruction:str, labels:dict) -> bool:
    #Simple return if the label is already in the labels dict (this value is important for both the first and second passes)
    return instruction in labels


def label_update(instruction:str, pc:int, labels:dict):
    #dicts are mutable so we can directly edit in an update
    labels[instruction] = pc


def arg_check(instruction_list:list, instruction_line:int, arg_count:int):
    #Ensure that there are a correct number of arguments in the instruction
    if (arg_count != len(instruction_list)):
        raise ValueError(f"Error on line {instruction_line} not enough operands")

#Raises errors on any bad arg inputs
def r_reg_check(rd:str, rm:str, rn:str, instruction_line:int):
    if (rd[0] != "X" or rm[0] != "X" or rn[0] != "X"):
        raise ValueError(f"Error on line {instruction_line} registers must begin with x or X")
    rd = rd.replace("X","")
    rm = rm.replace("X","")
    rn = rn.replace("X","")
    rd_int = int(rd)
    rn_int = int(rn)
    rm_int = int(rm)
    if (rd_int > 31 or rn_int > 31 or rm_int > 31):
        raise ValueError(f"Error on line {instruction_line} there are only 32 registers")

#Raises errors on any bad arg inputs
def i_reg_check(rd:str, rn:str, immediate:str, instruction_line:int):
    if (rd[0] != "X" or rn[0] != "X" or immediate[0] != "#"):
        raise ValueError(f"Error on line {instruction_line} registers must begin with x or X and immediates must begin with #")
    rd = rd.replace("X","")
    rn = rn.replace("X","")
    immediate = immediate.replace("#","")
    rd_int = int(rd)
    rn_int = int(rn)
    immediate_int = int(immediate)
    if (rd_int > 31 or rn_int > 31 or immediate_int > 4095):
        raise ValueError(f"Error on line {instruction_line} there are only 32 registers and immediates must be 4096 or lower")

#Raises errors on any bad arg inputs
def d_reg_check(rd:str, rn:str, offset:str, instruction_line:int):
    if (rd[0] != "X" or rn[0] != "X" or offset[0] != "#"):
        raise ValueError(f"Error on line {instruction_line} registers must begin with x or X and offsets must begin with #")
    rd = rd.replace("X","")
    rn = rn.replace("X","")
    offset = offset.replace("#","")
    rd_int = int(rd)
    rn_int = int(rn)
    offset_int = int(offset)
    if (rd_int > 31 or rn_int > 31 or offset_int > 511):
        raise ValueError(f"Error on line {instruction_line} there are only 32 registers and offsets must be 511 or lower")
    
#Raises errors on any bad arg inputs
def cb_reg_check(rt:str, instruction_line:int):
    if (rt[0] != "X"):
        raise ValueError(f"Error on line {instruction_line} registers must begin with x or X and offsets must begin with #")
    rt = rt.replace("X","")
    rt_int = int(rt)
    if (rt_int > 31):
        raise ValueError(f"Error on line {instruction_line} there are only 32 registers")

#Raises errors on any bad arg inputs
def m_reg_check(rt:str, immediate:str, shiftamt:str, instruction_line):
    if (rt[0] != "X"):
        raise ValueError(f"Error on line {instruction_line} registers must begin with x or X and offsets must begin with #")
    rt = rt.replace("X","")
    rt_int = int(rt)
    if (rt_int > 31):
        raise ValueError(f"Error on line {instruction_line} there are only 32 registers")
    shiftamt = int(shiftamt)
    if (shiftamt < 0 or shiftamt > 48 or shiftamt % 16 != 0):
        raise ValueError(f"Error on line {instruction_line} shift amount must be 0, 16, 32, or 48")
    if (int(immediate, 0) > 65535):
        raise ValueError(f"Error on line {instruction_line} immediate value must be less than 65536")
    
#Converts to the binary representation of the arguments
def r_reg_binary(rd:str, rn:str, rm:str):
    rd = rd.replace("X","")
    rn = rn.replace("X","")
    rm = rm.replace("X","")
    rd_int = int(rd)
    rn_int = int(rn)
    rm_int = int(rm)
    return f"{rd_int:05b}", f"{rn_int:05b}", f"{rm_int:05b}"

#Converts to the binary representation of the arguments
def i_reg_binary(rd:str, rn:str, immediate:str):
    rd = rd.replace("X","")
    rn = rn.replace("X","")
    immediate = immediate.replace("#","")
    rd_int = int(rd)
    rn_int = int(rn)
    immediate_int = int(immediate)
    return f"{rd_int:05b}", f"{rn_int:05b}", f"{immediate_int:012b}"

#Converts to the binary representation of the arguments
def d_reg_binary(rd:str, rn:str, offset:str):
    rd = rd.replace("X","")
    rn = rn.replace("X","")
    offset = offset.replace("#","")
    rd_int = int(rd)
    rn_int = int(rn)
    offset_int = int(offset)
    return f"{rd_int:05b}", f"{rn_int:05b}", f"{offset_int:09b}"

#Converts to the binary representation of the arguments
def cb_reg_binary(rt:str):
    rt = rt.replace("X","")
    rt_int = int(rt)
    return f"{rt_int:05b}"

#Converts to the binary representation of the arguments
def m_reg_binary(rt:str, immediate:str, shiftamt:str):
    rt = rt.replace("X","")
    rt_int = int(rt)
    immediate_int = int(immediate, 0)
    shiftamt_int = int(shiftamt) // 16
    return f"{rt_int:05b}", f"{immediate_int:016b}", f"{shiftamt_int:02b}"


def first_pass(lines:list[str], labels:dict, pc:int, instruction_line:int):
    for line in lines:
        instruction_list = string_clean(line)
        line_type = get_line_type(instruction_list)
        #Skip empty lines but increment the line number for error purposes
        if line_type == "empty":
            instruction_line += 1
            continue
        #First pass inserts labels into the dict, if there already is a label decleration thats a double label which isn't valid
        elif line_type == "label":
            instruction = instruction_list[0].replace(":","")
            if(label_check(instruction, labels)):
                raise KeyError(f"Error on line {instruction_line}, duplicate label {instruction} found")
            label_update(instruction, pc, labels)
            instruction_line += 1
            continue
        #Ensure the instruction is okay 
        elif line_type == "instruction":
            instruction = instruction_list[0].upper()
            arg_count = get_args(instruction, instruction_line)
            arg_check(instruction_list, instruction_line, arg_count)
            pc += 4
            instruction_line += 1

def second_pass(lines:list[str], labels:dict, pc:int, instruction_line:int):
    instruction_hex_list = []
    for line in lines:
        instruction_list = string_clean(line)
        line_type = get_line_type(instruction_list)
        if line_type != "instruction":
            instruction_line += 1
            continue
        instruction = instruction_list[0].upper()
        instruction_type = INSTRUCTION_INFO[instruction]["type"]
        opcode = INSTRUCTION_INFO[instruction]["opcode"]
        match instruction_type:
            case "R":
                r_reg_check(instruction_list[1], instruction_list[2], instruction_list[3], instruction_line)
                rd, rn, rm = r_reg_binary(instruction_list[1], instruction_list[2], instruction_list[3])
                instruction_bin = opcode + rm + "000000" + rn + rd
                instruction_hex = f"{int(instruction_bin,2):08X}"
            case "I":
                i_reg_check(instruction_list[1], instruction_list[2], instruction_list[3], instruction_line)
                rd, rn, immediate = i_reg_binary(instruction_list[1], instruction_list[2], instruction_list[3])
                instruction_bin = opcode + immediate + rn + rd
                instruction_hex = f"{int(instruction_bin,2):08X}"
            case "D":
                d_reg_check(instruction_list[1], instruction_list[2], instruction_list[3], instruction_line)
                rd, rn, offset = d_reg_binary(instruction_list[1], instruction_list[2], instruction_list[3])
                instruction_bin = opcode + offset + "00" + rn + rd
                instruction_hex = f"{int(instruction_bin,2):08X}"
            case "B":
                if (not label_check(instruction_list[1], labels)):
                    raise KeyError(f"Error on line {instruction_line}, label {instruction_list[1]} not found")
                offset = (labels[instruction_list[1]] - pc)//4
                address = format(offset & 0x3FFFFFF, '026b')
                instruction_bin = opcode + address
                instruction_hex = f"{int(instruction_bin,2):08X}"
            case "CB":
                if (not label_check(instruction_list[2], labels)):
                    raise KeyError(f"Error on line {instruction_line}, label {instruction_list[2]} not found")
                cb_reg_check(instruction_list[1], instruction_line)
                offset = (labels[instruction_list[2]] - pc)//4
                address = format(offset & 0x7FFFF, '019b')
                rt = cb_reg_binary(instruction_list[1]) 
                instruction_bin = "1" + opcode + address + rt
                instruction_hex = f"{int(instruction_bin,2):08X}"
            case "M":
                #MOVZ X13, 0xDEF0, LSL 0
                if (instruction_list[3].upper() != "LSL"):
                    raise ValueError(f"Error on line {instruction_line}, LSR is currently not supported")
                m_reg_check(instruction_list[1], instruction_list[2], instruction_list[4], instruction_line)
                rt, immediate, shiftamt = m_reg_binary(instruction_list[1], instruction_list[2], instruction_list[4])
                instruction_bin = opcode + shiftamt + immediate + rt 
                instruction_hex = f"{int(instruction_bin, 2):08X}"
                
        instruction_hex_list.append(instruction_hex)
        instruction_line += 1
        pc += 4 
    return instruction_hex_list
            
def main():
    asm_file_input = input("Please enter the file name (with the .asm): ")
    asm_file_path = "Assembly Files/" + asm_file_input
    try:
        with open(asm_file_path, 'r') as asm_file:
            lines = asm_file.readlines()
        
        labels = {}
        pc = 0
        instruction_line = 1 
        first_pass(lines, labels, pc, instruction_line)
        instruction_hex_list = second_pass(lines, labels, pc, instruction_line)
        write_instructions_to_file(instruction_hex_list, INSTRUCTION_MEMORY_FILE_PATH)

    except FileNotFoundError:
        raise FileNotFoundError(f"Error file {asm_file_input} not found. Please make sure that the file is in the \"Assembly files\" diretory and ends with .asm. File is also case sensitive")


main()         