// 2K pages
.text
.set noreorder

  .globl init_cpu_address_space
init_cpu_address_space:
  sd  $2, 0*8($29)
  sd  $3, 1*8($29)
  sd  $10, 2*8($29)
  sd  $31, 3*8($29)
  addiu $29, 4*8

  // RAM

  // 0x0000-0x0800 -> RAM 0x0000-0x0800
  la  $2, NES_RAM
  sw  $2, cpu_read_address_map+0
  sw  $2, cpu_write_address_map+0

  // 0x0800-0x1000 -> RAM 0x0000-0x0800
  la  $2, NES_RAM-0x800
  sw  $2, cpu_read_address_map+4
  sw  $2, cpu_write_address_map+4

  // 0x1000-0x1800 -> RAM 0x0000-0x0800
  la  $2, NES_RAM-0x1000
  sw  $2, cpu_read_address_map+8
  sw  $2, cpu_write_address_map+8
 
  // 0x1800-0x2000 -> RAM 0x0000-0x0800
  la  $2, NES_RAM-0x1800
  sw  $2, cpu_read_address_map+12
  sw  $2, cpu_write_address_map+12
 
  // 0x2000-0x4000 - PPU registers
  la  $2, read_handler_2000-0x80000000
  la  $3, write_handler_2000-0x80000000

  sw  $2, cpu_read_address_map+16
  sw  $3, cpu_write_address_map+16

  sw  $2, cpu_read_address_map+20
  sw  $3, cpu_write_address_map+20

  sw  $2, cpu_read_address_map+24
  sw  $3, cpu_write_address_map+24

  sw  $2, cpu_read_address_map+28
  sw  $3, cpu_write_address_map+28

  // 0x4000-0x6000 - APU registers/cartridge space
  la  $2, read_handler_4000-0x80000000
  la  $3, write_handler_4000-0x80000000

  sw  $2, cpu_read_address_map+32
  sw  $3, cpu_write_address_map+32

  sw  $2, cpu_read_address_map+36
  sw  $3, cpu_write_address_map+36

  sw  $2, cpu_read_address_map+40
  sw  $3, cpu_write_address_map+40

  sw  $2, cpu_read_address_map+44
  sw  $3, cpu_write_address_map+44

  // 0x6000-0x8000 SRAM
  la  $2, NES_SRAM-0x6000
  sw  $2, cpu_read_address_map+48
  sw  $2, cpu_write_address_map+48

  sw  $2, cpu_read_address_map+52
  sw  $2, cpu_write_address_map+52

  sw  $2, cpu_read_address_map+56
  sw  $2, cpu_write_address_map+56

  sw  $2, cpu_read_address_map+60
  sw  $2, cpu_write_address_map+60


  // 0x8000- PRGROM
  la  $10, _binary_nes_prg_raw_start
  jal setup_32k_PRGROM
  nop

  jal setup_rom_write_handlers
  nop

  addiu $29, -4*8
  ld  $2, 0*8($29)
  ld  $3, 1*8($29)
  ld  $10, 2*8($29)
  ld  $31, 3*8($29)
  
  jr  $31
  nop

setup_32k_PRGROM:
  /* $10 PRGROM */
  addiu $10, -0x8000

  // 0x8000-0xA000
  sw  $10, cpu_read_address_map+64
  sw  $10, cpu_read_address_map+68
  sw  $10, cpu_read_address_map+72
  sw  $10, cpu_read_address_map+76

  // 0xA000-0xC000
  sw  $10, cpu_read_address_map+80
  sw  $10, cpu_read_address_map+84
  sw  $10, cpu_read_address_map+88
  sw  $10, cpu_read_address_map+92

  // 0xC000-0xE000
  sw  $10, cpu_read_address_map+96
  sw  $10, cpu_read_address_map+100
  sw  $10, cpu_read_address_map+104
  sw  $10, cpu_read_address_map+108

  // 0xE000-
  sw  $10, cpu_read_address_map+112
  sw  $10, cpu_read_address_map+116
  sw  $10, cpu_read_address_map+120
  sw  $10, cpu_read_address_map+124

  jr  $31
  nop

setup_16k_PRGROM:
  /* $10 PRGROM */
  addiu $10, -0x8000

  // 0x8000-0xA000
  sw  $10, cpu_read_address_map+64
  sw  $10, cpu_read_address_map+68
  sw  $10, cpu_read_address_map+72
  sw  $10, cpu_read_address_map+76

  // 0xA000-0xC000
  sw  $10, cpu_read_address_map+80
  sw  $10, cpu_read_address_map+84
  sw  $10, cpu_read_address_map+88
  sw  $10, cpu_read_address_map+92

  addiu $10, -0x8000

  // 0xC000-0xE000
  sw  $10, cpu_read_address_map+96
  sw  $10, cpu_read_address_map+100
  sw  $10, cpu_read_address_map+104
  sw  $10, cpu_read_address_map+108

  // 0xE000-
  sw  $10, cpu_read_address_map+112
  sw  $10, cpu_read_address_map+116
  sw  $10, cpu_read_address_map+120
  sw  $10, cpu_read_address_map+124

  jr  $31
  nop

setup_rom_write_handlers:
  sd  $2, ($29)

  // 0x8000-0xA000
  la  $2, write_handler_8000-0x80000000
  sw  $2, cpu_write_address_map+64
  sw  $2, cpu_write_address_map+68
  sw  $2, cpu_write_address_map+72
  sw  $2, cpu_write_address_map+76

  // 0xA000-0xC000
  la  $2, write_handler_A000-0x80000000
  sw  $2, cpu_write_address_map+80
  sw  $2, cpu_write_address_map+84
  sw  $2, cpu_write_address_map+88
  sw  $2, cpu_write_address_map+92

  // 0xC000-0xE000
  la  $2, write_handler_C000-0x80000000
  sw  $2, cpu_write_address_map+96
  sw  $2, cpu_write_address_map+100
  sw  $2, cpu_write_address_map+104
  sw  $2, cpu_write_address_map+108

  // 0xE000-
  la  $2, write_handler_E000-0x80000000
  sw  $2, cpu_write_address_map+112
  sw  $2, cpu_write_address_map+116
  sw  $2, cpu_write_address_map+120
  sw  $2, cpu_write_address_map+124

  ld  $2, ($29)

  jr  $31
  nop

write_handler_8000:
write_handler_A000:
write_handler_C000:
write_handler_E000:
  jr  $31
  nop

write_handler_2000:
  /* $3: scratch */
  /* $10: byte to write */
  /* $11: address */

  sd  $31, 0*8($29)
  addiu $29, 1*8

  jal console_write_16
  nop

  jal console_write_8
  move  $11, $10

  addiu $29, -1*8
  ld  $31, 0*8($29)
  jr  $31
  nop
write_handler_4000:
  jr  $31
  nop

read_handler_2000:
read_handler_4000:
  jr  $31
  nop

.data
  .p2align 15

.bss
  .globl NES_RAM
NES_RAM:
  .skip 0x800
    
  .globl NES_SRAM
  .p2align 6
NES_SRAM:
  .skip 0x2000

  .globl cpu_write_address_map
cpu_write_address_map:
  .skip 0x20*4

  .globl cpu_read_address_map
cpu_read_address_map:
  .skip 0x20*4
