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
module VGA_Controller2(
input clk,
input switch1,
input switch2,
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
wire [14:0] mem_address;
wire [15:0] DOUTA;
wire [15:0] DOUTB;

wire [14:0] write_address;
wire [15:0] write_data;
wire write_enabled;
 
VGA VGA_Signal(.clk(clk), .pixel(pixelReq) ,.Hsync(Hsync), .Vsync(Vsync),
.red(red), .green(green), .blue(blue), .columnCounter(column), .lineCounter(line),.req(c_req));

Pixel_Gen VGA_Pixel(.clk(clk), .switch1(switch1), .switch2(switch2), .columnCounter(column), .lineCounter(line), .pixel(pixelReq), .req(c_req),
							.DOUTA(DOUTA), .mem_address(mem_address));

CORE_RAM _CORE_RAM(.clka(clk), .dina(16'h0000), .wea(1'b0), .douta(DOUTA), .addra(mem_address), 
				.clkb(clk), .dinb(write_data), .web(write_enabled), .doutb(DOUTB), .addrb(write_address));

Core _Core(.clk(clk), .memory_to_core_data(DOUTB), .write_address(write_address), .write_data(write_data), .write_enabled(write_enabled));
//module Core( 
//input clk,
//input [15:0] memory_to_core_data, 	//input line of assembly opcodes
//output reg [14:0] write_address, 	//address to write to
//output reg [15:0] write_data, 		//data to be written to
//output reg write_enabled 				//write enable memory aka write_enable_data
//    );

endmodule
