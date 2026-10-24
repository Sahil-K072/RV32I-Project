import definitions::*;

module alu (
    output logic signed [31:0] alu_out,
    output zero,lt,ltu,
    input logic signed [31:0] a,
    b,
    input alu_control_t alu_control
);

  always_comb begin
    case (alu_control)
      ADD:  alu_out = a + b;
      SUB:  alu_out = a - b;
      AND:  alu_out = a & b;
      OR:   alu_out = a | b;
      XOR:  alu_out = a ^ b;
      SLT:  alu_out = {{31{1'b0}}, a < b};
      SLTU: alu_out = {{31{1'b0}}, unsigned'(a) < unsigned'(b)};
      SLL:  alu_out = a << b[4:0];
      SRL:  alu_out = a >> b[4:0];
      SRA:  alu_out = a >>> b[4:0];

      default: alu_out = 'x;
    endcase
  end

  assign zero= (alu_out == 32'b0),
  lt= (a<b),
  ltu= (unsigned'(a) < unsigned'(b));

endmodule
