module reg_file (
    output logic [31:0] read1,
    read2,
    input logic [4:0] addr1,
    addr2,
    addr3,
    input logic [31:0] wd3,
    input we3,
    clk
);

  logic [31:0] r_file[31:0];
  assign r_file[0] = 32'b0;
  assign read1 = r_file[addr1], read2 = r_file[addr2];
  always_ff @(negedge clk) if (we3) r_file[addr3] <= wd3;

endmodule
