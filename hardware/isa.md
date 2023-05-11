# Instruction Set Architecture (ISA)

Based on the RISC-V (RV32I) ISA.

## Instructions

### 20-bit immediate

| Format | Instruction | Implementation |
| --- | --- | --- |
| `lui rd, imm20` | load upper immediate | `rd = imm20 << 12` |
| `auipc rd, imm20` | add upper immediate to pc | `rd = pc + imm20 << 12` |

### Branching

| Format | Instruction | Implementation |
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

| Format | Instruction | Implementation |
| --- | --- | --- |
| `lb rd, imm12(rs1)` | load byte | `rd = mem[rs1 + imm12]` |
| `lh rd, imm12(rs1)` | load halfword | `rd = mem[rs1 + imm12]` |
| `lw rd, imm12(rs1)` | load word | `rd = mem[rs1 + imm12]` |
| `lbu rd, imm12(rs1)` | load byte usigned | `rd = mem[rs1 + imm12]` |
| `lhu rd, imm12(rs1)` | load halfword unsigned | `rd = mem[rs1 + imm12]` |
| `sb rs2, imm12(rs1)` | store byte | `mem[rs1 + imm12] = rs2[7:0]` |
| `sh rs2, imm12(rs1)` | store halfword | `mem[rs1 + imm12] = rs2[15:0]` |
| `sw rs2, imm12(rs1)` | store word | `mem[rs1 + imm12] = rsw[31:0]` |

### Standard Arithmetic

| Format | Instruction | Implementation |
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

### Environment

| Format | Instruction | Implementation |
| --- | --- | --- |
| `fence pred, succ` | memory fence | |
| `ecall` | environment call | |
| `ebreak` | environment break | |

### CSR Extension

| Format | Instruction | Implementation |
| --- | --- | --- |
| `csrrw rd, offset, rs1` | CSR read/write | `t = CSRs[csr]; CSRs[csr] = x[rs1]; x[rd] = t` |
| `csrrs rd, offset, rs1` | CSR read and set bits | `t = CSRs[csr]; CSRs[csr] = t \| x[rs1]; x[rd] = t` |
| `csrrc rd, offset, rs1` | CSR read and clear bits | `t = CSRs[csr]; CSRs[csr] = t & ∼x[rs1]; x[rd] = t` |
| `csrrwi rd, offset, uimm` | CSR read/write (immediate) | `x[rd] = CSRs[csr]; CSRs[csr] = zimm` |
| `csrrsi rd, offset, uimm` | CSR read and set bits (immediate) | `t = CSRs[csr]; CSRs[csr] = t \| zimm; x[rd] = t` |
| `csrrci rd, offset, uimm` | CSR read and clear bits (immediate) | `t = CSRs[csr]; CSRs[csr] = t & ∼zimm; x[rd] = t` |