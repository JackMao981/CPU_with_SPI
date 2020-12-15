`include "cpu.v"
`timescale 1ns / 1ps

//------------------------------------------------------------------------
// Simple fake CPU testbench sequence
//------------------------------------------------------------------------

module cpu_test ();

  reg clk;
  reg reset;

  // Clock generation
  initial clk=0;
  always #10 clk = !clk;

  // Instantiate fake CPU
  SINGLE_CYCLE_CPU cpu(clk,reset);

  // Filenames for memory images and VCD dump file
  reg [1023:0] mem_inst_fn;
  reg [1023:0] mem_data_fn;
  reg [1023:0] vcd_dump_fn;
  reg init_data = 1;      // Initializing .data segment is optional

  // Test sequence
  initial begin
    // Get command line arguments for memory image(s) and VCD dump file
    //   http://iverilog.wikia.com/wiki/Simulation
    //   http://www.project-veripage.com/plusarg.php
    if (! $value$plusargs("mem_inst_fn=%s", mem_inst_fn)) begin
      $display("ERROR: provide +mem_inst_fn=[path to .inst.hex memory image] argument");
      $finish();
    end

    if (! $value$plusargs("mem_data_fn=%s", mem_data_fn)) begin
      $display("INFO: +mem_data_fn=[path to .data.hex memory image] argument not provided; data memory segment uninitialized");
      init_data = 0;
    end

    if (! $value$plusargs("vcd_dump_fn=%s", vcd_dump_fn)) begin
      $display("ERROR: provide +dump_fn=[path for VCD dump] argument");
      $finish();
    end


    // Load CPU memory from (assembly) dump files
    // Assumes compact memory map, _word_ addressed memory implementation
    //   -> .text segment starts at word address 0
    //   -> .data segment starts at word address 2048 (byte address 0x2000)
    $readmemh(mem_inst_fn, cpu.stage_MEMORY.mem, 0, 2047);
    if (init_data)
      $readmemh(mem_data_fn, cpu.stage_MEMORY.mem, 2048,4095);

    // Dump waveforms to file
    // Note: arrays (e.g. memory) are not dumped by default
    $dumpfile(vcd_dump_fn);
    $dumpvars();

    // Assert reset pulse
    reset = 0; #5;
    reset = 1; #10;
    reset = 0; #10;

    // End execution after some time delay - adjust to match your program
    // or use a smarter approach like looking for an exit syscall or the
    // PC to be the value of the last instruction in your program.
    /* verilator lint_off STMTDLY */
    #10000
    /* verilator lint_on STMTDLY */
    $display("Are you sure you should be running this long?");
    $finish();
    end
endmodule
