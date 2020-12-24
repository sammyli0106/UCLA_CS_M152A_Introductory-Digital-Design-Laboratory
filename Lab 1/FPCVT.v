`timescale 1ns / 1ps 
/*
	Class: UCLA CS 152A
	Name: Sum Yi Li (UID: 505146702)
	Module Name: Floating Point Conversion 
*/

module FPCVT (
	/*
		D[12:0] - input data in two's complement representation 
		S, 1 bit - sign bit o fthe floating point representation 
		E[2:0] - 3 bits exponent of the floating point representation 
		F[4:0] - 5 bits significand of the floating point representation   
	*/
	D, S, E, F
);

	// 13 bits input wire 
	input wire [12:0] D;
	// 1 sign bit wire 
	output wire S;
	// Set the sign bit to the MSB of the 2's complement input data
	// Can set it right away, does not matter to the calculation of the representation
	assign S = D[12];
	// 3 bits exponent wire 
	output wire [2:0] E;
	// 5 bits significand wire
	output wire [4:0] F;

	// Establish some temporary wires for usage 
	wire [12:0] output_temp;
	// 3 bits temporary exponent value
	wire [2:0] exponent_temp;
	// 6 bits temporary significand 
	wire [5:0] significand_temp;

	/* There are three main blocks to implement: 
		1. Convert 2s complement to sign magnitude 
		2. Count leading zeroes and Extract leading zeroes 
		3. Rounding 
	*/

	// First block: 13 bits two's complement input to sign magnitude representation
	// Give uniquie instantiations for the hardware block 
	two_complement_magnitude_converter conversion(
		// 2's complement input
		.input_place(D),
		// sign magnitude output 
		.output_place(output_temp),
		// sign input
		.sign_place(S)
		);

	// Second block : priority encoder to count the number of zeroes and extract the significand output
	count_zero_and_extract_significand extract(
		// input: the sign magnitude representation from block 1
		.input_encoder(output_temp),
		// output: the extracted exponent value from sign magnitude number
		.exponent_encoder(exponent_temp),
		// output: the extracted signifcand value from sign magnitude number 
		.significand_encoder(significand_temp)
		);

	// Third block 
	floating_point_rounding rounding(
		// 2 inputs: temporary significand and exponent from extract and count leading zeroes stage 
		// input: extracted temporary exponent from block 2
		.exponent_temp(exponent_temp),
		// input: extracted temporary significand from block 2
		.significand_temp(significand_temp),
		// 2 outputs: final significand and exponent 
		// output: final exponent value 
		.exponent_final(E),
		// output: final significand value 
		.significand_final(F)
	);

 
endmodule

// Here is the function definition of each block
// Block 1 Definition: 2 complement to sign magnitude conversion 
module two_complement_magnitude_converter (
	input_place,
	output_place,
	sign_place
	);

// Establish input and output variables
// This is the 2's complement input 
input [12:0] input_place;
// This is the sign magnitude representation output
output [12:0] output_place;
// This is a temporary register variable to store the updated sign magnitude
reg [12:0] pre_output_place;
// This is the sign bit of the floating point representation
input sign_place;

// This is a register variable to store the most negative 13 bits value in 2's complement 
reg [12:0] smallest_two_comp;
// This is a register variable to store the most positive 13 bits value in 2's complement  
reg [12:0] biggest_two_comp;

always @ (*) begin
	// Assign the two register variables for comparison later 
	smallest_two_comp = -13'b1000000000000;
	biggest_two_comp = 13'b0111111111111;

	pre_output_place = output_place;

	// Check if the sign bit is zero or not 
	if(input_place[12] == 0) begin
		// This is a positive nubmer, so we just keep the same form 
		pre_output_place = input_place;
	end 
	else begin 
		// This is a negative number and require, negation
		// First, check if it is the most negative number 
		if(input_place != smallest_two_comp) begin
			// If it is not, we just simply negate all the bits and add 1
			pre_output_place = ~input_place + 1;
		end
		else begin 
			// If it is, then we will set it to most positive number before count and extract stage 
			pre_output_place = biggest_two_comp;
		end

	end  
end 

// use assign to put values in the output variable outside always block 
assign output_place = pre_output_place;

endmodule

// Block 2 definition: Count leading zeroes and extract leading bits 
module count_zero_and_extract_significand (
	input_encoder, exponent_encoder, significand_encoder
	);

// Define the input and output variables for this module
// 13 bits sign magnitude value 
input [12:0] input_encoder;
// 3 bit extracted exponent value based from the encoding table 
output [2:0] exponent_encoder;
// 6 bit extracted significand value with addition 1 bit for rounding purpose 
output [5:0] significand_encoder;


// Set up some temporary variables for shifting 
// 4 bits to store the number of zeroes in register
wire [3:0] num_of_zeros_wire;
// 4 bits to store the number of zeroes in register 
reg [3:0] num_of_zeros_reg;
// 4 bits variable that store value needs to be shifted 
reg [3:0] position_shift;

// Set up some temporary variables for assignment to output variables 
// 13 bits shifted version of the original sign magnitude value 
reg [12:0] shifted_input;
// 5 bits counting from right of original sign magnitude value 
reg [4:0] lsb_significand; 
// 3 bits temporary exponent register
reg [2:0] exponent_temp;
// 6 bits temporary significand register 
reg [5:0] significand_temp;

// First, count the number of leading zeros in the input value 
assign num_of_zeros_wire = (input_encoder[12] == 1) ? 4'b0001 :
					  // 1 leading zero 
					  (input_encoder[11] == 1) ? 4'b0001 :
					  // 2 leading zeroes
					  (input_encoder[10] == 1) ? 4'b0010 :
					  // 3 leading zeroes 
					  (input_encoder[9] == 1) ? 4'b0011 :
					  // 4 leading zeroes 
					  (input_encoder[8] == 1) ? 4'b0100 :
					  // 5 leading zeroes 
					  (input_encoder[7] == 1) ? 4'b0101 :
					  // 6 leading zeroes 
					  (input_encoder[6] == 1) ? 4'b0110 :
					  // 7 leading zeroes 
					  (input_encoder[5] == 1) ? 4'b0111 :
					  // 8 leading zeroes 
					  (input_encoder[4] == 1) ? 4'b1000 :
					  // 9 leading zeroes 
					  (input_encoder[3] == 1) ? 4'b1001 : 
					  // 10 leading zeroes 
					  (input_encoder[2] == 1) ? 4'b1010 :
					  // 11 leading zeroes 
					  (input_encoder[1] == 1) ? 4'b1011 :
					  // 12 leading zeroes 
					  (input_encoder[0] == 1) ? 4'b1100 : 
					  4'b0000;

always @ (*) begin
	// predefined all the register variables with zero or corresponding values 
	num_of_zeros_reg = num_of_zeros_wire;
	exponent_temp = 0;
	significand_temp = 0;
	position_shift = 0;

	// Check the number of leading zeroes
	// Get rid of the extra leading zeros for converting to exponent number 
	if (num_of_zeros_wire >= 4'b1000) begin
		num_of_zeros_reg = 4'b1000;
	end

	//Find the corresponding exponent with the value of leading zeros (could change it to if else)
	exponent_temp = (num_of_zeros_reg == 0) ? 0 :
					(num_of_zeros_reg == 1) ? 7 : 
					(num_of_zeros_reg == 2) ? 6 :
					(num_of_zeros_reg == 3) ? 5 :
					(num_of_zeros_reg == 4) ? 4 :
					(num_of_zeros_reg == 5) ? 3 :
					(num_of_zeros_reg == 6) ? 2 :
					(num_of_zeros_reg == 7) ? 1 :
					(num_of_zeros_reg == 8) ? 0 :
					0;
	

	// Calculate the shift value 
	position_shift = 13 - (num_of_zeros_reg + 6);

	// When number of leading zero is less than 8 
	if (num_of_zeros_reg != 8) begin 
		// We need to first right shift the 6 bits which is 5 bits of significand plus the 1 bit rounding bit 
		shifted_input = input_encoder >> position_shift;
		// Extract the shifted 6 bits 
		significand_temp = shifted_input[5:0];
	end 
	else begin 
		// When number of leading zero is equal to 8, then extract the rightmost 5 bits from the sign magnitude value 
		lsb_significand = input_encoder[4:0];
		// Concatenate a zero at the end of the 5 bit sign magnitude value to make it to 6 bits for significand encoder
		/* We are padding a zero for rounding purpose if there are 8 leading zeros, which means left with 5 bit significand, 
		we need one more bit (6th bit) to see if we are rounding up or down */
		significand_temp = {lsb_significand, 1'b0};
	end 

end 

// Assign the extract value of significand and exponent to the corresponding output variables 
assign significand_encoder = significand_temp;
// Remember to use assign outside always block
assign exponent_encoder = exponent_temp;

endmodule

// Block 3 definition: Rounding Block 
module floating_point_rounding (
	// Define all the input and output ports based from function definition 
	exponent_temp, significand_temp, exponent_final, significand_final
	);

	// Define the number of bits for the input and output variables 
	input [2:0] exponent_temp;
	output [2:0] exponent_final;
	input [5:0] significand_temp;
	output [4:0] significand_final;

	// Define two register variables to store the final significand and exponent value for assignment in always block
	reg [2:0] exponent_reg;
	reg [5:0] significand_reg;
	// 5 bits temporary extracted significand bits 
	reg [4:0] extracted_significand;

	/*
		4 Rounding scenarios:

		1) Round Down, when the bit(last bit in temporary significand) after the inital 5 significand bits is 0
		2) Round Up, when the last bit in the temporary significand is 1 
			2.1) Normal round up, when all the significand bits are not 1, at least one of the bit is zero 
			2.2) Round up, when all the significand bits are 1, but exponent is less than 7 (the largest exponent)
			2.3) Round up, when all the significand bits are 1, but exponent is equal to 7 (the largest exponent) 
	*/

	always @ (*) begin
		// Assign the register variables with values of temporary exponent and significand values 
		exponent_reg = exponent_temp;
		significand_reg = significand_temp;

		// Check whether the rounding bit is equal to 0(round down) or 1(round up)
		if (significand_temp[0] == 0) begin
			// Round Down Case, just extract the 5 significand bits, ignore the last rounding bit 
			// Exponent value stays the same 
			exponent_reg = exponent_temp;
			// Extract the 5 bits significand index from 1 to 5
			significand_reg = significand_temp[5:1];
		end 
		else begin 
			// Round Up case, when significand_temp[0] == 1

			// If there is at least a zero among significand, can use AND to check if the outcome is 1 
			if ((& significand_temp) != 1) begin 
				// Normal Round Up: get the 5 bits of significand, and add 1 to it 
				exponent_reg = exponent_temp;
				extracted_significand = significand_temp[5:1];
				significand_reg = extracted_significand + 1;
			end
			else begin 
				// This is when all the significands bits are 1
				if (exponent_temp == 3'b111) begin 
					// If exponent is equal to 7, at max, and significand already all ones, so we use the largest possible floating point representation 
					// So exponent bits and significand bits are all ones 
					exponent_reg = exponent_temp;
					significand_reg = 5'b11111;
				end
				else if (exponent_temp < 3'b111) begin 
					// If exponent is less than 7, after adding one, shifting right and increase the exponent by 1
					exponent_reg = exponent_temp + 1;
					significand_reg = 5'b10000;
				end 
			end 
		end 
	end 

	// Update the latest value for the final exponent and significand output variables 
	assign exponent_final = exponent_reg;
	// Remeber to use assign outside always block 
	assign significand_final = significand_reg;

endmodule







