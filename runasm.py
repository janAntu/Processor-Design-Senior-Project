import sys
import re

BRANCH_OPS = ['beq', 'bne', 'blt', 'bge']
ALU_OPS = ['sub', 'dec', 'or', 'and', 'xor', 'add', 'mov', 'com', 'inc', 'decs', 'lsr', 'lsl', 'clr', 'swap', 'incs']
LS_OPS = ['lw', 'sw']
MISC_OPS = ['cmp', 'halt', 'setq', 'jumpq', 'rrc', 'rlc', 'setfp']

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
        print("Old line: " + lines[i])
        # If mnemonic is a setq, we just add the label destination
        if tokens[0] == 'setq':
          lines[i] = 'setq ' + str(labels[tokens[-1]])
        elif tokens[0].lower() in BRANCH_OPS:
          offset = labels[tokens[-1]] - i
          lines[i] = tokens[0] + ' ' + str(offset)
        print("New line: " + lines[i])
    
    # Replace instructions with new instructions
    self.instructions = lines
        

  def __repr__(self):
    if self.PC < len(self.instructions):
      instr = self.instructions[self.PC]
      instr = instr.split('#')[0]
      # If instruction is "print", output memory to stderr
      if instr == "print":
        sys.stderr.write(str(self.memory[8:16]) + '\n')
    else:
      instr = "---------"
    return "PC: {0}\tInst: {1}\tRegs: {2}\tQ: {3}".format(
          self.PC, instr, self.regs, self.W)

  def run_all(self, log='END'):
    self.preprocess()
    while self.PC < len(self.instructions):
      if log == 'EVERY':
        print(self)
      self.run()
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
      if result < 0:
        self.C_flag = True
        result += 256
    if op == 'dec':
      result = f - 1
    if op == 'or':
      result = f | self.W
    if op == 'and':
      result = f & self.W
      self.C_flag = result > 255
      result = result % 256
    if op == 'xor':
      result = f ^ self.W
    if op == 'add':
      result = f + self.W
    if op == 'mov':
      result = f if dest == 'q' else self.W
    if op == 'com':
      result = ~f
    if op == 'inc':
      result = f + 1
    if op == 'decs':
      result = f - 1
      self.PC += 1
    if op == 'lsl':
      result = f << 1
      self.C_flag = result > 255
      result = result % 256
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
    elif op == 'sw':
      # Store value from accumulator into memory
      self.memory[self.regs[reg] + offset] = self.W

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
      self.W = (self.Q << 1) + 1 if self.C_flag else 0
      self.C_flag = self.W > 255
      self.W %= 256
    elif ops[0] == 'rrc':
      new_carry = self.W & 1 == 1
      self.W = (self.Q >> 1) + 128 if self.C_flag else 0
      self.C_flag = new_carry
    elif ops[0] == 'setfp':
      self.FP = self.W


if len(sys.argv) == 1:
  print("Don't forget a filename!")
else:
  filename = sys.argv[1]
  with open(filename, 'r') as file:
    lines = [l.strip() for l in file]
    mem = [0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    proc = Processor(lines, mem=mem)
    proc.run_all(log='EVERY')