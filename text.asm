.set noreorder

.set width, 320
.set height, 240

.set console_x, 32
.set console_width, (width-console_x)/8
.set console_y, 32
.set console_max_y, 200
.set console_height, (console_max_y-console_y)/8

.data
console_inited:
  .byte 0

  .align 4
console_row:
  .word 0

.bss
console_buffer:
  .skip (console_width+1)*console_height

.text

// *** init_console

  .globl init_console
init_console:
  sd  $2, 8*0($29)
  sd  $3, 8*1($29)

  la    $2, console_buffer
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

// *** console_write_string

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

// *** console_write_64

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

// *** console_write_32

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

// *** console_write_16

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

// *** console_write_8

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


// *** console_write

console_write:
  /*
    $10: 0 (string), n (number digits)
    $11: message/number
  */

  .set digitlen, $10
  .set message, $11

  sd  $2, 0*8($29)
  sd  $3, 1*8($29)
  sd  $4, 2*8($29)
  sd  $12, 3*8($29)
  sd  $13, 4*8($29)
  mflo $2
  sd  $2, 5*8($29)
  mfhi $2
  sd  $2, 6*8($29)
  sd  $31, 7*8($29)
  addiu $29, 8*8

  //
  .set tmp, $2

  // check init
  lbu tmp, console_inited
  bnez  tmp, console_write_init_ok
  nop
  jal init_console
  nop
console_write_init_ok:

  // check if we need to scroll
  lw  tmp, console_row
  addiu tmp, 1
  sw  tmp, console_row
  addiu tmp, -console_height

  blez tmp, lines_ok
  nop

  // scroll up
  .set scroll_cur, $3
  .set scroll_end, $4
  la  scroll_cur, console_buffer+console_width+1
  la  scroll_end, console_buffer+(console_width+1)*console_height-1

scroll_loop:
  lbu tmp, (scroll_cur)
  sb  tmp, -(console_width+1)(scroll_cur)
  bne scroll_cur, scroll_end, scroll_loop
  addiu scroll_cur, 1

  li tmp, console_height
  sw  tmp, console_row
lines_ok:

  // find the row
  .set dest, $3
  lw  dest, console_row
  addiu dest, -1
  li  tmp, console_width+1
  mult  tmp, dest
  la    dest, console_buffer
  mflo  tmp
  addu  dest, tmp

  // fill in the row in the console
  bnez  digitlen, console_do_number
  nop

  // copy string
  .set width_left, $4

  li  width_left, console_width

console_copy_loop:
  lbu tmp, (message)
  sb  tmp, (dest)
  beqz tmp, console_string_copy_done
  addiu width_left, -1
  addiu message, 1
  bnez  width_left, console_copy_loop
  addiu dest, 1

  // terminate in case of overflow
  b console_string_copy_done
  sb  $0, (dest)

console_do_number:

  // generate number string
  move  $12, dest
  jal number_to_string
  nop

console_string_copy_done:

  addiu $29, -8*8
  ld  $2, 5*8($29)
  mtlo $2
  ld  $2, 6*8($29)
  mthi $2
  ld  $2, 0*8($29)
  ld  $3, 1*8($29)
  ld  $4, 2*8($29)
  ld  $12, 3*8($29)
  ld  $13, 4*8($29)
  ld  $31, 7*8($29)

  jr  $31
  nop

// **** console_render

  .globl console_render
console_render:
  .set rowy, $2
  .set rows, $3
  .set src, $4

  sd  $2, 0*8($29)
  sd  $3, 1*8($29)
  sd  $4, 2*8($29)
  sd  $31, 3*8($29)
  addiu $29, 4*8

  li  rowy, console_y
  li  rows, console_height-1
  la  src,  console_buffer

render_row_loop:
  move  $11, src
  li    $12, console_x
  move  $13, rowy

  jal text_blit
  nop

  addiu rowy, 8
  addiu src, console_width+1

  bnez  rows, render_row_loop
  addiu rows, -1

  addiu $29, -4*8
  ld  $2, 0*8($29)
  ld  $3, 1*8($29)
  ld  $4, 2*8($29)
  ld  $31, 3*8($29)

  jr  $31
  nop

// *** number to string
  .globl number_to_string
number_to_string:
  /*
    $10: digits
    $11: number
    $12: destination
  */

  .set digits, $10
  .set number, $11
  .set dest, $12

  sd  $2, 0*8($29)
  sd  $3, 1*8($29)

  // 0x
  li    tmp, 0x30
  sb    tmp, (dest)
  li    tmp, 0x78
  sb    tmp, 1(dest)
  addiu  dest, 2

  // null terminate
  addu  dest, digits
  sb    $0, (dest)

  addiu digits, -1

  .set digit, $2
digit_loop:
  andi  digit, number, 0xf
  srl   number, 4

  .set char, $3
  la    char, digit_chars
  addu  char, digit

  lb    char, (char)
  addiu dest, -1
  sb    char, (dest)

  bnez  digitlen, digit_loop
  addiu digitlen, -1

  ld  $2, 0*8($29)
  ld  $3, 1*8($29)

  jr    $31
  nop
.data
digit_chars:
  .string "0123456789abcdef"
.text

// *** text_blit

  .globl text_blit

text_blit:
/*
 $11 pointer to null terminated string
 $12 x
 $13 y
*/

.set message, $11
.set xpos, $12
.set ypos, $13


//inputs, $2 through $6, hi and lo are clobbered
  sd  $2, 0*8($29)
  sd  $3, 1*8($29)
  sd  $4, 2*8($29)
  sd  $5, 3*8($29)
  sd  $6, 4*8($29)
  sd  $7, 5*8($29)
  mflo $2
  sd  $2, 5*8($29)
  mfhi $2
  sd  $2, 7*8($29)
  addiu $29, 8*8

text_string:

  .set tmp, $2
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
  .set fb_cur, $3
  move  fb_cur, fb

  lbu   tmp, 0(message)
  beqz  tmp, end_charloop
  .set linecnt, $4
  li    linecnt, 8-1   // 8 lines

  .set bmp_ptr, $5
  sll   bmp_ptr, tmp, 3
  addu  bmp_ptr, bmp

lineloop:
  .set bmp_line, $6
  lbu   bmp_line, 0(bmp_ptr) // line bitmap

  .set pixcnt, $7
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

  addiu $29, -8*8

  ld  $2, 6*8($29)
  mtlo $2
  ld  $2, 7*8($29)
  mthi $2

  ld  $2, 0*8($29)
  ld  $3, 1*8($29)
  ld  $4, 2*8($29)
  ld  $5, 3*8($29)
  ld  $6, 4*8($29)
  ld  $7, 5*8($29)
  jr  $31
  nop

