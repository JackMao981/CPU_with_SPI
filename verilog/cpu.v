`include "fetch.v"
`include "decode.v"
`include "regfile.v"
`include "alu.v"
`include "memory.v"
`include "regfile_spi.v"

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

  reg [`W_SPI_CTRL-1:0] spi_ctrl;

  // Muxinginput control_rd,input control_rd,
  reg [`W_PC_SRC-1:0] pc_src;
  reg [`W_EN-1:0] branch_ctrl;

  reg [`W_ALU_SRC-1:0] alu_src; // ALU Source
  reg [`W_REG_SRC-1:0] reg_src;
  DECODE decode(inst, wa, ra1, ra2,
                reg_wen, imm_ext, imm,
                jump_addr, alu_op, spi_ctrl, pc_src,
                mem_cmd, alu_src, reg_src);

  reg isZero;
  reg [`W_CPU-1:0] rd1;
  FETCH fetch(clk, rst, pc_src, branch_ctrl, rd1, jump_addr, imm, PC);

  reg [`W_CPU-1:0] wd;
  REGFILE regfile(clk, rst, reg_wen, wa, wd, ra1, ra2, rd1, rd2);

  reg [`W_CPU-1:0] spi_out;
  // ra1: address to read in spi register
  // wa:  addres to write to in spi register
  // rd2: data to send to spi
  SPI_REGFILE spi_regfile(clk, rst, ra1, rd2, spi_ctrl, spi_out);

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
      `BEQ:  begin branch_ctrl = isZero; end
      `BNE:  begin branch_ctrl = ~isZero; end

      default: branch_ctrl = isZero;
    endcase
  end

  always @* begin
    case (reg_src)
      `REG_SRC_ALU :
        begin
          wd = aluOut;
        end
      `REG_SRC_MEM :
        begin
          wd = dataOut; // from data memory
        end
      `REG_SRC_PC :
        begin
          wd = aluOut; // REG_SRC_PC HERE
        end
      `REG_SRC_SPI :
        begin
          wd = spi_out; // from data memory;
        end
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