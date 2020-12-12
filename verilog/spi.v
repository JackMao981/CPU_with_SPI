`include "lib/opcodes.v"

module spi (
  // Same inputs from CPU
  input rst,
  input clk,

  // clock phase and polarity ignoring for now for simplification
  // currently looking at rising edge
  // input CPHA,
  // input CPOL,

  // the data and its signal  (MOSI)
  output reg transmit_ready_MOSI, // set to 1 when SPI device is ready to send a new byte
  output reg transmit_ready_MISO,
  input [W_Data-1:0] data_to_transmit, // 8 bit data being sent from device
  input data_transmit_valid, // blipped when new data is loaded and ready

  // (MISO)
  output reg [W_Data-1:0] data_in, // maybe reg?
  output reg data_in_valid, // goes high once data has been fully received

  //SPI in/output
  input MISO_in,
  output spi_clk,
  output reg MOSI_out // the bit that you send out
  ); //CHECK THIS LATER

  parameter W_Data = `W_CPU;
  parameter W_Counter = 5;

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

always @(posedge clk or negedge rst)
begin
  //Catches reset case
  if (rst)
  begin
    MOSI_out <= 1'b0;
    MOSI_counter <= 5'b11111;
    transmit_ready_MOSI = 1'b1;
  end
  //Sends current index bit
  else
  begin
    if(transmit_ready_MOSI) // if device is ready to send new data
    begin
      MOSI_counter <= 5'b11111;
    end
    else
    begin
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
        end
      end
    end
  end
end

// MISO
reg [W_Counter-1:0] MISO_counter;
always @(posedge clk or negedge rst)
begin
  if (rst)
  begin
    $display("rst  = %x",rst);
    data_in <= 1'd0;
    data_in_valid <= 1'b0;
    MISO_counter <= 5'b11111;
    transmit_ready_MISO = 1'b1; // maybe replace with receive ready
  end

  else
  begin
    if (transmit_ready_MISO) // keep an eye on this
    begin
      // $display("transmit ready  = %x",transmit_ready);
      MISO_counter <= 5'b11111;
      transmit_ready_MISO = 1'b0;
    end
    else
    begin
      data_in[MISO_counter] <= MISO_in;
      MISO_counter <= MISO_counter - 1;
      // $display("counter  = %x",MISO_counter);
      if (MISO_counter == 0) begin
        data_in_valid = 1'b1;
      end
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
