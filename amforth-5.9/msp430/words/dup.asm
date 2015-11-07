;C DUP      x -- x x      duplicate top of stack
        CODEHEADER(XT_DUP,3,"dup") 
PUSHTOS: SUB    #2,PSP          ; 1  push old TOS..
        MOV     TOS,0(PSP)      ; 4  ..onto stack
        NEXT                    ; 4
