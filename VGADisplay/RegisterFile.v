`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:36 10/19/2017 
// Design Name: 
// Module Name:    RegisterFile 
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
module RegisterFile(
input clk,
input  [2:0] 	read_index1,
input  [2:0] 	read_index2,
input  [2:0] 	write_index,
input  [15:0] 	write_data,
input 			write_enable,
output reg [15:0] 	read_data1,
output reg [15:0] 	read_data2	// Look at this later. Is this a reg or not? Gives error if not reg
    );
reg [15:0] A1;
reg [15:0] A2;
reg [15:0] A3;
reg [15:0] D1;
reg [15:0] SP;
reg [15:0] FP;
reg [15:0] OUT;

reg [15:0] LIT = 0;
//reg [15:0] R1 = 0; 

always@*
begin 
	case (read_index1)
		0:	read_data1 = LIT;
		1:	read_data1 = A1;
		2: read_data1 = A2;
		3: read_data1 = A3;
		4: read_data1 = D1;
		5: read_data1 = OUT;
		6: read_data1 = FP;
		7: read_data1 = SP;
	endcase
	case (read_index2)
		0:	read_data2 = LIT;
		1:	read_data2 = A1;
		2: read_data2 = A2;
		3: read_data2 = A3;
		4: read_data2 = D1;
		5: read_data2 = OUT;
		6: read_data2 = FP;
		7: read_data2 = SP;
	endcase
end

always @ (posedge clk)
begin
		if(write_enable)
		begin
			case (write_index)
				0: LIT <= write_data;
				1: A1  <= write_data;
				2: A2  <= write_data;
				3: A3  <= write_data;
				4: D1  <= write_data;
				5: OUT <= write_data;
				6: FP  <= write_data;
				7: SP  <= write_data;
			endcase;
		end
end

endmodule
