SECTIONS {
. = 0x80000400 ;

.text : {
  *(.init)
  *(.text) ;
}

.data : {
  *(.data) ;
}

rom_end = . ;
.pad : {
  . = 0x80100400 - rom_end ;
}


.bss : {
  *(.bss)
}

. = . - 0x80000000 + 0xa0000000 ;

.nocachebss : {
  *(.nocachebss)
}


}
