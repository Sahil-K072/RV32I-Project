module mux_2to1 (
    output logic [31:0] out,
    input logic [31:0] a,
    b,
    input select
);

  always_comb out = select ? b : a;

endmodule
