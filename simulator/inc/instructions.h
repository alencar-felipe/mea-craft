#pragma once

#include <stdint.h>

#include "types.h"

// 20-bit immediate
void lui(ctx_t *ctx, reg_addr_t rd, imm20_t imm20);
void auipc(ctx_t *ctx, reg_addr_t rd, imm20_t imm20);

// branching
void jal(ctx_t *ctx, reg_addr_t rd, imm20_t imm20);
void jalr(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1);
void beq(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12);
void bne(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12);
void blt(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12);
void bge(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12);
void bltu(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12);
void bgeu(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12);

// memory
void lb(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1);
void lh(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1);
void lw(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1);
void lbu(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1);
void lhu(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1);
void sb(ctx_t *ctx, reg_addr_t rs2, imm12_t imm12, reg_addr_t rs1);
void sh(ctx_t *ctx, reg_addr_t rs2, imm12_t imm12, reg_addr_t rs1);
void sw(ctx_t *ctx, reg_addr_t rs2, imm12_t imm12, reg_addr_t rs1);

// common arithmetic
void addi(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
void slti(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
void sltiu(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
void xori(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
void ori(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
void andi(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
void slli(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, shamt_t shamt);
void srli(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, shamt_t shamt);
void srai(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, shamt_t shamt);
void add(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void sub(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void sll(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void slt(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void sltu(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void xor_(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void srl(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void sra(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void or_(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
void and_(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);

// environment
void fence(ctx_t *ctx, fence_arg_t pred, fence_arg_t succ);
void ecall(ctx_t *ctx);
void ebreak(ctx_t *ctx);