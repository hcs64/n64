.set noreorder

.text

.set width, 320
  .globl text_blit

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


//inputs and $2 through $6 are clobbered
text_blit:
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
  jr  $31
  nop

.data
digit_chars:
  .string "0123456789abcdef"
text_buffer:
  .string "0x01234567"
