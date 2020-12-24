/*
	Class: UCLA CS 152A
	Name: Sum Yi Li (UID: 505146702)
	Module Name: Clock Design Methodology  
*/

`timescale 1ns / 1ps

/*
	The following are the given inputs from the spec.
	This the top level module 
*/

module clock_gen( 
	input clk_in,
	input rst,
	output clk_div_2,
	output clk_div_4,
	output clk_div_8,
	output clk_div_16,
	output clk_div_28,

	// Add a temporary output variable for clock div 32
	output clk_div_32,

	// Add three temporary output variables for task 4, 5, 6
	output thirty_three_duty_cycle_pos_edge,
	output thirty_three_duty_cycle_neg_edge,
	output thirty_three_duty_cycle_pos_OR_neg_edge,

	output clk_div_5,
	output [31:0] toggle_counter );
	
	// First module 
	clock_div_two task_one( 
		.clk_in(clk_in),
		.rst(rst), 
		// Task 1: Clock Divider by Power of 2s
		.clk_div_2(clk_div_2), 
		.clk_div_4(clk_div_4), 
		.clk_div_8(clk_div_8), 
		.clk_div_16(clk_div_16) 
		);

	// Task 2: Generate the divide by 32 clocks 
	// Temporary module for clock div 32
	clock_div_thirty_two temp_task(
		.clk_in(clk_in),
		.rst(rst), 
		.clk_div_32(clk_div_32) 
	);

	// Task 3: Generate the divide by 28 clocks
	// Second module 
	clock_div_twenty_eight task_two( 
		.clk_in(clk_in),
		.rst(rst), 
		.clk_div_28(clk_div_28) 
	);
	
	// Task 4, 5, 6: Generte two 33% duty cycle clock (raising, falling edge), and logical OR of the two clocks
	// Temporary module for combined task 4, 5, 6 togther due to comparison of waveform diagram side by side
	clock_div_thirty_three_duty_cycle temp_task_two(
		.clk_in(clk_in),
		.rst(rst),
		.thirty_three_duty_cycle_pos_edge(thirty_three_duty_cycle_pos_edge),
		.thirty_three_duty_cycle_neg_edge(thirty_three_duty_cycle_neg_edge),
		.thirty_three_duty_cycle_pos_OR_neg_edge(thirty_three_duty_cycle_pos_OR_neg_edge)
	);


	// Task 7: Generate a 50% duty cycle divide by 5 clock 
	clock_div_five task_three( 
		.clk_in(clk_in),
		.rst(rst), 
		.clk_div_5(clk_div_5) 
		);

	// Task 8: verify the output clock is 50% divided by 200 clocks running at 500Khz
	clock_div_two_hundred temp_task_three(
		.clk_in(clk_in),
		.rst(rst),
		.clk_div_200(clk_div_200)
	);

	// Task 9: Generate a 8 bit counter that counts up to 2 on every positive edge of the master clock, but subtracts by 5 on every strobe
	// Fourth module: Use the master clock and a divide by 4 strobe to generate an 8 bit counter
	clock_strobe task_four( 
		.clk_in(clk_in),
		.rst(rst),
		.toggle_counter (toggle_counter)
	);

endmodule

// Design Task 1: Assign 4 1-bit wires to each of the bits from the 4 bit counter 
module clock_div_two(
	// Set up the input variables 
	input clk_in, 
	input rst, 
	// Set up the output variables 
	output clk_div_2, 
	output clk_div_4, 
	output clk_div_8, 
	output clk_div_16
);

	// Instantiate a 4 bit variable to store the temporary value during the count up process
	reg [3:0] temp_count;

	// Assign 4 1-bit wires to each of the bits from the 4 bit temporary counter 
	// The first bit of the counter 
	assign clk_div_2 = temp_count[0];
	// The second bit of the counter 
	assign clk_div_4 = temp_count[1];
	// The third bit of the counter 
	assign clk_div_8 = temp_count[2];
	// The fourth bit of the counter 
	assign clk_div_16 = temp_count[3];

	// I need to first initalize the counter since it is not initalize when it first starts 
	// Set the counter to 0 in the initial block 
	// Remember to use the non-blocking assignment operator 
	initial begin 
		temp_count <= 0;
	end 

	// Then, create a 4 bit counter within the always block 
	always @ (posedge clk_in) begin
		if (rst)
			// Reset the count to 0 
			temp_count <= 4'b0000;
		else 
			// Increment the counter by 1
			temp_count <= temp_count + 1'b1;
	end 

endmodule

// Observe Task 2: Generate the divide by 32 clocks by flipping the output clock on every counter overflow
module clock_div_thirty_two (
	// Set up the input variables 
	input clk_in,
	input rst,
	// Set up the output register 
	output clk_div_32
	);
	
	// Instantiate a 4 bit variable to store the temporary value during the count up process
	reg [3:0] temp_count;
	// Create a temporary register variable to store the final output 
	reg clk_32;
	// Assign the final output variable of clock div 32 to store the value from the temporary variable 
	assign clk_div_32 = clk_32;

	// Set both the counter and output register variable for divide clock of 32
	// Remember to use the non-blocking assignment operator 
	initial begin 
		// Initialize the counter to 0 
		temp_count <= 0;
		// Initialize the output register for fivide clock of 32 to 0
		clk_32 <= 0;
	end 

	// Then, modify the 4 bit counter to count from 0 to 15, then on the 16th edge, flip the output 
	always @ (posedge clk_in) begin
		if (rst) begin 
			// Reset the counter to 0
			temp_count <= 0;
			// Reset the output register for divide clock of 32
			clk_32 <= 0;
		end 
		// Check if the current count is already 15, get ready to flip the clock 
		else if (temp_count == 4'b1111) begin 
			// Reset the counter to 0
			temp_count <= 0;
			// Flip the output register for divide clock of 32 
			clk_32 <= ~clk_32;
		end 
		else 
			// Increment the counter by 1
			temp_count <= temp_count + 1'b1;
	end 

endmodule 


// Design task 3: generate a clock that is 28 times smaller by modifying when the counter resets to 0
module clock_div_twenty_eight(
	// Set up the input variables 
	input clk_in,
	input rst,
	// Set up the output variables 
	output clk_div_28
);
	// Instantiate a 4 bit variable to store the temporary value during the count up process
	reg [3:0] temp_count;
	// Create a temporary register variable to store the final output
	reg temp_clk_28;
	// Assign the final output variable of clock div 28 to store the value from the temporary variable 
	assign clk_div_28 = temp_clk_28;

	// Set both the counter and output register variable for divide clock of 28
	// Remember to use the non-blocking assignment operator 
	initial begin 
		// Initialize the counter to 0 
		temp_count <= 0;
		// Initialize the output register for divide clock of 28 to 0
		temp_clk_28 <= 0;
	end 

	// Then, modify the 4 bit counter to count from 0 to 13, then on the 14th edge, flip the output
	always @ (posedge clk_in) begin
		if (rst) begin
			// Reset the counter to 0
			temp_count <= 0;
			// Reset the output register for divide clock of 28 
			temp_clk_28 <= 0;
		end 
		// Check if the current count is already 13, get ready to flip the clock 
		else if (temp_count == 4'b1101) begin 
			// Reset the counter to 0
			temp_count <= 0;
			// flip the output register for divide clock of 28 
			temp_clk_28 <= ~temp_clk_28;
		end 
		else 
			// Increment the counter by 1
			temp_count <= temp_count + 1'b1;
	end 

endmodule

// Observe task 4: Generate a 33% duty cycle clock (rising on positive edge) using if statement and counters and verify the waveform 
// Observe task 5: Generate a 33% duty cycle clock (rising on negative edge) using if statement and counters and verify the waveform 
// Observe task 6: Assign a wire that takes the logical or of the two 33% duty cycle clock 
module clock_div_thirty_three_duty_cycle(
	// Set up the input variables
	input clk_in,
	input rst,
	// Set up the output variables
	output thirty_three_duty_cycle_pos_edge,
	output thirty_three_duty_cycle_neg_edge,
	output thirty_three_duty_cycle_pos_OR_neg_edge
	);
	
	// Create temporary variable for the 33% duty cycle positive edge
	reg thirty_three_pos_temp;
	// Create temporary variable for the 33% duty cycle negative edge
	reg thirty_three_neg_temp;
	// Create temporary variable for the logical or of the two clock 
	reg thirty_three_OR_temp;
	// Instantiate a 4 bit variable to store the temporary value during the positive count up process
	reg [3:0] temp_pos_count; 
	// Instantiate a 4 bit variable to store the temporary value during the negative count up process
	reg [3:0] temp_neg_count;

	// Assign the final output variable of 33% duty cycle positive edge
	assign thirty_three_duty_cycle_pos_edge = thirty_three_pos_temp;
	// Assign the final output variable of 33% duty cycle positive edge
	assign thirty_three_duty_cycle_neg_edge = thirty_three_neg_temp;
	// Assign the final output variable of the logical OR of the two clocks 
	assign thirty_three_duty_cycle_pos_OR_neg_edge = thirty_three_duty_cycle_pos_edge | thirty_three_duty_cycle_neg_edge;

	// Set all the temporary register variables to zero in the initial block 
	// Remember to use the non-blocking assignment operator 
	initial begin 
		// initalize the positive edge of the 33% duty cycle to zero 
		thirty_three_pos_temp <= 0;
		// initialize the negative edge of the 33% duty cycle to zero 
		thirty_three_neg_temp <= 0;
		// initialize the positive counter to zero 
		temp_pos_count <= 0;
		// initialize the negative counter to zero 
		temp_neg_count <= 0;
	end 

	// Modify the 4 bit counter to generate a 33% duty cycle clock that triggers on the rising edge
	always @ (posedge clk_in) begin
		if (rst) begin 	
			// reset the positive counter to 0
			temp_pos_count <= 0;
			// reset the temporary register for divide clock of 9 on positive edge 
			thirty_three_pos_temp <= 0;
		end 
		// Check if the current count is 5, get ready to flip the clock
		// Since 33% duty cycle is 1/3 and 15/3 = 5
		else if (temp_pos_count == 4'b0101) begin
			// Increment the positive counter by 1
			temp_pos_count <= temp_pos_count + 1'b1;
			// Flip the temporary register for the divide clock with 33% duty cycle
			thirty_three_pos_temp <= ~thirty_three_pos_temp;
		end 
		// Check if the current count is 8, get ready to flip the clock
		else if (temp_pos_count == 4'b1000) begin
			// Reset the positive counter by 1
			temp_pos_count <= 0;
			// Flip the temporary register for the divide clock of 9
			thirty_three_pos_temp <= ~thirty_three_pos_temp;
		end 
		else 
			// increment the positve counter by 1
			temp_pos_count <= temp_pos_count + 1'b1;
	end


	// Modify the 4 bit counter to generate a 33% duty cycle clock that triggers on the falling edge
	always @ (negedge clk_in) begin
		if (rst) begin 	
			// reset the positive counter to 0
			temp_neg_count <= 0;
			// reset the temporary register for divide clock of 9 on negative edge 
			thirty_three_neg_temp <= 0;
		end 
		// Check if the current count is 5, get ready to flip the clock
		// Since 33% duty cycle is 1/3 and 15/3 = 5
		else if (temp_neg_count == 4'b0101) begin
			// Increment the negative counter by 1
			temp_neg_count <= temp_neg_count + 1'b1;
			// Flip the temporary register for the divide clock with 33% duty cycle
			thirty_three_neg_temp <= ~thirty_three_neg_temp;
		end 
		// Check if the current count is 8, get ready to flip the clock
		else if (temp_neg_count == 4'b1000) begin
			// Reset the negative counter by 1
			temp_neg_count <= 0;
			// Flip the temporary register for the divide clock of 9
			thirty_three_neg_temp <= ~thirty_three_neg_temp;
		end 
		else 
			// increment the negative counter by 1
			temp_neg_count <= temp_neg_count + 1'b1;
	end

endmodule


// Design task 7: Generate a 50% duty cycle which is divide by 5 clock 
module clock_div_five (
	// Set up the input variables 
	input clk_in, 
	input rst, 
	// Set up the output variables 
	output clk_div_5
);
	
	// Create temporary variable for the 55% duty cycle positive edge
	reg clk_5_pos_temp;
	// Create temporary variable for the 55% duty cycle negative edge
	reg clk_5_neg_temp;
	// Instantiate a 4 bit variable to store the temporary value during the positive count up process
	reg [3:0] clk_5_pos_count; 
	// Instantiate a 4 bit variable to store the temporary value during the negative count up process
	reg [3:0] clk_5_neg_count;

	// Assign the final output variable for clock divide by 5 with logical or of the two clocks 
	assign clk_div_5 = clk_5_pos_temp | clk_5_neg_temp;
	
	// Set all the temporary register variables to zero in the initial block 
	// Remember to use the non-blocking assignment operator 
	initial begin 
		// Initialize the temporary output register for divide clock of 5 to 0 on positive edge
		clk_5_pos_temp <= 0;
		// Initialize the temporary output register for divide clock of 5 to 0 on negative edge 
		clk_5_neg_temp <= 0;
		// initialize the positive edge ccount to zero
		clk_5_pos_count <= 0;
		// initialize the negative edge ccount to zero
		clk_5_neg_count <= 0;
	end 

	// Modify the 4 bit counter to generate a 50% duty cycle clock that triggers on the rising edge
	always @ (posedge clk_in) begin
		if (rst) begin
			// reset the positive counter to 0
			clk_5_pos_count <= 0;
			// reset the temporary register for divide clock of 5 on positive edge to zero 
			clk_5_pos_temp <= 0;
		end 
		// Check if the current count is 2, get ready to flip the clock
		// Since 55% duty cycle is 2/5 of the clock divide of 5
		else if (clk_5_pos_count == 4'b0010) begin
			// increment the positive counter by 1
			clk_5_pos_count <= clk_5_pos_count + 1'b1;
			// Flip the temporary register for the divide clock with 50% duty cycle
			clk_5_pos_temp <= ~clk_5_pos_temp;
		end 
		// Check if the current count is 4, get ready to flip the clock
		else if (clk_5_pos_count == 4'b0100) begin
			// Reset the positive counter to 0
			clk_5_pos_count <= 0;
			// Flip the temporary register for the divide clock of 5 with rising on positive edge 
			clk_5_pos_temp <= ~clk_5_pos_temp;
		end
		else 
			// increment the positive counter by 1 
			clk_5_pos_count <= clk_5_pos_count + 1'b1;
	end

	// Modify the 4 bit counter to generate a 50% duty cycle clock that triggers on the falling edge
	always @ (negedge clk_in) begin
		if (rst) begin
			// reset the negative counter to 0
			clk_5_neg_count <= 0;
			// reset the temporary register for divide clock of 5 on negative edge 
			clk_5_neg_temp <= 0;
		end 
		// Check if the current count is 2, get ready to flip the clock
		// Since 55% duty cycle is 2/5 of the clock divide of 5
		else if (clk_5_neg_count == 4'b0010) begin
			// increment the neagtive counter by 1
			clk_5_neg_count <= clk_5_neg_count + 1'b1;
			// Flip the temporary register for the divide clock with 50% duty cycle
			clk_5_neg_temp <= ~clk_5_neg_temp;
		end 
		// Check if the current count is 4, get ready to flip the clock
		else if (clk_5_neg_count == 4'b0100) begin
			// Reset the negative counter to 0
			clk_5_neg_count <= 0;
			// Flip the temporary register for the divide clock of 5 with rising on falling edge 
			clk_5_neg_temp <= ~clk_5_neg_temp;
		end
		else 
			// increment the negative counter by 1 
			clk_5_neg_count <= clk_5_neg_count + 1'b1;
	end

endmodule

// Observe Task 8: Create a divide by 100 clock with only 1% duty cycle.
// Then, create a second always block that runs on the system clock and 
// switch the output clock every time the divide by 100 pulse is active with an if statement 
module clock_div_two_hundred (
	input clk_in,
	input rst,
	output clk_div_200
);

	// Instantiate a 7 bit variable to store the temporary value during the count up process
	// I need 7 bit variable for the count up process of the divide by 100 clock 
	reg [6:0] temp_count;
	// Create a temporary register variable to store the final output of divide clock of 100
	reg temp_clk_one_hundred;
	// Create a temporary register variable to store the final output of divide clock of 200
	reg temp_clk_two_hundred;
	// Assign the final output variable of clock div 200 to store the value from the temporary variable 
	assign clk_div_200 = temp_clk_two_hundred;	

	// Set all the temporary register variables to zero in the initial block 
	// Remember to use the non-blocking assignment operator 
	initial begin 
		// Initialize the temporary count variable to 0
		temp_count <= 0;
		// Initialize the temporary output register for divide clock of 100 to 0
		temp_clk_one_hundred <= 0;
		// Initialize the temporary output register for divide clock of 200 to 0
		temp_clk_two_hundred <= 0;
	end 

	// Create a divide by 100 clock with 1% duty cycle with an always block
	always @ (posedge clk_in) begin
		if (rst) begin
			// Reset the counter to zero 
			temp_count <= 0;
			// Reset the temporary register for divide clock of 100 to zero  
			temp_clk_one_hundred <= 0;
		end
		// Check if the current count is 98, get ready to flip the clock
		else if (temp_count == 7'b1100010) begin
			// Increment the counter by 1 
			temp_count <= temp_count + 1'b1;
			// Flip the temporary register for the divide clock of 100
			temp_clk_one_hundred <= ~temp_clk_one_hundred;
		end 
		// Check if the current count is 99, get ready to flip the clock
		else if (temp_count == 7'b1100011) begin
			// Reset the counter to 0
			temp_count <= 0;
			// Flip the temporary register for the divide clock of 100
			temp_clk_one_hundred <= ~temp_clk_one_hundred;
		end 
		else 
			// Increment the counter by 1 
			temp_count <= temp_count + 1'b1;
	end

	// Create a divide by 200 clock with an always block 
	always @ (posedge clk_in) begin 
		if (rst) begin
			// Reset the temporary register for divide clock of 200 to zero 
			temp_clk_two_hundred <= 0;
		end 
		// Check if divide by 100 pulse is active, then switch the output clock 
		else if (temp_clk_one_hundred) begin
			// if the divide by 100 pulse is active, flip the divide clock of 200
			temp_clk_two_hundred <= ~temp_clk_two_hundred;
		end
	end 

endmodule

// Design task 9: create a divide by 4 strobe 
// Generate a 8 bit counter that counts up by 2 on every positive edge of master clock
// Subtracts by 5 on every strobe 
module clock_strobe (
	input clk_in, 
	input rst, 
	output [31:0] toggle_counter
);

	// Create a temporary register for storing the final value of toggle counter 
	reg [31:0] temp_toggle_counter;
	// Assign the final output variable of toggle counter 
	assign toggle_counter = temp_toggle_counter;
	// Create a temporary output register for divide clock of 4
	reg clk_div_4;
	// Create a temporary counter for divide clock of 4
	reg [3:0] temp_count;

	// Set all the temporary register variables to zero in the initial block 
	// Remember to use the non-blocking assignment operator 
	initial begin 
		// Initialize the temporary counter to zero 
		temp_toggle_counter <= 0;
		// Initialize the temporary ouput register for divide clock of 4 to zero 
		clk_div_4 <= 0;
		// Initialize the temporary couner for divide clock of 4 to zero 
		temp_count <= 0;
	end 

	// Create a divide by 4 clock with an always block
	always @ (posedge clk_in) begin 
		if (rst) begin
			// Reset the counter to zero 
			temp_count <= 0;
			// Reset the temporary register for divide clock of 4 to zero  
			clk_div_4 <= 0;
		end 
		// Check if the current count is 2 or not, get ready to flip the counter
		else if (temp_count == 4'b0010) begin
			// Increment the counter by 1
			temp_count <= temp_count + 1'b1;
			// Flip the temporary register for the divide clock of 4
			clk_div_4 <= ~clk_div_4;
		end 
		// Check if the current count is 3 or not get ready to flip the counter 
		else if (temp_count == 4'b0011) begin
			// Reset the counter to zero
			temp_count <= 0;
			// Flip the temporary register for the divide clock of 4
			clk_div_4 <= ~clk_div_4;
		end 
		else 
			// increment the counter by 1
			temp_count <= temp_count + 1'b1;
	end 

	// Create the second always block that subtracts by 5 on every strobe
	// Normal case: just increment by two each time 
	// Special case: It means to check if the divide by 4 pulse is high, then subtract 5 from the temporary toggle counter
	always @ (posedge clk_in) begin
		if (rst) begin
			// reset the temporary toggle counter to zero
			temp_toggle_counter <= 0;
		end
		// Normal case: when it is not an active pulse for divide clock of 4
		else if (!clk_div_4) begin
			// increment the toggle counter by 2
			temp_toggle_counter <= temp_toggle_counter + 2;
		end 
		// Special case: when it is active pulse for divide clock of 4
		else 
			// decrement the toggle counter by 5 
			temp_toggle_counter <= temp_toggle_counter - 5;
	end 

endmodule








