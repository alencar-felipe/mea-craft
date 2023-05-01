# GPU Instruction Set Architecture (ISA)

Based on the RISC-V (RV32I) ISA.

## Instructions

### 20-bit immediate

| Mnemonic | Type | Instruction | Implementation |
| --- | --- | --- | --- |
| `lui rd, imm20` | U | load upper immediate | `rd = imm20 << 12` |
| `auipc rd, imm20` | U | add upper immediate to pc | `rd = pc + imm20 << 12` |

### Branching

| Mnemonic | Type | Instruction | Implementation |
| --- | --- | --- | --- |
| `jal rd, imm20` | UJ | jump and link | `rd = pc + 4; pc = pc + imm20` |
| `jalr rd, imm12(rs1)` | I | jump and link register | `rd = pc + 4; pc = rs1 + imm12` |
| `beq rs1, rs2, imm12` | SB | branch equal | `if rs1 == rs2: pc = pc + imm12` |
| `bne rs1, rs2, imm12` | SB | branch not equal | `if rs1 != rs2: pc = pc + imm12` |
| `blt rs1, rs2, imm12` | SB | branch less than | `if rs1 < rs2: pc = pc + imm12` |
| `bge rs1, rs2, imm12` | SB | branch greater than or equal | `if rs1 >= rs2: pc = pc + imm12` |
| `bltu rs1, rs2, imm12` | SB | branch less than unsigned | `if rs1 < rs2: pc = pc + (imm12 << 1)` |
| `bgeu rs1, rs2, imm12` | SB | branch greater than or equal unsigned | `if rs1 >= rs2: pc = pc + imm12` |
### Memory

| Mnemonic | Type | Instruction | Implementation |
| --- | --- | --- | --- |
| `lb rd, imm12(rs1)` | I | load byte | `rd = mem[rs1 + imm12]` |
| `lh rd, imm12(rs1)` | I | load halfword | `rd = mem[rs1 + imm12]` |
| `lw rd, imm12(rs1)` | I | load word | `rd = mem[rs1 + imm12]` |
| `lbu rd, imm12(rs1)` | I | load byte usigned | `rd = mem[rs1 + imm12]` |
| `lhu rd, imm12(rs1)` | I | load halfword unsigned | `rd = mem[rs1 + imm12]` |
| `sb rs2, imm12(rs1)` | S | store byte | `mem[rs1 + imm12] = rs2[7:0]` |
| `sh rs2, imm12(rs1)` | S | store halfword | `mem[rs1 + imm12] = rs2[15:0]` |
| `sw rs2, imm12(rs1)` | S | store word | `mem[rs1 + imm12] = rsw[31:0]` |

### Standard Arithmetic

| Mnemonic | Type | Instruction | Implementation |
| --- | --- | --- | --- |
| `addi rd, rs1, imm12` | I | add immediate | `rd = rs1 + imm12` |
| `slti rd, rs1, imm12` | I | set less than immediate | `rd = rs1 < rs2 ? 1 : 0` |
| `sltiu rd, rs1, imm12` | I | set less than immediate unsigned | `rd = rs1 < imm12 ? 1 : 0` |
| `xori rd, rs1, imm12` | I | xor immediate | `rd = rs1 ^ imm12` |
| `ori rd, rs1, imm12` | I | or immediate | `rd = rs1 \| imm12` |
| `andi rd, rs1, imm12` | I | and immediate | `rd = rs1 & imm12` |
| `slli rd, rs1, shamt` | I | shift left logical immediate | `rd = rs1 << shamt` |
| `srli rd, rs1, shamt` | I | shift right logical immediate | `rd = rs1 >> shamt` |
| `srai rd, rs1, shamt` | I | shift right arithmetic immediate | `rd = rs1 >> shamt` |
| `add rd, rs1, rs2` | R | add | `rd = rs1 + rs2` |
| `sub rd, rs1, rs2` | R | subtract | `rd = rs1 - rs2` |
| `sll rd, rs1, rs2` | R | shift left logical | `rd = rs1 << rs2` |
| `slt rd, rs1, rs2` | R | set less than | `rd = rs1 < rs2 ? 1 : 0` |
| `sltu rd, rs1, rs2` | R | set less than unsigned | `rd = rs1 < rs2 ? 1 : 0` |
| `xor rd, rs1, rs2` | R | xor | `rd = rs1 ^ rs2` |
| `srl rd, rs1, rs2` | R | shift right logical | `rd = rs1 >> rs2` |
| `sra rd, rs1, rs2` | R | shift right arithmetic | `rd = rs1 >> rs2` |
| `or rd, rs1, rs2` | R | or | `rd = rs1 \| rs2` |
| `and rd, rs1, rs2` | R | and | `rd = rs1 & rs2` |

### Environment

| Mnemonic | Type | Instruction | Implementation |
| --- | --- | --- | --- |
| `fence pred, succ` | I | memory fence | |
| `ecall` | I | environment call | |
| `ebreak` | I | environment break | |