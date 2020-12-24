`timescale 1ns / 1ps

module clock_design_TB;

	// Define the given inputs
	reg clk_in;
	reg rst;

	// Define the given outputs
	wire clk_div_2;
	wire clk_div_4;
	wire clk_div_8;
	wire clk_div_16;
	wire clk_div_28;
	wire clk_div_5;
	wire [31:0] toggle_counter;

	// Create the UUT (unit under the testing)
	clock_gen uut (
		.clk_in(clk_in), 
		.rst(rst), 
		.clk_div_2(clk_div_2), 
		.clk_div_4(clk_div_4), 
		.clk_div_8(clk_div_8), 
		.clk_div_16(clk_div_16), 
		.clk_div_28(clk_div_28), 
		.clk_div_5(clk_div_5), 
		.toggle_counter(toggle_counter)
	);

	initial begin
		// Initialize the clock and reset signal
		clk_in = 0;
		rst = 0;
		// Wait for 50 ns
		#50;
		// Set the reset signal to 1
		rst = 1;
		// Wait for 30 ns
		#30;
		// Set the reset signal back to 0
		rst = 0;

	end
	
	// Set the input clock frequency to 100Mhz in the testbench 
	// 10 ns for the clock period
	always begin
		#5;
		clk_in = ~clk_in; 
	end
	
	always begin 
		#1000;
		$finish;
	end


endmodule 