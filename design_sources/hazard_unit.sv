import definitions::*;

module hazard_unit (
    output hazard_controls_t hazard_controls,
    input logic [4:0] rs1D,
    rs2D,
    rs1E,
    rs2E,
    rdE,
    rdM,
    rdW,
    input logic [2:0] result_selE,
    input logic pc_selE,
    reg_writeM,
    reg_writeW,
    haltW
);
  logic lwStall;
  always_comb begin
    if (((rs1E == rdM) & reg_writeM) & rs1E != 0) hazard_controls.forwardAE = 2'b10;
    else if (((rs1E == rdW) & reg_writeW) & rs1E != 0) hazard_controls.forwardAE = 2'b01;
    else hazard_controls.forwardAE = 2'b00;

    if (((rs2E == rdM) & reg_writeM) & rs2E != 0) hazard_controls.forwardBE = 2'b10;
    else if (((rs2E == rdW) & reg_writeM) & rs2E != 0) hazard_controls.forwardBE = 2'b01;
    else hazard_controls.forwardBE = 2'b00;

    case (result_selE)
      3'b001, 3'b011, 3'b100: lwStall = 1'b1;
      default: lwStall = 1'b0;
    endcase
  end

  assign hazard_controls.stallF = lwStall | haltW,
      hazard_controls.stallD = lwStall,
      hazard_controls.stallW = haltW,
      hazard_controls.flushD = pc_selE | haltW,
      hazard_controls.flushE = lwStall | pc_selE | haltW,
      hazard_controls.flushM = haltW;

endmodule
