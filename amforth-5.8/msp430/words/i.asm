;C I        -- n   R: sys1 sys2 -- sys1 sys2
;C                  get the innermost loop index
        CODEHEADER(XT_I,1,"i")
        SUB     #2,PSP          ; make room in TOS
        MOV     TOS,0(PSP)
        MOV     INDEX,TOS       ; index = loopctr - fudge
        SUB     LIMIT,TOS
        NEXT
