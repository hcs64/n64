.set noreorder

.section .init

  .globl _init

# PI init
_init:
  lui $2, 0xbfc0
  lw  $3, 0x07fc($2)
  nop
  ori $3, 8
  sw  $3, 0x07fc($2)
  nop

# disable interrupts
  mfc0  $3, $12
  addiu $4, $0, 0xfffe
  and   $3, $4
  mtc0  $3, $12

  lui $2, 0xa440
  la  $3, 0x00013002
  sw  $3, 0($2)
  li  $3, 320
  sw  $3, 8($2)
  
  # video timing
  la  $3, 0x03e52239
  sw  $3, 20($2)

  # vertical sync
  li  $3, 0x020d
  sw  $3, 24($2)

  # horizontal sync
  li  $3, 0x0c15
  sw  $3, 28($2)
  sll $4, $3, 16
  or  $3, $4, $3
  sw  $3, 32($2)

  # horizontal screen limits
  la  $3, 0x006c02ec
  sw  $3, 36($2)

  # vertical screen limits
  la  $3, 0x002501ff
  sw  $3, 40($2)

  # color burst
  la  $3, 0x000e0204
  sw  $3, 44($2)

  # horizontal scale
  li  $3, 0x200
  sw  $3, 48($2)

  # vertical scale
  li  $3, 0x400
  sw  $3, 52($2)

  j _start
  nop
