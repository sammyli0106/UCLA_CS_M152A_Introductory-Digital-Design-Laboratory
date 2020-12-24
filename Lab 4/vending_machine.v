`timescale 1ns / 1ps

/*
	CS M152A Lab 4: Use Verilog code to design a FSM to simulate the behavior of a vending machine
	specified according to requirements and actions from the lab instructions 
*/

// First I need to create a separate module for counting of the 5 clock cycles
// Th counting of the 5 clock cycles will be used as checking in Transact, Vend and Get Code Stage 

// Check five clock cycles modules 
module check_five_clock_cycles(
	// This is my signal to go to next clock cycle during the counting process
	input proceed_signal,
	// This is my reset signal to clean up and get ready to repeat the counting process again 
	input rst_signal,
	// This is my input clock signal 
	input CLK,
	// This is my signal to stay at where it is during the counting process
	output reg stop_signal
);

// Create a 3 bits counter for counting from 0 (000) to 5 (101) 
reg [2:0] check_five_clock_cycles;

// I need to create a initalize block to initialize all the needed registers and variables
initial begin
	// Initialize the stop signal with 1 bit of zero 
	stop_signal <= 1'b0;  
	// Initialize the count with 3 bits of zeros
	check_five_clock_cycles <= 3'b000;
end

// Create a always block to start counting the clock cycles 
always @(posedge CLK) 
	begin
		// Check if my reset signal is high or low 
		if (rst_signal) 
			begin
				// Reset my stop signal back to 1 bit of zero 
				stop_signal <= 1'b0; 
				// Reset my count five back to 3 bits of zero 
				check_five_clock_cycles <= 3'b000; 
			end
		// Check if my proceed signal is high or low
		else if (proceed_signal) 
			begin 
				// If the proceed signal is high, then increment my counter for counting 5 clock cycles
				check_five_clock_cycles <= check_five_clock_cycles + 3'b001;
				// Check if my current count is already 4 
				if (check_five_clock_cycles == 3'b100) 
					begin
						// If my count is 4 now, it is already 5 clock cycle index from 0 to 4
						// Set stop signal to high to indicate
						stop_signal <= 1'b1; 
						// Reset my counter back to 3 bits of zeros
						check_five_clock_cycles <= 3'b000;
					end
			end	
	end

endmodule

// This is my module for the vending machine 
// First, define the give inputs and outputs according to the high level schematics
module vending_machine(
	// define the given inputs and outputs of the vending machine 
    input CARD_IN,
	input VALID_TRAN,
	input [3:0] ITEM_CODE,
	input KEY_PRESS,
	input DOOR_OPEN,
	input RELOAD,
	input CLK,
	input RESET,
	output reg VEND,
	output reg INVALID_SEL,
	output reg FAILED_TRAN,
	output reg [2:0] COST
);
	
	// 1. Registers relate to the module that check 5 clock cycle 
	// This is my reset signal to clean up and get ready to repeat the counting process again 
	reg five_cycle_counter_rst_signal;
	// This is my signal to go to next clock cycle during the counting process
	reg five_cycle_counter_proceed_signal;
	// This is my signal to stay at where it is during the counting process
	wire five_cycle_counter_stop_signal;

	// I need to instantiate my check five clock cycles module with the established inputs
	check_five_clock_cycles check_five_clock_cycles_count(.proceed_signal(five_cycle_counter_proceed_signal), .rst_signal(five_cycle_counter_rst_signal), .CLK(CLK), .stop_signal(five_cycle_counter_stop_signal));

	// 2. Registers relate to the items from the vending machine
	// Create two registers to store the first and second digit item code 
	// The digit goes from 0 to 9, so we need 4 bits to store values 0 - 9
	// This is the register to store first digit item code
	reg [3:0] first_digit_item_code; 
	// This is the register to store second digit item code
	reg [3:0] second_digit_item_code; 
	// I need a 5 bits of wire to store my slot index of the machine since the it starts from 0 to 19
	// it requires 5 bits to store up to the value of 19 
	wire [4:0] slot_num;
	// Equation: first item digit item code * 10 + second item digit item code
	assign slot_num = first_digit_item_code * 5'b01010 + second_digit_item_code; 

	// I need two arrays
	// The first array will store the corrpesonding costs for every single item
	// The array will have 20 slots and each of the slot is a 3 bits number to represents the costs from 1 to 6
	reg [2:0] costs_of_item [0:19]; 
	// The second array will store the remaining units for every single item 
	// The array will have 20 slots and each of the slot is a 4 bits number to store a max of 10 units of snacks
	reg [3:0] units_of_item [0:19];

	// 3. Registers and parameters relate to state transitions
	// I need two registers to store my current state and my update state 
	// Each of them is 4 bits which allows me could have up to 15 states, but I only need 12 states for my module
	// This is the register that store my current state 
	reg [3:0] current_state;
	// This is the register that store my update state 
	reg [3:0] update_state;
	
	// I need to create a encoding from all my states to a binary number 
	// This means I am gonna assign a binary number to each of my state 
	// The idle state represents binary 0
	parameter state_of_idle = 4'b0000;
	// The reset state represents binary 1
	parameter state_of_reset = 4'b0001;
	// The reload state represents binary 2 
	parameter state_of_reload = 4'b0010;
	// The reading of first digit item code represents 3
	parameter state_of_first_digit_item_code = 4'b0011;
	// The reading of second digit item code represents 4
	parameter state_of_second_digit_item_code = 4'b0100;
	// The valid transaction after item code reading represents 5
	parameter state_of_valid_transaction = 4'b0101;
	// The invalid transaction after item code reading represents 6
	parameter state_of_invalid_transaction = 4'b0110;
	// The valid vending state represents 7 
	parameter state_of_valid_vending = 4'b0111;
	// The final success state for the entire transaction represents 8
	parameter state_of_final_success_transaction = 4'b1000;
	// The door open signal during the vending state represents 9 
	parameter state_of_pick_up_item = 4'b1001;
	// The final failed state for the entire transaction represents 10
	parameter state_of_final_failed_transaction = 4'b1010;

	// I need to create a initalize block to first initialize the needed inputs and registers 
	initial begin
		// initialize the two registes for counting 5 clock cycles 
		// Initialize the 5 clock cycles reset signal to be 1 bit of 0 
	    five_cycle_counter_rst_signal <= 1'b0;
	    // Initailize the 5 clock cycles proceed signal to be 1 bit of 0
	    five_cycle_counter_proceed_signal <= 1'b0;

	    // Initalize the two registers for storing the first and second digit item code 
		// Initialize first digit item code to 4 bits of zero 
	    first_digit_item_code <= 4'b0000;
	    // Initalize second digit item code to 4 bits of zero 
		second_digit_item_code <= 4'b0000;

		// We need to initialize all of my output registers to 0
		// Initialize output vend to 0
		VEND <= 1'b0;
		// Initialize invalid sel to 0
		INVALID_SEL <= 1'b0;
		// Initialize failed tran to 0
		FAILED_TRAN <= 1'b0;
		// Initialize cost to 0
		COST <= 3'b000;

		// Initialize two registers that store the status of the states 
		// Initialize my current state to the initial state which is 0  
		current_state <= 4'b0000;
		// Initialize my update state to the initial state which is 0
		update_state <= 4'b0000;

		// We need to fill in initial value for the array that store the cost of each corresponding item 
		/*
			There are 6 different costs:

			1. Cost 001 -> item code: 00, 01, 02, 03
			2. Cost 010 -> item code: 04, 05, 06, 07 
			3. Cost 011 -> item code: 08, 09, 10, 11
			4. Cost 100 -> item code: 12, 13, 14, 15
			5. Cost 101 -> item code: 16, 17
			6. Cost 110 -> item code: 18, 19
		*/
		
		// From slot 0 to 3, cost is 1 which is 001 in BCD form 
		costs_of_item[0] <= 3'b001; 	
		costs_of_item[1] <= 3'b001; 
		costs_of_item[2] <= 3'b001; 	
		costs_of_item[3] <= 3'b001; 
		// From slot 4 to 7, cost is 2 which is 010 in BCD form 	
		costs_of_item[4] <= 3'b010;	
		costs_of_item[5] <= 3'b010;	
		costs_of_item[6] <= 3'b010;	
		costs_of_item[7] <= 3'b010; 
		// From slot 8 to 11, cost is 3 which is 011 in BCD form 	
		costs_of_item[8] <= 3'b011;	
		costs_of_item[9] <= 3'b011;	
		costs_of_item[10] <= 3'b011;	
		costs_of_item[11] <= 3'b011; 
		// From slot 12 to 15, cost is 4 which is 100 in BCD form 
		costs_of_item[12] <= 3'b100;	
		costs_of_item[13] <= 3'b100;	
		costs_of_item[14] <= 3'b100;	
		costs_of_item[15] <= 3'b100;
		// From slot 16 to 17, cost is 5 which is 101 in BCD form
		costs_of_item[16] <= 3'b101;	
		costs_of_item[17] <= 3'b101; 
		// From slot 18 to 19, cost is 6 which is 110 in BCD form 
		costs_of_item[18] <= 3'b110;	
		costs_of_item[19] <= 3'b110; 

		// We need to fill in the initial value for the array that store the number of remaining snacks for each of the corresponding item 
		// Each slots in the units of item array start with 10 units of snack 
		// Set my slot 00 to contain 10 units of snacks 
		units_of_item[0] <= 4'b1010; 
		// Set my slot 01 to contain 10 units of snacks 	
		units_of_item[1] <= 4'b1010; 	
		// Set my slot 02 to contain 10 units of snacks 
		units_of_item[2] <= 4'b1010; 	
		// Set my slot 03 to contain 10 units of snacks 
		units_of_item[3] <= 4'b1010;
		// Set my slot 04 to contain 10 units of snacks 
		units_of_item[4] <= 4'b1010; 	
		// Set my slot 05 to contain 10 units of snacks 
		units_of_item[5] <= 4'b1010; 	
		// Set my slot 06 to contain 10 units of snacks 
		units_of_item[6] <= 4'b1010; 	
		// Set my slot 07 to contain 10 units of snacks 
		units_of_item[7] <= 4'b1010;
		// Set my slot 08 to contain 10 units of snacks 
		units_of_item[8] <= 4'b1010; 	
		// Set my slot 09 to contain 10 units of snacks 
		units_of_item[9] <= 4'b1010; 	
		// Set my slot 10 to contain 10 units of snacks 
		units_of_item[10] <= 4'b1010; 	
		// Set my slot 11 to contain 10 units of snacks 
		units_of_item[11] <= 4'b1010;
		// Set my slot 12 to contain 10 units of snacks 
		units_of_item[12] <= 4'b1010; 	
		// Set my slot 13 to contain 10 units of snacks 
		units_of_item[13] <= 4'b1010; 	
		// Set my slot 14 to contain 10 units of snacks 
		units_of_item[14] <= 4'b1010; 	
		// Set my slot 15 to contain 10 units of snacks 
		units_of_item[15] <= 4'b1010;
		// Set my slot 16 to contain 10 units of snacks 
		units_of_item[16] <= 4'b1010; 	
		// Set my slot 17 to contain 10 units of snacks 
		units_of_item[17] <= 4'b1010; 	
		// Set my slot 18 to contain 10 units of snacks 
		units_of_item[18] <= 4'b1010; 	
		// Set my slot 19 to contain 10 units of snacks 
		units_of_item[19] <= 4'b1010;
		
	end
	
	// I need a always block to reset my current state register 
	// Also to make an update to my update state register 
	always @(posedge CLK) 
		begin 
			// Check if the reset signal is high 
			if (RESET)
				// If my reset state is high, then I will reset my current state to my state of reset 
				current_state <= state_of_reset;
			else
				// If my current state is low, then I will reset my current state to my update state register 
				current_state <= update_state;     
		end
	
	// I need a always block to decide what is my next state transition based on the current state and given signals 
	always @(*) begin 
		/*
			There are a total of of 11 states/actions in this FSM
			1. Idle -> the machine waits for a new transcation to begin 
			2. Reset -> all item counters and outputs are set to 0
			3. Reload -> all snacks are set to 10 units
			4. Read first digit code -> when card is inserted and wait for valid selection
			5. Read second digit code -> when cars is inserted and wait for valid selection
			6. Valid transaction under transaction stage -> when valid signal goes high within 5 clock cycles
			7. Invalid transaction under transaction stage -> when invalid signal does not go high within 5 clock cycles
			8. Valid Vending -> decrement the counter of the corresponding item by 1
			9. Final Valid Transaction -> the entire transaction is successful
			10. Final Invalid Transaction -> the entire transaction is failed
			11. Door open -> wait for the door open signal to open then close 
		*/
		// Check if my current state is idle
		if (current_state == state_of_idle)
			begin
				// There are two states we need to check 
				// First, Check if the reload state is high 
				// We can only reload during idle, this is the place to check  
				if (RELOAD)
					begin
						// If reload is high, then set my update to go to the reload state for the corresponding actions
						update_state <= state_of_reload;
					end
				// Second, Check if the card in signal is high 
				else if (CARD_IN)
					begin
						// Then, we can move on to read the first digit item code from the users
						// Set the update state to the first digit item code state 
						update_state <= state_of_first_digit_item_code;
					end

				// First, set my 5 clock cycles reset signal to 1 
				five_cycle_counter_rst_signal <= 1;
				// Then, I need to reset my two registers that store the first and second digit item code
				// Set the first digit item code register to 0 to prepare to read
				first_digit_item_code <= 4'b0000;
				// Set the second digit item code register to 0 to prepare to read 
				second_digit_item_code <= 4'b0000;

			end
		// Check if my current state is reset state 
		else if (current_state == state_of_reset) 
			begin
				// There is one state I need to check 
				// Check if the reset state is being set to 0, then machine goes to idle state
				if (RESET == 1'b0) 
					begin
						// If the reset signal is equal to 0 
						// Set my update state to go to idle 
						update_state <= state_of_idle;
					end 

				// First set my 5 clock cycles reset signal to 1
				// Since this is a reset state
				five_cycle_counter_rst_signal <= 1'b1;
				// Then set my 5 clock cycles proceed signal to 0
				// Since reset does not require the usage of counting 5 clock cycles
				five_cycle_counter_proceed_signal <= 1'b0;

				// Then I need to reset my first and second digit item code to 0 
				// Reset my first digit item code to 0
				first_digit_item_code <= 4'b0000;
				// Reset my second digit item code to 0
				second_digit_item_code <= 4'b0000;

			end
		// Check if my current state is reload state 
		else if (current_state == state_of_reload) 
		begin
			// I just need to check if my reload signal is on or not 
			if (RELOAD == 1'b0)
				begin 
					// If my reload signal is off, then I need to move to idle
					// Set my update state to be idle 
					update_state <= state_of_idle;
				end 
		end
		// Check if my current state is waiting to read the first digit item code 
		else if (current_state == state_of_first_digit_item_code) 
		begin
			// Check if my stop signal is on or not for the counting of 5 clock cycles
			// This means I already waited 5 clock cycles 
			if (five_cycle_counter_stop_signal) 
			begin
					// This is means it falls under the failed transaction during the reading of digit code
					update_state <= state_of_invalid_transaction;
					// If I already count up to 5 clock cycles, then I will stop counting 
					// Set the 5 clock cycles proceed signal to 0 
					five_cycle_counter_proceed_signal <= 1'b0;
					// Then, I would need to reset the 5 clock cycles to ready for next count 
					// Set the 5 clock cycles reset signal to 1
					five_cycle_counter_rst_signal <= 1'b1;
			end
			// Check if the key press signal is on or not 
			else if (KEY_PRESS) 
			begin
					// This is a valid first digit item code 
					first_digit_item_code <= ITEM_CODE;
					// Reset the counting of the 5 clock cycle to get ready for reading the second digit item code
					five_cycle_counter_rst_signal <= 1'b1;
					// Set the update state to go to state ready to read the second digit item code
					update_state <= state_of_second_digit_item_code;
			end
			else 
			begin
				// I dont need to reset the my count for 5 clock cycles yet, so the reset signal should be set to 0 for now
				five_cycle_counter_rst_signal <= 1'b0;
				// This is the normal case, I am currently waiting to read the first digit item code within 5 clock cycles
			    // I will keep increment the counting of clock cycles until it gets 5 
				five_cycle_counter_proceed_signal <= 1'b1;
			end

		end
		// Check if the current state is to read the second digit item code 
		else if (current_state == state_of_second_digit_item_code) 
		begin
		// Check if the 5 clock cycles stop signal is on or not 
		if (five_cycle_counter_stop_signal) 
		begin
			// This is means it falls under the failed transaction during the reading of second digit item code
			update_state <= state_of_invalid_transaction;
			// If I already count up to 5 clock cycles, then I will stop counting 
			// my proceed to keep counting signal will be set to 0
			five_cycle_counter_proceed_signal <= 1'b0;
			// This is means it falls under the failed transaction during the reading of second digit item code
			five_cycle_counter_rst_signal <= 1'b1;
		end
		// Check if the key press is high or low
		else if (KEY_PRESS) 
		begin
			// This is a valid second digit item code
			second_digit_item_code <= ITEM_CODE;
			// Reset the counting of the 5 clock cycle to get ready for reading the second digit item code
			five_cycle_counter_rst_signal <= 1'b1;
			// Set my update state to be valid transaction 
			update_state <= state_of_valid_transaction;
		end
		else 
		begin
			// I dont need to reset the my count for 5 clock cycles yet, so the reset signal should be set to 0 for now
			five_cycle_counter_rst_signal <= 1'b0;
			// This is the normal case, I am currently waiting to read the first digit item code within 5 clock cycles
			// I will keep increment the counting of clock cycles until it gets 5 
			five_cycle_counter_proceed_signal <= 1'b1; 
		end

		end

		// Check if th current state is the valid transaction which is mainly check for the combined digit item code from above (must be between 00 and 19)
		// It also checks whether there are a non-zero number of items corresponding to the code left in the machine 
		else if (current_state == state_of_valid_transaction) 
		begin
			// Check if the number of items left in the slot is less than 1
			if (units_of_item[slot_num] < 1) 
				// If there are zero items in the corresponding slot, this is a invalid transaction 
				// Set the update state to go to invalid transaction 
				update_state <= state_of_invalid_transaction;
			// Check if the combined number of the item digit code is greater than 19 which is the last slot in the vending machine 
			else if (slot_num > 5'b10011) 
				// If the user attempt to enter item code that exceed 19, then this is a invalid transaction
				// Set the update state to go to invalid transaction
				update_state <= state_of_invalid_transaction;
			else 
			begin
				// Then we will go to the vending state that correspond to setting the vending signal 
				// Set the update state to valid vending 
				update_state <= state_of_valid_vending;
			end


		end	
		// Check if the current state is invalid transaction 
		else if (current_state == state_of_invalid_transaction) 
		begin
			// I wll just route it back to the idle state to wait for next transaction to happen 
			update_state <= state_of_idle;
		end
		// Check if the current state is valid vending 
		else if (current_state == state_of_valid_vending) 
		begin
			// Check if my 5 clock cycle stop signal is high or not 
			// This is basically checking if I have already reached the maximum 5 clock cycles at max
			if (five_cycle_counter_stop_signal) 
			begin
				// If I already count up to 5 clock cycles, then I will stop counting 
				// my proceed to keep counting signal will be set to 0
				five_cycle_counter_proceed_signal <= 1'b0;
				// I need to reset my counting for the 5 clock cycles by setting the reset sigal to flush 
				five_cycle_counter_rst_signal <= 1'b1;
				// This is means it falls under the final transaction
				update_state <= state_of_final_failed_transaction;
			end
			// Check if the valid transaction signal is high or not 
			else if (VALID_TRAN) 
			begin
				// Turn on my reset signal to reset the 5 clock cycles counting 
				five_cycle_counter_rst_signal <= 1'b1;
				// update my state to move to the final success transaction
				update_state <= state_of_final_success_transaction;
			end
			// This is the normal case which is I keep counting the 5 clock cyles to check 
			else 
			begin
				// This is the normal case, I am currently waiting to read the first digit item code within 5 clock cycles
				// I will keep increment the counting of clock cycles until it gets 5 
				five_cycle_counter_proceed_signal <= 1'b1;
				// I dont need to reset the my count for 5 clock cycles yet, so the reset signal should be set to 0 for now
				five_cycle_counter_rst_signal <= 1'b0;
			end

		end
		// Check if the current state is the final success transaction
		else if (current_state == state_of_final_success_transaction) 
		begin
			// I need to check if the door open within 5 clock cycles 
			if (five_cycle_counter_stop_signal) 
			begin
				// If I already count up to 5 clock cycles, then I will stop counting 
				// my proceed to keep counting signal will be set to 0
				five_cycle_counter_proceed_signal <= 1'b0;
				// I need to reset my counting for the 5 clock cycles by setting the reset sigal to flush 
				five_cycle_counter_rst_signal <= 1'b1;
				// I moving back to idle to wait for next upcoming transaction 
				update_state <= state_of_idle;
			end
			// Check my door open signal is high or low 
			else if (DOOR_OPEN) 
			begin
				// If the door open is high, then stop the counting of 5 clock cycles
				five_cycle_counter_proceed_signal <= 1'b0;
				// If the door open is high, then set the 5 clock cycles reset signal to 1 to get ready for next transaction
				five_cycle_counter_rst_signal <= 1'b1;
				// My door open signal is high, then move to pick up item state 
				update_state <= state_of_pick_up_item;
			end

		end
		// Check if the current is the door open status 
		else if (current_state == state_of_pick_up_item) 
		begin
			// I just need to check if door is closed or not 
			if (DOOR_OPEN == 1'b0)
			// Move back to idle for next action
				update_state <= state_of_idle;	
		end
		// Check if the curren state is the final failed transaction
		else if (current_state == state_of_final_failed_transaction) 
		begin
			// I am here at the final failed transaction 
			// Move back to idle for next action
			update_state <= state_of_idle;
		end

	end

	// I need a always block to update my outputs as I am moving between different states 
	always @(current_state) 
	begin 
		// Check if my current state is idle 
		if (current_state == state_of_idle) 
		begin
			// Reset cost to 0
			COST <= 3'b000;
			// We need to reset all of my output registers to 0
			// Reset output vend to 0
			VEND <= 1'b0;
			// Reset invalid sel to 0
			INVALID_SEL <= 1'b0;
			// Reset failed tran to 0
			FAILED_TRAN <= 1'b0;
		end
		// Check if my current state is reset 
		else if (current_state == state_of_reset) 
		begin
			// I need to first reset all of number of items per slot back to 0 
			units_of_item[0] <= 4'b0000; 
			units_of_item[1] <= 4'b0000; 
			units_of_item[2] <= 4'b0000; 
			units_of_item[3] <= 4'b0000;
			units_of_item[4] <= 4'b0000; 
			units_of_item[5] <= 4'b0000; 
			units_of_item[6] <= 4'b0000; 
			units_of_item[7] <= 4'b0000;
			units_of_item[8] <= 4'b0000; 
			units_of_item[9] <= 4'b0000; 
			units_of_item[10] <= 4'b0000; 
			units_of_item[11] <= 4'b0000;
			units_of_item[12] <= 4'b0000; 
			units_of_item[13] <= 4'b0000; 
			units_of_item[14] <= 4'b0000; 
			units_of_item[15] <= 4'b0000;
			units_of_item[16] <= 4'b0000; 
			units_of_item[17] <= 4'b0000; 
			units_of_item[18] <= 4'b0000; 
			units_of_item[19] <= 4'b0000;

			// We need to reset all of my output registers to 0
			// Reset cost to 0
			COST <= 3'b000;
			// Reset output vend to 0
			VEND <= 1'b0;
			// Reset invalid sel to 0
			INVALID_SEL <= 1'b0;
			// Reset failed tran to 0
			FAILED_TRAN <= 1'b0;

		end
		// Check if my current state is reload 
		else if (current_state == state_of_reload) 
		begin
			// I am reloading each of my slot with 10 units of snack
			// Set my slot 00 to contain 10 units of snacks 
			units_of_item[0] <= 4'b1010; 
			units_of_item[1] <= 4'b1010; 
			units_of_item[2] <= 4'b1010; 
			units_of_item[3] <= 4'b1010;
			units_of_item[4] <= 4'b1010; 
			units_of_item[5] <= 4'b1010; 
			units_of_item[6] <= 4'b1010; 
			units_of_item[7] <= 4'b1010;
			units_of_item[8] <= 4'b1010; 
			units_of_item[9] <= 4'b1010; 
			units_of_item[10] <= 4'b1010; 
			units_of_item[11] <= 4'b1010;
			units_of_item[12] <= 4'b1010; 
			units_of_item[13] <= 4'b1010; 
			units_of_item[14] <= 4'b1010; 
			units_of_item[15] <= 4'b1010;
			units_of_item[16] <= 4'b1010; 
			units_of_item[17] <= 4'b1010; 
			units_of_item[18] <= 4'b1010; 
			units_of_item[19] <= 4'b1010;
		end
		// Check if my current state is invalid transcation 
		else if (current_state ==  state_of_invalid_transaction) 
		begin
			// set my output register for invalid transaction to 1
			INVALID_SEL <= 1'b1;
		end
		// Check if my current state is valid vending
		else if (current_state == state_of_valid_vending) 
		begin
			// Set my cost output register with the corresponding cost of the selected slot from the array
			COST <= costs_of_item[slot_num];
		end
		// Check if my current state is the final success transaction
		else if (current_state == state_of_final_success_transaction) 
		begin
			// I need to decrement my units of item for the corresponding 
			units_of_item[slot_num] <= units_of_item[slot_num] - 4'b0001;
			// I need to indicate it is a successful transaction
			// Set the VEND signal to high 
			VEND <= 1'b1;
		end
		// Check if my current state is pick up item 
		else if (current_state == state_of_pick_up_item) 
		begin
			// Set my vend signal back to 0 again 
			VEND <= 1'b0;
		end
		// Check if my current state is final failed transaction 
		else if (current_state == state_of_final_failed_transaction) 
		begin
			// If yes, then set my failed transaction signal to high to indicate failure 
			FAILED_TRAN <= 1'b1;
		end
	
	end

endmodule

