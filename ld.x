SECTIONS {
. = 0x80000400 ;

.text : {
  *(.init)
  *(.text) 
  *(.data) ;

  . = 0x100000 ;
}

.bss : {
  *(.bss)
}

. = . - 0x80000000 + 0xa0000000 ;

.nocachebss : {
  *(.nocachebss)
}


}
