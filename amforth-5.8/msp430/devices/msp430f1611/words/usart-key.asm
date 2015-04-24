;C KEY      -- c      get character from keyboard
        CODEHEADER(XT_KEY,3,"key")
KEYLOOP:
        BIT.B   #URXIFG0,&IFG1
        JZ      KEYLOOP
        SUB     #2,PSP          ; 1  push old TOS..
        MOV     TOS,0(PSP)      ; 4  ..onto stack
        MOV.B   &U0RXBUF,TOS    ; read character into TOS
donext: NEXT
