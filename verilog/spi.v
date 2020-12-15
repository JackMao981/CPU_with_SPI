`include "lib/opcodes.v"

module miso (
  // Same inputs from CPU
  input rst,
  input clk,

  // the data and its signal  (MOSI)
  output reg receive_ready, // set to 1 when SPI device is ready to receive a new byte
  output reg [W_Data-1:0] data_in,
  input      receive_start, // goes high once data has been fully received

  //SPI in/output
  input MISO_in);

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;

  // MISO
  reg [W_Counter-1:0] MISO_counter;
  reg receive_data;

  always @(posedge clk or negedge rst)
  begin
    if (rst)
    begin
      receive_ready <= 1'b1;
      MISO_counter <= 5'b11111;
    end
    else
    begin
      if (receive_start) // keep an eye on this
      begin
        receive_data = 1'b1;
        receive_ready = 1'b0;
      end

      if (receive_data) begin
        data_in[MISO_counter] = MISO_in; //will be floating at some points
        MISO_counter <= MISO_counter - 1;
        if(MISO_counter == 0) begin
          $display("DATA RECEIVED");
          receive_ready = 1'b1;
          MISO_counter <= 5'b11111;
          receive_data = 1'b0;
        end
      end
    end
  end

  always @(posedge clk or negedge rst)
  begin
    if(`DEBUG_MISO) begin
      #2
      $display("MISO COUNTER: %d", MISO_counter);
    end
  end
endmodule



module mosi (
  // Same inputs from CPU
  input rst,
  input clk,

  // the data and its signal  (MOSI)
  output reg transmit_ready, // set to 1 when SPI device is ready to send new message
  input [W_Data-1:0] data_to_transmit, // 8 bit data being sent from device
  input  data_transmit_valid, // blipped when new data is loaded and ready

  //SPI in/output
  output reg MOSI_out); //CHECK THIS LATER

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;

  //Keeps track of current bit being sent
  reg [W_Counter-1:0] MOSI_counter;
  reg send_data;

  always @(posedge clk or negedge rst)
  begin
    //Catches reset case
    if (rst)
    begin
      MOSI_out <= 1'b0;
      MOSI_counter <= 5'b11111;
      transmit_ready = 1'b1;
    end
    //Sends current index bit
    else
    begin
      if(data_transmit_valid) begin
        send_data = 1'b1;
        transmit_ready = 1'b0;
        MOSI_out <= data_to_transmit[MOSI_counter];
        MOSI_counter <= MOSI_counter - 1;

      end

      if(send_data) begin
        MOSI_out <= data_to_transmit[MOSI_counter];
        MOSI_counter <= MOSI_counter - 1;

        if(MOSI_counter == 0) begin
          $display("DATA SENT");
          transmit_ready = 1'b1;
          MOSI_counter = 5'b11111;
          send_data = 1'b0;
        end
      end
    end
  end
  always @(posedge clk or negedge rst)
  begin
    if(`DEBUG_MOSI) begin
      #2
      $display("MOSI COUNTER: %d", MOSI_counter);
    end
  end

endmodule
