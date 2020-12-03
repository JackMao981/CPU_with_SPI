`include "fetch.v"
`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "memory.v"
`include "fake_spi.v"

`timescale 1ns / 1ps

module SINGLE_CYCLE_CPU
  (input clk,
   input rst);

  // memory
  // Read port for instructions
  reg [`W_CPU-1:0] PC;		// Program counter (instruction address)
  reg [`W_CPU-1:0] inst;

  // Read/write port for data
  reg [`W_MEM_CMD-1:0] mem_cmd; // Mem Command
  reg [`W_CPU-1:0]     rd2;
  reg [`W_CPU-1:0]     data_addr;
  reg [`W_CPU-1:0]     dataOut;
  MEMORY stage_MEMORY(clk, rst, PC, inst,
                      mem_cmd, rd2, data_addr, dataOut); //connect these wires

  reg [`W_REG-1:0]     wa;      // Register Write Address
  reg [`W_REG-1:0]     ra1;     // Register Read Address 1
  reg [`W_REG-1:0]     ra2;     // Register Read Address 2
  reg                  reg_wen; // Register Write Enable
  // Immediate
  reg [`W_IMM_EXT-1:0] imm_ext; // 1-Sign or 0-Zero extend
  reg [`W_IMM-1:0]     imm;     // Immediate Field
  // Jump Address
  reg [`W_JADDR-1:0]   jump_addr;    // Jump Addr Field
  // ALU Control
  reg [`W_FUNCT-1:0]   alu_op;  // ALU OP
  // Muxinginput control_rd,input control_rd,
  reg [`W_PC_SRC-1:0] pc_src;
  reg [`W_EN-1:0] branch_ctrl;

  reg [`W_ALU_SRC-1:0] alu_src; // ALU Source
  reg [`W_REG_SRC-1:0] reg_src;
  reg [`W_SPI_MODE-1:0] spi_mode;
  DECODE decode(inst, wa, ra1, ra2,
                reg_wen, imm_ext, imm,
                jump_addr, alu_op, spi_mode, pc_src,
                mem_cmd, alu_src, reg_src);

  reg isZero;
  reg [`W_CPU-1:0] rd1;
  FETCH fetch(clk, rst, pc_src, branch_ctrl, rd1, jump_addr, imm, PC);

  reg [`W_CPU-1:0] wd;
  REGFILE regfile(clk, rst, reg_wen, wa, wd, ra1, ra2, rd1, rd2);


// input clk,
// input reg [7:0] data_in,
// input control_rd,
// output reg [7:0] data_out,
// output dv_data_out,
//
  reg dv_miso;
  reg [7:0] data_miso;
  reg dv_mosi;
  reg [7:0] data_mosi;
  reg [7:0] spi_out;
  reg spi_dv;
  FAKE_SPI_CONTROL fake_spi_control(clk, 8'b00001111, spi_mode, spi_out,
                                    spi_dv, dv_miso, data_miso,
                                    dv_mosi, data_mosi);


  always @* begin
    $display ("MODE: %b", spi_mode);
  end

  //immediate mux
  reg [`W_CPU-1:0] ALUSrcOut;
  always @* begin
    case (alu_src)
      `ALU_SRC_REG :
        begin
          ALUSrcOut = rd2; // get data from db
        end
      `ALU_SRC_IMM :
        begin
          // get data from immediate
          case(imm_ext)
            `IMM_ZERO_EXT: begin ALUSrcOut = {{16{1'b0}}, {imm}}; end
            `IMM_SIGN_EXT: begin ALUSrcOut = {{16{imm[15]}}, {imm}}; end
          endcase
        end
      `ALU_SRC_SHA :
        begin
          ALUSrcOut = inst[`FLD_SHAMT];//{{27{1'b0}}, {inst[`FLD_SHAMT]}}; // SHAMT HERE
        end
    endcase
  end

  reg [`W_CPU-1:0] aluOut;
  reg carryOut;

  ALU alu(alu_op, rd1, ALUSrcOut, aluOut, carryOut, isZero);
  assign data_addr = aluOut;

  // handles selecting BNE vs BEQ case
  always @* begin
    case(inst[`FLD_OPCODE])
    // checks if BNE or BEQ and sets branch_ctrl accordingly
      `BEQ: begin branch_ctrl = isZero; end
      `BNE: begin branch_ctrl = ~isZero; end

      default: branch_ctrl = isZero;
    endcase
  end

  reg [`W_CPU-1:0] wd_inter;

  always @* begin
    case (reg_src)
      `REG_SRC_ALU :
        begin
          wd_inter = aluOut;
        end
      `REG_SRC_MEM :
        begin
          wd_inter = dataOut; // from data memory
        end
      `REG_SRC_PC :
        begin
          wd_inter = aluOut; // REG_SRC_PC HERE
          // MAYBE branch address????
        end
    endcase

    case(spi_mode) // handles choosing between spi data and cpu data
      `SPI_RECEIVE: // miso case
      begin
      $display("DATA RECEIVED");
        wd = spi_out;
      end
      default: wd = wd_inter;
    endcase
  end

  //SYSCALL Catch
  always @(posedge clk) begin
    //Is the instruction a SYSCALL?
    if (inst[`FLD_OPCODE] == `OP_ZERO &&
        inst[`FLD_FUNCT]  == `F_SYSCAL) begin
        case(rd1)
          1 : $display("SYSCALL  1: a0 = %x",rd2);
          10: begin
              $display("SYSCALL 10: Exiting...");
              $finish;
            end
          default:;
        endcase
    end
  end

endmodule
