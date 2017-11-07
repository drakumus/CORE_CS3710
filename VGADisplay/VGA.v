`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:46:18 09/06/2017 
// Design Name: 
// Module Name:    VGA 
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
module VGA(
input clk,
input [7:0] pixel,
output Hsync,
output Vsync,
output [2:0] red,
output [2:0] green,
output [1:0] blue,
output reg [9:0] columnCounter, lineCounter,
output req
    );
parameter HPULSE = 96, HBD = 48, HDISPLAY = 640, HFD = 16;	 
parameter VPULSE = 2, VBD = 10, VDISPLAY = 480, VFD = 33;

initial columnCounter = 0;
initial lineCounter = 0;
//initial {red[2:0], green[2:0], blue[1:0]} = 8'b00000000;
reg [1:0] pixelCounter = 0; //next state counter

reg [9:0] hsyncCounter = 10'b0; //next state counter
reg [9:0] vsyncCounter = 10'b0; //next state counter

reg isDrawableH = 1'b0;
reg isDrawableV = 1'b0;

wire HsyncNext; //holds the value of HSync for the next state and interacts with all blocked logic
wire VsyncNext; //holds the value of VSync for the next state and interacts with all blocked logic

wire isDrawableHNext;
wire isDrawableVNext;

wire [1:0] pixelCounterNext; //holds counter for 0 through 3 for a count of 4 that simulates dividing clock by 4
wire [9:0] columnCounterNext; //counter used for checking thresholds on doors and tracks currently drawn pixel
wire [9:0] lineCounterNext; //counter used for checking thresholds on doors and tracks currently drawn pixel

assign req = pixelCounter == 2'b11 ? 1'b1:1'b0;
//does this work since front + back porch = 41 pixels verticle
//58 for horizontal?
assign pixelCounterNext = pixelCounter == 2'd3 ? 1'b0: pixelCounter + 1'b1;			//	* display pixel + doors
assign columnCounterNext = columnCounter == 10'd799 && pixelCounterNext == 2'd3 ? 1'b0 : 	//check if columnCounter needs to be reset *
									pixelCounterNext == 2'd3 ? columnCounter + 1'b1: //if not check if pixel counter has reached it's 4th count [0-3] and inc
									                           columnCounter;			 //otherwise maintain value from last state      ^this logic simulates slow clock
// 
assign lineCounterNext = lineCounter== 10'd524 ? 1'b0 : 			      // check if line counter needs to be reset *
								 columnCounterNext == 10'd799 && pixelCounterNext == 2'd3 ? lineCounter + 1'b1: // check column counter is gen last pixel, if so inc 
																		  lineCounter;				// if not maintain previous value
// 0 < columnCounter <= 96
assign Hsync = columnCounterNext >= 96;
//assign HsyncNext = columnCounter == 10'd0  ? 1'b0 : //if we find the last column is being drawn assert Hsync
//						 columnCounter == 10'd96 ? 1'b1 : //if we find that columnCounter is back to first pixel turn off Hsync
//												         Hsync; //otherwise let Hsync be what is was the previous cycle

// 0 < lineCounter <= 2 
assign Vsync = lineCounterNext >= 2;
//assign VsyncNext = lineCounter == 10'd0 ? 1'b0 : //if we find the last row is being drawn assert Hsync
//						 lineCounter == 10'd2   ? 1'b1 : //if we find the first line is being drawn (reset lineCounter) turn off Vsync
//														  Vsync; //otherwise let Vsync be what is was last cycle
//pulse, bp, disp, fp > 96, 48, 640, 16
//144 < columnCounterNext <= 784
assign isDrawableHNext = columnCounter == 10'd144  ? 1'b1 : //was 144 //96 + 48
								 columnCounter == 10'd784 ? 1'b0 : //was784 //96 + 48 + 640
								 isDrawableH;


//pulse, bp, disp, fp > 2, 29, 480, 10
//make sure it's drawing at end of pixel and not begining. Done?
//35 < lineCounterNext <= 515
assign isDrawableVNext = lineCounter == 10'd35  ? 1'b1 : //was 35 //2+33
								 lineCounter == 10'd515 ? 1'b0 : //was 522 //2+33+480
								 isDrawableV;

assign {red[2:0], blue[1:0], green[2:0]} = isDrawableV && isDrawableH ? pixel:1'b0;
//assign pixel = pixelCounter==0 ? 8'b11111111 : 8'b0;
//don't draw pixels until 47 for horizontal (make them black) 
//don't sync horizontal until 640+48+16
//don't draw pixels until 33 for verticle (make them black)
//don't sync verticle until 480+33+10 
always @(posedge clk)
begin

	//pixelCounter <= pixelCounter + 1'b1;
	pixelCounter <= pixelCounterNext;
	columnCounter <= columnCounterNext;
	lineCounter <= lineCounterNext; 
//	Hsync <= HsyncNext;
//	Vsync <= VsyncNext;
	isDrawableH <= isDrawableHNext;
	isDrawableV <= isDrawableVNext;
end

always @(*)
begin 

end

endmodule
