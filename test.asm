.set noreorder
.text

  .globl _start
  .globl fb

# framebuffer setup
.set fb, 0xa0200000

_start:
  lui $2, 0xa440
  la  $3, fb
  sw  $3, 4($2)

  li $10, 1

refresh:
  li $4, 0
  jal read_controller
  nop
  move $18, $4

  la $6, red_4_times
  srl $4, 16
  bne $4, $0, red
  nop

  la $6, green_4_times
 
red:
  ld $6, ($6)

  li $7, 0
repeat_it:
  
  la $3, fb
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

  # wait for vblank
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

  la    $3, controller_response-0x80000000+0xa0000000
  lbu   $5, 3($3)
  sll   $4, $5, 24
  lhu   $5, 4($3)
  sll   $5, 8
  or    $4, $5
  lbu   $5, 6($3)
  or    $4, $5

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

  .p2align 6
controller_response:
  .skip 64

message:
  .string "Hello, world!"

  .p2align 3
red_4_times:
  .word 0xf800f800,0xf800f800
green_4_times:
  .word 0x07c007c0,0x07c007c0
