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

//inputs and $2 through $8 are clobbered
text_blit:
  beqz  $10, text_string
  nop

  la    $2, text_buffer+2
  addu  $2, $10
  sb    $0, 0($2)

  addiu $10, -1

digit_loop:
  andi  $4, $11, 0xf
  srl   $11, 4
  la    $3, digits
  addu  $3, $4

  lb    $3, ($3)
  addiu $2, -1
  sb    $3, ($2)

  bnez  $10, digit_loop
  addiu $10, -1

  la    $11, text_buffer

text_string:

  li    $2, width
  mult  $13,  $2
  mflo  $13
  addu  $13, $12
  sll   $13, 1
  la    $2, framebuffer
  addu  $13, $2     // $13 is current framebuffer address

  li    $12, 0xfffe // $12 is text color
  la    $2, _binary_font_raw_start  // $2 is font bitmap


charloop:
  move  $8, $13  // $14 is the current pixel of the character

  lbu   $10, 0($11)
  beqz  $10, end_charloop
  li    $3, 8-1   // 8 lines

  sll   $4, $10, 3
  addu  $4, $2
lineloop:
  lbu   $5, 0($4) // line bitmap
  li    $6, 8-1   // 8 pixels

pixloop:
  andi  $7, $5, 0x80
  sll   $5, 1
  beqz  $7, black
  li    $7, 0
  move  $7, $12
black:
  sh    $7, 0($8)
  addiu $8, 2
  bnez  $6, pixloop
  addiu $6, -1

  addiu $8, -(8*2)+width*2
  addiu $4, 1
  bnez  $3, lineloop
  addiu $3, -1

  addiu $13, 8*2
  b charloop
  addiu $11, 1

end_charloop:
  jr  $31
  nop

.data
digits:
  .string "0123456789abcdef"
text_buffer:
  .string "0x01234567"
