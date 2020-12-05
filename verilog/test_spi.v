`include "fake_spi.v"
`include "lib/opcodes.v"
// Testbench for Full Adder
module test_spi ();
  // Regs and wires for input/output
  // input clk,
  //
  // input clk,
  // input [7:0] data_in,
  // input [`W_SPI_MODE-1:0] control_rd,
  // output reg [7:0] data_out,
  // output dv_data_out,
  //
  // output reg dv_miso,
  // output reg [7:0] data_miso,
  // output reg dv_mosi,
  // output reg [7:0] data_mosi);
  reg [7:0] data_in;
  reg [`W_SPI_MODE-1:0] control_rd;
  reg [7:0] data_out;
  reg dv_data_out;

  reg dv_miso;
  reg [7:0] data_miso;
  reg dv_mosi;
  reg [7:0] data_mosi;

  reg clk;
  initial clk=0;
  always #10 clk = !clk;

  //Instantiate your "Device Under Test"
  FAKE_SPI_CONTROL DUT(clk, 8'b00001111, `SPI_RECEIVE, data_out, dv_data_out,
                       dv_miso, data_miso, dv_miso, data_mosi);

  initial begin
    // Hooks for vvp/gtkwave
    // the *.vcd filename should match the *.v filename for Makefile cleanliness
    $dumpfile("test_spi.vcd");
    $dumpvars(0,test_spi);

    //Your Code Here!
    $display("dv_miso %b", dv_miso);
    $display("dv_data_out %b", dv_data_out);
    $display("data_out %b", data_out);
    $display("-------------");


  end
endmodule
