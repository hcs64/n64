.set noreorder
.text

  .globl _start

// framebuffer setup

_start:

refresh:
  li $4, 0
  jal read_controller
  nop
  move $18, $4

  li $6, 0xf800
  srl $4, 16
  bne $4, $0, red
  nop

  li $6, 0x07c0
 
red:
  jal doubleify
  nop

  li $7, 0
repeat_it:
  
  la $3, framebuffer
  li $4, 240-1
yloop:
  li $5, 320-4
xloop:
  
  sd $6, 0($3)
  addiu $3, 8

  bnez  $5, xloop
  addiu $5, -4

  bnez  $4, yloop
  addiu $4, -1

  bnez  $7, repeat_it
  addiu $7, -1


  li    $10, 0
  la    $11, message
  andi  $12, $18, 0xff00
  srl   $12, 8

.data
message:
  .string "Hello, world!!"
.text

  andi  $2, $12, 0x80
  beqz  $2, pos_x
  nop
  neg   $12
  addiu $12, 0x100
  neg   $12
pos_x:
  addiu $12, 100

  andi  $13, $18, 0xff
  andi  $2, $13, 0x80
  beqz  $2, pos_y
  nop
  neg   $13
  addiu $13, 0x100
  neg   $13
pos_y:
  neg   $13
  addiu $13, 100
  jal   text_blit
  nop

  /*
  li    $10, 8
  move  $11, $31
  li    $12, 100
  li    $13, 108
  jal   text_blit
  nop
  */

  la  $11, message
  jal console_write_string
  nop

.data
message2:
  .string "Hello, world again!!"
.text
  la  $11, message2
  jal console_write_string
  nop

  la $11, 0xdeadbeef
  jal console_write_32
  nop

  la $2, 1
count_loop:
  move $11, $2
  jal console_write_16
  nop

  jal console_render
  nop

  li $3, 10000000
waitloop:
  bnez $3, waitloop
  addiu $3, -1

  b count_loop
  addiu $2, 1

  la  $11, message
  li  $12, 32
  li  $13, 120
  jal   text_blit
  nop


deadloop:
  j deadloop
  nop

  // wait for vblank
  li    $3, 0x202
  lui   $4, 0xa440
vblank_loop:
  lw    $5, 0x10($4)
  nop
  bne   $5, $3, vblank_loop
  nop

  b refresh
  nop

doubleify:
  dsll  $2, $6, 16
  or    $2, $6
  dsll32 $3, $2, 0
  or    $6, $2, $3
  jr    $31
  nop

