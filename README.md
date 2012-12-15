Verilog_Microprocessor_Design
=============================

VonNeumann three-address stored program computer architecture
![](/path/to/img.jpg)

Introduction. The following circuit is a big-end microprocessor (similar to an ARMCORE)
data path with some of the control logic. Please describe behaviorally in VERILOG what the
hardware in Figure 1 does. There should be separate modules for the RegisterFile, ALU,
and PC. Module control is a finite state machine that sequences all of the control lines in
the figure for the other modules.

Instruction Format: This machine is a 3-address machine. The OPCODE field of IR
says what instruction to do, R1 of IR says what register is gated onto the ABUS, R2 of IR
says what register is gated onto the BBUS, and R3 of IR says where to store the result on
the CBUS.

Register File Operation: You operate the RegisterFile by wiring R1 to ABUSread, R2
to BBUSread, and R3 to CBUSwriteMSB. CBUSwriteMSB gives the register that the
32 MSBs of the CBUS are written to, and CBUSwriteLSB gives the register that the 32
LSBs of the CBUS are written to. The memory is not written from the CBUS unless signal
activateLSB or activateMSB is asserted to 1. There are 32 general purpose registers, of 32
bits, named X0 through X31.

Instruction Descriptions: In order to do arithmetic instructions, you must assert the
lines (sub, multi, rightrotateshift, nand, or or) to tell the ALU what to do. The ALU
operates on the ABUS and BBUS and puts its result on the CBUS. For sub ((R1)−(R2)),and right 
rotate shift ((R1) right rotated by (R2)), only the 32 least significant bits are set
on the CBUS. The multiply ((R1) × (R2)) instruction sets all 64 bits of the CBUS. The
arithmetic operations set the zero, carry, and negative signals to indicate the outcome of the
instruction. The rotate instructions set zero if the result is all zeros, set carry to be the last
bit rotated around, and set negative if the MSB at the end of the operation is a 1. The nand
and or instructions set zero and negative to indicate the status of the result from the bitwise
instruction, but always clear the carry.

Instructions to Implement: You are now ready to implement the following instructions
with the specified hexadecimal OPCODEs. Assume that some other hardware has already
pre-fetched the instruction to be executed into the Instruction Register. Don’t forget to add
1 to the PC after the instruction executes, so that the machine will fetch the next sequential
instruction. Branches are executed by adding the Immediate field of IR to the PC and
storing the result in the PC, as follows:
OPCODE Operation Meaning
8’h0A SUB R3   (R1) − (R2)
8’h1A MULT {R3,R3 + 1}   (R1) × (R2)
8’h21 RIGHT ROTATE SHIFT (R3)   (R1) >>> (R2)
8’h22 NAND (R3)   ((R1)&(R2))
8’h23 OR (R3)   (R1)|(R2)
8’h14 BRANCH IF ZERO PC   (PC) + Immediate only if zero is set

Instruction Timing: In the first clock after the machine enters the RESET state of the
CPU controller, assume that an instruction has been fetched, and operate the ALU to execute
that instruction and produce its result on the CBUS (including updating the PC). If the
instruction is branch if zero, then go to the RESET state at the second clock. Otherwise, in 
the second clock, store the CBUS back into the RegisterFile, and then return to the RESET
state at the third clock. In addition to all signals in Figure 1, the machine has active high
signals clk and reset, which puts the CPU controller in the RESET state and clears the PC.
