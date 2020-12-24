`timescale 1ms / 1ps

module testbench_505146702;

	// Define the given inputs
	reg add1;
	reg add2;
	reg add3;
	reg add4;
	reg rst1;
	reg rst2;
	reg clk;
	reg rst;

	// Defint the given outputs 
	wire a3;
	wire a2;
	wire a1;
	wire a0;
	wire [6:0] led_seg;
	wire [3:0] val3;
	wire [3:0] val2;
	wire [3:0] val1;
	wire [3:0] val0;

	// Need to instantiate the parking meter with the given inputs and outputs 
	parking_meter uut (
		.add1(add1), 
		.add2(add2), 
		.add3(add3), 
		.add4(add4), 
		.rst1(rst1), 
		.rst2(rst2), 
		.clk(clk), 
		.rst(rst), 
		.a3(a3), 
		.a2(a2), 
		.a1(a1), 
		.a0(a0), 
		.led_seg(led_seg), 
		.val3(val3), 
		.val2(val2), 
		.val1(val1), 
		.val0(val0)
	);

	initial begin
		// First set all the needed input registers to zero 
		add1 = 0;
		add2 = 0;
		add3 = 0;
		add4 = 0;
		rst1 = 0;
		rst2 = 0;
		clk = 0;
		rst = 0;

		// Then, wait for 1000 ms = 1 sec for eveyrthing to reset 
		#1000;
		// 1. Test the functionality of add4 to add seconds to the parking meter 
		// Reset everything before testing 
		rst = 1;
		#3000;
		rst = 0;
		#3000;
		// Set the add4 signal to high  
		add4 = 1;
		#500;   
		// Set the add4 signal back to low  
		add4 = 0;
		#4500;
		
		// 2. Test the functionality of add3 to add seconds to the parking meter 
		// Reset everything before testing 
		rst = 1;
		#3000;
		rst = 0;
		#3000;
		// Set the add3 signal to high 
		add3 = 1;
		#500;
		// Set the add3 signal back to low 
		add3 = 0;
		#4500;
		
		// 3. Test the functionality of add2 to add seconds to the parking meter 
		// Reset everything before testing 
		rst = 1;
		#3000;
		rst = 0;
		#3000;
		// Set the add2 signal to high 
		add2 = 1;
		#500;
		// Set the add2 signal back to low 
		add2 = 0;
		#4500;
	
		// 4. Test the functionality of add1 to add seconds to the parking meter
		// Reset everything before testing  
		rst = 1;
		#3000;
		rst = 0;
		#3000;
		// Set the add1 signal to high 
		add1 = 1;
		#500;
		// Set the add1 signal back to low 
		add1 = 0;
		#4500;
		
		// 5. Test the functionality of rst1 to reset the seconds of the parking meter 
		// Set the rst1 signal to high 
		rst1 = 1;
		#500;
		// Set the rst1 signal back to low 
		rst1 = 0;
		#4500;

		// 6. Test the functionality of rst2 to reset the seconds of the parking meter 
		// Set the rst2 signal to high 
		rst2 = 1;
		#500;
		// Set the rst2 signal to low 
		rst2 = 0;
		#4500;

		// 7. Test the flash period for 180 seconds 
		// Reset everything before testing 
		rst = 1;
		#3000;
		rst = 0;
		#3000;
		// Set add3 signal to high 
		add3 = 1;
		#500;
		// Set add3 signal back to low 
		add3 = 0;

		// Test the flash period after exceed 180 seconds 
		#2500;
		// Set add1 signal to high 
		add1 = 1;
		#500;
		// Set add1 signal back to low 
		add1 = 0; 
		#251000;
		
		// 8. Test the mmaxium value of the seconds stored in the parking meter 
		// Set add4 signal to high 
		add4 = 1;
		// Set add4 signal back to low 
		#41000
		add4 = 0;	

	end
	
	always begin
		// input clock frequency, 100 Hz
		#5; 
		clk <= ~clk; 
	end
	
	always begin
		#20000000; 
		$finish;
	end

endmodule