.section .text
.globl _start

_start:

test_lui:
    lui x1, 1                           // x1 = 0x1000
    addi x2, x0, 1                      // x2 = 0x1000
    slli x2, x2, 12  
    beq x1, x2, 8                       // assert x1 == x2
    ebreak

test_auipc:
    auipc x1, 1                         // x1 = test_auipc + 0x1000
    lui x2, %hi(test_auipc)             // x2 = text_auipc + 0x1000
    addi x2, x2, %lo(test_auipc)
    addi x3, x0, 1
    slli x3, x3, 12
    add x2, x2, x3
    beq x1, x2, 8                       // assert x1 == x2
    ebreak

test_jal:
    jal x1, 8                           // x1 = pc + 4; pc += 8
    ebreak                              // should not run
    auipc x2, 0                         // x2 = pc
    addi x2, x2, -4                     // x2 = x2 - 4
    beq x1, x2, 8                       // assert x1 == x2
    ebreak

test_jalr:
    auipc x2, 0                         // x2 = pc
    jalr x1, x2, 13                     // x1 = pc + 4; pc = (x2 + 13) & ~1; 
    ebreak                              // should not run
    addi x2, x2, 8                      // x2 = x2 + 8
    beq x1, x1, 8                       // assert x2 == x3
    ebreak

test_branch:
    addi x1, x0, 10                     // x1 = 10
    addi x2, x0, 10                     // x2 = 10
    addi x3, x0, 11                     // x3 = 11
    addi x4, x0, -15                    // x4 = -15
    
    beq x1, x3, 8                       // if x1 == x3; pc = pc + 8
    beq x1, x2, 8                       // if x1 == x2; pc = pc + 8
    ebreak                              // should not run

    bne x1, x2, 8                       // if x1 != x2; pc = pc + 8
    bne x1, x3, 8                       // if x1 != x3, pc = pc + 8
    ebreak                              // should not run

    blt x1, x2, 8                       // if x1 < x2; pc = pc + 8
    blt x4, x1, 8                       // if x4 < x1; pc = pc + 8
    ebreak                              // should not run

    bge x2, x3, 8                       // if x2 >= x3; pc = pc + 8
    bge x3, x2, 8                       // if x3 >= x2; pc = pc + 8
    ebreak                              // should not run

    bltu x4, x1, 8                      // if u(x4) < u(x2); pc = pc + 8
    bltu x1, x4, 8                      // uf u(x2) < u(x4); pc = pc + 8
    ebreak                              // should not run

    bgeu x1, x4, 8                      // if u(x1) >= u(x4); pc = pc + 8
    bgeu x4, x1, 8                      // if u(x4) >= u(x1); pc = pc + 8
    ebreak                              // should not run

end:
    ebreak
    