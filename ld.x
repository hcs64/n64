SECTIONS {
. = 0x80000400 ;

.text : {
  *(.init)
  *(.text) 
  *(.data) ;

  . = 0x100000 ;
}

}
