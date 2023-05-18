.section .init
.globl test_isa

test_isa:

test_isa_lui:
    lui t0, 1                           // t0 = 0x1000
    addi t1, x0, 1                      // t1 = 0x1000
    slli t1, t1, 12  
    beq t3, t4, 8                       // assert t0 == t1
    ebreak

test_isa_auipc:
    auipc t0, 1                         // t0 = test_isa_auipc + 0x1000
    la t1, test_isa_auipc               // t1 = text_auipc + 0x1000
    addi t2, x0, 1
    slli t2, t2, 12
    add t1, t1, t2
    beq t3, t4, 8                       // assert t0 == t1
    ebreak

test_isa_jal:
    jal t0, 8                           // t0 = pc + 4; pc += 8
    ebreak                              // should not run
    auipc t1, 0                         // t1 = pc
    addi t1, t1, -4                     // t1 = t1 - 4
    beq t3, t4, 8                       // assert t0 == t1
    ebreak

test_isa_jalr:
    auipc t1, 0                         // t1 = pc
    jalr t0, t1, 13                     // t0 = pc + 4; pc = (x2 + 13) & ~1; 
    ebreak                              // should not run
    addi t1, t1, 8                      // t1 = t1 + 8
    beq t0, t0, 8                       // assert t1 == t2
    ebreak

test_isa_branch:
    addi t0, x0, 10                     // t0 = 10
    addi t1, x0, 10                     // t1 = 10
    addi t2, x0, 11                     // t2 = 11
    addi t3, x0, -15                    // t3 = -15
    
    beq t0, t2, 8                       // if t0 == t2; pc = pc + 8
    beq t0, t1, 8                       // if t0 == t1; pc = pc + 8
    ebreak                              // should not run

    bne t0, t1, 8                       // if t0 != t1; pc = pc + 8
    bne t0, t2, 8                       // if t0 != t2, pc = pc + 8
    ebreak                              // should not run

    blt t0, t1, 8                       // if t0 < t1; pc = pc + 8
    blt t3, t0, 8                       // if t3 < t0; pc = pc + 8
    ebreak                              // should not run

    bge t1, t2, 8                       // if t1 >= t2; pc = pc + 8
    bge t2, t1, 8                       // if t2 >= t1; pc = pc + 8
    ebreak                              // should not run

    bltu t3, t0, 8                      // if u(x4) < u(x2); pc = pc + 8
    bltu t0, t3, 8                      // uf u(x2) < u(x4); pc = pc + 8
    ebreak                              // should not run

    bgeu t0, t3, 8                      // if u(x1) >= u(x4); pc = pc + 8
    bgeu t3, t0, 8                      // if u(x4) >= u(x1); pc = pc + 8
    ebreak                              // should not run

test_isa_mem_0:
    lui t0, %hi(array)                  // t0 = array
    addi t0, t0, %lo(array)              

    lui t1, %hi(0xDEADBEEF)             // t1 = 0xDEADBEEF
    addi t1, t1, %lo(0xDEADBEEF)
    
    lui t2, %hi(0xBADC0FFE)             // t2 = 0xBADC0FFE
    addi t2, t2, %lo(0xBADC0FFE)

    sw t1, 0(t0)                        // array[0] = t1
    sw t2, 4(t0)                        // array[1] = t2

    lw t3, 0(t0)                        // t3 = array[0]
    beq t3, t1, 8                       // assert t3 == t1
    ebreak

    lw t4, 4(t0)                        // t4 = array[1]
    beq t4, t2, 8                       // assert t4 == t1
    ebreak

test_isa_mem_1:
    la t0, array                        // t0 = array
    li t1, 0xDEADBEEF                   // t1 = 0xDEADBEEF
    li t2, 0x000000EF                   // t2 = 0x000000EF
    li t3, 0xFFFFFFEF                   // t3 = 0xFFFFFFEF
    li t4, 0x0000BEEF                   // t4 = 0x0000BEEF
    li t5, 0xFFFFBEEF                   // t5 = 0xFFFFBEEF

    sw x0, 0(t0)                        // array[0] = 0
    sb t1, 0(t0)                        // array[0] = 0xEF

    lw t6, 0(t0)                        // t6 = array[0]
    beq t6, t2, 8                       // assert t6 == t2
    ebreak
    
    lb t6, 0(t0)                        // t6 = sext(array[0][7:0])
    beq t6, t3, 8                       // assert t6 == t3
    ebreak

    lbu t6, 0(t0)                       // t6 = array_b[0][7:0]
    beq t6, t2, 8                       // assert t6 == t2
    ebreak
    
    sw x0, 0(t0)                        // array[0] = 0
    sh t1, 0(t0)                        // array[0] = 0xBEEF
    
    lw t6, 0(t0)                        // t6 = array[0]
    beq t6, t4, 8                       // assert t6 == t4
    ebreak

    lh t6, 0(t0)                        // t6 = sext(array[0][15:0])
    beq t6, t5, 8                       // assert t6 == t5
    ebreak

    lhu t6, 0(t0)                       // t6 = array[0][31:0]
    beq t6, t4, 8                       // assert t6 == t4
    ebreak

test_isa_op_immed: 
    li t0, 40                           // t0 = 40
    li t1, 0x0AA                        // t1 = 0x00000AAA
    li t2, -40                          // t2 = -40

    addi t3, t0, 40                     // t3 = t0 + 40
    li t4, 80                           // t4 = 80
    beq t3, t4, 8                       // assert t3 == t4
    ebreak
    
    slti t3, t0, -40                    // t3 = t0 < -40
    li t4, 0                            // t4 = 0
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    sltiu t3, t0, -40                   // t3 = u(x1) < u(-40)
    li t4, 1                            // t4 = 1
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    xori t3, t1, 0x92                  // t3 = t1 ^ 0x92
    li t4, 0x38                        // t4 = 0x38
    beq t3, t4, 8                      // assert t3 == t4
    ebreak

    ori t3, t1, 0x92                   // t3 = t1 | 0x92
    li t4, 0xBA                        // t4 = 0xBA
    beq t3, t4, 8                      // assert t3 == t4
    ebreak

    andi t3, t1, 0x92                  // t3 = t1 & 0x92
    li t4, 0x82                        // t4 = 0x82
    beq t3, t4, 8                      // assert t3 == t4
    ebreak

    slli t3, t0, 2                     // t3 = t0 << 2
    li t4, 160                         // t4 = 160
    beq t3, t4, 8                      // assert t3 == t4
    ebreak

    srli t3, t0, 2                     // t3 = t0 >> 2
    li t4, 10                          // t4 = 2
    beq t3, t4, 8                      // assert t3 == t4
    ebreak

    srai t3, t2, 2                     // t3 = s(t2) >> 2
    li t4, -10                         // t4 = -10
    beq t3, t4, 8                      // assert t3 == t4
    ebreak

test_isa_op: 
    li t0, 40                           // t0 = 40
    li t1, 0x0AA                        // t1 = 0x00000AAA
    li t2, -40                          // t2 = -40

    li t5, 40                           // t5 = 40
    add t3, t0, t5                      // t3 = t0 + t5
    li t4, 80                           // t4 = 80
    beq t3, t4, 8                       // assert t3 == t4
    ebreak
    
    li t5, -40                          // t5 = -40
    slt t3, t0, t5                      // t3 = t0 < t5
    li t4, 0
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    li t5, -40                          // t5 = -40
    sltu t3, t0, t5                     // t3 = u(t0) < u(t5)
    li t4, 1                            // t4 = 1
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    li t5, 0x92                         // t5 = 0x92
    xor t3, t1, t5                      // t3 = t1 ^ t5
    li t4, 0x38                         // t4 = 0x38
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    li t5, 0x92                         // t5 = 0x92
    or t3, t1, t5                       // t3 = t1 | t5
    li t4, 0xBA                         // t4 = 0xBA
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    li t5, 0x92                         // t5 = 0x92
    and t3, t1, t5                      // t3 = t1 & t5
    li t4, 0x82                         // t4 = 0x82
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    li t5, 2                            // t2 = 2
    sll t3, t0, t5                      // t3 = t0 << t5
    li t4, 160                          // t4 = 160
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    li t5, 2                            // t5 = 2
    srl t3, t0, t5                      // t3 = t0 >> t5
    li t4, 10                           // t4 = 10
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

    li t5, 2                            // t5 = 2
    sra t3, t2, t5                      // t3 = s(t2) >> t5
    li t4, -10                          // t4 = -10
    beq t3, t4, 8                       // assert t3 == t4
    ebreak

test_isa_end:
    ret
    
.section .data
array:
    .word 0
    .word 0
