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
  output reg [`W_CPU-1:0] data_out,

  // SPI
  output reg SPI_out,
  input      SPI_in,
  output     SPI_clk,
  output reg SPI_cs);

  /** Storage Element **/
  reg [`W_CPU-1:0] rf [31:0];

  // Main SPI logic
  always @* begin
    // Updates register for spi to check if MOSI is done
    if(transmit_ready) begin
      rf[`REG_MOSI_TR] = 1'b1;
    end
    else begin
      rf[`REG_MOSI_TR] = 1'b0;
    end

    // Updates register for spi to check if MISO is done
    if(receive_ready) begin
      rf[`REG_MISO_DV] = 1'b1;
    end
    else begin
      rf[`REG_MISO_DV] = 1'b0;
    end

    case (ctrl)
      `MT: begin // MTC0
        rf[addr] = wd; // Writes data from cpu to spi register
        data_out = 0; // No data is written back to CPU

        // Tells MOSI module to begin sending data
        if(rf[`REG_MOSI_S] == 1 && transmit_ready) begin
          MOSI_data = rf[`REG_MOSI];
          rf[`REG_MOSI_S] = 1'b0;
          transmit_start = 1'b1;
        end
        // Ensures that MOSI module doesn't suddenly restart
        else begin
          transmit_start = 1'b0;
        end
      end

      `MF: begin // MFC0
        rf[`REG_MISO] = MISO_data;

        // Tells MISO module when to begin receiving data
        if(rf[`REG_T7] == 1) begin
          receive_start = 1'b1;
          rf[`REG_T7] = 1'b0;
          data_out = rf[`REG_MISO];
          #10;
        end
        // Ensures that MISO module doesn't suddenly restart
        else begin
          data_out = rf[addr];
          receive_start = 1'b0;
        end
      end
      default: begin data_out = 0; end
    endcase
  end


  /*---------------
  ------MOSI-------
  ---------------*/
  // 1 when SPI device is ready to send a message, 0 otherwise
  reg reg transmit_ready;
  // Message being sent from the device.
  reg [`W_CPU-1:0] MOSI_data;
  // Blipped to begin sending message
  reg  transmit_start;

  //SPI in/output
  reg MOSI_out;

  mosi MOSI(rst, clk, transmit_ready,
            MOSI_data, transmit_start, MOSI_out);


  /*---------------
  ------MISO-------
  ---------------*/
  // 1 when SPI device is ready to receive a message, 0 otherwise
  reg receive_ready;
  // MISO data received from external device
  reg [`W_CPU-1:0] MISO_data;
  // Blipped to begin receiving message
  reg receive_start;

  //SPI in/output
  reg MISO_in; // MISO bits being received from external device

  miso MISO(rst, clk, receive_ready,
            MISO_data, receive_start,
            MISO_in);

  // Update later to reflect actual SPI clock speeds
  assign SPI_clk = clk;
  always @* begin
    SPI_out = MOSI_out;
    MISO_in = SPI_in;

    // Controls chip select to ensure external device is ready to send or receive
    if ((rf[`REG_MISO_DV] == 0) || (rf[`REG_MOSI_TR] == 0)) begin
      SPI_cs = 1'b0;
    end
    else begin
      SPI_cs = 1'b1;
    end
  end


  // Used for debugging
  reg [`W_CPU-1:0] MOSI_out_check;

  always @(posedge clk,posedge rst) begin
    if (rst) begin
      for(int i = 0; i<32; i=i+1)
        rf[i] = 0;
    end
    else begin
      #2
      if (`DEBUG_REGFILE_SPI) begin
        /* verilator lint_off STMTDLY */
         // Delay slightly to correct print timing issue
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

      if (`DEBUG_MOSI) begin
        MOSI_out_check = {MOSI_out_check[30:0], MOSI_out};
        $display("WD: %b", wd);
        $display("TRANS READY:  %b", transmit_ready);
        $display("TRANS START:  %b", transmit_start);
        $display("MOSI TR:      %b", rf[`REG_MOSI_TR]);
        $display("REG MOSI:     %b", rf[`REG_MOSI]);
        $display("REG MOSI S:   %b", rf[`REG_MOSI_S]);
        $display("MOSI OUT:     %b", MOSI_out);
        $display("MOSI OUT C:   %b", MOSI_out_check);
      end

      if (`DEBUG_MISO) begin
        $display("RECEIVE READY: %b", receive_ready);
        $display("RECEIVE START: %b", receive_start);
        $display("MISO RR:       %b", rf[`REG_MISO_DV]);
        $display("REG MISO:      %b", rf[`REG_MISO]);
        $display("REG MISO S:    %b", rf[`REG_MISO_S]);
        $display("MISO IN:       %b", MISO_in);
        $display("MISO IN C:     %b", data_out);
      end
    end

  end

  // assign spi_out = (ra != 0) ? rf[ra]:0;
  // assign  rd1 = (ra1 != 0) ? rf[ra1]:0;
  // assign  rd2 = (ra2 != 0) ? rf[ra2]:0;

endmodule
