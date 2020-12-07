`include "lib/debug.v"
`include "lib/opcodes.v"
`timescale 1ns / 1ps

// Register file two read ports and one write port

module SPI_REGFILE
 (input                   clk,
  input                   rst,
  // input                   wren,
  input      [`W_REG-1:0] addr,
  input      [`W_CPU-1:0] wd,
  input      [`W_SPI_CTRL-1:0] ctrl,
  output reg              dv_spi,
  output reg [`W_CPU-1:0] spi_out);

  /** Storage Element **/
  reg [`W_CPU-1:0] rf [31:0];

  reg [1:0] ctrl_state;
  always @(posedge clk,posedge rst) begin
    if (rst) begin
      for(int i = 0; i<32; i=i+1)
        rf[i] = 0;
    end
    else begin

      if (ctrl == 1) begin // MOSI
        ctrl_state = 2'b01;
        rf[addr] = wd; // writes data from cpu to spi register
        dv_spi = 1'b0;
      end
      else if (ctrl == 2) begin // MISO
        ctrl_state = 2'b10;
        spi_out = 22;
        #6969
        dv_spi = 1'b1;
      end
      else begin // do nothing
        ctrl_state = 2'b00;
        dv_spi = 1'b0;
      end

      if (`DEBUG_REGFILE_SPI) begin
        /* verilator lint_off STMTDLY */
        #2 // Delay slightly to correct print timing issue
        /* verilator lint_on STMTDLY */
        $display("$0  = %x $at = %x $v0 = %x $v1 = %x",rf[`REG_0], rf[`REG_AT],rf[`REG_V0],rf[`REG_V1]);
        $display("$a0 = %x $a1 = %x $a2 = %x $a3 = %x",rf[`REG_A0],rf[`REG_A1],rf[`REG_A2],rf[`REG_A3]);
        $display("$t0 = %x $t1 = %x $t2 = %x $t3 = %x",rf[`REG_T0],rf[`REG_T1],rf[`REG_T2],rf[`REG_T3]);
        $display("$t4 = %x $t5 = %x $t6 = %x $t7 = %x",rf[`REG_T4],rf[`REG_T5],rf[`REG_T6],rf[`REG_T7]);
        $display("$s0 = %x $s1 = %x $s2 = %x $s3 = %x",rf[`REG_S0],rf[`REG_S1],rf[`REG_S2],rf[`REG_S3]);
        $display("$s6 = %x $s5 = %x $s6 = %x $s7 = %x",rf[`REG_S4],rf[`REG_S5],rf[`REG_S6],rf[`REG_S7]);
        $display("$t8 = %x $t9 = %x $k0 = %x $k1 = %x",rf[`REG_T8],rf[`REG_T9],rf[`REG_K0],rf[`REG_K1]);
        $display("$gp = %x $sp = %x $s8 = %x $ra = %x",rf[`REG_GP],rf[`REG_SP],rf[`REG_S8],rf[`REG_RA]);
      end
    end

  end

  // assign spi_out = (ra != 0) ? rf[ra]:0;
  // assign  rd1 = (ra1 != 0) ? rf[ra1]:0;
  // assign  rd2 = (ra2 != 0) ? rf[ra2]:0;

endmodule
