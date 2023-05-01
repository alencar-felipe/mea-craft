#include "instructions.h"

#define SEXT(size, num)
#define S(num)
#define U(num)

static bus_t load(int bits, mem_t *mem, bus_t addr);
static void write(int bits, mem_t *mem, bus_t addr, bus_t value);
static bus_t logical_left_shift(bus_t num);
static bus_t signed_left_shift(bus_t num);
static bus_t logical_right_shift(bus_t num);
static bus_t signed_right_shift(bus_t num);

void lui(ctx_t *ctx, reg_addr_t rd, imm20_t imm20)
{
    bus_t imm = imm20;
    ctx->regs[rd] = SEXT(32, imm << 12);
}

void auipc(ctx_t *ctx, reg_addr_t rd, imm20_t imm20)
{
    bus_t imm = imm20;
    ctx->regs[rd] = ctx->pc + SEXT(32, imm << 12);
}

void jal(ctx_t *ctx, reg_addr_t rd, imm20_t imm20)
{
    ctx->regs[rd] = ctx->pc + 4;
    ctx->pc += SEXT(20, imm20);
}

void jalr(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1)
{
    bus_t tmp = ctx->pc + 4;
    ctx->pc = (ctx->regs[rs1] + SEXT(12, imm12)) & ~1;
    ctx->regs[rd] = tmp;
}

void beq(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12)
{
    if(ctx->regs[rs1] == ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm12);
    } 
}

void bne(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12)
{
    if(ctx->regs[rs1] != ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm12);
    }
}

void blt(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12)
{
    if(S(ctx->regs[rs1]) < S(ctx->regs[rs2])) {
        ctx->pc += SEXT(12, imm12);
    }
}

void bge(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12)
{
    if(S(ctx->regs[rs1]) >= S(ctx->regs[rs2])) {
        ctx->pc += SEXT(12, imm12);
    }
}

void bltu(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12)
{
    if(ctx->regs[rs1] < ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm12);
    }
}

void bgeu(ctx_t *ctx, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12)
{
    if(ctx->regs[rs1] >= ctx->regs[rs2]) {
        ctx->pc += SEXT(12, imm12);
    }
}

void lb(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1)
{  
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    bus_t val = load(8, ctx->mem, addr);
    ctx->regs[rd] = SEXT(8, val & 0xFF);
}

void lh(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1)
{
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    bus_t val = load(16, ctx->mem, addr);
    ctx->regs[rd] = SEXT(16, val & 0xFFFF);
}

void lw(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1)
{
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    bus_t val = load(32, ctx->mem, addr);
    ctx->regs[rd] = SEXT(32, val);
}

void lbu(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1)
{
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    bus_t val = load(8, ctx->mem, addr);
    ctx->regs[rd] = val & 0xFF;
}

void lhu(ctx_t *ctx, reg_addr_t rd, imm12_t imm12, reg_addr_t rs1)
{
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    bus_t val = load(16, ctx->mem[addr]);
    ctx->regs[rd] = val & 0xFFF;
}

void sb(ctx_t *ctx, reg_addr_t rs2, imm12_t imm12, reg_addr_t rs1)
{
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    store(8, mem, addr, ctx->regs[rs2] & 0xFF);
}

void sh(ctx_t *ctx, reg_addr_t rs2, imm12_t imm12, reg_addr_t rs1)
{  
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    store(16, mem, addr, ctx->regs[rs2] & 0xFFFF);
}

void sw(ctx_t *ctx, reg_addr_t rs2, imm12_t imm12, reg_addr_t rs1)
{
    bus_t addr = ctx->regs[rs1] + SEXT(12, imm12);
    store(32, mem, addr, ctx->regs[rs2] & 0xFFFFFFFF);
}

void addi(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12)
{
    ctx->regs[rd] = ctx->regs[rs1] + SEXT(12, imm12);
}

void slti(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12)
{
    ctx->regs[rd] = S(ctx->regs[rs1]) < S(SEXT(12, imm12));
}

void sltiu(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12)
{
    ctx->regs[rd] = ctx->regs[rs1] < SEXT(12, imm12);
}

void xori(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12)
{
    ctx->regs[rd] = ctx->regs[rs1] ^ SEXT(12, imm12);
}

void ori(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12)
{
    ctx->regs[rd] = ctx->regs[rs1] | SEXT(12, imm12);
}

void andi(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12)
{
    ctx->regs[rd] = ctx->regs[rs1] & SEXT(12, imm12);
}

void slli(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, shamt_t shamt)
{
    ctx->regs[rd] = ctx->regs[rs1] << shamt;
}

void srli(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, shamt_t shamt)
{
    ctx->regs[rd] = ctx->regs[rs1] >> shamt;
}

void srai(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, shamt_t shamt)
{
    ctx->regs[rd] = U(S(ctx->regs[rs1]) >> shamt);
}

void add(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] + ctx->regs[rs2];
}

void sub(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] - ctx->regs[rs2];
}

void sll(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] << ctx->regs[rs2];
}

void slt(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = S(ctx->regs[rs1]) < S(ctx->regs[rs2]);
}

void sltu(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] < ctx->regs[rs2];
}

void xor_(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] ^ ctx->regs[rs2];
}

void srl(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] >> ctx->regs[rs2];
}

void sra(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = U(S(ctx->regs[rs1]) >> ctx->regs[rs2]);
}

void or_(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] | ctx->regs[rs2];
}

void and_(ctx_t *ctx, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2)
{
    ctx->regs[rd] = ctx->regs[rs1] & ctx->regs[rs2];
}

void fence(ctx_t *ctx, fence_arg_t pred, fence_arg_t succ)
{
    exit(-1);
}

void ecall(ctx_t *ctx)
{
    exit(-1);
}

void ebreak(ctx_t *ctx)
{
    exit(-1);
}

bus_t load(int bits, mem_t *mem, bus_t addr) 
{   
    bus_t val = 0;

    for(int i = 0; i < bits / 8; i++) {
        val += mem[addr + i] << (8*i);
    }

    return val;
}

static void write(int bits, mem_t *mem, bus_t addr, bus_t value)
{
    bus_t val = 0;

    for(int i = 0; i < bits / 8; i++) {
        mem[addr + i] = (value >> (8*i)) & 0xFF;
    }

    return val;
}