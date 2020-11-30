// include stuff?

module spi (
  // Same inputs from CPU
  input rst,
  input clk,

  // clock phase and polarity ignoring for now for simplification
  // currently looking at rising edge
  // input CPHA,
  // input CPOL,

  // the data and its signal  (MOSI)
  output reg transmit_ready, // set to 1 when SPI device is ready to send a new byte
  input [W_Byte-1:0] data_to_transmit, // 8 bit data being sent from device
  input data_out_valid, // blipped when new data is loaded and ready

  // (MISO)
  output reg [W_Byte-1:0] data_in, // maybe reg?
  output reg data_in_valid, // goes high once data has been fully received

  //SPI in/output
  output reg MOSI_out, // the bit that you send out
  output reg MISO_in,


);

  parameter W_Byte = 8;

//Loads Mosi Data
//stores data being sent to prevent data loss from glitches
reg [W_Byte-1:0] data_out_buffer;
reg data_out_valid_buffer;

always @(posedge clk or negedge rst)
begin
  //Catches reset case
  if (~rst)
  begin
    data_out_buffer <= 8'h00;
    data_out_valid_buffer <= 1'b0;
  end

  //Delays for one clock pulse before sending data
  else
  begin
    data_out_valid_buffer <= data_out_valid;
    if (data_out_valid)
    begin
      data_out_buffer <= data_to_transmit;
    end
  end
end


//Creates MOSI_data
//Keeps track of current bit being sent
reg [W_Byte-1:0] MOSI_counter;

always @(posedge clk or negedge rst)
begin
  //Catches reset case
  if (~rst)
  begin
    MOSI_out <= 1'b0;
    MOSI_counter <= 3'b111;
  end
  //Sends current index bit
  else
  begin
    if(transmit_ready) // if device is ready to send new data
    begin
      MOSI_counter <= 3'b111;
    end
    else
    begin
      //if data being passed in is valid
      if(data_out_valid)
      begin
        MOSI_out <= data_out_buffer[MOSI_counter];
        MOSI_counter <= MOSI_counter - 1;
        if (MOSI_counter == 3'b000)
        begin
          transmit_ready <= 1'b1;
        end
      end
    end
  end
end

// MISO
reg [W_Byte-1:0] MISO_counter;
always @(posedge clk or negedge rst)
begin
  if (~rst)
  begin
    data_in <= 1'd0;
    data_in_valid <= 1'b0;
    MISO_counter <= 3'b111;
  end

  else
  begin
    if (transmit_ready)
    begin
      MISO_counter <= 3'b111;
    end
    else
    begin
      data_in[MISO_counter] <= MISO_in;
      MISO_counter <= MISO_counter - 1;
    end
  end
end

// SS??????

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
