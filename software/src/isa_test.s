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

end:
    ebreak
    