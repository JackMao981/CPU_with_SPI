// fake_spi
module fake_spi_control
  (input clk,

  input reg [7:0] data_in,
  input control_rd,
  output reg [7:0] data_out,
  output dv_data_out,

  input dv_miso,
  input reg [7:0] data_miso,
  output dv_mosi,
  output reg [7:0] data_mosi);

  if (control_rd == 0)
  begin
    // print data_mosi to verify data was sent properly
    assign data_mosi <= data_in;
  end
  else if (control_rd == 1)
  begin
    // print data_miso from register in CPU
    assign data_miso <= 8'b10101010;
    #12
    assign data_out <= data_miso;
  end

endmodule
