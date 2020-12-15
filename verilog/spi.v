`include "lib/opcodes.v"

module miso (
  // Same inputs from CPU
  input rst,
  input clk,

  output reg receive_ready, // 1 when SPI device is ready to receive a new message
  output reg [W_Data-1:0] data_in, // Stores incoming data
  input      receive_start, // Blipped to start receiving data

  //SPI in/output
  input MISO_in);

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;

  // MISO
  reg [W_Counter-1:0] MISO_counter; // Keeps track of current bit being received
  reg receive_data; // 1 when data is currently being received


  always @(posedge clk or negedge rst)
  begin
    if (rst)
    begin
      receive_ready <= 1'b1;
      MISO_counter <= 5'b11111;
    end

    else
    begin
      // Starts receiving message
      if (receive_start)
      begin
        receive_data = 1'b1;
        receive_ready = 1'b0;
        data_in[MISO_counter] = MISO_in; //will be floating at some points
        MISO_counter <= MISO_counter - 1;
      end

      // Receives message bit by bit
      if (receive_data) begin
        data_in[MISO_counter] = MISO_in; //will be floating at some points
        MISO_counter <= MISO_counter - 1;

        // Exits once data is fully received
        if (MISO_counter == 0) begin

          if (`DEBUG_SPI_OUT) begin
            $display("DATA RECEIVED");
          end

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
  output reg transmit_ready, // 1 when SPI device is ready to send new message
  input [W_Data-1:0] data_to_transmit, // Message being sent from device
  input  transmit_start, // Blipped to start sending message

  //SPI in/output
  output reg MOSI_out);

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;


  reg [W_Counter-1:0] MOSI_counter; //Keeps track of current bit being sent
  reg send_data; // 1 when data is currently being sent

  always @(posedge clk or negedge rst)
  begin
    if (rst)
    begin
      MOSI_out <= 1'b0;
      MOSI_counter <= 5'b11111;
      transmit_ready = 1'b1;
    end

    //Sends message bit by bit
    else
    begin
      // Starts message sending process
      if(transmit_start) begin
        send_data = 1'b1;
        transmit_ready = 1'b0;
      end

      if(send_data) begin
        MOSI_out <= data_to_transmit[MOSI_counter];
        MOSI_counter <= MOSI_counter - 1;

        // Exits once data is fully sent
        if(MOSI_counter == 0) begin

          if(`DEBUG_SPI_OUT) begin
            $display("DATA SENT");
          end
          
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
