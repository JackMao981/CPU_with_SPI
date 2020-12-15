`include "lib/opcodes.v"

module miso (
  // Same inputs from CPU
  input rst,
  input clk,

  // the data and its signal  (MOSI)
<<<<<<< HEAD
  output reg transmit_ready_MOSI, // set to 1 when SPI device is ready to send a new byte
  output reg transmit_ready_MISO,
  input [W_Data-1:0] data_to_transmit, // 8 bit data being sent from device
  input data_transmit_valid, // blipped when new data is loaded and ready

  // (MISO)
  output reg [W_Data-1:0] data_in, // maybe reg?
  output reg data_in_valid, // goes high once data has been fully received
=======
  output reg receive_ready, // set to 1 when SPI device is ready to receive a new byte
  output reg [W_Data-1:0] data_in,
  input      receive_start, // goes high once data has been fully received
>>>>>>> mosi-v2

  //SPI in/output
  input MISO_in);

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;

<<<<<<< HEAD
//Loads Mosi Data
//stores data being sent to prevent data loss from glitches
reg [W_Data-1:0] data_out_buffer;
reg data_transmit_valid_buffer;
// reg transmit_ready; // can set transmit ready to input
assign spi_clk = clk;

always @(posedge clk or negedge rst)
begin
  //Catches reset case
  if (rst)
  begin
    data_out_buffer <= 8'h00;
    data_transmit_valid_buffer <= 1'b0;
    transmit_ready_MOSI = 1'b1;
  end

  //Delays for one clock pulse before sending data
  else
  begin
     data_transmit_valid_buffer <=  data_transmit_valid;
    if ( data_transmit_valid)
    begin
      data_out_buffer <= data_to_transmit;
      transmit_ready_MOSI = 1'b0;
    end
  end
end


//Creates MOSI_data
//Keeps track of current bit being sent
reg [W_Counter-1:0] MOSI_counter;
=======
  // MISO
  reg [W_Counter-1:0] MISO_counter;
  reg receive_data;
>>>>>>> mosi-v2

  always @(posedge clk or negedge rst)
  begin
<<<<<<< HEAD
    MOSI_out <= 1'b0;
    MOSI_counter <= 5'b11111;
    transmit_ready_MOSI = 1'b1;
  end
  //Sends current index bit
  else
  begin
    if(transmit_ready_MOSI) // if device is ready to send new data
=======
    if (rst)
>>>>>>> mosi-v2
    begin
      receive_ready <= 1'b1;
      MISO_counter <= 5'b11111;
    end
    else
    begin
<<<<<<< HEAD
      $display("data_transmit_valid_buffer: %b", data_transmit_valid_buffer);
      //if data being passed in is valid
      if(data_transmit_valid_buffer)
      begin
        MOSI_out <= data_out_buffer[MOSI_counter];
        $display("REG MOSI OUT: %b", MOSI_out);
        MOSI_counter <= MOSI_counter - 1;
        $display("MOSI counter  = %x",MOSI_counter);
        if (MOSI_counter == 0)
        begin
          transmit_ready_MOSI <= 1'b1;
        end
        else begin
          transmit_ready_MOSI <= 1'b0;
=======
      if (receive_start) // keep an eye on this
      begin
        receive_data = 1'b1;
        receive_ready = 1'b0;
        data_in[MISO_counter] = MISO_in; //will be floating at some points
        MISO_counter <= MISO_counter - 1;
      end

      if (receive_data) begin
        data_in[MISO_counter] = MISO_in; //will be floating at some points
        MISO_counter <= MISO_counter - 1;
        if(MISO_counter == 0) begin
          $display("DATA RECEIVED");
          receive_ready = 1'b1;
          MISO_counter <= 5'b11111;
          receive_data = 1'b0;
>>>>>>> mosi-v2
        end
      end
    end
  end

  always @(posedge clk or negedge rst)
  begin
<<<<<<< HEAD
    $display("rst  = %x",rst);
    data_in <= 1'd0;
    data_in_valid <= 1'b0;
    MISO_counter <= 5'b11111;
    transmit_ready_MISO = 1'b1; // maybe replace with receive ready
=======
    if(`DEBUG_MISO) begin
      #2
      $display("MISO COUNTER: %d", MISO_counter);
    end
>>>>>>> mosi-v2
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
<<<<<<< HEAD
    if (transmit_ready_MISO) // keep an eye on this
    begin
      // $display("transmit ready  = %x",transmit_ready);
      MISO_counter <= 5'b11111;
      transmit_ready_MISO = 1'b0;
=======
    //Catches reset case
    if (rst)
    begin
      MOSI_out <= 1'b0;
      MOSI_counter <= 5'b11111;
      transmit_ready = 1'b1;
>>>>>>> mosi-v2
    end
    //Sends current index bit
    else
    begin
<<<<<<< HEAD
      data_in[MISO_counter] <= data_to_transmit[MISO_counter];
      MISO_counter <= MISO_counter - 1;
      // $display("counter  = %x",MISO_counter);
      if (MISO_counter == 0) begin
        data_in_valid = 1'b1;
=======
      if(data_transmit_valid) begin
        send_data = 1'b1;
        transmit_ready = 1'b0;
        // MOSI_out <= data_to_transmit[MOSI_counter];
        // MOSI_counter <= MOSI_counter - 1;

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
>>>>>>> mosi-v2
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
