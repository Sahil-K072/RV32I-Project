import definitions::*;

module top (
    input logic clk,
    reset
);

  logic [31:0] pcF_next;

  logic [ 2:0] imm_sel;

  logic branchE, pc_selE, zeroE, ltE, ltuE;
  logic [31:0] aluA, aluB, pc_target_ip, pc_targetE;

  logic [31:0] resultW;

  signals_F2D_t IFout, IDin;
  signals_D2E_t IDout, EXin;
  signals_E2M_t EXout, MEMin;
  signals_M2W_t MEMout, WBin;
  hazard_controls_t hazard_controls;


  //========================================
  // FETCH
  //========================================

  // pc select mux
  mux_2to1 pc_mux (
      .out(pcF_next),
      .a(IFout.pcplus4),
      .b(pc_targetE),
      .select(pc_selE)
  );

  // pc update adder
  always_comb IFout.pcplus4 = IFout.pc + 32'd4;

  // pc register
  always_ff @(posedge clk) begin
    if (reset) IFout.pc <= 32'b0;  // active-high reset
    else if (~hazard_controls.stallF) IFout.pc <= pcF_next;  // active-low enable
  end

  instruction_mem i_mem1 (
      .read(IFout.instr_read),
      .addr(IFout.pc)
  );

  // Fetch to Decode pipeline register
  always_ff @(posedge clk) begin
    if (~hazard_controls.stallD & ~hazard_controls.flushD)
      IDin <= IFout;  // active-low enable and active-high clear
    else if (hazard_controls.flushD) IDin <= '0;
  end



  //========================================
  // DECODE
  //========================================

  control_unit control_unit1 (
      .reg_write(IDout.reg_write),
      .alu_sel(IDout.alu_sel),
      .mem_write(IDout.mem_write),
      .jump(IDout.jump),
      .branch(IDout.branch),
      .pc_target_sel(IDout.pc_target_sel),
      .imm_sel(imm_sel),
      .result_sel(IDout.result_sel),
      .alu_control(IDout.alu_control),
      .exception_cause(IDout.exception_cause),
      .halt(IDout.halt),
      .op(opcode_t'(IDin.instr_read[6:0])),
      .funct3(IDin.instr_read[14:12]),
      .funct7_5(IDin.instr_read[30]),
      .instr_20(IDin.instr_read[20])
  );

  reg_file reg_file1 (
      .read1(IDout.reg_read1),
      .read2(IDout.reg_read2),
      .addr1(IDin.instr_read[19:15]),
      .addr2(IDin.instr_read[24:20]),
      .addr3(WBin.reg_rd),
      .wd3  (resultW),
      .we3  (WBin.reg_write),
      .clk  (clk)
  );

  imm_extender imm_extender1 (
      .imm_ext(IDout.imm_ext),
      .imm(IDin.instr_read[31:7]),
      .imm_sel(imm_sel)
  );

  assign IDout.funct3 = IDin.instr_read[14:12],
      IDout.pc = IDin.pc,
      IDout.reg_rs1 = IDin.instr_read[19:15],
      IDout.reg_rs2 = IDin.instr_read[24:20],
      IDout.reg_rd = IDin.instr_read[11:7],
      IDout.pcplus4 = IDin.pcplus4;

  // Decode to Execute pipeline register
  always_ff @(posedge clk) begin
    if (hazard_controls.flushE) EXin <= '0;  // active-high clear
    else EXin <= IDout;
  end



  //========================================
  // EXECUTE
  //========================================

  mux_3to1 alu_muxA (
      .out(aluA),
      .a(EXin.reg_read1),
      .b(resultW),
      .c(MEMin.alu_result),
      .select(hazard_controls.forwardAE)
  );

  mux_3to1 mux2 (
      .out(EXout.write_data),
      .a(EXin.reg_read2),
      .b(resultW),
      .c(MEMin.alu_result),
      .select(hazard_controls.forwardBE)
  );

  mux_2to1 alu_muxB (
      .out(aluB),
      .a(EXout.write_data),
      .b(EXin.imm_ext),
      .select(EXin.alu_sel)
  );

  alu alu1 (
      .alu_out(EXout.alu_result),
      .zero(zeroE),
      .lt(ltE),
      .ltu(ltuE),
      .a(aluA),
      .b(aluB),
      .alu_control(EXin.alu_control)
  );

  always_comb begin
    case (EXin.funct3)
      3'b000:  branchE = zeroE ? 1 : 0;
      3'b001:  branchE = zeroE ? 0 : 1;
      3'b100:  branchE = ltE ? 1 : 0;
      3'b101:  branchE = ltE ? 0 : 1;
      3'b110:  branchE = ltuE ? 1 : 0;
      3'b111:  branchE = ltuE ? 0 : 1;
      default: branchE = 0;
    endcase
  end

  assign pc_selE = EXin.jump | (EXin.branch & branchE);

  mux_2to1 pc_target_mux (
      .out(pc_target_ip),
      .a(EXin.pc),
      .b(EXin.reg_read1),
      .select(EXin.pc_target_sel)
  );

  assign pc_targetE = pc_target_ip + EXin.imm_ext;

  assign EXout.reg_write = EXin.reg_write,
      EXout.result_sel = EXin.result_sel,
      EXout.mem_write = EXin.mem_write,
      EXout.funct3 = EXin.funct3,
      EXout.exception_cause = EXin.exception_cause,
      EXout.halt = EXin.halt,
      EXout.pc = EXin.pc,
      EXout.reg_rd = EXin.reg_rd,
      EXout.pc_target = pc_targetE,
      EXout.imm_ext = EXin.imm_ext,
      EXout.pcplus4 = EXin.pcplus4;

  // Execute to Memory pipeline register
  always_ff @(posedge clk) begin
    if(hazard_controls.flushM) MEMin <= '0;  // active-high clear
    else MEMin <= EXout;
  end

  //========================================
  // MEMORY
  //========================================

  data_mem d_mem1 (
      .read(MEMout.data_read),
      .addr(MEMin.alu_result),
      .wd(MEMin.write_data),
      .funct3(MEMin.funct3),
      .we(MEMin.mem_write),
      .clk(clk)
  );

  assign MEMout.reg_write = MEMin.reg_write,
      MEMout.result_sel = MEMin.result_sel,
      MEMout.exception_cause = MEMin.exception_cause,
      MEMout.halt = MEMin.halt,
      MEMout.alu_result = MEMin.alu_result,
      MEMout.pc = MEMin.pc,
      MEMout.reg_rd = MEMin.reg_rd,
      MEMout.pc_target = MEMin.pc_target,
      MEMout.imm_ext = MEMin.imm_ext,
      MEMout.pcplus4 = MEMin.pcplus4;

  // Memory to Writeback pipeline register
  always_ff @(posedge clk) begin
    if(~hazard_controls.stallW) WBin <= MEMout;
  end

  //========================================
  // WRITEBACK
  //========================================

  mux_5to1 result_mux (
      .out(resultW),
      .a(WBin.alu_result),
      .b(WBin.data_read),
      .c(WBin.pcplus4),
      .d(WBin.imm_ext),
      .e(WBin.pc_target),
      .select(WBin.result_sel)
  );
    
  //========================================
  // HAZARD UNIT & CSR BLOCK
  //========================================

  hazard_unit hazard_unit1 (
      .hazard_controls(hazard_controls),
      .rs1D(IDout.reg_rs1),
      .rs2D(IDout.reg_rs2),
      .rs1E(EXin.reg_rs1),
      .rs2E(EXin.reg_rs2),
      .rdE(EXin.reg_rd),
      .rdM(MEMin.reg_rd),
      .rdW(WBin.reg_rd),
      .result_selE(EXin.result_sel),
      .pc_selE(pc_selE),
      .reg_writeM(MEMin.reg_write),
      .reg_writeW(WBin.reg_write),
      .haltW(WBin.halt)
  );


    csr_block csr_block1 (
        .pcW(WBin.pc),
        .exception_causeW(WBin.exception_cause),
        .haltW(WBin.halt)
    );

endmodule
