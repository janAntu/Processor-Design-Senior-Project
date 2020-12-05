import sys
import re

BRANCH_OPS = ['beq', 'bne', 'blt', 'bge']
ALU_OPS = ['sub', 'dec', 'ior', 'or', 'and', 'xor', 'add', 'mov', 'com', 'inc', 'decs', 'lsr', 'lsl', 'clr', 'swap', 'incs']
LS_OPS = ['lw', 'sw']
MISC_OPS = ['cmp', 'cmpz', 'cmpc', 'halt', 'setq', 'jumpq', 'rrc', 'rlc', 'setfp', 'cplc', 'clrc']

class Processor:

  def __init__(self, instructions, mem=[]):
    # Initialize all registers
    self.instructions = instructions
    self.memory = [0]*256
    self.PC = 0
    self.regs = [0, 0, 0, 0]
    self.W = 0
    self.FP = 0
    self.Z_flag, self.C_flag = False, False

    # Copy the initial memory to our array
    for i in range(len(mem)):
      self.memory[i] = mem[i]

  def preprocess(self):
    # Sweep through the list of instructions, removing
    # comments and blank lines and replacing GOTO labels
    # with line numbers.
    labels = dict()
    lines = []

    # First pass: get all labels, remove non-instructions from code
    for instr in self.instructions:
      # Remove commented code from line
      line = instr.lower().split('#')[0]
      if re.match("^.*:", line) is not None:
        # If line is a label, add label to dictionary
        label = line.split(':')[0]
        labels[label] = len(lines) - 1
        continue
      # Convert jump into setq+jumpq
      if line.startswith("jump "):
        lines.append("setq " + line.split("jump ")[1])
        lines.append("jumpq")
        continue
      # Add line to list of lines
      if line.strip() != "":
        lines.append(line)
    
    # Second pass: replace labels with line numbers
    for i in range(len(lines)):
      tokens = lines[i].split()
      if tokens[-1] in labels.keys():
        # If mnemonic is a setq, we just add the label destination
        if tokens[0] == 'setq':
          lines[i] = 'setq ' + str(labels[tokens[-1]])
        elif tokens[0].lower() in BRANCH_OPS:
          offset = labels[tokens[-1]] - i
          lines[i] = tokens[0] + ' ' + str(offset)
    
    # Replace instructions with new instructions
    self.instructions = lines
  
  def assemble_single(self, instr):
    bit_string = ""
    ops = instr.replace('$', '').replace(',', '').split()
    # Helper function to convert integer to fixed-width binary
    binary = lambda x, width: format(x, '0{0}b'.format(width))

    # Translate instruction according to instruction type
    op = ops[0]
    if op == 'setq':
      # Ensure that literal value is between 0 and 127
      literal = int(ops[1])
      assert literal < 128 and literal >= 0, "Literal value {0} out of range".format(literal)
      bit_string = '11' + binary(literal, 7)

    elif op in BRANCH_OPS:
      # Add opcode and function code for operation
      bit_string += '10'
      bit_string += {
        'beq': '00',
        'bne': '01',
        'blt': '10',
        'bge': '11'
      }.get(op, None)
      # Ensure that literal value is between 0 and 31
      offset = int(ops[1])
      assert offset < 32 and offset >= 0, "Offset value {0} out of range".format(offset)
      bit_string += binary(offset, 5)

    elif op in ALU_OPS:
      # Replace mov ## q/f with movq/movf ##
      if op == 'mov':
        op += ops[2]
      # Add opcode and function code for operation
      bit_string += '00'
      bit_string += {
        'sub': '0010',
        'dec': '0011',
        'ior': '0100',
        'and': '0101',
        'xor': '0110',
        'add': '0111',
        'movq': '1000',
        'com': '1001',
        'inc': '1010',
        'movf': '1011',
        'lsl': '1100',
        'clr': '1101',
        'lsr': '1110'
      }.get(op, None)

      # Add destination bit for F or Q
      dest = ops[2]
      assert dest == 'f' or dest == 'q', "Invalid destination bit {0}".format(dest)
      bit_string += '0' if dest =='q' else '1'
      # Ensure that literal value is between 0 and 3
      register = int(ops[1])
      assert register < 4 and register >= 0, "Register value {0} out of range".format(register)
      bit_string += binary(register, 2)

    elif op in LS_OPS:
      bit_string += '01'
      bit_string += '00' if op == 'lw' else '01'
      # Ensure that literal value is between 0 and 8
      offset = int(ops[2])
      assert offset < 8 and offset >= 0, "Offset value {0} out of range".format(offset)
      bit_string += binary(offset, 3)
      # Ensure that literal value is between 0 and 3
      register = int(ops[1])
      assert register < 4 and register >= 0, "Register value {0} out of range".format(register)
      bit_string += binary(register, 2)

    elif op in MISC_OPS:
      bit_string += '00'
      bit_string += {
        'halt': '0000000',
        'jumpq': '0000001',
        'rrc': '0000100',
        'rlc': '0000101',
        'cplc': '0000110',
        'clrc': '0000111',
        'cmpz': '00010',
        'cmpc': '00011'
      }.get(op, None)
      # Add register for CMPZ or CMPC
      if op == 'cmpz' or op == 'cmpc':
        # Ensure that literal value is between 0 and 3
        register = int(ops[1])
        assert register < 4 and register >= 0, "Register value {0} out of range".format(register)
        bit_string += binary(register, 2)

    assert len(bit_string) == 9, "Assembler error on instruction '{0}' translated as {1}".format(instr, bit_string)
    print(bit_string, '  ', instr)
    return bit_string

  def assemble(self, filename):
    # Transform instructions into a list of 9-bit binary strings
    self.preprocess()
    bitstr_iter = map(self.assemble_single, self.instructions)
    bitstr = ''.join(bitstr_iter)
    # Append trailing zeroes so that length is a multiple of 8
    bitstr += '0'*(8 - (len(bitstr)) % 8)
    # Convert binary string to an array of bytes
    byte_array = int(bitstr, 2).to_bytes(len(bitstr)//8, 'big')
    print(byte_array)
    with open(filename, 'wb') as fout:
      fout.write(byte_array)

  def __repr__(self):
    if self.PC < len(self.instructions):
      instr = self.instructions[self.PC]
      instr = instr.split('#')[0]
      # If instruction is "print", output memory to stderr
      if instr == "print":
        sys.stderr.write(str(self.memory[16:22]) + '\n')
    else:
      instr = "---------"
    return "PC: {0}\tInst: {1}\tRegs: {2}\tQ: {3}\tC: {4}".format(
          self.PC, instr, self.regs, self.W, self.C_flag)

  def run_all(self, log='END'):
    self.preprocess()
    while self.PC < len(self.instructions):
      if log == 'EVERY':
        print(self)
      self.run()
    if log != 'NONE':
      print(self)
      print("Memory:\n", self.memory[:24])

  def run(self):
    # Get the operations and operands from the instruction
    instr = self.instructions[self.PC].lower()
    instr = instr.split('#')[0]
    ops = instr.replace('$', '').replace(',', '').split()

    # Skip empty lines or comments
    if len(ops) == 0 or ops[0].startswith('#'):
      self.PC += 1
      return

    # Call a helper function for the particular instruction type
    op = ops[0]
    if op in BRANCH_OPS:
      self.run_branch(ops)
    elif op in ALU_OPS:
      self.run_alu(ops)
    elif op in LS_OPS:
      self.run_ls(ops)
    elif op in MISC_OPS:
      self.run_misc(ops)

    # Update the program counter, even if we branched 
    self.PC += 1

  def run_branch(self, ops):
    op, offset = ops[0], int(ops[1])
    if ((op == 'beq' and self.Z_flag == True) or
        (op == 'bne' and self.Z_flag == False) or
        (op == 'blt' and self.C_flag == True) or
        (op == 'bge' and self.C_flag == False)):
      
      # Update the program counter
      self.PC += offset

  def run_alu(self, ops):
    op, reg, dest = ops[0], int(ops[1]), ops[2]
    f = self.regs[reg]
    result = None
    if op == 'sub':
      result = f - self.W
      self.C_flag = result < 0
      result %= 256
    if op == 'dec':
      result = f - 1
    if op == 'or' or op == 'ior':
      result = f | self.W
    if op == 'and':
      result = f & self.W
      self.C_flag = result > 255
      result = result % 256
    if op == 'xor':
      result = f ^ self.W
    if op == 'add':
      result = f + self.W
      self.C_flag = result > 255
      result %= 256
    if op == 'mov':
      result = f if dest == 'q' else self.W
    if op == 'com':
      result = ~f % 256
    if op == 'inc':
      result = (f + 1) % 256
    if op == 'decs':
      result = (f - 1) % 256
      self.PC += 1
    if op == 'lsl':
      result = f << 1
      self.C_flag = result > 255
      result = result % 256
    if op == 'lsr':
      self.C_flag = f & 1 != 0
      result = f >> 1
    if op == 'clr':
      result = 0
    if op == 'swap':
      result = f << 4 | f >> 4
    if op == 'incs':
      result = f + 1
      self.PC += 1
    
    # Store result of ALU operation to destination,
    # which is W if d == 0 otherwise f
    if dest == 0 or dest == 'q':
      self.W = result
    else:
      self.regs[reg] = result

  def run_ls(self, ops):
    op, reg, offset = ops[0], int(ops[1]), int(ops[2])
    if op == 'lw':
      # Load value from memory into accumulator
      self.W = self.memory[self.regs[reg] + offset]
      print(self.memory[:8])
    elif op == 'sw':
      # Store value from accumulator into memory
      self.memory[self.regs[reg] + offset] = self.W
      print(self.memory[:8])

  def run_misc(self, ops):
    if ops[0] == 'cmp':
      f = self.regs[int(ops[1])]
      self.Z_flag = self.W == f
      self.C_flag = f < self.W
    elif ops[0] == 'halt':
      self.PC = len(self.instructions)
    elif ops[0] == 'setq':
      self.W = int(ops[1])
    elif ops[0] == 'jumpq':
      self.PC = self.W
    elif ops[0] == 'rlc':
      self.W = (self.W << 1) + (1 if self.C_flag else 0)
      self.C_flag = self.W > 255
      self.W %= 256
    elif ops[0] == 'rrc':
      new_carry = self.W & 1 == 1
      self.W = (self.W >> 1) + (128 if self.C_flag else 0)
      self.C_flag = new_carry
    elif ops[0] == 'setfp':
      self.FP = self.W
    elif ops[0] == 'cplc':
      self.C_flag = not (self.C_flag)
      print("invert")
    elif ops[0] == 'clrc':
      self.C_flag = False

def test(filename, mem=[], log='EVERY'):
  with open(filename, 'r') as file:
    lines = [l.strip() for l in file]
    proc = Processor(lines, mem=mem)
    proc.run_all(log=log)
    return proc
'''
def test_sqrt():
  results = dict()
  for n in range(65536):
    n1, n0 = n / 256, n % 256
    expected = int(n**0.5)
    mem = [0]*16 + [n1, n0]
    proc = test('squareroot.s9', mem=mem, log='END')
    results[n] = proc.memory[18]
  error = 0
  for input, actual in results.items():
    expected = input**0.5
    if abs(expected - actual) > 1:
      error += 1
      print("Input: {0}, Expected: {1}, Actual: {2}".format(
        input, expected, actual
      ))
  print("Error: {0}/{1}".format(error, len(results)))

test_sqrt()
'''
mem = [0, 179, 8,0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 17, 0]
if len(sys.argv) == 1:
  print("Don't forget a filename!")
elif len(sys.argv) == 2:
  test(sys.argv[1], mem=mem)
elif len(sys.argv) == 3:
  with open(sys.argv[1], 'r') as file:
    lines = [l.strip() for l in file]
    proc = Processor(lines, mem=mem)
    proc.assemble(sys.argv[2])
