;C ROT    x1 x2 x3 -- x2 x3 x1  per stack diagram
        CODEHEADER(XT_ROT,3,"rot")
        MOV     @PSP,W          ; 2 fetch x2
        MOV     TOS,0(PSP)      ; 4 store x3
        MOV     2(PSP),TOS      ; 3 fetch x1
        MOV     W,2(PSP)        ; 4 store x2
        NEXT                    ; 4
