package definitions;

  typedef enum logic [3:0] {
    ADD,
    SUB,
    AND,
    OR,
    XOR,
    SLT,
    SLTU,
    SLL,
    SRL,
    SRA
  } alu_control_t;

  typedef enum logic [6:0] {
    LOAD = 7'b0000011,
    STORE = 7'b0100011,
    R_TYPE = 7'b0110011,
    I_TYPE = 7'b0010011,
    BRANCH = 7'b1100011,
    JAL = 7'b1101111,
    JALR = 7'b1100111,
    LUI = 7'b0110111,
    AUIPC = 7'b0010111,
    FENCE = 7'b0001111,
    SYSTEM = 7'b1110011
  } opcode_t;

  typedef struct packed {logic [31:0] instr_read, pc, pcplus4;} signals_F2D_t;

  typedef struct packed {
    logic reg_write;
    logic [2:0] result_sel;
    logic mem_write, jump, branch, pc_target_sel;
    alu_control_t alu_control;
    logic alu_sel;
    logic [2:0] funct3;
    logic [3:0] exception_cause;
    logic halt;
    logic [31:0] reg_read1, reg_read2, pc;
    logic [4:0] reg_rs1, reg_rs2, reg_rd;
    logic [31:0] imm_ext, pcplus4;
  } signals_D2E_t;

  typedef struct packed {
    logic reg_write;
    logic [2:0] result_sel;
    logic mem_write;
    logic [2:0] funct3;
    logic [3:0] exception_cause;
    logic halt;
    logic [31:0] alu_result, write_data, pc;
    logic [4:0] reg_rd;
    logic [31:0] imm_ext, pc_target, pcplus4;
  } signals_E2M_t;

  typedef struct packed {
    logic reg_write;
    logic [2:0] result_sel;
    logic [3:0] exception_cause;
    logic halt;
    logic [31:0] alu_result, data_read, pc;
    logic [4:0] reg_rd;
    logic [31:0] imm_ext, pc_target, pcplus4;
  } signals_M2W_t;

  typedef struct packed {
    logic stallF, stallD, stallW, flushD, flushE, flushM;
    logic [1:0] forwardAE, forwardBE;
  } hazard_controls_t;

endpackage
