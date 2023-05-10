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

test_mem_0:
    lui x1, %hi(array)                  // x1 = array
    addi x1, x1, %lo(array)              

    lui x2, %hi(0xDEADBEEF)             // x2 = 0xDEADBEEF
    addi x2, x2, %lo(0xDEADBEEF)
    
    lui x3, %hi(0xBADC0FFE)             // x3 = 0xBADC0FFE
    addi x3, x3, %lo(0xBADC0FFE)

    sw x2, 0(x1)                        // array[0] = x2
    sw x3, 4(x1)                        // array[1] = x3

    lw x4, 0(x1)                        // x4 = array[0]
    beq x4, x2, 8                       // assert x4 == x2
    ebreak

    lw x5, 4(x1)                        // x5 = array[1]
    beq x5, x3, 8                       // assert x5 == x2
    ebreak

test_mem_1:
    la x1, array                        // x1 = array
    li x2, 0xDEADBEEF                   // x2 = 0xDEADBEEF
    li x3, 0x000000EF                   // x3 = 0x000000EF
    li x4, 0xFFFFFFEF                   // x4 = 0xFFFFFFEF
    li x5, 0x0000BEEF                   // x5 = 0x0000BEEF
    li x6, 0xFFFFBEEF                   // x6 = 0xFFFFBEEF

    sw x0, 0(x1)                        // array[0] = 0
    sb x2, 0(x1)                        // array[0] = 0xEF

    lw x7, 0(x1)                        // x7 = array[0]
    beq x7, x3, 8                       // assert x7 == x3
    ebreak
    
    lb x7, 0(x1)                        // x7 = sext(array[0][7:0])
    beq x7, x4, 8                       // assert x7 == x4
    ebreak

    lbu x7, 0(x1)                       // x7 = array_b[0][7:0]
    beq x7, x3, 8                       // assert x7 == x3
    ebreak
    
    sw x0, 0(x1)                        // array[0] = 0
    sh x2, 0(x1)                        // array[0] = 0xBEEF
    
    lw x7, 0(x1)                        // x7 = array[0]
    beq x7, x5, 8                       // assert x7 == x5
    ebreak

    lh x7, 0(x1)                        // x7 = sext(array[0][15:0])
    beq x7, x6, 8                       // assert x7 == x6
    ebreak

    lhu x7, 0(x1)                       // x7 = array[0][31:0]
    beq x7, x5, 8                       // assert x7 == x5
    ebreak

test_op_immed: 
    li x1, 40                           // x1 = 40
    li x2, 0x0AA                        // x2 = 0x00000AAA
    li x3, -40                          // x3 = -40

    addi x10, x1, 40                    // x10 = x1 + 40
    li x11, 80                         // x11 = 80
    beq x10, x11, 8                     // assert x10 == x11
    ebreak
    
    slti x10, x1, -40                   // x10 = x1 < -40
    li x11, 0
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    sltiu x10, x1, -40                  // x10 = u(x1) < u(-40)
    li x11, 1
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    xori x10, x2, 0x92                  // x10 = x2 ^ 0x92
    li x11, 0x38                        // x11 = 0x38
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    ori x10, x2, 0x92                   // x10 = x2 | 0x92
    li x11, 0xBA                        // x11 = 0xBA
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    andi x10, x2, 0x92                  // x10 = x2 & 0x92
    li x11, 0x82                        // x11 = 0x82
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    slli x10, x1, 2                     // x10 = x1 << 2
    li x11, 160                         // x11 = 160
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    srli x10, x1, 2                     // x10 = x2 >> 2
    li x11, 10                          // x11 = 2
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    srai x10, x3, 2                     // x10 = s(x10) >> 2
    li x11, -10                         // x11 = -10
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

test_op: 
    li x1, 40                           // x1 = 40
    li x2, 0x0AA                        // x2 = 0x00000AAA
    li x3, -40                          // x3 = -40

    li x12, 40                          // x12 = 40
    add x10, x1, x12                   // x10 = x1 + x12
    li x11, 80                          // x11 = 80
    beq x10, x11, 8                     // assert x10 == x11
    ebreak
    
    li x12, -40                         // x12 = -40
    slt x10, x1, x12                    // x10 = x1 < x12
    li x11, 0
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    li x12, -40                         // x12 = -40
    sltu x10, x1, x12                   // x10 = u(x1) < u(-40)
    li x11, 1
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    li x12, 0x92                        // x12 = 0x92
    xor x10, x2, x12                    // x10 = x2 ^ x12
    li x11, 0x38                        // x11 = 0x38
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    li x12, 0x92                        // x12 = 0x92
    or x10, x2, x12                     // x10 = x2 | x12
    li x11, 0xBA                        // x11 = 0xBA
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    li x12, 0x92
    and x10, x2, x12                    // x10 = x2 & x12
    li x11, 0x82                        // x11 = 0x82
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    li x12, 2                           // x12 = 2
    sll x10, x1, x12                    // x10 = x1 << x12
    li x11, 160                         // x11 = 160
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    li x12, 2                           // x12 = 2
    srl x10, x1, x12                   // x10 = x2 >> x12
    li x11, 10                          // x11 = 2
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

    li x12, 2                           // x12 = 2
    sra x10, x3, x12                    // x10 = s(x10) >> x12
    li x11, -10                         // x11 = -10
    beq x10, x11, 8                     // assert x10 == x11
    ebreak

end:
    ebreak
    
.section .data
array:
    .word 0
    .word 0
