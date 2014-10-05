.set noreorder
.text

  .globl _start

// framebuffer setup

_start:
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

//// main loop
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

  li $7, 10
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


    jal console_render
  nop

  jal poll_controller
  nop

mfc0 $12, $9
  // wait for vblank
  li    $3, 200 //0x202
  lui   $4, 0xa440
vblank_loop:
  lw    $5, 0x10($4)
  nop
  bne   $5, $3, vblank_loop
  nop

  mfc0  $11, $9
  move  $14, $11
  jal console_write_32
  nop
  subu  $11, $14, $12
  jal console_write_32
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

