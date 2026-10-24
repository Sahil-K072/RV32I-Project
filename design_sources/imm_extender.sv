module imm_extender (
    output logic [31:0] imm_ext,
    input  logic [31:7] imm,
    input  logic [ 2:0] imm_sel
);

  always_comb begin
    case (imm_sel)
      3'b000: imm_ext = {{20{imm[31]}}, imm[31:20]};
      3'b001: imm_ext = {{20{imm[31]}}, imm[31:25], imm[11:7]};
      3'b010: imm_ext = {{20{imm[31]}}, imm[7], imm[30:25], imm[11:8], 1'b0};
      3'b011: imm_ext = {{12{imm[31]}}, imm[19:12], imm[20], imm[30:21], 1'b0};
      3'b100: imm_ext = {imm[31:12], {12{1'b0}}};
      default: imm_ext = 'x;
    endcase
  end

endmodule
