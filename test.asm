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

  li    $10, 8
  move  $11, $31
  li    $12, 100
  li    $13, 108
  jal   text_blit
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

read_controller:
  lui   $2, 0xa480

/*
DANGER!
busy1:
  lw    $3, 0x18($2)
  andi  $3, 3
  bnez  $3, busy1
  nop
  */

  la    $3, controller_command-0x80000000
  sw    $3, 0($2)
  la    $3, 0x1fc007c0
  sw    $3, 0x10($2)
  
  nop

busy2:
  lw    $3, 0x18($2)
  nop
  andi  $3, 3
  bnez  $3, busy2
  nop

  la    $3, controller_response-0x80000000
  sw    $3, 0($2)
  la    $3, 0x1fc007c0
  sw    $3, 0x4($2)

  nop

busy3:
  lw    $3, 0x18($2)
  andi  $3, 3
  bnez  $3, busy3
  nop

  la    $3, controller_response
  lbu   $5, 3($3)
  sll   $4, $5, 24
  lhu   $5, 4($3)
  sll   $5, 8
  or    $4, $5
  lbu   $5, 6($3)
  or    $4, $5

  jr    $31
  nop

doubleify:
  dsll  $2, $6, 16
  or    $2, $6
  dsll32 $3, $2, 0
  or    $6, $2, $3
  jr    $31
  nop

.data

  .p2align 6

controller_command:
  /* write 1, read 4 */
  .byte 1,4
  /* command */
  .byte 1
  /* space for result */
  .byte 0,0,0,0
  /* end */
  .byte 0xfe

  /* padding */
  .rep 64-8-1
  .byte 0
  .endr

  /* command ready */
  .byte 1

.section .nocachebss, "", @nobits
  .p2align 6
controller_response:
  .skip 64

.data

message:
  .string "Hello, world!"
