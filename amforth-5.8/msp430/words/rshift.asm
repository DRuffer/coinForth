;C RSHIFT  x1 u -- x2    logical R shift u places
        CODEHEADER(RSHIFT,6,"rshift")
        MOV     @PSP+,W
        AND     #1Fh,TOS        ; no need to shift more than 16
        JZ      RSH_X
RSH_1:  CLRC
        RRC     W
        SUB     #1,TOS
        JNZ     RSH_1
RSH_X:  MOV     W,TOS
        NEXT
