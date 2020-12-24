`timescale 1ns / 1ps

/*
	CS M152A Lab 3: This lab is required to design an FSM to model a parking meter 
	which simulates coins being added and displays the appropriate time remaining
*/

module parking_meter (
	// First, Define the given inputs
	// Input 1: add 60 seconds to the parking meter 
    input add1,
    // Input 2: add 120 seconds to the parking meter 
    input add2,
	// Input 3: add 180 seconds to the parking meter 
    input add3,
    // Input 4: add 300 seconds to the parking meter 
    input add4,
    // Input 5: reset time to 16 seconds
    input rst1,
    // Input 6: reset time to 150 seconds
    input rst2,
    // Input 7: frequency of 100 Hz
    input clk,
    // Input 8: resets signal to the initial state 
    input rst,

    // The, Define the anodes driving each of these segments are (one bit signals)
	// a3 = most significant anode
	// a0 = the least significant anode
	// The order of anode goes from left to right  
	// This is the 1 bit anode a3
    output reg a3,
    // This is the 1 bit anode a2
    output reg a2,
    // This is the 1 bit anode a1
    output reg a1,
    // This is the 1 bit anode a0
    output reg a0,

    // Define the 7 bits output register for the seven segment display 
	// Define the seven segment vector (7 bit vector) in the output module to display the actual 
	// value fed to the 4 segments corresponding to the digits being displayed 
    output reg [6:0] led_seg,

    // Define the 4 output ports, each of them is a 4 bit vector
	// Each of the output port display the actual digit in BCD corresponding to each of the segment 
	// This is output port val3
    output reg [3:0] val3,
    // This is output port val2
    output reg [3:0] val2,
    // This is output port val1
    output reg [3:0] val1,
    // This is output port val0
    output reg [3:0] val0
    );
	
	// Create two registers that store the current state and the update state
	// This is a 2 bits register that store the current state of the FSM 
	 reg [1:0] current_state;
	// This is a 2 bit register that store the update state of the FSM
	 reg [1:0] update_state;
	 
	// Create a 14 bits register to hold the total number of seconds in the parking meter 
	// The maximum value of time will be 9999, it will require 14 bits to hold values from 0 to 9999 in decimal
	 reg [13:0] parking_meter_seconds;

	// Create two registers for the calculation of the period of 2 seconds and 50% duty cycle
	// The is the clock period of two register 
	 reg clock_period_two_proceed;
	 // Use for signaling the moment to flip the clock period of 2
	 reg clock_period_two_flip;
	 // Create a 7 bits counter that store the value when incrementing in the always block 
	 reg [6:0] hundred_counter;

	// Create paramaters to help make the code more readable
	// Set up a parameter to store the initial state period 
	 parameter inital_state_period = 3'b000; 
	// Set up a parameter to store the period 1 second when the parking meter's seocnds are greater than (>) 180 seconds
	 parameter one_second_state_period = 3'b001; 
	// Set up a parameter to store the period 2 seconds when the parking meter's seconds are between 0 and 180 seconds (0 second < parking meter remaining seconds <= 180 seconds)
	 parameter two_second_state_period = 3'b010; 
	 

	// Then, I need to set up four individual wires for each of our anodes 
	// This is the flash wire for anode a3
	 wire flash_a3;
	// This is the flash wire for anode a2
	 wire flash_a2;
	// This is the flash wire for anode a1
	 wire flash_a1;
	// This is the flash wire for anode a0
	 wire flash_a0;

	// Set up the needed wires for the seven segment vector 
	// First, I need a 7 bit vector wire for our output module 
	 wire [6:0] output_led_seg;

	// Then, I need to initialize the output module that consist of a seven segment vector
	// to displays the actual value fed to the 4 segments 
	seven_segment_vec_display my_nfssd(.val3(val3), .val2(val2), .val1(val1), .val0(val0),
			.clk(clk), .rst(rst), .a3(flash_a3), .a2(flash_a2), .a1(flash_a1), .a0(flash_a0), .led_seg(output_led_seg));
	 
	// I need a initialize block to intialize my needed registers and variables 
	initial begin
	 	// First, I need to initalize my current state and the following states
		// Initailize my current state to inital state period 
		current_state <= inital_state_period;
		// Initialize my update state to inital state period 
		update_state <= inital_state_period;

		// Second, initialize the four output ports with 4 bits of zeroes
		// Initialize val3 output port to 0
		val3 <= 4'b0000;
		// Initialize val2 output port to 0
		val2 <= 4'b0000;
		// Initialize val1 output port to 0
		val1 <= 4'b0000;
		// Initialize val0 output port to 0
		val0 <= 4'b0000;
		
		// Then, I need to initizlie my two registers for the calculation of the period of 2 seconds and 50% duty cycle
		// Both of my clock registers are 1 bit 
		// Initialize my clock period of two to zero 
		clock_period_two_proceed <= 1'b0;
		// Initialize my clock_period_two_flip register to 1
		clock_period_two_flip <= 1'b1;

		// Initalize my 7 bits hundred counter to 0 
		hundred_counter <= 7'b0000000;
		// Initialize my parking meter that store the remaining second to 0
		parking_meter_seconds <= 14'b00000000000000;
		
	end
	
	// Then, I need to create a always block for updating the states 
	always @(posedge clk) begin
	 	// If the reset signal is high, get ready to reset to initial state 
		if (rst)
			// Then, reset the current state to the period of the inital state  
			current_state <= inital_state_period;
		else
			// If the reset signal is low, update the current state to the next state
			current_state <= update_state;
	end
	 
	// I need to create a always block for updating the counter that count up to 100
	always @(posedge clk) begin
	 	// If the rest signal is high 
		if (rst) 
			begin 
				// Reset the clock_period_two_flip register to 1
				clock_period_two_flip <= 1'b1; 
				// Reset the hundred counter to 7 bits zeroes 
				hundred_counter <= 7'b0000000; 
			end
		else 

			// If the reset signl is low and the counter is greater than and equal to 99 right now 
			if (hundred_counter >= 7'b1100011) 
				begin
					// Reset the hundred counter to 0
					hundred_counter <= 7'b0000000;

					// Check if the clock period two is high or low 
					if (!clock_period_two_proceed)
						// If the clock period two is low, then set the clock_period_two_flip back to 1
						clock_period_two_flip <= 1'b1;
					else
					// If the clock period two is high, then flip the clock period 
						clock_period_two_flip <= ~clock_period_two_flip;

				end	
			else 
				// If the reset signl is low and the counter is less than 99 right now 
				// Increment the hundred counter by 1
				hundred_counter <= hundred_counter + 7'b0000001;	
	 end
	 
	// Create a always block to update the remaining seconds of the parking meter on a negative edge 
	 always @(negedge clk) begin
	 	// Check if the reset signal is high or low 
		if (rst)
			// If the rest signal is high, then reset the remaining seconds of the parking meter to 0
			parking_meter_seconds <= 14'b00000000000000;
		// Check if the hundred counter is 0, then get ready to read the inputs corresponding added seconds represented by each button
		// For every second, input are processed once only and during the one second, ignore the multiple inputs being pressed together
		else if (hundred_counter == 7'b0000000) 
			begin
				/*
					There are 9 cases:
					1. When input add1 is pressed, add 60 seconds
					2. When input add2 is pressed, add 120 seconds 
					3. When input add3 is pressed, add 180 seconds
					4. When input add4 is pressed, add 300 seconds 
					5. When input rst1 is pressed, reset to 16 seconds
					6. When input rst2 is pressed, reset to 150 seconds
					7. When current state is initial period, reset the remaining seconds to 0 second
					8. When current state is  period 1 second, decrement the stored seconds by 1
					9. When current state is  period 2 seconds, decrement the stored seconds by 1
				*/

				if (add1)
					// Input add1 is pressed, add 60 seconds to the parking meter
					parking_meter_seconds <= parking_meter_seconds + 14'b00000000111100; 
				else if (add2)
					// Input add2 is pressed, add 120 seconds to the parking meter 
					parking_meter_seconds <= parking_meter_seconds + 14'b00000001111000; 
				else if (add3)
					// Input add3 is pressed, add 180 seconds to the parking meter
					parking_meter_seconds <= parking_meter_seconds + 14'b00000010110100; 
				else if (add4)
					// Input add4 is pressed, add 300 seconds to the parking meter 
					parking_meter_seconds <= parking_meter_seconds + 14'b00000100101100; 
				else if (rst1)
					// Input rst1 is pressed, reset the parking meter to hold 16 seconds
					parking_meter_seconds <= 14'b00000000010000; 
				else if (rst2)
					// Input rst2 is pressed, reset the parking meter to hold 150 seconds
					parking_meter_seconds <= 14'b00000010010110; 
				else if (current_state == inital_state_period)
					// If the current state is inital state, then reset the parking meter to hold 0 second
					parking_meter_seconds <= 14'b00000000000000;	
					
				else if (current_state == one_second_state_period)
					// If the current state is one second period, then decrement the remaining seconds by 1
					parking_meter_seconds <= parking_meter_seconds - 14'b00000000000001;
					
				else if (current_state == two_second_state_period)
					// If the current state is two second period, then decrement the remaining seconds by 1
					parking_meter_seconds <= parking_meter_seconds - 14'b00000000000001;
			end

		// After adjusting the remaining seconds in the parking meter
		// Check whether there is attempt to increment beyond 9999
		// If yes, then counter should latch to 9999 and counting down from there
		// Check if the counter is > 9999, then set the counter to 9999 which is the maximum value of the remaining seocnds in the meter 
		if (parking_meter_seconds > 14'b10011100001111) 
			// set the counter to 9999 as the maximum seconds from the parking meter
			parking_meter_seconds <= 14'b10011100001111; 
		
	 end
	 	 
	// I need a always block to update the following state after current state
	 always @(*) begin
	 	// Check if the reset signal is high or low
		if (rst)
			begin
				// If the reset signal is 1, reset the update state to inital state 
				update_state = inital_state_period; 
				// If the reset signal is 1, reset the clock period of two to 0 
				clock_period_two_proceed = 1'b0; 
			end
		// Check if the remaining seconds in the parking meter are greater than 180 seconds
		else if (parking_meter_seconds > 14'b00000010110100) 
			begin 
				// Set the update state to the one second clock state
				update_state = one_second_state_period; 
				// Set the clock period of two to 0
				clock_period_two_proceed = 1'b0; 
			end
		// Check if the remaining seconds in the parking meter equal to 0 
		else if (parking_meter_seconds == 14'b00000000000000) 
			begin 
				// If the remaining seconds are 0, then set the next state to inital state period 
				update_state = inital_state_period; 
				// If the remaining seconds are 0, then set the clock period of two to 0
				clock_period_two_proceed = 1'b0; 
			end
		// Check if the remaining seconds are between 0 and 180 (0 second < remaining seconds in the parking meter <= 180 seconds)
		else 
			begin
				// Set the next state to the two second clock 
				update_state = two_second_state_period; 
				// Check if the clock period of two is 0 or not 
				if (clock_period_two_proceed == 1'b0) 
					// Set the clock period of two to 1
					clock_period_two_proceed = 1'b1;
			end
		
	 end

	 // I need a always block to extract the corresponding values for the output ports 
	 always @(posedge clk) begin
	  	// Set val3 output port to be the thousands place
		 val3 <= parking_meter_seconds / 1000; 
		// Set val2 output port to be the hundred place
		 val2 <= (parking_meter_seconds % 1000) / 100; 
		// Set val1 output port to be the tens place 
		 val1 <= (parking_meter_seconds % 100) / 10; 
		// Set val0 output port to be the ones place
		 val0 <= parking_meter_seconds % 10; 
		 
		 // Assign the corresponding wires for the anodes 
		 // Assign the anode a3 with the flash wire a3
		 a3 <= flash_a3;
		 // assign the anode a2 with the flash wire a2 
		 a2 <= flash_a2;
		 // assign the anode a1 with the flash wire a1
		 a1 <= flash_a1;
		 // Assign the anode a0 with the flash wire a0
		 a0 <= flash_a0;

		 // Check whether the current state is equal to one seocnd period or initial state or rst signal is on  
		if (rst || current_state == inital_state_period || current_state == one_second_state_period)
			begin
			 	// If the counter is greater than 50  
				if (hundred_counter >= 7'b0110010) 
					// Set the led segment to zero 
					led_seg <= 7'b0000000;
				else
				// If the counter is less than 50
					// If yes, then set the led segment with the value of output led segment 
					led_seg <= output_led_seg; 
			end
		// Check whether the current state is equal to two second clock period or the remaining seconds are 180 seocnds
		else if (parking_meter_seconds == 14'b00000010110100 || current_state == two_second_state_period) 
			begin
				// Check the flip signal for two seconds clock period is on or not 
				if (!clock_period_two_flip)
					// If it is off, set the led segment to zero 
					led_seg <= 7'b0000000;
				else 
					// If it is on, the signal will be high for the 1st seoncd, then low for the 2nd second 
					led_seg <= output_led_seg;
			end	
	 end
endmodule

// This the module of the display of the seven segement vector 
module seven_segment_vec_display (
	// These are the four output ports
	// This is my 4 bits output port val3
	input [3:0] val3,
	// This is my 4 bits output port val2
	input [3:0] val2,
	// This is my 4 bits output port val1
	input [3:0] val1,
	// This is my 4 bits output port val0
	input [3:0] val0,
	// This is the input clk and use to reboot the display 
	input clk, 
	// This is my reset signal
	input rst,
	// These are the four anodes 
	// This is my anode a3
	output reg a3,
	// This is my anode a2
	output reg a2,
	// This is my anode a1
	output reg a1,
	// This is my anode a0
	output reg a0,
	// This is the output led display 
	output reg [6:0] led_seg
);
	
	// I need to set up 4 states to indicate which led I am currently displaying the value 
	// This is the inital state 
	parameter zero_screen_state = 3'b000;
	// This is my first state 
	parameter first_screen_state = 3'b001;
	// This is my second state 
	parameter second_screen_state = 3'b010;
	// This is my third state 
	parameter third_screen_state = 3'b011;
	// This is my fourth state 
	parameter fourth_screen_state = 3'b100;

	// Set up two registers to store states 
	// This is my current state 
	reg [2:0] current_state;
	// This is my next following state 
	reg [2:0] update_state;
	

	// I need a initial block to initialize my output registers and states 
	initial begin
		// Initialize my led segment to zero 
		led_seg <= 7'b0000000; 
		// Set all my anodes to high at first 
		// Set anode a3 to high 
		a3 <= 1; 
		// Set anode a2 to high 
		a2 <= 1; 
		// Set anode a1 to high 
		a1 <= 1; 
		// Set anode a0 to high 
		a0 <= 1; 
		// Initialize my current state to zero state which is initial
		current_state <= zero_screen_state;
		// Initialize my update state to zero state which is initial 
		update_state <= zero_screen_state;
	end

	// Create a encode function that transfer from 4 bit binary number to the 7 segment vector 
	function [6:0] seven_segment_vec_encode;
		// This is my input to the encode function 
		input [3:0] encode_input;

		if (encode_input == 4'b0000)
			// This is encode 0 for binary input 0
			seven_segment_vec_encode = 7'b1111110; 
		else if (encode_input == 4'b0001)
			// This is encode 1 for binary input 1
			seven_segment_vec_encode = 7'b0110000;
		else if (encode_input == 4'b0010)
			// This is encode 2 for binary input 2
			seven_segment_vec_encode = 7'b1101101; 
		else if (encode_input == 4'b0011)
			// This is encode 3 for binary input 3
			seven_segment_vec_encode = 7'b1111001;
		else if (encode_input == 4'b0100)
			// This is encode 4 for binary input 4 
			seven_segment_vec_encode = 7'b0110011;
		else if (encode_input == 4'b0101)
			// This is encode 5 for binary input 5
			seven_segment_vec_encode = 7'b1011011;
		else if (encode_input == 4'b0110)
			// This is encode 6 for binary input 6
			seven_segment_vec_encode = 7'b1011111;
		else if (encode_input == 4'b0111)
			// This is encode 7 for binary input 7
			seven_segment_vec_encode = 7'b1110000;
		else if (encode_input == 4'b0111)
			// This is encode 8 for binary input 8
			seven_segment_vec_encode = 7'b1110000;
		else if (encode_input == 4'b1001)
			// This is encode 9 for binary input 9
			seven_segment_vec_encode = 7'b1111011;
		else 
			// This is the default case for the encode output
			seven_segment_vec_encode = 7'b0000000; 

	endfunction
	
	// I need a always block to check my current state value 
	always @(posedge clk) begin
	// If my current state value is equal to my fourth screen state value 
		if (current_state == fourth_screen_state)
			// Set my update state to my first screen state value 
			update_state <= first_screen_state;
		else 
			// If my current state value is not equal to my fourth screen state value,
			// then update my next state by adding one to my current state 
			update_state <= current_state + 2'b01;
	end
	
	// I need a always block to reset and update my current state value 
	always @(posedge clk) begin
		// If reset signal is high 
		if (rst)
			// Reset my current state back to inital state 
			current_state <= zero_screen_state; 
		else 
			// If not, set my current state to the next state 
			current_state <= update_state;
	end
	
	// I need a always block to show the status of the anodes 
	always @(posedge clk) begin
		// Check which anodes are on with the current states 
		// If my current state is equal to the value of first screen state 
		if (current_state == first_screen_state)
			// This is the case when a3 = low, a2 = a1 = a0 = high
			begin 
				// Set anode a3 to low
				a3 <= 1'b0; 
				// Set anode a2 to high 
				a2 <= 1'b1; 
				// Set anode a1 to high 
				a1 <= 1'b1; 
				// Set anode a0 to high 
				a0 <= 1'b1; 
			end 
		// If my current state is equal to the value of the second screen state 
		else if (current_state == second_screen_state)
			begin 
			// This is the case when a2 = low, a3 = a1 = a0 = high
				// Set anode a3 to high 
				a3 <= 1'b1; 
				// Set anode a2 to low 
				a2 <= 1'b0; 
				// Set anode a1 to high 
				a1 <= 1'b1; 
				// Set anode a0 to high 
				a0 <= 1'b1; 
			end
		// If my current state is equal to the value of the third screen state 
		else if (current_state == third_screen_state)
			begin 
			// This is the case when a1 = low, a3 = a2 = a0 = high
				// Set anode a3 to high 
				a3 <= 1'b1;
				// Set anode a2 to high 
				a2 <= 1'b1; 
				// Set anode a1 to low 
				a1 <= 1'b0; 
				// Set anode a0 to high 
				a0 <= 1'b1; 
			end
		// If my current state is equal to the value of the fourth screen state 
		else if (current_state == fourth_screen_state)
			begin 
			// This is the case when a0 = low, a3 = a2 = a1 = high
				// Set anode a3 to high 
				a3 <= 1'b1; 
				// Set anode a2 to high 
				a2 <= 1'b1; 
				// Set anode a1 to high 
				a1 <= 1'b1; 
				// Set anode a0 to low 
				a0 <= 1'b0; 
			end
		// If my current state is equal to the value of the initial screen state 
		else if (current_state == zero_screen_state)
			begin 
			// This is the inital case, as well as default case
				// Set anode a3 to high  
				a3 <= 1'b1; 
				// Set anode a2 to high 
				a2 <= 1'b1; 
				// Set anode a1 to high 
				a1 <= 1'b1; 
				// Set anode a0 to high 
				a0 <= 1'b1; 
			end 
		
		// Check which output port we are suppose to display with the current state value 
		// If my current state is equal to first screen state
		if (current_state == first_screen_state)
			// Displaying output port val3
			led_seg <= seven_segment_vec_encode(val3);
		// If my current state is equal to second screen state 
		else if (current_state == second_screen_state)
			// Displaying output port val2
			led_seg <= seven_segment_vec_encode(val2);
		// If my current state is equal to third screen state
		else if (current_state == third_screen_state)
			// Displaying output port val1
			led_seg <= seven_segment_vec_encode(val1);
		// If my current state is equal to fourth screen state 
		else if (current_state == fourth_screen_state)
			// Displaying output port val0
			led_seg <= seven_segment_vec_encode(val0);
		// if my current state is equal to initial screen state 
		else if (current_state == zero_screen_state)
			// Set led_segment to zero, displaying 0, inital and default 
			led_seg <= 'b0000000;
	end
endmodule