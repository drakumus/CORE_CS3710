`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:02:21 09/25/2017
// Design Name:   Pixel_Gen
// Module Name:   C:/Xilinx/VGADisplay/pixelTest.v
// Project Name:  VGADisplay
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Pixel_Gen
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module pixelTest;

	// Inputs
	reg clk;
	reg [9:0] columnCounter;
	reg [9:0] lineCounter;
	reg switch;
	reg req;

	// Outputs
	wire [7:0] pixel;

	// Instantiate the Unit Under Test (UUT)
	Pixel_Gen uut (
		.clk(clk), 
		.columnCounter(columnCounter), 
		.lineCounter(lineCounter), 
		.switch(switch), 
		.req(req), 
		.pixel(pixel)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		columnCounter = 0;
		lineCounter = 0;
		switch = 0;
		req = 0;

		// Wait 100 ns for global reset to finish
		#100;

		// Add stimulus here

	end
always begin #2 clk = ~clk;
end
      
endmodule

