TARGET = 1802MAX
ASM = asm02
ASMFLAGS = -L -D$(TARGET)
LINK = link02
LINKFLAGS = -i
OBJ =  ledclock.prg led7_lib.prg i2c_lib.prg tobcd8.prg

%.prg: %.asm
	$(ASM) $(ASMFLAGS) $<

ledclock.intel: $(OBJ)
	$(LINK) $(LINKFLAGS) $^

clean:
	rm *.prg *.intel
 
