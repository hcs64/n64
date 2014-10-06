// 1K pages
.text
.set noreorder

  .globl init_ppu_address_space
init_ppu_address_space:
  // hardcoded to 8k CHRROM, vertical mirroring  for now

  sd  $10, 0*8($29)
  sd  $31, 1*8($29)
  addiu $29, 2*8

  la  $10, _binary_nes_chr_raw_start
  jal setup_8k_CHRROM
  nop

  jal setup_vertical_mirroring
  nop

  jal setup_mirror_traps
  nop

  addiu $29, -2*8
  ld  $10, 0*8($29)
  ld  $31, 1*8($29)

  jr  $31
  nop

setup_pattern_0:
  /* $10: pattern table #0 (0x0000-0x1000) */

  sw  $10, ppu_read_address_map+0
  sw  $10, ppu_read_address_map+4
  sw  $10, ppu_read_address_map+8
  sw  $10, ppu_read_address_map+12

  sw  $10, ppu_write_address_map+0
  sw  $10, ppu_write_address_map+4
  sw  $10, ppu_write_address_map+8
  sw  $10, ppu_write_address_map+12

  jr  $31
  nop

setup_pattern_1:
  /* $10: pattern table #1 (0x1000-0x2000) */
  
  addiu $10, -0x1000

  sw  $10, ppu_read_address_map+16
  sw  $10, ppu_read_address_map+20
  sw  $10, ppu_read_address_map+24
  sw  $10, ppu_read_address_map+28

  sw  $10, ppu_write_address_map+16
  sw  $10, ppu_write_address_map+20
  sw  $10, ppu_write_address_map+24
  sw  $10, ppu_write_address_map+28

  jr  $31
  nop

setup_8k_CHRROM:
  /* $10: ROM address */

  sd  $31, 0*8($29)
  addiu $29, 1*8

  jal setup_pattern_0
  nop

  addiu $10, 0x1000
  jal setup_pattern_1
  nop

  addiu $29, -1*8
  ld  $31, 0*8($29)

  jr  $31
  nop
  
setup_horizontal_mirroring:
  sd  $2, 0*8($29)

  /* addr 0x2000-0x2400 -> VRAM 0x0000-0x0400 */
  la  $2, VRAM-0x2000
  sw  $2, ppu_read_address_map+32  
  sw  $2, ppu_write_address_map+32  
  /* addr 0x2400-0x2800 -> VRAM 0x0000-0x0400 */
  la  $2, VRAM-0x2400
  sw  $2, ppu_read_address_map+36
  sw  $2, ppu_write_address_map+36
  /* addr 0x2800-0x2C00 -> VRAM 0x0400-0x0800 */
  la  $2, VRAM-0x2400
  sw  $2, ppu_read_address_map+40
  sw  $2, ppu_write_address_map+40
  /* addr 0x2C00-0x3000 -> VRAM 0x0400-0x0800 */
  la  $2, VRAM-0x2800
  sw  $2, ppu_read_address_map+44
  sw  $2, ppu_write_address_map+44

  ld  $2, 0*8($29)

  jr  $31
  nop

setup_vertical_mirroring:
  sd  $2, 0*8($29)

  /* addr 0x2000-0x2400 -> VRAM 0x0000-0x0400 */
  la  $2, VRAM-0x2000
  sw  $2, ppu_read_address_map+32  
  sw  $2, ppu_write_address_map+32  
  /* addr 0x2400-0x2800 -> VRAM 0x0400-0x0800 */
  la  $2, VRAM-0x2000
  sw  $2, ppu_read_address_map+36
  sw  $2, ppu_write_address_map+36
  /* addr 0x2800-0x2C00 -> VRAM 0x0000-0x0400 */
  la  $2, VRAM-0x2800
  sw  $2, ppu_read_address_map+40
  sw  $2, ppu_write_address_map+40
  /* addr 0x2C00-0x3000 -> VRAM 0x0400-0x0800 */
  la  $2, VRAM-0x2800
  sw  $2, ppu_read_address_map+44
  sw  $2, ppu_write_address_map+44

  ld  $2, 0*8($29)

  jr  $31
  nop

setup_mirror_traps:
  sd  $2, 0*8($29)

  la  $2, vram_end_read_handler-0x80000000
  sw  $2, ppu_read_address_map+48
  la  $2, vram_end_write_handler-0x80000000
  sw  $2, ppu_write_address_map+48

  la  $2, vram_end_read_handler-0x80000000
  sw  $2, ppu_read_address_map+52
  la  $2, vram_end_write_handler-0x80000000
  sw  $2, ppu_write_address_map+52

  la  $2, vram_end_read_handler-0x80000000
  sw  $2, ppu_read_address_map+56
  la  $2, vram_end_write_handler-0x80000000
  sw  $2, ppu_write_address_map+56

  la  $2, vram_end_read_handler-0x80000000
  sw  $2, ppu_read_address_map+60
  la  $2, vram_end_write_handler-0x80000000
  sw  $2, ppu_write_address_map+60

  ld  $2, 0*8($29)

  jr  $31
  nop

vram_end_read_handler:
  jr  $31
  nop

vram_end_write_handler:
  jr  $31
  nop

.bss
VRAM:
  .skip 0x800
extra_VRAM:
  .skip 0x800

  .globl ppu_write_address_map

ppu_write_address_map:
  .skip 0x10*4

  .global ppu_read_address_map
ppu_read_address_map:
  .skip 0x10*4

