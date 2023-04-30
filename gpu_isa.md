# Instruction Set Architecture (ISA) for GPU

## Instructions

### Common Arithmetic

| Mnemonic | Instruction | Description |
| --- | --- | --- |
| `addi rd, rs1, imm12` | add immediate | rd = rs1 + imm12 |
| `slti rd, rs1, imm12` | set less than immediate | rd = rs1 < rs2 ? 1 : 0 |
| `sltiu rd, rs1, imm12` | set less than immediate unsigned | rd = rs1 < imm12 ? 1 : 0 |
| `xori rd, rs1, imm12` | xor immediate | rd = rs1 ^ imm12 |
| `ori rd, rs1, imm12` | or immediate | rd = rs1 | imm12 |
| `andi rd, rs1, imm12` | and immediate | rd = rs1 & imm12 |
| `slli rd, rs1, shamt` | shift left logical immediate | rd = rs1 << shamt |
| `srli rd, rs1, shamt` | shift right logical immediate | rd = rs1 >> shamt |
| `srai rd, rs1, shamt` | shift right arithmetic immediate | rd = rs1 >> shamt |
| `add rd, rs1, rs2` | add | rd = rs1 + rs2 |
| `sub rd, rs1, rs2` | subtract | rd = rs1 - rs2 |
| `sll rd, rs1, rs2` | shift left logical | rd = rs1 << rs2 |
| `slt rd, rs1, rs2` | set less than | rd = rs1 < rs2 ? 1 : 0 |
| `sltu rd, rs1, rs2` | set less than unsigned | rd = rs1 < rs2 ? 1 : 0 |
| `xor rd, rs1, rs2` | xor | rd = rs1 ^ rs2 |
| `srl rd, rs1, rs2` | shift right logical | rd = rs1 >> rs2 |
| `sra rd, rs1, rs2` | shift right arithmetic | rd = rs1 >> rs2 |
| `or rd, rs1, rs2` | or | rd = rs1 \| rs2 |
| `and rd, rs1, rs2` | and | rd = rs1 & rs2 |

lui
auipc
jal
jalr
beq
bne
blt
bge
bltu
bgeu
lb
lh
lw
lbu
lhu
sb
sh
sw
fence
ecall
ebreak
