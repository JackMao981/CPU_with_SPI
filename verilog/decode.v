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
  // Muxing
  output reg [`W_SPI_MODE-1:0] spi_mode,
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
  assign spi_mode = 2'b00;

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
        end
      `ADDIU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU;
        end
      `ANDI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_AND;
        end
      `ORI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR;
        end
      `SLTI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLT;
        end
      `SLTIU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLTU;
        end
      `XORI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_ALU;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_XOR;
        end

      // Part 3 Start
      `J_:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_PC;
          pc_src  = `PC_SRC_JUMP;  alu_op  = inst[`FLD_FUNCT];
        end
      `JAL:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_PC; // either this or the PC
          pc_src  = `PC_SRC_JUMP;  alu_op  = inst[`FLD_FUNCT];
        end

      `BEQ:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_PC;
          pc_src  = `PC_SRC_BRCH;  alu_op  = `F_SUB;
        end
      `BNE:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_PC;
          pc_src  = `PC_SRC_BRCH;  alu_op  = `F_SUB;
        end

      // lbu, lhu, luui, lw
      `LBU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end
      `LHU:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end
      `LUI:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLL;
        end
      `LW:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_READ;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end
      // sb, sh, sw
      `SB:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end
      `SH:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
        end
      `SW:
        begin
          wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WREN;
          imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
          alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
          pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADD;
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
          end
        `F_ADDU:
          begin
            wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;  alu_op  = `F_ADDU;
         end
       `F_AND:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_AND;
         end
       `F_NOR:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           mem_cmd = `MEM_NOP; imm_ext = `IMM_ZERO_EXT;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_NOR;
         end
       `F_OR:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           mem_cmd = `MEM_NOP;  imm_ext = `IMM_ZERO_EXT;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_OR;
         end
       `F_SLT:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLT;
         end
       `F_SLTU:
         begin
           wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
           imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
           alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLTU;
         end
       `F_SLL:
         begin
           wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
           imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
           alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
           pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SLL;
         end
         `F_SRL:
           begin
             wa = rd; ra1 = rt; ra2 = rs; reg_wen = `WREN;
             imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
             alu_src = `ALU_SRC_SHA;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRL;
           end
         `F_SRAV:
           begin
             wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
             mem_cmd = `MEM_NOP;  imm_ext = `IMM_ZERO_EXT;
             alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SRAV;
           end
         `F_SUB:
           begin
             wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
             imm_ext = `IMM_SIGN_EXT; mem_cmd = `MEM_NOP;
             alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SUB;
           end
         `F_SUBU:
           begin
             wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WREN;
             imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
             alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
             pc_src  = `PC_SRC_NEXT;  alu_op  = `F_SUBU;
           end
        `F_SYSCAL:
          begin
            ra1 = `REG_V0;
            ra2 = `REG_A0;
            wa = rd; reg_wen = `WDIS;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
            alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
            pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];
          end

        //PART 3
        `F_JR:
          begin
            wa = rt; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
            imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_WRITE;
            alu_src = `ALU_SRC_IMM;  reg_src = `REG_SRC_MEM;
            pc_src  = `PC_SRC_REGF;  alu_op  = inst[`FLD_FUNCT];
          end

        // New Part!
        `MC0:
          begin
            case(inst[`FLD_RS])
            begin
              `RS_MFC0:
              begin
                wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
                imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
                alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
                pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];
                spi_mode = inst[`FLD_SPI_MODE];
              end
              `RS_MTC0:
              begin
                wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
                imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
                alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
                pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT];
                spi_mode = inst[`FLD_SPI_MODE];
              end
            end
          end
        endcase
      end

      default: begin // handles NOP
        wa = rd; ra1 = rs; ra2 = rt; reg_wen = `WDIS;
        imm_ext = `IMM_ZERO_EXT; mem_cmd = `MEM_NOP;
        alu_src = `ALU_SRC_REG;  reg_src = `REG_SRC_ALU;
        pc_src  = `PC_SRC_NEXT;  alu_op  = inst[`FLD_FUNCT]; end
    endcase
  end
endmodule
