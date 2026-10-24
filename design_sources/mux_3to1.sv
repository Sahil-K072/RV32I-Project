module mux_3to1 (
    output logic [31:0] out,
    input logic [31:0] a,
    b,
    c,
    input [1:0] select
);

  always_comb begin
    case (select)
      2'b00: out = a;
      2'b01: out = b;
      2'b10: out = c;
      2'b11: out = 'x;
    endcase
  end

endmodule
