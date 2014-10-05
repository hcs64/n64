.set noreorder

.section .init

  .globl _init

  // PI init
_init:
  jal setup_exception_handlers
  nop

  lui $2, 0xbfc0
  lw  $3, 0x07fc($2)
  nop
  ori $3, 8
  sw  $3, 0x07fc($2)
  nop

  // stack
  la  $29, _stack

  // setup VI
  lui $2, 0xa440

  // framebuffer control
  la  $3, 0x00013002
  sw  $3, 0($2)

  // framebuffer address
  la  $3, framebuffer0
  sw  $3, 4($2)
  la  $3, framebuffer1
  sw  $3, active_framebuffer

  // framebuffer width (pixels)
  li  $3, 320
  sw  $3, 8($2)

  // vertical interrupt on line 0
  sw  $0, 12($2)

  // current line (clear interrupt)
  sw  $0, 16($2)
  
  // video timing
  la  $3, 0x03e52239
  sw  $3, 20($2)

  // vertical sync
  li  $3, 0x020d
  sw  $3, 24($2)

  // horizontal sync
  li  $3, 0x0c15
  sw  $3, 28($2)
  sll $4, $3, 16
  or  $3, $4, $3
  sw  $3, 32($2)

  // horizontal screen limits
  la  $3, 0x006c02ec
  sw  $3, 36($2)

  // vertical screen limits
  la  $3, 0x002501ff
  sw  $3, 40($2)

  // color burst
  la  $3, 0x000e0204
  sw  $3, 44($2)

  // horizontal scale
  li  $3, 0x200
  sw  $3, 48($2)

  // vertical scale
  li  $3, 0x400
  sw  $3, 52($2)


  j _start
  nop

.bss
  .p2align 8
_stack: .skip 1024

  .globl active_framebuffer
active_framebuffer:
  .skip 4

.section .nocachebss, "", @nobits
  .p2align 16
  .globl framebuffer0
framebuffer0: .skip 320*240*2
  .globl framebuffer1
framebuffer1: .skip 320*240*2
  .p2align

