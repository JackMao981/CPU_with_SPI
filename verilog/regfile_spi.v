`include "lib/debug.v"
`include "lib/opcodes.v"
`include "spi.v"
`timescale 1ns / 1ps

// Register file two read ports and one write port

module SPI_REGFILE
 (input                   clk,
  input                   rst,
  // input                   wren,
  input      [`W_REG-1:0] addr,
  input      [`W_CPU-1:0] wd,
  input      [`W_SPI_CTRL-1:0] ctrl,
  output reg [`W_CPU-1:0] data_out);

  /** Storage Element **/
  reg [`W_CPU-1:0] rf [31:0];

  always @* begin
    case (ctrl)
      `MT: begin // MTC0
        rf[addr] = wd; // writes data from cpu to spi register
        data_out = 0; // no data is written back to CPU

        MOSI_data = rf[`REG_MOSI_S];
        rf[`REG_MOSI_TR] = transmit_ready;

        if((rf[`REG_MOSI] != rf[`REG_MOSI_S]) && transmit_ready) begin
          $display("HUH?: %b", (rf[`REG_MOSI] != rf[`REG_MOSI_S]));
          rf[`REG_MOSI_S] = rf[`REG_MOSI];
          MOSI_ready = 1'b1;
        end
        else begin
          MOSI_ready = 1'b0;
        end
      end

      `MF: begin // MFC0
        // Handles if MOSI register is overwritten
        if(addr == `REG_MISO) begin
          if(MISO_dv == 1'b1) begin
            rf[`REG_MISO] = MISO_data;
            data_out = rf[`REG_MISO];
            rf[`REG_MISO_DV] = 1'b1;
          end
          else begin
            rf[`REG_MISO_DV] = 1'b0;
          end
        end
        // Handles general move from case
        else begin
          data_out = rf[addr];
        end

      end
      default: begin data_out = 0; end
    endcase
  end

  always @(posedge clk) begin
    $display("TRANS READY:  %b", transmit_ready);
    $display("MOSI READY:   %b", MOSI_ready);
    $display("MOSI TR:      %h", rf[`REG_MOSI_TR]);
    $display("REG MOSI:     %b", rf[`REG_MOSI]);
    $display("REG MOSI S:   %b", rf[`REG_MOSI_S]);
    $display("MOSI OUT:     %b", MOSI_out);
  end

  /*---------------
  ------MOSI-------
  ---------------*/
  // the data and its signal  (MOSI)
  reg reg transmit_ready; // set to 1 when SPI device is ready to send a new byte
  reg [`W_CPU-1:0] MOSI_data; // 8 bit data being sent from device
  reg  MOSI_ready; // blipped when new data is loaded and ready

  //SPI in/output
  wire spi_clk;
  reg MOSI_out;

  mosi MOSI(rst, clk, transmit_ready,
            MOSI_data, MOSI_ready,
            spi_clk, MOSI_out);


  /*---------------
  ------MISO-------
  ---------------*/
  // Generates bits to read on MISO
  always @(posedge clk) begin
    if (MISO_in == 1'b1) begin
      MISO_in = 1'b0;
    end
    else begin
      MISO_in = 1'b1;
    end
  end

  reg MISO_dv; // goes high once data has been fully received
  reg MISO_in; // MISO bits being received from external device
  reg [`W_CPU-1:0] MISO_data; // loaded MISO data
  reg receive_ready; // notes when it's ready to receive more data

  miso MISO(rst, clk, receive_ready,
            MISO_data, MISO_dv,
            MISO_in, spi_clk);



  always @(posedge clk,posedge rst) begin
    if (rst) begin
      for(int i = 0; i<32; i=i+1)
        rf[i] = 0;
    end
    else begin

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
