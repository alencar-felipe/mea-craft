#include "instructions.h"

void lui(ctx_t *ctx, word_t rd, word_t imm)
{
    ctx->regs[rd] = SEXT(32, imm << 12);
    ctx-> pc += 4;
}

void auipc(ctx_t *ctx, word_t rd, word_t imm)
{
    ctx->regs[rd] = ctx->pc + SEXT(32, imm << 12);
    ctx-> pc += 4;
}

void jal(ctx_t *ctx, word_t rd, word_t imm)
{
    ctx->regs[rd] = ctx->pc + 4;
    ctx->pc += SEXT(20, imm);
}

void jalr(ctx_t *ctx, word_t rd, word_t imm, word_t rs1)
{
    word_t tmp = ctx->pc + 4;
    ctx->pc = (ctx->regs[rs1] + SEXT(12, imm)) & ~1;
    ctx->regs[rd] = tmp;
}

void beq(ctx_t *ctx, word_t rs1, word_t rs2, word_t imm)
{
    if(ctx->regs[rs1] == ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm);
    } else { 
        ctx-> pc += 4;
    }
}

void bne(ctx_t *ctx, word_t rs1, word_t rs2, word_t imm)
{
    if(ctx->regs[rs1] != ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm);
    } else {
        ctx-> pc += 4;
    }
}

void blt(ctx_t *ctx, word_t rs1, word_t rs2, word_t imm)
{
    if(S(ctx->regs[rs1]) < S(ctx->regs[rs2])) {
        ctx->pc += SEXT(12, imm);
    } else {
        ctx-> pc += 4;
    }
}

void bge(ctx_t *ctx, word_t rs1, word_t rs2, word_t imm)
{
    if(S(ctx->regs[rs1]) >= S(ctx->regs[rs2])) {
        ctx->pc += SEXT(12, imm);
    } else {
        ctx-> pc += 4;
    }
}

void bltu(ctx_t *ctx, word_t rs1, word_t rs2, word_t imm)
{
    if(ctx->regs[rs1] < ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm);
    } else {
        ctx-> pc += 4;
    }
}

void bgeu(ctx_t *ctx, word_t rs1, word_t rs2, word_t imm)
{
    if(ctx->regs[rs1] >= ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm);
    } else {
        ctx-> pc += 4;
    }
}

void lb(ctx_t *ctx, word_t rd, word_t imm, word_t rs1)
{  
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    word_t val = load(8, ctx->mem, addr);
    ctx->regs[rd] = SEXT(8, val & 0xFF);
    ctx-> pc += 4;
}

void lh(ctx_t *ctx, word_t rd, word_t imm, word_t rs1)
{
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    word_t val = load(16, ctx->mem, addr);
    ctx->regs[rd] = SEXT(16, val & 0xFFFF);
    ctx-> pc += 4;
}

void lw(ctx_t *ctx, word_t rd, word_t imm, word_t rs1)
{
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    word_t val = load(32, ctx->mem, addr);
    ctx->regs[rd] = SEXT(32, val);
    ctx-> pc += 4;
}

void lbu(ctx_t *ctx, word_t rd, word_t imm, word_t rs1)
{
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    word_t val = load(8, ctx->mem, addr);
    ctx->regs[rd] = val & 0xFF;
    ctx-> pc += 4;
}

void lhu(ctx_t *ctx, word_t rd, word_t imm, word_t rs1)
{
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    word_t val = load(16, ctx->mem, addr);
    ctx->regs[rd] = val & 0xFFF;
    ctx-> pc += 4;
}

void sb(ctx_t *ctx, word_t rs2, word_t imm, word_t rs1)
{
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    store(8, ctx->mem, addr, ctx->regs[rs2] & 0xFF);
    ctx-> pc += 4;
}

void sh(ctx_t *ctx, word_t rs2, word_t imm, word_t rs1)
{  
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    store(16, ctx->mem, addr, ctx->regs[rs2] & 0xFFFF);
    ctx-> pc += 4;
}

void sw(ctx_t *ctx, word_t rs2, word_t imm, word_t rs1)
{
    word_t addr = ctx->regs[rs1] + SEXT(12, imm);
    store(32, ctx->mem, addr, ctx->regs[rs2] & 0xFFFFFFFF);
    ctx-> pc += 4;
}

void addi(ctx_t *ctx, word_t rd, word_t rs1, word_t imm)
{
    ctx->regs[rd] = ctx->regs[rs1] + SEXT(12, imm);
    ctx-> pc += 4;
}

void slti(ctx_t *ctx, word_t rd, word_t rs1, word_t imm)
{
    ctx->regs[rd] = S(ctx->regs[rs1]) < S(SEXT(12, imm));
    ctx-> pc += 4;
}

void sltiu(ctx_t *ctx, word_t rd, word_t rs1, word_t imm)
{
    ctx->regs[rd] = ctx->regs[rs1] < SEXT(12, imm);
    ctx-> pc += 4;
}

void xori(ctx_t *ctx, word_t rd, word_t rs1, word_t imm)
{
    ctx->regs[rd] = ctx->regs[rs1] ^ SEXT(12, imm);
    ctx-> pc += 4;
}

void ori(ctx_t *ctx, word_t rd, word_t rs1, word_t imm)
{
    ctx->regs[rd] = ctx->regs[rs1] | SEXT(12, imm);
    ctx-> pc += 4;
}

void andi(ctx_t *ctx, word_t rd, word_t rs1, word_t imm)
{
    ctx->regs[rd] = ctx->regs[rs1] & SEXT(12, imm);
    ctx-> pc += 4;
}

void slli(ctx_t *ctx, word_t rd, word_t rs1, word_t shamt)
{
    ctx->regs[rd] = ctx->regs[rs1] << shamt;
    ctx-> pc += 4;
}

void srli(ctx_t *ctx, word_t rd, word_t rs1, word_t shamt)
{
    ctx->regs[rd] = ctx->regs[rs1] >> shamt;
    ctx-> pc += 4;
}

void srai(ctx_t *ctx, word_t rd, word_t rs1, word_t shamt)
{
    ctx->regs[rd] = U(S(ctx->regs[rs1]) >> shamt);
    ctx-> pc += 4;
}

void add(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] + ctx->regs[rs2];
    ctx-> pc += 4;
}

void sub(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] - ctx->regs[rs2];
    ctx-> pc += 4;
}

void sll(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] << ctx->regs[rs2];
    ctx-> pc += 4;
}

void slt(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = S(ctx->regs[rs1]) < S(ctx->regs[rs2]);
    ctx-> pc += 4;
}

void sltu(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] < ctx->regs[rs2];
    ctx-> pc += 4;
}

void xor_(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] ^ ctx->regs[rs2];
    ctx-> pc += 4;
}

void srl(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] >> ctx->regs[rs2];
    ctx-> pc += 4;
}

void sra(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = U(S(ctx->regs[rs1]) >> ctx->regs[rs2]);
    ctx-> pc += 4;
}

void or_(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] | ctx->regs[rs2];
    ctx-> pc += 4;
}

void and_(ctx_t *ctx, word_t rd, word_t rs1, word_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] & ctx->regs[rs2];
    ctx-> pc += 4;
}

void fence(ctx_t *ctx, word_t pred, word_t succ)
{
    printf("fence\n");
    //ctx-> pc += 4;
}

void ecall(ctx_t *ctx)
{
    printf("ecall\n");
    //ctx-> pc += 4;
}

void ebreak(ctx_t *ctx)
{
    printf("ebreak\n");
    //ctx-> pc += 4;
}