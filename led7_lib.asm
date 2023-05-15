#include    include/opcodes.def
#include    include/bios.inc

            extrn   i2c_wrbuf
            extrn   led7_clear
            extrn   led7_write_disp
            extrn   led7_digits
            extrn   led7_display_buf
            extrn   led7_cmd_buf

#define COLON_OFFSET    5

CMD_BRIGHT: equ     0e0h
CMD_BLINK:  equ     080h
DISP_ON:    equ     001h
OSC_ON:     equ     021h

I2C_ADDR:   equ     070h

            proc    led7_write_disp

            call    i2c_wrbuf
            db      I2C_ADDR, 17
            dw      led7_display_buf

            rtn

            endp

.link       .align  page

            proc    led7_clear

            ghi     rd
            stxd
            glo     rd
            stxd
            glo     r9
            stxd
            mov     rd, led7_display_buf+1
            ldi     16
            plo     r9

clr_loop:   ldi     0
            str     rd
            inc     rd
            dec     r9
            glo     r9
            bnz     clr_loop

            irx
            ldxa
            plo     r9
            ldxa
            plo     rd
            ldx
            phi     rd
            rtn

            endp

            proc    led7_init

            call    i2c_wrbuf
            db      I2C_ADDR, 1
            dw      osc_on

            call    led7_clear

            call    led7_write_disp
            rtn
osc_on:     db  $21

            endp

            proc    led7_set_brightness

            ghi     rd
            stxd
            glo     rd
            stxd
            mov     rd, led7_cmd_buf
            glo     rb
            ani     0fh
            ori     CMD_BRIGHT
            str     rd
            call    i2c_wrbuf
            db      I2C_ADDR, 1
            dw      led7_cmd_buf

            irx
            ldxa
            plo     rd
            ldx
            phi     rd
            rtn

            endp

            proc    led7_set_blink_rate

            ghi     rd
            stxd
            glo     rd
            stxd
            mov     rd, led7_cmd_buf
            glo     rb
            shl
            ani     06h
            ori     CMD_BLINK | DISP_ON
            str     rd
            call    i2c_wrbuf
            db      I2C_ADDR, 1
            dw      led7_cmd_buf

            irx
            ldxa
            plo     rd
            ldx
            phi     rd
            rtn

            endp

            proc    led7_write_digit

            ghi     rc
            stxd
            glo     rc
            stxd
            ghi     rd
            stxd
            glo     rd
            stxd

            mov     rd, led7_display_buf+1
            glo     ra
            bz      set
            inc     rd
            inc     rd
            smi     1
            bz      set
            inc     rd
            inc     rd
            inc     rd
            inc     rd
            smi     1
            bz      set
            inc     rd
            inc     rd

set:        ldi     led7_digits.1
            phi     rc
            glo     rb
            ani     $0f
            adi     led7_digits.0
            plo     rc
            ldn     rc
            str     rd

            irx
            ldxa
            plo     rd
            ldxa
            phi     rd
            ldxa
            plo     rc
            ldx
            phi     rc

            rtn

            endp

            proc    led7_write_blank

            ghi     rd
            stxd
            glo     rd
            stxd

            mov     rd, led7_display_buf+1
            glo     ra
            bz      blank
            inc     rd
            inc     rd
            smi     1
            bz      blank
            inc     rd
            inc     rd
            inc     rd
            inc     rd
            smi     1
            bz      blank
            inc     rd
            inc     rd

blank:      ldi     0
            str     rd

            irx
            ldxa
            plo     rd
            ldx
            phi     rd

            rtn

            endp

            proc    led7_write_colon

            ghi     rd
            stxd
            glo     rd
            stxd
            mov     rd, led7_display_buf + COLON_OFFSET
            glo     rb
            ani     01h
            shl
            str     rd

            irx
            ldxa
            plo     rd
            ldx
            phi     rd
            rtn

            endp

.link       .align  para
            proc    led7_digits

            db      $3f
            db      $06
            db      $5b
            db      $4f
            db      $66
            db      $6d
            db      $7d
            db      $07
            db      $7f
            db      $6f
            db      $77
            db      $7c
            db      $39
            db      $5e
            db      $79
            db      $71

            endp

            proc    led7_cmd_buf
cmd:        ds      1

            endp

            proc    led7_display_buf
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00
            db      $00, $00, $00, $00, $00, $00

            endp

