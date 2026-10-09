            ; Include kernel API entry points

#include include/sysconfig.inc
#include include/opcodes.def
#include include/bios.inc
#include include/kernel.inc
#include i2c_lib.inc
#include led7_lib.inc

            extrn   tobcd8

            org     2000h
start:      br      main

            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-I2C for more info',0


            ; Main code starts here, check provided argument

main:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     main
            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get byte
            lbz     temp                ; jump if no argument given
            call    o_inmsg             ; otherwise display usage message
            db      'Usage: temp',10,13,0
            ldi     $0a
            rtn                         ; and return to os

temp:       sex     r3

          #if I2C_GROUP
            out     EXP_PORT
            db      I2C_GROUP
          #endif

            out     I2C_PORT            ; init i2c output port
            db      0

            sex     r2

            ldi     0                   ; current state of port
            phi     r9                  ; is kept in R9.1

            call    led7_init

            ldi     LED7_BLINK_OFF
            plo     rb
            call    led7_set_blink_rate

            ldi     10
            plo     rb
            call    led7_set_brightness

            call    i2c_rdreg
            db      $48, 1, 0, 2          ; read temperature from LM75A
            dw      temp

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT              ; make sure default expander group
            db      NO_GROUP
            sex     r2
          #endif

            mov     ra, temp
            lda     ra
            plo     rd
            ani     $80
            lsz
            ldi     $ff
            phi     rd

            mov     rf, buffer
            call    f_intout

            mov     rd,rf

            ldn     ra
            ani     $80
            bz      finish

            mov     rf, half_str
            call    f_strcpy

finish:     mov     rf, unit_str
            call    f_strcpy

            mov     rf, buffer
            call    o_msg

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT
            db      I2C_GROUP
            sex     r2
          #endif

            call    i2c_wrbuf             ; clear status of SHT31 temp/humidity
            db      $44, 3                ; sensor
            dw      clr_status

            call    i2c_rdreg
            db      $44, 2, $F3, $2D, 3   ; read temp/humidity status
            dw      sensor_buf

          #if I2C_GROUP
            sex     r3
            out     EXP_PORT              ; make sure default expander group
            db      NO_GROUP
            sex     r2
          #endif

            mov     ra, sensor_buf
            lda     ra
            phi     rd
            ldn     ra
            plo     rd

            mov     rf, sensor_out
            call    f_hexout4

            mov     rd, rf
            mov     rf, eol
            call    f_strcpy

            mov     rf, sensor_out
            call    o_msg

            ldi     0
            rtn

temp_buf:   ds      2
buffer:     ds      12
half_str:   db      '.5',0
unit_str:   db      'C',10,13,0

sensor_buf: ds      3
sensor_out: ds      8
eol:        db      10,13,0

clr_status: db      $30,$41,$3F

            end     start
