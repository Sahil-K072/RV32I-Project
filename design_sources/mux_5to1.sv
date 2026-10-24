module mux_5to1 (
    output logic [31:0] out,
    input logic [31:0] a,
    b,
    c,
    d,
    e,
    input [2:0] select
);

  always_comb begin
    case (select)
      3'b000:  out = a;
      3'b001:  out = b;
      3'b010:  out = c;
      3'b011:  out = d;
      3'b100:  out = e;
      default: out = 'x;
    endcase
  end

endmodule
