`include "lib/opcodes.v"
`include "lib/debug.v"

// fake_spi
module FAKE_SPI_CONTROL
  (input clk,

  input [7:0] data_in,
  input [`W_SPI_MODE-1:0] control_rd,
  output reg [7:0] data_out,
  output dv_data_out,

  output dv_miso,
  output reg [7:0] data_miso,
  output dv_mosi,
  output reg [7:0] data_mosi);

  always @* begin
    case (control_rd)
      `SPI_SEND:
      begin
        // print data_mosi to verify data was sent properly
        data_mosi = data_in;
      end
      `SPI_RECEIVE:
      begin
        // print data_miso from register in CPU
        data_miso = 8'b10101010;
        // #50
        data_out = data_miso;
      end
    endcase
  end

endmodule
