
#include include/opcodes.def

            proc    tobcd8

            ldi     0
            str     rf
            glo     rc
            smi     200
            bl      lp100
            plo     rc
            ldn     rf
            adi     2
            str     rf
lp100:      glo     rc
            smi     100
            bl      lp80
            plo     rc
            ldn     rf
            adi     1
            str     rf
lp80:       inc     rf
            ldi     0
            str     rf
            glo     rc
            smi     80
            bl      lp40
            plo     rc
            ldn     rf
            adi     8
            str     rf
lp40:       glo     rc
            smi     40
            bl      lp20
            plo     rc
            ldn     rf
            adi     4
            str     rf
lp20:       glo     rc
            smi     20
            bl      lp10
            plo     rc
            ldn     rf
            adi     2
            str     rf
lp10:       glo     rc
            smi     10
            bl      lp1
            plo     rc
            ldn     rf
            adi     1
            str     rf
lp1:        inc     rf
            glo     rc
            str     rf
            rtn

            endp