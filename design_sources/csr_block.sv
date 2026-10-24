module csr_block (
    input logic [31:0] pcW,
    input logic [3:0] exception_causeW,
    input logic haltW
);

  logic [31:0] mepc;
  logic [ 3:0] mcause;

  always_comb begin
    if (haltW) begin
      mepc   = pcW;
      mcause = exception_causeW;
    end else begin
      mepc   = '0;
      mcause = '0;
    end
  end

endmodule
