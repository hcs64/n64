.set noreorder
.text

  .globl _start

_start:
.data
message:
  .string "Hello, world!"
message2:
  .string "Hello, world again!!"
.text
  la  $11, message
  jal console_write_string
  nop

  la  $11, message2
  jal console_write_string
  nop

  la $11, 0xdeadbeef
  jal console_write_32
  nop

  jal init_cpu
  nop
  jal run_cpu_cycle
  nop
  jal run_cpu_cycle
  nop
  jal run_cpu_cycle
  nop

//// main loop
refresh:
  // read controller buttons
  li $4, 0
  jal read_controller
  nop
  move $18, $4

  // fill background
  li $6, 0x07c0
  srl $4, 16
  beq $4, $0, green
  nop

  li $6, 0xf800
  //lw $7, 0xdeadbeef
  //div $6, $0
 
green:
  jal doubleify
  nop

  li $7, 0
repeat_it:
  
  lw $3, active_framebuffer
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


  // render joystick feedback

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

  // render the console on top of everything else
  jal console_render
  nop

  // framebuffer is now complete for this frame
  lw  $2, active_framebuffer
  sw  $2, ready_framebuffer

  // poll controller for next time
  jal poll_controller
  nop

  lw $11, my_frame_count
  addiu $11, 1
  sw  $11, my_frame_count

.data
my_frame_count:
  .word 0
.text

  // wait for that frame to be displayed
ready_wait:
  lw    $2, ready_framebuffer
  bnez  $2, ready_wait
  nop

  lw    $2, available_framebuffer
  sw    $2, active_framebuffer

  // loop!
  b refresh
  nop

doubleify:
  dsll  $2, $6, 16
  or    $2, $6
  dsll32 $3, $2, 0
  or    $6, $2, $3
  jr    $31
  nop

