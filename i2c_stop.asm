;------------------------------------------------------------------------
;This routine creates a STOP condition on the i2c bus.
;
;Register usage:
;   R2   points to an available memory location (typically top of stack)
;   R9.1 maintains the current state of the output port
;
            ghi     r9
            ori     SDA_LOW         ; SDA low
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SCL_HIGH        ; SCL high
            str     r2
            out     I2C_PORT
            dec     r2
            ani     SDA_HIGH        ; SDA high
            str     r2
            out     I2C_PORT
            dec     r2
            phi     r9              ; Update port data
