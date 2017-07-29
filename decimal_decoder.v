module decimal_decoder(
	input [7:0] number,
	output reg [6:0] segments0, segments1
	);
	// constants for segments displaying decimal values
	localparam	ZERO	= 7'b100_0000,
					ONE	= 7'b111_1001,
					TWO	= 7'b010_0100,
					THREE	= 7'b011_0000,
					FOUR	= 7'b001_1001,
					FIVE	= 7'b001_0010,
					SIX	= 7'b000_0010,
					SEVEN	= 7'b111_1000,
					EIGHT	= 7'b000_0000,
					NINE	= 7'b001_1000;
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
			0: segments0 <= ZERO;
			1: segments0 <= ONE;
			2: segments0 <= TWO;
			3: segments0 <= THREE;
			4: segments0 <= FOUR;
			5: segments0 <= FIVE;
			6: segments0 <= SIX;
			7: segments0 <= SEVEN;
			8: segments0 <= EIGHT;
			9: segments0 <= NINE;
			default: segments0 <= ZERO;
		endcase
		case (tens)
			0: segments1 <= ZERO;
			1: segments1 <= ONE;
			2: segments1 <= TWO;
			3: segments1 <= THREE;
			4: segments1 <= FOUR;
			5: segments1 <= FIVE;
			6: segments1 <= SIX;
			7: segments1 <= SEVEN;
			8: segments1 <= EIGHT;
			9: segments1 <= NINE;
			default: segments1 <= ZERO;
		endcase
	end

endmodule // decimal_decoder
