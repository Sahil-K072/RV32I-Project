import definitions::*;

module control_unit (
    output logic reg_write,
    alu_sel,
    mem_write,
    jump,
    branch,
    pc_target_sel,
    output logic [2:0] imm_sel,
    output logic [2:0] result_sel,
    output alu_control_t alu_control,
    output logic [3:0] exception_cause,
    output logic halt,
    input opcode_t op,
    input logic [2:0] funct3,
    input logic funct7_5,
    input logic instr_20
);

  logic [ 1:0] alu_op;

  logic [13:0] control_bus;
  assign {reg_write, imm_sel, alu_sel, mem_write, result_sel, branch, alu_op, jump, pc_target_sel} = control_bus;


  // main decoder
  always_comb begin
    case (op)
      LOAD: control_bus = 14'b1_000_1_0_001_0_00_0_0;
      STORE: control_bus = 14'b0_001_1_1_xx0_0_00_0_0;
      R_TYPE: control_bus = 14'b1_xxx_0_0_000_0_10_0_0;
      BRANCH: control_bus = 14'b0_010_0_0_xx0_1_01_0_0;
      I_TYPE: control_bus = 14'b1_000_1_0_000_0_10_0_0;
      JAL: control_bus = 14'b1_011_x_0_010_0_xx_1_0;
      JALR: control_bus = 14'b1_000_x_0_010_0_xx_1_1;
      LUI: control_bus = 14'b1_100_x_0_011_0_xx_0_0;
      AUIPC: control_bus = 14'b1_100_x_0_100_0_xx_0_0;
      FENCE: control_bus = 14'b0_xxx_x_0_xx0_0_xx_0_x;
      SYSTEM: control_bus = 14'b0_xxx_x_0_xx0_0_xx_0_x;

      default: control_bus = {14{1'b0}};
    endcase

    if (op == SYSTEM) begin
      exception_cause = instr_20 ? 4'd3 : 4'd11; // ecall , ebreak
      halt = 1;
    end else begin
      exception_cause = 4'd0;
      halt = 0;
    end
  end

  // alu decoder
  always_comb begin
    case (alu_op)
      2'b00: alu_control = ADD;
      2'b01: alu_control = SUB;
      2'b10: begin
        case (op[5])
          1'b1: begin : r_type
            case (funct3)
              3'b000: alu_control = funct7_5 ? SUB : ADD;
              3'b001: alu_control = SLL;
              3'b010: alu_control = SLT;
              3'b011: alu_control = SLTU;
              3'b100: alu_control = XOR;
              3'b101: alu_control = funct7_5 ? SRA : SRL;
              3'b110: alu_control = OR;
              3'b111: alu_control = AND;
            endcase
          end : r_type
          1'b0: begin : i_type
            case (funct3)
              3'b000: alu_control = ADD;
              3'b001: alu_control = SLL;
              3'b010: alu_control = SLT;
              3'b011: alu_control = SLTU;
              3'b100: alu_control = XOR;
              3'b101: alu_control = funct7_5 ? SRA : SRL;
              3'b110: alu_control = OR;
              3'b111: alu_control = AND;
            endcase
          end : i_type
        endcase
      end

      default: alu_control = alu_control_t'('x);
    endcase
  end

endmodule
