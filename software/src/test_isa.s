.section .init
.globl test_isa

test_isa:
    addi sp, sp, -12

test_isa_lui:
    lui t0, 1                           // t0 = 0x1000
    addi t1, x0, 1                      // t1 = 0x1000
    slli t1, t1, 12  
    beq t3, t4, 12                      // assert t0 == t1
    li a0, 1
    j test_isa_return

test_isa_auipc:
    auipc t0, 1                         // t0 = test_isa_auipc + 0x1000
    la t1, test_isa_auipc               // t1 = text_auipc + 0x1000
    addi t2, x0, 1
    slli t2, t2, 12
    add t1, t1, t2
    beq t3, t4, 12                      // assert t0 == t1
    li a0, 2
    j test_isa_return

test_isa_jal:
    jal t0, 12                          // t0 = pc + 4; pc += 8
    li a0, 2
    j test_isa_return                   // should not run
    auipc t1, 0                         // t1 = pc
    addi t1, t1, -4                     // t1 = t1 - 4
    beq t3, t4, 12                      // assert t0 == t1
    li a0, 3
    j test_isa_return

test_isa_jalr:
    auipc t1, 0                         // t1 = pc
    jalr t0, t1, 17                     // t0 = pc + 4; pc = (t1 + 17) & ~1; 
    li a0, 4
    j test_isa_return                   // should not run
    addi t1, t1, 8                      // t1 = t1 + 8
    beq t0, t0, 12                      // assert t1 == t2
    li a0, 5
    j test_isa_return

test_isa_branch:
    addi t0, x0, 10                     // t0 = 10
    addi t1, x0, 10                     // t1 = 10
    addi t2, x0, 11                     // t2 = 11
    addi t3, x0, -15                    // t3 = -15
    
    beq t0, t2, 12                      // if t0 == t2; pc = pc + 8
    beq t0, t1, 12                      // if t0 == t1; pc = pc + 8
    li a0, 6
    j test_isa_return                   // should not run

    bne t0, t1, 12                      // if t0 != t1; pc = pc + 8
    bne t0, t2, 12                      // if t0 != t2, pc = pc + 8
    li a0, 7
    j test_isa_return                   // should not run

    blt t0, t1, 12                      // if t0 < t1; pc = pc + 8
    blt t3, t0, 12                      // if t3 < t0; pc = pc + 8
    li a0, 8
    j test_isa_return                   // should not run

    bge t1, t2, 12                      // if t1 >= t2; pc = pc + 8
    bge t2, t1, 12                      // if t2 >= t1; pc = pc + 8
    li a0, 9
    j test_isa_return                   // should not run

    bltu t3, t0, 12                     // if u(x4) < u(x2); pc = pc + 8
    bltu t0, t3, 12                     // uf u(x2) < u(x4); pc = pc + 8
    li a0, 10
    j test_isa_return                   // should not run

    bgeu t0, t3, 12                     // if u(x1) >= u(x4); pc = pc + 8
    bgeu t3, t0, 12                     // if u(x4) >= u(x1); pc = pc + 8
    li a0, 11
    j test_isa_return                   // should not run

test_isa_mem_0:
    addi t0, sp, 0                      // t0 = sp
    li t1, 0xDEADBEEF                   // t1 = 0xDEADBEEF
    li t2, 0xBADC0FFE                   // t2 = 0xBADC0FFE

    sw t1, 0(t0)                        // mem[0] = t1
    sw t2, 4(t0)                        // mem[1] = t2

    lw t3, 0(t0)                        // t3 = mem[0]
    beq t3, t1, 12                      // assert t3 == t1
    li a0, 12
    j test_isa_return

    lw t4, 4(t0)                        // t4 = mem[1]
    beq t4, t2, 12                      // assert t4 == t1
    li a0, 13
    j test_isa_return

test_isa_mem_1:
    addi t0, sp, 1                      // t0 = mem + 1
    li t1, 0xDEADBEEF                   // t1 = 0xDEADBEEF
    li t2, 0xBADC0FFE                   // t2 = 0xBADC0FFE

    sw t1, 0(t0)                        // mem[0] = t1
    sw t2, 4(t0)                        // mem[1] = t2

    lw t3, 0(t0)                        // t3 = mem[0]
    beq t3, t1, 12                      // assert t3 == t1
    li a0, 14
    j test_isa_return

    lw t4, 4(t0)                        // t4 = mem[1]
    beq t4, t2, 12                      // assert t4 == t1
    li a0, 15
    j test_isa_return

test_isa_mem_2:
    addi t0, sp, 2                      // tp = sp + 2
    li t1, 0xDEADBEEF                   // t1 = 0xDEADBEEF
    li t2, 0x000000EF                   // t2 = 0x000000EF
    li t3, 0xFFFFFFEF                   // t3 = 0xFFFFFFEF
    li t4, 0x0000BEEF                   // t4 = 0x0000BEEF
    li t5, 0xFFFFBEEF                   // t5 = 0xFFFFBEEF

    sw x0, 0(t0)                        // mem[0] = 0
    sb t1, 0(t0)                        // mem[0] = 0xEF

    lw t6, 0(t0)                        // t6 = mem[0]
    beq t6, t2, 12                      // assert t6 == t2
    li a0, 16
    j test_isa_return
    
    lb t6, 0(t0)                        // t6 = sext(mem[0][7:0])
    beq t6, t3, 12                      // assert t6 == t3
    li a0, 17
    j test_isa_return

    lbu t6, 0(t0)                       // t6 = mem_b[0][7:0]
    beq t6, t2, 12                      // assert t6 == t2
    li a0, 18
    j test_isa_return
    
    sw x0, 0(t0)                        // mem[0] = 0
    sh t1, 0(t0)                        // mem[0] = 0xBEEF
    
    lw t6, 0(t0)                        // t6 = mem[0]
    beq t6, t4, 12                      // assert t6 == t4
    li a0, 19
    j test_isa_return

    lh t6, 0(t0)                        // t6 = sext(mem[0][15:0])
    beq t6, t5, 12                      // assert t6 == t5
    li a0, 20
    j test_isa_return

    lhu t6, 0(t0)                       // t6 = mem[0][31:0]
    beq t6, t4, 12                      // assert t6 == t4
    li a0, 21
    j test_isa_return

test_isa_op_immed: 
    li t0, 40                           // t0 = 40
    li t1, 0x0AA                        // t1 = 0x00000AAA
    li t2, -40                          // t2 = -40

    addi t3, t0, 40                     // t3 = t0 + 40
    li t4, 80                           // t4 = 80
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 22
    j test_isa_return
    
    slti t3, t0, -40                    // t3 = t0 < -40
    li t4, 0                            // t4 = 0
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 23
    j test_isa_return

    sltiu t3, t0, -40                   // t3 = u(x1) < u(-40)
    li t4, 1                            // t4 = 1
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 24
    j test_isa_return

    xori t3, t1, 0x92                  // t3 = t1 ^ 0x92
    li t4, 0x38                        // t4 = 0x38
    beq t3, t4, 12                     // assert t3 == t4
    li a0, 25
    j test_isa_return

    ori t3, t1, 0x92                   // t3 = t1 | 0x92
    li t4, 0xBA                        // t4 = 0xBA
    beq t3, t4, 12                     // assert t3 == t4
    li a0, 26
    j test_isa_return

    andi t3, t1, 0x92                  // t3 = t1 & 0x92
    li t4, 0x82                        // t4 = 0x82
    beq t3, t4, 12                     // assert t3 == t4
    li a0, 27
    j test_isa_return

    slli t3, t0, 2                     // t3 = t0 << 2
    li t4, 160                         // t4 = 160
    beq t3, t4, 12                     // assert t3 == t4
    li a0, 28
    j test_isa_return

    srli t3, t0, 2                     // t3 = t0 >> 2
    li t4, 10                          // t4 = 2
    beq t3, t4, 12                     // assert t3 == t4
    li a0, 29
    j test_isa_return

    srai t3, t2, 2                     // t3 = s(t2) >> 2
    li t4, -10                         // t4 = -10
    beq t3, t4, 12                     // assert t3 == t4
    li a0, 30
    j test_isa_return

test_isa_op: 
    li t0, 40                           // t0 = 40
    li t1, 0x0AA                        // t1 = 0x00000AAA
    li t2, -40                          // t2 = -40

    li t5, 40                           // t5 = 40
    add t3, t0, t5                      // t3 = t0 + t5
    li t4, 80                           // t4 = 80
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 31
    j test_isa_return
    
    li t5, -40                          // t5 = -40
    slt t3, t0, t5                      // t3 = t0 < t5
    li t4, 0
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 32
    j test_isa_return

    li t5, -40                          // t5 = -40
    sltu t3, t0, t5                     // t3 = u(t0) < u(t5)
    li t4, 1                            // t4 = 1
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 33
    j test_isa_return

    li t5, 0x92                         // t5 = 0x92
    xor t3, t1, t5                      // t3 = t1 ^ t5
    li t4, 0x38                         // t4 = 0x38
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 34
    j test_isa_return

    li t5, 0x92                         // t5 = 0x92
    or t3, t1, t5                       // t3 = t1 | t5
    li t4, 0xBA                         // t4 = 0xBA
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 35
    j test_isa_return

    li t5, 0x92                         // t5 = 0x92
    and t3, t1, t5                      // t3 = t1 & t5
    li t4, 0x82                         // t4 = 0x82
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 36
    j test_isa_return

    li t5, 2                            // t2 = 2
    sll t3, t0, t5                      // t3 = t0 << t5
    li t4, 160                          // t4 = 160
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 37
    j test_isa_return

    li t5, 2                            // t5 = 2
    srl t3, t0, t5                      // t3 = t0 >> t5
    li t4, 10                           // t4 = 10
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 38
    j test_isa_return

    li t5, 2                            // t5 = 2
    sra t3, t2, t5                      // t3 = s(t2) >> t5
    li t4, -10                          // t4 = -10
    beq t3, t4, 12                      // assert t3 == t4
    li a0, 39
    j test_isa_return

test_isa_end:
    li a0, 0
    j test_isa_return

test_isa_return:
    addi sp, sp, 12
    ret