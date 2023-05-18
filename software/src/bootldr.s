.section .init
.globl bootldr

bootldr:
    la sp, _estack      // Set the stack pointer.
    jal test_isa        // Execute ISA test.
    ebreak
