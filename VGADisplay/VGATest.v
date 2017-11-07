`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:41:00 09/07/2017
// Design Name:   VGA
// Module Name:   C:/Xilinx/VGADisplay/VGATest.v
// Project Name:  VGADisplay
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: VGA
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module VGATest;

	// Inputs
	reg clk;

	// Outputs
	wire Hsync;
	wire Vsync;
	wire [2:0] red;
	wire [2:0] green;
	wire [1:0] blue;
	wire [9:0] columnCounter;
	wire [9:0] lineCounter;

	// Instantiate the Unit Under Test (UUT)
	VGA uut (
		.clk(clk), 
		.Hsync(Hsync), 
		.Vsync(Vsync), 
		.red(red), 
		.green(green), 
		.blue(blue), 
		.columnCounter(columnCounter), 
		.lineCounter(lineCounter),
		.led(LED)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		
		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
       
	always #5 clk = ~clk;
endmodule
 
