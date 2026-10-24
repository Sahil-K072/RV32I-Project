module data_mem (
    output logic [31:0] read,
    input logic [31:0] addr,
    wd,
    input logic [2:0] funct3,
    input we,
    clk
);

  logic [3:0][7:0] mem[255:0];

  always_ff @(posedge clk) begin
    if(we) begin
      case(funct3)
      3'b00: mem[addr[31:2]][0] <= wd[7:0];
      3'b01: mem[addr[31:2]][1:0] <= wd[15:0];
      3'b10: mem[addr[31:2]] <= wd;
      default: mem[addr[31:2]] <= 'x;
      endcase
    end
  end

  always_comb begin
    case (funct3)
      3'b000:  read = {{24{mem[addr[31:2]][0][7]}}, mem[addr[31:2]][0]};
      3'b001:  read = {{16{mem[addr[31:2]][1][7]}}, mem[addr[31:2]][1:0]};
      3'b010:  read = mem[addr[31:2]];
      3'b011:  read = {{24{1'b0}}, mem[addr[31:2]][0]};
      3'b100:  read = {{16{1'b0}}, mem[addr[31:2]][1:0]};
      default: read = 'x;
    endcase
  end

endmodule
