/**
 * A 2-to-1 multiplexer.
 */
module mux2to1(
  input x, y, s,
  output m
  );
	assign m = x & ~s | y & s;
endmodule // mux2to1

//////////////////////////////////////////////////////////////////////////////

/**
 * A 4-to-1 multiplexer.
 */
module mux4to1(
	input x0, x1, x2, x3, s0, s1,
	output out
	);
	wire out01, out23;
	mux2to1 m0( .x(x0), .y(x1), .s(s0), .m(out01) );
	mux2to1 m1( .x(x2), .y(x3), .s(s0), .m(out23) );
	mux2to1 m2( .x(out01), .y(out23), .s(s1), .m(out) );
endmodule // mux4to1
