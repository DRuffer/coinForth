;C FILL   c-addr u char --  fill memory with char
        CODEHEADER(XT_FILL,4,"fill")
        MOV     @PSP+,X     ; count
        MOV     @PSP+,W     ; address
        CMP     #0,X
        JZ      FILL_X
FILL_1: MOV.B   TOS,0(W)    ; store char in memory
        ADD     #1,W
        SUB     #1,X
        JNZ     FILL_1
FILL_X: MOV     @PSP+,TOS   ; pop new TOS
        NEXT
