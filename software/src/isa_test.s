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

end:
    ebreak
    