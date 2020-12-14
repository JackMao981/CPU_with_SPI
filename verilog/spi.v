`include "lib/opcodes.v"

module miso (
  // Same inputs from CPU
  input rst,
  input clk,

  // the data and its signal  (MOSI)
  output reg receive_ready, // set to 1 when SPI device is ready to send a new byte

  // (MISO)
  output reg [W_Data-1:0] data_in,
  output reg data_in_valid, // goes high once data has been fully received

  //SPI in/output
  input MISO_in,
  output spi_clk);

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;

  assign spi_clk = clk;

  // MISO
  reg [W_Counter-1:0] MISO_counter;
  always @(posedge clk or negedge rst)
  begin
    if (rst)
    begin
      data_in <= 1'd0;
      data_in_valid <= 1'b0;
      MISO_counter <= 5'b11111;
      receive_ready = 1'b1; // maybe replace with receive ready
    end

    else
    begin
      if (receive_ready) // keep an eye on this
      begin
        MISO_counter <= 5'b11111;
        receive_ready = 1'b0;
      end
      else
      begin
        data_in[MISO_counter] <= MISO_in;
        MISO_counter <= MISO_counter - 1;
        if (MISO_counter == 0) begin
          data_in_valid = 1'b1;
        end
      end
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
  output spi_clk,
  output reg MOSI_out); //CHECK THIS LATER

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;

  // reg transmit_ready; // can set transmit ready to input
  assign spi_clk = clk;

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
        // if(data_transmit_valid)
        // begin
        //   MOSI_out <= data_to_transmit[MOSI_counter];
        //   MOSI_counter <= MOSI_counter - 1;
        //   send_data <= 1'b1;
        //   transmit_ready = 1'b0;
        //   end
        // if(send_data)
        // begin
        //   MOSI_out <= data_to_transmit[MOSI_counter];
        //   MOSI_counter <= MOSI_counter - 1;
        //   if (MOSI_counter == 1) begin
        //
        //     transmit_ready = 1'b1;
        //     $display("REFGILE TR: %b", transmit_ready);
        //     MOSI_counter <= 5'b11111;
        //     send_data <= 1'b0;
        //   end
        //   else begin
        //     transmit_ready <= 1'b0;
        //   end
        // end
    end
  end
  always @(posedge clk or negedge rst)
  begin
  #2
    $display("MOSI COUNTER: %d", MOSI_counter);
  end

endmodule


/*
PSUEDOCODE

//loads MOSI data
at posedge
  if reset
    reset transmit byte
    reset data valid
  else
    wait a hot sec for data to load
    load data to transmit into register so it doesnt get lost later

// creates MOSI data
at posedge
  if reset
    reset output bit
    reset current bit index counter
  else
    if send new data
      start with MSB
    else
      count down from MSB to LSB
      send each bit

// Read MISO data
at posedge
  if reset
    set byte to Zero
    set data valid pulse to Zero
    set bit count to MSB
  else
    if receive new data
      retrieve each bit
      count down from MSB to LSB
      if done (bit count is zero)
        set data valid pulse to one (says that data is finished being received)
*/
