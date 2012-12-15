module register(ABUSread,BBUSread,CBUSwriteMSB,activateLSB,activateMSB,clk,CBUS,ABUS,BBUS);
input [4:0] ABUSread,BBUSread,CBUSwriteMSB;
input activateLSB,activateMSB,clk;
input [63:0] CBUS;
output reg [31:0] ABUS,BBUS;
reg [31:0] X[31:0];
reg [5:0]i;

initial begin
for(i=0;i<32;i=i+1)
	X[i]=i;
end

always@(posedge clk)begin
	ABUS=X[ABUSread];
	BBUS=X[BBUSread];
	case({activateMSB,activateLSB})
		3: begin X[CBUSwriteMSB+1]=CBUS[31:0]; X[CBUSwriteMSB]=CBUS[63:32];end
		1: begin X[CBUSwriteMSB+1]=CBUS[31:0];end
 		2: X[CBUSwriteMSB]=CBUS[63:32];
	endcase
end
endmodule

module ALU(ABUS,BBUS,CBUS,operation,zero,carry,negative);
input [31:0] ABUS,BBUS;
input [2:0] operation;
output reg [63:0] CBUS;
output reg zero,carry,negative;

always@(operation)begin
	case (operation)
		0:begin {carry,CBUS[31:0]}=ABUS-BBUS;zero=(CBUS[31:0] ? 0:1);negative=CBUS[31];end
		1:begin {carry,CBUS[63:0]}=ABUS*BBUS;zero=(CBUS[63:0] ? 0:1);negative=CBUS[63];end
		2:begin CBUS[31:0]=ABUS>>>BBUS;carry=ABUS[BBUS];zero=(CBUS[31:0] ? 0:1);negative=CBUS[31];end
		3:begin CBUS[31:0]=ABUS&BBUS;carry=0;zero=(CBUS[31:0] ? 0:1);negative=CBUS[31];end
		4:begin CBUS[31:0]=ABUS|BBUS;carry=0;zero=(CBUS[31:0] ? 0:1);negative=CBUS[31];end
	endcase
end
endmodule

module programcounter(clk,reset,resetstate,PCinc,Immediate,PCload,PC);
input clk,reset,PCinc,resetstate,PCload;
input [8:0] Immediate;
output reg [31:0] PC;

always@(PCinc or PCload or resetstate)begin
if(PCload)begin
	PC=PC+Immediate;
end
else if(PCinc)begin
	PC=PC+1;
end
else if(resetstate==1)begin
	PC=0;
end
end



endmodule

module control(IR,clk,reset,operation,PCinc,activateLSB,activateMSB,R1,R2,R3,Immediate,PCload,resetstate,nstate,pstate,zero);
output reg [2:0] operation;
output reg resetstate,activateMSB,activateLSB,PCinc,PCload;
input [31:0] IR;
input clk,reset,zero;
wire[7:0] OPCODE;
output wire[4:0] R1,R2,R3;
output wire[8:0] Immediate;
output reg [2:0] pstate,nstate;

assign OPCODE=IR[31:24];
assign R1=IR[22:18];
assign R2=IR[17:13];
assign R3=IR[12:8];
assign Immediate=IR[7:0];

always@(posedge clk or posedge reset)begin
if(reset==1)begin
	pstate=1;
	resetstate=1;
end
else begin
	resetstate=0;
	pstate=nstate;
end
end

always@(pstate)begin
case(pstate)
0: begin
	activateLSB=0;
	activateMSB=0;
	PCinc=0;
	PCload=0;
	case (OPCODE)
		8'h0a:begin operation=0;nstate=2;PCinc=1;end
		8'h14:begin if(zero)begin nstate=1;PCload=1;end end
		8'h1a:begin operation=1;nstate=2;PCinc=1;end
		8'h21:begin operation=2;nstate=2;PCinc=1;end
		8'h22:begin operation=3;nstate=2;PCinc=1;end
		8'h23:begin operation=4;nstate=2;PCinc=1;end
	endcase
end
1: begin
	activateLSB=0;
	activateMSB=0;
	PCinc=0;
	PCload=0;
	nstate=0;
end
2: begin
	activateLSB=0;
	activateMSB=0;
	PCinc=0;
	PCload=0;
	nstate=1;
	case(operation)
		0:begin activateLSB=1;end
		1:begin activateLSB=1;activateMSB=1;end
		2:begin activateLSB=1;end
		3:begin activateLSB=1;end
		4:begin activateLSB=1;end
	endcase
end

endcase
end

endmodule

module testbench (IR, clk, reset, ABUS, BBUS, CBUS, PCvalue, nst, cst, zero,
                  carry, negative, pos);
output [0:31] IR;
reg [0:31] IR;
output clk, reset;
reg clk, reset;
input [0:31] ABUS;
input [0:31] BBUS;
input [0:63] CBUS;
input [0:31] PCvalue;
inout [0:2] nst, cst;
input zero, carry, negative;
input [0:5] pos; // Used by Bushnell's solution for debugging -- you can
                 // ignore this

// Opcode definitions
parameter SUB = 8'h0A, MULT = 8'h1A, RRS = 8'h21, NANDOP = 8'h22,
          OROP = 8'h23, BRANCHIFZERO = 8'h14;

// In your Register File module, please add initialization code to
// set the contents of each Register to its register number, so
// R0 will be set to 0, R1 to 1, ..., and R15 to 15.
// This test bench assumes that the registers have been set that way.
   
initial
  begin
    $dumpvars;
    $dumpfile ("hw5.dump");
    clk = 0;
    reset = 1;
    IR = 0;
#5 reset = 0;
    // SUB instruction
    IR = {SUB, 5'd1, 5'd2, 5'd3, 9'b0};
#10
#10
#10 // MULT instruction
    IR = {MULT, 5'd1, 5'd2, 5'd3, 9'b0};
#10
#10
#10 // RRS instruction
    IR = {RRS, 5'd3, 5'd4, 5'd5, 9'b0};
#10
#10
#10 // NAND instruction
    IR = {NANDOP, 5'd5, 5'd6, 5'd7, 9'b0};
#10
#10
#10 // OR instruction
    IR = {OROP, 5'd7, 5'd8, 5'd9, 9'b0};
#10
#10
#10 // Add R0 <= R0 + R0 to set the Z bit to 1
    IR = {SUB, 5'd0, 5'd0, 5'd0, 9'b0};
#10
#10
#10 //BRANCHIFZERO instruction
    IR = {BRANCHIFZERO, 5'd0, 5'd0, 5'd0, 9'd7};
#10
#10 $finish;
  end

always
#5  clk = ~ clk;

endmodule

module circuit;
wire [4:0] ABUSread,BBUSread,CBUSwriteMSB;
wire activateLSB,activateMSB,clk,reset,PCinc,PCload,resetstate,zero,carry,negative;
wire [63:0] CBUS;
wire [31:0] ABUS,BBUS,IR,PCvalue;
wire [7:0] OPCODE;
wire [8:0] Immediate;
wire [2:0] operation,nstate,pstate;
wire [5:0] pos;
wire [2:0] cst,nst;

testbench(IR, clk, reset, ABUS, BBUS, CBUS, PCvalue, nstate,pstate, zero, carry, negative, pos);
register(ABUSread,BBUSread,CBUSwriteMSB,activateLSB,activateMSB,clk,CBUS,ABUS,BBUS);
ALU(ABUS,BBUS,CBUS,operation,zero,carry,negative);
programcounter(clk,reset,resetstate,PCinc,Immediate,PCload,PCvalue);
control(IR,clk,reset,operation,PCinc,activateLSB,activateMSB,ABUSread,BBUSread,CBUSwriteMSB,Immediate,PCload,resetstate,nstate,pstate,zero);
endmodule
