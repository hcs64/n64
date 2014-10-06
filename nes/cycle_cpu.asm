.set noreorder
.text

.set ra,    $31
.set PC,    $28
.set FLAGS, $27
.set SP,    $26
.set A,     $25
.set X,     $24
.set Y,     $23
.set ADR_LO,$22
.set ADR_HI,$21
.set VAL,   $20
.set TMP,   $19
.set cpu_next, $18
.set cpu_next_op, $17
.set cpu_read_pages, $16
.set cpu_write_pages, $15
.set cpu_op_list, $14

  .globl init_cpu
init_cpu:
  la  cpu_next, reset_atomic
  la  cpu_read_pages, cpu_read_address_map
  la  cpu_write_pages, cpu_write_address_map
  la  cpu_op_list, opcode_to_atomic
  jr  ra
  lw  cpu_next_op, (cpu_next)

  .globl run_cpu_cycle
run_cpu_cycle:
  sd    ra, 0*8($29)
  addiu $29, 1*8

  jalr  cpu_next_op
  addiu cpu_next, 4

  addiu $29, -1*8
  ld    ra, 0*8($29)

  jr  ra
  nop

#define read_an_addr(addr_reg, dest_reg) \
  srl   $3, addr_reg, 11  ;\
  sll   $3, 2         ;\
  addu  $3, cpu_read_pages;\
  lw    $3, ($3)      ;\
  bltz  $3, 1f        ;\
  lui   $4, 0x8000    ;\
  or    $3, $4        ;\
  move  $4, ra        ;\
  jalr  $3            ;\
  nop                 ;\
  move  ra, $4        ;\
  b     2f            ;\
  move  dest_reg, $10 ;\
1:                    ;\
  addu  $3, addr_reg  ;\
  lbu   dest_reg, ($3);\
2:

#define read_addr(reg) \
  sll   $2, ADR_HI, 8  ;\
  or    $2, ADR_LO     ;\
  read_an_addr($2, reg)

#define write_an_addr(addr_reg, src_reg) \
  srl   $3, addr_reg, 11 ;\
  sll   $3, 2         ;\
  addu  $3, cpu_write_pages ;\
  lw    $3, ($3)      ;\
  bltz  $3, 1f        ;\
  lui   $4, 0x8000    ;\
  or    $3, $4        ;\
  move  $4, ra        ;\
  move  $11, addr_reg ;\
  jalr  $3            ;\
  move  $10, src_reg  ;\
  b     2f            ;\
  move  ra, $4        ;\
1:                    ;\
  addu  $3, addr_reg  ;\
  sb    src_reg, ($3) ;\
2:

#define write_addr(reg) \
  sll   $2, ADR_HI, 8  ;\
  or    $2, ADR_LO     ;\
  write_an_addr($2, reg)

// atomic operations
CLD:
  jr  ra
  lw  cpu_next_op, (cpu_next)

SEI:
  jr  ra
  lw  cpu_next_op, (cpu_next)

LDA_Imm:
  read_an_addr(PC, A)
  addiu PC, 1
  jr  ra
  lw  cpu_next_op, (cpu_next)

LDA_Abs:
  read_addr(A)
  jr  ra
  lw  cpu_next_op, (cpu_next)

LDX_Imm:
  read_an_addr(PC, X)
  addiu PC, 1
  jr  ra
  lw  cpu_next_op, (cpu_next)

STA_Abs:
  write_addr(A)
  jr  ra
  lw  cpu_next_op, (cpu_next)

TXS:
  move  SP, X
  jr  ra
  lw  cpu_next_op, (cpu_next)

fetch_next:
  read_an_addr(PC, cpu_next)
  addiu PC, 1
  sll cpu_next, 5
  addu cpu_next, cpu_op_list
  jr  ra
  lw  cpu_next_op, (cpu_next)

fetch_adr_lo:
  read_an_addr(PC, ADR_LO)
  addiu PC, 1
  jr  ra
  lw  cpu_next_op, (cpu_next)

fetch_adr_hi:
  read_an_addr(PC, ADR_HI)
  addiu PC, 1
  jr  ra
  lw  cpu_next_op, (cpu_next)

read_resetL:
  li  $2, 0xfffc
  read_an_addr($2, ADR_LO)
  jr  ra
  lw  cpu_next_op, (cpu_next)

read_resetH:
  li  $2, 0xfffd
  read_an_addr($2, ADR_HI)

  sll PC, ADR_HI, 8
  or  PC, ADR_LO

  jr  ra
  lw  cpu_next_op, (cpu_next)


unsupported_opcode:
.data
unsupported_string:
  .string "Unsupported opcode"
.text
  
  la    $11, unsupported_string
  jal   console_write_string
  nop

  move  $11, cpu_next
  la    $12, opcode_to_atomic
  subu  $11, $12
  srl   $11, 5
  jal   console_write_8
  nop

  jal   console_render
  nop

  lw    $11, active_framebuffer
  sw    $11, ready_framebuffer
 
unsupported_deadend:
  b unsupported_deadend
  nop

.data

#define UNSUPPORTED  \
  .word unsupported_opcode;\
  .p2align 5

reset_atomic:
  .word read_resetL, read_resetH, fetch_next

  .p2align 5
opcode_to_atomic:
  // 0x00: BRK
  UNSUPPORTED

  // 0x01: ORA (indir,X)
  UNSUPPORTED

  // 0x02:
  UNSUPPORTED

  // 0x03:
  UNSUPPORTED

  // 0x04:
  UNSUPPORTED
  
  // 0x05: ORA ZP
  UNSUPPORTED

  // 0x06: ASL ZP
  UNSUPPORTED

  // 0x07:
  UNSUPPORTED

  // 0x08: PHP
  UNSUPPORTED

  // 0x09: ORA Immed
  UNSUPPORTED

  // 0x0A: ASL A
  UNSUPPORTED

  // 0x0B: 
  UNSUPPORTED

  // 0x0C
  UNSUPPORTED

  // 0x0D: ORA Abs
  UNSUPPORTED

  // 0x0E: ASL Abs
  UNSUPPORTED

  // 0x0F:
  UNSUPPORTED

  // 0x10: BPL
  UNSUPPORTED

  // 0x11: ORA (indir),Y
  UNSUPPORTED

  // 0x12:
  UNSUPPORTED

  // 0x13
  UNSUPPORTED

  // 0x14
  UNSUPPORTED

  // 0x15: ORA ZP,X
  UNSUPPORTED

  // 0x16: ASL ZP, X
  UNSUPPORTED

  // 0x17:
  UNSUPPORTED

  // 0x18: CLC
  UNSUPPORTED

  // 0x19: ORA Abs, Y
  UNSUPPORTED

  // 0x1A:
  UNSUPPORTED

  // 0x1B:
  UNSUPPORTED

  // 0x1C:
  UNSUPPORTED

  // 0x1D: ORA Abs, X
  UNSUPPORTED

  // 0x1E: ASL Abs, X
  UNSUPPORTED

  // 0x1F:
  UNSUPPORTED

  // 0x20: JSR
  UNSUPPORTED

  // 0x21: AND (indir,X)
  UNSUPPORTED

  // 0x22:
  UNSUPPORTED

  // 0x23:
  UNSUPPORTED

  // 0x24: BIT ZP
  UNSUPPORTED

  // 0x25: AND ZP
  UNSUPPORTED

  // 0x26: ROL ZP
  UNSUPPORTED

  // 0x27: 
  UNSUPPORTED

  // 0x28: PLP
  UNSUPPORTED

  // 0x29: AND Immed
  UNSUPPORTED

  // 0x2A: ROL A
  UNSUPPORTED

  // 0x2B: 
  UNSUPPORTED

  // 0x2C: BIT Abs
  UNSUPPORTED

  // 0x2D: AND Abs
  UNSUPPORTED

  // 0x2E: ROL Abs
  UNSUPPORTED

  // 0x2F: 
  UNSUPPORTED

  // 0x30: BMI
  UNSUPPORTED

  // 0x31: AND (indir),Y
  UNSUPPORTED

  // 0x32:
  UNSUPPORTED

  // 0x33:
  UNSUPPORTED

  // 0x34:
  UNSUPPORTED

  // 0x35: AND ZP, X
  UNSUPPORTED

  // 0x36: ROL ZP, X
  UNSUPPORTED

  // 0x37:
  UNSUPPORTED

  // 0x38: SEC
  UNSUPPORTED

  // 0x39: AND Abs, Y
  UNSUPPORTED

  // 0x3A:
  UNSUPPORTED

  // 0x3B
  UNSUPPORTED

  // 0x3C
  UNSUPPORTED

  // 0x3D: AND Abs, X
  UNSUPPORTED

  // 0x3E: ROL Abs, X
  UNSUPPORTED

  // 0x3F:
  UNSUPPORTED

  // 0x40: RTI
  UNSUPPORTED

  // 0x41: EOR (indir, X)
  UNSUPPORTED

  // 0x42:
  UNSUPPORTED

  // 0x43:
  UNSUPPORTED

  // 0x44:
  UNSUPPORTED

  // 0x45: EOR ZP
  UNSUPPORTED

  // 0x46: LSR ZP
  UNSUPPORTED
  
  // 0x47:
  UNSUPPORTED

  // 0x48: PHA
  UNSUPPORTED

  // 0x49: EOR Imm
  UNSUPPORTED

  // 0x4A: LSR A
  UNSUPPORTED

  // 0x4B: 
  UNSUPPORTED

  // 0x4C: JMP Abs
  UNSUPPORTED

  // 0x4D: EOR Abs
  UNSUPPORTED

  // 0x4E: LSR ABs
  UNSUPPORTED

  // 0x4F:
  UNSUPPORTED

  // 0x50: BVC
  UNSUPPORTED

  // 0x51: EOR (indir), Y
  UNSUPPORTED

  // 0x52:
  UNSUPPORTED

  // 0x53:
  UNSUPPORTED

  // 0x54:
  UNSUPPORTED

  // 0x55: EOR ZP, X
  UNSUPPORTED

  // 0x56: LSR ZP, X
  UNSUPPORTED

  // 0x57:
  UNSUPPORTED

  // 0x58: CLI
  UNSUPPORTED

  // 0x59: EOR Abs, Y
  UNSUPPORTED

  // 0x5A:
  UNSUPPORTED
  
  // 0x5B:
  UNSUPPORTED

  // 0x5C:
  UNSUPPORTED

  // 0x5D: EOR Abs, X
  UNSUPPORTED

  // 0x5E: LSR Abs, X
  UNSUPPORTED

  // 0x5F:
  UNSUPPORTED

  // 0x60: RTS
  UNSUPPORTED

  // 0x61: ADC (indir, X)
  UNSUPPORTED

  // 0x62:
  UNSUPPORTED

  // 0x63:
  UNSUPPORTED

  // 0x64:
  UNSUPPORTED

  // 0x65: ADC, ZP
  UNSUPPORTED

  // 0x66: ROR, ZP
  UNSUPPORTED

  // 0x67:
  UNSUPPORTED

  // 0x68: PLA
  UNSUPPORTED

  // 0x69: ADC Imm
  UNSUPPORTED

  // 0x6A: ROR A
  UNSUPPORTED

  // 0x6B:
  UNSUPPORTED

  // 0x6C: JMP (absolute indirect)
  UNSUPPORTED

  // 0x6D: ADC Abs
  UNSUPPORTED

  // 0x6E: ROR Abs
  UNSUPPORTED

  // 0x6F:
  UNSUPPORTED

  // 0x70: BVS
  UNSUPPORTED

  // 0x71: ADC (inidr), Y
  UNSUPPORTED

  // 0x72:
  UNSUPPORTED

  // 0x73:
  UNSUPPORTED

  // 0x74:
  UNSUPPORTED

  // 0x75: ADC ZP, X
  UNSUPPORTED

  // 0x76: ROR ZP, X
  UNSUPPORTED

  // 0x77:
  UNSUPPORTED

  // 0x78: SEI
  .word SEI, fetch_next
  .p2align 5

  // 0x79: ADC Abs, Y
  UNSUPPORTED

  // 0x7A:
  UNSUPPORTED

  // 0x7B:
  UNSUPPORTED

  // 0x7C:
  UNSUPPORTED

  // 0x7D: ADC Abs, X
  UNSUPPORTED

  // 0x7E: ROR Abs, X
  UNSUPPORTED

  // 0x7F:
  UNSUPPORTED

  // 0x80:
  UNSUPPORTED
  
  // 0x81: STA (indir, X)
  UNSUPPORTED

  // 0x82:
  UNSUPPORTED

  // 0x83:
  UNSUPPORTED

  // 0x84: STY ZP
  UNSUPPORTED

  // 0x85: STA ZP
  UNSUPPORTED

  // 0x86: STX ZP
  UNSUPPORTED

  // 0x87:
  UNSUPPORTED

  // 0x88: DEY
  UNSUPPORTED

  // 0x89:
  UNSUPPORTED

  // 0x8A: TXA
  UNSUPPORTED

  // 0x8B:
  UNSUPPORTED

  // 0x8C: STY Abs
  UNSUPPORTED

  // 0x8D: STA Abs
  .word fetch_adr_lo, fetch_adr_hi, STA_Abs, fetch_next
  .p2align 5

  // 0x8E: STX Abs
  UNSUPPORTED

  // 0x8F:
  UNSUPPORTED

  // 0x90: BCC
  UNSUPPORTED

  // 0x91: STA (indir), Y
  UNSUPPORTED

  // 0x92:
  UNSUPPORTED

  // 0x93:
  UNSUPPORTED

  // 0x94: STY ZP, X
  UNSUPPORTED

  // 0x95: STA ZP, X
  UNSUPPORTED

  // 0x96: STX ZP, Y
  UNSUPPORTED

  // 0x97
  UNSUPPORTED

  // 0x98: TYA
  UNSUPPORTED

  // 0x99: STA Abs, Y
  UNSUPPORTED

  // 0x9A: TXS
  .word TXS, fetch_next
  .p2align 5

  // 0x9B:
  UNSUPPORTED

  // 0x9C:
  UNSUPPORTED

  // 0x9D: STA Abs, X
  UNSUPPORTED

  // 0x9E:
  UNSUPPORTED

  // 0x9F:
  UNSUPPORTED

  // 0xA0: LDY Immed
  UNSUPPORTED

  // 0xA1: LDA (indir, X)
  UNSUPPORTED

  // 0xA2: LDX Immed
  .word LDX_Imm, fetch_next
  .p2align 5

  // 0xA3:
  UNSUPPORTED

  // 0xA4: LDY ZP
  UNSUPPORTED

  // 0xA5: LDA ZP
  UNSUPPORTED

  // 0xA6: LDX ZP
  UNSUPPORTED

  // 0xA7:
  UNSUPPORTED

  // 0xA8: TAY
  UNSUPPORTED

  // 0xA9: LDA Imm
  .word LDA_Imm, fetch_next
  .p2align 5

  // 0xAA: TAX
  UNSUPPORTED

  // 0xAB:
  UNSUPPORTED

  // 0xAC: LDY Abs
  UNSUPPORTED

  // 0xAD: LDA Abs
  .word fetch_adr_lo, fetch_adr_hi, LDA_Abs, fetch_next
  .p2align 5

  // 0xAE: LDX Abs
  UNSUPPORTED

  // 0xAF:
  UNSUPPORTED

  // 0xB0: BCS
  UNSUPPORTED

  // 0xB1: LDA (indir), Y
  UNSUPPORTED

  // 0xB2:
  UNSUPPORTED

  // 0xB3:
  UNSUPPORTED

  // 0xB4: LDY ZP, X
  UNSUPPORTED

  // 0xB5: LDA ZP, X
  UNSUPPORTED

  // 0xB6: LDX ZP, Y
  UNSUPPORTED

  // 0xB7:
  UNSUPPORTED

  // 0xB8: CLV
  UNSUPPORTED

  // 0xB9: LDA Abs, Y
  UNSUPPORTED

  // 0xBA: TSX
  UNSUPPORTED

  // 0xBB:
  UNSUPPORTED

  // 0xBC: LDY Abs, X
  UNSUPPORTED

  // 0xBD: LDA Abs, X
  UNSUPPORTED

  // 0XBE: LDX Abs, Y
  UNSUPPORTED

  // 0xBF:
  UNSUPPORTED

  // 0xC0: CPY Immed
  UNSUPPORTED

  // 0xC1: CMP (indir, X)
  UNSUPPORTED

  // 0xC2:
  UNSUPPORTED

  // 0xC3:
  UNSUPPORTED

  // 0xC4: CPY ZP
  UNSUPPORTED

  // 0xC5: CMP ZP
  UNSUPPORTED

  // 0xC6: DEC ZP
  UNSUPPORTED

  // 0xC7:
  UNSUPPORTED

  // 0xC8: INY
  UNSUPPORTED

  // 0xC9: CMP Imm
  UNSUPPORTED

  // 0xCA: DEX
  UNSUPPORTED

  // 0xCB:
  UNSUPPORTED

  // 0xCC: CPY Abs
  UNSUPPORTED

  // 0xCD: CMP Abs
  UNSUPPORTED

  // 0xCE: DEC Abs
  UNSUPPORTED

  // 0xCF:
  UNSUPPORTED

  // 0xD0: BNE
  UNSUPPORTED

  // 0xD1: CMP (indir), Y
  UNSUPPORTED

  // 0xD2:
  UNSUPPORTED

  // 0xD3:
  UNSUPPORTED

  // 0xD4:
  UNSUPPORTED

  // 0xD5: CMP ZP, X
  UNSUPPORTED

  // 0xD6: DEC ZP, X
  UNSUPPORTED

  // 0xD7:
  UNSUPPORTED

  // 0xD8: CLD
  .word CLD, fetch_next
  .p2align 5

  // 0xD9: CMP Abs, Y
  UNSUPPORTED

  // 0xDA:
  UNSUPPORTED

  // 0xDB:
  UNSUPPORTED

  // 0xDC:
  UNSUPPORTED

  // 0xDD: CMP Abs, X
  UNSUPPORTED

  // 0xDE: DEC Abs, X
  UNSUPPORTED

  // 0xDF:
  UNSUPPORTED

  // 0xE0: CPX Immed
  UNSUPPORTED

  // 0xE1: SBC (indir, X)
  UNSUPPORTED

  // 0xE2:
  UNSUPPORTED

  // 0xE3:
  UNSUPPORTED

  // 0xE4: CPX ZP
  UNSUPPORTED

  // 0xE5: SBC ZP
  UNSUPPORTED

  // 0xE6: INC ZP
  UNSUPPORTED

  // 0xE7:
  UNSUPPORTED

  // 0xE8: INX
  UNSUPPORTED

  // 0xE9: SBC Imm
  UNSUPPORTED

  // 0xEA: NOP
  UNSUPPORTED

  // 0xEB:
  UNSUPPORTED

  // 0xEC: CPX Abs
  UNSUPPORTED

  // 0xED: SBC Abs
  UNSUPPORTED

  // 0xEE: INC Abs
  UNSUPPORTED

  // 0xEF:
  UNSUPPORTED

  // 0xF0: BEQ
  UNSUPPORTED

  // 0xF1: SBC (indir), Y
  UNSUPPORTED

  // 0xF2:
  UNSUPPORTED

  // 0xF3:
  UNSUPPORTED

  // 0xF4:
  UNSUPPORTED

  // 0xF5: SBC ZP, X
  UNSUPPORTED

  // 0xF6: INC ZP, X
  UNSUPPORTED

  // 0xF7:
  UNSUPPORTED

  // 0xF8: SED
  UNSUPPORTED

  // 0xF9: SBC Abs, Y
  UNSUPPORTED

  // 0xFA:
  UNSUPPORTED

  // 0xFB:
  UNSUPPORTED

  // 0xFC:
  UNSUPPORTED

  // 0xFD: SBC Abs, X
  UNSUPPORTED

  // 0xFE: INC Abs, X
  UNSUPPORTED

  // 0xFF:
  UNSUPPORTED

