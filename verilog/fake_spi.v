// `include "lib/opcodes.v"
`timescale 1ns / 1ps

// fake_spi
module FAKE_SPI_CONTROL
  (input clk,
  input [7:0] data_in,
  input [2-1:0] control_rd,
  output reg [7:0] data_out,
  output reg dv_data_out,

  output reg dv_miso,
  output reg [7:0] data_miso,
  output reg dv_mosi,
  output reg [7:0] data_mosi);

  always @* begin
  $display("SPI MODE: %b", control_rd);
    case (control_rd)
      2'b00:
      begin
        $display("DATA SENT (MOSI)");
        // print data_mosi to verify data was sent properly
        data_mosi = data_in;
      end
      2'b10:
      begin
        $display("DATA RECEIVED (MISO)");
        // print data_miso from register in CPU
        data_miso = 8'b00001111;
        dv_miso = 1'b1;
        // #50
        data_out = data_miso;
      end
      default: begin   $display("DEFAULT CASE HIT");
        data_miso = 8'b00001111;
        dv_data_out = 1'b1;
        // #50
        data_out = data_miso;
      end
    endcase
  end

endmodule
