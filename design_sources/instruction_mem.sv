module instruction_mem (
    output logic [31:0] read,
    input  logic [31:0] addr
);

  logic [31:0] mem[int];
  assign read = mem[addr[31:2]];

endmodule
