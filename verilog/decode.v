`include "lib/opcodes.v"
`include "lib/debug.v"
`timescale 1ns / 1 ps

module DECODE
 (input [`W_CPU-1:0] inst,

  // Register File control
  output reg [`W_REG-1:0]     wa,      // Register Write Address
  output reg [`W_REG-1:0]     ra1,     // Register Read Address 1
  output reg [`W_REG-1:0]     ra2,     // Register Read Address 2
  output reg                  reg_wen, // Register Write Enable
  // Immediate
  output reg [`W_IMM_EXT-1:0] imm_ext, // 1-Sign or 0-Zero extend
  output reg [`W_IMM-1:0]     imm,     // Immediate Field
  // Jump Address
  output reg [`W_JADDR-1:0]   addr,    // Jump Addr Field
  // ALU Control
  output reg [`W_FUNCT-1:0]   alu_op,  // ALU OP

  // SPI control
  output reg [`W_SPI_CTRL-1:0] spi_ctrl,

  // Muxing
  output reg [`W_PC_SRC-1:0]  pc_src,  // PC Source
  output reg [`W_MEM_CMD-1:0] mem_cmd, // Mem Command
  output reg [`W_ALU_SRC-1:0] alu_src, // ALU Source
  output reg [`W_REG_SRC-1:0] reg_src);// Mem to Reg

  // Unconditionally pull some instruction fields
  wire [`W_REG-1:0] rs;
  wire [`W_REG-1:0] rt;
  wire [`W_REG-1:0] rd;
  assign rs   = inst[`FLD_RS];
  assign rt   = inst[`FLD_RT];
  assign rd   = inst[`FLD_RD];
  assign imm  = inst[`FLD_IMM];
  assign addr = inst[`FLD_ADDR];

  always @(inst) begin
    if (`DEBUG_DECODE)
      /* verilator lint_off STMTDLY */
      #1 // Delay Slightly
      $display("op = %x rs = %x rt = %x rd = %x imm = %x addr = %x",inst[`FLD_OPCODE],rs,rt,rd,imm,addr);
      /* verilator lint_on STMTDLY */
  end

  always @* begin
    case(inst[`FLD_OPCODE])
      // Jon, if you're reding this, we defeated the dragon
      `ADDI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
          spi_ctrl = `SPI_NOP;
        end
      `ADDIU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU;
          spi_ctrl = `SPI_NOP;
        end
      `ANDI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_AND;
          spi_ctrl = `SPI_NOP;
        end
      `ORI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR;
          spi_ctrl = `SPI_NOP;
        end
      `SLTI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLT;
          spi_ctrl = `SPI_NOP;
        end
      `SLTIU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLTU;
          spi_ctrl = `SPI_NOP;
        end
      `XORI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_XOR;
          spi_ctrl = `SPI_NOP;
        end

      // Part 3 Start
      `J_:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_PC;
          pc_src  = `PC_SRC_JUMP;  alu_op  = inst[`FLD_FUNCT];
          spi_ctrl = `SPI_NOP;
        end
      `JAL:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_PC; // either this or the PC
          pc_src  = `PC_SRC_JUMP;  alu_op  = inst[`FLD_FUNCT];
          spi_ctrl = `SPI_NOP;
        end

      `BEQ:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_PC;
          pc_src  = `PC_SRC_BRCH;  alu_op  = `F_SUB;
          spi_ctrl = `SPI_NOP;
        end
      `BNE:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_PC;
          pc_src  = `PC_SRC_BRCH;  alu_op  = `F_SUB;
          spi_ctrl = `SPI_NOP;
        end

      // lbu, lhu, luui, lw
      `LBU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
          spi_ctrl = `SPI_NOP;
        end
      `LHU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
          spi_ctrl = `SPI_NOP;
        end
      `LUI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLL;
          spi_ctrl = `SPI_NOP;
        end
      `LW:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
          spi_ctrl = `SPI_NOP;
        end
      // sb, sh, sw
      `SB:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
          spi_ctrl = `SPI_NOP;
        end
      `SH:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
          spi_ctrl = `SPI_NOP;
        end
      `SW:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
          spi_ctrl = `SPI_NOP;
        end

      // Part 2
      `OP_ZERO: begin // set every output
        case(inst[`FLD_FUNCT])
        `F_ADD:
          begin
            wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
            spi_ctrl = `SPI_NOP;
          end
        `F_ADDU:
          begin
            wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU;
            spi_ctrl = `SPI_NOP;
         end
       `F_AND:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_AND;
           spi_ctrl = `SPI_NOP;
         end
       `F_NOR:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_NOR;
           spi_ctrl = `SPI_NOP;
         end
       `F_OR:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           mem_cmd = `MEM_NOP;  imm_ext = `IMM_ZERO_EXT;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR;
           spi_ctrl = `SPI_NOP;
         end
       `F_SLT:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLT;
           spi_ctrl = `SPI_NOP;
         end
       `F_SLTU:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLTU;
           spi_ctrl = `SPI_NOP;
         end
       `F_SLL:
         begin
           wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
           imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
           alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLL;
           spi_ctrl = `SPI_NOP;
         end
         `F_SRL:
           begin
             wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
             imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
             alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRL;
             spi_ctrl = `SPI_NOP;
           end
         `F_SRAV:
           begin
             wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
             mem_cmd = `MEM_NOP;  imm_ext = `IMM_ZERO_EXT;
             alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRAV;
             spi_ctrl = `SPI_NOP;
           end
         `F_SUB:
           begin
             wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
             imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
             alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SUB;
             spi_ctrl = `SPI_NOP;
           end
         `F_SUBU:
           begin
             wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
             imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
             alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SUBU;
             spi_ctrl = `SPI_NOP;
           end
        `F_SYSCAL:
          begin
            ra1 = `REG_V0;
            ra2 = `REG_A0;
            wa = rd; reg_wen = `WDIS;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];
            spi_ctrl = `SPI_NOP;
          end

        //PART 3
        `F_JR:
          begin
            wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
            alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
            pc_src  = `PC_SRC_REGF;  alu_op  = inst[`FLD_FUNCT];
            spi_ctrl = `SPI_NOP;
          end

          // New Part!
        `BSPI:
          begin
            wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_PC;
            pc_src  = `PC_SRC_BRCH;  alu_op  = `F_SUB;
            spi_ctrl = `SPI_NOP;
          end
        `MFC0: // same op code, so it doesn't matter if mfc0 or mtc0
          begin
            case(inst[`FLD_RS])
              `RS_MFC0:
              begin
                wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
                imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
                alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_SPI;
                pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];
                spi_ctrl = `MISO;
              end
              `RS_MTC0:
              begin
                wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
                imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
                alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_SPI;
                pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];
                spi_ctrl = `MOSI;
              end
            endcase
          end

        endcase
      end

      default: begin // handles NOP
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT]; spi_ctrl = `SPI_NOP;
        end
    endcase
  end
endmodule
