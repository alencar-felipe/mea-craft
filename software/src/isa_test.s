.section .text
.globl _start

_start:
    addi x1, x0, 8      /* x1 = 8 */
    addi x2, x0, 0      /* x2 = 0 */
    addi x2, x2, 1      /* x2 = x2 + 1 */
    bne x1, x2, -4      /* while x1 != x2 */
    ebreak