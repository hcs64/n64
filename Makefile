PREFIX=./bin/mips64-elf-
AS=$(PREFIX)as
CPP=cpp
LD=$(PREFIX)ld
OBJCOPY=$(PREFIX)objcopy
CHKSUM64=./bin/chksum64
SFDRIVE=./bin/64drive_usb
HEADER=header

OBJECTS=test.o text.o init.o font.o control.o exception.o panic.o

.PHONY: send clean clean-all 

test.n64: $(OBJECTS)

test.elf: $(OBJECTS)
	$(LD) -T ld.x $^ -o $@

send: test.n64
	sudo $(SFDRIVE) -l test.n64

font.o: font.raw
	$(OBJCOPY) -I binary -O elf32-bigmips -B mips:4000 $< $@

%.n64: %.bin
	cat $(HEADER) $< > $@
	$(CHKSUM64) $@

%.bin: %.elf
	$(OBJCOPY) -O binary --set-section-flag .pad=alloc,contents $< $@

%.o: %.asm
	cpp $< | $(AS) -o $@

clean:
	rm -f $(OBJECTS) test.bin test.elf

clean-all: clean
	rm -f test.n64

