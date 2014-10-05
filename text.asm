.set noreorder

.text

.set width, 320
.set height, 240

.set console_x, 32
.set console_width, (width-console_x)/8
.set console_y, 32
.set console_height, (height-console_y)/8

  .globl init_console
init_console:
  sd  $2, 8*0($29)
  sd  $3, 8*1($29)

  la    $2, console_buffer+console_width
  li    $3, console_height

console_init_loop:
  sb    $0, ($2)
  addiu $3, -1
  bnez  $3, console_init_loop
  addiu $2, console_width+1

  li  $2, 0
  sw  $2, console_row

  li  $3, 1
  sb  $3, console_inited

  ld  $2, 8*0($29)
  ld  $3, 8*1($29)
  jr  $31
  nop

  .globl console_write_string
console_write_string:
  /* $11: string ptr */

  sd  $10, 0*8($29)
  sd  $31, 1*8($29)
  addiu $29, 2*8

  jal console_write
  li  $10, 0
  
  addiu $29, -2*8
  ld  $10, 0*8($29)
  ld  $31, 1*8($29)

  jr  $31
  nop

  .globl console_write_64
console_write_64:
  /* $11: string ptr */

  sd  $10, 0*8($29)
  sd  $31, 1*8($29)
  addiu $29, 2*8

  jal console_write
  li  $10, 16
  
  addiu $29, -2*8
  ld  $10, 0*8($29)
  ld  $31, 1*8($29)

  jr  $31
  nop

  .globl console_write_32
console_write_32:
  /* $11: string ptr */

  sd  $10, 0*8($29)
  sd  $31, 1*8($29)
  addiu $29, 2*8

  jal console_write
  li  $10, 8
  
  addiu $29, -2*8
  ld  $10, 0*8($29)
  ld  $31, 1*8($29)

  jr  $31
  nop

  .globl console_write_16
console_write_16:
  /* $11: string ptr */

  sd  $10, 0*8($29)
  sd  $31, 1*8($29)
  addiu $29, 2*8

  jal console_write
  li  $10, 4
  
  addiu $29, -2*8
  ld  $10, 0*8($29)
  ld  $31, 1*8($29)

  jr  $31
  nop

  .globl console_write_8
console_write_8:
  /* $11: string ptr */

  sd  $10, 0*8($29)
  sd  $31, 1*8($29)
  addiu $29, 2*8

  jal console_write
  li  $10, 2
  
  addiu $29, -2*8
  ld  $10, 0*8($29)
  ld  $31, 1*8($29)

  jr  $31
  nop

  .globl console_write
console_write:
  /*
    $10: 0 (string), n (number digits)
    $11: message/number
  */

  sd  $12, 0*8($29)
  sd  $13, 1*8($29)
  sd  $31, 2*8($29)
  addiu $29, 3*8

  lbu $12, console_inited

  bnez  $12, console_write_init_ok
  nop
  jal init_console
  nop
console_write_init_ok:

  lw  $13, console_row
  sll $13, 3
  addiu $13, console_y
  li  $12, console_x

  jal text_blit
  nop

  lw  $13, console_row
  addiu $13, 1
  li  $12, console_height

  blt $13, $12, lines_ok
  nop
  li $13, console_height-1
lines_ok:
  sw  $13, console_row

  addiu $29, -3*8
  ld  $12, 0*8($29)
  ld  $13, 1*8($29)
  ld  $31, 2*8($29)

  jr  $31
  nop

.data
console_inited:
  .byte 0
  .align 4
console_row:
  .word 0

.bss
console_buffer:
  .skip (console_width+1)*(console_height+3)  // +3 extra rows for "safety"

.text

  .globl text_blit

text_blit:
/*
 $10 length if numeric, 0 if string
 $11 number if numeric, else pointer to null terminated string
 $12 x
 $13 y
*/

.set digitlen, $10
.set number, $11
.set message, $11
.set xpos, $12
.set ypos, $13


//inputs, $2 through $6, hi and lo are clobbered
  sd  $2, 0*8($29)
  sd  $3, 1*8($29)
  sd  $4, 2*8($29)
  sd  $5, 3*8($29)
  sd  $6, 4*8($29)
  mflo $2
  sd  $2, 5*8($29)
  mfhi $2
  sd  $2, 6*8($29)
  addiu $29, 7*8

  beqz  digitlen, text_string
  nop

  .set ptr, $2
  // null terminate
  la    ptr, text_buffer+2
  addu  ptr, digitlen
  sb    $0, (ptr)

  addiu digitlen, -1

  .set digit, $4
digit_loop:
  andi  digit, number, 0xf
  srl   number, 4

  .set char, $3
  la    char, digit_chars
  addu  char, digit

  lb    char, (char)
  addiu ptr, -1
  sb    char, (ptr)

  bnez  digitlen, digit_loop
  addiu digitlen, -1

  la    message, text_buffer

  // no more use of digitlen ($10)

text_string:

  .set tmp, $10
  li    tmp, width
  mult  ypos, tmp // no more use of ypos ($13)

  .set fb, $13
  mflo  fb
  addu  fb, xpos  // no more use of xpos ($12)
  sll   fb, 1
  la    tmp, framebuffer
  addu  fb, tmp

  .set bmp, $12
  la    bmp, _binary_font_raw_start


charloop:
  .set fb_cur, $2
  move  fb_cur, fb

  lbu   tmp, 0(message)
  beqz  tmp, end_charloop
  .set linecnt, $3
  li    linecnt, 8-1   // 8 lines

  .set bmp_ptr, $4
  sll   bmp_ptr, tmp, 3
  addu  bmp_ptr, bmp

lineloop:
  .set bmp_line, $5
  lbu   bmp_line, 0(bmp_ptr) // line bitmap

  .set pixcnt, $6
  li    pixcnt, 8-1   // 8 pixels

pixloop:
  andi  tmp, bmp_line, 0x80
  sll   bmp_line, 1
  beqz  tmp, black
  li    tmp, 0  // black background
  li    tmp, 0xfffe // white foreground
black:
  sh    tmp, (fb_cur)
  addiu fb_cur, 2
  bnez  pixcnt, pixloop
  addiu pixcnt, -1

  addiu fb_cur, -(8*2)+width*2  // next line of framebuffer
  addiu bmp_ptr, 1  // next line of bitmap
  bnez  linecnt, lineloop
  addiu linecnt, -1

  addiu fb, 8*2
  b charloop
  addiu message, 1

end_charloop:

  addiu $29, -7*8

  ld  $2, 5*8($29)
  mtlo $2
  ld  $2, 6*8($29)
  mthi $2

  ld  $2, 0*8($29)
  ld  $3, 1*8($29)
  ld  $4, 2*8($29)
  ld  $5, 3*8($29)
  ld  $6, 4*8($29)
  jr  $31
  nop

.data
digit_chars:
  .string "0123456789abcdef"
text_buffer:
  .string "0x0123456701234567"
