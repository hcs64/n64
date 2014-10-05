.text
.set noreorder

#define text_string(x, y, str) \
  la  $11, 1f  ;\
  li  $12, x   ;\
  jal text_blit;\
  li  $13, y   ;\
.data            ;\
1: .string str   ;\
.text

#define text_value(x, y, value, digits) \
  lw  $11, value                    ;\
  la  $12, exception_number_buffer  ;\
  jal number_to_string              ;\
  li  $10, digits                   ;\
                                     \
  li  $12, x                        ;\
  la  $11, exception_number_buffer  ;\
  jal text_blit                     ;\
  li  $13, y

#define text_reg(x, y, reg, digits) \
  move $11, reg                     ;\
  la  $12, exception_number_buffer  ;\
  jal number_to_string              ;\
  li  $10, digits                   ;\
                                     \
  li  $12, x                        ;\
  la  $11, exception_number_buffer  ;\
  jal text_blit                     ;\
  li  $13, y

.data
exception_number_buffer:
  .string "0x012345670123467"
.text

  .globl panic_screen
panic_screen:

  .set epc, $14
  .set badvaddr, $8
  move $4, $31
  move $5, $10
  mfc0 $6, epc
  mfc0 $7, badvaddr

  lw  $2, 0xA4400004
  lui $3, 0xA000
  or  $2, $3
  sw  $2, active_framebuffer

  text_string(13,24,"Exception ")

  andi    $5,0xff
  srl     $5,2
  text_reg(8*10+13,24,$5,2)

  text_string(8*14+13,24," at PC ")
  text_reg(8*21+13,24,$6,8)

  text_string(13,40,"badvaddr=")
  text_reg(8*9+13,40,$7,8)
/*
  _text_string(13,8*1+40,"$1=          ")
  _text_value(8*3+13,8*1+40,exception_gprs,7)
  _text_string(13,8*2+40,v0val)
  _text_value(8*3+13,8*2+40,v0,7)
  _text_string(13,8*3+40,v1val)
  _text_value(8*3+13,8*3+40,v1,7)
  _text_string(13,8*4+40,a0val)
  _text_value(8*3+13,8*4+40,a0,7)
  _text_string(13,8*5+40,a1val)
  _text_value(8*3+13,8*5+40,a1,7)
  _text_string(13,8*6+40,a2val)
  _text_value(8*3+13,8*6+40,a2,7)
  _text_string(13,8*7+40,a3val)
  _text_value(8*3+13,8*7+40,a3,7)

  _text_string(13,8*8+40,t0val)
  _text_value(8*3+13,8*8+40,t0,7)
  _text_string(13,8*9+40,t1val)
  _text_value(8*3+13,8*9+40,t1,7)
  _text_string(13,8*10+40,t2val)
  _text_value(8*3+13,8*10+40,t2,7)
  _text_string(13,8*11+40,t3val)
  _text_value(8*3+13,8*11+40,t3,7)
  _text_string(13,8*12+40,t4val)
  _text_value(8*3+13,8*12+40,t4,7)
  _text_string(13,8*13+40,t5val)
  _text_value(8*3+13,8*13+40,t5,7)
  _text_string(13,8*14+40,t6val)
  _text_value(8*3+13,8*14+40,t6,7)
  _text_string(13,8*15+40,t7val)
  _text_value(8*3+13,8*15+40,t7,7)

  _text_string(13+108,8*1+40,s0val)
  _text_value(8*3+13+108,8*1+40,s0,7)
  _text_string(13+108,8*2+40,s1val)
  _text_value(8*3+13+108,8*2+40,s1,7)
  _text_string(13+108,8*3+40,s2val)
  _text_value(8*3+13+108,8*3+40,s2,7)
  _text_string(13+108,8*4+40,s3val)
  _text_value(8*3+13+108,8*4+40,s3,7)
  _text_string(13+108,8*5+40,s4val)
  _text_value(8*3+13+108,8*5+40,s4,7)
  _text_string(13+108,8*6+40,s5val)
  _text_value(8*3+13+108,8*6+40,s5,7)
  _text_string(13+108,8*7+40,s6val)
  _text_value(8*3+13+108,8*7+40,s6,7)
  _text_string(13+108,8*8+40,s7val)
  _text_value(8*3+13+108,8*8+40,s7,7)

  _text_string(13+108,8*9+40,t8val)
  _text_value(8*3+13+108,8*9+40,t8,7)
  _text_string(13+108,8*10+40,t9val)
  _text_value(8*3+13+108,8*10+40,t9,7)
  _text_string(13+108,8*11+40,k0val)
  _text_value(8*3+13+108,8*11+40,k0,7)
  _text_string(13+108,8*12+40,k1val)
  _text_value(8*3+13+108,8*12+40,k1,7)
  _text_string(13+108,8*13+40,gpval)
  _text_value(8*3+13+108,8*13+40,gp,7)
  _text_string(13+108,8*14+40,spval)
  _text_value(8*3+13+108,8*14+40,sp,7)

  _text_string(13+108,8*15+40,raval)
  _tpa(lw,t1,rasave)
  _text_value(8*3+13+108,8*15+40,t1,7)
  _text_string(13+108,8*16+40,s8val)
  _tpa(lw,t1,s8save)
  _text_value(8*3+13+108,8*16+40,t1,7)
*/

  jr  $4
  nop
