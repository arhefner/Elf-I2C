#include    include/opcodes.def
#include    include/sysconfig.inc
#include    i2c_io.inc

            extrn   i2c_write_byte
            extrn   i2c_read_byte

;------------------------------------------------------------------------
;This library contains routines to implement the i2c protocol using two
;bits of a parallel port. The two bits should be connected to open-
;collector or open-drain drivers such that when the output bit is HIGH,
;the corresponding i2c line (SDA or SCL) is pulled LOW.
;
;The current value of the output port is maintained in register RE.1.
;This allows the routines to manipulate the i2c outputs without
;disturbing the values of other bits on the output port.
;
;The routines are meant to be called using SCRT, with X=R2 being the
;stack pointer.

;------------------------------------------------------------------------
;This routine writes a message to the i2c bus.
;
;Parameters:
;   1: i2c_address     7-bit i2c address (1 byte)
;   2: num_bytes       number of bytes to write (1 byte)
;   3: address         address of message to be written (2 bytes)
;
;Example:
;   This call writes a 17 byte message to the i2c device at address 0x70:
;
;            CALL I2C_WRBUF
;            DB $70,17
;            DW BUFFER
;
; BUFFER:    DB $00
;            DB $06,$00,$5B,$00,$00,$00,$4F,$00
;            DB $66,$00,$00,$00,$00,$00,$00,$00
;
;Register usage:
;   R9.1 maintains the current state of the output port
;
.link       .align  page

            proc    i2c_wrbuf

            ghi     ra
            stxd
            glo     ra
            stxd
            ghi     rd
            stxd
            glo     rd
            stxd
            glo     r9
            stxd
            ghi     rf
            stxd
            glo     rf
            stxd

            ; Set up sep function calls
            mov     ra, i2c_write_byte+1

            ; Read parameters
            lda     r6              ; get i2c address
            shl                     ; add write flag
            phi     rf
            lda     r6              ; get count of bytes to write
            plo     rf              ; and save it.
            lda     r6              ; get high address of buffer
            phi     rd
            lda     r6              ; get low address of buffer
            plo     rd

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure i2c port group
            db      I2C_GROUP
            sex     r2
          #endif

            #include i2c_start.asm

            sep     ra              ; write address + write flag
            bdf     wr_stop         ; report error if no device ack
next_byte:  lda     rd              ; get next byte
            phi     rf
            sep     ra              ; write data byte
            bdf     wr_stop         ; error if device does not ack
            dec     rf
            glo     rf
            bnz     next_byte

wr_stop:
            #include i2c_stop.asm

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure default expander group
            db      NO_GROUP
            sex     r2
          #endif

            irx                     ; restore registers
            ldxa
            plo     rf
            ldxa
            phi     rf
            ldxa
            plo     r9
            ldxa
            plo     rd
            ldxa
            phi     rd
            ldxa
            plo     ra
            ldx
            phi     ra
            rtn

            endp

;------------------------------------------------------------------------
;This routine reads a message from the i2c bus.
;
;Parameters:
;   1: i2c_address     7-bit i2c address (1 byte)
;   2: num_bytes       number of bytes to read (1 byte)
;   3: address         address of message buffer (2 bytes)
;
;Example:
;   This call reads a 2 byte message from the i2c device at address 0x48.
;   On completion, the message is at TEMP_DATA:
;
;   READ_TEMP:  CALL I2C_RDBUF
;               DB $48,2
;               DW TEMP_DATA
;
;   TEMP_DATA:  DS 2
;
;Register usage:
;   R9.1 maintains the current state of the output port
;
            proc    i2c_rdbuf

            ghi     ra
            stxd
            glo     ra
            stxd
            ghi     rb
            stxd
            glo     rb
            stxd
            ghi     rd
            stxd
            glo     rd
            stxd
            glo     r9
            stxd
            ghi     rf
            stxd
            glo     rf
            stxd

            ; Set up sep function calls
            mov     ra, i2c_write_byte+1
            mov     rb, i2c_read_byte+1

            ; Read parameters
            lda     r6              ; get i2c address
            shl
            ori     01h             ; add read flag
            phi     rf
            lda     r6              ; save count of bytes
            smi     01h             ; minus one.
            plo     rf
            lda     r6              ; get high address of buffer
            phi     rd
            lda     r6              ; get low address of buffer
            plo     rd

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure i2c port group
            db      I2C_GROUP
            sex     r2
          #endif

            #include i2c_start.asm

            sep     ra              ; write address + read flag
            bdf     rd_stop

            glo     rf
            bz      rd_last

rd_loop:    sep     rb              ; read next byte
            ghi     rf
            str     rd
            inc     rd

            ; ack
            ghi     r9
            ori     SDA_LOW         ; SDA low
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9

            dec     rf
            glo     rf
            bnz     rd_loop

rd_last:    sep     rb              ; read final byte
            ghi     rf
            str     rd

            ; nak
            ghi     r9
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9

            clc

rd_stop:
            #include i2c_stop.asm

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure default expander group
            db      NO_GROUP
            sex     r2
          #endif

            irx                     ; restore registers
            ldxa
            plo     rf
            ldxa
            phi     rf
            ldxa
            plo     r9
            ldxa
            plo     rd
            ldxa
            phi     rd
            ldxa
            plo     rb
            ldxa
            phi     rb
            ldxa
            plo     ra
            ldx
            phi     ra
            rtn

            endp

.link       .align  page

;------------------------------------------------------------------------
;This routine reads a message from the i2c bus.
;
;Parameters:
;   1: i2c_address     7-bit i2c address (1 byte)
;   2: num_bytes       number of bytes to read (1 byte)
;   3: address         address of message buffer (2 bytes)
;
;Example:
;   This call reads a 2 byte message from the i2c device at address 0x48.
;   On completion, the message is at TEMP_DATA:
;
;   READ_TEMP:  CALL I2C_RDBUF
;               DB $48,2
;               DW TEMP_DATA
;
;   TEMP_DATA:  DS 2
;
;Register usage:
;   R9.1 maintains the current state of the output port
;
            proc    i2c_rdreg

            ghi     ra
            stxd
            glo     ra
            stxd
            ghi     rb
            stxd
            glo     rb
            stxd
            glo     rc
            stxd
            ghi     rd
            stxd
            glo     rd
            stxd
            glo     r9
            stxd
            ghi     rf
            stxd
            glo     rf
            stxd

            ; Set up sep function calls
            mov     ra, i2c_write_byte+1
            mov     rb, i2c_read_byte+1

            ; Read parameters
            lda     r6              ; get i2c address
            shl                     ; add write flag
            plo     rc              ; save shifted address
            phi     rf
            lda     r6              ; get count of bytes to write
            plo     rf              ; and save it.

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure i2c port group
            db      I2C_GROUP
            sex     r2
          #endif

            #include i2c_start.asm

            sep     ra              ; write address + write flag
            bdf     rdr_stop
wloop:      lda     r6              ; get next byte
            phi     rf
            sep     ra              ; write next byte
            bdf     rdr_stop
            dec     rf
            glo     rf
            bnz     wloop

            lda     r6              ; save count of bytes
            smi     01h             ; minus one.
            plo     rf
            lda     r6              ; get high address of buffer
            phi     rd
            lda     r6              ; get low address of buffer
            plo     rd

            ; repeated start
            #include i2c_start.asm

            ; rewrite the i2c address with read bit set
            glo     rc
            ori     01h
            phi     rf
            sep     ra

            glo     rf
            bz      rdr_last

rloop:      sep     rb              ; read next byte
            ghi     rf
            str     rd
            inc     rd

            ; ack
            ghi     r9
            ori     SDA_LOW         ; SDA low
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9

            dec     rf
            glo     rf
            bnz     rloop

rdr_last:   sep     rb              ; read final byte
            ghi     rf
            str     rd

            ; nak
            ghi     r9
            ani     SDA_HIGH        ; SDA high
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9

            clc

rdr_stop:
            #include i2c_stop.asm

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure default expander group
            db      NO_GROUP
            sex     r2
          #endif

            irx                     ; restore registers
            ldxa
            plo     rf
            ldxa
            phi     rf
            ldxa
            plo     r9
            ldxa
            plo     rd
            ldxa
            phi     rd
            ldxa
            plo     rc
            ldxa
            plo     rb
            ldxa
            phi     rb
            ldxa
            plo     ra
            ldx
            phi     ra
            rtn

            endp

.link       .align  page

;------------------------------------------------------------------------
;This routine writes one byte of data (MSB first) on the i2c bus.
;
;Register usage:
;   R2   points to an available memory location (typically top of stack)
;   R9.1 maintains the current state of the output port
;   R9.0 bit counter
;   RF.1 on entry, contains the value to be written to the bus
;
            proc    i2c_write_byte

            sep     r3

            ldi     8
            plo     r9
wr_next:    ghi     rf
            shlc
            phi     rf
            ghi     r9
            bdf     wr_one
            ori     SDA_LOW         ; SDA low
            lskp
wr_one:     ani     SDA_HIGH        ; SDA high
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9              ; update port data
            dec     r9
            glo     r9
            bnz     wr_next
            ; ack/nak
            ghi     r9
            ani     SDA_HIGH        ; SDA high
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
stretch:    b4      stretch
            clc 
            b3      wr_ack
nak:        stc
wr_ack:     ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9

            br      i2c_write_byte

            endp

;------------------------------------------------------------------------
;This routine reads one byte of data (msb first) from the i2c bus.
;
;Register usage:
;   R2   points to an available memory location (typically top of stack)
;   R9.0 bit counter
;   RB.0 on output, contains the value read from to the bus
;
            proc    i2c_read_byte

            sep     r3

            ldi     8
            plo     r9
            ghi     r9
            ani     SDA_HIGH        ; SDA high
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9
rd_next:    ghi     r9
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9
            ghi     rf
            shl
            b3      zero_bit
            ori     01h
zero_bit:   phi     rf
            ghi     r9
            ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9
            dec     r9
            glo     r9
            bnz     rd_next

            br      i2c_read_byte

            endp

;------------------------------------------------------------------------
;This routine attempts to clear a condition where a slave is out of
;sync and is holding the SDA line low.
;
;Register usage:
;   R9.1 maintains the current state of the output port
;
            proc    i2c_clear

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure i2c port group
            db      I2C_GROUP
            sex     r2
          #endif

            ghi     r9
            ani     SDA_HIGH        ; SDA high
            str     r2
            out     I2C_PORT
            dec     r2
            bn3     done            ; if SDA is high, we're done
toggle:     ori     SCL_LOW         ; SCL low
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            b3      toggle          ; keep toggling scl until sda is high
done:       phi     r9

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT        ; make sure default expander group
            db      NO_GROUP
            sex     r2
          #endif

            rtn

            endp
