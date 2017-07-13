module Snek(
      CLOCK_50,      // On Board 50 MHz
      KEY,           // KEY controls are for movement
      SW,            // SW switches are for reset, gamespeed
      HEX0,
      HEX1,
      HEX2,
      HEX3,
      // The ports below are for the VGA output.
      VGA_CLK,       // VGA Clock
      VGA_HS,        // VGA H_SYNC
      VGA_VS,        // VGA V_SYNC
      VGA_BLANK_N,   // VGA BLANK
      VGA_SYNC_N,    // VGA SYNC
      VGA_R,         // VGA Red   [9:0]
      VGA_G,         // VGA Green [9:0]
      VGA_B          // VGA Blue  [9:0]
   );
   input CLOCK_50;      // 50 MHz
   input [9:0] SW;
   input [3:0] KEY;
	output [6:0] HEX0, HEX1, HEX2, HEX3;

   // Outputs for VGA
   output VGA_CLK;      // VGA Clock
   output VGA_HS;       // VGA H_SYNC
   output VGA_VS;       // VGA V_SYNC
   output VGA_BLANK_N;  // VGA BLANK
   output VGA_SYNC_N;   // VGA SYNC
   output [9:0] VGA_R;  // VGA Red[9:0]
   output [9:0] VGA_G;  // VGA Green[9:0]
   output [9:0] VGA_B;  // VGA Blue[9:0]

   // Create the colour, x, y and writeEn wires that are inputs to the controller.
   wire [2:0] colour;
   wire [7:0] x;
   wire [6:0] y;
   wire writeEn;

   // Create an Instance of a VGA controller - there can be only one!
   // Define the number of colours as well as the initial background
   // image file (.MIF) for the controller.
   vga_adapter VGA(
      .resetn(resetn),
      .clock(CLOCK_50),
      .colour(colour),
      .x(x),
      .y(y),
      .plot(writeEn),
      /* Signals for the DAC to drive the monitor. */
      .VGA_R(VGA_R),
      .VGA_G(VGA_G),
      .VGA_B(VGA_B),
      .VGA_HS(VGA_HS),
      .VGA_VS(VGA_VS),
      .VGA_BLANK(VGA_BLANK_N),
      .VGA_SYNC(VGA_SYNC_N),
      .VGA_CLK(VGA_CLK)
   );
   defparam VGA.RESOLUTION = "160x120";
   defparam VGA.MONOCHROME = "FALSE";
   defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
   defparam VGA.BACKGROUND_IMAGE = "black.mif";

   // player inputs go here
   wire resetn;
   wire press_right, press_up, press_down, press_left;
   
   assign resetn      = SW[0];
   assign press_right = ~KEY[0];
   assign press_up    = ~KEY[1];
   assign press_down  = ~KEY[2];
   assign press_left  = ~KEY[3];

	// game speed clock
	wire gameclk;
   rate_divider rd(
		.clkin(CLOCK_50),
		.clkout(gameclk)
	);

	// output wires from datapath
	wire [1:0] direction;
	wire [2:0] state;
	wire [7:0] score;
	
	reg [7:0] totalScore;
	initial begin
		totalScore = 8'b0;
	end
	
   // Instansiate FSM control
	player_controller player_ctrl(
		.clk(CLOCK_50),
		.gameclk(gameclk),
		.resetn(resetn),
		.press_left(press_left),
		.press_up(press_up),
		.press_down(press_down),
		.press_right(press_right),
		.direction(direction),
		.state(state),
		.writeEn(writeEn)
	);

   // Instansiate datapath
	player_datapath player_data(
		.clk(CLOCK_50),
		.gameclk(gameclk),
		.resetn(resetn),
		.direction(direction),
		.state(state),
		.x(x),
		.y(y),
		.colour(colour),
		.score(score)
	);

endmodule // main module

////////////////////////////////////////////////////////////////////////////////

module player_controller(
   input clk,		// 50 MHz FPGA clock
	input gameclk,	// game speed clock
   input resetn,	// active low synchronous reset
	input press_left, press_up, press_down, press_right,
	output reg [1:0] direction,
	output [2:0] state,
	output reg writeEn
   );
	
	localparam	MOVE_BODY		= 3'b000,
					CLEAR_TAIL		= 3'b001,
					END_CYCLE		= 3'b010;
	
	reg [2:0] current_state, next_state;
	
	always @(posedge clk)
	begin: state_table
		case (current_state)
			CLEAR_TAIL:		next_state <= MOVE_BODY;
			MOVE_BODY: 	next_state <= END_CYCLE;
			END_CYCLE: 		next_state <= gameclk ? CLEAR_TAIL: END_CYCLE;
			default:			next_state <= END_CYCLE;
		endcase
	end
   
	localparam  LEFT  = 2'b00,
               UP    = 2'b01,
               DOWN  = 2'b10,
               RIGHT = 2'b11;
	
   always @(posedge clk) begin
		if (~resetn) begin
			direction <= RIGHT;
		end else begin
			if (press_left && direction != RIGHT)			// if player presses left
				direction <= LEFT;
			else if (press_up && direction != DOWN)		// if player presses up
				direction <= UP;
			else if (press_down && direction != UP) 	// if player presses down
				direction <= DOWN;
			else if (press_right && direction != LEFT)	// if player presses right
				direction <= RIGHT;
		end
   end
	
	always @(posedge clk) begin
		if (~resetn) begin
			current_state <= END_CYCLE;
			writeEn <= 1'b0;
		end
		else begin
			current_state <= next_state;
			writeEn <= 1'b1;
		end
	end

	assign state = current_state;
	
endmodule // player_controller

////////////////////////////////////////////////////////////////////////////////

module player_datapath(
   input clk,		// 50 MHz FPGA clock
	input gameclk,	// game speed clock
   input resetn,	// active low synchronous reset
	input [1:0] direction,
	input [2:0] state,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg [2:0] colour,
	output reg [7:0] score
   );
	
	reg [7:0] newX;
	reg [6:0] newY;
	reg [7:0] bodyX[0:127];
	reg [6:0] bodyY[0:127];
	reg [7:0] curr_body_index;
	
	initial begin
		newX <= 60;
		newY <= 40;
		score <= 0;
		curr_body_index <= 1;
	end

	localparam  LEFT  = 2'b00,
               UP    = 2'b01,
               DOWN  = 2'b10,
               RIGHT = 2'b11;
					
	localparam	MOVE_BODY		= 3'b000,
					CLEAR_TAIL		= 3'b001,
					END_CYCLE		= 3'b010;
					
	always @(posedge clk) begin
		if (state == MOVE_BODY) begin
			case (direction)
				LEFT:		newX <= newX - 1'b1;
				UP:		newY <= newY - 1'b1;
				DOWN:		newY <= newY + 1'b1;
				RIGHT:	newX <= newX + 1'b1;
			endcase
			bodyX[0] <= newX;
			bodyY[0] <= newY;
			curr_body_index <= 2;
			/*
			while (curr_body_index <= score) begin
				bodyX[curr_body_index] <= bodyX[curr_body_index - 1];
				bodyY[curr_body_index] <= bodyY[curr_body_index - 1];
				curr_body_index <= curr_body_index + 1;
			end
			*/
			x <= newX;
			y <= newY;
			colour <= 3'b010;
		end else if (state == CLEAR_TAIL) begin
			x <= bodyX[score];
			y <= bodyY[score];
			colour <= 3'b000;
		end
	end

endmodule // player

////////////////////////////////////////////////////////////////////////////////

module apple_generator(
	input clk,
	input resetn,
	input [7:0] playerX,
	input [6:0] playerY,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg add_score,
	output reg [2:0] colour,
	output reg writeEn
	);
	wire [7:0] randomX;
	wire [6:0] randomY;
	random_coordinates RC0(
		.clk(clk),
		.randomX(randomX),
		.randomY(randomY)
	);
	reg [7:0] prevX, appleX;
	reg [6:0] prevY, appleY;
	
	initial begin
		appleX <= {1'b0, randomX[6:0]};
		appleY <= randomY;
		prevX <= {1'b0, randomX[6:0]};
		prevY <= randomY;
		add_score <= 1'b0;
		colour <= 3'b100;
		writeEn <= 1'b1;
	end
	
	always @(posedge clk) begin
		add_score <= 1'b0;
		colour <= 3'000;
		writeEn <= 1'b0;
		if (~resetn) begin
			x <= prevX;
			y <= prevY;
			writeEn <= 1'b1;
		end else if
			if (playerX == appleX && playerY == appleY) begin
				appleX <= {1'b0, randomX[6:0]};
				appleY <= randomY;
				add_score <= 1'b1;
				colour <= 3'100;
				writeEn <= 1'b1;
			end
			prevX <= appleX;
			prevY <= appleY;
			x <= appleX;
			y <= appleY;
		end
	end
	
	
endmodule // apple_generator

////////////////////////////////////////////////////////////////////////////////

module rate_divider(
   input clkin,
   output reg clkout
   );
   reg [21:0] count;
	initial begin
		clkout <= 1'b0;
		count <= 22'b0;
	end
   always@(posedge clkin) begin
      if (count == 1777777) begin
         clkout <= 1'b1;
         count <= 22'b0;
      end else begin
         clkout <= 1'b0;
         count <= count + 1'b1;
      end
   end
endmodule

////////////////////////////////////////////////////////////////////////////////

module random_coordinates(
   input clk,
   output reg [7:0] randomX,
   output reg [6:0] randomY
   );
   initial begin
      randomX <= 8'b10101010;
      randomY <= 7'b0011001;
   end
   always @(posedge clk) begin  
      randomX <= ((randomX + 3) % 78) + 1;
      randomY <= ((randomY + 5) % 58) + 1;
   end
endmodule // random_coordinates