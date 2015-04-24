;C OVER    x1 x2 -- x1 x2 x1   per stack diagram
        CODEHEADER(XT_OVER,4,"over")
        MOV     @PSP,W          ; 2
        SUB     #2,PSP          ; 2
        MOV     TOS,0(PSP)      ; 4
        MOV     W,TOS           ; 1
        NEXT                    ; 4

