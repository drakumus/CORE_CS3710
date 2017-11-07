`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:37:02 10/19/2017 
// Design Name: 
// Module Name:    Core 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Core(
input clk,
input [15:0] memory_to_core_data, 	//input line of assembly opcodes
output reg [14:0] write_address, 	//address to write to
output reg [15:0] write_data, 		//data to be written to
output reg write_enabled 				//write enable memory aka write_enable_data
    );
//STATES
parameter FETCH = 3'd0, DECODE = 3'd1, EXECUTE = 3'd2, LOAD1 = 3'd3, LOAD2 = 3'd4, STORE = 3'd5, BRANCH = 3'd6;
//LOAD AND STORE INSTRUCTIONS
parameter I_MOV = 4'b0, I_LOAD = 4'b0001, I_SETB = 4'b1000, I_SETT = 4'b1001;
//ARITHMETIC OPS
parameter I_ADD = 4'b0010, I_LSH = 4'b0011; 
//BRANCHING
parameter I_BRL = 4'b0100, I_BRZ = 4'b0101, I_BR = 4'b0110, I_BR_DEST = 4'b0111;
//parameter setlo = 4'b0000, sethi = 4'b0100, add = 4'b0010, loadmem = 4'b1000, storemem = 4'b1001, biz = 4'b1010, bim = 4'b1011;

reg [2:0] state ;
initial state = FETCH;
reg [14:0] po = 15'h5400;
reg status_z, status_n;

reg [14:0] pc;
initial pc = 0;
reg [2:0] 	read_index1; //was wire
reg [2:0] 	read_index2; //was wire
reg  [2:0] 	write_index; //was wire
//wire  [15:0] 	write_data;
//reg 			write_enabled; //was wire
wire [15:0] read_data1;	 
wire [15:0] read_data2;

reg [3:0] opcode;
reg [2:0] dest_index;
reg [15:0] data1;
reg [15:0] data2;
reg [7:0] immediate;

RegisterFile _RegisterFile(.clk(clk), .read_index1(read_index1), .read_index2(read_index2), .write_index(write_index),
.write_data(write_data), .write_enable(write_enabled), .read_data1(read_data1), .read_data2(read_data2));

always @(*) 
begin
	read_index1 = 0;
	read_index2 = 0;
	write_index = 0;
	write_enabled = 0;
	write_data = 0;
	write_address = 0;
	
	case(state)
			FETCH: 
			begin						  //this might assume that the core instructions are in the first bits of memory and looks there
				write_address = pc; //request the next address and returned as mem_to_core_data
			end
			DECODE: begin								 //should these be memory_to_core_address?
				read_index1	= memory_to_core_data [10:8];  //be able to read from a register in index1
				read_index2	= memory_to_core_data [7:5];	 //be able to read from a register in index2
				immediate 	= memory_to_core_data [7:0];	 //set the immediate
			end
			EXECUTE: begin
				write_index = dest_index;
				write_enabled = 1'b1;
				case(opcode)
					I_ADD: write_data = data1+data2;
					I_LSH: 
					begin
						if(data2[7] == 0) //checks if literal is greater than 0
							write_data = data1<<data2;
						else
							write_data = data1>>data2;
					end
				endcase
			end
			LOAD1: begin								//sets the address to write to from the contents of a register
				write_address = read_data2[14:0];		//looks at read_data1 in the register file which is data associated with a register
			end
			LOAD2: begin								//write_index chooses a register to write to then 
				write_index 	= dest_index;		//looks at dest_index in the register file which is data associated with a register
				write_enabled 	= 1; 					//allows for writing to memory
				write_data 		= write_address;	//sets the data to store in the write address to the write address?
			end
			STORE: begin								//store data at an address
				case(opcode)
					I_MOV: //write contents of register to destination address
					begin
						write_address = read_data1[14:0];
						write_data = read_data2;
						//write_index 	= read_index1;	//destination reg is first input reg
						//write_enabled 	= 1;				//enables writing //move contents of one register to another
						//write_data 		= read_data2;	//set contents of first reg to contents of second reg
					end
					I_SETB:	
					begin
						write_index		 = read_index1;							//write to the first input reg
						//write_enabled 	 = 1;											//enables writing
						write_data 		 = {read_data1[15:8], immediate};	//keeps top 8 bits and sets bottom 8 bits
					end
					I_SETT:
					begin
						write_index		 = read_index1;							//write to the first input reg
						//write_enabled 	 = 1;											//enables writing
						write_data 		 = {immediate, read_data1[7:0]};		//keeps bottom 8 bits and sets top 8 bits
					end
				endcase
				//write_address = read_data1;//destination address to read_data1
				//write_data = read_data2;	//set store data to contents of a register at read_data2
			end
	endcase
end

always@(posedge clk)
begin
	case(state)
		FETCH:
		begin
			state <= DECODE;	//move to decode
			pc <= pc + 1'b1;		//increment program counter
		end
		DECODE:
		begin
			opcode <= memory_to_core_data[15:12]; 		//opcode is top 4 bits
			dest_index <= memory_to_core_data[10:8]; 	//which register of the 4 COME BACK TO THIS FIX REGISTER FILE
			data1 <= read_data1;								//first param
			data2 <= read_data2;								//second param
			case (opcode)
				4'b0000: state <= STORE;	//mov
				4'b0001: state <= LOAD1;	//load
				4'b0010: state <= EXECUTE;	//add
				4'b0011: state <= EXECUTE;	//lsh
				4'b0100: state <= BRANCH;	//brl
				4'b0101: state <= BRANCH;	//brz
				4'b0110: state <= BRANCH;	//br
				4'b0111: state <= BRANCH;	//br_dest
				4'b1000: state <= STORE;	//setb
				4'b1001: state <= STORE;	//sett
				//4'b0000: state <= STORE; 	//setlo
				//4'b0100: state <= STORE; 	//sethi
				//4'b0010: state <= EXECUTE; //add
				//4'b1000: state <= LOAD1; 	//loadmem
				//4'b1001: state <= STORE; 	//storemem
				//4'b1010: state <= BRANCH; 	//biz
				//4'b1011: state <= BRANCH; 	//bim
			endcase
		end
		EXECUTE:
		begin
			status_z <= write_data == 0;
			status_n <= write_data [15];
			state <= FETCH;
		end
		LOAD1:
		begin
			state <= LOAD2;
		end
		LOAD2:
		begin
			status_z <= write_data == 0;
			status_n <= write_data [15];
			state <= FETCH;
		end
		BRANCH:
		begin
			case(opcode)
				I_BRZ:
				begin
					if(data1 == data2)
						pc <= pc + {{7{immediate[7]}}, immediate};
				end
				I_BRL:
				begin
					if(data1 < data2)
						pc <= pc + {{7{immediate[7]}}, immediate};
				end
				default: pc <= pc + {{7{immediate[7]}}, immediate};
			endcase
			state <= DECODE;
		end
	endcase
end

endmodule
