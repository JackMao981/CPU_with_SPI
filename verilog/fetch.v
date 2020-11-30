`include "lib/opcodes.v"
`include "lib/debug.v"
`timescale 1ns / 1ps

module FETCH
 (input                      clk,
  input                      rst,
  input      [`W_PC_SRC-1:0] pc_src,
  input      [`W_EN-1:0]     branch_ctrl,
  input      [`W_CPU-1:0]    reg_addr,
  input      [`W_JADDR-1:0]  jump_addr,
  input      [`W_IMM-1:0]    imm_addr,
  output reg [`W_CPU-1:0]    pc_next);

  always @(posedge clk, posedge rst) begin
    if (rst) begin
      // Make sure you're very careful here!!
      // You need to add more cases here
      pc_next <= `W_CPU'd0;
    end
    else begin
      case(pc_src)
        `PC_SRC_NEXT: begin
          pc_next <= pc_next + 4;
        end
        `PC_SRC_JUMP: begin
          pc_next = {{pc_next[31:28]},{jump_addr},{2{1'b0}}};
        end
        `PC_SRC_BRCH: begin // not sure about how BNE case works
          pc_next = pc_add;
        end
        `PC_SRC_REGF: begin
          pc_next <= reg_addr;
        end
        default     : pc_next <= pc_next + 4;
      endcase

      if (`DEBUG_PC && ~rst)
        $display("-- PC, PC/4 = %x, %d",pc_next,pc_next/4);
    end
  end

  reg [`W_CPU-1:0] pc_add;
  reg [`W_CPU-1:0] bval;

  always @* begin
    case(branch_ctrl)
      1'b0: begin bval = 1'b0; end
      1'b1: begin bval = {{14{imm_addr[15]}},{imm_addr},{2'b00}}; end
    endcase
    pc_add = pc_next + bval + 4;
  end
endmodule
