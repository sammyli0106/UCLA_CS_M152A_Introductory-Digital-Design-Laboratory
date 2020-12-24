// Remember to change the name of the file to testbench 505146702.v when it is ready to submit 

`timescale 1ns / 1ps

module floating_point_converter_TB;

// This is the input data in two's complement representation
reg [12:0] two_complement_value;

// Output variable for sign bit 
wire sign_bit;
// Output variable for exponent 
wire [2:0] exponent;
// Output variable for signicand 
wire [4:0] significand;

// Define the unit under test, instantiate with values
FPCVT uut (
	.D(two_complement_value),
	.S(sign_bit),
	.E(exponent),
	.F(significand)
);

initial begin 
	// Assign a value to input first 
	two_complement_value = 0;

	// Try test values from the examples of the spec to check
	#30;
	two_complement_value = -104;

	#30;
	two_complement_value = 120;

	#30;
	two_complement_value = 253;

	#30;
	two_complement_value = 4095;

	#30;
	two_complement_value = -4095;

	#30;
	two_complement_value = 0;

	#30;
	two_complement_value = -4096;

	//108
	#30;
	two_complement_value = 13'b0000001101100;

	#30;
	two_complement_value = 13'b0000001101101;

	//110
	#30;
	two_complement_value = 13'b0000001101110;

	#30;
	two_complement_value = 13'b0000001101111;

	// Try test some basic numbers 

	#30;
	two_complement_value = 0;

	#30; 
	two_complement_value = 1;

	#30;
	two_complement_value = 10;

	#30;
	two_complement_value = 20;

	#30;
	two_complement_value = 30;

	#30;
	two_complement_value = 40;

	#30;
	two_complement_value = 44;

	#30;
	two_complement_value = 55;

	#30;
	two_complement_value = 56;

	#30;
	two_complement_value = 100;

	#30;
	two_complement_value = 125;

	#30;
	two_complement_value = 128;

	#30;
	two_complement_value = 416;

	#30;
	two_complement_value = 422;

	#30;
	two_complement_value = -422;

	// Test bigger values in positive and negative 
	#30;
	two_complement_value = 3968;

	#30;
	two_complement_value = -3968;

	#30;
	two_complement_value = 3969;

	#30;
	two_complement_value = -3969;

	#30;
	two_complement_value = 4000;

	#30;


end

endmodule








