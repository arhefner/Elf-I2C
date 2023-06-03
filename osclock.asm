            ; Include kernel API entry points

#include include/opcodes.def
#include include/kernel.inc
#include include/sysconfig.inc
#include led7_lib.inc

            extrn   tobcd8

#define RTC_REG         20h

#define CLEAR_INT       10h

#define RATE_64HZ       10h
#define RATE_1_PER_SEC  14h
#define RATE_1_PER_MIN  18h
#define RATE_1_PER_HR   1ch

#define INT_ENABLE      10h
#define INT_MASK        11h

#define PULSE_MODE      10h
#define INT_MODE        12h

#define RTC_INT_ENABLE  41h
#define RTC_INT_DISABLE 40h


            org     2000h
start:      br      main


            ; Build information

            ever

            db    'See github.com/arhefner/Elfos-osclock for more info',0


            ; Main code starts here, check provided argument

main:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     main
            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get byte
            lbz     clock               ; jump if no argument given
            call    o_inmsg             ; otherwise display usage message
            db      'Usage: osclock',10,13,0
            ldi     $0a
            rtn                         ; and return to os

clock:      call    o_inmsg             ; display greeting
            db      'LED Clock',10,13,0

            sex     r3

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

            mov     r1, introu

            ldi     1
            plo     r8

            sex     r3

          #if RTC_GROUP != I2C_GROUP
            out     EXP_PORT
            db      RTC_GROUP
          #endif

            out     RTC_PORT
            db      RTC_REG | 0eh
            out     RTC_PORT
            db      RATE_1_PER_SEC | INT_MODE | INT_ENABLE

            out     RTC_PORT
            db      RTC_INT_ENABLE

          #if RTC_GROUP
            out     EXP_PORT              ; make sure default expander group
            db      NO_GROUP
          #endif

            ret
            db      23h

wait:       bn4     test
            lbr     done
test:       glo     r8
            bnz     wait

            ldi     1
            plo     r8

            mov     rf, time_buf
            call    o_gettod

            mov     rf, time_buf+3

            ldn     rf
            bz      hr12
            smi     12
            bz      hr12
            bge     disphr
            ldn     rf
            lskp

hr12:       ldi     12

disphr:     plo     rc
            mov     rf, bcd_buf
            call    tobcd8

            ldi     0
            plo     ra
            mov     rf, tens
            ldn     rf
            bz      lead0
            plo     rb
            call    led7_write_digit
            lskp

lead0:      call    led7_write_blank      

disphr1:    mov     rf, ones
            ldn     rf
            plo     rb
            ldi     1
            plo     ra
            call    led7_write_digit

            mov     rf, time_buf+4

            ldn     rf
            plo     rc
            mov     rf, bcd_buf
            call    tobcd8

            mov     rf, tens
            ldn     rf
            plo     rb
            ldi     2
            plo     ra
            call    led7_write_digit

            mov     rf, ones
            ldn     rf
            plo     rb
            ldi     3
            plo     ra
            call    led7_write_digit

            mov     rf, time_buf+5

            ldn     rf
            plo     rb
            call    led7_write_colon

            call    led7_write_disp

            lbr     wait

done:       sex     r3
            dis
            db      23h

            sex     r3

          #if RTC_GROUP
            out     EXP_PORT
            db      RTC_GROUP
          #endif

            out     RTC_PORT
            db      RTC_INT_DISABLE
            out     RTC_PORT
            db      INT_MASK
            out     RTC_PORT
            db      CLEAR_INT

          #if RTC_GROUP
            out     EXP_PORT              ; make sure default expander group
            db      NO_GROUP
          #endif

            sex     r2

            ldi     0
            rtn

time_buf:   ds      10
bcd_buf:    ds      1
tens:       ds      1
ones:       ds      1

.align      page

exiti:      ret

introu:     dec     r2
            sav
            dec     r2
            stxd
            shrc
            stxd

            sex     r1

          #if RTC_GROUP
            out     EXP_PORT                ; make sure default expander group
            db      RTC_GROUP
          #endif

            out     RTC_PORT
            db      RTC_REG | 0dh
            out     RTC_PORT
            db      CLEAR_INT

          #if RTC_GROUP
            out     EXP_PORT              ; make sure default expander group
            db      NO_GROUP
          #endif

            sex     r2

            dec     r8

exit:       inc     r2
            lda     r2
            shl
            lda     r2
            br      exiti

            end     start
