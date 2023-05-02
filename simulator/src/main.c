#include "main.h"

int main()
{
    return 0;
}

void decode_and_excute(ctx_t *ctx, word_t data)
{
    word_t op = BITS(data, 0, 6);
    
    word_t rd = BITS(data, 7, 11);
    word_t rs1 = BITS(data, 15, 19);
    word_t rs2 = BITS(data, 20, 24);

    word_t imm12 = BITS(data, 20, 31);
    word_t imm20 = BITS(data, 12, 31); 
    
    word_t imm12_alt =
        (BITS(data,  7, 11) <<  0) +
        (BITS(data, 25, 31) <<  5);

    word_t imm13 =
        (BITS(data,  8, 11) <<  1) +
        (BITS(data, 25, 30) <<  5) +
        (BITS(data,  7,  7) << 11) +
        (BITS(data, 31, 31) << 12);

    word_t imm20_alt = 
        (BITS(data, 19, 12) <<  0) +
        (BITS(data, 20, 20) <<  8) +
        (BITS(data, 21, 30) <<  9) +
        (BITS(data, 31, 31) << 19);

    word_t funct3 = BITS(data, 12, 14);
    word_t shamt = BITS(data, 20, 24);
    word_t pred = BITS(data, 24, 27);
    word_t succ = BITS(data, 20, 23);
    
    word_t shift_arg = BITS(data, 5, 31);

    if(op == 0b011011) {
        lui(ctx, rd, imm20);

    } else if(op == 0b0010111) {
        auipc(ctx, rd, imm20);

    } else if(op == 0b1101111) {
        jal(ctx, rd, imm20_alt);
    
    } else if(op == 0b1100111) {
        jalr(ctx, rd, imm12, rs1);
    
    } else if(op == 0b1100011) { // conditional branch
        if(funct3 == 0b000) {
            beq(ctx, rs1, rs2, imm13);

        } else if(funct3 == 0b001) {
            bne(ctx, rs1, rs2, imm13);
        
        } else if(funct3 == 0b100) {
            blt(ctx, rs1, rs2, imm13);
        
        } else if(funct3 == 0b101) {
            bge(ctx, rs1, rs2, imm13);
        
        } else if(funct3 == 0b110) {
            bltu(ctx, rs1, rs2, imm13);
        
        } else if(funct3 == 0b111) {
            bgeu(ctx, rs1, rs2, imm13);
        
        }
    
    } else if(op == 0b0000011) { // load
        if(funct3 == 0b000) { 
            lb(ctx, rd, imm12, rs1);
        
        } else if(funct3 == 0b001) {
            lh(ctx, rd, imm12, rs1);
        
        } else if(funct3 == 0b010) {
            lw(ctx, rd, imm12, rs1);
        
        } else if(funct3 == 0b100) {
            lbu(ctx, rd, imm12, rs1);
        
        } else if(funct3 == 0b101) {
            lhu(ctx, rd, imm12, rs1);
        
        }
    
    } else if(op == 0b0100011) { // store
        if(funct3 == 0b000) {
            sb(ctx, rs2, imm12_alt, rs1);
            
        } else if(funct3 == 0b001) {
            sh(ctx, rs2, imm12_alt, rs1);

        } else if(funct3 == 0b010) {
            sw(ctx, rs2, imm12_alt, rs1);

        }

    } else if(op == 0b0010011) { // ALU I-Type
        if(funct3 == 0b000) {
            addi(ctx, rd, rs1, imm12);

        } else if(funct3 == 0b010) {
            slti(ctx, rd, rs1, imm12);

        } else if(funct3 == 0b011) {
            sltiu(ctx, rd, rs1, imm12);

        } else if(funct3 == 0b100) {
            xori(ctx, rd, rs1, imm12);

        } else if(funct3 == 0b110) {
            ori(ctx, rd, rs1, imm12);

        } else if(funct3 == 0b111) {
            andi(ctx, rd, rs1, imm12);

        } else if(funct3 == 0b001) {
            slli(ctx, rd, rs1, shamt);

        } else if(funct3 == 0b101) {
            if(shift_arg == 0b0000000) {
                srli(ctx, rd, rs1, shamt);

            } else if(shift_arg == 0b0100000) {
                srai(ctx, rd, rs1, shamt);
            
            }

        } 

    } else if(op == 0b0110011) { // ALU R-Type
        if(funct3 == 0b000) {
            if(shift_arg == 0b0000000) {
                add(ctx, rd, rs1, rs2);

            } else if(shift_arg == 0b0100000) {
                sub(ctx, rd, rs1, rs2);

            }
        } else if(funct3 == 0b001) {
            sll(ctx, rd, rs1, rs2);

        } else if(funct3 == 0b010) {
            slt(ctx, rd, rs1, rs2);
        
        } else if(funct3 == 0b011) {
            sltu(ctx, rd, rs1, rs2);

        } else if(funct3 == 0b100) {
            xor_(ctx, rd, rs1, rs2);

        } else if(funct3 == 0b101) {
            if(shift_arg == 0b0000000) {
                srl(ctx, rd, rs1, rs2);
            
            } else if(shift_arg == 0b0100000) {
                sra(ctx, rd, rs1, rs2);

            }

        } else if(funct3 == 0b110) {
            or_(ctx, rd, rs1, rs2);
        
        } else if(funct3 == 0b111) {
            and_(ctx, rd, rs1, rs2);

        }
    
    } else if(op == 0b0001111) { // fence
        fence(ctx, pred, succ);

    } else if(op == 0b1110011) { // ecall, ebreak
        if(BIT(data, 20) == 0) {
            ecall(ctx);

        } else {
            ebreak(ctx);

        }

    }
}