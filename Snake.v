/**
 * The main module for the game Snake.
 */
module Snake(
    CLOCK_50,      // On Board 50 MHz
    KEY,           // KEY controls are for movement
    SW,            // SW switches are for reset, gamespeed
    HEX4,          // displays ones place of scores
    HEX5,          // displays tens place of score
    LEDR,          // lights up when snake eats apple
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
  input CLOCK_50;           // 50 MHz clock
  input [9:0] SW;           // Switches to control difficulty (game speed)
  input [3:0] KEY;          // KEY button to control snake movement
  output [6:0] HEX4, HEX5;  // HEX displays to show current score
  output [17:0] LEDR;       // red LEDs lights up when snake eats apple

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
  defparam VGA.BACKGROUND_IMAGE = "snake_bg_title.mif";

  // player inputs go here
  wire resetn;
  wire press_right, press_up, press_down, press_left;
  assign resetn      = SW[0];
  assign press_right = ~KEY[0];
  assign press_up    = ~KEY[1];
  assign press_down  = ~KEY[2];
  assign press_left  = ~KEY[3];

  // get clocks to later select for difficulty
  wire easyclk, normalclk, hardclk, extremeclk;
  rate_divider_slower rd0(  .clkin(CLOCK_50), .clkout(easyclk)    );
  rate_divider rd1(         .clkin(CLOCK_50), .clkout(normalclk)  );
  rate_divider_faster rd2(  .clkin(CLOCK_50), .clkout(hardclk)    );
  rate_divider_extreme rd3( .clkin(CLOCK_50), .clkout(extremeclk) );

  // game speed clock (for difficulty or game speed)
  wire gameclk;
  mux4to1 gameMux(
    .x0(easyclk),
    .x1(normalclk),
    .x2(hardclk),
    .x3(extremeclk),
    .s0(SW[2]),
    .s1(SW[3]),
    .out(gameclk)
  );

  // output wires from datapath
  wire [1:0] direction;
  wire [2:0] state;
  wire [7:0] score;
  wire ate_apple;

  // Instansiate FSM control
  controller ctrl(
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
  datapath data(
    .clk(CLOCK_50),
    .gameclk(gameclk),
    .resetn(resetn),
    .direction(direction),
    .state(state),
    .x(x),
    .y(y),
    .colour(colour),
    .score(score),
    .ate_apple(ate_apple)
  );

  // flash LEDs on snake eating apple
  led_flasher lf(
    .ate_apple(ate_apple),
    .ledr(LEDR[17:0])
  );

  // display score as decimal on HEX displays
  wire carry0, carry1;
  decimal_decoder dd0(
    .hex_digit(score[3:0]),
    .segments(HEX4),
    .carry_ten(carry0)
  );
  decimal_decoder dd1(
    .hex_digit(score[7:4] + carry0),
    .segments(HEX5),
    .carry_ten(carry1)
  );
endmodule // main module

//////////////////////////////////////////////////////////////////////////////

/**
 * Flashes the red LED lights when snake eats an apple.
 */
module led_flasher(
  input ate_apple,
  output [17:0] ledr
  );
  assign ledr[0] = ate_apple;
  assign ledr[2] = ate_apple;
  assign ledr[4] = ate_apple;
  assign ledr[6] = ate_apple;
  assign ledr[8] = ate_apple;
  assign ledr[10] = ate_apple;
  assign ledr[12] = ate_apple;
  assign ledr[14] = ate_apple;
  assign ledr[16] = ate_apple;
endmodule // led_flasher

//////////////////////////////////////////////////////////////////////////////

/**
 * FSM controller to output states.
 */
module controller(
  input clk,                    // 50 MHz FPGA clock
  input gameclk,                // game speed clock
  input resetn,                 // active low synchronous reset
  input press_left, press_up, press_down, press_right,  // player key inputs
  output reg [1:0] direction,   // direction to output
  output [2:0] state,           // FSM state to output
  output reg writeEn            // write to output
  );
  // registers to hold current state and next state
  reg [2:0] current_state, next_state;
  // constants for FSM states
  localparam  CLEAR_TAIL_PREP  = 3'b000,
              CLEAR_TAIL       = 3'b001,
              MOVE_BODY_PREP   = 3'b010,
              MOVE_BODY        = 3'b011,
              PRINT_APPLE_PREP = 3'b100,
              PRINT_APPLE      = 3'b101,
              END_CYCLE        = 3'b110;
  // constants for direction
  localparam  LEFT  = 2'b00,
              UP    = 2'b01,
              DOWN  = 2'b10,
              RIGHT = 2'b11;
  // initialize values
  initial begin
    direction <= RIGHT;
    current_state <= END_CYCLE;
    writeEn <= 1'b0;
  end
  // cycle through FSM states
  always @(posedge clk)
  begin: state_table
    case (current_state)
      CLEAR_TAIL_PREP:  next_state <= CLEAR_TAIL;
      CLEAR_TAIL:       next_state <= MOVE_BODY_PREP;
      MOVE_BODY_PREP:   next_state <= MOVE_BODY;
      MOVE_BODY:        next_state <= PRINT_APPLE_PREP;
      PRINT_APPLE_PREP: next_state <= PRINT_APPLE;
      PRINT_APPLE:      next_state <= END_CYCLE;
      END_CYCLE:        next_state <= gameclk ? CLEAR_TAIL_PREP: END_CYCLE;
      default:          next_state <= END_CYCLE;
    endcase
  end
  // change direction based on player key input and current direction
  always @(posedge clk) begin
    if (~resetn) begin                       // if resetn is low,
      direction <= RIGHT;                    // set direction to right
    end else begin
      if (press_left && direction != RIGHT)  // if player presses left,
        direction <= LEFT;                   // set direction to left
      if (press_up && direction != DOWN)     // if player presses up,
        direction <= UP;                     // set direction to up
      if (press_down && direction != UP)     // if player presses down,
        direction <= DOWN;                   // set direction to down
      if (press_right && direction != LEFT)  // if player presses right,
        direction <= RIGHT;                  // set direction to right
    end
  end
  // set the current state
  always @(posedge clk) begin
    if (~resetn) begin
      current_state <= END_CYCLE;
      writeEn <= 1'b0;
    end else begin
      current_state <= next_state;
      writeEn <= 1'b1;
    end
  end
  // assign state to output
  assign state = current_state;

endmodule // controller

//////////////////////////////////////////////////////////////////////////////

/**
 * Snake datapath module for game mechanics.
 */
module datapath(
  input clk,                // 50 MHz FPGA clock
  input gameclk,            // game speed clock
  input resetn,             // active low synchronous reset
  input [1:0] direction,    // direction of the snake, from controller
  input [2:0] state,        // current FSM state, from controller
  output reg [7:0] x,       // x-coordinate to print on VGA screen
  output reg [6:0] y,       // y-coordinate to print on VGA screen
  output reg [2:0] colour,  // colour of pixel to print
  output reg [7:0] score,   // score to show on HEX displays
  output reg ate_apple      // when snake eats an apple, LEDRs light up
  );
  reg [7:0] headX, appleX;  // 8-bit x-coordinates of snake head and apple
  reg [6:0] headY, appleY;  // 7-bit y-coordinates of snake head and apple
  reg [7:0] bodyX[0:127];   // 128-element array of 8-bit x-coordinates
  reg [6:0] bodyY[0:127];   // 128-element array of 7-bit y-coordinates
  reg init_state;           // boolean register for initial state
  reg gameover;             // boolean register for game over
  integer i;                // integer value for looping

  // initialize module, init_state is for print apple at beginning of game
  initial begin
    headX <= 60; headY <= 40;
    appleX <= 50; appleY <= 70;
    bodyX[0] <= 60; bodyY[0] <= 40;
    score <= 0;
    init_state <= 1;
    gameover <= 0;
    x <= 60; y <= 40;
    ate_apple <= 0;
    colour <= BLACK;
  end

  // constants for FSM stategameclks
  localparam  CLEAR_TAIL_PREP  = 3'b000,
              CLEAR_TAIL       = 3'b001,
              MOVE_BODY_PREP   = 3'b010,
              MOVE_BODY        = 3'b011,
              PRINT_APPLE_PREP = 3'b100,
              PRINT_APPLE      = 3'b101,
              END_CYCLE        = 3'b110;
  // constants for direction
  localparam  LEFT  = 2'b00,
              UP    = 2'b01,
              DOWN  = 2'b10,
              RIGHT = 2'b11;
  // constants for colours
  localparam  RED    = 3'b100,
              GREEN  = 3'b010,
              BLUE   = 3'b001,
              PURPLE = 3'b101,
              BLACK  = 3'b000;
  // pseudorandom coordinates generator
  wire [7:0] randX; wire [6:0] randY;
  random_coordinates RC0(
    .clk(clk),
    .randX(randX),
    .randY(randY)
  );

  // reset, same as init
  always @(posedge clk) begin
    if (~resetn || gameover) begin
      init_state <= 1;
      headX <= 60; headY <= 40;
      bodyX[0] <= 60; bodyY[0] <= 40;
      appleX <= 50; appleY <= 70;
      x <= appleX; y <= appleY;
      score <= 0;
      gameover <= 0;
      ate_apple <= 0;
      colour <= BLACK;
    end

    if (state == CLEAR_TAIL_PREP) begin
      ate_apple <= 0;
      // update new snake head coordinates
      case (direction)
        LEFT: begin
          headX <= headX - 1'b1;
          if (headX == 0) gameover <= 1;
        end
        UP: begin
          headY <= headY - 1'b1;
          if (headY == 25) gameover <= 1;
        end
        DOWN: begin
          headY <= headY + 1'b1;
          if (headY == 119) gameover <= 1;
        end
        RIGHT: begin
          headX <= headX + 1'b1;
          if (headX == 159) gameover <= 1;
        end
      endcase

    end else if (state == CLEAR_TAIL) begin
      x <= bodyX[score]; y <= bodyY[score];
      // if apple will be eaten
      if (appleX == headX && appleY == headY) begin
        colour <= GREEN;
      // if apple won't be eaten
      end else begin
        colour <= BLACK;
      end

    end else if (state == MOVE_BODY_PREP) begin
      // if snake eats apple, increment score
      if (appleX == headX && appleY == headY) begin
        score <= score + 1;
      end

    end else if (state == MOVE_BODY) begin
      // update the head position and print it
      if (headX == 0 || headX == 159 || headY == 25 || headY == 119) begin
        colour <= BLUE;
      end else begin
        colour <= GREEN;
      end

      // update body positions
      x <= headX; y <= headY;
      bodyX[0] <= headX; bodyY[0] <= headY;
      for (i = 0; i < 127; i++) begin
        bodyX[i + 1'b1] <= bodyX[i];
        bodyY[i + 1'b1] <= bodyY[i];
      end

    end else if (state == PRINT_APPLE_PREP) begin
      // do nothing here, this is preparing for PRINT_APPLE

    end else if (state == PRINT_APPLE) begin
      // if apple eaten or initial
      if (appleX == headX && appleY == headY || init_state) begin
        ate_apple <= 1;
        init_state <= 0;

        // if apple is spawned on border, regenerate apple coordinates on next cycle
        if (randX == 0 || randX == 159 || randY <= 25 || randY == 119) begin
          init_state <= 1;
          appleX <= 255; appleY <= 127;
          x <= 255; y <= 127;

        end else begin
          appleX <= randX; appleY <= randY;
          x <= randX; y <= randY;
          colour <= RED;
        end

      end
    end
  end

endmodule // datapath

//////////////////////////////////////////////////////////////////////////////

/**
 * Generates random 8-bit x and 7-bit y coordinates.
 */
module random_coordinates(
   input clk,
   output reg [7:0] randX,
   output reg [6:0] randY
   );
   initial begin
      randX <= 8'b10101010;
      randY <= 7'b0011001;
   end
   always @(posedge clk) begin
      randX <= ((randX + 4) % 154) + 1;
      randY <= ((randY + 30) % 116) + 1;
   end
endmodule // random_coordinates

//////////////////////////////////////////////////////////////////////////////
