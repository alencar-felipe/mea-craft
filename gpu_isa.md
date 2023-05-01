# GPU Instruction Set Architecture (ISA)

## Instructions

### Branching

| Mnemonic | Instruction | Description |
| --- | --- | --- |
| `jal rd, imm20` | jump and link | `rd = pc + 4; pc = pc + imm20` |
| `jalr rd, imm12(rs1)` | jump and link register | `rd = pc + 4; pc = rs1 + imm12` |
| `beq rs1, rs2, imm12` | branch equal | `if rs1 == rs2: pc = pc + imm12` |
| `bne rs1, rs2, imm12` | branch not equal | `if rs1 != rs2: pc = pc + imm12` |
| `blt rs1, rs2, imm12` | branch less than | `if rs1 < rs2: pc = pc + imm12` |
| `bge rs1, rs2, imm12` | branch greater than or equal | `if rs1 >= rs2: pc = pc + imm12` |
| `bltu rs1, rs2, imm12` | branch less than unsigned | `if rs1 < rs2: pc = pc + (imm12 << 1)` |
| `bgeu rs1, rs2, imm12` | branch greater than or equal unsigned | `if rs1 >= rs2: pc = pc + imm12` |
### Memory

| Mnemonic | Instruction | Description |
| --- | --- | --- |
| `lb rd, imm12(rs1)` | load byte | `rd = mem[rs1 + imm12]` |
| `lh rd, imm12(rs1)` | load halfword | `rd = mem[rs1 + imm12]` |
| `lw rd, imm12(rs1)` | load word | `rd = mem[rs1 + imm12]` |
| `lbu rd, imm12(rs1)` | load byte usigned | `rd = mem[rs1 + imm12]` |
| `lhu rd, imm12(rs1)` | load halfword unsigned | `rd = mem[rs1 + imm12]` |
| `sb rs2, imm12(rs1)` | store byte | `mem[rs1 + imm12] = rs2[7:0]` |
| `sh rs2, imm12(rs1)` | store halfword | `mem[rs1 + imm12] = rs2[15:0]` |
| `sw rs2, imm12(rs1)` | store word | `mem[rs1 + imm12] = rsw[31:0]` |

### Common Arithmetic

| Mnemonic | Instruction | Description |
| --- | --- | --- |
| `addi rd, rs1, imm12` | add immediate | `rd = rs1 + imm12` |
| `slti rd, rs1, imm12` | set less than immediate | `rd = rs1 < rs2 ? 1 : 0` |
| `sltiu rd, rs1, imm12` | set less than immediate unsigned | `rd = rs1 < imm12 ? 1 : 0` |
| `xori rd, rs1, imm12` | xor immediate | `rd = rs1 ^ imm12` |
| `ori rd, rs1, imm12` | or immediate | `rd = rs1 \| imm12` |
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
fence
ecall
ebreak
