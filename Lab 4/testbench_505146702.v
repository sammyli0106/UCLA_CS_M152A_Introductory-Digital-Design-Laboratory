`timescale 1ns / 1ps

module testbench_505146702;

	// 1. I need to define the given inputs 
	reg CARD_IN;
	reg VALID_TRAN;
	reg [3:0] ITEM_CODE;
	reg KEY_PRESS;
	reg DOOR_OPEN;
	reg RELOAD;
	reg CLK;
	reg RESET;

	// 2. I need to define the given outputs 
	wire VEND;
	wire INVALID_SEL;
	wire FAILED_TRAN;
	wire [2:0] COST;

	// 3. Instantiate the corresponding testing unit 
	vending_machine uut (
		// new instantiation 
		.CARD_IN(CARD_IN),
		.VALID_TRAN(VALID_TRAN),
		.ITEM_CODE(ITEM_CODE),
		.KEY_PRESS(KEY_PRESS),
		.DOOR_OPEN(DOOR_OPEN),
		.RELOAD(RELOAD),
		.CLK(CLK),
		.RESET(RESET),
		.VEND(VEND),
		.INVALID_SEL(INVALID_SEL),
		.FAILED_TRAN(FAILED_TRAN),
		.COST(COST)
	);

	// Start testing 
	initial begin
		// I need to initialize corresponding input with 0 
		CARD_IN = 0;
		VALID_TRAN = 0;
		ITEM_CODE = 0;
		KEY_PRESS = 0;
		DOOR_OPEN = 0;
		RELOAD = 0;
		CLK = 0;
		RESET = 0;
		
		#70;
		// Test Case: This is to test for a successful transaction 
		// Item Code: Choose 16 (0001 0110)
		// Cost: (0101 = 5)
		#5;
		// User inserted the card
		CARD_IN = 1'b1;
		#20;
		// The first decimal digit is 1
		ITEM_CODE = 4'b0001;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		// Set the key press signal to low
		CARD_IN = 1'b0;
		// This is the temporary item code 
		ITEM_CODE = 4'b0000;
		KEY_PRESS = 1'b0;
		#10;
		// The second deciaml digit is 6
		ITEM_CODE = 4'b0110;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		ITEM_CODE = 4'b0000;
		// Set the key press signal to low
		KEY_PRESS = 1'b0;
		#30;
		// Set valid_tran to high 
		VALID_TRAN = 1'b1;
		#10;
		// Set the door open signal to high 
		DOOR_OPEN = 1'b1;
		#20;
		// Set valid_tran signal to low 
		VALID_TRAN = 1'b0;
		// Set the door signal to low 
		DOOR_OPEN = 1'b0;
	
		// Test Case: A failed transaction happen when number of items are below 1
		#75;
		// Set the rest signal to high 
		RESET = 1'b1;
		#100;
		// Set the rest signal to low 
		RESET = 1'b0;
		#5;
		// User insert the card 
		CARD_IN = 1'b1;
		#20;
		// The first decimal digit is 1
		ITEM_CODE = 4'b0001; 
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		CARD_IN = 1'b0;
		// This is a separator between the two digits
		ITEM_CODE = 4'b0000;
		KEY_PRESS = 1'b0;
		#10;
		// The second decimal digit is 8
		ITEM_CODE = 4'b1000; 
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		// Reset the item code back to 0
		ITEM_CODE = 4'b0000;
		KEY_PRESS = 1'b0;
		#30;
		// Set the valid tran signal to high 
		VALID_TRAN = 1'b1;
		#10;
		// Set the door signal to high 
		DOOR_OPEN = 1'b1;
		#20;
		// Set the valid tran signal and door open signal back to low 
		VALID_TRAN = 1'b0;
		// Set the door open signal back to low 
		DOOR_OPEN = 1'b0;
	
		// TestCase: A failed transaction happen when user try to enter code during a reload state 
		// wait 65 to refesh everything 
		#75;
		// Set rest to high 
		RESET = 1'b1;
		#100;
		// Set rest back to low
		RESET = 1'b0;
		#5;
		// User insert the card
		CARD_IN = 1'b1;
		#20;
		// I am setting the reload to high when user are entering the first digit code
		RELOAD = 1'b1; 
		// My first decimal digit is 1
		ITEM_CODE = 4'b0001;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		CARD_IN = 1'b0;
		// This is a separator between the two digit code
		ITEM_CODE = 4'b0000;
		// Set the key press signal to low 
		KEY_PRESS = 1'b0;
		#10;
		// Setting the reload signal back to 0
		RELOAD = 1'b0;
		// My second decimal digit is 5
		ITEM_CODE = 4'b0101;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		// Clean up the item code before next testcase
		ITEM_CODE = 4'b0000;
		KEY_PRESS = 1'b0;
		#30;
		// Set the valid tran signal to high 
		VALID_TRAN = 1'b1;
		#10;
		// Set the door open signal to high 
		DOOR_OPEN = 1'b1;
		#20;
		// Set both the valid tran and door open signal to low 
		VALID_TRAN = 1'b0;
		DOOR_OPEN = 1'b0;

		// TestCase: A failed transaction will happen when user try to enter an nonexistent item code (valid: 00 to 19)
		// wait for 65 to refresh everything 
		#75;
		// Set reset signal to high 
		RESET = 1'b1;
		#100;
		// Set reset signal back to low 
		RESET = 1'b0;
		// I want to reload in idle for the new testcase 
		// Set the realod signal to high 
		RELOAD = 1'b1;
		#30;
		// Set the reload signal to low again 
		RELOAD = 1'b0;
		#5;
		// the user insert the card 
		CARD_IN = 1'b1;
		#20;
		// My first decimal digit is 2
		ITEM_CODE = 4'b0010;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		CARD_IN = 1'b0;
		// This is a separator between two digit item code
		ITEM_CODE = 4'b0000;
		KEY_PRESS = 1'b0;
		#10;
		// My second decimal digit is 5
		ITEM_CODE = 4'b0101; 
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		// Set the item code back to 0
		ITEM_CODE = 4'b0000;
		// Set the key press signal to low 
		KEY_PRESS = 1'b0;
		#30;
		// Set the valid tran signal to high 
		VALID_TRAN = 1'b1;
		#10;
		// Set the open door signal to be high 
		DOOR_OPEN = 1'b1;
		#10;
		// Set the valid tran signal to be low
		VALID_TRAN = 1'b0;
		#20;
		// Set the door open signal to be low 
		DOOR_OPEN = 1'b0;

		// TestCase: A failed transaction will happen when user enter item code during key_press is low 
		#75;
		// Set the reset signal to be high 
		RESET = 1'b1;
		#100;
		// Set the reset signal to be low 
		RESET = 1'b0;
		// I want to reload in idle for the new testcase
		RELOAD = 1'b1; 
		#30;
		// Set the reload signal to low
		RELOAD = 1'b0;
		#5;
		// User insert the card
		CARD_IN = 1'b1;
		#20;
		// The first decimal digit is 1
		// But there is no key_press signal 
		ITEM_CODE = 4'b0001;
		// Set the card in signal back to low
		CARD_IN = 1'b0;
		#60;
		// The second decimal digit is 1
		// But there is no key_press signal 
		ITEM_CODE = 4'b0001; 
		// Set the valid tran signal to high 
		VALID_TRAN = 1'b1;
		#10;
		// Set the door open signal to low 
		DOOR_OPEN = 1'b1;
		#10;
		// Set the valid tran signal back to low
		VALID_TRAN = 1'b0;
		#20;
		// Set the door open signal to low 
		DOOR_OPEN = 1'b0;

		// TestCase: A transaction is failed when reading a successful first digit item code, but fail to read a second digit item code
		#75;
		// I need to reset before the next new transaction
		RESET = 1'b1;
		#100;
		// Set the reset signal back to low 
		RESET = 1'b0;
		// I want to realod in idle for the new testcases
		RELOAD = 1'b1;
		#30;
		// Set the reload signal back to low 
		RELOAD = 1'b0;
		#5;
		// User insert the card
		CARD_IN = 1'b1;
		#20;
		// The first decimal digit is 1
		ITEM_CODE = 4'b0000;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		CARD_IN = 1'b0;
		// This the separator between the two digit item code 
		ITEM_CODE = 4'b0000;
		// Set the key press signal back to low 
		KEY_PRESS = 1'b0;
		// It is already 6 clock cycles after reading the first digit item code
		#60;
		// The second decimal digit is 2, this a invalid read 
		ITEM_CODE = 4'b0010;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		// Clean up the item code and set back to 0
		ITEM_CODE = 4'b0000;
		// Set the key press signal back to low 
		KEY_PRESS = 1'b0;
		#30;
		// Set the valid tran signal back to high 
		VALID_TRAN = 1'b1;
		#10;
		// Set the door open signal back to high 
		DOOR_OPEN = 1'b1;
		#10;
		// Set the valid tran signal back to low 
		VALID_TRAN = 1'b0;
		#20;
		// Set the door open signal to low 
		DOOR_OPEN = 1'b0;

		// Test Case: A transaction is failed when everything is checked but in five clock cycles, VALID_TRAN signal is not set to high 
		#75;
		// I need to reset everything before next transaction
		RESET = 1'b1;
		#100;
		// Set the reset signal back to low 
		RESET = 1'b0;
		// I want to reload in idle for the new transaction 
		RELOAD = 1'b1; 
		#30;
		RELOAD = 1'b0;
		#5;
		// User insert the card
		CARD_IN = 1'b1;
		#20;
		// My first deciaml digit is 1
		ITEM_CODE = 4'b0001;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		CARD_IN = 1'b0;
		// This is just the separator 
		ITEM_CODE = 4'b0000;
		// Set the key press signal back to low 
		KEY_PRESS = 1'b0;
		#10;	
		// My second decimal digit is 3
		ITEM_CODE = 4'b0011; 
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		// Clean up the item code 
		ITEM_CODE = 4'b0000;
		// Set the key press signal to 0
		KEY_PRESS = 1'b0;
		// I do not have VALID_TRAN signal inserted here, so this should be a failed transaction
		#70;
		// Set the door open signal to high 
		DOOR_OPEN = 1'b1;
		#10;
		// Set the door open signal back to low 
		DOOR_OPEN = 1'b0;

		// TestCase: A transaction is failed when everything is checked but VALID_TRAN goes high after 5 clock cycles 
		#75;
		// Set the reset signal to high to reset everything 
		RESET = 1'b1;
		#100;
		// Set the reset signal back to low 
		RESET = 1'b0;
		// I want to reload in idle for the new transaction 
		RELOAD = 1'b1;
		#30;
		// Set the reload signal back to low 
		RELOAD = 1'b0;
		#5;
		// User insert card 
		CARD_IN = 1'b1;
		#20;
		// My first decimal digit is 1
		ITEM_CODE = 4'b0001;
		// Set the key press signal to high 
		KEY_PRESS = 1'b1;
		#10;
		// Set the card in signal to low 
		CARD_IN = 1'b0;
		// This is the separator for reading digit 
		ITEM_CODE = 4'b0000;
		// Set the key press signal back to low
		KEY_PRESS = 1'b0;
		#10;
		// My second decimal digit is 9
		ITEM_CODE = 4'b1001; 
		// Set the key press signal back to high 
		KEY_PRESS = 1'b1;
		#10;
		// Refresh the item code back to 0
		ITEM_CODE = 4'b0000;
		// Set the key press signal back to low 
		KEY_PRESS = 1'b0;
		// I set the valid tran to go high after five clock cycles
		#70;
		// Set the valid tran signal back to high 
		VALID_TRAN = 1'b1;
		#20;
		// Set the valid tran signal back to low 
		VALID_TRAN = 1'b0;
		// Set the door open signal to high 
		DOOR_OPEN = 1'b1;
		#10;
		// Set the door open signal back to low 
		DOOR_OPEN = 1'b0;
		
		#150;
		// Reset everything after the test 
		RESET = 1'b1;		
	end
	
	// Defined based on clk frequency 100Hz on the spec 
	always begin
		#5;
		CLK = ~CLK; 
	end
	
	always begin
		#5000;
		$finish;
	end
      
endmodule

