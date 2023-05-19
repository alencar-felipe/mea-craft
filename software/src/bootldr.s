.section .init
.globl bootldr

bootldr:
    la sp, _estack                  // Set the stack pointer.
    jal test_isa                    // Execute ISA test.

    la a0, greating                 // a0 = greating
    jal puts                        // puts(a0)

    li t0, 0x10000000               // Load RAM address into t0.
    jalr x0, t0, 0                  // Jump to address in t0.

puts:
    li t0, 0x30000000               // Load UART address into t0.
_puts_loop_start:
    lb t1, 0(a0)                    // t1 = *a0
    beq t1, x0, _puts_loop_end      // while(t0 != 0)
    sb t1, 0(t0)                    // *t0 = t1
    addi a0, a0, 1                  // a0 = a0 + 1
    j _puts_loop_start              // Go to loop start.
_puts_loop_end:
    ret                             // Return.

greating:
    .asciz "Greetings from Bootloader. Waiting for binary file."
