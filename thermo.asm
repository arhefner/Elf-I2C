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
            db    'Thermometer test',10,13,0

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

wait:       call  f_inmsg
            db    'Press input',10,13,0

down:       bn4   down
up:         b4    up

            call  i2c_rdreg
            db    $48, 1, 0, 2
            dw    temp

            mov   rf, temp
            lda   rf
            phi   rd
            ldn   rf
            plo   rd

            mov   rf, buffer
            call  f_hexout4

            mov   rf, buffer
            call  f_msg

            call  i2c_rdreg
            db    $60, 1, 0, 1
            dw    temp

            mov   rf, temp
            ldn   rf
            plo   rd

            mov   rf, buffer
            call  f_hexout2

            mov   rf, buffer
            call  f_msg

            br    wait

temp:       ds    2
buffer:     db    0,0,0,0,10,13,0

            end   start
