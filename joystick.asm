#include include/opcodes.def
#include include/bios.inc
#include include/sysconfig.inc
#include i2c_lib.inc

            org   0100h

start:      mov   r2, $7fff
            mov   r6, main

            lbr   f_initcall

main:       call  f_setbd
            call  f_inmsg             ; display greeting
            db    'Joystick test',10,13,0

            sex   r3

          #if I2C_GROUP
            out   EXP_PORT
            db    I2C_GROUP
          #endif

            out   I2C_PORT            ; init i2c output port
            db    0

          #if I2C_GROUP
            out   EXP_PORT             ; make sure default expander group
            db    NO_GROUP
          #endif

            sex   r2

            ldi   0                   ; current state of port
            phi   r9                  ; is kept in R9.1

            call  i2c_clear

wait:       call  f_inmsg
            db    'Press input',10,13,0

down:       bn4   down
up:         b4    up

            call  i2c_rdreg
            db    $20, 1, 1, 2
            dw    reading

            bdf   i2c_err

            mov   rf, reading
            lda   rf
            phi   rd
            ldn   rf
            plo   rd

            mov   rf, buffer
            call  f_hexout4

            mov   rf, buffer
            call  f_msg

            call  i2c_rdreg
            db    $20, 1, 3, 2
            dw    reading

            bdf   i2c_err

            mov   rf, reading
            lda   rf
            phi   rd
            ldn   rf
            plo   rd

            mov   rf, buffer
            call  f_hexout4

            mov   rf, buffer
            call  f_msg

            call  i2c_rdreg
            db    $20, 1, 5, 2
            dw    reading

            bdf   i2c_err

            mov   rf, reading
            lda   rf
            phi   rd
            ldn   rf
            plo   rd

            mov   rf, buffer
            call  f_hexout4

            mov   rf, buffer
            call  f_msg

            lbr   wait

i2c_err:    call  f_inmsg
            db    'i2c device returned nak',10,13,0

            lbr   wait

reading:    ds    2
buffer:     db    0,0,0,0,10,13,0

            end   start
