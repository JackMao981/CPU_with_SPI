# Single Cycle CPU with SPI
For more information about this project as a whole, please see our website.
## Running the code
1. Head to this link and start a docker container: https://github.com/SSModelGit/DokerFiles/wiki/Class-Specific-Info
2. Run "sudo apt install default-jre" to install java
3. Run "git clone https://github.com/JackMao981/CPU_with_SPI.git" to clone the repository
4. Navigate to the "CPU_with_SPI" directory and run "make test_move"
  - To see more outputs, head to "verilog/lib/opcodes.v" and set values to 1 to have them output additional information. Otherwise, set values to 0 to hide their outputs.
  - To change data being sent using MOSI, adjust $t1 in lines 1-4 of "asm/move.asm".
  - To change data being received using MISO, adjust "data_to_receive" on line 166 of "verilog/cpu.v".
## About the code
This code was built on top of a single cycle CPU we had previously implemented. The primary goal of this project was to tack on SPI functionality. The files and code directly written for SPI is fairly well commented, so please see the code for clarifications.
### Single Cycle CPU
Because this project was not focused on implementing a single cycle CPU, enough information will be provided to orient you, but nothing more. The single cycle CPU used is based on the MIPS architecture. Only one instruction can be sent at a time, hence the the name, single cycle CPU. The file cpu.v handles a majority of the basic MIPS instructions, though a SPI module (lines 59-67) and SPI testing code (lines 158-207) have been added. Ignoring the SPI functionality, the CPU has a register file in which it can store 32 32-bit values, which can be used for various functions. The CPU will perform an action with these registers based on an instruction given. To better understand the data path, see these slides: https://www.cs.fsu.edu/~zwang/files/cda3101/Fall2017/Lecture5_cda3101.pdf. The primary use for the CPU in this project was in controlling a separate SPI module. By using different combinations of MFC0 (move from coprocess 0) and MTC0 (move to coprocess 0), data can be sent using the SPI protocol.
### SPI Implementation
Our main SPI module is built in "verilog/regfile_spi.v" where the "SPI_REGFILE" module handles MFC0 and MTC0 instructions. By moving specific values to predetermined registers in "SPI_REGFILE", SPI communication is initiated (see comments in "asm/move.asm" to instruction combinations needed to send and receive information). A 32 bit value is then either sent or received on MOSI or MISO respectively. Within "SPI_REGFILE", the modules (see "verilog/spi.v") "mosi" and "miso" are used. These handle sending and receiving data asynchronously once a start signal is sent from "SPI_REGFILE" (see comments in "verilog/spi.v" and "verilog/regfile_spi.v" for more details).
In "verilog/cpu.v" code for testing the SPI module has been added (see lines 158-207 for comments). This code will either begin listening or transmitting when a specific MOSI or MISO instruction is hit.
### Notes
  - Be careful with blocking and non blocking operations. Incorrect usage causes misaligned data sent and received through SPI.
  - If you build on this code, ensure that your assembly instructions are sending things to the correct registers prior to reworking code. Also, think very carefully about when data is being sent and read.
  - This implementation does not follow all SPI standards.
### Next Steps
Our code heavily relies on ideal simulation conditions to operate. To improve on this code, we would:
  1. Add a clock divider to decrease SPI clock speeds to more closely match real world values.
  2. Implement the project on an FPGA to ensure it works with hardware.
  3. Add error checking to ensure data does not contain any glitches.
  4. Verify that bits are being read at their centers, not edges.
## Attributions
Much of the code for the single cycle CPU was written by Jon Tse for the Fall 2020 Computer Architecture class at Olin College of Engineering.
