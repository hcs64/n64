.set noreorder
.text

  .set count, $9
  .set compare, $11
  .set status, $12
  .set cause, $13

  .globl setup_exception_handlers
setup_exception_handlers:
  // disable interrupts
  mfc0  $2, status
  andi  $2, 0x00fe
  mtc0  $2, status

  // install exception vector
  la  $2, exception_vector
  lui $3, 0xa000
  la  $4, exception_vector_last

storeloop:
  lw  $5, ($2)
  sw  $5, 0x180($3)
  cache 0x10, 0x180($3)
  addiu $3, 4
  bne $2, $4, storeloop
  addiu $2, 4

  // disable AI DMA
  sw  $0, 0xa4500008
  // clear AI interrupt
  sw  $0, 0xa450000c
  // clear VI interrupt
  sw  $0, 0xa4400010

  // enable unmask VI, AI interrupt in MIPS
  li  $2, 0x5a5
  sw  $2, 0xa430000c

  // enable interrupt for MIPS
  mfc0  $2, status
  ori   $2, 0x0401
  mtc0  $2, status

  jr  $31
  nop

exception_vector:
  la  $30, exception_handler
  jr  $30
exception_vector_last:
  nop

.set noat
exception_handler:
  la  $30, exception_gprs
  sd $1, 1*8($30)
  sd $2, 2*8($30)
  sd $3, 3*8($30)

.set at
  mfc0  $2, status
  sw  $2, status_save

  mfc0  $2, cause
  andi  $3, $2, 0xff
  beqz  $3, just_an_interrupt
  nop

  la $11, exception_message
  la $12, 32
  la $13, 32
  jal text_blit
  nop

exception_deadend:
  j exception_deadend
  nop

.data
exception_message:
  .string "!!! Exception !!!"

.text

just_an_interrupt:

  // check count interrupt
  andi  $3, $2, 0x8000
  beqz  $3, notcount
  nop

  mtc0  $0,count
  li    $2, 50000000
  mtc0  $2, compare

  j endint
  nop
notcount:

  // check VI interrupt
  lw    $2, 0xa4300008
  andi  $2, 8
  beqz  $2, notvi
  nop

  sw    $0, 0xa4400010 // clear CI int line

  lw    $2, frame_count
  addiu $2, 1
  sw    $2, frame_count

  // swap framebuffers if requested
  lw    $2, ready_framebuffer
  beqz  $2, noswap
  nop

  lw    $2, 0xa4400004
  lui   $3, 0xa000
  addu  $3, $2
  sw    $3, available_framebuffer
  
  lw    $2, ready_framebuffer
  sw    $2, 0xa4400004
  sw    $0, ready_framebuffer
noswap:

.data
  .globl frame_count
frame_count: .word 0
  .global ready_framebuffer
ready_framebuffer: .word 0
  .global available_framebuffer
available_framebuffer: .word 0
.text
notvi:

endint:
  
  la  $30, exception_gprs
  ld $2, 2*8($30)
  ld $3, 3*8($30)
.set noat
  ld $1, 1*8($30)
.set at

  eret
  nop

 .bss
  .align 4
exception_gprs:
  .skip 32*8
status_save:
  .skip 4
