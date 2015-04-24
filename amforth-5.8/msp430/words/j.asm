
;C J        -- n   R: 4*sys -- 4*sys
;C                  get the second loop index
        CODEHEADER(XT_J,1,"j")
        SUB     #2,PSP          ; make room in TOS
        MOV     TOS,0(PSP)
        MOV     @RSP,TOS        ; index = loopctr - fudge
        SUB     2(RSP),TOS
        NEXT
