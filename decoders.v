/**
 * Hex decoder to display decimal values (DOES NOT WORK!).
 */
module decimal_decoder(
  input [7:0] number,
  output reg [6:0] hex0, hex1
  );
  // constants for segments displaying decimal values
  localparam  ZERO  = 7'b100_0000,
              ONE   = 7'b111_1001,
              TWO   = 7'b010_0100,
              THREE = 7'b011_0000,
              FOUR  = 7'b001_1001,
              FIVE  = 7'b001_0010,
              SIX   = 7'b000_0010,
              SEVEN = 7'b111_1000,
              EIGHT = 7'b000_0000,
              NINE  = 7'b001_1000;
  // declare registers to hold digits at ones and tens place
  reg ones, tens;
  initial begin
    ones <= ZERO;
    tens <= ZERO;
  end
  always @(*) begin
    ones <= number % 10;
    tens <= number / 10;
    case (ones)
      0: hex0 <= ZERO;
      1: hex0 <= ONE;
      2: hex0 <= TWO;
      3: hex0 <= THREE;
      4: hex0 <= FOUR;
      5: hex0 <= FIVE;
      6: hex0 <= SIX;
      7: hex0 <= SEVEN;
      8: hex0 <= EIGHT;
      9: hex0 <= NINE;
      default: hex0 <= ZERO;
    endcase
    case (tens)
      0: hex1 <= ZERO;
      1: hex1 <= ONE;
      2: hex1 <= TWO;
      3: hex1 <= THREE;
      4: hex1 <= FOUR;
      5: hex1 <= FIVE;
      6: hex1 <= SIX;
      7: hex1 <= SEVEN;
      8: hex1 <= EIGHT;
      9: hex1 <= NINE;
      default: hex1 <= ZERO;
    endcase
  end
endmodule // decimal_decoder
