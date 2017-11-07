`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:13:38 09/25/2017
// Design Name:   VGA_Controller2
// Module Name:   C:/Xilinx/VGADisplay/VGA_Controller2_Test.v
// Project Name:  VGADisplay
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: VGA_Controller2
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module VGA_Controller2_Test;

	// Inputs
	reg clk;
	reg switch;

	// Outputs
	wire Hsync;
	wire Vsync;
	wire [2:0] red;
	wire [2:0] green;
	wire [1:0] blue;

	// Instantiate the Unit Under Test (UUT)
	VGA_Controller2 uut (
		.clk(clk), 
		.switch(switch), 
		.Hsync(Hsync), 
		.Vsync(Vsync), 
		.red(red), 
		.green(green), 
		.blue(blue)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		switch = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
   always #1 clk = ~clk;
endmodule

