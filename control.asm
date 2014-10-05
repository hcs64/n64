.set noreorder
.text
  .globl read_controller

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


