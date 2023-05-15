#define LED7_BLINK_OFF      0
#define LED7_BLINK_2HZ      1
#define LED7_BLINK_1HZ      2
#define LED7_BLINK_HALFHZ   3

            extrn   led7_init
            extrn   led7_set_blink_rate
            extrn   led7_set_brightness
            extrn   led7_clear
            extrn   led7_write_digit
            extrn   led7_write_disp
            extrn   led7_write_colon
            extrn   led7_write_blank
            