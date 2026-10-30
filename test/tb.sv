`timescale 1ns / 1ps

module tb;

  logic clk, reset;

  top dut (
      .clk  (clk),
      .reset(reset)
  );

  initial begin
    clk = 0;
    forever #5ns clk = ~clk;
  end

  initial begin
    $display("started");
    reset = 1;
    $readmemh("./test/testbench_machine_code.txt", dut.i_mem1.mem);
    $dumpfile("wave.vcd");
    $dumpvars(0, dut);
    #17ns reset = 0;
  end

  always @(posedge clk) begin
    if (dut.IFout.pc == 32'h84 && dut.pcF_next == 32'h7C) begin  // pc is looping 
      if (dut.reg_file1.r_file[5'd2] == 32'h68 && dut.reg_file1.r_file[5'd8] == 32'd256) begin
        $display("Success, wooohooooo");
        $stop;
      end else $display("Failure");
    end
  end

endmodule
