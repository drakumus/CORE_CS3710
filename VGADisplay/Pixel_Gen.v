`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:50:30 09/15/2017 
// Design Name: 
// Module Name:    Pixel_Gen 
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
module Pixel_Gen(
input clk,
input [9:0] columnCounter, 
input [9:0] lineCounter, 
input switch1,
input switch2,
input req, 
input [15:0] DOUTA,
output reg [7:0] pixel,
output [14:0] mem_address
    );
reg [2:0] STATE = 2'b0;
parameter REQ = 2'b0, R_T = 2'b01, R_G = 2'b10, O_P = 2'b11;	 
initial pixel = 1'b0;
////////////////////////////////////LAST WEEK//////////////////////////////////////
wire [7:0] nextPixel;
wire [9:0] logicColumn;
wire [9:0] logicLine;
assign logicColumn = columnCounter - 8'd144;
assign logicLine = lineCounter - 6'd35;
 
reg [31:0] seed = 32'b10100110111101011011101110111010;
wire [31:0] seedNext;
assign seedNext = {seed[23:0],random[7:0]};//
wire [7:0] random;
assign random = seed[31:24]^seed[23:16];

reg [41:0] counter = 42'b0;

wire [7:0] color;
assign color = ~random;

assign nextPixel = switch1 ? logicColumn[6]^logicLine[6]? 8'b11111111: 8'b0:
											//random                ? 8'b11111111: 8'b0;
											logicColumn[4]^logicLine[4]? random: 
											color;
//////////////////////////////////////////////////////////////////////////////////
reg [7:0] c = 8'b0;
reg isOn = 1'b0; 
//wire [15:0] DOUTA;
wire [14:0] glyphAddress;
//add offset 0x2000 to 4*bottom 7 bits of text data out.
//bottom 2 bits of logic line are then used to determine which 4 line seg.
assign glyphAddress = 14'h2000 + {DOUTA[6:0],logicLine[2:1]};

wire [14:0] textAddress;
//row left shift by 7 bits to provide proper offset for row.
assign textAddress = {1'b0, logicLine[9:3], logicColumn[9:3]};

//wire [14:0] mem_address;
assign mem_address = STATE == REQ ? textAddress: glyphAddress;

//(* BOX_TYPE = "primitive" *)
//VGA_RAM RAM(.clka(clk), .dina(16'h0000), .wea(1'b0), .douta(DOUTA), .addra(mem_address));

always @(posedge clk)
begin
	counter <= counter + 1'b1;
	seed <= seedNext; 
	if(req && !switch2)	//hacked out code from the snow,checker part of previous assignment
		pixel <= nextPixel; 
	else
	begin
	case(STATE)
		REQ: //idle until request
		begin
			if(req)
			begin
				STATE <= R_T;
				//ADDRA <= textAddress;
			end
			else
				STATE <= REQ;
		end
		R_T: //retrieve text
		begin
			c <= DOUTA[15:8]; //text color
			STATE <= R_G;
		end
		R_G: //retrieve glyph
		begin
			//compute pixel in glyph
			//use bottom 3 bits (leftovers from divide by 8)
			//check row modulo for top bits or bottom
			if(logicLine[0] == 0)
			begin //x2000 = 14'b10 0000 0000 0000
				isOn <= DOUTA[{1'b1,logicColumn[2:0]}]; //address into bits 15-8
			end
			else
			begin
				isOn <= DOUTA[logicColumn[2:0]]; //address into bits 7-0
			end
			STATE <= O_P;
		end
		O_P: //output pixel
		begin
			//assign color to pixel based on glyph pixel.
			if(isOn)
				pixel <= c;
			else
				pixel <= 8'b0; 
			STATE <= REQ;
		end
	endcase
	end
end

endmodule
