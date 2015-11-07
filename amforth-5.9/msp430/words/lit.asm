;Z lit      -- x    fetch inline literal to stack
; This is the primtive compiled by LITERAL.
        HEADLESS(XT_DOLITERAL,PFA_DOLITERAL)
PFA_DOLITERAL:
        SUB #2,PSP      ; 1  push old TOS..
        MOV TOS,0(PSP)  ; 4  ..onto stack
        MOV @IP+,TOS    ; 2  fetch new TOS value
        NEXT            ; 4
