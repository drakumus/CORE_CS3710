`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:07:28 09/14/2017 
// Design Name: 
// Module Name:    VGA_Controller 
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
module VGA_Controller(
input clk,
input switch, 
output Hsync,
output Vsync,
output [2:0] red,
output [2:0] green,
output [1:0] blue
);

wire [7:0] pixelReq;

wire c_req;

wire [9:0] line;
wire [9:0] column;

 
VGA VGA_Signal(.clk(clk), .pixel(pixelReq) ,.Hsync(Hsync), .Vsync(Vsync),
.red(red), .green(green), .blue(blue), .columnCounter(column), .lineCounter(line),.req(c_req));

Pixel_Gen VGA_Pixel(.clk(clk), .switch(switch), .columnCounter(column), .lineCounter(line), .pixel(pixelReq), .req(c_req));

endmodule
