module rate_divider_slower(
  input clkin,
  output reg clkout
  );
  reg [21:0] count;
  initial begin
    clkout <= 1'b0;
    count <= 22'b0;
  end
always@(posedge clkin) begin
  if (count == 3555555) begin
    clkout <= 1'b1;
    count <= 22'b0;
  end else begin
    clkout <= 1'b0;
    count <= count + 1'b1;
  end
end
endmodule // rate_divider_slower

//////////////////////////////////////////////////////////////////////////////

module rate_divider(
  input clkin,
  output reg clkout
  );
  reg [20:0] count;
  initial begin
    clkout <= 1'b0;
    count <= 21'b0;
  end
  always@(posedge clkin) begin
    if (count == 1777777) begin
      clkout <= 1'b1;
      count <= 21'b0;
    end else begin
      clkout <= 1'b0;
      count <= count + 1'b1;
    end
  end
endmodule // rate_divider

//////////////////////////////////////////////////////////////////////////////

module rate_divider_faster(
  input clkin,
  output reg clkout
  );
  reg [19:0] count;
  initial begin
    clkout <= 1'b0;
    count <= 20'b0;
  end
  always@(posedge clkin) begin
    if (count == 888888) begin
      clkout <= 1'b1;
      count <= 20'b0;
    end else begin
      clkout <= 1'b0;
      count <= count + 1'b1;
    end
  end
endmodule // rate_divider_faster

//////////////////////////////////////////////////////////////////////////////

module rate_divider_extreme(
  input clkin,
  output reg clkout
  );
  reg [18:0] count;
  initial begin
    clkout <= 1'b0;
    count <= 19'b0;
  end
  always@(posedge clkin) begin
    if (count == 444444) begin
      clkout <= 1'b1;
      count <= 19'b0;
    end else begin
      clkout <= 1'b0;
      count <= count + 1'b1;
    end
  end
endmodule // rate_divider_extreme
