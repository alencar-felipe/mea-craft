# GPU Instruction Set Architecture (ISA)

## Instructions

### Memory

| Mnemonic | Instruction | Description |
| --- | --- | --- |
| `lb rd, imm12(rs1)` | load byte | `rd = mem[rs1 + imm12]` |
| `lh rd, imm12(rs1)` | load halfword | `rd = mem[rs1 + imm12]` |
| `lw rd, imm12(rs1)` | load word | `rd = mem[rs1 + imm12]` |
| `lbu rd, imm12(rs1)` | load byte usigned | `rd = mem[rs1 + imm12]` |
| `lhu rd, imm12(rs1)` | load halfword unsigned | `rd = mem[rs1 + imm12]` |
| `sb rs2, imm12(rs1)` | store byte | `mem[rs1 + imm12] = res2(7:0)` |
| `sh rs2, imm12(rs1)` | store halfword | `mem[rs1 + imm12] = rs2(15:0)` |
| `sw rs2, imm12(rs1)` | store word | `mem[rs1 + imm12] = rsw(31:0)` |

### Common Arithmetic

| Mnemonic | Instruction | Description |
| --- | --- | --- |
| `addi rd, rs1, imm12` | add immediate | `rd = rs1 + imm12` |
| `slti rd, rs1, imm12` | set less than immediate | `rd = rs1 < rs2 ? 1 : 0` |
| `sltiu rd, rs1, imm12` | set less than immediate unsigned | `rd = rs1 < imm12 ? 1 : 0` |
| `xori rd, rs1, imm12` | xor immediate | `rd = rs1 ^ imm12` |
| `ori rd, rs1, imm12` | or immediate | `rd = rs1 | imm12` |
| `andi rd, rs1, imm12` | and immediate | `rd = rs1 & imm12` |
| `slli rd, rs1, shamt` | shift left logical immediate | `rd = rs1 << shamt` |
| `srli rd, rs1, shamt` | shift right logical immediate | `rd = rs1 >> shamt` |
| `srai rd, rs1, shamt` | shift right arithmetic immediate | `rd = rs1 >> shamt` |
| `add rd, rs1, rs2` | add | `rd = rs1 + rs2` |
| `sub rd, rs1, rs2` | subtract | `rd = rs1 - rs2` |
| `sll rd, rs1, rs2` | shift left logical | `rd = rs1 << rs2` |
| `slt rd, rs1, rs2` | set less than | `rd = rs1 < rs2 ? 1 : 0` |
| `sltu rd, rs1, rs2` | set less than unsigned | `rd = rs1 < rs2 ? 1 : 0` |
| `xor rd, rs1, rs2` | xor | `rd = rs1 ^ rs2` |
| `srl rd, rs1, rs2` | shift right logical | `rd = rs1 >> rs2` |
| `sra rd, rs1, rs2` | shift right arithmetic | `rd = rs1 >> rs2` |
| `or rd, rs1, rs2` | or | `rd = rs1 \| rs2` |
| `and rd, rs1, rs2` | and | `rd = rs1 & rs2` |

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
fence
ecall
ebreak
