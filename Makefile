TARGET = 1802MAX
ASM = asm02
ASMFLAGS = -L -D$(TARGET)
LINK = link02
LINKFLAGS = -i
OS_LINKFLAGS = -e -o ledclock.elfos
OBJ =  ledclock.prg led7_lib.prg i2c_lib.prg tobcd8.prg
OS_OBJ = osclock.prg led7_lib.prg i2c_lib.prg tobcd8.prg

%.prg: %.asm
	$(ASM) $(ASMFLAGS) $<

ledclock.elfos: $(OS_OBJ)
	$(LINK) $(OS_LINKFLAGS) $^

ledclock.intel: $(OBJ)
	$(LINK) $(LINKFLAGS) $^

clean:
	rm -f *.prg *.intel *.elfos
 
