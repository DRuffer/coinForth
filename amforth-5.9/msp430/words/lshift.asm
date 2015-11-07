;C LSHIFT  x1 u -- x2    logical L shift u places
        CODEHEADER(LSHIFT,6,"lshift")
        MOV     @PSP+,W
        AND     #1Fh,TOS        ; no need to shift more than 16
        JZ      LSH_X
LSH_1:  ADD     W,W
        SUB     #1,TOS
        JNZ     LSH_1
LSH_X:  MOV     W,TOS
        NEXT
