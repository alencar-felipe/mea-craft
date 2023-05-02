#pragma once

#include <stdint.h>
#include <stdio.h>

#include "types.h"
#include "utils.h"

// 20-bit immediate
void lui(ctx_t *ctx, word_t rd, word_t imm);
void auipc(ctx_t *ctx, word_t rd, word_t imm);

// branching
void jal(ctx_t *ctx, word_t rd, word_t offset);
void jalr(ctx_t *ctx, word_t rd, word_t rs1, word_t offset);
void beq(ctx_t *ctx, word_t rs1, word_t rs2, word_t offset);
void bne(ctx_t *ctx, word_t rs1, word_t rs2, word_t offset);
void blt(ctx_t *ctx, word_t rs1, word_t rs2, word_t offset);
void bge(ctx_t *ctx, word_t rs1, word_t rs2, word_t offset);
void bltu(ctx_t *ctx, word_t rs1, word_t rs2, word_t offset);
void bgeu(ctx_t *ctx, word_t rs1, word_t rs2, word_t offset);

// memory
void lb(ctx_t *ctx, word_t rd, word_t imm, word_t rs1);
void lh(ctx_t *ctx, word_t rd, word_t imm, word_t rs1);
void lw(ctx_t *ctx, word_t rd, word_t imm, word_t rs1);
void lbu(ctx_t *ctx, word_t rd, word_t imm, word_t rs1);
void lhu(ctx_t *ctx, word_t rd, word_t imm, word_t rs1);
void sb(ctx_t *ctx, word_t rs2, word_t imm, word_t rs1);
void sh(ctx_t *ctx, word_t rs2, word_t imm, word_t rs1);
void sw(ctx_t *ctx, word_t rs2, word_t imm, word_t rs1);

// common arithmetic
void addi(ctx_t *ctx, word_t rd, word_t rs1, word_t imm);
void slti(ctx_t *ctx, word_t rd, word_t rs1, word_t imm);
void sltiu(ctx_t *ctx, word_t rd, word_t rs1, word_t imm);
void xori(ctx_t *ctx, word_t rd, word_t rs1, word_t imm);
void ori(ctx_t *ctx, word_t rd, word_t rs1, word_t imm);
void andi(ctx_t *ctx, word_t rd, word_t rs1, word_t imm);
void slli(ctx_t *ctx, word_t rd, word_t rs1, word_t shamt);
void srli(ctx_t *ctx, word_t rd, word_t rs1, word_t shamt);
void srai(ctx_t *ctx, word_t rd, word_t rs1, word_t shamt);
void add(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void sub(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void sll(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void slt(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void sltu(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void xor_(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void srl(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void sra(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void or_(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);
void and_(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2);

// environment
void fence(ctx_t *ctx, word_t pred, word_t succ);
void ecall(ctx_t *ctx);
void ebreak(ctx_t *ctx);